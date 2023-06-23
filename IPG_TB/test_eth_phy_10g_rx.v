module test_eth_phy_10g_rx;

parameter HDR_WIDTH = 2;
parameter BIT_REVERSE = 0;
parameter SCRAMBLER_DISABLE = 1;
parameter PRBS31_ENABLE = 0;
parameter TX_SERDES_PIPELINE = 2;
parameter RX_SERDES_PIPELINE = 2;
parameter BITSLIP_HIGH_CYCLES = 1;
parameter BITSLIP_LOW_CYCLES = 8;
parameter COUNT_125US = 125000/6.4;

parameter DATA_WIDTH = 64;
parameter KEEP_WIDTH = (DATA_WIDTH/8);
parameter CTRL_WIDTH = (DATA_WIDTH/8);

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg rx_clk = 0;
reg rx_rst = 0;
reg tx_clk = 0;
reg tx_rst = 0;

//inputs


reg [DATA_WIDTH-1:0] serdes_rx_data;
reg [HDR_WIDTH-1:0] serdes_rx_hdr;

reg rx_prbs31_enable = 0;

// Outputs

wire serdes_rx_bitslip;
wire [6:0] rx_error_count;
wire rx_bad_block;
wire rx_block_lock;
wire rx_high_ber;

wire [DATA_WIDTH-1:0] xgmii_rxd;
wire [CTRL_WIDTH-1:0] xgmii_rxc;


//IPG Customize
wire [DATA_WIDTH-1:0] rx_ipg_data;

// wire [DATA_WIDTH-1:0] recoved_encoded_rx_data;


// //echo
// assign serdes_rx_data = serdes_tx_data;
// assign serdes_rx_hdr = serdes_tx_hdr;

initial begin

//Assign value here as stimulus
    // Generate the clock
    //For timing simu, try 4ns per half cycle
    clk = 1'b1;
    rx_clk = 1'b1;
    tx_clk = 1'b1;
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

    //For timing/functional simulation 104ns. For behavioral, 20ns
    #104
    serdes_rx_data = 64'h112233445566771e;
    serdes_rx_hdr = 2'h01;
    #2
    serdes_rx_data = 64'h1122334455660087;
    serdes_rx_hdr = 2'h01;

   

end



eth_phy_10g_rx #(
    .DATA_WIDTH(DATA_WIDTH),
    .CTRL_WIDTH(CTRL_WIDTH),
    .HDR_WIDTH(HDR_WIDTH),
    .BIT_REVERSE(BIT_REVERSE),
    .SCRAMBLER_DISABLE(SCRAMBLER_DISABLE),
    .PRBS31_ENABLE(PRBS31_ENABLE),
    .SERDES_PIPELINE(RX_SERDES_PIPELINE),
    .BITSLIP_HIGH_CYCLES(BITSLIP_HIGH_CYCLES),
    .BITSLIP_LOW_CYCLES(BITSLIP_LOW_CYCLES),
    .COUNT_125US(COUNT_125US)
)
UUT (
    .clk(rx_clk),
    .rst(rx_rst),
    .xgmii_rxd(xgmii_rxd),
    .xgmii_rxc(xgmii_rxc),
    .serdes_rx_data(serdes_rx_data),
    .serdes_rx_hdr(serdes_rx_hdr),
    .serdes_rx_bitslip(serdes_rx_bitslip),
    .serdes_rx_reset_req(serdes_rx_reset_req),
    .rx_error_count(rx_error_count),
    .rx_bad_block(rx_bad_block),
    .rx_sequence_error(rx_sequence_error),
    .rx_block_lock(rx_block_lock),
    .rx_high_ber(rx_high_ber),
    .rx_status(rx_status),
    .rx_prbs31_enable(rx_prbs31_enable),
    // .recoved_encoded_rx_data(recoved_encoded_rx_data),
    //output received ipg data
    .rx_ipg_data(rx_ipg_data)
);

endmodule