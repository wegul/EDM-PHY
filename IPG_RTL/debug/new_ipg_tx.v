`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
    Transmit ipg data according to block type. 
    TODO: If the block is not large enough, wait til next block.
*/

module new_ipg_tx(
        input wire clk,

        //Give information about the next block
        // if this is a control frame to be sent and could fit in, then use it
        // else, msg needs to be pulled from queue monitor.
        input wire [1:0] encoded_tx_hdr_next,
        input wire [63:0] encoded_tx_data_next,
        input wire [63:0] ipg_reply_chunk,//From ipg_proc.v

        output reg [63:0] proced_encoded_tx_data,
        output reg [1:0] proced_encoded_tx_hdr,

        output wire [1:0] tuser,

        //for debug
        // output reg [9:0] tx_payload_count_reg,// msg left to be sent
        output reg [6:0] tx_len


        //debug
        //    output wire [519:0] tx_ipg_data,// msg to be transmitted. this is from memq
        //     output wire netfin,
        //     output wire ipg_en,
        //     output reg memfin
    );



    localparam [1:0]
               SYNC_DATA = 2'b10,
               SYNC_CTRL = 2'b01;

    localparam [7:0]
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


    // reg [9:0] tx_payload_count_reg=10'd512;// msg left to be sent
    // reg [5:0] tx_len=0;
    wire memq_empty,
         memq_full,
         netq_empty,
         netq_full,
         memq_write,
         netq_write,
         memq_read,
         netq_read,
         memq_reset,
         netq_reset;


    reg [1:0] netq_inc;
    reg [63:0] netq_ind;
    wire [1:0] netq_outc;
    wire [63:0] netq_outd;
    wire [2:0] netq_space;
    wire [2:0] memq_space;


    wire [63:0] tx_ipg_data;// msg to be transmitted. this is from memq

    wire netfin;
    wire ipg_en;



    // Queue management
    // ipg msg to be sent
    mem_fifo_buf memq(
                     .data_in (ipg_reply_chunk),
                     .reset(memq_reset),
                     .read(memq_read),
                     .write(memq_write),
                     .clk (clk),
                     .data_out (tx_ipg_data),
                     .empty (memq_empty),
                     .full (memq_full),
                     .space(memq_space)
                 );

    // network frames bufferd here
    net_fifo_buf netq(
                     .data_ind (encoded_tx_data_next),//this is from mac
                     .data_inc (encoded_tx_hdr_next),
                     .reset(netq_reset),
                     .read(netq_read),
                     .write(netq_write),
                     .clk (clk),
                     //important
                     .data_outd (netq_outd),
                     .data_outc (netq_outc),
                     .netfin(netfin),

                     .empty (netq_empty),
                     .full (netq_full),
                     .space(netq_space)
                 );

    buf_mon monitor(
                .clk(clk),
                .memq_read (memq_read),
                .netq_read (netq_read),
                .memq_reset (memq_reset),
                .netq_reset (netq_reset),
                .memq_space(memq_space),
                .netq_space(netq_space),
                .memq_empty(memq_empty),
                .netq_empty(netq_empty),
                .netfin(netfin),
                .tuser(tuser),
                .ipg_en(ipg_en)// if 1, tx ipg. else tx net frame
            );

    assign netq_write =1'b1;
    assign memq_write =1'b1;

    integer i=0;


    /*
        if ipg is enabled, then check if network packet is finished.
        then buffer all network frames, making
        SYNC_DATA intp SYNC_CTRL.
        and should read something out of memq.
    */
    always@(posedge clk) begin
        if (ipg_en) begin
            proced_encoded_tx_hdr <= SYNC_CTRL;
            proced_encoded_tx_data <= tx_ipg_data;
            //TODO: 7777 means this is a IPG stream control block..
        end

        else begin
            // send network frames and buffer ipg messages
            proced_encoded_tx_hdr <= netq_outc;
            proced_encoded_tx_data <= netq_outd;
        end


    end

endmodule
