`timescale 1ns / 100ps

module resp_adapter#(
        parameter IW=56,
        parameter OW = 64
    )(
        input wire clk,
        input wire rst,
        input wire [IW-1:0] in,
        input wire ivalid,
        output reg ovalid,
        output reg [OW-1:0] out
    );
    reg [2*IW-1:0] bits;
    reg [OW-1:0] out_next;
    reg [6:0] iptr=0,iptr_next;
    reg ovalid_next;
    integer i;

    // always @(posedge clk) begin
    //     if(rst) begin
    //         bits=0;
    //         iptr=0;
    //         ovalid=0;
    //         out=0;
    //     end
    //     else begin
    //         if(iptr>=OW) begin// fire and shift
    //             out = bits[OW-1:0];
    //             iptr = iptr-OW;
    //             bits = bits >> OW;
    //             ovalid=1;
    //             $display("1bits=%h, time=%t",bits,$time);
    //         end
    //         else begin
    //             ovalid=0;
    //         end
    //         if(ivalid) begin
    //             bits[iptr +: IW] = in;
    //             iptr = iptr +IW;
    //             $display("2bits=%h, time=%t",bits,$time);
    //         end
    //     end
    // end
    always @(*) begin
        if(rst) begin
            bits=0;
            iptr_next=0;
            ovalid_next=0;
            out_next=0;
        end
        else begin
            iptr_next=iptr;
            if(iptr_next>=OW) begin// fire and shift
                out_next = bits[OW-1:0];
                iptr_next = iptr_next-OW;
                bits = bits >> OW;
                ovalid_next=1;
                $display("1bits=%h, time=%t",bits,$time);
            end
            else begin
                ovalid_next=0;
            end
            if(ivalid) begin
                bits[iptr_next +: IW] = in;
                iptr_next = iptr_next +IW;
                $display("2bits=%h, time=%t",bits,$time);
            end
        end
    end

    always @(posedge clk ) begin
        out<=out_next;
        iptr<=iptr_next;
        ovalid<=ovalid_next;
    end

endmodule
