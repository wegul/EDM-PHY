module test_eth_phy_rx;
  parameter DATA_WIDTH = 64;
  parameter CTRL_WIDTH = (DATA_WIDTH / 8);
  parameter HDR_WIDTH = 2;
  parameter BIT_REVERSE = 0;
  parameter SCRAMBLER_DISABLE = 1;
  parameter PRBS31_ENABLE = 1;
  parameter SERDES_PIPELINE = 0;
  parameter BITSLIP_HIGH_CYCLES = 1;
  parameter BITSLIP_LOW_CYCLES = 8;
  parameter COUNT_125US = 1250 / 6.4;
  // Inputs
  reg clk = 0;
  reg rst = 0;

  reg [DATA_WIDTH-1:0] serdes_rx_data = 0;
  reg [HDR_WIDTH-1:0] serdes_rx_hdr = 1;
  reg rx_prbs31_enable = 0;

  // Outputs
  wire [DATA_WIDTH-1:0] xgmii_rxd;
  wire [CTRL_WIDTH-1:0] xgmii_rxc;
  wire serdes_rx_bitslip;
  wire [6:0] rx_error_count;
  wire rx_bad_block;
  wire rx_block_lock;
  wire rx_high_ber;
  wire [5:0] rx_len;
  wire [DATA_WIDTH-1:0] rx_ipg_data;


  initial begin
    //Assign value here as stimulus

    // Generate the clock
    clk = 1'b1;
    forever begin
      #1 clk = ~clk;
    end
  end

  initial begin
    rst = 1;
    #6 rst = 0;
    #2 serdes_rx_data = 64'h112233445566770a;
    serdes_rx_hdr = 2'b01;
    #2 serdes_rx_data = 64'h222222222222221a;
    serdes_rx_hdr = 2'b01;
    #2 serdes_rx_data = 64'h333333333333333a;
    serdes_rx_hdr = 2'b01;
    #20 serdes_rx_data = 64'h112233000000dd33;
    serdes_rx_hdr = 2'b01;
    #2 serdes_rx_data = 64'h112233005500dd11;
    serdes_rx_hdr = 2'b10;
    #2 serdes_rx_data = 64'h112233445500ddaa;
    serdes_rx_hdr = 2'b10;
    #2 serdes_rx_data = 64'h112233445500ddbb;
    serdes_rx_hdr = 2'b10;
    #2 serdes_rx_data = 64'h112233445500ddbb;
    serdes_rx_hdr = 2'b10;
    #2 serdes_rx_data = 64'h112233445500ddff;
    serdes_rx_hdr = 2'b01;
    #2 serdes_rx_data = 64'h112233445566771e;
    serdes_rx_hdr = 2'b01;
    #20 $finish;




  end





  eth_phy_10g_rx #(
      .DATA_WIDTH(DATA_WIDTH),
      .CTRL_WIDTH(CTRL_WIDTH),
      .HDR_WIDTH(HDR_WIDTH),
      .BIT_REVERSE(BIT_REVERSE),
      .SCRAMBLER_DISABLE(SCRAMBLER_DISABLE),
      .PRBS31_ENABLE(PRBS31_ENABLE),
      .SERDES_PIPELINE(SERDES_PIPELINE),
      .BITSLIP_HIGH_CYCLES(BITSLIP_HIGH_CYCLES),
      .BITSLIP_LOW_CYCLES(BITSLIP_LOW_CYCLES),
      .COUNT_125US(COUNT_125US)
  ) UUT (
      .clk(clk),
      .rst(rst),
      .xgmii_rxd(xgmii_rxd),
      .xgmii_rxc(xgmii_rxc),
      .serdes_rx_data(serdes_rx_data),
      .serdes_rx_hdr(serdes_rx_hdr),
      .serdes_rx_bitslip(serdes_rx_bitslip),
      .rx_error_count(rx_error_count),
      .rx_bad_block(rx_bad_block),
      .rx_block_lock(rx_block_lock),
      .rx_high_ber(rx_high_ber),
      .rx_prbs31_enable(rx_prbs31_enable),

      .rx_len(rx_len),
      .rx_ipg_data(rx_ipg_data)
  );
endmodule
