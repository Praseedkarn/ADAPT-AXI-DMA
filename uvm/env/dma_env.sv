class dma_env extends uvm_env;

    `uvm_component_utils(dma_env)

    //============================================================
    // Agents
    //============================================================

    axi_lite_agent   axi_lite_ag;
    axi_master_agent axi_master_ag;

    //============================================================
    // Scoreboard
    //============================================================

    dma_scoreboard scoreboard;

        //============================================================
        // Functional Coverage
        //============================================================

        dma_coverage coverage;
    //============================================================
    // Constructor
    //============================================================

    function new(string name = "dma_env",
                 uvm_component parent = null);

        super.new(name, parent);

    endfunction


    //============================================================
    // Build phase
    //============================================================

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        // AXI-Lite agent
        axi_lite_ag = axi_lite_agent::type_id::create(
            "axi_lite_ag",
            this
        );

        // AXI4 memory/slave agent
        axi_master_ag = axi_master_agent::type_id::create(
            "axi_master_ag",
            this
        );

        // Scoreboard
        scoreboard = dma_scoreboard::type_id::create(
            "scoreboard",
            this
        );

        // Functional coverage
        coverage = dma_coverage::type_id::create(
            "coverage",
            this
        );

        // Both agents are active
        axi_lite_ag.is_active   = UVM_ACTIVE;
        axi_master_ag.is_active = UVM_ACTIVE;

    endfunction


    //============================================================
    // Connect phase
    //============================================================

function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    //============================================================
    // AXI-Lite monitor -> scoreboard
    //============================================================

    axi_lite_ag.monitor.ap.connect(
        scoreboard.axil_imp
    );


    //============================================================
    // AXI-Lite monitor -> coverage
    //============================================================

    axi_lite_ag.monitor.ap.connect(
        coverage.axil_imp
    );


    //============================================================
    // AXI4 monitor -> scoreboard
    //============================================================

    axi_master_ag.monitor.ap.connect(
        scoreboard.axi4_imp
    );


    //============================================================
    // AXI4 monitor -> coverage
    //============================================================

    axi_master_ag.monitor.ap.connect(
        coverage.axi_imp
    );

endfunction

    //============================================================
    // End of elaboration
    //============================================================

    function void end_of_elaboration_phase(uvm_phase phase);

        super.end_of_elaboration_phase(phase);

        `uvm_info(
            "DMA_ENV",
            "DMA UVM environment constructed successfully",
            UVM_LOW
        )

    endfunction

endclass