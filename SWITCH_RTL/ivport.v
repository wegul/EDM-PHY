`resetall
`timescale 1ns / 1ps
`default_nettype none

/*

Get input from ovport;
Maintain THREE queues (rreq, wreq and rresp), depending on those valid bits to decide which queue to push the fwd_ipg_data;
fire_type_sel will give a selection of which queue to pop.
If fire_type_sel enabled, select a queue by fire_type_sel to pop to fire_ipg_data
*/

module ivport #(
        parameter DATA_WIDTH = 64,
        parameter HDR_WIDTH = 2,
        parameter QUE_DEPTH = 6
    ) (
        input wire clk,
        input wire rst,
        input wire wreq_valid,
        input wire rreq_valid,
        input wire rresp_valid,
        input wire fwd_en,//ingress enable
        input wire [DATA_WIDTH-1:0] fwd_ipg_data,

        input wire[1:0] fire_type_sel,
        input wire fire_en,//egress enable
        output wire [DATA_WIDTH-1:0] fire_ipg_data,

        output wire rreq_empty,wreq_empty,rresp_empty,rreq_full,wreq_full,rresp_full,
        output wire [QUE_DEPTH:0] rreq_space,wreq_space,rresp_space
    );
    localparam  [1:0]
                FIRE_DISABLE=2'd3,
                FIRE_RREQ=2'd0,
                FIRE_RRESP=2'd1,
                FIRE_WREQ=2'd2;

    wire [DATA_WIDTH-1:0] rreq,wreq,rresp;
    wire [QUE_DEPTH:0] rreq_space,wreq_space,rresp_space;



    assign fire_ipg_data = (fire_en & fire_type_sel == FIRE_RREQ) ? rreq :
           (fire_en & fire_type_sel == FIRE_RRESP) ? rresp :
           (fire_en & fire_type_sel == FIRE_WREQ) ? wreq :  1'bz;


    mem_fifo_buf rreqQ(
                     .clk (clk),
                     .reset(rst),
                     .rd(fire_en & fire_type_sel == FIRE_RREQ),
                     .wr(rreq_valid & fwd_en),
                     .r_data (rreq),
                     .w_data (fwd_ipg_data),
                     .empty (rreq_empty),
                     .full (rreq_full),
                     .space(rreq_space)
                 );
    mem_fifo_buf wreqQ(
                     .clk (clk),
                     .reset(rst),
                     .rd(fire_en & fire_type_sel == FIRE_WREQ),
                     .wr(wreq_valid & fwd_en),
                     .r_data (wreq),
                     .w_data (fwd_ipg_data),
                     .empty (wreq_empty),
                     .full (wreq_full),
                     .space(wreq_space)
                 );
    mem_fifo_buf rrespQ(
                     .clk (clk),
                     .reset(rst),
                     .rd(fire_en & fire_type_sel == FIRE_RRESP),
                     .wr(rresp_valid & fwd_en),
                     .r_data (rresp),
                     .w_data (fwd_ipg_data),
                     .empty (rresp_empty),
                     .full (rresp_full),
                     .space(rresp_space)
                 );

endmodule


module tb_ivport#(
        parameter DATA_WIDTH = 64,
        parameter HDR_WIDTH = 2
    );
    localparam  [1:0]
                FIRE_DISABLE=2'd0,
                FIRE_RREQ=2'd1,
                FIRE_WREQ=2'd2,
                FIRE_RRESP=2'd3;
    reg clk;
    reg rst;
    reg wreq_valid;
    reg rreq_valid;
    reg rresp_valid;
    reg [DATA_WIDTH-1:0] fwd_ipg_data;

    reg[1:0] fire_type_sel;
    reg fwd_en;
    wire [DATA_WIDTH-1:0] fire_ipg_data;

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
         fwd_en<=1;
        rreq_valid<=1;
        wreq_valid<=0;
        rresp_valid<=0;
        fwd_ipg_data<=64'h008056781234561a;
        fire_type_sel <= FIRE_RREQ;
        #2
         fwd_en<=1;
        rreq_valid<=1;
        wreq_valid<=0;
        rresp_valid<=0;
        fwd_ipg_data<=64'h1118056781234561a;
        #2
         fwd_en<=0;

        #2
         fire_type_sel <= FIRE_DISABLE;
        #4
         $finish;
    end


    ivport DUT(
               .clk(clk),
               .rst(rst),
               .wreq_valid(wreq_valid),
               .rreq_valid(rreq_valid),
               .rresp_valid(rresp_valid),
               .fwd_ipg_data(fwd_ipg_data),
               .fwd_en(fwd_en),
               .fire_type_sel(fire_type_sel),
               .fire_ipg_data(fire_ipg_data)
           );

endmodule
