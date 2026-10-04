class dma_error_test extends dma_basic_test;

    `uvm_component_utils(dma_error_test)

    //============================================================
    // Constructor
    //============================================================

    function new(
        string name = "dma_error_test",
        uvm_component parent = null
    );

        super.new(name, parent);

    endfunction


    //============================================================
    // Run phase
    //============================================================

    task run_phase(uvm_phase phase);

        //========================================================
        // Enable AXI error injection
        //
        // Read response  = SLVERR
        // Write response = SLVERR
        //========================================================

        env.axi_master_ag.driver.inject_read_slverr  = 1'b1;
        env.axi_master_ag.driver.inject_write_slverr = 1'b1;
        env.scoreboard.expected_slverr = 1'b1;

        `uvm_info(
            "DMA_ERROR_TEST",
            "AXI SLVERR injection ENABLED for READ and WRITE",
            UVM_MEDIUM
        )

        // Run the normal DMA test sequence
        super.run_phase(phase);

    endtask

endclass
