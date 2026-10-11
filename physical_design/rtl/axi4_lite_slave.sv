module axi4_lite_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  logic clk,
    input  logic rst_n,

    //============================================================
    // AXI-Lite Write Address Channel
    //============================================================

    input  logic [ADDR_WIDTH-1:0] s_axi_awaddr,
    input  logic                  s_axi_awvalid,
    output logic                  s_axi_awready,

    //============================================================
    // AXI-Lite Write Data Channel
    //============================================================

    input  logic [DATA_WIDTH-1:0]   s_axi_wdata,
    input  logic [DATA_WIDTH/8-1:0] s_axi_wstrb,
    input  logic                   s_axi_wvalid,
    output logic                   s_axi_wready,

    //============================================================
    // AXI-Lite Write Response Channel
    //============================================================

    output logic [1:0] s_axi_bresp,
    output logic       s_axi_bvalid,
    input  logic       s_axi_bready,

    //============================================================
    // AXI-Lite Read Address Channel
    //============================================================

    input  logic [ADDR_WIDTH-1:0] s_axi_araddr,
    input  logic                  s_axi_arvalid,
    output logic                  s_axi_arready,

    //============================================================
    // AXI-Lite Read Data Channel
    //============================================================

    output logic [DATA_WIDTH-1:0] s_axi_rdata,
    output logic [1:0]            s_axi_rresp,
    output logic                  s_axi_rvalid,
    input  logic                  s_axi_rready,

    //============================================================
    // Register Interface
    //============================================================

    output logic                  reg_write_en,
    output logic [ADDR_WIDTH-1:0] reg_write_addr,
    output logic [DATA_WIDTH-1:0] reg_write_data,

    output logic                  reg_read_en,
    output logic [ADDR_WIDTH-1:0] reg_read_addr,

    input logic [DATA_WIDTH-1:0]  reg_read_data
);


    //============================================================
    // Internal Write Registers
    //============================================================

    logic aw_received;
    logic w_received;

    logic [ADDR_WIDTH-1:0]   awaddr_reg;
    logic [DATA_WIDTH-1:0]   wdata_reg;
    logic [DATA_WIDTH/8-1:0] wstrb_reg;


    //============================================================
    // AXI-Lite READY Signals
    //============================================================

    always_comb begin

        // Accept AW only when previous write is not waiting
        // for a response.

        s_axi_awready = !aw_received && !s_axi_bvalid;

        // Accept W only when previous write is not waiting
        // for a response.

        s_axi_wready  = !w_received && !s_axi_bvalid;

        // Read address can be accepted when no read response
        // is currently outstanding.

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

            // ---------------------------------------------------
            // Capture AW channel
            // ---------------------------------------------------

            if (s_axi_awvalid && s_axi_awready) begin

                aw_received <= 1'b1;
                awaddr_reg  <= s_axi_awaddr;

            end


            // ---------------------------------------------------
            // Capture W channel
            // ---------------------------------------------------

            if (s_axi_wvalid && s_axi_wready) begin

                w_received <= 1'b1;
                wdata_reg  <= s_axi_wdata;
                wstrb_reg  <= s_axi_wstrb;

            end


            // ---------------------------------------------------
            // Clear captured write information after B handshake
            // ---------------------------------------------------

            if (s_axi_bvalid && s_axi_bready) begin

                aw_received <= 1'b0;
                w_received  <= 1'b0;

            end

        end

    end


    //============================================================
    // Register Write Interface
    //============================================================

    always_comb begin

        reg_write_en   = 1'b0;
        reg_write_addr = awaddr_reg;
        reg_write_data = wdata_reg;

        if (aw_received &&
            w_received &&
            !s_axi_bvalid) begin

            reg_write_en = 1'b1;

        end

    end


    //============================================================
    // AXI-Lite Write Response
    //============================================================

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            s_axi_bvalid <= 1'b0;
            s_axi_bresp  <= 2'b00;

        end
        else begin

            // ---------------------------------------------------
            // Both AW and W have been received.
            // Generate OKAY response.
            // ---------------------------------------------------

            if (aw_received &&
                w_received &&
                !s_axi_bvalid) begin

                s_axi_bvalid <= 1'b1;
                s_axi_bresp  <= 2'b00;

            end

            // ---------------------------------------------------
            // Complete B channel handshake.
            // ---------------------------------------------------

            else if (s_axi_bvalid &&
                     s_axi_bready) begin

                s_axi_bvalid <= 1'b0;

            end

        end

    end


    //============================================================
    // Register Read Interface
    //============================================================

    always_comb begin

        reg_read_en   = 1'b0;
        reg_read_addr = s_axi_araddr;

        if (s_axi_arvalid &&
            s_axi_arready) begin

            reg_read_en = 1'b1;

        end

    end


    //============================================================
    // AXI-Lite Read Response
    //============================================================

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            s_axi_rvalid <= 1'b0;
            s_axi_rdata  <= '0;
            s_axi_rresp  <= 2'b00;

        end
        else begin

            // ---------------------------------------------------
            // Accept read request
            // ---------------------------------------------------

            if (s_axi_arvalid &&
                s_axi_arready) begin

                s_axi_rvalid <= 1'b1;
                s_axi_rdata  <= reg_read_data;
                s_axi_rresp  <= 2'b00;

            end

            // ---------------------------------------------------
            // Complete read response
            // ---------------------------------------------------

            else if (s_axi_rvalid &&
                     s_axi_rready) begin

                s_axi_rvalid <= 1'b0;

            end

        end

    end

endmodule