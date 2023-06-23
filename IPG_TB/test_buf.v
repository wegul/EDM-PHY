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
reg memq_write=1,netq_write=1;

wire [2:0] memq_space;
wire [2:0] netq_space;

wire memq_full,netq_full;

reg [519:0] ipg_reply;

wire [63:0] netq_outd;
wire [1:0] netq_outc;

wire [519:0] tx_ipg_data;

reg [63:0] encoded_tx_data_next;
reg [1:0] encoded_tx_hdr_next;

reg memfin=0;



wire [1:0] tuser;// pause signal backpressure
wire ipg_en;
wire netfin;
wire memq_read,
    netq_read,
    memq_reset,
    netq_reset,
    memq_empty,
    netq_empty;

initial begin
    clk = 1'b1;
    forever begin
        #1
        clk = ~clk;
    end
end



integer i=0;

initial begin
     #6
    encoded_tx_hdr_next=SYNC_CTRL;
    encoded_tx_data_next = 0;
    encoded_tx_data_next[15 : 8] = 8'haa;
    // encoded_tx_data_next=64'heeffeeeffff;
    encoded_tx_data_next[7:0]=BLOCK_TYPE_TERM_1;
    #2
    encoded_tx_data_next=64'hX;
    encoded_tx_hdr_next = 2'hX;

    for(i=0;i<520;i=i+1) begin
        ipg_reply[i]=1'b1;
    end
    ipg_reply[519 -:64] = 64'hccccaaaaccccaaaa;
    // ipg_reply[63 -: 64] = 64'hbbbbaaaabbbbaaaa;
    #2
    ipg_reply = 520'hX;
    encoded_tx_hdr_next=SYNC_DATA;
    encoded_tx_data_next = 64'hbb11223344556677;
    #4
    encoded_tx_hdr_next=SYNC_CTRL;
    encoded_tx_data_next = 0;
    encoded_tx_data_next[15 : 8] = 8'hbb;
    // encoded_tx_data_next=64'heeffeeeffff;
    encoded_tx_data_next[7:0]=BLOCK_TYPE_TERM_1;
    #2
    encoded_tx_data_next=64'hX;
    encoded_tx_hdr_next = 2'hX;
    for(i=0;i<520;i=i+1) begin
        ipg_reply[i]=1'b0;
    end
    ipg_reply[519 -:64] = 64'hddd00dddffffffff;
    ipg_reply[63:0] = 64'h6666666666666; 
    #2
    ipg_reply = 520'hX;
    #58
    $finish;
    



end




mem_fifo_buf memq(
    .data_in (ipg_reply),
    .reset(memq_reset),
    .read(memq_read),
    .write(memq_write),
    .clk (clk),
    .memfin(memfin),

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
    .memq_space(memq_space),
    .netq_space(netq_space),
    .memq_read(memq_read),
    .memq_reset(memq_reset),
    .memq_empty(memq_empty),
    .netq_read(netq_read),
    .netq_reset(memq_reset),
    .netq_empty(netq_empty),
    .netfin(netfin),

    .ipg_en(ipg_en),// if 1, tx ipg. else tx net frame
    .tuser(tuser)
);

endmodule