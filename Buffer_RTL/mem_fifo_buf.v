module mem_fifo_buf #(
    parameter DEPTH = 8,
    parameter WIDTH = 520
)(
    input [WIDTH-1:0] data_in,
    input  memfin,
    input       reset,
                read,
                write,
                clk,
    output reg [WIDTH-1:0] data_out,
    output reg       empty,
                     full,
    output reg [2:0] space
);
    reg [2:0] rd_ptr,
              wr_ptr;
    reg [WIDTH-1:0] memory [DEPTH-1:0];

    initial begin
        rd_ptr = 0;
        empty =0;
        full = 0;
        space =DEPTH-1;

        memory[0] = 0;
        memory[0] [519 -:8]= 8'h66; 
        memory[0] [519-8 -:64] = 64'h01234578abcdefb;
        memory[0] [63:0] = 64'heeeeeeeeeeeeebbb;
        wr_ptr=1;
    end

always @(posedge memfin) begin

    if (memfin) begin
        if(rd_ptr < wr_ptr) begin
            // $display("memfin, rd_ptr %h", rd_ptr);
            rd_ptr = rd_ptr + 1;
        end
        else if (rd_ptr == DEPTH -1) begin
            rd_ptr=0;
        end
    end
    if(rd_ptr==wr_ptr) begin
        empty=1;
        data_out = 520'hZ;
        $display("mem empty");
    end 
end


    always@(posedge clk or negedge reset ) begin
        if(reset) begin
            empty = 1;
            full = 0;
            rd_ptr = 0;
            wr_ptr = 0;
            space = DEPTH;
        end else begin

            if (wr_ptr>=rd_ptr) space = DEPTH - (wr_ptr-rd_ptr);
            else space = rd_ptr - wr_ptr;
            if(read & !empty) begin
                full=0;
                data_out = memory[rd_ptr];
                

                // $display("reading, data out %h", data_out);
            end 
            else if(empty) begin
                data_out = {WIDTH{1'bZ}};
            end
        end

    if (write & !full && data_in>=0) begin
        memory[wr_ptr] = data_in;
        empty = 0;    
        
        if(wr_ptr == DEPTH-1) begin
            full = 1;
            wr_ptr = 0;
        end
        else begin
            wr_ptr = wr_ptr + 1;
            full = 0;
        end  
    end
end

        // $display("in mem fifo buf, empty=%h",!empty);

endmodule

