// Language: Verilog 2001

`timescale 1ns / 100ps

/*
 * Testbench for eth_mac_10g
 */
module vivadotest_ipg_mac_phy_10g;


    //**************** For MAC+PHY begin ****************
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
    //**************** For MAC+PHY end ****************

    //**************** For MAC-Only begin ****************
    // Parameters

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

    //******* MAC TX *******
    reg [DATA_WIDTH-1:0] tx_axis_tdata = 0;
    reg [KEEP_WIDTH-1:0] tx_axis_tkeep = 0;
    reg tx_axis_tvalid = 0;
    reg tx_axis_tlast = 0;
    reg [TX_USER_WIDTH-1:0] tx_axis_tuser = 0;
    reg [TX_PTP_TS_WIDTH-1:0] tx_ptp_ts = 0;
    reg [RX_PTP_TS_WIDTH-1:0] rx_ptp_ts = 0;
    reg [7:0] ifg_delay = 0;

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

    //**************** For MAC-Only end ****************


    //**************** For PHY-Only end ****************
    // Parameters
    parameter HDR_WIDTH = 2;
    parameter BIT_REVERSE = 0;
    parameter SCRAMBLER_DISABLE = 1;
    parameter PRBS31_ENABLE = 0;
    parameter TX_SERDES_PIPELINE = 2;
    parameter RX_SERDES_PIPELINE = 2;
    parameter BITSLIP_HIGH_CYCLES = 1;
    parameter BITSLIP_LOW_CYCLES = 8;
    parameter COUNT_125US = 125000/6.4;


    //******* PHY TX *******
    wire [DATA_WIDTH-1:0] serdes_rx_data;
    wire [HDR_WIDTH-1:0] serdes_rx_hdr;
    reg tx_prbs31_enable = 0;
    reg rx_prbs31_enable = 0;


    wire [DATA_WIDTH-1:0] serdes_tx_data;
    wire [HDR_WIDTH-1:0] serdes_tx_hdr;
    wire serdes_rx_bitslip;
    wire [6:0] rx_error_count;
    wire rx_bad_block;
    wire rx_block_lock;
    wire rx_high_ber;


    //**************** For PHY-Only end ****************


    assign serdes_rx_data = serdes_tx_data;
    assign serdes_rx_hdr = serdes_tx_hdr;

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
        #10
         rst = 1'b0;
        rx_rst = 1'b0;
        tx_rst = 1'b0;
    end

    integer i;
    integer packet_size;


    //Objective: create a series of continuous packets - replace /I/ in eth_phy_10g_tx_if.v

    // ********* Pattern *********
    // 1. an one-unit (8 byte) packet (0xdddddddd00000000)
    // 2. IDLE for 20ns.
    // 3. an two-unit (8 byte) packet (0xd1, 0xd2)
    // 4. an eight-unit (64 byte) packet (1~8)
    // ***************************


    // Each unit (8 Bytes) needs one cycle to transmit,
    // indicating a total of 9 cycles for a minimum {8B[Preamble]+64B[4B FCS + 60B data]} packet.

    initial begin
        ifg_delay=8'd12;
        packet_size=8;
        //For timing/functional simulation 104ns. For behavioral, 20ns
        #104

         //1. an one-unit (8 byte) packet (0xdd)
         tx_axis_tkeep = 8'hff;
        tx_axis_tvalid = 1'b1;
        tx_axis_tlast = 1'b1;
        tx_axis_tuser = 2'b00;
        tx_axis_tdata = 64'hdddddddd00000000;
        #2
         tx_axis_tkeep = 8'h00;

        // wait for zero padding(16 for 2ns_clock)
        tx_axis_tdata = 64'haabbddffffff0000;
        #16

         // +++++ Close AXI Transmission +++++
         tx_axis_tlast = 1'b1;
        tx_axis_tkeep = 8'h00;
        tx_axis_tvalid = 1'b0;
        tx_axis_tdata = 64'haabbddffffff0000;
        #2
         // ----- Close AXI Transmission -----


         // 2. IDLE for 20ns.
         #20

         //3. an one-unit (8 byte) packet (0xd1)
         tx_axis_tkeep = 8'hff;
        tx_axis_tvalid = 1'b1;
        tx_axis_tlast = 1'b0;
        tx_axis_tuser = 2'b00;
        tx_axis_tdata = 64'hd111111110000000;
        #2
         tx_axis_tlast = 1'b1;
        tx_axis_tdata = 64'hd222222220000000;
        #2

         // wait for zero padding
         // TODO: why padding time here is 14???
         tx_axis_tdata = 64'haabbddffffff0000;
        #14

         // +++++ Close AXI Transmission +++++
         tx_axis_tkeep = 8'h00;
        tx_axis_tvalid = 1'b0;
        tx_axis_tdata = 64'haabbddffffff0000;
        #2
         // ----- Close AXI Transmission -----


         //4. an eight-unit (64 byte) packet (1~8)
         tx_axis_tkeep = 8'hff;
        tx_axis_tvalid = 1'b1;
        tx_axis_tlast = 1'b0;
        tx_axis_tdata = 64'h01;
        for (i=1;i<packet_size;i=i+1) begin
            #2
             tx_axis_tdata = tx_axis_tdata +1;
        end
        tx_axis_tlast=1'b1;
        #2
         // +++++ Close AXI Transmission +++++
         tx_axis_tkeep = 8'h00;
        tx_axis_tvalid = 1'b0;
        tx_axis_tdata = 64'haabbddffffff0000;
        // ----- Close AXI Transmission -----

    end

    ipg_mac_phy_10g #(
                        .DATA_WIDTH(DATA_WIDTH),
                        .KEEP_WIDTH(KEEP_WIDTH),
                        .HDR_WIDTH(HDR_WIDTH),
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
                        .RX_USER_WIDTH(RX_USER_WIDTH),
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
                        .tx_axis_tdata(tx_axis_tdata),//data
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
                        .serdes_tx_data(serdes_tx_data),
                        .serdes_tx_hdr(serdes_tx_hdr),

                        //echo here
                        .serdes_rx_data(serdes_rx_data),
                        .serdes_rx_hdr(serdes_rx_hdr),

                        .serdes_rx_bitslip(serdes_rx_bitslip),
                        .tx_ptp_ts(tx_ptp_ts),
                        .rx_ptp_ts(rx_ptp_ts),



                        .tx_start_packet(tx_start_packet),
                        .tx_error_underflow(tx_error_underflow),
                        .rx_start_packet(rx_start_packet),
                        .rx_error_count(rx_error_count),
                        .rx_error_bad_frame(rx_error_bad_frame),
                        .rx_error_bad_fcs(rx_error_bad_fcs),
                        .rx_bad_block(rx_bad_block),
                        .rx_block_lock(rx_block_lock),
                        .rx_high_ber(rx_high_ber),
                        .tx_prbs31_enable(tx_prbs31_enable),
                        .rx_prbs31_enable(rx_prbs31_enable),

                        .ifg_delay(ifg_delay)
                    );


endmodule
