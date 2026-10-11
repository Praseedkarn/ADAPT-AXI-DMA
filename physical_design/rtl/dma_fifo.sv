module dma_fifo #(
    parameter DATA_WIDTH = 32 ,
    parameter DEPTH = 4 
)(
    input logic clk , 
    input logic rst_n,

    input logic [DATA_WIDTH-1:0] wr_data,
    input logic wr_en,

    output logic [DATA_WIDTH-1:0] rd_data,
    input logic  rd_en,

    output logic full , 
    output logic empty ,
    output logic [$clog2(DEPTH+1)-1:0] count
);

    localparam PTR_WIDTH = $clog2(DEPTH);
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    logic [PTR_WIDTH-1:0] wr_ptr;
    logic [PTR_WIDTH-1:0] rd_ptr;

    always_ff @(posedge clk or negedge rst_n) begin 

        if(!rst_n) begin 
            wr_ptr<='0;
            rd_ptr <='0;
            count <= '0;
        end
        else begin 

            if(wr_en && !full) begin 
                mem[wr_ptr]<= wr_data;
                wr_ptr <= wr_ptr+1'b1;
            end

            if(rd_en && !empty ) begin 
                rd_ptr <=rd_ptr+1'b1;
            end

            case ({wr_en && !full, rd_en && !empty})

                2'b10:
                    count <= count + 1'b1;

                2'b01:
                    count <= count - 1'b1;

                default:
                    count <= count;

            endcase
        end

    end

    assign rd_data = mem[rd_ptr];

    assign empty = (count==0);
    assign full = (count == DEPTH);
endmodule 
