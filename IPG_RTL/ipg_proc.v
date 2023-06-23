`resetall
`timescale 1ns / 1ps
`default_nettype none

//1. read the received IPG message
//2. generate message
// 3. transmit the generated message to output [63:0] ipg_msg
module ipg_proc(
    input wire clk,

   

    // The received frame.
    input wire [63:0] rx_ipg_data,
    input wire [5:0] rx_len,

    input wire en_req,
    input wire [63:0] req, //manually input ipg msg
    
    output reg [511:0] tx_ipg_data,

    output reg qreset,
                qread,
                qwrite,
                qen
);


/* 1. parse tx_ipg_data. The format is: 2bit hdr: 00 c_read, 01 c_write, 10 d_read, 11 d_write. 
c_read means it is a control msg and the payload data is addr to be read.
d_read means it is a data msg and the payload is answer to a read request.

d_write means it is a control msg and the payload could be either addr or memory data.

 2. ipg_proc should use a state machine to wait for 64bit address. 
 
 3. If read, ipg_proc return Memory data = repeat the 64bit address 8 times

 3. If write. ipg_proc should use the state machine to wait for 512bit memory data.
*/

parameter HDR_LEN=1;

localparam READ_REQ=0;
localparam WRITE_REQ=1;


reg hdr = 0; // 0 for read, 1 for write
reg [63:0] addr=0;
reg [63:0] rx_payload = 0;// should be 512

reg [63:0] tx_payload = 0;



localparam [1:0]
    STATE_WAIT = 2'd0,
    STATE_ADDR = 2'd1,
    STATE_REPLY = 2'd2,
    STATE_WRITE = 2'd3;



reg [2:0] state_reg = STATE_WAIT, state_next;

reg [6:0] addr_count_reg = 7'd64;
reg [9:0] payload_count_reg = 10'd512;


reg [511:0] payload;


initial begin
    qreset =1 ;
end



//TODO: make IPG stream preemptable.
always @(posedge clk) begin
    state_reg <= state_next;
end

integer i =0;



always@(posedge clk) begin
    state_next = STATE_WAIT;
    case(state_reg)
        STATE_WAIT: begin
            // some request to send
            if (en_req == 1) begin
                tx_ipg_data = req;
                state_next=STATE_WAIT;
            end

            // wait for ipg and get hdr
            else if (rx_len > 0) begin
                hdr = rx_ipg_data[63:63-HDR_LEN+1];
                addr_count_reg = addr_count_reg - rx_len + HDR_LEN;
                // addr[63:addr_count_reg] = rx_ipg_data[63-HDR_LEN:64-rx_len]; 
                
                for(i=63;i>=addr_count_reg;i=i-1) begin
                    addr[i] = rx_ipg_data[i-HDR_LEN];
                end

                state_next = STATE_ADDR;
            end
            else begin
                state_next = STATE_WAIT;
                addr_count_reg = 7'd64;
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
            if (addr_count_reg == 0) begin
                // finish addr
                if (hdr == READ_REQ) begin
                    state_next = STATE_REPLY;
                end
                else if (hdr == WRITE_REQ) begin
                    state_next = STATE_WRITE;
                end
                addr = 0;
                addr_count_reg=7'd64;

            end
            else begin
                state_next = STATE_ADDR;
            end
        end

        STATE_REPLY: begin
            tx_ipg_data = 512'hccc00ccc;
            qreset = 0;
            qwrite = 1;
            qread = 0;
            qen  = 0;



            state_next = STATE_WAIT;
        end

        STATE_WRITE: begin
            if (rx_len < payload_count_reg) begin
                for (i=1;i<=rx_len;i=i+1) begin
                    payload[payload_count_reg-i] = rx_ipg_data[64-i];
                end
                payload_count_reg = payload_count_reg - rx_len;
            end
            else begin
                for(i=1;i<=payload_count_reg;i=i+1) begin
                    payload[payload_count_reg-i] = rx_ipg_data [64-i];
                end
                payload_count_reg = 0;
            end
            if (payload_count_reg == 0) begin
                // finish receiving payload
                //TODO: write payload in memory
                payload = 0;
                payload_count_reg =10'd512;
            end
            else begin
                state_next = STATE_WRITE;
            end
        end



    endcase


end


// assign tx_ipg_data = rx_ipg_data*12;




endmodule