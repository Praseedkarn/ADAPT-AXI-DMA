module dma_registers #(
    parameter ADDR_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst_n,

    // Register write interface
    input  logic                  reg_write_en,
    input  logic [ADDR_WIDTH-1:0] reg_write_addr,
    input  logic [31:0]           reg_write_data,

    // Register read interface
    input  logic                  reg_read_en,
    input  logic [ADDR_WIDTH-1:0] reg_read_addr,
    output logic [31:0]           reg_read_data,

    // DMA status
    input  logic                  dma_busy,
    input  logic                  dma_done,

    // Configuration outputs
    output logic [ADDR_WIDTH-1:0] source_addr,
    output logic [ADDR_WIDTH-1:0] dest_addr,
    output logic [31:0]           transfer_length,
    output logic                  dma_start
);

    // Register addresses
    localparam CONTROL_ADDR = 32'h00000000;
    localparam STATUS_ADDR  = 32'h00000004;
    localparam SOURCE_ADDR  = 32'h00000008;
    localparam DEST_ADDR    = 32'h0000000C;
    localparam LENGTH_ADDR  = 32'h00000010;

    // Write registers
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            source_addr     <= '0;
            dest_addr       <= '0;
            transfer_length <= '0;
            dma_start       <= 1'b0;
        end
        else begin
            dma_start <= 1'b0;

            if (reg_write_en) begin
                case (reg_write_addr)

                    CONTROL_ADDR: begin
                        dma_start <= reg_write_data[0];
                    end

                    SOURCE_ADDR: begin
                        source_addr <= reg_write_data;
                    end

                    DEST_ADDR: begin
                        dest_addr <= reg_write_data;
                    end

                    LENGTH_ADDR: begin
                        transfer_length <= reg_write_data;
                    end

                    default: begin
                    end

                endcase
            end
        end
    end

    // Register read logic
    always_comb begin

        reg_read_data = 32'h00000000;

        if (reg_read_en) begin
            case (reg_read_addr)

                CONTROL_ADDR: begin
                    reg_read_data = {31'b0, dma_start};
                end

                STATUS_ADDR: begin
                    reg_read_data = {
                        30'b0,
                        dma_done,
                        dma_busy
                    };
                end

                SOURCE_ADDR: begin
                    reg_read_data = source_addr;
                end

                DEST_ADDR: begin
                    reg_read_data = dest_addr;
                end

                LENGTH_ADDR: begin
                    reg_read_data = transfer_length;
                end

                default: begin
                    reg_read_data = 32'h00000000;
                end

            endcase
        end
    end

endmodule