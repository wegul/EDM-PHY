module buf_mon (
        input wire clk,
        input wire reset,
        input wire [3:0] memq_space,
        input wire [3:0] netq_space,
        input wire [3:0] reqq_space,
        input wire reqfin,
        memq_empty,
        netq_empty,
        reqq_empty,


        output reg memq_read,
        netq_read,
        reqq_read,
        memq_reset,
        netq_reset,
        reqq_reset,


        output reg [1:0] sel,
        output reg tx_pause=0
        // assert to de-assert tx_axis_tready in axis_xgmii_tx L588
    );

    localparam thres = 3'd5;

    localparam [1:0]
               SYNC_DATA = 2'b10,
               SYNC_CTRL = 2'b01;

    localparam [1:0]
               SEND_REQ = 2'b01,
               SEND_MEM = 2'b10,
               SEND_NET = 2'b11;

    always@(posedge clk, posedge reset) begin
        if(reset) begin
            memq_reset<=1;
            netq_reset<=1;
            reqq_reset<=1;
            reqq_read<=0;
            memq_read<=0;
            netq_read<=0;
        end
        else begin
            memq_reset<=0;
            netq_reset<=0;
            reqq_reset<=0;
        end
    end

    always @(*) begin
        if (!reqfin) begin
            sel=SEND_REQ;
            netq_read=0;
            memq_read=0;
            reqq_read=1;
        end
        else if(!memq_empty) begin
            sel=SEND_MEM;
            netq_read=0;
            memq_read=1;
            reqq_read=0;
        end
        else if (!reqq_empty) begin
            sel=SEND_REQ;
            netq_read=0;
            memq_read=0;
            reqq_read=1;
        end
        else begin
            if(!netq_empty) begin
                sel=SEND_NET;
                netq_read=1;
                memq_read=0;
                reqq_read=0;
            end
            else begin
                //all empty, send 000001e. See ipg_tx
                sel=2'b00;
                netq_read=0;
                memq_read=0;
                reqq_read=0;
            end

        end

        if (netq_space < thres) begin
            tx_pause = 1'b1;
        end
        else tx_pause = 0;
    end










endmodule
