
`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * 10G Ethernet PHY
 */
module eth_phy_10g #
    (
        parameter DATA_WIDTH = 64,
        parameter CTRL_WIDTH = (DATA_WIDTH/8),
        parameter HDR_WIDTH = 2,
        parameter BIT_REVERSE = 0,
        parameter SCRAMBLER_DISABLE = 1,
        parameter PRBS31_ENABLE = 0,
        parameter TX_SERDES_PIPELINE = 0,
        parameter RX_SERDES_PIPELINE = 0,
        parameter BITSLIP_HIGH_CYCLES = 1,
        parameter BITSLIP_LOW_CYCLES = 8,
        parameter COUNT_125US = 125000/6.4
    )
    (
        input  wire                  rx_clk,
        input  wire                  rx_rst,
        input  wire                  tx_clk,
        input  wire                  tx_rst,

        /*
         * XGMII interface
         */
        input  wire [DATA_WIDTH-1:0] xgmii_txd,
        input  wire [CTRL_WIDTH-1:0] xgmii_txc,
        output wire [DATA_WIDTH-1:0] xgmii_rxd,
        output wire [CTRL_WIDTH-1:0] xgmii_rxc,

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
        output wire                  tx_bad_block,
        output wire [6:0]            rx_error_count,
        output wire                  rx_bad_block,
        output wire                  rx_sequence_error,
        output wire                  rx_block_lock,
        output wire                  rx_high_ber,
        output wire                  rx_status,

        /*
         * Configuration
         */
        input  wire                  tx_prbs31_enable,
        input  wire                  rx_prbs31_enable,

        //back pressure
        output wire [1:0] tuser
    );
    localparam RX_COUNT=6;
    // ipg customize
    // wire [DATA_WIDTH-1:0] rx_ipg_data;
    wire [DATA_WIDTH-1:0] ipg_reply_chunk;
    wire [RX_COUNT-1:0] rx_len;


    wire [DATA_WIDTH-1:0] netq_ind;
    wire [CTRL_WIDTH-1:0] netq_inc;
    wire [DATA_WIDTH-1:0] rx_ipg_data;
    wire memq_write,jobq_write;


    assign jobq_write = (rx_len>0) ? 1 : 0;


    //generate reply or write stuff to RAM
    ipg_proc inst_ipg_proc(
                 .clk(tx_clk),
                 .reset(tx_rst),
                 .jobq_write(jobq_write),
                 .rx_len(rx_len),
                 .rx_ipg_data(rx_ipg_data),
                 .ipg_reply_chunk(ipg_reply_chunk),
                 .memq_write(memq_write)
             );

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
                   eth_phy_10g_rx_inst (
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

                       //output received ipg data
                       .rx_len(rx_len),
                       .rx_ipg_data(rx_ipg_data)
                   );

    eth_phy_10g_tx #(
                       .DATA_WIDTH(DATA_WIDTH),
                       .CTRL_WIDTH(CTRL_WIDTH),
                       .HDR_WIDTH(HDR_WIDTH),
                       .BIT_REVERSE(BIT_REVERSE),
                       .SCRAMBLER_DISABLE(SCRAMBLER_DISABLE),
                       .PRBS31_ENABLE(PRBS31_ENABLE),
                       .SERDES_PIPELINE(TX_SERDES_PIPELINE)
                   )
                   eth_phy_10g_tx_inst (
                       .clk(tx_clk),
                       .rst(tx_rst),
                       .xgmii_txd(xgmii_txd),
                       .xgmii_txc(xgmii_txc),
                       .serdes_tx_data(serdes_tx_data),
                       .serdes_tx_hdr(serdes_tx_hdr),
                       .tx_bad_block(tx_bad_block),
                       .tx_prbs31_enable(tx_prbs31_enable),

                       // input ipg data to be sent
                       .ipg_reply_chunk(ipg_reply_chunk),
                       .memq_write(memq_write),
                       .tuser(tuser)
                   );

endmodule

`resetall
