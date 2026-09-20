module axi4_lite_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  logic clk,
    input  logic rst_n,

    //============================================================
    // AXI4-Lite Write Address Channel
    //============================================================

    input  logic [ADDR_WIDTH-1:0] s_axi_awaddr,
    input logic                  s_axi_awvalid,
    output logic                 s_axi_awready,

    //============================================================
    // AXI4-Lite Write Data Channel
    //============================================================

    input  logic [DATA_WIDTH-1:0] s_axi_wdata,
    input logic [DATA_WIDTH/8-1:0] s_axi_wstrb,
    input logic                   s_axi_wvalid,
    output logic                  s_axi_wready,

    //============================================================
    // AXI4-Lite Write Response Channel
    //============================================================

    output logic [1:0] s_axi_bresp,
    output logic       s_axi_bvalid,
    input  logic       s_axi_bready,

    //============================================================
    // AXI4-Lite Read Address Channel
    //============================================================

    input  logic [ADDR_WIDTH-1:0] s_axi_araddr,
    input  logic                  s_axi_arvalid,
    output logic                  s_axi_arready,

    //============================================================
    // AXI4-Lite Read Data Channel
    //============================================================

    output logic [DATA_WIDTH-1:0] s_axi_rdata,
    output logic [1:0]             s_axi_rresp,
    output logic                   s_axi_rvalid,
    input  logic                   s_axi_rready,

    //============================================================
    // Internal Register Interface
    //============================================================

    output logic                   reg_write_en,
    output logic [ADDR_WIDTH-1:0] reg_write_addr,
    output logic [DATA_WIDTH-1:0] reg_write_data,

    output logic                   reg_read_en,
    output logic [ADDR_WIDTH-1:0] reg_read_addr,
    input  logic [DATA_WIDTH-1:0] reg_read_data
);

    //============================================================
    // Internal Write Registers
    //============================================================

    logic                  aw_received;
    logic                  w_received;

    logic [ADDR_WIDTH-1:0] awaddr_reg;
    logic [DATA_WIDTH-1:0] wdata_reg;
    logic [DATA_WIDTH/8-1:0] wstrb_reg;

    //============================================================
    // AXI READY Signals
    //============================================================

    always_comb begin

        s_axi_awready = !aw_received && !s_axi_bvalid;
        s_axi_wready  = !w_received  && !s_axi_bvalid;

        s_axi_arready = !s_axi_rvalid;

    end

    //============================================================
    // Capture Write Address and Write Data
    //============================================================

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            aw_received <= 1'b0;
            w_received  <= 1'b0;

            awaddr_reg  <= '0;
            wdata_reg   <= '0;
            wstrb_reg   <= '0;

        end
        else begin

            // Capture AW channel
            if (s_axi_awvalid && s_axi_awready) begin
                aw_received <= 1'b1;
                awaddr_reg  <= s_axi_awaddr;
            end

            // Capture W channel
            if (s_axi_wvalid && s_axi_wready) begin
                w_received <= 1'b1;
                wdata_reg  <= s_axi_wdata;
                wstrb_reg  <= s_axi_wstrb;
            end

            // Clear after response handshake
            if (s_axi_bvalid && s_axi_bready) begin
                aw_received <= 1'b0;
                w_received  <= 1'b0;
            end

        end

    end

    //============================================================
    // Register Write
    //============================================================

    always_comb begin

        reg_write_en   = 1'b0;
        reg_write_addr = awaddr_reg;
        reg_write_data = wdata_reg;

        if (aw_received && w_received && !s_axi_bvalid)
            reg_write_en = 1'b1;

    end

    //============================================================
    // Write Response
    //============================================================

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            s_axi_bvalid <= 1'b0;
            s_axi_bresp  <= 2'b00;

        end
        else begin

            // Both AW and W have arrived
            if (aw_received && w_received && !s_axi_bvalid) begin

                s_axi_bvalid <= 1'b1;
                s_axi_bresp  <= 2'b00;

            end

            // Master accepted response
            else if (s_axi_bvalid && s_axi_bready) begin

                s_axi_bvalid <= 1'b0;

            end

        end

    end

    //============================================================
    // Read Address
    //============================================================

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            reg_read_en   <= 1'b0;
            reg_read_addr <= '0;

        end
        else begin

            reg_read_en <= 1'b0;

            if (s_axi_arvalid && s_axi_arready) begin

                reg_read_en   <= 1'b1;
                reg_read_addr <= s_axi_araddr;

            end

        end

    end

    //============================================================
    // Read Response
    //============================================================

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            s_axi_rvalid <= 1'b0;
            s_axi_rdata  <= '0;
            s_axi_rresp  <= 2'b00;

        end
        else begin

            if (s_axi_arvalid && s_axi_arready) begin

                s_axi_rvalid <= 1'b1;
                s_axi_rresp  <= 2'b00;

                case (s_axi_araddr)

                    32'h00000000:
                        s_axi_rdata <= 32'h00000000;

                    32'h00000004:
                        s_axi_rdata <= reg_read_data;

                    32'h00000008:
                        s_axi_rdata <= reg_read_data;

                    32'h0000000C:
                        s_axi_rdata <= reg_read_data;

                    32'h00000010:
                        s_axi_rdata <= reg_read_data;

                    default:
                        s_axi_rdata <= 32'h00000000;

                endcase

            end
            else if (s_axi_rvalid && s_axi_rready) begin

                s_axi_rvalid <= 1'b0;

            end

        end

    end

    

endmodule