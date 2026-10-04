class axi_lite_monitor extends uvm_monitor;

    `uvm_component_utils(axi_lite_monitor)

    //============================================================
    // Virtual Interface
    //============================================================

    virtual axi_lite_if vif;

    //============================================================
    // Analysis Port
    //============================================================

    uvm_analysis_port #(axi_lite_transaction) ap;

    //============================================================
    // Constructor
    //============================================================

    function new(
        string name = "axi_lite_monitor",
        uvm_component parent = null
    );

        super.new(name, parent);

        ap = new("ap", this);

    endfunction

    //============================================================
    // Build Phase
    //============================================================

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db#(virtual axi_lite_if)::get(
                this,
                "",
                "vif",
                vif
            )) begin

            `uvm_fatal(
                "AXIL_MON",
                "AXI-Lite virtual interface not found"
            )

        end

    endfunction

    //============================================================
    // Run Phase
    //============================================================

    task run_phase(uvm_phase phase);

        forever begin

            //====================================================
            // Sample on NEGEDGE
            //
            // Driver/DUT operate around POSITIVE edge.
            // Sampling here avoids missing the handshake.
            //====================================================

            @(negedge vif.clk);

            //====================================================
            // WRITE TRANSACTION
            //====================================================

            if (vif.awvalid &&
                vif.awready &&
                vif.wvalid &&
                vif.wready) begin

                axi_lite_transaction tr;

                tr = axi_lite_transaction::type_id::create(
                    "tr"
                );

                tr.cmd  = axi_lite_transaction::AXI_LITE_WRITE;
                tr.addr = vif.awaddr;
                tr.data = vif.wdata;
                tr.strb = vif.wstrb;
                tr.resp = 2'b00;

                // Publish transaction
                ap.write(tr);

                `uvm_info(
                    "AXIL_MON",
                    $sformatf(
                        "Observed WRITE: ADDR=0x%08h DATA=0x%08h",
                        tr.addr,
                        tr.data
                    ),
                    UVM_MEDIUM
                )

            end

            //====================================================
            // READ TRANSACTION
            //====================================================

            if (vif.arvalid &&
                vif.arready) begin

                axi_lite_transaction tr;

                tr = axi_lite_transaction::type_id::create(
                    "tr"
                );

                tr.cmd  = axi_lite_transaction::AXI_LITE_READ;
                tr.addr = vif.araddr;

                //================================================
                // Wait for RVALID
                //================================================

                while (!vif.rvalid)
                    @(negedge vif.clk);

                tr.read_data = vif.rdata;
                tr.resp      = vif.rresp;

                // Publish transaction
                ap.write(tr);

                `uvm_info(
                    "AXIL_MON",
                    $sformatf(
                        "Observed READ: ADDR=0x%08h DATA=0x%08h",
                        tr.addr,
                        tr.read_data
                    ),
                    UVM_MEDIUM
                )

            end

        end

    endtask

endclass