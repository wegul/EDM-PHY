// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * Testbench for eth_phy_10g
 */
module test_eth_phy;

// Parameters
parameter DATA_WIDTH = 64;
parameter CTRL_WIDTH = (DATA_WIDTH/8);
parameter HDR_WIDTH = 2;
parameter BIT_REVERSE = 0;
parameter SCRAMBLER_DISABLE = 1;
parameter PRBS31_ENABLE = 0;
parameter TX_SERDES_PIPELINE = 0;
parameter RX_SERDES_PIPELINE = 0;
parameter BITSLIP_HIGH_CYCLES = 1;
parameter BITSLIP_LOW_CYCLES = 8;
parameter COUNT_125US = 125000/6.4;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg rx_clk = 0;
reg rx_rst = 0;
reg tx_clk = 0;
reg tx_rst = 0;
reg [DATA_WIDTH-1:0] xgmii_txd = 0;
reg [CTRL_WIDTH-1:0] xgmii_txc = 0;
reg [DATA_WIDTH-1:0] serdes_rx_data = 0;
reg [HDR_WIDTH-1:0] serdes_rx_hdr = 1;
reg tx_prbs31_enable = 0;
reg rx_prbs31_enable = 0;

// Outputs
wire [DATA_WIDTH-1:0] xgmii_rxd;
wire [CTRL_WIDTH-1:0] xgmii_rxc;
wire [DATA_WIDTH-1:0] serdes_tx_data;
wire [HDR_WIDTH-1:0] serdes_tx_hdr;
wire serdes_rx_bitslip;
wire [6:0] rx_error_count;
wire rx_bad_block;
wire rx_block_lock;
wire rx_high_ber;

wire [63:0] rx_ipg_data;

initial begin
   //Assign value here as stimulus

    // Generate the clock
    clk = 1'b1;
    tx_clk = 1'b1;
    rx_clk = 1'b1;
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

integer i;
integer packet_size;
reg [31:0] fake_fcs;

initial begin
        packet_size = 8;
        #14
        xgmii_txd = 64'hd5555555555555fb;//fake preamble
        xgmii_txc = 8'h01;
        #2
        //warmup
        //Data input (8 Bytes)
        xgmii_txd = 64'hdddddaaaddddd;
        xgmii_txc = 8'h00;
        #2
        xgmii_txd = 64'hecccffccccccc;
        xgmii_txc = 8'h00;
        #2
        xgmii_txd = 64'h0;
        xgmii_txc = 8'hff;
        // serdes_rx_data = 64'h8A8A8A8A8A8A8A8A;
        // serdes_rx_hdr = 2'b10;

        #2
        
//         xgmii_txd = 64'h01;
//         for (i=0;i<packet_size;i=i+1) begin
//             #2
//             xgmii_txd = xgmii_txd +1;
//         end
        
//         xgmii_txd = {{32'h070707fd},{fake_fcs}};
//         xgmii_txc = 8'hf0; //Term_4
//         #2
// //        //Enter IDLE
//         xgmii_txd={8{8'h07}};
//         xgmii_txc={8'hff};
        #36
        $finish;
end

debug_eth_phy_10g #(
    .DATA_WIDTH(DATA_WIDTH),
    .CTRL_WIDTH(CTRL_WIDTH),
    .HDR_WIDTH(HDR_WIDTH),
    .BIT_REVERSE(BIT_REVERSE),
    .SCRAMBLER_DISABLE(SCRAMBLER_DISABLE),
    .PRBS31_ENABLE(PRBS31_ENABLE),
    .TX_SERDES_PIPELINE(TX_SERDES_PIPELINE),
    .RX_SERDES_PIPELINE(RX_SERDES_PIPELINE),
    .BITSLIP_HIGH_CYCLES(BITSLIP_HIGH_CYCLES),
    .BITSLIP_LOW_CYCLES(BITSLIP_LOW_CYCLES),
    .COUNT_125US(COUNT_125US)
)
UUT (
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
    .serdes_rx_data(serdes_tx_data),
    .serdes_rx_hdr(serdes_tx_hdr),
    .serdes_rx_bitslip(serdes_rx_bitslip),
    .rx_error_count(rx_error_count),
    .rx_bad_block(rx_bad_block),
    .rx_block_lock(rx_block_lock),
    .rx_high_ber(rx_high_ber),
    .tx_prbs31_enable(tx_prbs31_enable),
    .rx_prbs31_enable(rx_prbs31_enable),

    .rx_ipg_data(rx_ipg_data)
);

endmodule