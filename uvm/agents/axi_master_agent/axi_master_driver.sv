class axi_master_driver extends uvm_driver #(axi4_transaction);

    `uvm_component_utils(axi_master_driver)

    //============================================================
    // Virtual AXI4 interface
    //============================================================

    virtual axi4_if.slave vif;

    //============================================================
    // AXI Error Injection Control
    //============================================================

    // 0 = normal operation
    // 1 = inject SLVERR
    bit inject_read_slverr;
    bit inject_write_slverr;

    //============================================================
    // Memory
    //============================================================

    localparam int MEM_DEPTH = 16384;

    logic [31:0] mem [0:MEM_DEPTH-1];

    //============================================================
    // Constructor
    //============================================================

    function new(
        string name = "axi_master_driver",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    //============================================================
    // Build
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
                "AXI_DRV",
                "Could not get AXI4 virtual interface"
            )

        end

    endfunction

    //============================================================
    // Initialize memory
    //============================================================

    function void initialize_memory();

        int i;

        for (i = 0; i < MEM_DEPTH; i++) begin
            mem[i] = 32'hA5000000 + i;
        end

    endfunction

    //============================================================
    // Run phase
    //============================================================

    task run_phase(uvm_phase phase);

        // Initialize outputs
  
        vif.arready = 1'b0;

        vif.rdata  = 32'h0;
        vif.rresp  = 2'b00;
        vif.rlast  = 1'b0;
        vif.rvalid = 1'b0;

        vif.awready = 1'b0;

        vif.wready = 1'b0;

        vif.bresp  = 2'b00;
        vif.bvalid = 1'b0;

        initialize_memory();

        // Run read and write slaves independently

        fork

            handle_reads();

            handle_writes();

        join

    endtask

    //============================================================
    // AXI4 WRITE CHANNEL
    //============================================================

    task handle_writes();

        logic [31:0] write_addr;
        logic [7:0]  write_len;
        logic [7:0]  write_count;
        logic        aw_seen;

        aw_seen     = 1'b0;
        write_addr  = 32'h0;
        write_len   = 8'h0;
        write_count = 8'h0;

        forever begin

            @(posedge vif.clk);

            if (!vif.rst_n) begin

                vif.awready <= 1'b0;
                vif.wready  <= 1'b0;
                vif.bvalid  <= 1'b0;

                aw_seen     = 1'b0;
                write_count = 8'h0;

            end
            else begin

                //================================================
                // Accept AW channel
                //================================================

                if (!aw_seen && !vif.bvalid) begin

                    vif.awready <= 1'b1;

                    if (vif.awvalid) begin

                        write_addr  = vif.awaddr;
                        write_len   = vif.awlen;
                        write_count = 8'd0;

                        aw_seen = 1'b1;

                        vif.awready <= 1'b0;

                        `uvm_info(
                            "AXI_WRITE",
                            $sformatf(
                                "AW accepted: ADDR=0x%08h LEN=%0d",
                                vif.awaddr,
                                vif.awlen + 1
                            ),
                            UVM_MEDIUM
                        )

                    end

                end
                else begin

                    vif.awready <= 1'b0;

                end

                //================================================
                // Accept W channel
                //================================================

                if (aw_seen && !vif.bvalid) begin

                    vif.wready <= 1'b1;

                    if (vif.wvalid) begin

                        //========================================
                        // Write data into memory
                        //========================================

                        if ((write_addr >> 2) < MEM_DEPTH) begin

                            if (vif.wstrb[0])
                                mem[write_addr >> 2][7:0]
                                    <= vif.wdata[7:0];

                            if (vif.wstrb[1])
                                mem[write_addr >> 2][15:8]
                                    <= vif.wdata[15:8];

                            if (vif.wstrb[2])
                                mem[write_addr >> 2][23:16]
                                    <= vif.wdata[23:16];

                            if (vif.wstrb[3])
                                mem[write_addr >> 2][31:24]
                                    <= vif.wdata[31:24];

                        end

                        `uvm_info(
                            "AXI_WRITE",
                            $sformatf(
                                "W accepted: ADDR=0x%08h DATA=0x%08h LAST=%0b",
                                write_addr,
                                vif.wdata,
                                vif.wlast
                            ),
                            UVM_MEDIUM
                        )

                        //========================================
                        // Last beat
                        //========================================

                        if (vif.wlast ||
                            (write_count == write_len)) begin

                            vif.wready <= 1'b0;

                            aw_seen = 1'b0;

                            write_count = 8'd0;

                           //========================================================
                            // Generate B response
                            //========================================================

                            if (inject_write_slverr)
                                vif.bresp <= 2'b10;       // SLVERR
                            else
                                vif.bresp <= 2'b00;       // OKAY

                            vif.bvalid <= 1'b1;

                            `uvm_info(
                                "AXI_WRITE",
                                "BVALID asserted",
                                UVM_MEDIUM
                            )

                        end
                        else begin

                            write_count = write_count + 1'b1;

                            write_addr = write_addr + 4;

                        end

                    end

                end
                else begin

                    vif.wready <= 1'b0;

                end

                //================================================
                // B response
                //================================================

                if (vif.bvalid && vif.bready) begin

                    vif.bvalid <= 1'b0;

                    `uvm_info(
                        "AXI_WRITE",
                        "B response accepted",
                        UVM_MEDIUM
                    )

                end

            end

        end

    endtask

    //============================================================
    // AXI4 READ CHANNEL
    //============================================================

    task handle_reads();

        logic [31:0] read_addr;
        logic [7:0]  read_len;
        logic [7:0]  read_count;

        forever begin

            @(posedge vif.clk);

            if (!vif.rst_n) begin

                vif.arready <= 1'b0;

                vif.rvalid <= 1'b0;
                vif.rlast  <= 1'b0;
                vif.rdata  <= 32'h0;
                vif.rresp  <= 2'b00;

            end
            else begin

                //================================================
                // Accept AR
                //================================================

                if (!vif.rvalid) begin

                    vif.arready <= 1'b1;

                    if (vif.arvalid) begin

                        read_addr  = vif.araddr;
                        read_len   = vif.arlen;
                        read_count = 8'd0;

                        vif.arready <= 1'b0;

                        `uvm_info(
                            "AXI_READ",
                            $sformatf(
                                "AR accepted: ADDR=0x%08h LEN=%0d",
                                vif.araddr,
                                vif.arlen + 1
                            ),
                            UVM_MEDIUM
                        )

                        //========================================
                        // First RDATA
                        //========================================

                        if ((read_addr >> 2) < MEM_DEPTH)
                            vif.rdata <= mem[read_addr >> 2];
                        else
                            vif.rdata <= 32'h00000000;

                        //========================================================
                        // Generate R response
                        //========================================================

                        if (inject_read_slverr)
                            vif.rresp <= 2'b10;        // SLVERR
                        else
                            vif.rresp <= 2'b00;        // OKAY

                        vif.rlast  <= (read_len == 0);
                        vif.rvalid <= 1'b1;

                    end

                end

                //================================================
                // R handshake
                //================================================

                if (vif.rvalid && vif.rready) begin

                    `uvm_info(
                        "AXI_READ",
                        $sformatf(
                            "R accepted: DATA=0x%08h LAST=%0b",
                            vif.rdata,
                            vif.rlast
                        ),
                        UVM_MEDIUM
                    )

                    if (vif.rlast) begin

                        vif.rvalid <= 1'b0;
                        vif.rlast  <= 1'b0;

                    end
                    else begin

                        read_count = read_count + 1'b1;
                        read_addr  = read_addr + 4;

                        if ((read_addr >> 2) < MEM_DEPTH)
                            vif.rdata <= mem[read_addr >> 2];
                        else
                            vif.rdata <= 32'h00000000;

                        vif.rlast <=
                            (read_count == read_len - 1);

                    end

                end

            end

        end

    endtask

endclass