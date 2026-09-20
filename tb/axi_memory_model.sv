module axi_memory_model #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter MEM_DEPTH  = 16384
)(
    input  logic                     clk,
    input  logic                     rst_n,

    //============================================================
    // AXI Read Address Channel
    //============================================================

    input  logic [ADDR_WIDTH-1:0]     s_axi_araddr,
    input  logic [7:0]                s_axi_arlen,
    input  logic [2:0]                s_axi_arsize,
    input  logic [1:0]                s_axi_arburst,
    input  logic                     s_axi_arvalid,
    output logic                     s_axi_arready,

    //============================================================
    // AXI Read Data Channel
    //============================================================

    output logic [DATA_WIDTH-1:0]     s_axi_rdata,
    output logic [1:0]                s_axi_rresp,
    output logic                     s_axi_rlast,
    output logic                     s_axi_rvalid,
    input  logic                     s_axi_rready,

    //============================================================
    // AXI Write Address Channel
    //============================================================

    input  logic [ADDR_WIDTH-1:0]     s_axi_awaddr,
    input logic [7:0]                s_axi_awlen,
    input logic [2:0]                s_axi_awsize,
    input logic [1:0]                s_axi_awburst,
    input logic                     s_axi_awvalid,
    output logic                     s_axi_awready,
    input logic wready_enable,
    input logic awready_enable,
    input logic bvalid_enable,
input logic rvalid_enable,
input logic rresp_error_enable,
input logic bresp_error_enable,
    //============================================================
    // AXI Write Data Channel
    //============================================================

    input logic [DATA_WIDTH-1:0]     s_axi_wdata,
    input logic [DATA_WIDTH/8-1:0]   s_axi_wstrb,
    input logic                     s_axi_wlast,
    input logic                     s_axi_wvalid,
    output logic                     s_axi_wready,

    //============================================================
    // AXI Write Response Channel
    //============================================================

    output logic [1:0]               s_axi_bresp,
    output logic                     s_axi_bvalid,
    input logic                     s_axi_bready
);

    localparam BYTE_WIDTH = DATA_WIDTH / 8;

    //============================================================
    // Memory
    //============================================================

    logic [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

    //============================================================
    // Internal state
    //============================================================

    logic [ADDR_WIDTH-1:0] read_addr_reg;
    logic                  read_active;

    logic [ADDR_WIDTH-1:0] write_addr_reg;
    logic                  write_active;
logic                  bresp_pending;


    //============================================================
    // AXI READY signals
    //============================================================

    assign s_axi_arready = !read_active && !s_axi_rvalid;

   assign s_axi_awready = awready_enable &&
                       !write_active &&
                       !s_axi_bvalid;

    assign s_axi_wready = wready_enable &&
                      write_active &&
                      !s_axi_bvalid;

    //============================================================
    // Read channel
    //============================================================

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            read_addr_reg <= '0;
            read_active   <= 1'b0;

            s_axi_rdata   <= '0;
            s_axi_rresp   <= 2'b00;
            s_axi_rlast   <= 1'b0;
            s_axi_rvalid  <= 1'b0;

        end
        else begin

            //====================================================
            // Accept read address
            //====================================================

            if (s_axi_arvalid && s_axi_arready) begin

                read_addr_reg <= s_axi_araddr;
                read_active   <= 1'b1;

            end

            //====================================================
            // Generate read response
            //====================================================

if (read_active && !s_axi_rvalid && rvalid_enable) begin

    s_axi_rdata <= mem[read_addr_reg >> 2];

    if (rresp_error_enable)
        s_axi_rresp <= 2'b10;   // SLVERR
    else
        s_axi_rresp <= 2'b00;   // OKAY

    s_axi_rlast  <= 1'b1;
    s_axi_rvalid <= 1'b1;

end

            //====================================================
            // Read response accepted
            //====================================================

            if (s_axi_rvalid && s_axi_rready) begin

                s_axi_rvalid <= 1'b0;
                s_axi_rlast  <= 1'b0;
                read_active  <= 1'b0;

            end

        end

    end

    //============================================================
    // Write channel
    //============================================================

//============================================================
// Write channel
//============================================================

always_ff @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin

        write_addr_reg <= '0;
        write_active   <= 1'b0;

        bresp_pending  <= 1'b0;

        s_axi_bvalid   <= 1'b0;
        s_axi_bresp    <= 2'b00;

    end
    else begin

        //====================================================
        // Accept write address
        //====================================================

        if (s_axi_awvalid && s_axi_awready) begin

            write_addr_reg <= s_axi_awaddr;
            write_active   <= 1'b1;

        end

        //====================================================
        // Accept write data
        //====================================================

        if (s_axi_wvalid && s_axi_wready) begin

            for (int i = 0; i < BYTE_WIDTH; i++) begin

                if (s_axi_wstrb[i]) begin

                    mem[(write_addr_reg >> 2)][8*i +: 8]
                        <= s_axi_wdata[8*i +: 8];

                end

            end

            write_active  <= 1'b0;

            // Remember that a response is pending
            bresp_pending <= 1'b1;

        end

        //====================================================
        // Generate BVALID when enabled
        //====================================================
if (bresp_pending &&
    bvalid_enable &&
    !s_axi_bvalid) begin

    s_axi_bvalid <= 1'b1;

    if (bresp_error_enable)
        s_axi_bresp <= 2'b10;   // SLVERR
    else
        s_axi_bresp <= 2'b00;   // OKAY

    bresp_pending <= 1'b0;

end

        //====================================================
        // Complete write response
        //====================================================

        if (s_axi_bvalid && s_axi_bready) begin

            s_axi_bvalid <= 1'b0;

        end

    end

end
endmodule