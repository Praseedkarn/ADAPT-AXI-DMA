class dma_basic_test extends uvm_test;

    `uvm_component_utils(dma_basic_test)

    //============================================================
    // Environment
    //============================================================

    dma_env env;


    //============================================================
    // Constructor
    //============================================================

    function new(string name = "dma_basic_test",
                 uvm_component parent = null);

        super.new(name, parent);

    endfunction


    //============================================================
    // Build phase
    //============================================================

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        env = dma_env::type_id::create(
            "env",
            this
        );

    endfunction


    //============================================================
    // Run phase
    //============================================================

    task run_phase(uvm_phase phase);

        dma_sequence seq;

        int unsigned rand_src;
        int unsigned rand_dst;
        int unsigned rand_len;

 phase.raise_objection(this);

#1000;


        `uvm_info(
            "DMA_TEST",
            "Starting pseudo-randomized DMA UVM test",
            UVM_LOW
        )


        //========================================================
        // Create sequence
        //========================================================

        seq = dma_sequence::type_id::create("seq");


        //========================================================
        // Generate pseudo-random DMA configuration
        //
        // No seq.randomize() is used.
        // This avoids the Questa svverification license
        // requirement.
        //========================================================

        rand_src = $urandom;
        rand_dst = $urandom;


        // Keep addresses aligned and inside the AXI memory
        // space used by the testbench.
        //
        // Generate offsets in a safe range and force 4-byte
        // alignment.

        seq.src_addr =
            32'h0000_1000 +
            ((rand_src % 1024) & 32'hFFFF_FFFC);

        seq.dst_addr =
            32'h0000_2000 +
            ((rand_dst % 1024) & 32'hFFFF_FFFC);


        //========================================================
        // Generate legal transfer length
        //
        // 4, 8, 12, ... 64 bytes
        //========================================================

        rand_len = $urandom_range(1, 16);

        seq.transfer_length = rand_len * 4;


        //========================================================
        // Display configuration
        //========================================================

        `uvm_info(
            "DMA_TEST",
            $sformatf(
                "Pseudo-Random DMA: SRC=0x%08h DST=0x%08h LEN=%0d bytes",
                seq.src_addr,
                seq.dst_addr,
                seq.transfer_length
            ),
            UVM_MEDIUM
        )


        //========================================================
        // Start DMA sequence
        //========================================================

        seq.start(
            env.axi_lite_ag.sequencer
        );


        //========================================================
        // Sequence completed
        //========================================================

        `uvm_info(
            "DMA_TEST",
            "Pseudo-random DMA sequence completed",
            UVM_LOW
        )


        //========================================================
        // Give DMA enough time to complete
        //========================================================

        #5us;

        `uvm_info(
            "DMA_TEST",
            "5us wait completed - dropping objection",
            UVM_LOW
        )
        //========================================================
        // End test
        //========================================================

        phase.drop_objection(this);

    endtask

endclass