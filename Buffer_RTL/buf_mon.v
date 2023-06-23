module buf_mon (
    input wire clk,
    input wire [2:0] memq_space,
    input wire [2:0] netq_space,
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

initial begin
    ipg_en =0;
    memq_reset=0;
    netq_reset=0;

end

always@(posedge clk) begin
    if (netq_space<=1 || memq_empty) begin
        if(!netq_empty) begin
            ipg_en = 0;
            netq_read = 1;
            memq_read = 0;
        end
    end

    else if (netfin) begin
        // $display("bufmon netfin enableed");
        if(!memq_empty) begin
            ipg_en=1;
            netq_read = 0;
            memq_read = 1;
        end
        else begin
            ipg_en = 0;
            netq_read = 1;
            memq_read = 0;
        end
    end
    
    if (memq_space < thres) begin
        tuser[1:0]= 2'b11;
    end
    else tuser[1:0]= 0;

end










endmodule