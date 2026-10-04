class axi_lite_driver extends uvm_driver #(axi_lite_transaction);

    `uvm_component_utils(axi_lite_driver)

    virtual axi_lite_if vif;

    function new(
        string name = "axi_lite_driver",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction


    //============================================================
    // BUILD
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
                "AXIL_DRV",
                "AXI-Lite virtual interface not found"
            )

        end

    endfunction


    //============================================================
    // RUN
    //============================================================

    task run_phase(uvm_phase phase);

        // Initialize outputs

        vif.awaddr  = '0;
        vif.awvalid = 1'b0;

        vif.wdata   = '0;
        vif.wstrb   = 4'b0000;
        vif.wvalid  = 1'b0;

        vif.bready  = 1'b0;

        vif.araddr  = '0;
        vif.arvalid = 1'b0;

        vif.rready  = 1'b0;


        // Wait until reset is released

        wait (vif.rst_n === 1'b1);

        @(posedge vif.clk);


        forever begin

            seq_item_port.get_next_item(req);

            `uvm_info(
                "AXIL_DRV",
                $sformatf(
                    "Driving AXI-Lite transaction: %s",
                    req.convert2string()
                ),
                UVM_MEDIUM
            )


            case (req.cmd)

                axi_lite_transaction::AXI_LITE_WRITE:
                    drive_write(req);

                axi_lite_transaction::AXI_LITE_READ:
                    drive_read(req);

                default:
                    `uvm_error(
                        "AXIL_DRV",
                        "Unknown AXI-Lite command"
                    )

            endcase


            seq_item_port.item_done();

        end

    endtask


    //============================================================
    // WRITE
    //============================================================

    task drive_write(axi_lite_transaction tr);

        bit aw_done;
        bit w_done;

        aw_done = 1'b0;
        w_done  = 1'b0;


        //========================================================
        // Drive transaction
        //========================================================

        @(negedge vif.clk);

        vif.awaddr  = tr.addr;
        vif.awvalid = 1'b1;

        vif.wdata   = tr.data;
        vif.wstrb   = tr.strb;
        vif.wvalid  = 1'b1;

        `uvm_info(
            "AXIL_DRV",
            $sformatf(
                "AW/W VALID asserted: ADDR=0x%08h DATA=0x%08h",
                tr.addr,
                tr.data
            ),
            UVM_HIGH
        )


        //========================================================
        // AW/W handshake
        //========================================================

        while (!aw_done || !w_done) begin

            @(posedge vif.clk);

            if (vif.awvalid && vif.awready) begin
                aw_done = 1'b1;
                vif.awvalid = 1'b0;

                `uvm_info(
                    "AXIL_DRV",
                    "AW handshake completed",
                    UVM_HIGH
                )
            end

            if (vif.wvalid && vif.wready) begin
                w_done = 1'b1;
                vif.wvalid = 1'b0;

                `uvm_info(
                    "AXIL_DRV",
                    "W handshake completed",
                    UVM_HIGH
                )
            end

        end


        //========================================================
        // Write response
        //========================================================

        @(negedge vif.clk);

        vif.bready = 1'b1;

        `uvm_info(
            "AXIL_DRV",
            "Waiting for BVALID",
            UVM_HIGH
        )


        while (!vif.bvalid) begin
            @(posedge vif.clk);
        end


        tr.resp = vif.bresp;


        `uvm_info(
            "AXIL_DRV",
            $sformatf(
                "WRITE response received: RESP=%0d",
                tr.resp
            ),
            UVM_HIGH
        )


        // Allow response handshake

        @(posedge vif.clk);


        @(negedge vif.clk);

        vif.bready = 1'b0;

    endtask


    //============================================================
    // READ
    //============================================================

    task drive_read(axi_lite_transaction tr);

        @(negedge vif.clk);

        vif.araddr  = tr.addr;
        vif.arvalid = 1'b1;

        while (!vif.arready) begin
            @(posedge vif.clk);
        end

        @(posedge vif.clk);

        vif.arvalid = 1'b0;


        vif.rready = 1'b1;

        while (!vif.rvalid) begin
            @(posedge vif.clk);
        end


        tr.read_data = vif.rdata;
        tr.resp      = vif.rresp;


        @(posedge vif.clk);

        vif.rready = 1'b0;

    endtask

endclass