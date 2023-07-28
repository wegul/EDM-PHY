`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
    Transmit ipg data according to block type. 
    TODO: If the block is not large enough, wait til next block.
*/

module ipg_tx
    (
        input wire clk,
        input wire reset,
        input wire memq_write,
        input wire netq_write,
        input wire reqq_write,


        //Give information about the next block
        // if this is a control frame to be sent and could fit in, then use it
        // else, msg needs to be pulled from queue monitor.
        input wire [1:0] encoded_tx_hdr,
        input wire [63:0] encoded_tx_data,
        input wire [63:0] ipg_reply_chunk,//From ipg_proc.v
        input wire [63:0] ipg_req_chunk,// from user logic

        output reg [63:0] proced_encoded_tx_data,
        output reg [1:0] proced_encoded_tx_hdr,

        output wire tx_pause

    );


    localparam [1:0]
               SEND_REQ = 2'b01,
               SEND_MEM = 2'b10,
               SEND_NET = 2'b11;

    localparam [1:0]
               SYNC_DATA = 2'b10,
               SYNC_CTRL = 2'b01;

    localparam [7:0]
               BLOCK_TYPE_REQ = 8'h1a, // I6 I5 I4 I3 I2 I1 I0 BT
               BLOCK_TYPE_RESP = 8'h1f, // I6 I5 I4 I3 I2 I1 I0 BT

               BLOCK_TYPE_CTRL     = 8'h1e, // C7 C6 C5 C4 C3 C2 C1 C0 BT
               BLOCK_TYPE_OS_4     = 8'h2d, // D7 D6 D5 O4 C3 C2 C1 C0 BT
               BLOCK_TYPE_START_4  = 8'h33, // D7 D6 D5    C3 C2 C1 C0 BT
               BLOCK_TYPE_OS_START = 8'h66, // D7 D6 D5    O0 D3 D2 D1 BT
               BLOCK_TYPE_OS_04    = 8'h55, // D7 D6 D5 O4 O0 D3 D2 D1 BT
               BLOCK_TYPE_START_0  = 8'h78, // D7 D6 D5 D4 D3 D2 D1    BT
               BLOCK_TYPE_OS_0     = 8'h4b, // C7 C6 C5 C4 O0 D3 D2 D1 BT
               BLOCK_TYPE_TERM_0   = 8'h87, // C7 C6 C5 C4 C3 C2 C1    BT
               BLOCK_TYPE_TERM_1   = 8'h99, // C7 C6 C5 C4 C3 C2    D0 BT
               BLOCK_TYPE_TERM_2   = 8'haa, // C7 C6 C5 C4 C3    D1 D0 BT
               BLOCK_TYPE_TERM_3   = 8'hb4, // C7 C6 C5 C4    D2 D1 D0 BT
               BLOCK_TYPE_TERM_4   = 8'hcc, // C7 C6 C5    D3 D2 D1 D0 BT
               BLOCK_TYPE_TERM_5   = 8'hd2, // C7 C6    D4 D3 D2 D1 D0 BT
               BLOCK_TYPE_TERM_6   = 8'he1, // C7    D5 D4 D3 D2 D1 D0 BT
               BLOCK_TYPE_TERM_7   = 8'hff; //    D6 D5 D4 D3 D2 D1 D0 BT


    wire memq_empty,
         memq_full,
         netq_empty,
         netq_full,
         memq_read,
         netq_read,
         memq_reset,
         netq_reset,
         reqq_empty,
         reqq_full,
         reqq_read,
         reqq_reset;


    wire [1:0] netq_outc;
    wire [63:0] netq_outd;
    wire [3:0] memq_space,reqq_space;
    wire [5:0] netq_space;

    wire [63:0] tx_ipg_mem;// msg to be transmitted. this is from memq
    wire [63:0] tx_ipg_req;// msg to be transmitted. this is from reqq

    wire [1:0] mon_sel;


    // Queue management

    // ipg req to be sent
    req_fifo_buf reqq(
                     .w_data (ipg_req_chunk),
                     .reset(reqq_reset),
                     .rd(reqq_read),
                     .wr(reqq_write),
                     .clk (clk),
                     .r_data (tx_ipg_req),
                     .empty (reqq_empty),
                     .full (reqq_full),
                     .space(reqq_space)
                 );

    // ipg msg to be sent
    mem_fifo_buf memq(
                     .w_data (ipg_reply_chunk),
                     .reset(memq_reset),
                     .rd(memq_read),
                     .wr(memq_write),
                     .clk (clk),
                     .r_data (tx_ipg_mem),
                     .empty (memq_empty),
                     .full (memq_full),
                     .space(memq_space)
                 );

    // network frames bufferd here
    net_fifo_buf netq(
                     .w_data_d(encoded_tx_data),//this is from mac
                     .w_data_c (encoded_tx_hdr),
                     .reset(netq_reset),
                     .rd(netq_read),
                     .wr(netq_write),
                     .clk (clk),
                     //important
                     .r_data_d (netq_outd),
                     .r_data_c (netq_outc),

                     .empty (netq_empty),
                     .full (netq_full),
                     .space(netq_space)
                 );

    buf_mon monitor(
                .clk(clk),
                .reset(reset),
                .memq_read (memq_read),
                .netq_read (netq_read),
                .memq_reset (memq_reset),
                .netq_reset (netq_reset),
                .memq_space(memq_space),
                .netq_space(netq_space),
                .memq_empty(memq_empty),
                .netq_empty(netq_empty),

                .reqq_read(reqq_read),
                .reqq_reset(reqq_reset),
                .reqq_space(reqq_space),
                .reqq_empty(reqq_empty),

                .tx_pause(tx_pause),
                .sel(mon_sel)// if 1, tx ipg. else tx net frame
            );


    integer i=0;
    /*
        if ipg is enabled, then check if network packet is finished.
        then buffer all network frames, making
        SYNC_DATA intp SYNC_CTRL.
        and should read something out of memq.
    */
    always@(*) begin
        case(mon_sel)
            SEND_MEM: begin
                proced_encoded_tx_hdr = SYNC_CTRL;
                proced_encoded_tx_data = tx_ipg_mem;
            end
            SEND_REQ: begin
                proced_encoded_tx_hdr = SYNC_CTRL;
                proced_encoded_tx_data = tx_ipg_req;
            end
            SEND_NET: begin
                proced_encoded_tx_hdr = netq_outc;
                proced_encoded_tx_data = netq_outd;
            end
            default: begin
                proced_encoded_tx_hdr = SYNC_CTRL;
                proced_encoded_tx_data = 64'h0000000000000001e;
            end
        endcase
    end

endmodule
