package dma_uvm_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    //============================================================
    // Transactions
    //============================================================

    `include "sequences/dma_transaction.sv"
    `include "sequences/axi_lite_transaction.sv"
    `include "sequences/axi_transaction.sv"
    `include "sequences/dma_sequence.sv"

    //============================================================
    // AXI-Lite Agent
    //============================================================

    `include "agents/axi_lite_agent/axi_lite_sequencer.sv"
    `include "agents/axi_lite_agent/axi_lite_driver.sv"
    `include "agents/axi_lite_agent/axi_lite_monitor.sv"
    `include "agents/axi_lite_agent/axi_lite_agent.sv"


    //============================================================
    // AXI4 Agent
    //============================================================

    `include "agents/axi_master_agent/axi_master_sequencer.sv"
    `include "agents/axi_master_agent/axi_master_driver.sv"
    `include "agents/axi_master_agent/axi_master_monitor.sv"
    `include "agents/axi_master_agent/axi_master_agent.sv"


    //============================================================
    // Scoreboard
    //============================================================

    `include "scoreboard/dma_scoreboard.sv"

    //============================================================
    // Functional Coverage
    //============================================================

    `include "coverage/dma_coverage.sv"

    //============================================================
    // Environment
    //============================================================

    `include "env/dma_env.sv"


  `include "tests/dma_basic_test.sv"

  `include "tests/dma_error_test.sv"

endpackage