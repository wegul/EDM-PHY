// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * Testbench for eth_phy_10g
 */
module test_eth_phy;

  // Parameters
  parameter DATA_WIDTH = 64;
  parameter CTRL_WIDTH = (DATA_WIDTH / 8);
  parameter HDR_WIDTH = 2;
  parameter BIT_REVERSE = 0;
  parameter SCRAMBLER_DISABLE = 1;
  parameter PRBS31_ENABLE = 0;
  parameter TX_SERDES_PIPELINE = 0;
  parameter RX_SERDES_PIPELINE = 0;
  parameter BITSLIP_HIGH_CYCLES = 1;
  parameter BITSLIP_LOW_CYCLES = 8;
  parameter COUNT_125US = 125000 / 6.4;
  localparam [1:0] SYNC_DATA = 2'b10, SYNC_CTRL = 2'b01;

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

  wire [DATA_WIDTH-1:0] ipg_req_chunk;
  wire reqq_write;


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

  wire [DATA_WIDTH-1:0] ipg_write_chunk;
  wire [DATA_WIDTH-1:0] ipg_rresp_chunk, sync_ipg_rresp_chunk;  /*received resp*/




  initial begin
    //Assign value here as stimulus
    // Generate the clock
    clk = 1'b1;
    tx_clk = 1'b1;
    rx_clk = 1'b0;
    forever begin
      #1 clk = ~clk;
      rx_clk = ~rx_clk;
      tx_clk = ~tx_clk;
    end
  end

  initial begin
    rst = 1'b1;
    rx_rst = 1'b1;
    tx_rst = 1'b1;
    #10 rst = 1'b0;
    rx_rst = 1'b0;
    tx_rst = 1'b0;
  end

  // REQ format: 8'b{reply_len}, 64'b src, 64'b dst

  reg [3:0] cnt = 0;
  reg en_reg_gen = 0;
  wire m_axis_sync_valid;
  always @(posedge tx_clk) begin
    if (rst) begin
      cnt <= 0;
    end else begin
      cnt <= cnt + 1;
    end
  end
  always @(*) begin
    if (cnt == 4'd8 || cnt == 4'd15 || cnt == 4'd0) begin
      en_reg_gen = 1;
    end else begin
      en_reg_gen = 0;
    end
  end

  req_gen gen_inst (
      .clk(tx_clk),
      .rst(tx_rst),
      .enable(en_reg_gen),
      .ipg_req_chunk(ipg_req_chunk),
      .valid_req(reqq_write)
  );
  axis_fifo #(
      .DATA_WIDTH(DATA_WIDTH),
      .DEPTH(2),
      .KEEP_ENABLE(0),
      .LAST_ENABLE(0),
      .DEST_ENABLE(0),
      .USER_ENABLE(0),
      .FRAME_FIFO(0),
      .ID_ENABLE(0)
  ) asf (
      // AXI input
      .clk(rx_clk),
      .rst(rx_rst),
      .s_axis_tdata(ipg_rresp_chunk),
      .s_axis_tkeep(8'hff),
      .s_axis_tvalid(1),
      .s_axis_tready(),
      .s_axis_tlast(0),
      .s_axis_tid(0),
      .s_axis_tdest(0),
      .s_axis_tuser(0),

      // AXI output
      .m_axis_tdata (sync_ipg_rresp_chunk),
      .m_axis_tvalid(m_axis_sync_valid),
      .m_axis_tready(1)
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
  ) UUT (
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

      .ipg_req_chunk(ipg_req_chunk),  //input for ipg_tx
      .reqq_write(reqq_write),  //input for ipg_tx
      .ipg_rresp_chunk(ipg_rresp_chunk),  // output from ipg_rx
      .tx_pause()
  );

endmodule
