
`resetall `timescale 1ns / 1ps `default_nettype none
/*
 * 10G Ethernet PHY
 */
(* DONT_TOUCH = "TRUE" *)
module eth_phy_10g #(
    parameter DATA_WIDTH = 64,
    parameter CTRL_WIDTH = (DATA_WIDTH / 8),
    parameter HDR_WIDTH = 2,
    parameter BIT_REVERSE = 0,
    parameter SCRAMBLER_DISABLE = 1,
    parameter PRBS31_ENABLE = 0,
    parameter TX_SERDES_PIPELINE = 0,
    parameter RX_SERDES_PIPELINE = 0,
    parameter BITSLIP_HIGH_CYCLES = 1,
    parameter BITSLIP_LOW_CYCLES = 8,
    parameter COUNT_125US = 125000 / 6.4
) (
    input wire rx_clk,
    input wire rx_rst,
    input wire tx_clk,
    input wire tx_rst,

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
    output wire [ HDR_WIDTH-1:0] serdes_tx_hdr,
    input  wire [DATA_WIDTH-1:0] serdes_rx_data,
    input  wire [ HDR_WIDTH-1:0] serdes_rx_hdr,
    output wire                  serdes_rx_bitslip,
    output wire                  serdes_rx_reset_req,

    /*
         * Status
         */
    output wire       tx_bad_block,
    output wire [6:0] rx_error_count,
    output wire       rx_bad_block,
    output wire       rx_sequence_error,
    output wire       rx_block_lock,
    output wire       rx_high_ber,
    output wire       rx_status,

    /*
         * Configuration
         */
    input wire tx_prbs31_enable,
    input wire rx_prbs31_enable,

    //back pressure
    output wire tx_pause,

    input wire [DATA_WIDTH-1:0] ipg_req_chunk,
    input wire reqq_write,

    output wire [DATA_WIDTH-1:0] ipg_write_chunk,
    output wire [DATA_WIDTH-1:0] ipg_rresp_chunk   /*received resp*/
);
  localparam RX_COUNT = 6;

  wire [DATA_WIDTH-1:0] ipg_reply_chunk;  /*resp for rreq*/



  // ipg customize
  wire [55:0] wreq_hdr, rresp_hdr;
  wire [111:0] wreq_mem_addr, rresp_mem_addr;

  wire [DATA_WIDTH-1:0] rx_ipg_data;
  wire [  RX_COUNT-1:0] rx_len;
  wire memq_write, rreq_valid, wreq_valid, rresp_valid;

  //generate reply or write stuff to RAM
  (* DONT_TOUCH = "TRUE" *)
  ipg_rreq_proc inst_ipg_read_proc (
      .clk(rx_clk),
      .reset(rx_rst),
      .rreq_valid(rreq_valid),
      .rx_len(rx_len),
      .rx_ipg_data(rx_ipg_data),
      .ipg_reply_chunk(ipg_reply_chunk),  // output to ipg_tx 
      .memq_write(memq_write)
  );
  (* DONT_TOUCH = "TRUE" *)
  ipg_wreq_proc inst_ipg_write_proc (
      .clk(rx_clk),
      .reset(rx_rst),
      .wreq_valid(wreq_valid),
      .rx_len(rx_len),
      .rx_ipg_data(rx_ipg_data),
      .hdr_in(wreq_hdr),
      .mem_addr_in(wreq_mem_addr),
      .ipg_write_chunk(ipg_write_chunk)
  );
  (* DONT_TOUCH = "TRUE" *)
  ipg_rresp_proc inst_ipg_rresp_proc (
      .clk(rx_clk),
      .reset(rx_rst),
      .rresp_valid(rresp_valid),
      .rx_len(rx_len),
      .rx_ipg_data(rx_ipg_data),
      .hdr_in(rresp_hdr),
      .mem_addr_in(rresp_mem_addr),
      .ipg_rresp_chunk(ipg_rresp_chunk)
  );

  (* DONT_TOUCH = "TRUE" *)
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
  ) eth_phy_10g_rx_inst (
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
      .rx_ipg_data(rx_ipg_data),
      .wreq_valid(wreq_valid),
      .rreq_valid(rreq_valid),
      .rresp_valid(rresp_valid)
  );

  (* DONT_TOUCH = "TRUE" *)
  eth_phy_10g_tx #(
      .DATA_WIDTH(DATA_WIDTH),
      .CTRL_WIDTH(CTRL_WIDTH),
      .HDR_WIDTH(HDR_WIDTH),
      .BIT_REVERSE(BIT_REVERSE),
      .SCRAMBLER_DISABLE(SCRAMBLER_DISABLE),
      .PRBS31_ENABLE(PRBS31_ENABLE),
      .SERDES_PIPELINE(TX_SERDES_PIPELINE)
  ) eth_phy_10g_tx_inst (
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
      .ipg_req_chunk(ipg_req_chunk),
      .memq_write(memq_write),
      .reqq_write(reqq_write),
      .tx_pause(tx_pause)
  );

endmodule

`resetall
