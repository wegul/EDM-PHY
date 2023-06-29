module test_buf;
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

    reg clk;

    wire [3:0] memq_space;
    wire [3:0] netq_space;

    wire memq_full,netq_full;

    reg [63:0] ipg_reply_chunk;

    wire [63:0] netq_outd;
    wire [1:0] netq_outc;

    wire [63:0] tx_ipg_data;

    reg [63:0] encoded_tx_data_next;
    reg [1:0] encoded_tx_hdr_next;



    wire [1:0] tuser;// pause signal backpressure
    wire ipg_en;
    wire netfin;
    reg buf_reset;

    // reg memq_read=0,netq_read,memq_write,netq_write,memq_reset,netq_reset;
    // wire memq_empty,netq_empty;

    reg memq_write=0,netq_write=0;
    wire memq_read,
         netq_read,
         memq_reset,
         netq_reset,
         memq_empty,
         netq_empty,
         memq_full,netq_full;

    initial begin
        clk = 1'b1;
        forever begin
            #1
             clk = ~clk;
        end
    end



    integer i=0;


    initial begin
        #4
         buf_reset=1;
        #2
         buf_reset=0;
        #2
         memq_write=0;
        netq_write=1;
        encoded_tx_hdr_next=SYNC_CTRL;
        encoded_tx_data_next = 64'haaaaaaaaaabbbbbb;
        encoded_tx_data_next[7:0]=BLOCK_TYPE_TERM_1;
        #2
         netq_write=1;
        encoded_tx_hdr_next=SYNC_DATA;
        encoded_tx_data_next = 64'h1122334455667700;
        #2
         memq_write=1;
        ipg_reply_chunk = 64'h11111111111111111;
        netq_write=1;
        encoded_tx_hdr_next=SYNC_CTRL;
        encoded_tx_data_next = 64'hbb11223344556677;
        encoded_tx_data_next[7:0]=BLOCK_TYPE_TERM_1;


        #2
         netq_write=0;
        encoded_tx_hdr_next=2'hX;
        encoded_tx_data_next = 64'hX;
        memq_write=1;
        ipg_reply_chunk = 64'h222222222222222222;
        #2
         memq_write=1;
        ipg_reply_chunk = 64'h333333333333333333;

        netq_write=1;
        encoded_tx_hdr_next=SYNC_CTRL;
        encoded_tx_data_next=64'hbbbbbbbbbbbbbbbb;
        encoded_tx_data_next[7:0]=BLOCK_TYPE_TERM_1;
        #2
         netq_write=0;
        encoded_tx_data_next=64'hX;
        encoded_tx_hdr_next = 2'hX;
        memq_write=1;
        ipg_reply_chunk = 64'h66666666666666666;

        #2
         memq_write=0;
        ipg_reply_chunk = 64'hX;

        netq_write=1;
        encoded_tx_hdr_next=SYNC_CTRL;
        encoded_tx_data_next = 64'haaaaaaabbbbbb;
        // encoded_tx_data_next=64'heeffeeeffff;
        encoded_tx_data_next[7:0]=BLOCK_TYPE_TERM_1;
        #2
         netq_write=1;
        encoded_tx_hdr_next=SYNC_CTRL;
        encoded_tx_data_next = 64'hbb11223344556699;
        #2

        netq_write=0;
        encoded_tx_hdr_next=2'hX;
        encoded_tx_data_next = 64'hX;

        memq_write=1;
        ipg_reply_chunk = 64'h11111111111111111;
        #2
         netq_write=0;
        encoded_tx_hdr_next=2'hX;
        encoded_tx_data_next = 64'hX;

        memq_write=1;
        ipg_reply_chunk = 64'h222222222222222222;
        #2
         memq_write=1;
        ipg_reply_chunk = 64'h333333333333333333;

        netq_write=1;
        encoded_tx_hdr_next=SYNC_CTRL;
        encoded_tx_data_next = 64'hbbbbbbbbbbbbbbbb;
        encoded_tx_data_next[7:0]=BLOCK_TYPE_TERM_1;
        #2
         netq_write=0;
        encoded_tx_data_next=64'hX;
        encoded_tx_hdr_next = 2'hX;
        memq_write=1;
        ipg_reply_chunk = 64'h666666666666666;
        #2
         memq_write=0;
        ipg_reply_chunk = 64'hX;
        #16
         $finish;
    end

    // memq tb
    // initial begin
    //     #4
    //      memq_reset=1;
    //     #2
    //      memq_reset=0;
    //     #2
    //      memq_read=0;
    //     memq_write=1;
    //     ipg_reply_chunk=64'h11111111111111111;
    //     #2
    //      //  memq_read=1;
    //      ipg_reply_chunk=64'h222222222222222222;
    //     #2
    //      memq_read=1;
    //     ipg_reply_chunk=64'h333333333333333333;
    //     #2
    //      memq_read=1;
    //     ipg_reply_chunk=64'h44444444444444444;
    //     #2
    //     ipg_reply_chunk=64'hX;
    //     #2
    //      memq_write=1;
    //     memq_read=0;
    //     ipg_reply_chunk=64'h11111111111111111;
    //     #2
    //      //  memq_read=1;
    //      ipg_reply_chunk=64'h222222222222222222;
    //     #2
    //      memq_read=1;
    //     ipg_reply_chunk=64'h333333333333333333;
    //     #2
    //      memq_read=1;
    //     ipg_reply_chunk=64'h44444444444444444;
    //     #2
    //      ipg_reply_chunk=64'hZ;
    //     #8
    //      $finish;
    // end

    // netq tb
    // initial begin
    //     #4
    //      netq_reset=1;
    //     #2
    //      netq_reset=0;
    //     #2
    //      netq_read=0;
    //     netq_write=1;
    //     encoded_tx_data_next=64'h1111111111111100;
    //     encoded_tx_hdr_next=SYNC_DATA;
    //     #2
    //      encoded_tx_data_next=64'h1111111111111100;
    //     encoded_tx_hdr_next=SYNC_DATA;
    //     #2
    //      encoded_tx_data_next=64'h1111111111111199;
    //     encoded_tx_hdr_next=SYNC_CTRL;
    //     #2
    //      netq_read=1;
    //     #8
    //      $finish;

    // end



    mem_fifo_buf memq(
                     .w_data (ipg_reply_chunk),
                     .reset(memq_reset),
                     .rd(memq_read),
                     .wr(memq_write),
                     .clk (clk),

                     .r_data (tx_ipg_data),
                     .empty (memq_empty),
                     .full (memq_full),
                     .space(memq_space)
                 );

    // network frames bufferd here
    net_fifo_buf netq(
                     .w_data_d (encoded_tx_data_next),//this is from mac
                     .w_data_c (encoded_tx_hdr_next),
                     .reset(netq_reset),
                     .rd(netq_read),
                     .wr(netq_write),
                     .clk (clk),
                     //important
                     .r_data_d (netq_outd),
                     .r_data_c (netq_outc),
                     .netfin(netfin),
                     .empty (netq_empty),
                     .full (netq_full),
                     .space(netq_space)
                 );

    buf_mon monitor(
                .reset(buf_reset),
                .clk(clk),
                .memq_space(memq_space),
                .netq_space(netq_space),
                .memq_read(memq_read),
                .memq_reset(memq_reset),
                .memq_empty(memq_empty),
                .netq_read(netq_read),
                .netq_reset(netq_reset),
                .netq_empty(netq_empty),
                .netfin(netfin),

                .ipg_en(ipg_en),// if 1, tx ipg. else tx net frame
                .tuser(tuser)
            );

endmodule
