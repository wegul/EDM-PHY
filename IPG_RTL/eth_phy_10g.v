
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

    output wire [DATA_WIDTH-1:0] rx_ipg_data

);

// ipg customize
// wire [DATA_WIDTH-1:0] rx_ipg_data;
wire [DATA_WIDTH-1:0] ipg_reply;
wire [5:0] rx_len;

wire memq_read;
wire memq_write;
wire memq_reset;
wire memq_empty;
wire memq_full;
wire [2:0] memq_space;
wire [519:0] tx_ipg_data;

wire netq_read;
wire netq_write;
wire netq_reset;
wire netq_empty;
wire netq_full;
wire [2:0] netq_space;
wire [DATA_WIDTH-1:0] netq_xgmii_txd;
wire [CTRL_WIDTH-1:0] netq_xgmii_txc;
wire ipg_en;

// wire [519:0] tx_ipg_data;

// ipg msg to be sent
mem_fifo_buf memq(
    .data_in (ipg_reply),
    .reset(memq_reset),
    // .read(memq_read),
    .write(memq_write),

    .clk (clk),
    .en (ipg_en),

    .data_out (tx_ipg_data),
    .empty (qempty),
    .full (qfull),
    .space(memq_space)
);

// network frames bufferd here
net_fifo_buf netq(
    .data_ind (xgmii_txd),//this is from mac
    .data_inc (xgmii_txc),
    .reset(qreset),
    // .read(qread),
    .write(qwrite),

    .clk (clk),
    .en (~ipg_en),
    //important
    .data_outd (netq_xgmii_txd),
    .data_outc (netq_xgmii_txc),

    .empty (netq_empty),
    .full (netq_full),
    .space(netq_space)
);

buf_mon monitor(
    .memq_space(memq_space),
    .netq_space(netq_space),

    .sel(ipg_en)// if 1, tx ipg. else tx net frame
);

ipg_proc inst_ipg_proc(

    .qwrite(qwrite),
    .qreset(qreset),

    .clk(tx_clk),
    .rx_len(rx_len),
    .rx_ipg_data(rx_ipg_data),
    .ipg_reply(ipg_reply)
);

//TODO: add queue management here



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
    .xgmii_txd(netq_xgmii_txd),
    .xgmii_txc(netq_xgmii_txc),
    .serdes_tx_data(serdes_tx_data),
    .serdes_tx_hdr(serdes_tx_hdr),
    .tx_bad_block(tx_bad_block),
    .tx_prbs31_enable(tx_prbs31_enable),

    // input ipg data to be sent
    .ipg_en(mem_en),
    .tx_ipg_data(tx_ipg_data)
);

endmodule

`resetall
