module dma_controller #(
    parameter ADDR_WIDTH = 32
)(
    input  logic clk,
    input  logic rst_n,

    input  logic dma_start,
    input  logic [ADDR_WIDTH-1:0] source_addr,
    input  logic [ADDR_WIDTH-1:0] dest_addr,
    input  logic [31:0] transfer_length,

    input  logic read_done,
    input  logic write_done,

    output logic read_request,
    output logic write_request,

    output logic [ADDR_WIDTH-1:0] current_source_addr,
    output logic [ADDR_WIDTH-1:0] current_dest_addr,

    output logic dma_busy,
    output logic dma_done
);

    typedef enum logic [2:0] {
        IDLE,
        READ_REQ,
        WRITE_REQ,
        DONE
    } state_t;

    state_t state;

    logic [ADDR_WIDTH-1:0] source_reg;
    logic [ADDR_WIDTH-1:0] dest_reg;
    logic [31:0] remaining_bytes;


    //============================================================
    // DMA STATE MACHINE
    //============================================================

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            state <= IDLE;
        end
        else begin

            case (state)

                IDLE: begin
                    if (dma_start && (transfer_length != 0))
                        state <= READ_REQ;
                end

                READ_REQ: begin
                    if (read_done)
                        state <= WRITE_REQ;
                end

                WRITE_REQ: begin
                    if (write_done) begin

                        if (remaining_bytes > 32'd4)
                            state <= READ_REQ;
                        else
                            state <= DONE;

                    end
                end

                DONE: begin
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end

            endcase

        end

    end


    //============================================================
    // ADDRESS AND LENGTH REGISTERS
    //============================================================

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            source_reg      <= '0;
            dest_reg        <= '0;
            remaining_bytes <= '0;

        end
        else begin

            case (state)

                IDLE: begin

                    if (dma_start && (transfer_length != 0)) begin

                        source_reg      <= source_addr;
                        dest_reg        <= dest_addr;
                        remaining_bytes <= transfer_length;

                    end

                end

                WRITE_REQ: begin

                    if (write_done) begin

                        source_reg      <= source_reg + 32'd4;
                        dest_reg        <= dest_reg + 32'd4;

                        if (remaining_bytes > 32'd4)
                            remaining_bytes <= remaining_bytes - 32'd4;
                        else
                            remaining_bytes <= 32'd0;

                    end

                end

                default: begin
                end

            endcase

        end

    end


    //============================================================
    // OUTPUT CONTROL
    //============================================================

    always_comb begin

        read_request        = 1'b0;
        write_request       = 1'b0;

        dma_busy            = 1'b0;
        dma_done            = 1'b0;

        current_source_addr = source_reg;
        current_dest_addr   = dest_reg;


        case (state)

            READ_REQ: begin
                read_request = 1'b1;
                dma_busy     = 1'b1;
            end

            WRITE_REQ: begin
                write_request = 1'b1;
                dma_busy      = 1'b1;
            end

            DONE: begin
                dma_done = 1'b1;
            end

            default: begin
            end

        endcase

    end

endmodule