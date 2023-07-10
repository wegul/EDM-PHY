module req_fifo_buf
    #(parameter WIDTH = 64, DEPTH = 3)(
         input wire clk, reset,
         input wire rd, wr,
         input wire [WIDTH-1:0] w_data,
         output wire empty , full,
         output reg reqfin, // when user puts in a request, it should be ended with a DELIM after the last frame.
         // the user makes sure this queue is never empty until a DELIM
         output wire [WIDTH-1:0] r_data,
         output reg [DEPTH:0] space
     );

    localparam DELIM=8'hee;

    reg [WIDTH - 1:0] array_reg [2**DEPTH-1:0];
    reg [DEPTH - 1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;
    reg [DEPTH - 1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;
    reg full_reg, empty_reg, full_next, empty_next;
    wire wr_en;

    always @(posedge clk) begin
        if (wr_en)
            array_reg[w_ptr_reg] <= w_data;
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
        reqfin<=1;
    end

    always @(posedge clk , posedge reset) begin
        if(reset)
        begin
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
            full_reg <= 1'b0;
            empty_reg <= 1'b1;
            space <= 2**DEPTH;
            reqfin<=1;
            // array_reg[0] <=64'hdddddddddaaaaaa;
        end
        else
        begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg <= full_next;
            empty_reg <= empty_next;
            if(w_ptr_reg >= r_ptr_reg) begin
                space <= 2**DEPTH - (w_ptr_reg - r_ptr_reg);
            end
            else begin
                space <= r_ptr_reg - w_ptr_reg;
            end
        end
    end

    always @*
    begin
        // if(empty) begin
        //     reqfin=1;
        // end
        if(rd & ~empty) begin
            if(r_data[7:0] == DELIM) begin
                reqfin=1;
            end
            else reqfin=0;
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
                w_ptr_next = w_ptr_succ;
                r_ptr_next = r_ptr_succ;
            end
            2'b00:;
        endcase
    end

    assign full = full_reg;
    assign empty = empty_reg;


endmodule
