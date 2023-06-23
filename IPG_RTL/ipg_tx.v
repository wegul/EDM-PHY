`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
    Transmit ipg data according to block type. 
    TODO: If the block is not large enough, wait til next block.
*/

module ipg_tx(
    input wire clk,

    //Give information about the next block
    input wire [1:0] encoded_tx_hdr_next,
    input wire [63:0] encoded_tx_data_next,

    input wire [63:0] tx_ipg_data,//From ipg_proc.v

    output wire [63:0] proced_encoded_tx_data_next
);

reg [63:0] proced_encoded_tx_data_reg=64'h0;

assign proced_encoded_tx_data_next = proced_encoded_tx_data_reg;



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


localparam STATE_WAIT =0;
localparam STATE_SEND = 1;

reg state_reg= STATE_WAIT, state_next;

always @(posedge clk) begin
    state_reg <= state_next;
end

reg [6:0] payload_count_reg=7'd64;// msg left to be sent
reg [5:0] tx_len_reg=0;

integer i=0;
always@(posedge clk) begin
    proced_encoded_tx_data_reg = encoded_tx_data_next;

    /*
        IPG data: 
        TERM_5: 2 C code 8'h11 
        TERM_4 3 C code 16'h1122
        TERM_3,OS_0,START_4,OS_4: 4 C code 24'h112233 
        TERM_2 5 C code 32'h11223344
        TERM_1 6 C code 40'h1122334455
        TERM_0 7 C code 48'h112233445566
        CTRL: 8 C code 56'h11223344556677
    */
    // ******Customize********
    if (encoded_tx_hdr_next == SYNC_CTRL) begin
        //switch on block type
        case (encoded_tx_data_next[7:0]) 
            BLOCK_TYPE_CTRL: begin // C7 C6 C5 C4 C3 C2 C1 C0 BT

                tx_len_reg=6'd56;

                if(tx_len_reg<payload_count_reg)begin 
                    // proced_encoded_tx_data_reg[63:8] = tx_ipg_data[payload_count_reg-1:payload_count_reg-1-tx_len_reg];
                    proced_encoded_tx_data_reg[63:8] = tx_ipg_data[payload_count_reg-1 -: 56];
                    payload_count_reg = payload_count_reg - tx_len_reg;


                    // proced_encoded_tx_data_reg[63:8] = 56'h11223344556677;
                end
                else begin
                    
                    // proced_encoded_tx_data_reg[63:64-payload_count_reg] = tx_ipg_data[payload_count_reg-1:0];
                    for (i=63;i>=64-payload_count_reg;i=i-1) begin
                        proced_encoded_tx_data_reg[i] = tx_ipg_data[payload_count_reg-(64-i)];
                    end

                    payload_count_reg = 7'd64;
                end
                
            end 
            BLOCK_TYPE_OS_4 : begin // D7 D6 D5 O4 C3 C2 C1 C0 BT
                // payload_count_reg = payload_count_reg - 24;
                // proced_encoded_tx_data_reg[31:8] = tx_ipg_data[payload_count_reg-1:payload_count_reg-1-23];
                // // proced_encoded_tx_data_reg[31:8] = 24'h112233;

                tx_len_reg=6'd24;

                if(tx_len_reg<payload_count_reg)begin 

                    // proced_encoded_tx_data_reg[31:8] = tx_ipg_data[payload_count_reg-1:payload_count_reg-1-tx_len_reg];
                    proced_encoded_tx_data_reg[31:8] = tx_ipg_data[payload_count_reg-1 -: 24];

                    payload_count_reg = payload_count_reg - tx_len_reg;
                end
                else begin
                    
                    // proced_encoded_tx_data_reg[31:32-payload_count_reg] = tx_ipg_data[payload_count_reg-1:0];
                    for (i=31;i>=32-payload_count_reg;i=i-1) begin
                        proced_encoded_tx_data_reg[i] = tx_ipg_data[payload_count_reg-(32-i)];
                    end

                    payload_count_reg = 7'd64;
                end

            end
            BLOCK_TYPE_START_4: begin // D7 D6 D5    C3 C2 C1 C0 BT
                // proced_encoded_tx_data_reg[31:8] = 24'h112233;
                tx_len_reg=6'd24;

                if(tx_len_reg<payload_count_reg)begin 
                    // proced_encoded_tx_data_reg[31:8] = tx_ipg_data[payload_count_reg-1:payload_count_reg-1-tx_len_reg];
                    proced_encoded_tx_data_reg[31:8] = tx_ipg_data[payload_count_reg-1 -: 24];

                    payload_count_reg = payload_count_reg - tx_len_reg;
                end
                else begin
                    // proced_encoded_tx_data_reg[31:32-payload_count_reg] = tx_ipg_data[payload_count_reg-1:0];
                    for (i=31;i>=32-payload_count_reg;i=i-1) begin
                        proced_encoded_tx_data_reg[i] = tx_ipg_data[payload_count_reg-(32-i)];
                    end

                    payload_count_reg = 7'd64;
                end

            end
            BLOCK_TYPE_OS_0: begin // C7 C6 C5 C4 O0 D3 D2 D1 BT
                // proced_encoded_tx_data_reg[63:40] = 24'h112233;
                tx_len_reg=6'd24;

                if(tx_len_reg<payload_count_reg)begin 
                    
                    // proced_encoded_tx_data_reg[63:40] = tx_ipg_data[payload_count_reg-1:payload_count_reg-1-tx_len_reg];
                    proced_encoded_tx_data_reg[63:40] = tx_ipg_data[payload_count_reg-1 -: 24];

                    payload_count_reg = payload_count_reg - tx_len_reg;
                end
                else begin
                    
                    // proced_encoded_tx_data_reg[63:64-payload_count_reg] = tx_ipg_data[payload_count_reg-1:0];
                    for(i=63;i>=64-payload_count_reg;i=i-1) begin
                        proced_encoded_tx_data_reg[i] = tx_ipg_data[payload_count_reg - (64-i)];
                    end
                    payload_count_reg = 7'd64;
                end
            end
            BLOCK_TYPE_TERM_0: begin // C7 C6 C5 C4 C3 C2 C1    BT
            // TODO: this could be 8!
                // proced_encoded_tx_data_reg[63:16] = 48'h112233445566;
                tx_len_reg=6'd48;

                if(tx_len_reg<payload_count_reg)begin 
                    
                    // proced_encoded_tx_data_reg[63:16] = tx_ipg_data[payload_count_reg-1:payload_count_reg-1-tx_len_reg];
                    proced_encoded_tx_data_reg[63:16] = tx_ipg_data[payload_count_reg-1 -: 48];
                    payload_count_reg = payload_count_reg - tx_len_reg;
                end
                else begin
                    
                    // proced_encoded_tx_data_reg[63:64-payload_count_reg] = tx_ipg_data[payload_count_reg-1:0];
                    for (i=63;i>=64-payload_count_reg;i=i-1) begin
                        proced_encoded_tx_data_reg[i] = tx_ipg_data[payload_count_reg - (64-i)];
                    end
                    payload_count_reg = 7'd64;
                end
            end
            BLOCK_TYPE_TERM_1: begin // C7 C6 C5 C4 C3 C2    D0 BT
                // proced_encoded_tx_data_reg[63:24] = 40'h1122334455;
                tx_len_reg=6'd40;

                if(tx_len_reg<payload_count_reg)begin 
                    
                    // proced_encoded_tx_data_reg[63:24] = tx_ipg_data[payload_count_reg-1:payload_count_reg-1-tx_len_reg];
                    proced_encoded_tx_data_reg[63:24] = tx_ipg_data[payload_count_reg-1 -: 40];
                    payload_count_reg = payload_count_reg - tx_len_reg;
                end
                else begin
                    
                    // proced_encoded_tx_data_reg[63:64-payload_count_reg] = tx_ipg_data[payload_count_reg-1:0];
                    for(i=63;i>=64-payload_count_reg;i=i-1) begin
                        proced_encoded_tx_data_reg[i] = tx_ipg_data[payload_count_reg - (64-i)];
                    end

                    payload_count_reg = 7'd64;
                end

            end
            BLOCK_TYPE_TERM_2: begin // C7 C6 C5 C4 C3    D1 D0 BT
                // proced_encoded_tx_data_reg[63:32] = 32'h11223344;
                tx_len_reg=6'd32;

                if(tx_len_reg<payload_count_reg)begin 
                    
                    // proced_encoded_tx_data_reg[63:32] = tx_ipg_data[payload_count_reg-1:payload_count_reg-1-tx_len_reg];
                    proced_encoded_tx_data_reg[63:32] = tx_ipg_data[payload_count_reg-1 -:32];
                    payload_count_reg = payload_count_reg - tx_len_reg;
                end
                else begin
                    
                    // proced_encoded_tx_data_reg[63:64-payload_count_reg] = tx_ipg_data[payload_count_reg-1:0];
                    for(i=63;i>=64-payload_count_reg;i=i-1) begin
                        proced_encoded_tx_data_reg[i] = tx_ipg_data[payload_count_reg - (64-i)];
                    end
                    payload_count_reg = 7'd64;
                end
            end
            BLOCK_TYPE_TERM_3: begin // C7 C6 C5 C4    D2 D1 D0 BT
                // proced_encoded_tx_data_reg[63:40] = 24'h112233;
                tx_len_reg=6'd24;

                if(tx_len_reg<payload_count_reg)begin 
                    
                    // proced_encoded_tx_data_reg[63:40] = tx_ipg_data[payload_count_reg-1:payload_count_reg-1-tx_len_reg];
                    proced_encoded_tx_data_reg[63:40] = tx_ipg_data[payload_count_reg-1 -: 24];
                    payload_count_reg = payload_count_reg - tx_len_reg;
                end
                else begin
                    
                    // proced_encoded_tx_data_reg[63:64-payload_count_reg] = tx_ipg_data[payload_count_reg-1:0];
                    for(i=63;i>=64-payload_count_reg;i=i-1) begin
                        proced_encoded_tx_data_reg[i] = tx_ipg_data[payload_count_reg - (64-i)];
                    end

                    payload_count_reg = 7'd64;
                end
            end
            BLOCK_TYPE_TERM_4: begin // C7 C6 C5    D3 D2 D1 D0 BT
                // proced_encoded_tx_data_reg[63:48] = 16'h1122;
                tx_len_reg=6'd16;

                if(tx_len_reg<payload_count_reg)begin 
                    
                    proced_encoded_tx_data_reg[63:48] = tx_ipg_data[payload_count_reg-1 -: 16];

                    payload_count_reg = payload_count_reg - tx_len_reg;
                end
                else begin
                    for(i=63;i>=64-payload_count_reg;i=i-1) begin
                        proced_encoded_tx_data_reg[i] = tx_ipg_data[payload_count_reg - (64-i)];
                    end

                    payload_count_reg = 7'd64;
                end
            end
            BLOCK_TYPE_TERM_5: begin // C7 C6    D4 D3 D2 D1 D0 BT
                // proced_encoded_tx_data_reg[63:56] = 8'h11;
                tx_len_reg=6'd8;

                if(tx_len_reg<payload_count_reg)begin 
                    
                    proced_encoded_tx_data_reg[63:56] = tx_ipg_data[payload_count_reg-1 -: 8];

                    payload_count_reg = payload_count_reg - tx_len_reg;
                end
                else begin
                    for(i=63;i>=64-payload_count_reg;i=i-1) begin
                        proced_encoded_tx_data_reg[i] = tx_ipg_data[payload_count_reg - (64-i)];
                    end

                    payload_count_reg = 7'd64;
                end
            end
            default: begin
                proced_encoded_tx_data_reg = encoded_tx_data_next;
                tx_len_reg=0;
            end
        endcase
    end
 


end



endmodule