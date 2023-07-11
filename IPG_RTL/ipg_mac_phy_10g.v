`resetall
`timescale 1ns / 1ps
`default_nettype none

module ipg_mac_phy_10g #(
        //++++++++++++++++ For MAC+PHY begin ++++++++++++++++
        parameter DATA_WIDTH = 64,
        parameter CTRL_WIDTH = (DATA_WIDTH/8),
        //**************** For MAC+PHY end ****************


        //++++++++++++++++ For MAC-Only begin ++++++++++++++++
        parameter KEEP_WIDTH = (DATA_WIDTH/8),
        parameter ENABLE_PADDING = 1,
        parameter ENABLE_DIC = 1,
        parameter MIN_FRAME_LENGTH = 64,
        parameter PTP_PERIOD_NS = 4'h6,
        parameter PTP_PERIOD_FNS = 16'h6666,
        parameter TX_PTP_TS_ENABLE = 0,
        parameter TX_PTP_TS_WIDTH = 96,
        parameter TX_PTP_TAG_ENABLE = TX_PTP_TS_ENABLE,
        parameter TX_PTP_TAG_WIDTH = 16,
        parameter RX_PTP_TS_ENABLE = 0,
        parameter RX_PTP_TS_WIDTH = 96,
        parameter TX_USER_WIDTH = (TX_PTP_TS_ENABLE && TX_PTP_TAG_ENABLE ? TX_PTP_TAG_WIDTH : 0) + 1,
        parameter RX_USER_WIDTH = (RX_PTP_TS_ENABLE ? RX_PTP_TS_WIDTH : 0) + 1,
        //**************** For MAC-Only end ****************


        //++++++++++++++++ For PHY-Only begin ++++++++++++++++
        parameter HDR_WIDTH = 2,
        parameter BIT_REVERSE = 0,
        parameter SCRAMBLER_DISABLE = 1,
        parameter PRBS31_ENABLE = 0,
        parameter TX_SERDES_PIPELINE = 0,
        parameter RX_SERDES_PIPELINE = 0,
        parameter BITSLIP_HIGH_CYCLES = 1,
        parameter BITSLIP_LOW_CYCLES = 8,
        parameter COUNT_125US = 125000/6.4
        //**************** For PHY-Only end ****************

    )
    (
        //++++++++++++++++ For MAC+PHY begin ++++++++++++++++
        input  wire                  rx_clk,
        input  wire                  rx_rst,
        input  wire                  tx_clk,
        input  wire                  tx_rst,
        //**************** For MAC+PHY end ****************

        /*
         * AXI input
         */
        input  wire [DATA_WIDTH-1:0]        tx_axis_tdata,
        input  wire [KEEP_WIDTH-1:0]        tx_axis_tkeep,
        input  wire                         tx_axis_tvalid,
        output wire                         tx_axis_tready,
        input  wire                         tx_axis_tlast,
        input  wire [TX_USER_WIDTH-1:0]     tx_axis_tuser,
        /*
         * AXI output
         */
        output wire [DATA_WIDTH-1:0]        rx_axis_tdata,
        output wire [KEEP_WIDTH-1:0]        rx_axis_tkeep,
        output wire                         rx_axis_tvalid,
        output wire                         rx_axis_tlast,
        output wire [RX_USER_WIDTH-1:0]     rx_axis_tuser,

        /*
         * SERDES interface
         */
        output wire [DATA_WIDTH-1:0] serdes_tx_data,
        output wire [HDR_WIDTH-1:0]  serdes_tx_hdr,
        input  wire [DATA_WIDTH-1:0] serdes_rx_data,
        input  wire [HDR_WIDTH-1:0]  serdes_rx_hdr,
        output wire                  serdes_rx_bitslip,
        output wire                  serdes_rx_reset_req,

        /*
        * Status
        */
        output wire [1:0]                   tx_start_packet,
        output wire                         tx_error_underflow,
        output wire [1:0]                   rx_start_packet,
        output wire [6:0]                   rx_error_count,
        output wire                         rx_error_bad_frame,
        output wire                         rx_error_bad_fcs,
        output wire                         rx_bad_block,
        output wire                         rx_block_lock,
        output wire                         rx_high_ber,
        output wire                         rx_status,


        /*
         * Configuration
         */
        input  wire [7:0]                   ifg_delay,
        input  wire                         tx_prbs31_enable,
        input  wire                         rx_prbs31_enable,

        /*
         * PTP
         */
        input  wire [TX_PTP_TS_WIDTH-1:0]   tx_ptp_ts,
        input  wire [RX_PTP_TS_WIDTH-1:0]   rx_ptp_ts
        // output wire [TX_PTP_TS_WIDTH-1:0]   tx_axis_ptp_ts,
        // output wire [TX_PTP_TAG_WIDTH-1:0]  tx_axis_ptp_ts_tag,
        // output wire                         tx_axis_ptp_ts_valid,

    );


    wire [DATA_WIDTH-1:0]     xgmii_txd;
    wire [CTRL_WIDTH-1:0]     xgmii_txc;
    wire [DATA_WIDTH-1:0]     xgmii_rxd;
    wire [CTRL_WIDTH-1:0]     xgmii_rxc;
    wire [1:0] pause_tuser;

    assign tx_axis_tuser=pause_tuser;


    eth_mac_10g #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .KEEP_WIDTH(KEEP_WIDTH),
                    .CTRL_WIDTH(CTRL_WIDTH),
                    .ENABLE_PADDING(ENABLE_PADDING),
                    .ENABLE_DIC(ENABLE_DIC),
                    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH),
                    .PTP_PERIOD_NS(PTP_PERIOD_NS),
                    .PTP_PERIOD_FNS(PTP_PERIOD_FNS),
                    .TX_PTP_TS_ENABLE(TX_PTP_TS_ENABLE),
                    .TX_PTP_TS_WIDTH(TX_PTP_TS_WIDTH),
                    .TX_PTP_TAG_ENABLE(TX_PTP_TAG_ENABLE),
                    .TX_PTP_TAG_WIDTH(TX_PTP_TAG_WIDTH),
                    .RX_PTP_TS_ENABLE(RX_PTP_TS_ENABLE),
                    .RX_PTP_TS_WIDTH(RX_PTP_TS_WIDTH),
                    .TX_USER_WIDTH(TX_USER_WIDTH),
                    .RX_USER_WIDTH(RX_USER_WIDTH)
                )
                mac_inst(
                    .rx_clk(rx_clk),
                    .rx_rst(rx_rst),
                    .tx_clk(tx_clk),
                    .tx_rst(tx_rst),
                    .tx_axis_tdata(tx_axis_tdata),
                    .tx_axis_tkeep(tx_axis_tkeep),
                    .tx_axis_tvalid(tx_axis_tvalid),
                    .tx_axis_tready(tx_axis_tready),
                    .tx_axis_tlast(tx_axis_tlast),
                    .tx_axis_tuser(tx_axis_tuser),
                    .rx_axis_tdata(rx_axis_tdata),
                    .rx_axis_tkeep(rx_axis_tkeep),
                    .rx_axis_tvalid(rx_axis_tvalid),
                    .rx_axis_tlast(rx_axis_tlast),
                    .rx_axis_tuser(rx_axis_tuser),
                    .xgmii_rxd(xgmii_rxd),
                    .xgmii_rxc(xgmii_rxc),
                    .xgmii_txd(xgmii_txd),
                    .xgmii_txc(xgmii_txc),
                    .tx_ptp_ts(tx_ptp_ts),//input, cannot delete
                    .rx_ptp_ts(rx_ptp_ts),
                    // .tx_axis_ptp_ts(tx_axis_ptp_ts),
                    // .tx_axis_ptp_ts_tag(tx_axis_ptp_ts_tag),
                    // .tx_axis_ptp_ts_valid(tx_axis_ptp_ts_valid),
                    .tx_start_packet(tx_start_packet),
                    .tx_error_underflow(tx_error_underflow),
                    .rx_start_packet(rx_start_packet),
                    .rx_error_bad_frame(rx_error_bad_frame),
                    .rx_error_bad_fcs(rx_error_bad_fcs),
                    .ifg_delay(ifg_delay)
                );

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
                phy_inst (
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
                    .tuser(pause_tuser)
                );
endmodule
