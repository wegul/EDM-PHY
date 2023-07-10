module net_fifo_buf
    #(parameter DWIDTH = 64, CWIDTH = 2, DEPTH = 3)(
         input wire clk, reset,
         input wire rd, wr,
         input wire [DWIDTH-1:0] w_data_d,
         input wire [CWIDTH-1:0] w_data_c,
         output wire empty , full,
         output reg netfin,
         output wire [DWIDTH-1:0] r_data_d,
         output wire [CWIDTH-1:0] r_data_c,
         output reg [DEPTH:0] space
     );
    localparam [1:0]
               SYNC_DATA = 2'b10,
               SYNC_CTRL = 2'b01;


    reg [DWIDTH - 1:0] darray_reg [2**DEPTH-1:0];
    reg [CWIDTH - 1:0] carray_reg [2**DEPTH-1:0];
    reg [DEPTH - 1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;
    reg [DEPTH - 1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;
    reg full_reg, empty_reg, full_next, empty_next;
    wire wr_en;

    always @(posedge clk) begin
        if (wr_en) begin
            darray_reg[w_ptr_reg] <= w_data_d;
            carray_reg[w_ptr_reg] <= w_data_c;
        end
    end

    assign r_data_d = darray_reg[r_ptr_reg];
    assign r_data_c = carray_reg[r_ptr_reg];
    assign wr_en = wr & (~full_reg);

    initial
    begin
        w_ptr_reg <= 0;
        r_ptr_reg <= 0;
        full_reg <= 1'b0;
        empty_reg <= 1'b1;
        space <= 2**DEPTH;
        netfin<=1;
    end


    always @(posedge clk , posedge reset) begin
        if(reset)
        begin
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
            full_reg <= 1'b0;
            empty_reg <= 1'b1;
            space <= 2**DEPTH;
            netfin<=1;
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
        if(empty) begin
            netfin=1;
        end
        if(rd & ~empty) begin
            if(r_data_c==SYNC_CTRL && r_data_d[7:0]>8'h86) begin
                netfin=1;
            end
            else netfin=0;
        end
    end

    always @*
    begin
        w_ptr_succ = w_ptr_reg+1;
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
                    if (w_ptr_succ == r_ptr_reg)
                        full_next = 1'b1;
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
