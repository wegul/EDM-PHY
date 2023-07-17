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
    reg reset =1;
    reg jobq_write=0;

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
        reset=1;
        #8
         reset=0;
        #2
         rx_ipg_data = 64'h00aabb12332155dd;
        rx_ipg_data[63:62]=2'b01;
        rx_len = 32;
        jobq_write=1;
        #2
         // rx_ipg_data[0] =0;//0 for read req
         rx_ipg_data = 64'h112233445566cc00;
        rx_len = 6'd56;
        jobq_write=1;
        #2
         // rx_ipg_data[0] =0;//0 for read req
         rx_ipg_data = 64'hdd22334455660000;
        rx_len = 6'd56;
        jobq_write=1;

        // #2
        //  //emulate netpacket preemption
        //  jobq_write=0;
        // rx_ipg_data = 0;
        // rx_len = 0;

        #2
         //write test
         //addr = add add add add add f
         jobq_write=1;
        rx_ipg_data = 64'h0000addaddffffff;
        rx_ipg_data[63:62]=2'b01;
        rx_len = 6'd32;
        #2
         rx_ipg_data = 64'hddaddaddaddfffff;
        rx_len=6'd48;
        for (i=0;i<5;i=i+1) begin
            #2
             rx_ipg_data = 64'hbb3344556699ffff;
            rx_len = 6'd56;
        end
        #4
         jobq_write=0;
        rx_ipg_data = 0;
        rx_len = 0;
        jobq_write=1;
        for (i=0;i<3;i=i+1) begin
            #2
             rx_ipg_data = 64'hbb3344556699ffff;
            rx_len = 6'd56;
        end
        #2
         rx_ipg_data = 64'h1616161616161616;
        rx_len = 8;

        #2
         rx_ipg_data = 64'h0011111111111111;
        rx_len = 24;
        jobq_write=1;
        #2
         // rx_ipg_data[0] =0;//0 for read req
         rx_ipg_data = 64'h2222222222222222;
        rx_len = 6'd56;
        jobq_write=1;
        #2
         rx_ipg_data=0;
        rx_len=0;
        jobq_write=0;
        #40
         $finish;




    end



    ipg_proc UUT(
                 .clk(clk),
                 .reset(reset),
                 .jobq_write(jobq_write),
                 .rx_ipg_data(rx_ipg_data),
                 .ipg_reply_chunk(ipg_reply_chunk),
                 .rx_len(rx_len)
             );

endmodule
