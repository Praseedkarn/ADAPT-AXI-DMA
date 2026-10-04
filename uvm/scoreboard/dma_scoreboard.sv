`uvm_analysis_imp_decl(_axil)

class dma_scoreboard extends uvm_scoreboard;
        //============================================================
        // Expected AXI Error Control
        //============================================================

        // 0 = normal test: non-OKAY responses are errors
        // 1 = error test: SLVERR is intentionally expected
        bit expected_slverr;
    `uvm_component_utils(dma_scoreboard)


    //============================================================
    // AXI4 analysis connection
    //============================================================

    uvm_analysis_imp #(axi4_transaction, dma_scoreboard) axi4_imp;


    //============================================================
    // AXI-Lite analysis connection
    //============================================================

    uvm_analysis_imp_axil #(axi_lite_transaction, dma_scoreboard) axil_imp;


    //============================================================
    // DMA configuration
    //============================================================

    bit [31:0] src_addr;
    bit [31:0] dst_addr;
    bit [31:0] transfer_length;


    //============================================================
    // Expected transfer tracking
    //============================================================

    int read_beats;
    int write_beats;

    int expected_beats;

    int error_count;


    //============================================================
    // Constructor
    //============================================================

    function new(
        string name = "dma_scoreboard",
        uvm_component parent = null
    );

        super.new(name, parent);

        // Create AXI4 analysis implementation
        axi4_imp = new("axi4_imp", this);

        // Create AXI-Lite analysis implementation
        axil_imp = new("axil_imp", this);


        //========================================================
        // Default values
        //========================================================

        src_addr        = 32'h0000_1000;
        dst_addr        = 32'h0000_2000;
        transfer_length = 32'd16;

        expected_beats = transfer_length / 4;

        read_beats  = 0;
        write_beats = 0;

        error_count = 0;
        expected_slverr = 1'b0;
    endfunction


    //============================================================
    // Build phase
    //============================================================

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        `uvm_info(
            "SCOREBOARD",
            "DMA scoreboard created",
            UVM_LOW
        )

    endfunction


    //============================================================
    // Receive AXI-Lite transactions
    //============================================================

    function void write_axil(axi_lite_transaction tr);


        //========================================================
        // Only process AXI-Lite WRITE transactions
        //========================================================

     if (tr.cmd != axi_lite_transaction::AXI_LITE_WRITE)
    return;


        //========================================================
        // SOURCE ADDRESS REGISTER
        //
        // Address = 0x08
        //========================================================

        if (tr.addr == 32'h0000_0008) begin

            src_addr = tr.data;

            `uvm_info(
                "SCOREBOARD",
                $sformatf(
                    "CONFIG: SRC_ADDR = 0x%08h",
                    src_addr
                ),
                UVM_MEDIUM
            )

        end


        //========================================================
        // DESTINATION ADDRESS REGISTER
        //
        // Address = 0x0C
        //========================================================

        else if (tr.addr == 32'h0000_000C) begin

            dst_addr = tr.data;

            `uvm_info(
                "SCOREBOARD",
                $sformatf(
                    "CONFIG: DST_ADDR = 0x%08h",
                    dst_addr
                ),
                UVM_MEDIUM
            )

        end


        //========================================================
        // TRANSFER LENGTH REGISTER
        //
        // Address = 0x10
        //========================================================

        else if (tr.addr == 32'h0000_0010) begin

            transfer_length = tr.data;

            expected_beats = transfer_length / 4;

            `uvm_info(
                "SCOREBOARD",
                $sformatf(
                    "CONFIG: LENGTH = %0d bytes (%0d beats)",
                    transfer_length,
                    expected_beats
                ),
                UVM_MEDIUM
            )

        end


        //========================================================
        // CONTROL / START REGISTER
        //
        // Address = 0x00
        // Bit 0 = START
        //========================================================

        else if (tr.addr == 32'h0000_0000) begin

            if (tr.data[0] == 1'b1) begin

                // Reset counters for new DMA transfer
                read_beats  = 0;
                write_beats = 0;
                error_count = 0;


                `uvm_info(
                    "SCOREBOARD",
                    "CONFIG: DMA START detected",
                    UVM_MEDIUM
                )

            end

        end

    endfunction


    //============================================================
    // Receive AXI4 transactions
    //============================================================

    function void write(axi4_transaction tr);

        bit [31:0] expected_data;
        bit [31:0] expected_addr;


        //========================================================
        // AXI4 READ
        //========================================================

        if (tr.cmd == axi4_transaction::AXI4_READ) begin

            read_beats++;


            //====================================================
            // Calculate expected READ address
            //====================================================

            expected_addr =
                src_addr + ((read_beats - 1) * 4);


            //====================================================
            // Calculate expected READ data
            //
            // AXI memory contains:
            //
            // mem[i] = 32'hA5000000 + i
            //
            // Address / 4 gives memory index.
            //====================================================

            expected_data =
                32'hA5000000 +
                (expected_addr >> 2);


            `uvm_info(
                "SCOREBOARD",
                $sformatf(
                    "READ CHECK: ADDR=0x%08h DATA=0x%08h",
                    tr.addr,
                    tr.read_data
                ),
                UVM_MEDIUM
            )


            //====================================================
            // READ ADDRESS CHECK
            //====================================================

            if (tr.addr != expected_addr) begin

                `uvm_error(
                    "SCOREBOARD",
                    $sformatf(
                        "READ ADDRESS ERROR: Expected=0x%08h Actual=0x%08h",
                        expected_addr,
                        tr.addr
                    )
                )

                error_count++;

            end


            //====================================================
            // READ DATA CHECK
            //====================================================

            if (tr.read_data != expected_data) begin

                `uvm_error(
                    "SCOREBOARD",
                    $sformatf(
                        "READ DATA ERROR: ADDR=0x%08h Expected=0x%08h Actual=0x%08h",
                        tr.addr,
                        expected_data,
                        tr.read_data
                    )
                )

                error_count++;

            end

            else begin

                `uvm_info(
                    "SCOREBOARD",
                    $sformatf(
                        "READ DATA PASS: ADDR=0x%08h DATA=0x%08h",
                        tr.addr,
                        tr.read_data
                    ),
                    UVM_LOW
                )

            end

        end


        //========================================================
        // AXI4 WRITE
        //========================================================

        else if (tr.cmd == axi4_transaction::AXI4_WRITE) begin

            write_beats++;


            //====================================================
            // Calculate expected WRITE address
            //====================================================

            expected_addr =
                dst_addr + ((write_beats - 1) * 4);


            //====================================================
            // Calculate expected WRITE data
            //
            // The data written to destination must be the
            // corresponding data originally read from source.
            //====================================================

            expected_data =
                32'hA5000000 +
                (
                    (src_addr + ((write_beats - 1) * 4))
                    >> 2
                );


            `uvm_info(
                "SCOREBOARD",
                $sformatf(
                    "WRITE CHECK: ADDR=0x%08h DATA=0x%08h",
                    tr.addr,
                    tr.data
                ),
                UVM_MEDIUM
            )


            //====================================================
            // WRITE ADDRESS CHECK
            //====================================================

            if (tr.addr != expected_addr) begin

                `uvm_error(
                    "SCOREBOARD",
                    $sformatf(
                        "WRITE ADDRESS ERROR: Expected=0x%08h Actual=0x%08h",
                        expected_addr,
                        tr.addr
                    )
                )

                error_count++;

            end


            //====================================================
            // WRITE DATA CHECK
            //====================================================

            if (tr.data != expected_data) begin

                `uvm_error(
                    "SCOREBOARD",
                    $sformatf(
                        "WRITE DATA ERROR: ADDR=0x%08h Expected=0x%08h Actual=0x%08h",
                        tr.addr,
                        expected_data,
                        tr.data
                    )
                )

                error_count++;

            end

            else begin

                `uvm_info(
                    "SCOREBOARD",
                    $sformatf(
                        "WRITE DATA PASS: ADDR=0x%08h DATA=0x%08h",
                        tr.addr,
                        tr.data
                    ),
                    UVM_LOW
                )

            end


            //====================================================
            // WRITE RESPONSE CHECK
            //
            // AXI OKAY = 2'b00
            //====================================================

            if (tr.resp != 2'b00) begin

                if (expected_slverr && tr.resp == 2'b10) begin

                    `uvm_info(
                        "SCOREBOARD",
                        $sformatf(
                            "EXPECTED SLVERR: WRITE RESPONSE RESP=%0d",
                            tr.resp
                        ),
                        UVM_MEDIUM
                    )

                end
                else begin

                    `uvm_error(
                        "SCOREBOARD",
                        $sformatf(
                            "WRITE RESPONSE ERROR: RESP=%0d",
                            tr.resp
                        )
                    )

                    error_count++;

                end

            end

        end

    endfunction


    //============================================================
    // Report phase
    //============================================================

    function void report_phase(uvm_phase phase);

        super.report_phase(phase);


        `uvm_info(
            "SCOREBOARD",
            "==========================================",
            UVM_LOW
        )


        //========================================================
        // Configuration summary
        //========================================================

        `uvm_info(
            "SCOREBOARD",
            $sformatf(
                "SOURCE ADDRESS      = 0x%08h",
                src_addr
            ),
            UVM_LOW
        )


        `uvm_info(
            "SCOREBOARD",
            $sformatf(
                "DESTINATION ADDRESS = 0x%08h",
                dst_addr
            ),
            UVM_LOW
        )


        `uvm_info(
            "SCOREBOARD",
            $sformatf(
                "TRANSFER LENGTH     = %0d bytes",
                transfer_length
            ),
            UVM_LOW
        )


        `uvm_info(
            "SCOREBOARD",
            $sformatf(
                "EXPECTED BEATS      = %0d",
                expected_beats
            ),
            UVM_LOW
        )


        //========================================================
        // Actual transfer summary
        //========================================================

        `uvm_info(
            "SCOREBOARD",
            $sformatf(
                "READ BEATS          = %0d",
                read_beats
            ),
            UVM_LOW
        )


        `uvm_info(
            "SCOREBOARD",
            $sformatf(
                "WRITE BEATS         = %0d",
                write_beats
            ),
            UVM_LOW
        )


        `uvm_info(
            "SCOREBOARD",
            $sformatf(
                "ERROR COUNT         = %0d",
                error_count
            ),
            UVM_LOW
        )


        //========================================================
        // Final result
        //========================================================

        if (
            error_count == 0 &&
            read_beats == expected_beats &&
            write_beats == expected_beats
        ) begin

            `uvm_info(
                "SCOREBOARD",
                "==========================================",
                UVM_LOW
            )

            `uvm_info(
                "SCOREBOARD",
                "DMA DATA INTEGRITY CHECK : PASS",
                UVM_NONE
            )

            `uvm_info(
                "SCOREBOARD",
                "==========================================",
                UVM_LOW
            )

        end

        else begin

            //====================================================
            // READ beat count check
            //====================================================

            if (read_beats != expected_beats) begin

                `uvm_error(
                    "SCOREBOARD",
                    $sformatf(
                        "READ BEAT COUNT ERROR: Expected=%0d Actual=%0d",
                        expected_beats,
                        read_beats
                    )
                )

            end


            //====================================================
            // WRITE beat count check
            //====================================================

            if (write_beats != expected_beats) begin

                `uvm_error(
                    "SCOREBOARD",
                    $sformatf(
                        "WRITE BEAT COUNT ERROR: Expected=%0d Actual=%0d",
                        expected_beats,
                        write_beats
                    )
                )

            end


            `uvm_error(
                "SCOREBOARD",
                "DMA DATA INTEGRITY CHECK : FAIL"
            )

        end

    endfunction

endclass
