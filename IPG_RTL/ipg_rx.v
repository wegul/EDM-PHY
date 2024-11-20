`resetall `timescale 1ns / 1ps `default_nettype none

/*
    Get data from PHY, decode the ipg data and then send to output "rx_ipg_data" for further processing
    Also recover the ipg to zeros.
*/
(* DONT_TOUCH = "TRUE" *)
module ipg_rx (
    input wire clk,
    input wire [1:0] encoded_rx_hdr,
    input wire [63:0] encoded_rx_data,

    (* keep = "TRUE" *) output reg [63:0] rx_ipg_data,
    (* keep = "TRUE" *) output reg [ 5:0] rx_len,

    //recover
    output reg [63:0] recoved_encoded_rx_data,
    output reg [ 1:0] recoved_encoded_rx_hdr,

    //shim layer control for net packets
    output reg shimq_write = 0,

    //read & write control
    output reg wreq_valid,
    output reg rreq_valid,
    output reg rresp_valid,
    // output reg [55:0] ipg_resp,
    output reg en_adapter
);



  localparam [1:0] SYNC_DATA = 2'b10, SYNC_CTRL = 2'b01;

  localparam [7:0] BLOCK_TYPE_READFIRST = 8'h0a,  // I6 I5 I4 I3 I2 I1 I0 BT
  BLOCK_TYPE_RESPFIRST = 8'h0b,  // I6 I5 I4 I3 I2 I1 I0 BT
  BLOCK_TYPE_WRITFIRST = 8'h0c,  // I6 I5 I4 I3 I2 I1 I0 BT

  BLOCK_TYPE_READ = 8'h1a,  // I6 I5 I4 I3 I2 I1 I0 BT
  BLOCK_TYPE_RRESP = 8'h1b,  // I6 I5 I4 I3 I2 I1 I0 BT
  BLOCK_TYPE_WRITE = 8'h1c,  // I6 I5 I4 I3 I2 I1 I0 BT

  BLOCK_TYPE_READLAST = 8'h2a,  // I6 I5 I4 I3 I2 I1 I0 BT
  BLOCK_TYPE_RESPLAST = 8'h2b,  // I6 I5 I4 I3 I2 I1 I0 BT
  BLOCK_TYPE_WRITLAST = 8'h2c,  // I6 I5 I4 I3 I2 I1 I0 BT

  BLOCK_TYPE_CTRL = 8'h1e;  // C7 C6 C5 C4 C3 C2 C1 C0 BT



  always @(posedge clk) begin
    if (encoded_rx_hdr == SYNC_CTRL) begin
      case (encoded_rx_data[7:0])
        BLOCK_TYPE_READ, BLOCK_TYPE_READLAST, BLOCK_TYPE_READFIRST: begin
          en_adapter <= 0;
          rreq_valid <= 1;
          wreq_valid <= 0;
          rresp_valid <= 0;
          rx_ipg_data <= encoded_rx_data;
          rx_len <= 6'd56;
          recoved_encoded_rx_data[7:0] <= BLOCK_TYPE_CTRL;
          recoved_encoded_rx_data[63:8] <= 0;
        end
        BLOCK_TYPE_RRESP, BLOCK_TYPE_RESPLAST, BLOCK_TYPE_RESPFIRST: begin
          en_adapter <= 0;
          rreq_valid <= 0;
          wreq_valid <= 0;
          rresp_valid <= 1;
          rx_ipg_data <= encoded_rx_data;
          rx_len <= 6'd56;
          recoved_encoded_rx_data[7:0] <= BLOCK_TYPE_CTRL;
          recoved_encoded_rx_data[63:8] <= 0;
        end
        // received response (write req) from other host
        BLOCK_TYPE_WRITE, BLOCK_TYPE_WRITLAST, BLOCK_TYPE_WRITFIRST: begin
          en_adapter <= 1;
          rreq_valid <= 0;
          wreq_valid <= 1;
          rresp_valid <= 0;
          rx_ipg_data <= encoded_rx_data;
          rx_len <= 6'd56;
          recoved_encoded_rx_data[7:0] <= BLOCK_TYPE_CTRL;
          recoved_encoded_rx_data[63:8] <= 0;
        end
        default: begin
          rreq_valid <= 0;
          wreq_valid <= 0;
          rresp_valid <= 0;
          rx_ipg_data <= 64'h0;
          rx_ipg_data[63:48] <= 16'heeee;
          rx_len <= 0;
          en_adapter <= 0;
        end
      endcase
    end else begin
      en_adapter <= 0;
      rreq_valid <= 0;
      wreq_valid <= 0;
      rresp_valid <= 0;
      rx_ipg_data <= 0;
      rx_len <= 0;
      recoved_encoded_rx_data <= encoded_rx_data;
      recoved_encoded_rx_hdr <= encoded_rx_hdr;
    end

    if (encoded_rx_data[7:0] == 0 && encoded_rx_hdr == SYNC_CTRL)
      shimq_write <= 0;  // usless, initialization
    else begin
      if (encoded_rx_data[7:0] <= BLOCK_TYPE_CTRL && encoded_rx_hdr == SYNC_CTRL) begin
        shimq_write <= 0;  //has no data
      end else begin
        shimq_write <= 1;
      end
    end

  end

  //   always @(posedge clk) begin
  //     rx_ipg_data <= rx_ipg_data_next;
  //     rx_len <= rx_len_next;
  //     recoved_encoded_rx_data <= recoved_encoded_rx_data_next;
  //     recoved_encoded_rx_hdr <= recoved_encoded_rx_hdr_next;
  //     shimq_write <= shimq_write_next;
  //     wreq_valid <= wreq_valid_next;
  //     rreq_valid <= rreq_valid_next;
  //     rresp_valid <= rresp_valid_next;
  //     en_adapter <= en_adapter_next;
  //   end
endmodule
