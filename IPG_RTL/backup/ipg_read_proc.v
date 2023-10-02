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
    localparam ADR_COUNT = 8;
    localparam PAYLOAD_COUNT = 10;
    localparam PAYLOAD_LEN = 512;
    localparam [7:0]
               BLOCK_TYPE_READ = 8'h1a, // I6 I5 I4 I3 I2 I1 I0 BT
               BLOCK_TYPE_WRITE = 8'h1b, // I6 I5 I4 I3 I2 I1 I0 BT
               BLOCK_TYPE_RRESP = 8'h1c,


               BLOCK_TYPE_CTRL     = 8'h1e, // C7 C6 C5 C4 C3 C2 C1 C0 BT

               BLOCK_TYPE_OS_4     = 8'h2d, // D7 D6 D5 O4 C3 C2 C1 C0 BT
               BLOCK_TYPE_START_4  = 8'h33, // D7 D6 D5    C3 C2 C1 C0 BT
               BLOCK_TYPE_OS_START = 8'h66, // D7 D6 D5    O0 D3 D2 D1 BT
               BLOCK_TYPE_OS_04    = 8'h55, // D7 D6 D5 O4 O0 D3 D2 D1 BT
               BLOCK_TYPE_START_0  = 8'h78, // D7 D6 D5 D4 D3 D2 D1    BT
               BLOCK_TYPE_OS_0     = 8'h4b, // C7 C6 C5 C4 O0 D3 D2 D1 BT
               BLOCK_TYPE_TERM_0   = 8'h87, // C7 C6 C5 C4 C3 C2 C1    BT
               BLOCK_TYPE_TERM_1   = 8'h99, // C7 C6 C5 C4 C3 C2    D0 BT
               BLOCK_TYPE_TERM_2   = 8'haa, // C7 C6 C5 C4 C3    D1 D0 BT
               BLOCK_TYPE_TERM_3   = 8'hb4, // C7 C6 C5 C4    D2 D1 D0 BT
               BLOCK_TYPE_TERM_4   = 8'hcc, // C7 C6 C5    D3 D2 D1 D0 BT
               BLOCK_TYPE_TERM_5   = 8'hd2, // C7 C6    D4 D3 D2 D1 D0 BT
               BLOCK_TYPE_TERM_6   = 8'he1, // C7    D5 D4 D3 D2 D1 D0 BT
               BLOCK_TYPE_TERM_7   = 8'hff; //    D6 D5 D4 D3 D2 D1 D0 BT


    reg [2:0] state_reg=3'd7, state_next;
    reg [HDR_WIDTH-1:0] hdr; // store the length for the msg
    wire [RX_COUNT-1:0] len;// job (received frame) length
    wire [DATA_WIDTH-1:0] ipg_data;


    reg [ADR_WIDTH-1:0] addr=0;
    reg [ADR_WIDTH/2-1:0] src=0, dst=0;
    reg [ADR_COUNT-1:0] addr_count_reg=ADR_WIDTH;


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
                    hdr = ipg_data[63:63-HDR_WIDTH+1];
                    addr_count_reg = addr_count_reg - len + HDR_WIDTH;
                    for(i=ADR_WIDTH-1;i>=addr_count_reg;i=i-1) begin
                        addr[i] = ipg_data[i-HDR_WIDTH-DATA_WIDTH];
                    end
                    state_next = STATE_ADDR;
                    // $display("===\n case wait %h %d %d %d\n===",addr,j, state_reg,state_next);
                end
                else begin
                    state_next = STATE_WAIT;
                end
            end
            STATE_ADDR: begin
                if(len > 0 && rreq_valid) begin
                    // parse the address in RAM
                    if (len < addr_count_reg) begin
                        for (i=1;i<=len;i=i+1) begin
                            addr[addr_count_reg-i] = ipg_data[DATA_WIDTH-i];
                        end
                        addr_count_reg = addr_count_reg - len;
                    end
                    else begin
                        for(i=1;i<=addr_count_reg;i=i+1) begin
                            addr[addr_count_reg-i] = ipg_data [64-i];
                        end
                        addr_count_reg = 0;
                    end
                    if (addr_count_reg == 0) begin
                        //check validity
                        src=addr[ADR_WIDTH-1:ADR_WIDTH/2];
                        dst=addr[ADR_WIDTH/2-1:0];
                        if(src!=dst)begin
                            // finish addr
                            state_next = STATE_REPLY;
                            ipg_reply_count = 10'd512+HDR_WIDTH; //could be variable, obtained from hdr.
                        end
                        else begin
                            $display("src == dst, error in ipg_proc");
                            state_next=STATE_WAIT;
                            addr_count_reg=ADR_COUNT;
                            addr=0;
                        end
                    end
                    else begin
                        state_next = STATE_ADDR;
                    end
                end
                else begin
                    state_next = STATE_ADDR;
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
                addr_count_reg=ADR_WIDTH;
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
                // addr_count_reg=ADR_COUNT;
            end
        endcase
    end

    always @(*) begin
        case(state_next)
            STATE_WAIT,STATE_ADDR: begin
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
