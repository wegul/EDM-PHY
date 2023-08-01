
`timescale 1ns / 100ps

module test_resp_adapter;

    reg [55:0] in;
    reg clk,ivalid,rst;
    wire ovalid;
    wire [63:0] out;
    initial begin
        clk = 1'b1;

        forever begin
            #1
             clk = ~clk;
        end
    end
    initial begin
        rst=1;
        #2
         rst=0;
        ivalid<=1;
        in<=56'h12345678123456;
        #2
         in<=56'h12345678123456;
        #2
         in<=56'h12345678123456;
        #2
         in<=56'h12345678123456;
        #2
         in<=56'h12345678123456;
        #2
         in<=56'h12345678123456;
        #2
         in<=56'h12345678123456;
        #2
         in<=0;
        ivalid<=0;
        #10
         $finish;
    end

    resp_adapter ra(
                     .in(in),
                     .rst(rst),
                     .clk(clk),
                     .ivalid(ivalid),
                     .ovalid(ovalid),
                     .out(out)
                 );

endmodule
