`resetall
`timescale 1ns / 1ps
`default_nettype none

//1. read the received IPG message
//2. generate message
// 3. transmit the generated message to output [63:0] ipg_msg
module ipg_rreq_proc(
        input wire clk,
        input wire reset,


        // The received frame.
        input wire [63:0] rx_ipg_data,
        input wire [5:0] rx_len,
        input wire rreq_valid,

        output reg [63:0] ipg_reply_chunk,
        output reg memq_write
    );
    /* 1. parse ipg_reply. The format is: 2bit hdr: 00 c_read, 01 c_write, 10 d_read, 11 d_write.
    c_read means it is a control msg and the payload data is addr to be read.
    d_read means it is a data msg and the payload is answer to a read request.

    d_write means it is a control msg and the payload could be either addr or memory data.

     2. ipg_proc should use a state machine to wait for 64bit address. 
     
     3. If read, ipg_proc return Memory data = repeat the 64bit address 8 times

     3. If write. ipg_proc should use the state machine to wait for 512bit memory data.
    */

    localparam HDR_WIDTH=16;//packets must be bigger than 16bits. this field is currently for payload length.
    localparam DATA_WIDTH=64;
    localparam ADR_WIDTH=40;
    localparam RX_COUNT = 6;
    localparam PAYLOAD_COUNT = 10;
    localparam PAYLOAD_LEN = 512;


    reg [2:0] state_reg=3'd7, state_next;
    reg [HDR_WIDTH-1:0] hdr; // store the length for the msg
    wire [RX_COUNT-1:0] len;// job (received frame) length
    wire [DATA_WIDTH-1:0] ipg_data;


    reg [ADR_WIDTH-1:0] addr=0;
    reg [ADR_WIDTH/2-1:0] src=0, dst=0;


    reg [PAYLOAD_COUNT-1:0] ipg_reply_count;// count how many bits are left in IPG_REPLY. This is for memQ counting
    reg [PAYLOAD_LEN+HDR_WIDTH-1:0] ipg_reply; //will be put in queue by chunks

    wire [3:0] jobq_space;
    reg jobq_reset;
    reg jobq_read;
    wire jobq_empty,jobq_full;

    localparam [2:0]
               STATE_WAIT = 3'd0,
               STATE_ADDR = 3'd1,
               STATE_REPLY = 3'd2,
               //    STATE_WRITE = 3'd3,
               STATE_MEMQ = 3'd4;

    integer i =0;

    always @(posedge clk, negedge reset) begin
        if(reset)begin
            jobq_reset=1;
        end
        else begin
            jobq_reset=0;
        end
    end

    //TODO: using blocking assignment could lead to race. So change assignment of ipg_data* related variable to non-blocking (using ipg_data_next).
    always @(posedge clk) begin
        state_next = STATE_WAIT;
        case(state_reg)
            STATE_WAIT: begin
                memq_write=0;
                if (len > 0 && rreq_valid) begin
                    hdr = ipg_data[DATA_WIDTH-1 -: HDR_WIDTH];
                    addr = ipg_data[DATA_WIDTH-1-HDR_WIDTH -: ADR_WIDTH];

                    state_next = STATE_REPLY;
                    // $display("===\n case wait %h %d %d %d\n===",addr,j, state_reg,state_next);
                end
                else begin
                    state_next = STATE_WAIT;
                end
            end
            STATE_REPLY: begin
                //generate reply, this should be length-variable
                ipg_reply = 0;
                for (i = 0;i<528;i =i+16) begin
                    ipg_reply[i +: 16] = i;
                end
                state_next = STATE_MEMQ;// push generated reply to memq
                addr=0;
            end
            STATE_MEMQ: begin
                memq_write=1;// writing to memq, which is to transmit mem replies...
                ipg_reply_chunk=64'hffffffffffffffff;
                ipg_reply_chunk[7:0] = 8'h1c;
                if (ipg_reply_count > 56) begin
                    ipg_reply_chunk[DATA_WIDTH-1:8] = ipg_reply[ipg_reply_count-1 -: 56];
                    ipg_reply_count = ipg_reply_count - 56;
                end
                else begin
                    for (i=0;i<ipg_reply_count;i=i+1) begin
                        ipg_reply_chunk[63-i] = ipg_reply[ipg_reply_count-i-1];
                    end
                    ipg_reply_count = 0;
                end
                if(ipg_reply_count == 0) begin
                    state_next = STATE_WAIT;
                end
                else state_next = STATE_MEMQ;
            end
            default: begin
                state_next=STATE_WAIT;
            end
        endcase
    end

    always @(*) begin
        case(state_next)
            STATE_WAIT: begin
                if(!jobq_empty) jobq_read=1;
                else jobq_read=0;
            end
            default: jobq_read=0;
        endcase
    end


    always @(posedge clk) begin
        state_reg<=state_next;
    end

    job_fifo_buf jobq(
                     .w_data_d (rx_ipg_data),
                     .w_data_c (rx_len),
                     .reset(jobq_reset),
                     .rd(jobq_read),
                     .wr(rreq_valid),
                     .clk (clk),

                     .r_data_d (ipg_data),
                     .r_data_c (len),
                     .empty (jobq_empty),
                     .full (jobq_full),
                     .space(jobq_space)
                 );


endmodule
