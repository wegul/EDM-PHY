module test_tx_ipg;

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

reg [519:0] tx_ipg_data;//From ipg_proc.v


//outputs
wire [63:0] proced_encoded_tx_data;
wire [6:0] tx_len;
wire [9:0] tx_payload_count;


initial begin
    clk = 1'b1;

    forever begin
        #1
        clk = ~clk;
    end

end

integer i=0;

initial begin
    #20
    encoded_tx_hdr_next=SYNC_CTRL;
    encoded_tx_data_next=0;
    encoded_tx_data_next[7:0]=BLOCK_TYPE_TERM_0;
    for(i=0;i<520;i=i+1) begin
        tx_ipg_data[i]=1'b1;
    end
    tx_ipg_data[519 -:64] = 64'hccccaaaaccccaaaa;
    tx_ipg_data[63 -: 64] = 64'hbbbbaaaabbbbaaaa;
    // #2
    // tx_ipg_data = 0;
    // tx_ipg_data[519 -:64] = 64'hbbb00bbbffffffff;
    #22
    $finish;



end



debug_ipg_tx UUT(
    .clk(clk),
    .encoded_tx_hdr_next(encoded_tx_hdr_next),
    .encoded_tx_data_next(encoded_tx_data_next),
    .tx_ipg_data(tx_ipg_data),
    .proced_encoded_tx_data(proced_encoded_tx_data),
    .tx_payload_count_reg(tx_payload_count),
    .tx_len(tx_len)
);


endmodule