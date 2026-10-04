class axi_master_monitor extends uvm_monitor;

    `uvm_component_utils(axi_master_monitor)

    //============================================================
    // Virtual AXI4 interface
    //============================================================

    virtual axi4_if.slave vif;

    //============================================================
    // Analysis port
    //============================================================

    uvm_analysis_port #(axi4_transaction) ap;


    //============================================================
    // Constructor
    //============================================================

    function new(
        string name = "axi_master_monitor",
        uvm_component parent = null
    );

        super.new(name, parent);

        ap = new("ap", this);

    endfunction


    //============================================================
    // Build phase
    //============================================================

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db#(virtual axi4_if.slave)::get(
                this,
                "",
                "vif",
                vif
            )) begin

            `uvm_fatal(
                "AXI_MON",
                "Could not get AXI4 virtual interface"
            )

        end

    endfunction


    //============================================================
    // Run phase
    //============================================================

    task run_phase(uvm_phase phase);

        fork
            monitor_reads();
            monitor_writes();
        join

    endtask


    //============================================================
    // Monitor AXI4 READ transactions
    //============================================================

    task monitor_reads();

        axi4_transaction tr;

        logic [31:0] current_addr;
        logic [7:0]  burst_len;
        logic [7:0]  beat_count;

        forever begin

            @(posedge vif.clk);

            if (!vif.rst_n)
                continue;


            //====================================================
            // Read address handshake
            //====================================================

            if (vif.arvalid && vif.arready) begin

                current_addr = vif.araddr;
                burst_len    = vif.arlen;
                beat_count   = 0;

                `uvm_info(
                    "AXI_MON",
                    $sformatf(
                        "READ ADDRESS: ADDR=0x%08h LEN=%0d",
                        vif.araddr,
                        vif.arlen + 1
                    ),
                    UVM_MEDIUM
                )


                //================================================
                // Monitor every read data beat
                //================================================

                forever begin

                    @(posedge vif.clk);

                    if (vif.rvalid && vif.rready) begin

                        tr = axi4_transaction::type_id::create(
                            "read_transaction",
                            this
                        );

                        tr.cmd       = axi4_transaction::AXI4_READ;
                        tr.addr      = current_addr;
                        tr.len       = burst_len;
                        tr.size      = vif.arsize;
                        tr.burst     = vif.arburst;

                        tr.read_data = vif.rdata;
                        tr.resp      = vif.rresp;
                        tr.last      = vif.rlast;

                        ap.write(tr);

                        `uvm_info(
                            "AXI_MON",
                            $sformatf(
                                "READ BEAT: ADDR=0x%08h DATA=0x%08h RESP=%0d LAST=%0b",
                                current_addr,
                                vif.rdata,
                                vif.rresp,
                                vif.rlast
                            ),
                            UVM_MEDIUM
                        )


                        //============================================
                        // Last beat
                        //============================================

                        if (vif.rlast)
                            break;


                        //============================================
                        // Next beat
                        //============================================

                        current_addr = current_addr + 4;
                        beat_count   = beat_count + 1;

                    end

                end

            end

        end

    endtask


    //============================================================
    // Monitor AXI4 WRITE transactions
    //============================================================

  //============================================================
// Monitor AXI4 WRITE transactions
//============================================================

task monitor_writes();

    axi4_transaction tr;
    axi4_transaction write_tr_queue[$];

    logic [31:0] current_addr;
    logic [7:0]  burst_len;
    logic [7:0]  beat_count;

    forever begin

        @(posedge vif.clk);

        if (!vif.rst_n)
            continue;


        //====================================================
        // Write address handshake
        //====================================================

        if (vif.awvalid && vif.awready) begin

            current_addr = vif.awaddr;
            burst_len    = vif.awlen;
            beat_count   = 0;

            // Clear transaction queue for this burst
            write_tr_queue.delete();

            `uvm_info(
                "AXI_MON",
                $sformatf(
                    "WRITE ADDRESS: ADDR=0x%08h LEN=%0d",
                    vif.awaddr,
                    vif.awlen + 1
                ),
                UVM_MEDIUM
            )


            //================================================
            // Monitor every write data beat
            //================================================

            forever begin

                @(posedge vif.clk);

                if (vif.wvalid && vif.wready) begin

                    tr = axi4_transaction::type_id::create(
                        "write_transaction",
                        this
                    );

                    tr.cmd   = axi4_transaction::AXI4_WRITE;
                    tr.addr  = current_addr;
                    tr.len   = burst_len;
                    tr.size  = vif.awsize;
                    tr.burst = vif.awburst;

                    tr.data  = vif.wdata;
                    tr.strb  = vif.wstrb;
                    tr.last  = vif.wlast;

                    // Response will be updated after B channel
                    tr.resp = 2'b00;

                    // Store transaction until B response arrives
                    write_tr_queue.push_back(tr);

                    `uvm_info(
                        "AXI_MON",
                        $sformatf(
                            "WRITE BEAT: ADDR=0x%08h DATA=0x%08h STRB=0x%0h LAST=%0b",
                            current_addr,
                            vif.wdata,
                            vif.wstrb,
                            vif.wlast
                        ),
                        UVM_MEDIUM
                    )


                    //============================================
                    // Last beat
                    //============================================

                    if (vif.wlast)
                        break;


                    //============================================
                    // Next beat
                    //============================================

                    current_addr = current_addr + 4;
                    beat_count   = beat_count + 1;

                end

            end


            //================================================
            // Wait for write response
            //================================================

            forever begin

                @(posedge vif.clk);

                if (vif.bvalid && vif.bready) begin

                    `uvm_info(
                        "AXI_MON",
                        $sformatf(
                            "WRITE RESPONSE: RESP=%0d",
                            vif.bresp
                        ),
                        UVM_MEDIUM
                    );

                    //================================================
                    // Attach B response to the LAST write transaction
                    //================================================

                    if (write_tr_queue.size() > 0) begin

                        write_tr_queue[write_tr_queue.size()-1].resp = vif.bresp;

                    end

                    break;

                end

            end


            //================================================
            // Publish write transactions AFTER B response
            //================================================

            foreach (write_tr_queue[i]) begin

                ap.write(write_tr_queue[i]);

            end

            // Clear queue
            write_tr_queue.delete();

        end

    end

endtask

endclass