module buf_mon (
        input wire clk,
        input wire reset,
        input wire [3:0] memq_space,
        input wire [3:0] netq_space,
        input wire netfin,
        memq_empty,
        netq_empty,


        output reg memq_read,
        netq_read,
        memq_reset,
        netq_reset,


        output reg ipg_en, // 1 for mem_queue
        output reg [1:0] tuser // set tuser[0] to enter IDLE line406 at axis_xgmii_tx
    );

    localparam thres = 3'd3;



    always@(posedge clk, posedge reset) begin
        if(reset) begin
            memq_reset=1;
            netq_reset=1;
            memq_read=0;
            netq_read=0;
        end
        else begin
            memq_reset=0;
            netq_reset=0;
        end

        case ({memq_empty, netq_empty, netfin})
            //unfinished net transmission
            3'b000: begin
                ipg_en=0;
                memq_read=0;
                netq_read=1;
            end
            3'b100: begin
                ipg_en=0;
                memq_read=0;
                netq_read=1;
            end
            3'b101: begin
                ipg_en=0;
                memq_read=0;
                netq_read=1;
            end
            3'b110: begin
                ipg_en=0;
                memq_read=0;
                netq_read=0;
            end
            3'b111: begin
                ipg_en=0;
                memq_read=0;
                netq_read=0;
            end
            default: begin
                ipg_en=1;
                memq_read=1;
                netq_read=0;
            end
        endcase
        // if(memq_empty) begin
        //     if(!netq_empty) begin
        //         ipg_en=0;
        //         memq_read=0;
        //         netq_read=1;
        //     end
        //     else begin
        //         ipg_en=0;
        //         memq_read=0;
        //         netq_read=0;
        //     end
        // end
        // else begin
        //     if (netfin) begin
        //         ipg_en=1;
        //         memq_read=1;
        //         netq_read=0;
        //     end
        //     else if(!netq_empty) begin
        //         ipg_en=0;
        //         memq_read=0;
        //         netq_read=1;
        //     end
        //     else begin
        //         ipg_en=0;
        //         memq_read=0;
        //         netq_read=0;
        //     end
        // end

        if (netq_space < thres) begin
            tuser[1:0]= 2'b11;
        end
        else tuser[1:0]= 0;

    end










endmodule
