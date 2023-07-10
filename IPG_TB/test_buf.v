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
    wire [3:0] reqq_space;

    wire memq_full,netq_full;

    reg [63:0] ipg_reply_chunk;
    reg [63:0] ipg_req_chunk;

    wire [63:0] netq_outd;
    wire [1:0] netq_outc;

    wire [63:0] tx_ipg_mem;
    wire [63:0] tx_ipg_req;


    reg [63:0] encoded_tx_data_next;
    reg [1:0] encoded_tx_hdr_next;



    wire [1:0] tuser;// pause signal backpressure
    wire [1:0] mon_sel;
    wire netfin;
    reg buf_reset;

    // reg memq_read=0,netq_read,memq_write,netq_write,memq_reset,netq_reset;
    // wire memq_empty,netq_empty;

    reg memq_write=0,netq_write=0,reqq_write=0;
    wire memq_read,
         netq_read,
         reqq_read,
         memq_reset,
         netq_reset,
         reqq_reset,
         memq_empty,
         netq_empty,
         reqq_empty,
         reqq_full,
         memq_full,
         netq_full;

    initial begin
        clk = 1'b1;
        forever begin
            #1
             clk = ~clk;
        end
    end



    integer i=0;


    // initial begin
    //     #4
    //      buf_reset=1;
    //     #2
    //      buf_reset=0;
    //     #2
    //      memq_write=0;
    //     netq_write=1;
    //     encoded_tx_hdr_next=SYNC_CTRL;
    //     encoded_tx_data_next = 64'haaaaaaaaaabbbbbb;
    //     encoded_tx_data_next[7:0]=BLOCK_TYPE_TERM_1;
    //     #2
    //      netq_write=1;
    //     encoded_tx_hdr_next=SYNC_DATA;
    //     encoded_tx_data_next = 64'h1122334455667700;
    //     #2
    //      memq_write=1;
    //     ipg_reply_chunk = 64'h11111111111111111;
    //     netq_write=1;
    //     encoded_tx_hdr_next=SYNC_CTRL;
    //     encoded_tx_data_next = 64'hbb11223344556677;
    //     encoded_tx_data_next[7:0]=BLOCK_TYPE_TERM_1;
    //     reqq_write=1;
    //     ipg_req_chunk=64'heeecffccccccccc;

    //     #2
    //      reqq_write=0;
    //     netq_write=0;
    //     encoded_tx_hdr_next=2'hX;
    //     encoded_tx_data_next = 64'hX;
    //     memq_write=1;
    //     ipg_reply_chunk = 64'h222222222222222222;
    //     #2
    //      reqq_write=1;
    //     ipg_req_chunk=64'hbbbbbbbbbcccc;
    //     memq_write=1;
    //     ipg_reply_chunk = 64'h333333333333333333;

    //     netq_write=1;
    //     encoded_tx_hdr_next=SYNC_CTRL;
    //     encoded_tx_data_next=64'hbbbbbbbbbbbbbbbb;
    //     encoded_tx_data_next[7:0]=BLOCK_TYPE_TERM_1;
    //     #2
    //      reqq_write=0;
    //     netq_write=0;
    //     encoded_tx_data_next=64'hX;
    //     encoded_tx_hdr_next = 2'hX;
    //     memq_write=1;
    //     ipg_reply_chunk = 64'h66666666666666666;

    //     #2
    //      memq_write=0;
    //     ipg_reply_chunk = 64'hX;

    //     netq_write=1;
    //     encoded_tx_hdr_next=SYNC_CTRL;
    //     encoded_tx_data_next = 64'haaaaaaabbbbbb;
    //     // encoded_tx_data_next=64'heeffeeeffff;
    //     encoded_tx_data_next[7:0]=BLOCK_TYPE_TERM_1;
    //     #2
    //      netq_write=1;
    //     encoded_tx_hdr_next=SYNC_CTRL;
    //     encoded_tx_data_next = 64'hbb11223344556699;
    //     #2

    //      netq_write=0;
    //     encoded_tx_hdr_next=2'hX;
    //     encoded_tx_data_next = 64'hX;

    //     memq_write=1;
    //     ipg_reply_chunk = 64'h11111111111111111;
    //     #2
    //      netq_write=0;
    //     encoded_tx_hdr_next=2'hX;
    //     encoded_tx_data_next = 64'hX;

    //     memq_write=1;
    //     ipg_reply_chunk = 64'h222222222222222222;
    //     #2
    //      memq_write=1;
    //     ipg_reply_chunk = 64'h333333333333333333;

    //     netq_write=1;
    //     encoded_tx_hdr_next=SYNC_CTRL;
    //     encoded_tx_data_next = 64'hbbbbbbbbbbbbbbbb;
    //     encoded_tx_data_next[7:0]=BLOCK_TYPE_TERM_1;
    //     #2
    //      netq_write=0;
    //     encoded_tx_data_next=64'hX;
    //     encoded_tx_hdr_next = 2'hX;
    //     memq_write=1;
    //     ipg_reply_chunk = 64'h666666666666666;
    //     #2
    //      memq_write=0;
    //     ipg_reply_chunk = 64'hX;
    //     #16
    //      $finish;
    // end



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
                .clk(clk),
                .reset(buf_reset),
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

                .netfin(netfin),
                .tuser(tuser),
                .sel(mon_sel)// if 1, tx ipg. else tx net frame
            );
endmodule
