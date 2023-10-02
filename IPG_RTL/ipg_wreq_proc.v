`resetall
`timescale 1ns / 1ps
`default_nettype none

//1. read the received IPG message
//2. generate message
// 3. transmit the generated message to output [63:0] ipg_msg
module ipg_wreq_proc(
        input wire clk,
        input wire reset,


        // The received frame.
        input wire [63:0] rx_ipg_data,
        input wire [5:0] rx_len,
        input wire wreq_valid,

        output reg [63:0] ipg_write_chunk
        // output reg memq_write
    );

    localparam HDR_WIDTH=16;//packets must be bigger than 16bits. this field is currently for payload length.
    localparam DATA_WIDTH=64;
    localparam ADR_WIDTH=40;
    localparam RX_COUNT = 6;
    localparam PAYLOAD_COUNT = 10;
    localparam PAYLOAD_LEN = 512;



    reg [2:0] state_reg=3'd7, state_next;
    reg [HDR_WIDTH-1:0] hdr;


    reg [ADR_WIDTH-1:0] addr=0;
    reg [ADR_WIDTH/2-1:0] src=0, dst=0;

    reg [PAYLOAD_COUNT-1:0] wr_payload_count;
    reg[PAYLOAD_LEN-1:0] wr_payload=0; //bytes in this array is written to RAM together. Temporarily 64bytes, but could change


    localparam [2:0]
               STATE_WAIT = 3'd0,
               //    STATE_ADDR = 3'd1,
               //    STATE_REPLY = 3'd2,
               STATE_WRITE = 3'd3;
    //    STATE_MEMQ = 3'd4;

    integer i =0;


    always @(posedge clk) begin
        state_next = STATE_WAIT;
        case(state_reg)
            STATE_WAIT: begin
                if (rx_len > 0 && wreq_valid) begin
                    hdr = rx_ipg_data[DATA_WIDTH-1 -: HDR_WIDTH];
                    addr = rx_ipg_data[DATA_WIDTH-1-HDR_WIDTH -: ADR_WIDTH];
                    wr_payload_count = hdr;
                    state_next = STATE_WRITE;

                    // $display("===\n case wait %h %d %d %d\n===",addr,j, state_reg,state_next);
                end
                else begin
                    state_next = STATE_WAIT;
                end
            end

            STATE_WRITE: begin
                if(rx_len > 0 && wreq_valid) begin
                    ipg_write_chunk = rx_ipg_data;
                    if (rx_len < wr_payload_count) begin
                        for (i=1;i<=rx_len;i=i+1) begin
                            wr_payload[wr_payload_count-i] = rx_ipg_data[64-i];
                        end
                        wr_payload_count = wr_payload_count - rx_len;
                    end
                    else begin
                        for(i=1;i<=wr_payload_count;i=i+1) begin
                            wr_payload[wr_payload_count-i] = rx_ipg_data [64-i];
                        end
                        wr_payload_count = 0;
                    end
                    if (wr_payload_count == 0) begin
                        // finish receiving payload
                        //TODO: write payload in memory
                        $display("done writing... %h",wr_payload);
                        addr = 0;
                        state_next=STATE_WAIT;
                    end
                    else begin
                        state_next = STATE_WRITE;
                    end
                end
                else begin
                    state_next = STATE_WRITE;
                end
            end
            default: begin
                state_next=STATE_WAIT;
            end
        endcase
    end

    always @(posedge clk) begin
        state_reg<=state_next;
    end



endmodule
