module axi4_read_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  logic clk,
    input  logic rst_n,

    input  logic [ADDR_WIDTH-1:0] read_addr,
    input  logic read_request,

    output logic read_done,
    output logic [DATA_WIDTH-1:0] read_data,
    output logic read_valid,

    output logic [ADDR_WIDTH-1:0] m_axi_araddr,
    output logic [7:0] m_axi_arlen,
    output logic [2:0] m_axi_arsize,
    output logic [1:0] m_axi_arburst,
    output logic m_axi_arvalid,
    input  logic m_axi_arready,

    input  logic [DATA_WIDTH-1:0] m_axi_rdata,
    input logic [1:0] m_axi_rresp,
    input logic m_axi_rlast,
    input logic m_axi_rvalid,
    output logic m_axi_rready
);

    typedef enum logic [1:0] {
        IDLE,
        SEND_AR,
        WAIT_R
    } state_t;

    state_t state;


    //============================================================
    // State Machine
    //============================================================

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            state <= IDLE;
        end

        else begin

            case (state)

                IDLE: begin

                    if (read_request)
                        state <= SEND_AR;

                end


                SEND_AR: begin

                    if (m_axi_arvalid && m_axi_arready)
                        state <= WAIT_R;

                end


                WAIT_R: begin

                    if (m_axi_rvalid &&
                        m_axi_rready &&
                        m_axi_rlast)

                        state <= IDLE;

                end


                default: begin
                    state <= IDLE;
                end

            endcase

        end

    end


    //============================================================
    // AXI Read Channel
    //============================================================

    always_comb begin

        m_axi_araddr  = read_addr;
        m_axi_arlen   = 8'd0;
        m_axi_arsize  = 3'd2;
        m_axi_arburst = 2'b01;

        m_axi_arvalid = 1'b0;
        m_axi_rready  = 1'b0;

        // IMPORTANT:
        // read_done is generated directly from the AXI
        // R-channel handshake.

        read_done = 1'b0;


        case (state)

            SEND_AR: begin

                m_axi_arvalid = 1'b1;

            end


            WAIT_R: begin

                m_axi_rready = 1'b1;

                if (m_axi_rvalid &&
                    m_axi_rready &&
                    m_axi_rlast)

                    read_done = 1'b1;

            end


            default: begin

            end

        endcase

    end


    //============================================================
    // Read Data
    //============================================================

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            read_data  <= '0;
            read_valid <= 1'b0;

        end

        else begin

            // Default pulse behavior
            read_valid <= 1'b0;

            // AXI R handshake
            if (m_axi_rvalid && m_axi_rready) begin

                read_data  <= m_axi_rdata;
                read_valid <= 1'b1;

            end

        end

    end

endmodule