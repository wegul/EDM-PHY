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
    localparam [1:0]
               SYNC_DATA = 2'b10,
               SYNC_CTRL = 2'b01;

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
        #10
         rst = 1'b0;
        rx_rst = 1'b0;
        tx_rst = 1'b0;
    end

    integer i;
    integer packet_size;

    initial begin
        #10
         xgmii_txd = 64'h0707070707070707;
        xgmii_txc = 8'hff;
        #4
         xgmii_txd = 64'hd5555555555555fb;
        xgmii_txc = 8'h01;
        #2
         xgmii_txd = 64'hdddddaaaddddd;
        xgmii_txc = 8'h00;
        #2
         xgmii_txd = 64'hecccffccccccc;
        xgmii_txc = 8'h00;
        #2
         xgmii_txd = 64'hfd2233ee44eeefff;
        xgmii_txc = 8'h80;
        #2
         xgmii_txd = 64'h0707070707070707;
        xgmii_txc = 8'hff;
        #8
         $finish;
    end

    // initial begin
    //     packet_size = 8;
    //     #14
    //      xgmii_txd = 64'hd5555555555555fb;//fake preamble
    //     xgmii_txc = 8'h01;
    //     #2
    //      //warmup
    //      //Data input (8 Bytes)
    //      xgmii_txd = 64'hdddddaaaddddd;
    //     xgmii_txc = 8'h00;
    //     #2
    //      xgmii_txd = 64'hecccffccccccc;
    //     xgmii_txc = 8'h00;
    //     #2
    //      xgmii_txd = 64'hfd2233ee44eeefff;
    //     xgmii_txc = 8'h80;
    //     #2
    //      xgmii_txd = 64'h0;
    //     xgmii_txc = 8'hff;

    //     serdes_rx_data = 64'h8A8A8A8A8A8A8A78;
    //     serdes_rx_hdr = SYNC_CTRL;
    //     #2
    //      serdes_rx_data = 64'h8B8B8B8B8B8B8A8A;
    //     serdes_rx_hdr = SYNC_DATA;
    //     #2
    //      serdes_rx_data = 64'h8CCCCC8B8CB8B8A8A;
    //     serdes_rx_hdr = SYNC_DATA;
    //     #2
    //      serdes_rx_data = 64'h0100ADDADDADDF1e;
    //     serdes_rx_data[63:62]=2'b01;
    //     serdes_rx_hdr = 2'b01;
    //     #2
    //      serdes_rx_data = 64'hADDADD8B8B8B8B1e;
    //     serdes_rx_hdr = 2'b01;
    //     //write payload below
    //     for (i=0;i<9;i=i+1) begin
    //         #2
    //          serdes_rx_data = 64'hbb3344556699ff1e;
    //         serdes_rx_hdr = 2'b01;
    //     end
    //     #2
    //      serdes_rx_data = 64'hbb3344556699ff1e;
    //     serdes_rx_hdr = 2'b01;

    //     #2
    //      serdes_rx_data = 64'haaaaaaaaaaaaaa78;
    //     serdes_rx_hdr = 2'b01;
    //     #2
    //      serdes_rx_data = 64'h8B8B8B8B8B8B8A8A;
    //     serdes_rx_hdr = SYNC_DATA;
    //     #2
    //      serdes_rx_data = 64'h8CCCCC8B8CB8B8A8A;
    //     serdes_rx_hdr = SYNC_DATA;
    //     #2
    //      serdes_rx_data = 64'h0000addaddaddad87;
    //     serdes_rx_hdr = SYNC_CTRL;

    //     #2
    //      serdes_rx_data = 64'hFFFFADDADDADDF1e;
    //     serdes_rx_hdr = 2'b01;
    //     #2
    //      serdes_rx_data = 64'hcccccccccccccc1e;
    //     serdes_rx_hdr = 2'b01;

    //     //warmup
    //     xgmii_txd = 64'hd5555555555555fb;//fake preamble
    //     xgmii_txc = 8'h01;
    //     #2
    //      xgmii_txd = 64'hdddddaaaddddd0000;
    //     xgmii_txc = 8'h00;
    //     #2
    //      xgmii_txd = 64'hecccffccccccc000;
    //     xgmii_txc = 8'h00;
    //     #2
    //      xgmii_txd = 64'hfd2233ee44eeefff;
    //     xgmii_txc = 8'h80;
    //     #2
    //      xgmii_txd = 64'h0;
    //     xgmii_txc = 8'hff;
    //     serdes_rx_data = 64'haaaaaaaaaaaaaa78;
    //     serdes_rx_hdr = 2'b01;
    //     #2
    //      serdes_rx_data = 64'h8B8B8B8B8B8B8A8A;
    //     serdes_rx_hdr = SYNC_DATA;
    //     #2
    //      serdes_rx_data = 64'h8CCCCC8B8CB8B8A8A;
    //     serdes_rx_hdr = SYNC_DATA;
    //     #2
    //      serdes_rx_data = 64'h00000000000000087;
    //     serdes_rx_hdr = SYNC_CTRL;
    //     #48
    //      $finish;
    // end

    eth_phy_10g #(
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
                    .serdes_rx_data(serdes_rx_data),
                    .serdes_rx_hdr(serdes_rx_hdr),
                    .serdes_rx_bitslip(serdes_rx_bitslip),
                    .rx_error_count(rx_error_count),
                    .rx_bad_block(rx_bad_block),
                    .rx_block_lock(rx_block_lock),
                    .rx_high_ber(rx_high_ber),
                    .tx_prbs31_enable(tx_prbs31_enable),
                    .rx_prbs31_enable(rx_prbs31_enable)
                );

endmodule
