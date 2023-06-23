module net_fifo_buf #(
    parameter DEPTH = 8,
    parameter DWIDTH = 64,
    parameter CWIDTH =2 //sync header
)(
    input [DWIDTH-1:0] data_ind,
    input [CWIDTH-1:0] data_inc,
    input       reset,
                read,
                write,
                clk,
    output reg [DWIDTH-1:0] data_outd,
    output reg [CWIDTH-1:0] data_outc,
    output reg       empty,
                     full,
                     netfin,
    output reg [2:0] space // space left
);

localparam [1:0]
    SYNC_DATA = 2'b10,
    SYNC_CTRL = 2'b01;


    reg [2:0] rd_ptr,
              wr_ptr;

    reg [DWIDTH-1:0] dmemory [DEPTH-1:0];
    reg [CWIDTH-1:0] cmemory [DEPTH-1:0];


    initial begin
        empty = 1;
        full = 0;
        rd_ptr = 0;
        wr_ptr = 0;
        space = DEPTH;
        netfin=1;  
    end

    always@(posedge clk or negedge reset) begin

        if(reset) begin
            empty = 1;
            full = 0;
            rd_ptr = 0;
            wr_ptr = 0;
            space = DEPTH;
            netfin=1;
        end else begin
            if (wr_ptr>=rd_ptr) space = DEPTH - (wr_ptr-rd_ptr);
            else space = rd_ptr - wr_ptr;

            if(empty) netfin = 1;

            if(read & !empty) begin
                netfin=0;
                full=0;
                data_outd = dmemory[rd_ptr];
                data_outc = cmemory[rd_ptr];

                if(data_outd[7:0]>8'h86 && data_outc ==SYNC_CTRL) begin
                    netfin=1;
                end
                if(rd_ptr < wr_ptr)
                    rd_ptr = rd_ptr + 1;
                else if (rd_ptr == DEPTH-1) begin
                    rd_ptr=0;
                end
                if(rd_ptr==wr_ptr) empty=1;
            end
            else if (empty) begin
                data_outd = {DWIDTH{1'bZ}};
                data_outc = {CWIDTH{1'bZ}};
            end
        end

        // TODO: IF it is an IDLE frame, do not push in!
        if (write && !full && data_inc>=0 && data_ind>=0) begin
            dmemory[wr_ptr] = data_ind;
            cmemory[wr_ptr] = data_inc;
            empty = 0;    
            // $display("net input %h, %d",data_ind, wr_ptr);
            if(wr_ptr == DEPTH-1) begin
                full = 1;
                wr_ptr = 0;
            end
            else begin
                wr_ptr = wr_ptr + 1;
                full = 0;
            end
        end
    end
 
endmodule

