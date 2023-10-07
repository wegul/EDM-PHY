`resetall
`timescale 1ns / 1ps
`default_nettype none

/* this module takes input from switch; src_addr&dst_addr is given
Egress maintains a virtual oport for each iport
A virtual oport (hereafter oport) has 3 queues rreq, wrea and rresp.
Egress receive a frame, then place it to an oport according to src_addr; the oport then classify the frame into one of the 3 queues according to BlockType (rreq, wreq, rresp).

Every cycle, each oport chooses one frame to send out; The decision is made by a scheduler module (per-port scheduling)
*/

/*
simply fire out a frame at each cycle (encoded tx=fwdipgdata)

*/

module egress #
    (
        parameter DATA_WIDTH = 64,
        parameter CTRL_WIDTH = (DATA_WIDTH/8),
        parameter HDR_WIDTH = 2,
        parameter BIT_REVERSE = 0,
        parameter SCRAMBLER_DISABLE = 1,
        parameter PRBS31_ENABLE = 0,
        parameter SERDES_PIPELINE = 0
    )
    (
        input  wire                  clk,
        input  wire                  rst,

        /*
         * XGMII interface
         */
        input  wire [DATA_WIDTH-1:0] xgmii_txd,
        input  wire [CTRL_WIDTH-1:0] xgmii_txc,

        /*
         * SERDES interface
         */
        output wire [DATA_WIDTH-1:0] serdes_tx_data,
        output wire [HDR_WIDTH-1:0]  serdes_tx_hdr,

        /*
         * Status
         */
        output wire                  tx_bad_block,

        /*
         * Configuration
         */
        input  wire                  tx_prbs31_enable,

        //ipg data to be sent
        input wire tx_ipg_en,
        input wire [DATA_WIDTH-1:0] tx_ipg_data
        // input wire [5:0] rx_len,
        // // output wire [DATA_WIDTH-1:0] rx_ipg_data
        // input wire [DATA_WIDTH-1:0] rreq_in,
        // input wire [DATA_WIDTH-1:0] wreq_in,
        // input wire [DATA_WIDTH-1:0] rresp_in,
        // input wire [4:0] srcPort
    );

    eth_phy_10g_tx #(
                       .DATA_WIDTH(DATA_WIDTH),
                       .CTRL_WIDTH(CTRL_WIDTH),
                       .HDR_WIDTH(HDR_WIDTH),
                       .BIT_REVERSE(BIT_REVERSE),
                       .SCRAMBLER_DISABLE(SCRAMBLER_DISABLE),
                       .PRBS31_ENABLE(PRBS31_ENABLE)
                   )
                   eth_phy_10g_tx_inst (
                       .clk(clk),
                       .rst(rst),
                       .xgmii_txd(xgmii_txd),
                       .xgmii_txc(xgmii_txc),
                       .serdes_tx_data(serdes_tx_data),
                       .serdes_tx_hdr(serdes_tx_hdr),
                       .tx_bad_block(tx_bad_block),
                       .tx_prbs31_enable(tx_prbs31_enable),

                       // input ipg data to be sent
                       .ipg_req_chunk(tx_ipg_data),
                       .reqq_write(tx_ipg_en)
                   );
endmodule



module tb_egress;
    localparam DATA_WIDTH = 64;
    localparam CTRL_WIDTH = 8;
    localparam HDR_WIDTH = 2;



    wire tx_bad_block;

    wire                  tx_prbs31_enable;

    wire [DATA_WIDTH-1:0] xgmii_txd;
    wire [CTRL_WIDTH-1:0] xgmii_txc;

    reg clk,rst;
    wire [DATA_WIDTH-1:0] serdes_tx_data;
    wire [HDR_WIDTH-1:0] serdes_tx_hdr;

    reg [DATA_WIDTH-1:0] tx_ipg_data;
    reg tx_ipg_en;

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
         tx_ipg_en<=1;
        tx_ipg_data<=64'h123456781234561a;
        #2
         tx_ipg_data<=64'h008056781234561a;
        #2
         tx_ipg_data<=64'h666600000000001a;
        #2
         tx_ipg_data<=64'h666600000000001e;


    end

    egress DUT(
               .clk(clk),
               .rst(rst),
               .xgmii_txd(xgmii_txd),
               .xgmii_txc(xgmii_txc),
               .serdes_tx_data(serdes_tx_data),
               .serdes_tx_hdr(serdes_tx_hdr),
               .tx_prbs31_enable(0),

               // input ipg data to be sent
               .tx_ipg_en(tx_ipg_en),
               .tx_ipg_data(tx_ipg_data)
           );

endmodule
