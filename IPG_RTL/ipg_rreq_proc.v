`resetall
`timescale 1ns / 1ps
`default_nettype none

//1. read the received IPG message
//2. generate message
// 3. transmit the generated message to output [63:0] ipg_msg
module ipg_rreq_proc(
        input wire clk,
        input wire reset,

        // The received frame.
        input wire [63:0] rx_ipg_data,
        input wire [5:0] rx_len,
        input wire rreq_valid,

        output wire [63:0] ipg_reply_chunk,
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

    localparam HDR_WIDTH=16;//packets must be bigger than 16bits. this field is currently for payload length.
    localparam DATA_WIDTH=64;
    localparam ADR_WIDTH=12;


    reg [2:0] state_reg=3'd7, state_next;
    reg fake_dram_en=0;
    reg [55:0] hdr,hdr_in,src_mem_addr,dst_mem_addr;
    reg [111:0] mem_addr_in;

    localparam [2:0]
               STATE_WAIT = 3'd0,
               STATE_BLK1 = 3'd1,// rreq is exactly: header + blk1 + blk2; this is for src_mem_addr
               STATE_BLK2 =3'd2;

    integer i =0;

    //TODO: using blocking assignment could lead to race. So change assignment of ipg_data* related variable to non-blocking (using ipg_data_next).
    always @(posedge clk) begin
        state_next = STATE_WAIT;
        case(state_reg)
            STATE_WAIT: begin
                fake_dram_en=0;src_mem_addr=0;dst_mem_addr=0;hdr=0;
                if (rreq_valid) begin
                    hdr = rx_ipg_data[DATA_WIDTH-1 -: 56];
                    state_next = STATE_BLK1;
                    // $display("===\n case wait %h %d %d %d\n===",addr,j, state_reg,state_next);
                end
                else begin
                    state_next = STATE_WAIT;
                end
            end
            STATE_BLK1: begin
                if (rreq_valid) begin
                    src_mem_addr = rx_ipg_data[DATA_WIDTH-1 -: 56];
                    state_next = STATE_BLK2;
                end
            end
            STATE_BLK2: begin
                if (rreq_valid) begin
                    dst_mem_addr = rx_ipg_data[DATA_WIDTH-1 -: 56];
                    // send info to FakeDRAM, where reply is generated
                    hdr_in = hdr;
                    mem_addr_in = {{src_mem_addr},{dst_mem_addr}};
                    fake_dram_en = 1;
                    state_next = STATE_WAIT;
                end
            end
            default: begin
                state_next=STATE_WAIT;
            end
        endcase
    end

    always @(posedge clk) begin
        state_reg<=state_next;
    end

    FakeDRAM fd (
                 .clk(clk),.rst(reset),
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
        parameter IPG_HDR_WIDTH = 16
    ) (
        input wire clk,rst,
        input wire fake_dram_en,
        input wire [111:0] mem_addr_in,
        input wire [55:0] hdr_in,
        output reg memq_write,
        output reg [DATA_WIDTH-1 : 0] ipg_reply_chunk
    );
    wire adrq_empty,adrq_full;
    reg adrq_read;
    reg [IPG_HDR_WIDTH-1 : 0] reply_len;
    reg [ADR_WIDTH/2 -1 : 0] src_port, dst_port;//original, need to swap
    reg [55 : 0] src_mem_addr, dst_mem_addr;//original, need to swap
    wire [55:0] hdr_out;
    wire [111:0] mem_addr_out;
    reg state=0, state_next;
    integer i;
    localparam
        STATE_WAIT = 1'd0,
        STATE_GEN = 1'd1;

    // assign adrq_read = adrq_empty ? 0:1;
    // assign src_mem_addr = mem_addr_out[ADR_WIDTH-1 -: ADR_WIDTH/2];
    // assign dst_mem_addr = mem_addr_out[ADR_WIDTH/2-1 : 0];

    always @(posedge clk) begin
        state_next=state;
        case (state)
            STATE_WAIT: begin
                memq_write=0;
                if (!adrq_empty) begin // start making up reply chunks
                    adrq_read=1;
                    reply_len = hdr_out[55 -: IPG_HDR_WIDTH];
                    src_port = hdr_out[55-IPG_HDR_WIDTH -: ADR_WIDTH/2];
                    dst_port = hdr_out[ADR_WIDTH/2 -1 : 0];
                    src_mem_addr = mem_addr_out[111 -: 56];
                    dst_mem_addr = mem_addr_out[55 : 0];
                    state_next=STATE_GEN;
                end
                else begin
                    adrq_read=0;
                    state_next=STATE_WAIT;
                end
            end
            STATE_GEN: begin
                adrq_read=0;
                memq_write = 1;
                // based on hdr.len, send out chunks
                if(reply_len>=56) begin
                    ipg_reply_chunk = {reply_len,src_port,dst_port,28'b0};
                    reply_len = reply_len - 56;
                end
                else begin
                    ipg_reply_chunk=0;
                    for ( i=1 ; i<=reply_len; i=i+1) begin
                        ipg_reply_chunk[i] = 1'b1;
                    end
                    reply_len=0;
                end

                if (reply_len == 0 ) begin
                    state_next = STATE_WAIT;
                end
                else state_next = STATE_GEN;
            end
        endcase
    end
    always @(posedge clk ) begin
        state<=state_next;
    end
    job_fifo_buf#(.DWIDTH(112), .CWIDTH(56), .DEPTH(6))
                adrq
                (
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

// STATE_REPLY: begin
//     ipg_reply = 0;
//     for (i = 0;i<MSG_COUNT**2; i=i+64) begin
//         if(i==0) ipg_reply[i +: 64] = {{i & 16'hFFFF},{src},{dst},{8'h2b}};
//         else if (i==64) ipg_reply[i +: 64] = {{src_mem_addr},{8'h1b}};
//         else if (i==128) ipg_reply[i +: 64] = {{dst_mem_addr},{8'h1b}};
//     end
//     ipg_reply[MSG_COUNT**2-1 -: 64] = {{i & 16'hFFFF},{src},{dst},{8'h0b}};
//     ipg_reply_count = MSG_COUNT**2;
//     state_next = STATE_MEMQ;// push generated reply to memq
//     addr=0;src=0;dst=0;src_mem_addr=0;dst_mem_addr=0;
// end
// STATE_MEMQ: begin
//     // ipg is already chunked, just send it
//     memq_write=1;
//     ipg_reply_chunk=64'hffffffffffffffff;
//     if (ipg_reply_count >= 64) begin
//         ipg_reply_chunk = ipg_reply[ipg_reply_count-1 -: 64];
//         ipg_reply_count = ipg_reply_count - 64;
//     end
// end

// STATE_MEMQ: begin
//     memq_write=1;// writing to memq, which is to transmit mem replies...
//     ipg_reply_chunk=64'hffffffffffffffff;
//     ipg_reply_chunk[7:0] = 8'h1c;
//     if (ipg_reply_count > 56) begin
//         ipg_reply_chunk[DATA_WIDTH-1:8] = ipg_reply[ipg_reply_count-1 -: 56];
//         ipg_reply_count = ipg_reply_count - 56;
//     end
//     else begin
//         for (i=0;i<ipg_reply_count;i=i+1) begin
//             ipg_reply_chunk[63-i] = ipg_reply[ipg_reply_count-i-1];
//         end
//         ipg_reply_count = 0;
//     end
//     if(ipg_reply_count == 0) begin
//         state_next = STATE_WAIT;
//     end
//     else state_next = STATE_MEMQ;
// end

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
        rx_ipg_data <= 64'h0100567890ABCD2a;
        rx_len <= 6'd56;;  // 2 in decimal
        rreq_valid <= 1;
        #2
         rx_ipg_data <= 64'h1234567890ABCD1a;
        #2
         rx_ipg_data <= 64'h1234567890ABCD0a;
        #2;

        rx_ipg_data <= 64'h01003453350ABC2a;
        #2
         rx_ipg_data <= 64'h53453453350ABC1a;
        #2
         rx_ipg_data <= 64'h53453453350ABC0a;
        #2;
        rreq_valid<=0;

        // Simulate for a specific duration, if needed
        #20 $stop;  // Stop simulation after 100ns
    end

endmodule
