`resetall
`timescale 1ns / 1ps
`default_nettype none


/*  this module takes ingress input from three hosts 0 1 2
    this module initiate three input ports and three output ports
    Each iport gives src&dst address and frames;
    the switch will place frames from an iport to a specific oport according to src&dst
    Each oport receives frames, then classify them to three queues according to BlockType (rreq, wreq, rresp).
*/

module switch_top #
    (
        parameter DATA_WIDTH = 64,
        parameter CTRL_WIDTH = (DATA_WIDTH/8),
        parameter HDR_WIDTH = 2,
        parameter ADR_WIDTH =40,
        parameter LOG_PORT_NUM = 4
    )
    (
        input  wire                  clk,
        input  wire                  rst,
        input wire [(DATA_WIDTH*LOG_PORT_NUM**2)-1:0] serdes_rx_data_flat,
        input wire [(HDR_WIDTH*LOG_PORT_NUM**2)-1:0]  serdes_rx_hdr_flat,

        output wire [(DATA_WIDTH*LOG_PORT_NUM**2)-1:0] serdes_tx_data_flat,
        output wire [(HDR_WIDTH*LOG_PORT_NUM**2)-1:0]  serdes_tx_hdr_flat
    );
    wire [DATA_WIDTH-1:0] serdes_rx_data [LOG_PORT_NUM**2-1:0];
    wire [DATA_WIDTH-1:0] serdes_tx_data [LOG_PORT_NUM**2-1:0];
    wire [HDR_WIDTH-1:0] serdes_rx_hdr [LOG_PORT_NUM**2-1:0];
    wire [HDR_WIDTH-1:0] serdes_tx_hdr [LOG_PORT_NUM**2-1:0];
    wire [CTRL_WIDTH-1:0] xgmii_rxc [LOG_PORT_NUM**2-1:0];
    wire [DATA_WIDTH-1:0] xgmii_rxd [LOG_PORT_NUM**2-1:0];
    wire [DATA_WIDTH-1:0] xgmii_txd [LOG_PORT_NUM**2-1:0];
    wire [CTRL_WIDTH-1:0] xgmii_txc [LOG_PORT_NUM**2-1:0];

    reg [LOG_PORT_NUM**2-1:0] fwd_wreq_valid, fwd_rreq_valid, fwd_rresp_valid;
    wire [LOG_PORT_NUM**2-1:0] rx_wreq_valid, rx_rreq_valid, rx_rresp_valid;

    wire [ADR_WIDTH/2-1:0] rx_src [LOG_PORT_NUM**2-1:0], rx_dst [LOG_PORT_NUM**2-1:0];//the src and dst field of msg from p_x
    reg [ADR_WIDTH/2-1:0] fwd_src [LOG_PORT_NUM**2-1:0], fwd_dst [LOG_PORT_NUM**2-1:0];

    wire [DATA_WIDTH-1:0] rx_ipg_data [LOG_PORT_NUM**2-1:0];//carry the ingressed ipg_data
    wire  [LOG_PORT_NUM**2-1:0] rx_ipg_en;
    reg [DATA_WIDTH-1:0] fwd_ipg_data [LOG_PORT_NUM**2-1:0];//carry to-be-forwarded ipg_data

    wire [DATA_WIDTH-1:0] tx_ipg_data [LOG_PORT_NUM**2-1:0];//carry the outbound egress ipg_data
    wire [LOG_PORT_NUM**2-1:0] tx_ipg_en;


    // Based on dst, forward it to ov-ivp
    integer i;
    always @(*) begin
        for ( i=0; i<LOG_PORT_NUM**2; i=i+1)begin
            if (rx_ipg_en[i]) begin
                fwd_src[rx_dst[i]]=rx_src[i];
                fwd_dst[rx_dst[i]]=rx_dst[i];
                fwd_rreq_valid[rx_dst[i]]=rx_rreq_valid[i];
                fwd_rresp_valid[rx_dst[i]]=rx_rresp_valid[i];
                fwd_wreq_valid[rx_dst[i]]=rx_wreq_valid[i];

                fwd_ipg_data[rx_dst[i]]=rx_ipg_data[i];
            end
        end
    end

    genvar k;
    generate
        for (k = 0; k < LOG_PORT_NUM**2; k = k + 1) begin
            assign serdes_rx_data[k] = serdes_rx_data_flat[k*DATA_WIDTH +: DATA_WIDTH];
            assign serdes_rx_hdr[k] = serdes_rx_hdr_flat[k*HDR_WIDTH +: HDR_WIDTH];
            assign serdes_tx_data_flat[k*DATA_WIDTH +: DATA_WIDTH] = serdes_tx_data[k];
            assign serdes_tx_hdr_flat[k*HDR_WIDTH +: HDR_WIDTH] = serdes_tx_hdr[k];
        end
        for ( k=0; k<LOG_PORT_NUM**2; k=k+1) begin
            ingress ig (
                        .clk(clk),
                        .rst(rst),
                        .xgmii_rxd(xgmii_rxd[k]),
                        .xgmii_rxc(xgmii_rxc[k]),
                        //input raw
                        .serdes_rx_data(serdes_rx_data[k]),
                        .serdes_rx_hdr(serdes_rx_hdr[k]),
                        .rx_prbs31_enable(0),
                        //output received ipg data
                        .wreq_valid(rx_wreq_valid[k]),
                        .rreq_valid(rx_rreq_valid[k]),
                        .rresp_valid(rx_rresp_valid[k]),
                        .rx_fwd_ipg_data(rx_ipg_data[k]),
                        .rx_ipg_en(rx_ipg_en[k]),
                        .src(rx_src[k]),
                        .dst(rx_dst[k])
                    );
            ovport ovp
                   (
                       .clk(clk),
                       .rst(rst),
                       .src(fwd_src[k]),
                       .dst(fwd_dst[k]),
                       .wreq_valid(fwd_wreq_valid[k]),
                       .rreq_valid(fwd_rreq_valid[k]),
                       .rresp_valid(fwd_rresp_valid[k]),
                       .fwd_ipg_data(fwd_ipg_data[k]),
                       .tx_ipg_en(tx_ipg_en[k]),
                       .tx_ipg_data(tx_ipg_data[k])
                   );
            egress eg(
                       .clk(clk),
                       .rst(rst),
                       .xgmii_txd(xgmii_txd[k]),
                       .xgmii_txc(xgmii_txc[k]),
                       .serdes_tx_data(serdes_tx_data[k]),
                       .serdes_tx_hdr(serdes_tx_hdr[k]),
                       .tx_prbs31_enable(0),

                       // input ipg data to be sent
                       .tx_ipg_en(tx_ipg_en[k]),
                       .tx_ipg_data(tx_ipg_data[k])
                   );
        end
    endgenerate


endmodule



module tb_switch_top;

    // Parameters for the switch_top
    parameter DATA_WIDTH = 64;
    parameter CTRL_WIDTH = (DATA_WIDTH/8);
    parameter HDR_WIDTH = 2;
    parameter ADR_WIDTH = 40;
    parameter LOG_PORT_NUM = 2;

    // Clock and reset signals
    reg clk;
    reg rst;
    // Flattened input and output arrays
    wire [(DATA_WIDTH*LOG_PORT_NUM**2)-1:0] serdes_rx_data_flat;
    wire [(HDR_WIDTH*LOG_PORT_NUM**2)-1:0]  serdes_rx_hdr_flat;

    reg [DATA_WIDTH-1:0] serdes_rx_data [LOG_PORT_NUM**2-1:0];
    reg [HDR_WIDTH-1:0] serdes_rx_hdr [LOG_PORT_NUM**2-1:0];
    wire [HDR_WIDTH-1:0] serdes_tx_hdr [LOG_PORT_NUM**2-1:0];
    wire [DATA_WIDTH-1:0] serdes_tx_data [LOG_PORT_NUM**2-1:0];

    wire [(DATA_WIDTH*LOG_PORT_NUM**2)-1:0] serdes_tx_data_flat;
    wire [(HDR_WIDTH*LOG_PORT_NUM**2)-1:0]  serdes_tx_hdr_flat;
    localparam [1:0]
               SYNC_DATA = 2'b10,
               SYNC_CTRL = 2'b01;

    genvar k;
    generate
        for (k = 0; k < LOG_PORT_NUM**2; k = k + 1) begin
            assign serdes_rx_data_flat[k*DATA_WIDTH +: DATA_WIDTH] = serdes_rx_data[k];
            assign serdes_rx_hdr_flat[k*HDR_WIDTH +: HDR_WIDTH] = serdes_rx_hdr[k];
            assign serdes_tx_data[k] = serdes_tx_data_flat[k*DATA_WIDTH +: DATA_WIDTH];
            assign serdes_tx_hdr[k] = serdes_tx_hdr_flat[k*HDR_WIDTH +: HDR_WIDTH];
        end
    endgenerate
    // Instantiate the switch_top module
    switch_top #(DATA_WIDTH, CTRL_WIDTH, HDR_WIDTH, ADR_WIDTH, LOG_PORT_NUM) uut (
                   .clk(clk),
                   .rst(rst),
                   .serdes_rx_data_flat(serdes_rx_data_flat),
                   .serdes_rx_hdr_flat(serdes_rx_hdr_flat),
                   .serdes_tx_data_flat(serdes_tx_data_flat),
                   .serdes_tx_hdr_flat(serdes_tx_hdr_flat)
               );

    // Clock Generation
    initial begin
        clk = 1;
        forever #1 clk = ~clk;
    end
    initial begin
        for (i = 0; i < LOG_PORT_NUM**2; i = i + 1) begin
            serdes_rx_data[i] <= 0;
            serdes_rx_hdr[i] <= SYNC_CTRL;
        end
        rst <= 1'b1;
        #6
         rst <= 1'b0;
    end
    integer i;
    //incast
    // initial begin
    //     #6
    //      //1. p0 send 1a to p2
    //      serdes_rx_data[0] [63 -: 16] <= 16'd118;//ipg_hdr: length
    //     serdes_rx_data[0] [47 -: 20] <= 20'h0; //src port
    //     serdes_rx_data[0] [27 -: 20] <= 20'h2; // dst port
    //     serdes_rx_data[0] [7:0]<=8'h2a; // blocktype read_first

    //     //2. p3 send 1b to p2
    //     serdes_rx_data[3] [63 -: 16] <= 16'd118;//ipg_hdr: length
    //     serdes_rx_data[3] [47 -: 20] <= 20'h3; //src port
    //     serdes_rx_data[3] [27 -: 20] <= 20'h2; //dst port
    //     serdes_rx_data[3] [7:0]<=8'h2b; // blocktype read_first
    //     #2
    //      serdes_rx_data[0]<=64'h0f2f1af01fffff1a;
    //     serdes_rx_data[3]<=64'h3f2f1bf01fffff1b;
    //     #2
    //      serdes_rx_data[0]<=64'h0f2f0af02fffff0a;
    //     serdes_rx_data[3]<=64'h3f2f0bf02fffff0b;
    //     #2
    //      for (i = 0; i < LOG_PORT_NUM**2; i = i + 1) begin
    //          serdes_rx_data[i] <= 0;
    //          serdes_rx_hdr[i] <= SYNC_CTRL;
    //      end
    //      #10 $stop;
    // end
    initial begin
        #6
         //1. p0 send 1a to p2
         serdes_rx_data[0] [63 -: 16] <= 16'd118;//ipg_hdr: length
        serdes_rx_data[0] [47 -: 20] <= 20'h0; //src port
        serdes_rx_data[0] [27 -: 20] <= 20'h2; // dst port
        serdes_rx_data[0] [7:0]<=8'h2a; // blocktype read_first
        #2
         serdes_rx_data[0]<=64'h0f2f1af01fffff1a;
        #2
         serdes_rx_data[0]<=64'h0f2f0af02fffff0a;
        #2
         //2. p3 send 1b to p2
         serdes_rx_data[3] [63 -: 16] <= 16'd118;//ipg_hdr: length
        serdes_rx_data[3] [47 -: 20] <= 20'h3; //src port
        serdes_rx_data[3] [27 -: 20] <= 20'h2; //dst port
        serdes_rx_data[3] [7:0]<=8'h2b; // blocktype read_first
        #2
         serdes_rx_data[3]<=64'h3f2f1bf01fffff1b;
        #2
         serdes_rx_data[3]<=64'h3f2f0bf02fffff0b;

        #2
         for (i = 0; i < LOG_PORT_NUM**2; i = i + 1) begin
             serdes_rx_data[i] <= 0;
             serdes_rx_hdr[i] <= SYNC_CTRL;
         end
         #10 $stop;
    end

endmodule

