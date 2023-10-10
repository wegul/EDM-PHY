`resetall
`timescale 1ns / 1ps
`default_nettype none

//1. read the received IPG message
//2. generate message
// 3. transmit the generated message to output [63:0] ipg_msg
module ipg_wreq_proc(
        input wire clk,
        input wire reset,
        // The received frame.
        input wire [63:0] rx_ipg_data,
        input wire [5:0] rx_len,
        input wire wreq_valid,

        output reg [55:0] hdr_in,
        output reg [111:0] mem_addr_in,
        output reg [63:0] ipg_write_chunk//bytes in this variable will be written to RAM.
    );

    localparam HDR_WIDTH=16;//packets must be bigger than 16bits. this field is currently for payload length.
    localparam DATA_WIDTH=64;
    localparam ADR_WIDTH=12;

    localparam [7:0]
               BLOCK_TYPE_WRITE = 8'h1c, // I6 I5 I4 I3 I2 I1 I0 BT
               BLOCK_TYPE_WRITLAST = 8'h0c, // I6 I5 I4 I3 I2 I1 I0 BT
               BLOCK_TYPE_WRITFIRST = 8'h2c; // I6 I5 I4 I3 I2 I1 I0 BT
    reg [2:0] state_reg=3'd7, state_next;
    reg [55:0] hdr,src_mem_addr,dst_mem_addr;
    integer i;
    localparam [1:0]
               STATE_WAIT = 2'd0,// wreq's info field is exactly: header + blk1 + blk2;
               STATE_BLK1 = 2'd1, //this is for src_mem_addr
               STATE_BLK2 =2'd2, // dst_mem_addr
               STATE_BLKN = 2'd3;

    always @(*) begin
        state_next = STATE_WAIT;ipg_write_chunk=0;
        case(state_reg)
            STATE_WAIT: begin
                if (wreq_valid & rx_ipg_data[7:0]==BLOCK_TYPE_WRITFIRST) begin
                    hdr = rx_ipg_data[DATA_WIDTH-1 -: 56];
                    state_next = STATE_BLK1;
                    // $display("===\n case wait %h %d %d %d\n===",addr,j, state_reg,state_next);
                end
                else begin
                    state_next = STATE_WAIT;
                end
            end
            STATE_BLK1: begin
                if (wreq_valid & rx_ipg_data[7:0]==BLOCK_TYPE_WRITE) begin
                    src_mem_addr = rx_ipg_data[DATA_WIDTH-1 -: 56];
                    state_next = STATE_BLK2;
                end
                else state_next=STATE_BLK1;
            end
            STATE_BLK2: begin
                if (wreq_valid & rx_ipg_data[7:0]==BLOCK_TYPE_WRITE) begin
                    dst_mem_addr = rx_ipg_data[DATA_WIDTH-1 -: 56];
                    // send info to FakeDRAM, where reply is generated
                    hdr_in = hdr;
                    mem_addr_in = {{src_mem_addr},{dst_mem_addr}};
                    state_next = STATE_BLKN;
                end
                else state_next=STATE_BLK2;
            end
            STATE_BLKN: begin
                if (wreq_valid) begin
                    ipg_write_chunk = rx_ipg_data;
                    if (rx_ipg_data[7:0] == BLOCK_TYPE_WRITLAST) begin
                        state_next = STATE_WAIT;
                    end
                    else state_next = STATE_BLKN;
                end
                else state_next = STATE_WAIT;
            end
            default: begin
                state_next=STATE_WAIT;
            end
        endcase
    end

    always @(posedge clk) begin
        state_reg<=state_next;
    end
endmodule

module tb_ipg_wreq_proc;

    // Parameters and signals
    reg clk;
    reg reset;
    reg [63:0] rx_ipg_data;
    reg [5:0] rx_len;
    reg wreq_valid;
    wire [63:0] ipg_write_chunk;

    // Instantiate the module under test (MUT)
    ipg_wreq_proc uut (
                      .clk(clk),
                      .reset(reset),
                      .rx_ipg_data(rx_ipg_data),
                      .rx_len(rx_len),
                      .wreq_valid(wreq_valid),
                      .ipg_write_chunk(ipg_write_chunk)
                  );

    // Clock generation with 2ns period (1ns high, 1ns low)
    initial begin
        clk = 1;
        forever #1 clk = ~clk;
    end

    // Stimulus
    initial begin
        // Active-high reset for the first 6ns
        reset <= 1;
        #6 reset <= 0;

        // Test vectors
        rx_ipg_data <= 64'h0100102890ABCD2c;
        rx_len <= 6'd56;
        wreq_valid <= 1;
        #2
         rx_ipg_data <= 64'h1234567890ABCD1c;
        #2
         rx_ipg_data <= 64'h1234567890ABCD1c;
        #2
         rx_ipg_data <= 64'h1234567890ABCD1c;
        #2
         rx_ipg_data <= 64'h1234567890ABCD0c;

        // Simulate for a specific duration, if needed
        #10 $stop;  // Stop simulation after 100ns
    end

endmodule
