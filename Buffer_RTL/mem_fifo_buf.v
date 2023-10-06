module mem_fifo_buf
    #(parameter WIDTH = 64, DEPTH = 6)(
         input wire clk, reset,
         input wire rd, wr,
         input wire [WIDTH-1:0] w_data,
         output wire empty , full,
         output wire [WIDTH-1:0] r_data,
         output reg [DEPTH:0] space
     );



    reg [WIDTH - 1:0] array_reg [2**DEPTH-1:0];
    reg [DEPTH - 1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;
    reg [DEPTH - 1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;
    reg full_reg, empty_reg, full_next, empty_next;

    wire wr_en;

    always @(posedge clk) begin
        if (wr_en) begin
            array_reg[w_ptr_reg] <= w_data;
            // $display("mem wriging %h %h",array_reg[0],w_data);
        end
    end

    assign r_data = array_reg[r_ptr_reg];
    assign wr_en = wr & (~full_reg);

    initial
    begin
        w_ptr_reg <= 0;
        r_ptr_reg <= 0;
        full_reg <= 1'b0;
        empty_reg <= 1'b1;
        space <= 2**DEPTH;
    end

    always @(posedge clk , posedge reset) begin
        if(reset)
        begin
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
            full_reg <= 1'b0;
            empty_reg <= 1'b1;
            space <= 2**DEPTH;
        end
        else
        begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg <= full_next;
            empty_reg <= empty_next;
            if(w_ptr_reg > r_ptr_reg) begin
                space <= 2**DEPTH - (w_ptr_reg - r_ptr_reg);
            end
            else begin
                space <= r_ptr_reg - w_ptr_reg;
            end
        end
    end

    always @*
    begin
        w_ptr_succ = w_ptr_reg + 1;
        r_ptr_succ = r_ptr_reg + 1;
        w_ptr_next = w_ptr_reg;
        r_ptr_next = r_ptr_reg;
        full_next = full_reg;
        empty_next = empty_reg;

        case ({wr, rd})
            2'b01: begin
                if(~empty_reg)
                begin
                    r_ptr_next = r_ptr_succ;
                    full_next = 1'b0;
                    if(r_ptr_succ == w_ptr_reg) begin
                        empty_next = 1'b1;
                    end
                end
            end
            2'b10: begin
                if(~full_reg)
                begin
                    w_ptr_next = w_ptr_succ;
                    empty_next = 1'b0;
                    if (w_ptr_succ == r_ptr_reg) begin
                        full_next = 1'b1;
                    end
                end
            end
            2'b11:
            begin
                if(~empty_reg) begin
                    w_ptr_next = w_ptr_succ;
                    r_ptr_next = r_ptr_succ;
                end
            end
            2'b00:;
        endcase
    end

    assign full = full_reg;
    assign empty = empty_reg;


endmodule

module tb_mem_fifo_buf;

    // Parameters for the FIFO
    parameter WIDTH = 64;
    parameter DEPTH = 6;

    // Clock and reset signals
    reg clk;
    reg reset;

    // Control signals
    reg rd;
    reg wr;

    // Data signals
    reg [WIDTH-1:0] w_data;
    wire [WIDTH-1:0] r_data;
    wire full;
    wire empty;
    wire [DEPTH:0] space;

    // Instantiate the mem_fifo_buf module
    mem_fifo_buf #(WIDTH, DEPTH) uut (
                     .clk(clk),
                     .reset(reset),
                     .rd(rd),
                     .wr(wr),
                     .w_data(w_data),
                     .r_data(r_data),
                     .full(full),
                     .empty(empty),
                     .space(space)
                 );

    // Clock Generation
    initial begin
        clk = 1;
        forever #1 clk = ~clk;
    end

    // Stimulus
    initial begin
        reset<=1;
        rd<=0;wr<=0;
        #6
         reset<=0;
        #2
         rd<=1;wr<=0;
        #2
         wr<=1;
        rd<=1;
        w_data<=64'h008056781234561a;
        #2
         rd<=0;
        wr<=1;
        w_data<=64'h111111111114561a;
        #2
         rd<=0;
        wr<=1;
        w_data<=64'h222222222224561a;
        #2
         rd<=1;wr<=1;
        w_data<=64'h33333333334561a;
        #2
         rd<=0;wr<=0;
        #10
         $finish;
    end

endmodule
