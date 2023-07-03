module test_ipg_proc;

    parameter HDR_WIDTH = 8;
    parameter BIT_REVERSE = 0;
    parameter SCRAMBLER_DISABLE = 1;
    parameter PRBS31_ENABLE = 0;
    parameter TX_SERDES_PIPELINE = 2;
    parameter RX_SERDES_PIPELINE = 2;
    parameter BITSLIP_HIGH_CYCLES = 1;
    parameter BITSLIP_LOW_CYCLES = 8;
    parameter COUNT_125US = 125000/6.4;

    parameter DATA_WIDTH = 64;
    parameter KEEP_WIDTH = (DATA_WIDTH/8);
    parameter CTRL_WIDTH = (DATA_WIDTH/8);

    // Inputs
    reg clk = 0;

    reg [DATA_WIDTH-1:0] rx_ipg_data;
    reg [5:0] rx_len;

    wire [63:0] ipg_reply_chunk;



    initial begin
        clk = 1'b1;

        forever begin
            #1
             clk = ~clk;
        end

    end

    integer i;

    initial begin

        #10
         rx_ipg_data = 64'h00aabb12332155dd;
        rx_len = 24;
        #2
         // rx_ipg_data[0] =0;//0 for read req
         rx_ipg_data = 64'h1122334455660000;
        rx_len = 6'd48;
        #2
         rx_ipg_data = 0;
        rx_len = 0;
        #22




         //write test

         //addr = add add add add add f
         rx_ipg_data = 64'h01addaddffffffff;
        rx_len = 6'd32;
        #2
         rx_ipg_data = 64'haddaddaddfffffff;
        rx_len=6'd40;


        for (i=0;i<5;i=i+1) begin
            #2
             rx_ipg_data = 64'hbb3344556699ffff;
            rx_len = 6'd56;
        end
        #4
         rx_ipg_data = 0;
        rx_len = 0;
        for (i=0;i<5;i=i+1) begin
            #2
             rx_ipg_data = 64'hbb3344556699ffff;
            rx_len = 6'd56;
        end
        #2

         $finish;




    end



    debug_ipg_proc UUT(
                       .clk(clk),
                       .rx_ipg_data(rx_ipg_data),
                       .ipg_reply_chunk(ipg_reply_chunk),
                       .rx_len(rx_len)
                   );

endmodule
