`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
Get input from ingress module;
Maintain a sched_table of ivports (p0 p1 p2...).
This table only has THREE rows:
    [rreq, ivport_num]
    [wreq, ivport_num]
    [rresp, ivport_num]

1. Check table, poll the first tuple [rreq, ivport_num];
if not empty, assert fire_en; 
    subtract count;
    if count ==0, remove the item;
if empty, go to the next. (TODO: could add a priority)
2. If table is empty: poll each ivport (empty); if not empty, assert fire_en to it; add to table tuple [ msg_type, ivport_num]

Input manuever:
1. Check if dst is myself, assert flag
2. Based on src, assign fwd_ipg_data to different ivports.
*/

module ovport #(
        parameter OVPORT_ADR = 2,
        parameter DATA_WIDTH = 64,
        parameter ADR_WIDTH =40,
        parameter HDR_WIDTH = 2,
        parameter IPG_HDR_WIDTH = 16,
        parameter QUE_DEPTH = 6,
        parameter LOG_PORT_NUM = 2
    ) (
        input  wire                  clk,
        input  wire                  rst,
        input wire [LOG_PORT_NUM**2-1:0] iv_ipg_en,// = rx_ipg_en
        input wire [(ADR_WIDTH/2)*LOG_PORT_NUM**2-1:0] src_flat,
        input wire [(ADR_WIDTH/2)*LOG_PORT_NUM**2-1:0] dst_flat,
        input wire [LOG_PORT_NUM**2-1:0] wreq_valid,
        input wire [LOG_PORT_NUM**2-1:0] rreq_valid,
        input wire [LOG_PORT_NUM**2-1:0] rresp_valid,
        input wire [(DATA_WIDTH*LOG_PORT_NUM**2)-1:0] fwd_ipg_data_flat,
        output wire tx_ipg_en,
        output wire [DATA_WIDTH-1:0] tx_ipg_data
    );
    localparam PORT_NUM = LOG_PORT_NUM**2;

    wire [ADR_WIDTH/2-1:0] src [LOG_PORT_NUM**2-1:0];
    wire [ADR_WIDTH/2-1:0] dst [LOG_PORT_NUM**2-1:0];

    reg [LOG_PORT_NUM-1:0] port [2:0], port_next [2:0];
    wire [DATA_WIDTH-1:0] fwd_ipg_data [LOG_PORT_NUM**2-1:0];
    wire [DATA_WIDTH-1:0] fire_ipg_data [PORT_NUM-1:0];
    wire [PORT_NUM-1:0] rreq_empty, rresp_empty, wreq_empty;//for ports emptiness check
    reg [PORT_NUM-1:0] fire_en=0,fwd_en;
    reg [2:0] type_en=0, type_en_next;
    reg [1:0] fire_type_sel;
    integer i,j;
    assign tx_ipg_data = fire_ipg_data[port[fire_type_sel]];
    assign tx_ipg_en = fire_type_sel<3 ? 1:0;

    always @(*) begin
        fwd_en = 0;
        for ( j = 0; j<LOG_PORT_NUM**2 ; j=j+1 ) begin
            if (iv_ipg_en[j] & dst[j] == OVPORT_ADR) begin// means if it is an ipg msg and dst is ovp_adr
                fwd_en[src[j]]=1;
            end
        end
    end

    /* Scheduler:
        0.  Check BlockType, mark if it is delimeter. If it is, disable current type_sel port.
        1. POLL: poll all ivports to fill in the empty spot
            check rreq rresp and wreq queue empty e.g., if reqq-p0 non-empty, add to type-port table.
            Likewise, if rresp-p0,p2 nonempty, since port[1](rresp)=1, next time should be p2. so...
                type|port|en                 type|port|en
               -----|----|-----             -----|----|-----
                rreq|  0 | 0         ->      rreq|  0 | 1   
               rresp|  1 | 0                rresp|  2 | 1
                wreq|  0 | 0                 wreq|  0 | 0
        2. FIRE: select a type from table; priority: rreq->rresp->wreq.
    */

    always @(*) begin
        type_en_next=type_en;port_next[0]=port[0];port_next[1]=port[1];port_next[2]=port[2];
        //poll all ivport for all types
        for ( i=1; i<PORT_NUM; i=i+1) begin
            if (!rreq_empty[(port[0]+i)%PORT_NUM] & !type_en[0]) begin
                port_next[0] = (port[0]+i)%PORT_NUM;
                type_en_next[0]=1;
            end
            if (!rresp_empty[(port[1]+i)%PORT_NUM] & !type_en[1]) begin
                port_next[1] = (port[1]+i)%PORT_NUM;
                type_en_next[1]=1;
            end
            if (!wreq_empty[(port[2]+i)%PORT_NUM] & !type_en[2]) begin
                port_next[2] = (port[2]+i)%PORT_NUM;
                type_en_next[2]=1;
            end
        end
        // select type for next transmission, where prioritization takes place: rreq>rresp>wreq
        if(type_en[0] & !rreq_empty[port[0]]) begin
            fire_type_sel = 0;
        end
        else if (type_en[1] & !rresp_empty[port[1]]) begin
            fire_type_sel = 1;
        end
        else if (type_en[2] & !wreq_empty[port[2]]) begin
            fire_type_sel = 2;
        end
        else fire_type_sel = 3;

        if (tx_ipg_data[7:4]==0) begin
            type_en_next[fire_type_sel] = 0;// since the last of this type has been sent, it should be disabled.
        end
    end
    always @(*) begin
        fire_en=0;
        fire_en[port[fire_type_sel]]=1;
    end
    always @(posedge clk ) begin
        if (rst) begin
            port[0]<=1;
            port[1]<=1;
            port[2]<=1;
            type_en<=0;
        end
        else begin
            port[0]<=port_next[0];
            port[1]<=port_next[1];
            port[2]<=port_next[2];
            type_en<=type_en_next;
        end
    end


    // virtual input ports that store inbound ipg msg
    genvar k;
    generate
        for ( k=0; k<PORT_NUM; k=k+1) begin
            assign src[k] = src_flat[k*(ADR_WIDTH/2) +: (ADR_WIDTH/2)];
            assign dst[k] = dst_flat[k*(ADR_WIDTH/2) +: (ADR_WIDTH/2)];
            assign fwd_ipg_data[k] = fwd_ipg_data_flat[k*DATA_WIDTH +: DATA_WIDTH];

            ivport iv (
                       .clk(clk),
                       .rst(rst),
                       .wreq_valid(wreq_valid[k]),
                       .rreq_valid(rreq_valid[k]),
                       .rresp_valid(rresp_valid[k]),
                       .fwd_ipg_data(fwd_ipg_data[k]),
                       //input from ovport
                       .fwd_en(fwd_en[k]),
                       .fire_type_sel(fire_type_sel),
                       .fire_en(fire_en[k]),
                       //output to ovport
                       .fire_ipg_data(fire_ipg_data[k]),
                       .rreq_empty(rreq_empty[k]),
                       .wreq_empty(wreq_empty[k]),
                       .rresp_empty(rresp_empty[k]),
                       .rreq_full(),
                       .wreq_full(),
                       .rresp_full(),
                       .rreq_space(),
                       .wreq_space(),
                       .rresp_space()
                   );
        end
    endgenerate
endmodule


module tb_ovport #(
        parameter OVPORT_ADR = 0,
        parameter DATA_WIDTH = 64,
        parameter ADR_WIDTH =40,
        parameter HDR_WIDTH = 2,
        parameter IPG_HDR_WIDTH = 16,
        parameter QUE_DEPTH = 6
    );
    reg                  clk;
    reg                  rst;
    reg [ADR_WIDTH/2:0] src;
    reg [ADR_WIDTH/2:0] dst;
    reg wreq_valid;
    reg rreq_valid;
    reg rresp_valid;
    reg [DATA_WIDTH-1:0] fwd_ipg_data;
    wire [DATA_WIDTH-1:0] tx_ipg_data;
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



    // 1. p0, 1a
    // 2. p0, 1a
    // 3. p0, 1b
    // 3. p0, 1d (b)
    // 4. p1, 1a
    // 5. p1, 1d (a)
    // 6. p0, 1a
    // 7. p0, 1d (a)

    initial begin
        rreq_valid<=0;
        rresp_valid<=0;
        wreq_valid<=0;
        #6
         // 1. p0, 1a
         src<=8;
        dst<=2;
        rreq_valid<=1;
        rresp_valid<=0;
        wreq_valid<=0;
        fwd_ipg_data<=64'h8f1af01fffffff1a;
        #2
         // 2. p0, 1a
         src<=0;
        rreq_valid<=1;
        rresp_valid<=0;
        wreq_valid<=0;
        fwd_ipg_data<=64'h0f1af02fffffff1a;
        #2
         // 3.1 p0, 1b
         src<=0;
        rreq_valid<=0;
        rresp_valid<=1;
        wreq_valid<=0;
        fwd_ipg_data<=64'h0f1bf01ffffff1b;
        #2
         // 3.2 p0, 1b (d)
         src<=0;
        rreq_valid<=0;
        rresp_valid<=1;
        wreq_valid<=0;
        fwd_ipg_data<=64'h0f1bf1dffffff1d;
        #2
         // 4. p1, 1a
         src<=1;
        rreq_valid<=1;
        rresp_valid<=0;
        wreq_valid<=0;
        fwd_ipg_data<=64'h1f1af01ffffff1a;
        #2
         // 5. p1, 1d (a)
         src<=1;
        rreq_valid<=1;
        rresp_valid<=0;
        wreq_valid<=0;
        fwd_ipg_data<=64'h1f1afddffffff1d;
        #2
         // 6. p0, 1a
         src<=0;
        rreq_valid<=1;
        rresp_valid<=0;
        wreq_valid<=0;
        fwd_ipg_data<=64'h0f1af03ffffff1a;
        #2
         // 7. p0, 1d (a)
         src<=0;
        rreq_valid<=1;
        rresp_valid<=0;
        wreq_valid<=0;
        fwd_ipg_data<=64'h0f1af4dffffff1d;
        #2
         // 8. p2, 1c
         src<=2;
        rreq_valid<=0;
        rresp_valid<=0;
        wreq_valid<=1;
        fwd_ipg_data<=64'h2f1cf01ffffff1c;
        #2
         // 9. p2, 1a
         src<=2;
        rreq_valid<=1;
        rresp_valid<=0;
        wreq_valid<=0;
        fwd_ipg_data<=64'h2f1af01ffffff1a;
        #2
         // 10. p2, 1c(d)
         src<=2;
        rreq_valid<=0;
        rresp_valid<=0;
        wreq_valid<=1;
        fwd_ipg_data<=64'h2f1cfd2ffffff1d;
        #2
         // 11. p2, 1a(d)
         src<=2;
        rreq_valid<=1;
        rresp_valid<=0;
        wreq_valid<=0;
        fwd_ipg_data<=64'h2f1af2dffffff1d;
        #8
         $finish;
    end
    ovport DUT(
               .clk(clk),
               .rst(rst),
               .src(src),
               .dst(dst),
               .wreq_valid(wreq_valid),
               .rreq_valid(rreq_valid),
               .rresp_valid(rresp_valid),
               .fwd_ipg_data(fwd_ipg_data),
               .tx_ipg_data(tx_ipg_data)
           );
endmodule

