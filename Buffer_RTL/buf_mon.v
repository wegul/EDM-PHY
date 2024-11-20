(* DONT_TOUCH = "TRUE" *)
module buf_mon (
    input wire clk,
    input wire reset,
    input wire [3:0] memq_space,
    input wire [5:0] netq_space,
    input wire [3:0] reqq_space,
    input wire memq_empty,
    netq_empty,
    reqq_empty,
    output reg memq_read,
    netq_read,
    reqq_read,
    memq_reset,
    netq_reset,
    reqq_reset,

    output wire [1:0] sel,
    output reg tx_pause = 0
    // assert to de-assert tx_axis_tready in axis_xgmii_tx L588
);

  localparam thres = 3'd4;

  localparam [1:0] SYNC_DATA = 2'b10, SYNC_CTRL = 2'b01;

  localparam [1:0] SEND_REQ = 2'b01, SEND_MEM = 2'b10, SEND_NET = 2'b11;

  reg [1:0] sel_reg;
  assign sel = sel_reg;
  reg memq_read_next, netq_read_next, reqq_read_next;


  always @(posedge clk) begin
    if (reset) begin
      memq_reset <= 1;
      netq_reset <= 1;
      reqq_reset <= 1;
      reqq_read  <= 0;
      memq_read  <= 0;
      netq_read  <= 0;
      tx_pause   <= 0;
    end else begin
      memq_reset <= 0;
      netq_reset <= 0;
      reqq_reset <= 0;

      netq_read  <= netq_read_next;
      memq_read  <= memq_read_next;
      reqq_read  <= reqq_read_next;
      if (netq_space < 26) begin
        // $display("num space=%d",netq_space);
        tx_pause <= 1'b1;
      end else tx_pause <= 0;
    end

  end

  always @(*) begin
    if (!memq_empty) begin
      sel_reg = SEND_MEM;
      netq_read_next = 0;
      memq_read_next = 1;
      reqq_read_next = 0;
    end else if (!reqq_empty) begin
      sel_reg = SEND_REQ;
      netq_read_next = 0;
      memq_read_next = 0;
      reqq_read_next = 1;
    end else begin
      //all empty, send 000001e. See ipg_tx
      sel_reg = 2'b00;
      netq_read_next = 0;
      memq_read_next = 0;
      reqq_read_next = 0;
    end
  end
endmodule
