module frame_filter
    #(
         parameter DWIDTH=64,
         parameter HDR=2
     )
     (
         input wire clk,
         input wire wr_en,
         input wire [DWIDTH-1:0] data_in,
         input wire [HDR-1:0] hdr_in,
         output reg discard // if IDLE is discarded, dont write
     );
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

    reg twin=0; //dont allow twin IDLE (2 or more IDLE in a row)

    always @(posedge clk) begin
        if(wr_en)begin
            //no err or idle frame.
            //note that idle+err = BLOCK_CONTROL
            if(hdr_in == SYNC_CTRL)begin
                if(data_in[7:0] == BLOCK_TYPE_CTRL)begin
                    if(data_in[14:8] != 0) begin
                        //err
                        discard=1;
                    end
                    else if (twin) begin
                        discard=1;
                        twin=1;
                    end
                    else begin
                        discard=0;
                        twin=1;
                    end
                end
                else begin
                    twin=0;
                    discard=0;
                end
            end
            else begin
                twin=0;
                discard=0;
            end
        end
        else discard=0;
    end

endmodule
