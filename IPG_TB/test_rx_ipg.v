module test_rx_ipg;

    localparam DATA_WIDTH = 64;
    localparam CTRL_WIDTH = (DATA_WIDTH/8);
    localparam HDR_WIDTH = 2;
    localparam BIT_REVERSE = 0;
    localparam SCRAMBLER_DISABLE = 1;
    localparam PRBS31_ENABLE = 0;
    localparam TX_SERDES_PIPELINE = 0;
    localparam RX_SERDES_PIPELINE = 0;
    localparam BITSLIP_HIGH_CYCLES = 1;
    localparam BITSLIP_LOW_CYCLES = 8;
    localparam COUNT_125US = 125000/6.4;



    /*
     * XGMII interface
     */
wire [DATA_WIDTH-1:0] xgmii_txd;
wire [CTRL_WIDTH-1:0] xgmii_txc;
wire [DATA_WIDTH-1:0] xgmii_rxd;
wire [CTRL_WIDTH-1:0] xgmii_rxc;

    /*
     * SERDES interface
     */
wire [DATA_WIDTH-1:0] serdes_tx_data;
wire [HDR_WIDTH-1:0]  serdes_tx_hdr;

wire                  serdes_rx_bitslip;
wire                  serdes_rx_reset_req;

    /*
     * Status
     */
wire                  tx_bad_block;
wire [6:0]            rx_error_count;
wire                  rx_bad_block;
wire                  rx_sequence_error;
wire                  rx_block_lock;
wire                  rx_high_ber;
wire                  rx_status;

    /*
     * Configuration
     */
wire                  tx_prbs31_enable;
wire                  rx_prbs31_enable;

wire [DATA_WIDTH-1:0] rx_ipg_data;
wire [5:0] rx_len;

wire [5:0] space;


reg [DATA_WIDTH-1:0] serdes_rx_data;
reg [HDR_WIDTH-1:0]  serdes_rx_hdr;
reg rst=0, rx_rst, tx_rst, clk, rx_clk, tx_clk;
// wire [DATA_WIDTH-1:0] rx_ipg_data;

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

initial begin
   //Assign value here as stimulus

    // Generate the clock
    clk = 1'b0;
    forever begin
        #1
        clk = ~clk;
        rx_clk = ~rx_clk;
        tx_clk = ~tx_clk;
    end
end

initial begin
    rst = 1'b1;
    rx_rst = 1'b1;
    tx_rst = 1'b1;
    #1
    rst = 1'b0;
    rx_rst = 1'b0;
    tx_rst = 1'b0;
end


initial begin
#104
serdes_rx_hdr = SYNC_CTRL;
serdes_rx_data[7:0] = BLOCK_TYPE_CTRL;
serdes_rx_data[63:8] =56'h0000aabbccddee;
#2
serdes_rx_data[63:8] =56'h1111aabbccddee;
#2
serdes_rx_data[63:8] =56'h2222aabbccddee;
#2
serdes_rx_data[63:8] =56'h3333aabbccddee;
#2
serdes_rx_data[63:8] =56'h4444aabbccddee;
#2
serdes_rx_data[63:8] =56'h5555aabbccddee;
#2
serdes_rx_data[63:8] =56'h6666aabbccddee;
#2
serdes_rx_data[63:8] =56'h7777aabbccddee;




end

debug_eth_phy_10g UUT (
    .rx_clk(rx_clk),
    .rx_rst(rx_rst),
    .tx_clk(tx_clk),
    .tx_rst(tx_rst),
    .xgmii_txd(xgmii_txd),
    .xgmii_txc(xgmii_txc),
    .xgmii_rxd(xgmii_rxd),
    .xgmii_rxc(xgmii_rxc),
    .serdes_tx_data(serdes_tx_data),
    .serdes_tx_hdr(serdes_tx_hdr),
    .serdes_rx_data(serdes_rx_data),
    .serdes_rx_hdr(serdes_rx_hdr),
    .serdes_rx_bitslip(serdes_rx_bitslip),
    .rx_error_count(rx_error_count),
    .rx_bad_block(rx_bad_block),
    .rx_block_lock(rx_block_lock),
    .rx_high_ber(rx_high_ber),
    .tx_prbs31_enable(tx_prbs31_enable),
    .rx_prbs31_enable(rx_prbs31_enable),

    
    .rx_ipg_data(rx_ipg_data),
    .rx_len(rx_len),
    .qspace(space)
);


endmodule





