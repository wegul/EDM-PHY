
`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * 10G Ethernet PHY TX
 */
module eth_phy_10g_tx #
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
        input wire [DATA_WIDTH-1:0] ipg_reply_chunk,
        input wire memq_write
    );

    // bus width assertions
    initial begin
        if (DATA_WIDTH != 64) begin
            $error("Error: Interface width must be 64");
            $finish;
        end

        if (CTRL_WIDTH * 8 != DATA_WIDTH) begin
            $error("Error: Interface requires byte (8-bit) granularity");
            $finish;
        end

        if (HDR_WIDTH != 2) begin
            $error("Error: HDR_WIDTH must be 2");
            $finish;
        end
    end

    wire [DATA_WIDTH-1:0] encoded_tx_data;
    wire [HDR_WIDTH-1:0]  encoded_tx_hdr;

    xgmii_baser_enc_64 #(
                           .DATA_WIDTH(DATA_WIDTH),
                           .CTRL_WIDTH(CTRL_WIDTH),
                           .HDR_WIDTH(HDR_WIDTH)
                       )
                       xgmii_baser_enc_inst (
                           .clk(clk),
                           .rst(rst),
                           .xgmii_txd(xgmii_txd),
                           .xgmii_txc(xgmii_txc),
                           .encoded_tx_data(encoded_tx_data),
                           .encoded_tx_hdr(encoded_tx_hdr),
                           .tx_bad_block(tx_bad_block),
                           .netq_write(netq_write)
                       );

    wire [DATA_WIDTH-1:0] proced_encoded_tx_data;
    wire [CTRL_WIDTH-1:0] proced_encoded_tx_hdr;
    wire [1:0] tuser;
    wire netq_write;



    ipg_tx inst_ipg_tx(
               .clk(clk),
               .reset(rst),
               .netq_write(netq_write),
               .memq_write(memq_write),

               .ipg_reply_chunk(ipg_reply_chunk),
               .tuser(tuser),
               .encoded_tx_data(encoded_tx_data),
               .encoded_tx_hdr(encoded_tx_hdr),
               .proced_encoded_tx_data(proced_encoded_tx_data), // this might contain ipg msg
               .proced_encoded_tx_hdr(proced_encoded_tx_hdr)
           );

    eth_phy_10g_tx_if #(
                          .DATA_WIDTH(DATA_WIDTH),
                          .HDR_WIDTH(HDR_WIDTH),
                          .BIT_REVERSE(BIT_REVERSE),
                          .SCRAMBLER_DISABLE(SCRAMBLER_DISABLE),
                          .PRBS31_ENABLE(PRBS31_ENABLE),
                          .SERDES_PIPELINE(SERDES_PIPELINE)
                      )
                      eth_phy_10g_tx_if_inst (
                          .clk(clk),
                          .rst(rst),
                          .encoded_tx_data(proced_encoded_tx_data), // this contains ipg data
                          .encoded_tx_hdr(proced_encoded_tx_hdr),
                          .serdes_tx_data(serdes_tx_data),
                          .serdes_tx_hdr(serdes_tx_hdr),
                          .tx_prbs31_enable(tx_prbs31_enable)
                      );

endmodule

`resetall
