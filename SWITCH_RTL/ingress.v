`resetall
`timescale 1ns / 1ps
`default_nettype none


/* this module is responsible of receiving and ipg data from a host, i.e., frames with 1a,1b,1c blocktypes.
    The parsed src and dst addr will output to src and dst port. (must have ipg_rreq_proc and ipg_wreq_proc)
    The received frames will be sent out in ONE output rx_ipg_data
*/
module ingress #
    (
        parameter ADR_WIDTH= 40,
        parameter DATA_WIDTH = 64,
        parameter CTRL_WIDTH = (DATA_WIDTH/8),
        parameter HDR_WIDTH = 2,
        parameter BIT_REVERSE = 0,
        parameter SCRAMBLER_DISABLE = 1,
        parameter PRBS31_ENABLE = 0,
        parameter SERDES_PIPELINE = 0,
        parameter BITSLIP_HIGH_CYCLES = 1,
        parameter BITSLIP_LOW_CYCLES = 8,
        parameter COUNT_125US = 125000/6.4
    )
    (
        input  wire                  clk,
        input  wire                  rst,

        /*
         * XGMII interface
         */
        output wire [DATA_WIDTH-1:0] xgmii_rxd,
        output wire [CTRL_WIDTH-1:0] xgmii_rxc,

        /*
         * SERDES interface
         */
        input  wire [DATA_WIDTH-1:0] serdes_rx_data,
        input  wire [HDR_WIDTH-1:0]  serdes_rx_hdr,
        output wire                  serdes_rx_bitslip,
        output wire                  serdes_rx_reset_req,

        /*
         * Status
         */
        output wire [6:0]            rx_error_count,
        output wire                  rx_bad_block,
        output wire                  rx_sequence_error,
        output wire                  rx_block_lock,
        output wire                  rx_high_ber,
        output wire                  rx_status,

        /*
         * Configuration
         */
        input  wire                  rx_prbs31_enable,

        //received ipg data
        output wire rx_ipg_en,
        output wire [DATA_WIDTH-1:0] rx_fwd_ipg_data,
        output reg [ADR_WIDTH/2-1:0] src,
        output reg [ADR_WIDTH/2-1:0] dst,
        output wire wreq_valid,
        output wire rreq_valid,
        output wire rresp_valid
    );

    localparam IPG_HDR_WIDTH=16;//packets must be bigger than 16bits. this field is currently for payload length.

    wire isHdr;
    wire [5:0] rx_len;
    wire [DATA_WIDTH-1:0] rx_ipg_data;

    assign rx_ipg_en = rx_len>0;
    assign rx_fwd_ipg_data = rx_ipg_en ? rx_ipg_data : 1'bz;
    assign isHdr = rx_ipg_en & rx_ipg_data[7:4]==4'h2 ;
    always @(*) begin
        if(isHdr) begin
            src = rx_ipg_data[DATA_WIDTH-IPG_HDR_WIDTH-1 -: ADR_WIDTH/2];
            dst = rx_ipg_data[DATA_WIDTH-IPG_HDR_WIDTH-ADR_WIDTH/2 - 1 -: ADR_WIDTH/2];
        end
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
                   )
                   eth_phy_10g_rx_inst (
                       .clk(clk),
                       .rst(rst),
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


endmodule

module tb_ingress;
    localparam DATA_WIDTH = 64;
    localparam CTRL_WIDTH = 8;
    localparam HDR_WIDTH = 2;


    wire serdes_rx_bitslip;
    wire [6:0] rx_error_count;
    wire rx_bad_block;
    wire                  rx_prbs31_enable;
    wire                  rx_block_lock;
    wire                  rx_high_ber;
    wire                  rx_status;
    wire [DATA_WIDTH-1:0] xgmii_rxd;
    wire [CTRL_WIDTH-1:0] xgmii_rxc;
    wire                  serdes_rx_reset_req;
    wire                  rx_sequence_error;

    wire rreq_valid,wreq_valid,rresp_valid;

    reg clk,rst;
    reg [DATA_WIDTH-1:0] serdes_rx_data;
    reg [HDR_WIDTH-1:0] serdes_rx_hdr;

    initial begin
        clk = 1'b1;
        forever begin
            #1
             clk = ~clk;
        end
    end
    initial begin
        rst = 1'b1;
        #6
         rst = 1'b0;
    end

    initial begin
        #6
         serdes_rx_data<=64'h008056781234561a;
        serdes_rx_hdr<=2'b01;
        #2
         serdes_rx_data<=64'h123456781234561a;
        #2
         serdes_rx_data<=64'h666600000000001a;
        #2
         serdes_rx_data<=64'h666600000000001e;


    end

    ingress DUT(
                .clk(clk),
                .rst(rst),
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

                .wreq_valid(wreq_valid),
                .rreq_valid(rreq_valid),
                .rresp_valid(rresp_valid)
            );
endmodule


