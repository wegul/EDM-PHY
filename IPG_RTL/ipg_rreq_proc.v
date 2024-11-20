`resetall `timescale 1ns / 1ps `default_nettype none

//1. read the received IPG message
//2. generate message
// 3. transmit the generated message to output [63:0] ipg_msg
module ipg_rreq_proc #(
    parameter HDR_WIDTH=16,//packets must be bigger than 16bits. this field is currently for payload length.
    parameter DATA_WIDTH = 64,
    parameter ADR_WIDTH = 12
) (
    input wire clk,
    input wire reset,

    // The received frame.
    input wire [DATA_WIDTH-1:0] rx_ipg_data,
    input wire [5:0] rx_len,
    input wire rreq_valid,

    output wire [DATA_WIDTH-1:0] ipg_reply_chunk,
    output wire memq_write
);
  /* 1. parse ipg_reply. The format is: 2bit hdr: 00 c_read, 01 c_write, 10 d_read, 11 d_write.
    c_read means it is a control msg and the payload data is addr to be read.
    d_read means it is a data msg and the payload is answer to a read request.

    d_write means it is a control msg and the payload could be either addr or memory data.

     2. ipg_proc should use a state machine to wait for 64bit address. 
     
     3. If read, ipg_proc return Memory data = repeat the 64bit address 8 times

     3. If write. ipg_proc should use the state machine to wait for 512bit memory data.
    */


  reg [1:0] state_reg = 2'd3, state_next;
  reg fake_dram_en = 0, fake_dram_en_next;
  reg [55:0] hdr, hdr_in, hdr_in_next, src_mem_addr, dst_mem_addr;
  reg [111:0] mem_addr_in, mem_addr_in_next;
  localparam [7:0] BLOCK_TYPE_READFIRST = 8'h0a,  // I6 I5 I4 I3 I2 I1 I0 BT
  BLOCK_TYPE_RESPFIRST = 8'h0b,  // I6 I5 I4 I3 I2 I1 I0 BT
  BLOCK_TYPE_WRITFIRST = 8'h0c,  // I6 I5 I4 I3 I2 I1 I0 BT

  BLOCK_TYPE_READ = 8'h1a,  // I6 I5 I4 I3 I2 I1 I0 BT
  BLOCK_TYPE_RRESP = 8'h1b,  // I6 I5 I4 I3 I2 I1 I0 BT
  BLOCK_TYPE_WRITE = 8'h1c,  // I6 I5 I4 I3 I2 I1 I0 BT

  BLOCK_TYPE_READLAST = 8'h2a,  // I6 I5 I4 I3 I2 I1 I0 BT
  BLOCK_TYPE_RESPLAST = 8'h2b,  // I6 I5 I4 I3 I2 I1 I0 BT
  BLOCK_TYPE_WRITLAST = 8'h2c;  // I6 I5 I4 I3 I2 I1 I0 BT
  localparam [1:0] STATE_WAIT = 2'd0,  // rreq is exactly: header + blk1 + blk2;
  STATE_BLK1 = 2'd1,  //this is for src_mem_addr
  STATE_BLK2 = 2'd2;

  integer i = 0;

  always @(*) begin
    state_next = STATE_WAIT;
    fake_dram_en_next = 0;
    hdr_in_next = 0;
    mem_addr_in_next = 0;
    case (state_reg)
      STATE_WAIT: begin
        if (rreq_valid & (rx_ipg_data[7:0] == BLOCK_TYPE_READFIRST)) begin
          hdr = rx_ipg_data[DATA_WIDTH-1-:56];
          state_next = STATE_BLK1;
        end else begin
          state_next = STATE_WAIT;
        end
      end
      STATE_BLK1: begin
        if (rreq_valid & (rx_ipg_data[7:0] == BLOCK_TYPE_READ)) begin
          src_mem_addr = rx_ipg_data[DATA_WIDTH-1-:56];
          state_next   = STATE_BLK2;
        end else state_next = STATE_BLK1;
      end
      STATE_BLK2: begin
        if (rreq_valid & (rx_ipg_data[7:0] == BLOCK_TYPE_READLAST)) begin
          dst_mem_addr = rx_ipg_data[DATA_WIDTH-1-:56];
          // send info to FakeDRAM, where reply is generated
          hdr_in_next = hdr;
          mem_addr_in_next = {{src_mem_addr}, {dst_mem_addr}};
          fake_dram_en_next = 1;
          state_next = STATE_WAIT;
        end else state_next = STATE_BLK2;
      end
      default: begin
        state_next = STATE_WAIT;
      end
    endcase
  end

  always @(posedge clk) begin
    if (reset) begin
      state_reg <= 0;
      fake_dram_en <= 0;
      mem_addr_in <= 0;
      hdr_in <= 0;
    end else begin
      fake_dram_en <= fake_dram_en_next;
      state_reg <= state_next;
      mem_addr_in <= mem_addr_in_next;
      hdr_in <= hdr_in_next;
    end
  end

  FakeDRAM fd (
      .clk(clk),
      .rst(reset),
      .fake_dram_en(fake_dram_en),
      .hdr_in(hdr_in),
      .mem_addr_in(mem_addr_in),
      .memq_write(memq_write),
      .ipg_reply_chunk(ipg_reply_chunk)
  );
endmodule

/*
TODO: receiver should give periodic feedback about buffer occupancy of this FakeDRAM
 so that you know how many packets can be admitted (for congestion control).
*/
module FakeDRAM #(
    parameter DATA_WIDTH = 64,
    parameter ADR_WIDTH = 12,
    parameter IPG_HDR_WIDTH = 16,
    parameter LENGTH_FIELD = 8
) (
    input wire clk,
    rst,
    input wire fake_dram_en,
    input wire [111:0] mem_addr_in,
    input wire [55:0] hdr_in,
    output reg memq_write,
    output reg [DATA_WIDTH-1 : 0] ipg_reply_chunk
);

  wire adrq_empty, adrq_full;
  reg adrq_read, adrq_read_next, first_resp, first_resp_next, memq_write_next;
  reg [LENGTH_FIELD-1 : 0] reply_len, reply_len_next;
  reg [ADR_WIDTH/2 -1 : 0]
      src_port, src_port_next, dst_port, dst_port_next;  //original, need to swap
  reg [DATA_WIDTH-1 : 0] ipg_reply_chunk_next;
  reg [55 : 0]
      src_mem_addr, src_mem_addr_next, dst_mem_addr, dst_mem_addr_next;  //original, need to swap
  wire [ 55:0] hdr_out;
  wire [111:0] mem_addr_out;
  reg state = 0, state_next;
  integer i;
  localparam STATE_WAIT = 1'd0, STATE_GEN = 1'd1;
  always @(*) begin
    state_next = state;
    adrq_read_next = 0;
    memq_write_next = 0;
    ipg_reply_chunk_next = 0;
    reply_len_next = 0;
    first_resp_next = 0;
    src_port_next = 0;
    dst_port_next = 0;
    src_mem_addr_next = 0;
    dst_mem_addr_next = 0;
    case (state)
      STATE_WAIT: begin
        if (!adrq_empty) begin  // start making up reply chunks
          adrq_read_next = 1;
          reply_len_next = hdr_out[55-:LENGTH_FIELD];
          src_port_next = hdr_out[55-IPG_HDR_WIDTH-:ADR_WIDTH/2];
          dst_port_next = hdr_out[55-IPG_HDR_WIDTH-ADR_WIDTH/2-:ADR_WIDTH/2];
          src_mem_addr_next = mem_addr_out[111-:56];
          dst_mem_addr_next = mem_addr_out[55 : 0];
          state_next = STATE_GEN;

          first_resp_next = 1;  //response header
        end else begin
          adrq_read_next = 0;
          state_next = STATE_WAIT;
        end
      end
      STATE_GEN: begin
        if (reply_len == 0) begin
          state_next = STATE_WAIT;
        end else begin
          state_next = STATE_GEN;
          adrq_read_next = 0;
          memq_write_next = 1;
          // based on hdr.len, send out chunks
          if (reply_len >= 56) begin
            if (first_resp) begin
              ipg_reply_chunk_next = {reply_len, src_port, dst_port, 28'h1111111, 8'h0b};
              first_resp_next = 0;
            end else begin
              ipg_reply_chunk_next = {16'hdddd, src_port, dst_port, 28'h2222222, 8'h1b};
            end
            reply_len_next = reply_len - 56;
          end else begin
            ipg_reply_chunk_next = 64'hffffffffffffff2b;
            reply_len_next = 0;
          end
        end
      end
    endcase
  end
  always @(posedge clk) begin
    state <= state_next;
    reply_len <= reply_len_next;
    first_resp <= first_resp_next;
    memq_write <= memq_write_next;
    adrq_read <= adrq_read_next;
    ipg_reply_chunk <= ipg_reply_chunk_next;

    src_port <= src_port_next;
    dst_port <= dst_port_next;
    src_mem_addr <= src_mem_addr_next;
    dst_mem_addr <= dst_mem_addr_next;

  end
  job_fifo_buf #(
      .DWIDTH(112),
      .CWIDTH(56),
      .DEPTH (6)
  ) adrq (
      .clk(clk),
      .reset(rst),
      .rd(adrq_read),
      .wr(fake_dram_en),
      .w_data_d(mem_addr_in),
      .w_data_c(hdr_in),
      .empty(adrq_empty),
      .full(adrq_full),
      .r_data_d(mem_addr_out),
      .r_data_c(hdr_out),
      .space()
  );

endmodule


module tb_ipg_rreq_proc;
  reg clk;
  reg reset;

  reg [63:0] rx_ipg_data;
  reg [5:0] rx_len;
  reg rreq_valid;

  wire [63:0] ipg_reply_chunk;
  wire memq_write;

  // Instantiate the module under test (MUT)
  ipg_rreq_proc uut (
      .clk(clk),
      .reset(reset),
      .rx_ipg_data(rx_ipg_data),
      .rx_len(rx_len),
      .rreq_valid(rreq_valid),
      .ipg_reply_chunk(ipg_reply_chunk),
      .memq_write(memq_write)
  );

  // Clock generation with 2ns period (1ns high, 1ns low)
  initial begin
    clk = 1;
    forever #1 clk = ~clk;
  end

  // Stimulus
  initial begin
    // Active-high reset for the first 6ns
    reset = 1;
    #6 reset = 0;

    // Test vectors
    rx_ipg_data[63-:16] <= 16'ha000;  //64'h0100 56789 0ABCD 0a;
    rx_ipg_data[47-:6] <= 6'd0;
    rx_ipg_data[41-:6] <= 6'd2;
    rx_ipg_data[35-:28] <= 0;
    rx_ipg_data[7 : 0] <= 8'h0a;
    rx_len <= 6'd56;
    ;  // 2 in decimal
    rreq_valid <= 1;
    #2 rx_ipg_data <= 64'h1234567890ABCD1a;
    #2 rx_ipg_data <= 64'h1234567890ABCD2a;
    #2;

    rx_ipg_data <= 64'h01003453350ABC0a;
    #2 rx_ipg_data <= 64'h53453453350ABC1a;
    #2 rx_ipg_data <= 64'h53453453350ABC2a;
    #2;
    rreq_valid <= 0;

    // Simulate for a specific duration, if needed
    #20 $stop;  // Stop simulation after 100ns
  end

endmodule
