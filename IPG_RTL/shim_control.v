module shim_control (
        input wire clk,
        input wire [1:0] shim_inc,
        input wire [63:0] shim_ind,
        input wire [1:0] shim_outc,
        input wire [63:0] shim_outd,
        output reg shimq_read
    );
    //if release is asserted, check outc, only de-assert read when term is detected
    reg shimq_read_next;
    reg shim_release=0;
    localparam [1:0]
               SYNC_DATA = 2'b10,
               SYNC_CTRL = 2'b01;
    //once a term is written in, start releasing
    always @(*) begin
        if (shim_ind[7:0]>8'h86 && shim_inc == SYNC_CTRL) shim_release=1;

        if(shim_release) begin
            //upon reading a term, stop releasing and lock until next complete packet
            if(shim_outc == SYNC_CTRL && shim_outd[7:0] > 8'h86) begin
                shimq_read_next=0;
                shim_release=0;
            end
            else shimq_read_next=1;
        end
        else shimq_read_next=0;
    end

    always @(posedge clk ) begin
        shimq_read<=shimq_read_next;
    end

endmodule
