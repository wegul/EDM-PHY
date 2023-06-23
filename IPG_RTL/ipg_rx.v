`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
    Get data from PHY, decode the ipg data and then send to output "rx_ipg_data" for further processing
    Also recover the ipg to zeros.
*/
module ipg_rx(
    input wire clk,
    input wire [1:0] encoded_rx_hdr,
    input wire [63:0] encoded_rx_data,

    output reg [63:0] rx_ipg_data,
    output reg [5:0] rx_len,

    //recover
    output wire [63:0] recoved_encoded_rx_data
);


reg [63:0] recoved_encoded_rx_data_reg=64'h0;


assign recoved_encoded_rx_data = recoved_encoded_rx_data_reg;
// assign rx_ipg_data = ipg_data_reg;
// assign rx_len = rx_len_reg;

localparam [1:0]
    SYNC_DATA = 2'b10,
    SYNC_CTRL = 2'b01;

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



always@(posedge clk) begin
    // $display("encoded rx data %h",encoded_rx_data);
    recoved_encoded_rx_data_reg=encoded_rx_data;
 // ====================================================================================
    if (encoded_rx_hdr == SYNC_CTRL) begin
    // ******Customize: output it to reg[63:0] ipg_data_reg ********
        //clear
        rx_ipg_data = 64'h0;
        
        //switch on block type
        case (encoded_rx_data[7:0]) 
            BLOCK_TYPE_CTRL: begin // C7 C6 C5 C4 C3 C2 C1 C0 BT
                rx_ipg_data[63:8]=encoded_rx_data[63:8];
                recoved_encoded_rx_data_reg[63:8]=0;
                rx_len = 6'd56;
            end 
            BLOCK_TYPE_OS_4 : begin // D7 D6 D5 O4 C3 C2 C1 C0 BT
                rx_ipg_data[31:8]=encoded_rx_data[31:8];
                recoved_encoded_rx_data_reg[31:8]=0;
                rx_len = 6'd24;
            end
            BLOCK_TYPE_START_4: begin // D7 D6 D5    C3 C2 C1 C0 BT
                rx_ipg_data[31:8]=encoded_rx_data[31:8];
                recoved_encoded_rx_data_reg[31:8]=0;
                rx_len = 6'd24;
            end
            // BLOCK_TYPE_OS_START: begin // D7 D6 D5    O0 D3 D2 D1 BT
            // nop;
            // end
            // BLOCK_TYPE_OS_04: begin // D7 D6 D5 O4 O0 D3 D2 D1 BT
            // nop;
            // end
            // BLOCK_TYPE_START_0: begin // D7 D6 D5 D4 D3 D2 D1    BT
            // nop;
            // end
            BLOCK_TYPE_OS_0: begin // C7 C6 C5 C4 O0 D3 D2 D1 BT
                rx_ipg_data[63:40]=encoded_rx_data[63:40];
                recoved_encoded_rx_data_reg[63:40]=0;
                rx_len = 6'd24;
            end
            BLOCK_TYPE_TERM_0: begin // C7 C6 C5 C4 C3 C2 C1    BT
            // TODO: this could be 8!
                rx_ipg_data[63:16]=encoded_rx_data[63:16];
                recoved_encoded_rx_data_reg[63:16]=0;
                rx_len = 6'd48;
            end
            BLOCK_TYPE_TERM_1: begin // C7 C6 C5 C4 C3 C2    D0 BT
                rx_ipg_data[63:24]=encoded_rx_data[63:24];
                recoved_encoded_rx_data_reg[63:24]=0;
                rx_len = 6'd40;
            end
            BLOCK_TYPE_TERM_2: begin // C7 C6 C5 C4 C3    D1 D0 BT
                rx_ipg_data[63:32]=encoded_rx_data[63:32];
                recoved_encoded_rx_data_reg[63:32]=0;
                rx_len = 6'd32;
            end
            BLOCK_TYPE_TERM_3: begin // C7 C6 C5 C4    D2 D1 D0 BT
                rx_ipg_data[63:40]=encoded_rx_data[63:40];
                recoved_encoded_rx_data_reg[63:40]=0;
                rx_len = 6'd24;
            end
            BLOCK_TYPE_TERM_4: begin // C7 C6 C5    D3 D2 D1 D0 BT
                rx_ipg_data[63:48]=encoded_rx_data[63:48];
                recoved_encoded_rx_data_reg[63:48]=0;
                rx_len = 6'd16;
            end
            BLOCK_TYPE_TERM_5: begin // C7 C6    D4 D3 D2 D1 D0 BT
                rx_ipg_data[63:56]=encoded_rx_data[63:56];
                recoved_encoded_rx_data_reg[63:56]=0;
                rx_len = 6'd8;
            end
            // BLOCK_TYPE_TERM_6: begin // C7    D5 D4 D3 D2 D1 D0 BT
            // nop;
            // end
            // BLOCK_TYPE_TERM_7: begin //    D6 D5 D4 D3 D2 D1 D0 BT
            // nop;
            // end
            default: begin
                rx_ipg_data[63:56]=8'hee;
                rx_len = 6'd0;
            end
                
        endcase
    end

    // ====================================================================================
end




endmodule