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
        output reg [63:0] recoved_encoded_rx_data,
        output reg [1:0]  recoved_encoded_rx_hdr,

        //shim layer control
        output reg shimq_write=0,
        output wire jobq_write,
        output reg [63:0] ipg_resp
    );



    localparam [1:0]
               SYNC_DATA = 2'b10,
               SYNC_CTRL = 2'b01;

    localparam [7:0]
               BLOCK_TYPE_REQ = 8'h1a, // I6 I5 I4 I3 I2 I1 I0 BT
               BLOCK_TYPE_RESP = 8'h1f, // I6 I5 I4 I3 I2 I1 I0 BT

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

    //exclude resp and short ipg (all CTRLs)
    assign jobq_write = (rx_len>0 && (encoded_rx_data[7:0]<BLOCK_TYPE_CTRL)) ? 1 : 0;

    always@(*) begin
        recoved_encoded_rx_data=encoded_rx_data;
        recoved_encoded_rx_hdr=encoded_rx_hdr;
        if (encoded_rx_hdr == SYNC_CTRL) begin
            case(encoded_rx_data[7:0])
                BLOCK_TYPE_REQ: begin
                    rx_ipg_data=encoded_rx_data;
                    rx_len = 6'd56;
                    recoved_encoded_rx_data[7:0]=BLOCK_TYPE_CTRL;
                    recoved_encoded_rx_data[63:8]=0;
                end
                BLOCK_TYPE_RESP: begin
                    ipg_resp = encoded_rx_data;
                    rx_ipg_data = 64'h0;
                    rx_ipg_data[63:48]=16'habab;
                    rx_len=0;
                    recoved_encoded_rx_data[7:0]=BLOCK_TYPE_CTRL;
                    recoved_encoded_rx_data[63:8]=0;
                end
                default: begin
                    rx_ipg_data = 64'h0;
                    rx_ipg_data[63:48]=16'heeee;
                    rx_len=0;
                end
            endcase
        end

        /* old version (short msg employed)
            if (encoded_rx_hdr == SYNC_CTRL) begin
                // ******Customize: output it to reg[63:0] ipg_data_reg ********
                //clear
                //switch on block type
                case (encoded_rx_data[7:0])
                    BLOCK_TYPE_CTRL: begin // C7 C6 C5 C4 C3 C2 C1 C0 BT
                        rx_ipg_data[63:8]=encoded_rx_data[63:8];
                        recoved_encoded_rx_data[63:8]=0;
                        rx_len = 6'd56;
                    end
                    BLOCK_TYPE_OS_4 : begin // D7 D6 D5 O4 C3 C2 C1 C0 BT
                        rx_ipg_data[31:8]=encoded_rx_data[31:8];
                        recoved_encoded_rx_data[31:8]=0;
                        rx_len = 6'd24;
                    end
                    BLOCK_TYPE_START_4: begin // D7 D6 D5    C3 C2 C1 C0 BT
                        rx_ipg_data[39:8]=encoded_rx_data[39:8];
                        recoved_encoded_rx_data[39:8]=0;
                        rx_len = 6'd32;
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
                        recoved_encoded_rx_data[63:36]=0;
                        rx_len = 6'd24;
                    end
                    BLOCK_TYPE_TERM_0: begin // C7 C6 C5 C4 C3 C2 C1    BT
                        rx_ipg_data[63:8]=encoded_rx_data[63:8];
                        recoved_encoded_rx_data[63:8]=0;
                        rx_len = 6'd56;
                    end
                    BLOCK_TYPE_TERM_1: begin // C7 C6 C5 C4 C3 C2    D0 BT
                        rx_ipg_data[63:16]=encoded_rx_data[63:16];
                        recoved_encoded_rx_data[63:16]=0;
                        rx_len = 6'd48;
                    end
                    BLOCK_TYPE_TERM_2: begin // C7 C6 C5 C4 C3    D1 D0 BT
                        rx_ipg_data[63:24]=encoded_rx_data[63:24];
                        recoved_encoded_rx_data[63:24]=0;
                        rx_len = 6'd40;
                    end
                    BLOCK_TYPE_TERM_3: begin // C7 C6 C5 C4    D2 D1 D0 BT
                        rx_ipg_data[63:32]=encoded_rx_data[63:32];
                        recoved_encoded_rx_data[63:32]=0;
                        rx_len = 6'd32;
                    end
                    BLOCK_TYPE_TERM_4: begin // C7 C6 C5    D3 D2 D1 D0 BT
                        rx_ipg_data[63:40]=encoded_rx_data[63:40];
                        recoved_encoded_rx_data[63:40]=0;
                        rx_len = 6'd24;
                    end
                    BLOCK_TYPE_TERM_5: begin // C7 C6    D4 D3 D2 D1 D0 BT
                        rx_ipg_data[63:48]=encoded_rx_data[63:48];
                        recoved_encoded_rx_data[63:48]=0;
                        rx_len = 6'd16;
                    end
                    // BLOCK_TYPE_TERM_6: begin // C7    D5 D4 D3 D2 D1 D0 BT
                    // nop;
                    // end
                    // BLOCK_TYPE_TERM_7: begin //    D6 D5 D4 D3 D2 D1 D0 BT
                    // nop;
                    // end
                    default: begin
                        rx_ipg_data[63:48]=16'heeee;
                        rx_len = 6'd0;
                    end
                endcase
            end
        */
        if(encoded_rx_data>=0) begin
            if(encoded_rx_data[7:0]==0 && encoded_rx_hdr == SYNC_CTRL) shimq_write=0;// usless, initialization
            else begin
                if(encoded_rx_data[7:0]<=BLOCK_TYPE_CTRL && encoded_rx_hdr == SYNC_CTRL)begin
                    shimq_write=0;//has no data
                end
                else begin
                    // $display("writing to shimq %h",recoved_encoded_rx_data);
                    shimq_write=1;
                end
            end
        end
        else shimq_write=0;

    end
endmodule
