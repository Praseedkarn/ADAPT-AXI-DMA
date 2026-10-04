interface dma_dut_if (
    input logic clk,
    input logic rst_n
);

    //============================================================
    // DMA GLOBAL INTERFACE
    //============================================================

    // Clock and reset are intentionally kept here
    // for UVM synchronization and assertions.

    modport dut (
        input clk,
        input rst_n
    );

    modport tb (
        input clk,
        input rst_n
    );

endinterface