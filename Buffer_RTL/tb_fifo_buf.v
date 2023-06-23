
module tb_fifo_buf;
    reg [511:0] data_in;
    reg       reset,
              read,
              write,
              clk;
    wire [511:0] data_out;
    wire       empty,
               full;
    wire [8:0] space;
    fifo_buf ffs (data_in, reset, read, write, clk, data_out, empty, full, space);
    initial $monitor("WRITE=%b\t READ=%b\t DATA IN:%d\t DATA OUT:%d\t FULL:%s\t EMPTY:%s", 
                        write, read, data_in, data_out, full?"YES":"NO", empty?"YES":"NO");
    always #3 clk = ~clk;
    initial begin
        $display("Synchronous FIFO\n");
        clk=1'b0;
        #5 reset=1'b0;
        #5 reset=1'b1;
        #5 write=1'b1; read=1'b0;
        #5 data_in=1;
        #5 data_in=2;
        #5 data_in=3;
        #5 data_in=5;
        #5 data_in=5;
        #5 data_in=6;
        #5 data_in=7;
        #5 data_in=8;
        #5 write=1'b0; read=1'b1;
        
    end
endmodule