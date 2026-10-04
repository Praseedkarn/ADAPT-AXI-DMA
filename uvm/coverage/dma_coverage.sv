`ifndef DMA_COVERAGE_SV
`define DMA_COVERAGE_SV

//============================================================
// Analysis implementation declarations
//============================================================

`uvm_analysis_imp_decl(_axil_cov)
`uvm_analysis_imp_decl(_axi_cov)


//============================================================
// DMA Manual Functional Coverage
//
// NOTE:
// No SystemVerilog covergroup is used.
// This works with the current Questa Starter license.
//============================================================

class dma_coverage extends uvm_component;

    `uvm_component_utils(dma_coverage)


    //============================================================
    // Analysis connections
    //============================================================

    uvm_analysis_imp_axil_cov #(
        axi_lite_transaction,
        dma_coverage
    ) axil_imp;

    uvm_analysis_imp_axi_cov #(
        axi4_transaction,
        dma_coverage
    ) axi_imp;


    //============================================================
    // Transfer Length Coverage
    //============================================================

    bit hit_len_4;
    bit hit_len_8;
    bit hit_len_16;
    bit hit_len_32;
    bit hit_len_64;


    //============================================================
    // AXI-Lite Register Coverage
    //============================================================

    bit hit_reg_control;
    bit hit_reg_src;
    bit hit_reg_dst;
    bit hit_reg_length;


    //============================================================
    // AXI4 Command Coverage
    //============================================================

    bit hit_axi_read;
    bit hit_axi_write;


    //============================================================
    // AXI4 Burst Coverage
    //============================================================

    bit hit_burst_fixed;
    bit hit_burst_incr;
    bit hit_burst_wrap;


    //============================================================
    // AXI4 Size Coverage
    //============================================================

    bit hit_size_byte;
    bit hit_size_halfword;
    bit hit_size_word;


    //============================================================
    // AXI4 Response Coverage
    //============================================================

    bit hit_resp_okay;
    bit hit_resp_exokay;
    bit hit_resp_slverr;
    bit hit_resp_decerr;


    //============================================================
    // LAST Coverage
    //============================================================

    bit hit_last;
    bit hit_not_last;


    //============================================================
    // Transaction counters
    //============================================================

    int axil_transactions;
    int axi_read_transactions;
    int axi_write_transactions;


    //============================================================
    // Constructor
    //============================================================

    function new(
        string name = "dma_coverage",
        uvm_component parent = null
    );

        super.new(name, parent);

        axil_imp = new("axil_imp", this);
        axi_imp  = new("axi_imp", this);

        axil_transactions     = 0;
        axi_read_transactions = 0;
        axi_write_transactions = 0;

    endfunction


    //============================================================
    // AXI-Lite coverage
    //============================================================

    function void write_axil_cov(
        axi_lite_transaction tr
    );

        axil_transactions++;


        //========================================================
        // Register address coverage
        //========================================================

        case (tr.addr)

            32'h0000_0000:
                hit_reg_control = 1'b1;

            32'h0000_0008:
                hit_reg_src = 1'b1;

            32'h0000_000C:
                hit_reg_dst = 1'b1;

            32'h0000_0010:
                begin
                    hit_reg_length = 1'b1;

                    //============================================
                    // Transfer length coverage
                    //============================================

                    case (tr.data)

                        32'd4:
                            hit_len_4 = 1'b1;

                        32'd8:
                            hit_len_8 = 1'b1;

                        32'd16:
                            hit_len_16 = 1'b1;

                        32'd32:
                            hit_len_32 = 1'b1;

                        32'd64:
                            hit_len_64 = 1'b1;

                        default:
                            ;

                    endcase
                end

            default:
                ;

        endcase


        `uvm_info(
            "COVERAGE",
            $sformatf(
                "AXI-Lite coverage sample: ADDR=0x%08h DATA=0x%08h",
                tr.addr,
                tr.data
            ),
            UVM_HIGH
        )

    endfunction


    //============================================================
    // AXI4 coverage
    //============================================================

    function void write_axi_cov(
        axi4_transaction tr
    );

        //========================================================
        // Command coverage
        //========================================================

        if (tr.cmd == axi4_transaction::AXI4_READ) begin

            axi_read_transactions++;
            hit_axi_read = 1'b1;

        end
        else begin

            axi_write_transactions++;
            hit_axi_write = 1'b1;

        end


        //========================================================
        // Burst coverage
        //========================================================

        case (tr.burst)

            2'b00:
                hit_burst_fixed = 1'b1;

            2'b01:
                hit_burst_incr = 1'b1;

            2'b10:
                hit_burst_wrap = 1'b1;

            default:
                ;

        endcase


        //========================================================
        // Size coverage
        //========================================================

        case (tr.size)

            3'd0:
                hit_size_byte = 1'b1;

            3'd1:
                hit_size_halfword = 1'b1;

            3'd2:
                hit_size_word = 1'b1;

            default:
                ;

        endcase


        //========================================================
        // Response coverage
        //========================================================

        case (tr.resp)

            2'b00:
                hit_resp_okay = 1'b1;

            2'b01:
                hit_resp_exokay = 1'b1;

            2'b10:
                hit_resp_slverr = 1'b1;

            2'b11:
                hit_resp_decerr = 1'b1;

            default:
                ;

        endcase


        //========================================================
        // LAST coverage
        //========================================================

        if (tr.last)
            hit_last = 1'b1;
        else
            hit_not_last = 1'b1;


        `uvm_info(
            "COVERAGE",
            $sformatf(
                "AXI4 coverage sample: CMD=%0d ADDR=0x%08h LEN=%0d SIZE=%0d BURST=%0d RESP=%0d LAST=%0b",
                tr.cmd,
                tr.addr,
                tr.len,
                tr.size,
                tr.burst,
                tr.resp,
                tr.last
            ),
            UVM_HIGH
        )

    endfunction


    //============================================================
    // Calculate coverage percentage
    //============================================================

    function real calculate_coverage();

        int total_bins;
        int hit_bins;

        total_bins = 0;
        hit_bins   = 0;


        //========================================================
        // Transfer lengths
        //========================================================

        total_bins++;

        if (hit_len_4)
            hit_bins++;

        total_bins++;

        if (hit_len_8)
            hit_bins++;

        total_bins++;

        if (hit_len_16)
            hit_bins++;

        total_bins++;

        if (hit_len_32)
            hit_bins++;

        total_bins++;

        if (hit_len_64)
            hit_bins++;


        //========================================================
        // AXI-Lite registers
        //========================================================

        total_bins++;

        if (hit_reg_control)
            hit_bins++;

        total_bins++;

        if (hit_reg_src)
            hit_bins++;

        total_bins++;

        if (hit_reg_dst)
            hit_bins++;

        total_bins++;

        if (hit_reg_length)
            hit_bins++;


        //========================================================
        // AXI commands
        //========================================================

        total_bins++;

        if (hit_axi_read)
            hit_bins++;

        total_bins++;

        if (hit_axi_write)
            hit_bins++;


        //========================================================
        // Burst
        //========================================================

        total_bins++;

        if (hit_burst_fixed)
            hit_bins++;

        total_bins++;

        if (hit_burst_incr)
            hit_bins++;

        total_bins++;

        if (hit_burst_wrap)
            hit_bins++;


        //========================================================
        // Size
        //========================================================

        total_bins++;

        if (hit_size_byte)
            hit_bins++;

        total_bins++;

        if (hit_size_halfword)
            hit_bins++;

        total_bins++;

        if (hit_size_word)
            hit_bins++;


        //========================================================
        // Response
        //========================================================

        total_bins++;

        if (hit_resp_okay)
            hit_bins++;

        total_bins++;

        if (hit_resp_exokay)
            hit_bins++;

        total_bins++;

        if (hit_resp_slverr)
            hit_bins++;

        total_bins++;

        if (hit_resp_decerr)
            hit_bins++;


        //========================================================
        // LAST
        //========================================================

        total_bins++;

        if (hit_last)
            hit_bins++;

        total_bins++;

        if (hit_not_last)
            hit_bins++;


        return (100.0 * hit_bins) / total_bins;

    endfunction


    //============================================================
    // Report phase
    //============================================================

    function void report_phase(uvm_phase phase);

        real coverage_percent;

        super.report_phase(phase);

        coverage_percent = calculate_coverage();


        `uvm_info(
            "COVERAGE",
            "==============================================",
            UVM_NONE
        )

        `uvm_info(
            "COVERAGE",
            "       DMA FUNCTIONAL COVERAGE REPORT",
            UVM_NONE
        )

        `uvm_info(
            "COVERAGE",
            "==============================================",
            UVM_NONE
        )


        //========================================================
        // Transfer length
        //========================================================

        `uvm_info(
            "COVERAGE",
            $sformatf(
                "Length:  4=%0b  8=%0b  16=%0b  32=%0b  64=%0b",
                hit_len_4,
                hit_len_8,
                hit_len_16,
                hit_len_32,
                hit_len_64
            ),
            UVM_NONE
        )


        //========================================================
        // Registers
        //========================================================

        `uvm_info(
            "COVERAGE",
            $sformatf(
                "Registers: CTRL=%0b SRC=%0b DST=%0b LEN=%0b",
                hit_reg_control,
                hit_reg_src,
                hit_reg_dst,
                hit_reg_length
            ),
            UVM_NONE
        )


        //========================================================
        // AXI command
        //========================================================

        `uvm_info(
            "COVERAGE",
            $sformatf(
                "AXI Command: READ=%0b WRITE=%0b",
                hit_axi_read,
                hit_axi_write
            ),
            UVM_NONE
        )


        //========================================================
        // Burst
        //========================================================

        `uvm_info(
            "COVERAGE",
            $sformatf(
                "Burst: FIXED=%0b INCR=%0b WRAP=%0b",
                hit_burst_fixed,
                hit_burst_incr,
                hit_burst_wrap
            ),
            UVM_NONE
        )


        //========================================================
        // Size
        //========================================================

        `uvm_info(
            "COVERAGE",
            $sformatf(
                "Size: BYTE=%0b HALFWORD=%0b WORD=%0b",
                hit_size_byte,
                hit_size_halfword,
                hit_size_word
            ),
            UVM_NONE
        )


        //========================================================
        // Response
        //========================================================

        `uvm_info(
            "COVERAGE",
            $sformatf(
                "Response: OKAY=%0b EXOKAY=%0b SLVERR=%0b DECERR=%0b",
                hit_resp_okay,
                hit_resp_exokay,
                hit_resp_slverr,
                hit_resp_decerr
            ),
            UVM_NONE
        )


        //========================================================
        // LAST
        //========================================================

        `uvm_info(
            "COVERAGE",
            $sformatf(
                "LAST: NOT_LAST=%0b LAST=%0b",
                hit_not_last,
                hit_last
            ),
            UVM_NONE
        )


        //========================================================
        // Transaction counts
        //========================================================

        `uvm_info(
            "COVERAGE",
            $sformatf(
                "Transactions: AXIL=%0d READ=%0d WRITE=%0d",
                axil_transactions,
                axi_read_transactions,
                axi_write_transactions
            ),
            UVM_NONE
        )


        //========================================================
        // Overall
        //========================================================

        `uvm_info(
            "COVERAGE",
            $sformatf(
                "FUNCTIONAL COVERAGE = %0.2f%%",
                coverage_percent
            ),
            UVM_NONE
        )

        `uvm_info(
            "COVERAGE",
            "==============================================",
            UVM_NONE
        )

    endfunction

endclass

`endif