module req_gen(
        input wire clk,
        output wire reqq_write,
        output wire [63:0] ipg_req_chunk
    );
    localparam DELIM=8'hee;

    assign ipg_req_chunk = {{56'h0},{DELIM}};
    assign reqq_write = 1;

endmodule
