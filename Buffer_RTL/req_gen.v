(* DONT_TOUCH = "TRUE" *)
module req_gen #(
    parameter DATA_WIDTH = 64,
    parameter IPG_WIDTH  = 56,
    parameter PORT_WIDTH = 12,  // src + dst
    parameter REQL_WDITH = 8
) (
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  enable,
    output reg  [DATA_WIDTH-1:0] ipg_req_chunk,
    output reg                   valid_req
);
  // REQ format: [8'b{reply_len}, 12'b{srcport, dstport}] ,[56'b {srcmem}], [56'b {dstmem}]
  // There should be a fixed {len}, two counters for SRC and DST.
  reg [DATA_WIDTH-1:0] ipg_req_chunk_next;
  reg valid_req_next;
  reg [IPG_WIDTH-1:0] mem_addr_count;
  reg [PORT_WIDTH-1:0] port_addr_count;
  reg [REQL_WDITH-1:0] req_len = 8'd160;


  reg [1:0] state, state_next;
  localparam [1:0] STATE_WAIT = 2'd0,  // rreq is exactly: header + blk1 + blk2;
  STATE_BLK1 = 2'd1,  //this is for src_mem_addr
  STATE_BLK2 = 2'd2;


  always @(*) begin
    state_next = STATE_WAIT;
    ipg_req_chunk_next = 0;
    valid_req_next = 0;
    case (state)
      STATE_WAIT: begin
        if (enable) begin
          state_next = STATE_BLK1;
          ipg_req_chunk_next[DATA_WIDTH-1-:REQL_WDITH] = req_len;
          ipg_req_chunk_next[DATA_WIDTH-1-REQL_WDITH-:PORT_WIDTH] = port_addr_count;
          ipg_req_chunk_next[7:0] = 8'h0a;
          valid_req_next = 1'b1;
        end else begin
          state_next = STATE_WAIT;
        end
      end
      STATE_BLK1: begin  // inject src_addr;
        state_next = STATE_BLK2;
        ipg_req_chunk_next[DATA_WIDTH-1-:IPG_WIDTH] = mem_addr_count;
        ipg_req_chunk_next[7:0] = 8'h1a;
        valid_req_next = 1'b1;

      end
      STATE_BLK2: begin
        state_next = STATE_WAIT;
        ipg_req_chunk_next[DATA_WIDTH-1-:IPG_WIDTH] = mem_addr_count;
        ipg_req_chunk_next[7:0] = 8'h2a;
        valid_req_next = 1'b1;
      end
    endcase
  end

  // Counter logic
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      mem_addr_count  <= {IPG_WIDTH{1'b0}};
      port_addr_count <= {PORT_WIDTH{1'b0}};
    end else begin
      if (enable) begin
        mem_addr_count  <= mem_addr_count + 1;
        port_addr_count <= port_addr_count + 1;
      end
      ipg_req_chunk <= ipg_req_chunk_next;
      valid_req <= valid_req_next;
      state <= state_next;
    end

  end

endmodule
