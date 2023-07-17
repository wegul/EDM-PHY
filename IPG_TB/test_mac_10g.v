`timescale 1ns / 100ps

/*
 * Testbench for eth_mac_10g
 */
module test_mac_10g;

    // Parameters
    parameter DATA_WIDTH = 64;
    parameter KEEP_WIDTH = (DATA_WIDTH/8);
    parameter CTRL_WIDTH = (DATA_WIDTH/8);
    parameter ENABLE_PADDING = 1;
    parameter ENABLE_DIC = 1;
    parameter MIN_FRAME_LENGTH = 64;
    parameter PTP_PERIOD_NS = 4'h6;
    parameter PTP_PERIOD_FNS = 16'h6666;
    parameter TX_PTP_TS_ENABLE = 0;
    parameter TX_PTP_TS_WIDTH = 96;
    parameter TX_PTP_TAG_ENABLE = TX_PTP_TS_ENABLE;
    parameter TX_PTP_TAG_WIDTH = 16;
    parameter RX_PTP_TS_ENABLE = 0;
    parameter RX_PTP_TS_WIDTH = 96;
    parameter TX_USER_WIDTH = (TX_PTP_TAG_ENABLE ? TX_PTP_TAG_WIDTH : 0) + 1;
    parameter RX_USER_WIDTH = (RX_PTP_TS_ENABLE ? RX_PTP_TS_WIDTH : 0) + 1;

    // Inputs
    reg clk = 0;
    reg rst = 0;

    reg rx_clk = 0;
    reg rx_rst = 0;
    reg tx_clk = 0;
    reg tx_rst = 0;
    reg [DATA_WIDTH-1:0] tx_axis_tdata = 0;
    reg [KEEP_WIDTH-1:0] tx_axis_tkeep = 0;
    reg tx_axis_tvalid = 0;
    reg tx_axis_tlast = 0;
    reg [TX_USER_WIDTH-1:0] tx_axis_tuser = 0;
    reg [DATA_WIDTH-1:0] xgmii_rxd = 0;
    reg [CTRL_WIDTH-1:0] xgmii_rxc = 0;
    reg [TX_PTP_TS_WIDTH-1:0] tx_ptp_ts = 0;
    reg [RX_PTP_TS_WIDTH-1:0] rx_ptp_ts = 0;
    reg [7:0] ifg_delay = 0;
    reg tx_pause=0;

    // Outputs
    wire tx_axis_tready;
    wire [DATA_WIDTH-1:0] rx_axis_tdata;
    wire [KEEP_WIDTH-1:0] rx_axis_tkeep;
    wire rx_axis_tvalid;
    wire rx_axis_tlast;
    wire [RX_USER_WIDTH-1:0] rx_axis_tuser;
    wire [DATA_WIDTH-1:0] xgmii_txd;
    wire [CTRL_WIDTH-1:0] xgmii_txc;
    wire [TX_PTP_TS_WIDTH-1:0] tx_axis_ptp_ts;
    wire [TX_PTP_TAG_WIDTH-1:0] tx_axis_ptp_ts_tag;
    wire tx_axis_ptp_ts_valid;
    wire [1:0] tx_start_packet;
    wire tx_error_underflow;
    wire [1:0] rx_start_packet;
    wire rx_error_bad_frame;
    wire rx_error_bad_fcs;


    initial begin
        //Assign value here as stimulus

        // Generate the clock
        //For timing simu, try 4ns per half cycle
        rx_clk = 1;
        tx_clk = 1;
        clk = 1'b1;
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

    initial begin
        ifg_delay=8'd12;
        packet_size=8;
        //For timing simulation 100ns. For behavioral, 20ns
        #10

         //  //warmup
         //  tx_axis_tkeep = 8'hff;
         // tx_axis_tvalid = 1'b1;
         // tx_axis_tlast = 1'b0;
         // tx_axis_tuser = 2'b00;
         // tx_axis_tdata = 64'hdd;
         // #2
         //  tx_axis_tdata = 64'haaaaaaaaa;
         // tx_axis_tkeep = 8'h00;
         // #2
         //  tx_axis_tkeep = 8'h00;
         // tx_axis_tdata = 64'hffffffff;



         // // This waits for zero padding
         // #16

         tx_axis_tdata = 64'h01;
        tx_axis_tkeep = 8'hff;
        tx_axis_tvalid = 1'b1;
        tx_axis_tlast = 1'b0;
        tx_axis_tuser = 2'b00;
        // xgmii_rxd = ;
        // xgmii_rxc = ;
        // tx_ptp_ts = ;
        // rx_ptp_ts = ;

        for (i=1;i<packet_size-1;i=i+1) begin
            #2
             tx_axis_tdata = tx_axis_tdata +1;
        end

        #2
         tx_pause=1;
        tx_axis_tdata = 64'hdddddddddaaaaaa;
        #2
         tx_axis_tdata = 64'hccccaaaaccccaabb;
        #2
         tx_axis_tlast=1'b1;
        #2
         //  tx_axis_tkeep=8'h00;
         //  tx_axis_tvalid=1'b0;
         #10
         $finish;





    end

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
                UUT (
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
                    // .tx_ptp_ts(tx_ptp_ts),
                    // .rx_ptp_ts(rx_ptp_ts),
                    // .tx_axis_ptp_ts(tx_axis_ptp_ts),
                    // .tx_axis_ptp_ts_tag(tx_axis_ptp_ts_tag),
                    // .tx_axis_ptp_ts_valid(tx_axis_ptp_ts_valid),
                    .tx_start_packet(tx_start_packet),
                    .tx_error_underflow(tx_error_underflow),
                    .rx_start_packet(rx_start_packet),
                    .rx_error_bad_frame(rx_error_bad_frame),
                    .rx_error_bad_fcs(rx_error_bad_fcs),
                    .ifg_delay(ifg_delay),
                    .tx_pause(tx_pause)
                );

endmodule
