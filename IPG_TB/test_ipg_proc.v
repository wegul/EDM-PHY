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

wire [519:0] tx_ipg_data;

reg en_req;


reg [63:0] req;
reg qreset=0 , qread, qwrite, qen;

wire [1:0] state, state_next;
wire [63:0] addr;
wire [6:0] addr_count;
wire [9:0] rx_payload_count;
wire [511:0] rx_payload;
wire [HDR_WIDTH-1:0]rx_hdr;


initial begin
    clk = 1'b1;

    forever begin
        #1
        clk = ~clk;
    end

end



initial begin

    #20
    // rx_ipg_data[0] =0;//0 for read req
    rx_ipg_data = 64'h1122334455667700;
    rx_len = 6'd56;
    #2
    rx_ipg_data = 64'haa22334455661100;
    rx_len = 6'd56;
    #2
    rx_ipg_data = 64'hbb33445566990000;
    rx_len = 6'd56;
    
    // $finish;



   
end



debug_ipg_proc UUT(
    .clk(clk),
    .rx_ipg_data(rx_ipg_data),
    .en_req(en_req),
    .req(req),
    .tx_ipg_data(tx_ipg_data),
    .state_reg(state),
    .state_next(state_next),
    .rx_hdr(rx_hdr),
    .addr(addr),
    .addr_count_reg(addr_count),
    .rx_payload_count_reg(rx_payload_count),
    .rx_payload(rx_payload),
    .rx_len(rx_len)


);

endmodule