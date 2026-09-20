module axi4_write_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input logic clk,
    input logic rst_n,

    input logic [ADDR_WIDTH-1:0] write_addr,
    input logic write_request,
    output logic write_done,

    input logic [DATA_WIDTH-1:0] write_data,
    input logic write_data_valid,
    output logic write_data_ready,

    output logic [ADDR_WIDTH-1:0] m_axi_awaddr,
    output logic [7:0] m_axi_awlen,
    output logic [2:0] m_axi_awsize,
    output logic [1:0] m_axi_awburst,
    output logic m_axi_awvalid,
    input logic m_axi_awready,

    output logic [DATA_WIDTH-1:0] m_axi_wdata,
    output logic [DATA_WIDTH/8-1:0] m_axi_wstrb,
    output logic m_axi_wlast,
    output logic m_axi_wvalid,
    input logic m_axi_wready,

    input logic [1:0] m_axi_bresp,
    input logic m_axi_bvalid,
    output logic m_axi_bready
);

    typedef enum logic [1:0] {
        IDLE,
        SEND_AW,
        SEND_W,
        WAIT_B
    } state_t;

    state_t state;
    state_t next_state;

    logic [DATA_WIDTH-1:0] write_data_reg;


    //============================================================
    // State Register
    //============================================================

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n)
            state <= IDLE;

        else
            state <= next_state;

    end


    //============================================================
    // Capture Write Data
    //============================================================

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            write_data_reg <= '0;

        end

        else begin

            if (state == SEND_AW &&
                m_axi_awready &&
                write_data_valid) begin

                write_data_reg <= write_data;

            end

        end

    end


    //============================================================
    // Next State Logic
    //============================================================

    always_comb begin

        next_state = state;

        case (state)

            IDLE: begin

                if (write_request)
                    next_state = SEND_AW;

            end


            SEND_AW: begin

                if (m_axi_awready &&
                    write_data_valid)

                    next_state = SEND_W;

            end


            SEND_W: begin

                if (m_axi_wvalid &&
                    m_axi_wready)

                    next_state = WAIT_B;

            end


            WAIT_B: begin

                if (m_axi_bvalid &&
                    m_axi_bready)

                    next_state = IDLE;

            end


            default: begin

                next_state = IDLE;

            end

        endcase

    end


    //============================================================
    // AXI Write Outputs
    //============================================================

    always_comb begin

        m_axi_awaddr  = write_addr;
        m_axi_awlen   = 8'd0;
        m_axi_awsize  = 3'd2;
        m_axi_awburst = 2'b01;

        m_axi_awvalid = 1'b0;

        m_axi_wdata   = write_data_reg;
        m_axi_wstrb   = {DATA_WIDTH/8{1'b1}};
        m_axi_wlast   = 1'b1;
        m_axi_wvalid  = 1'b0;

        m_axi_bready  = 1'b0;

        write_data_ready = 1'b0;

        // IMPORTANT:
        // write_done is directly tied to the B-channel
        // handshake.

        write_done = 1'b0;


        case (state)

            //====================================================
            // WRITE ADDRESS
            //====================================================

            SEND_AW: begin

                m_axi_awvalid = 1'b1;

            end


            //====================================================
            // WRITE DATA
            //====================================================

            SEND_W: begin

                m_axi_wvalid = 1'b1;

                // FIFO pop occurs on W handshake
                if (m_axi_wvalid &&
                    m_axi_wready)

                    write_data_ready = 1'b1;

            end


            //====================================================
            // WRITE RESPONSE
            //====================================================

            WAIT_B: begin

                m_axi_bready = 1'b1;

                if (m_axi_bvalid &&
                    m_axi_bready)

                    write_done = 1'b1;

            end


            default: begin

            end

        endcase

    end

endmodule