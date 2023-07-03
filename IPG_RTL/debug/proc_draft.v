`resetall
`timescale 1ns / 1ps
`default_nettype none

//1. read the received IPG message
//2. generate message
// 3. transmit the generated message to output [63:0] ipg_msg
module debug_ipg_proc(
        input wire clk,



        // The received frame.
        input wire [63:0] rx_ipg_data,
        input wire [5:0] rx_len,

        output reg [63:0] ipg_reply_chunk


    );


    /* 1. parse ipg_reply. The format is: 2bit hdr: 00 c_read, 01 c_write, 10 d_read, 11 d_write.
    c_read means it is a control msg and the payload data is addr to be read.
    d_read means it is a data msg and the payload is answer to a read request.

    d_write means it is a control msg and the payload could be either addr or memory data.

     2. ipg_proc should use a state machine to wait for 64bit address. 
     
     3. If read, ipg_proc return Memory data = repeat the 64bit address 8 times

     3. If write. ipg_proc should use the state machine to wait for 512bit memory data.
    */

    parameter HDR_WIDTH=8;

    localparam READ_REQ=0;
    localparam WRITE_REQ=1;

    localparam [7:0]
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

    // reg hdr = 0; // 0 for read, 1 for write
    // reg [63:0] addr=0;
    // reg [511:0] rx_payload = 0;

    reg [HDR_WIDTH-1:0] tx_hdr= 0;
    reg [2:0] state_reg=3'd7, state_next;
    reg [HDR_WIDTH-1:0] rx_hdr; // 0 for read, 1 for write
    reg [63:0] addr;
    reg [6:0] addr_count_reg;
    reg [511:0] rx_payload;
    reg [9:0] rx_payload_count;
    reg [9:0] tx_payload_count;

    reg [519:0] ipg_reply; //will be put in queue by chunks

    wire [63:0] req_addr;
    wire [3:0] adrq_space;
    reg adrq_read,adrq_write,adrq_reset;
    wire adrq_empty,adrq_full;


    localparam [2:0]
               STATE_WAIT = 3'd0,
               STATE_ADDR = 3'd1,
               STATE_REPLY = 3'd2,
               STATE_WRITE = 3'd3,
               STATE_ENQ = 3'd4;

    initial begin
        state_reg =STATE_WAIT;
        state_next= STATE_WAIT;
        addr_count_reg = 7'd64;
        rx_payload_count = 10'd512;
        rx_payload = 0;
        addr = 0;
    end

    integer i =0;


    always @(posedge clk) begin
        state_next = STATE_WAIT;
        case(state_reg)
            STATE_WAIT: begin
                adrq_write=0;
                if (rx_len > 0) begin
                    rx_hdr = rx_ipg_data[63:63-HDR_WIDTH+1];
                    addr_count_reg = addr_count_reg - rx_len + HDR_WIDTH;
                    // addr[63:addr_count_reg] = rx_ipg_data[63-HDR_LEN:64-rx_len];
                    for(i=63;i>=addr_count_reg;i=i-1) begin
                        addr[i] = rx_ipg_data[i-HDR_WIDTH];
                    end
                    state_next = STATE_ADDR;
                    // $display("===\n case wait %h %d %d %d\n===",addr,j, state_reg,state_next);
                end
                else begin
                    state_next = STATE_WAIT;
                end
            end
            STATE_ADDR: begin
                if (rx_len < addr_count_reg) begin
                    // addr[addr_count_reg-1:addr_count_reg-rx_len]=rx_ipg_data[63:64-rx_len];
                    for (i=1;i<=rx_len;i=i+1) begin
                        addr[addr_count_reg-i] = rx_ipg_data[64-i];
                    end
                    addr_count_reg = addr_count_reg - rx_len;
                end
                else begin
                    // addr[addr_count_reg-1:0]=rx_ipg_data[63:64-addr_count_reg];
                    for(i=1;i<=addr_count_reg;i=i+1) begin
                        addr[addr_count_reg-i] = rx_ipg_data [64-i];
                    end
                    addr_count_reg = 0;
                end
                // $display("===\n aaaaa%d\n===",addr_count_reg);
                if (addr_count_reg == 0) begin
                    // finish addr
                    if (rx_hdr == READ_REQ) begin
                        //read request will go to AddrQ
                        state_next = STATE_WAIT;
                        //enqueue, datain is addr(64b)
                        adrq_write =1;
                        addr_count_reg=7'd64;
                    end
                    else if (rx_hdr == WRITE_REQ) begin
                        //write request will be processed immediately
                        state_next = STATE_WRITE;
                    end
                end
                else begin
                    state_next = STATE_ADDR;
                end
            end

            STATE_WRITE: begin
                if (rx_len < rx_payload_count) begin
                    for (i=1;i<=rx_len;i=i+1) begin
                        rx_payload[rx_payload_count-i] = rx_ipg_data[64-i];
                    end
                    rx_payload_count = rx_payload_count - rx_len;
                end
                else begin
                    for(i=1;i<=rx_payload_count;i=i+1) begin
                        rx_payload[rx_payload_count-i] = rx_ipg_data [64-i];
                    end
                    rx_payload_count = 0;
                end
                if (rx_payload_count == 0) begin
                    // finish receiving payload
                    //TODO: write payload in memory
                    $display("done writing... ");

                    // rx_payload = 0;
                    rx_payload_count =10'd512;
                    addr = 0;
                    addr_count_reg=7'd64;
                    state_next=STATE_WAIT;
                end
                else begin
                    state_next = STATE_WRITE;
                end
            end
            default: begin
                state_next=STATE_WAIT;
                $display("===\ndefault called\n=== %h",rx_ipg_data);
            end
        endcase
    end

    always @(posedge clk) begin
        state_reg<=state_next;
        adr_state<=adr_state_next;

    end

    reg [2:0] adr_state=STATE_ADDR, adr_state_next;
    always @(posedge clk) begin
        case (adr_state)
            STATE_REPLY: begin
                //extract request from ReadQ and generate reply
                if(~adrq_empty) begin
                    adrq_read=1;

                    ipg_reply = 0;
                    for (i = 0;i<520;i =i+16) begin
                        ipg_reply[i +: 16] = i;
                    end
                    state_next = STATE_ENQ;
                    tx_payload_count = 10'd520;// TODO: could be variable.
                end
                else begin
                    adrq_read=0;
                end
            end

            STATE_ENQ: begin
                adrq_read=0;

                ipg_reply_chunk[7:0] = BLOCK_TYPE_CTRL;
                if(tx_payload_count > 56) begin
                    ipg_reply_chunk[64:8] = ipg_reply[tx_payload_count-1 -: 56];
                    tx_payload_count = tx_payload_count - 56;
                end
                else begin
                    for (i=0;i<tx_payload_count;i=i+1) begin
                        ipg_reply_chunk[63-i] = ipg_reply[tx_payload_count-i-1];
                    end
                    tx_payload_count = 0;
                end
                if(tx_payload_count == 0) begin
                    state_next = STATE_ADDR;
                end
                else state_next = STATE_ENQ;
            end
        endcase
    end





    adr_fifo_buf adrq(
                     .w_data (addr),
                     .reset(adrq_reset),
                     .rd(adrq_read),
                     .wr(adrq_write),
                     .clk (clk),

                     .r_data (req_addr),
                     .empty (adrq_empty),
                     .full (adrq_full),
                     .space(adrq_space)
                 );


endmodule
