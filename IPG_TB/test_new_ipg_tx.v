module test_new_ipg_tx;

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



    reg clk = 0;
    reg [1:0] encoded_tx_hdr_next;
    reg [63:0] encoded_tx_data_next;

    reg [63:0] ipg_reply_chunk;//From ipg_proc.v
    reg [63:0] ipg_req_chunk;//From ipg_proc.v
    reg reset;


    //outputs
    wire [63:0] proced_encoded_tx_data;
    wire [1:0] proced_encoded_tx_hdr;
    wire [1:0] tuser;

    reg reqq_write=0,memq_write=0,netq_write=0;


    initial begin
        clk = 1'b1;
        forever begin
            #1
             clk = ~clk;
        end

    end

    integer i=0;

    initial begin
        #8
         reset=1;
        #2
         reset=0;
        #2
         reqq_write=1;
        ipg_req_chunk=64'hdddddddddaaaaaa;

        #2
         netq_write=1;
        reqq_write=0;
        encoded_tx_data_next=0;
        encoded_tx_data_next[7:0]=8'h1e;
        encoded_tx_hdr_next=SYNC_CTRL;
        #4

         netq_write=1;
        memq_write=0;
        reqq_write=1;
        ipg_req_chunk=64'heeeeeeeeffffffff;
        encoded_tx_hdr_next=SYNC_CTRL;
        encoded_tx_data_next = 0;
        encoded_tx_data_next[15 : 8] = 8'haa;
        // encoded_tx_data_next=64'heeffeeeffff;
        encoded_tx_data_next[7:0]=BLOCK_TYPE_TERM_1;

        #2
         netq_write=0;
        memq_write=1;
        reqq_write=1;
        ipg_req_chunk=64'haaaaaaeeffffffff;
        encoded_tx_data_next=64'hX;
        encoded_tx_hdr_next = 2'hX;

        ipg_reply_chunk = 64'hccccaaaaccccaa1e;
        // ipg_reply[63 -: 64] = 64'hbbbbaaaabbbbaaaa;
        #2
         netq_write=1;
        memq_write=0;
        reqq_write=0;
        ipg_reply_chunk = 64'hX;
        encoded_tx_hdr_next=SYNC_DATA;
        encoded_tx_data_next = 64'hbb11223344556677;
        #4
         netq_write=1;
        memq_write=1;
        ipg_reply_chunk= 64'h666666666666661e;
        reqq_write=0;
        encoded_tx_hdr_next=SYNC_DATA;
        encoded_tx_data_next = 0;
        encoded_tx_data_next[15 : 8] = 8'hbb;
        // encoded_tx_data_next=64'heeffeeeffff;
        encoded_tx_data_next[7:0]=BLOCK_TYPE_TERM_1;
        #2
         netq_write=0;
        memq_write=1;
        reqq_write=0;
        encoded_tx_data_next=64'hX;
        encoded_tx_hdr_next = 2'hX;

        ipg_reply_chunk= 64'h77777777777771e;
        #2
         netq_write=0;
        memq_write=0;
        reqq_write=0;
        ipg_reply_chunk = 64'hX;
        #8
         $finish;



    end

    ipg_tx UUT(
               .clk(clk),
               .reset(reset),
               .memq_write(memq_write),
               .netq_write(netq_write),
               .encoded_tx_hdr(encoded_tx_hdr_next),
               .encoded_tx_data(encoded_tx_data_next),
               .ipg_reply_chunk(ipg_reply_chunk),
               .tuser(tuser),
               .proced_encoded_tx_data(proced_encoded_tx_data),
               .proced_encoded_tx_hdr(proced_encoded_tx_hdr)
           );


endmodule
