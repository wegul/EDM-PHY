

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * 10G Ethernet PHY RX
 */
module eth_phy_10g_rx #
    (
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


        // output wire [DATA_WIDTH-1:0] recoved_encoded_rx_data,
        //received ipg data
        output wire [5:0] rx_len,
        output wire [DATA_WIDTH-1:0] rx_ipg_data
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

    wire [DATA_WIDTH-1:0] encoded_rx_data;
    wire [HDR_WIDTH-1:0]  encoded_rx_hdr;

    wire [DATA_WIDTH-1:0] recoved_encoded_rx_data;
    wire [HDR_WIDTH-1:0]  recoved_encoded_rx_hdr;

    wire [DATA_WIDTH-1:0] shim_outd;
    wire [HDR_WIDTH-1:0] shim_outc;
    wire shimq_write,shimq_read;


    eth_phy_10g_rx_if #(
                          .DATA_WIDTH(DATA_WIDTH),
                          .HDR_WIDTH(HDR_WIDTH),
                          .BIT_REVERSE(BIT_REVERSE),
                          .SCRAMBLER_DISABLE(SCRAMBLER_DISABLE),
                          .PRBS31_ENABLE(PRBS31_ENABLE),
                          .SERDES_PIPELINE(SERDES_PIPELINE),
                          .BITSLIP_HIGH_CYCLES(BITSLIP_HIGH_CYCLES),
                          .BITSLIP_LOW_CYCLES(BITSLIP_LOW_CYCLES),
                          .COUNT_125US(COUNT_125US)
                      )
                      eth_phy_10g_rx_if_inst (
                          .clk(clk),
                          .rst(rst),
                          .encoded_rx_data(encoded_rx_data),
                          .encoded_rx_hdr(encoded_rx_hdr),
                          .serdes_rx_data(serdes_rx_data),
                          .serdes_rx_hdr(serdes_rx_hdr),
                          .serdes_rx_bitslip(serdes_rx_bitslip),
                          .serdes_rx_reset_req(serdes_rx_reset_req),
                          .rx_bad_block(rx_bad_block),
                          .rx_sequence_error(rx_sequence_error),
                          .rx_error_count(rx_error_count),
                          .rx_block_lock(rx_block_lock),
                          .rx_high_ber(rx_high_ber),
                          .rx_status(rx_status),
                          .rx_prbs31_enable(rx_prbs31_enable)
                      );
    shim_control controller (
                     .clk(clk),
                     .shim_inc(recoved_encoded_rx_hdr),
                     .shim_ind(recoved_encoded_rx_data),
                     .shim_outc(shim_outc),
                     .shim_outd(shim_outd),
                     .shimq_read(shimq_read)
                 );
    shim_fifo_buf shimq(
                      .w_data_d(recoved_encoded_rx_data),
                      .w_data_c (recoved_encoded_rx_hdr),
                      .reset(rst),
                      .rd(shimq_read),
                      .wr(shimq_write),
                      .clk (clk),
                      //important
                      .r_data_d (shim_outd),
                      .r_data_c (shim_outc),

                      .empty (),
                      .full (),
                      .space()
                  );



    ipg_rx inst_ipg_rx(
               .clk(clk),
               .encoded_rx_data(encoded_rx_data),
               .encoded_rx_hdr(encoded_rx_hdr),

               .rx_ipg_data(rx_ipg_data),
               .rx_len(rx_len),
               .recoved_encoded_rx_data(recoved_encoded_rx_data),
               .recoved_encoded_rx_hdr(recoved_encoded_rx_hdr),

               .shimq_write(shimq_write)
           );


    xgmii_baser_dec_64 #(
                           .DATA_WIDTH(DATA_WIDTH),
                           .CTRL_WIDTH(CTRL_WIDTH),
                           .HDR_WIDTH(HDR_WIDTH)
                       )
                       xgmii_baser_dec_inst (
                           .clk(clk),
                           .rst(rst),
                           .encoded_rx_data(shim_outd),
                           .encoded_rx_hdr(shim_outc),
                           .xgmii_rxd(xgmii_rxd),
                           .xgmii_rxc(xgmii_rxc),
                           .rx_bad_block(rx_bad_block),
                           .rx_sequence_error(rx_sequence_error)
                       );

endmodule

`resetall
