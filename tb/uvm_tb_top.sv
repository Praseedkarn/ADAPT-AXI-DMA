`timescale 1ns/1ps

import uvm_pkg::*;
import dma_uvm_pkg::*;

module uvm_tb_top;

    //============================================================
    // Clock and Reset
    //============================================================

    logic clk;
    logic rst_n;


    //============================================================
    // AXI-Lite interface
    //
    // DMA = AXI-Lite slave
    // UVM AXI-Lite agent = AXI-Lite master
    //============================================================

    axi_lite_if axi_lite_vif (
        .clk   (clk),
        .rst_n (rst_n)
    );


    //============================================================
    // AXI4 interface
    //
    // DMA = AXI4 master
    // UVM AXI4 agent = AXI4 slave / memory
    //============================================================

    axi4_if axi4_vif (
        .clk   (clk),
        .rst_n (rst_n)
    );


    //============================================================
    // Clock generation
    //============================================================

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end


    //============================================================
    // Reset generation
    //============================================================

    initial begin

        rst_n = 1'b0;

        repeat (5)
            @(posedge clk);

        rst_n = 1'b1;

    end


    //============================================================
    // DMA DUT
    //============================================================

    axi4_dma_top dut (

        .clk   (clk),
        .rst_n (rst_n),

        //========================================================
        // AXI4-Lite
        //========================================================

        .s_axi_awaddr  (axi_lite_vif.awaddr),
        .s_axi_awvalid (axi_lite_vif.awvalid),
        .s_axi_awready (axi_lite_vif.awready),

        .s_axi_wdata   (axi_lite_vif.wdata),
        .s_axi_wstrb   (axi_lite_vif.wstrb),
        .s_axi_wvalid  (axi_lite_vif.wvalid),
        .s_axi_wready  (axi_lite_vif.wready),

        .s_axi_bresp   (axi_lite_vif.bresp),
        .s_axi_bvalid  (axi_lite_vif.bvalid),
        .s_axi_bready  (axi_lite_vif.bready),

        .s_axi_araddr  (axi_lite_vif.araddr),
        .s_axi_arvalid (axi_lite_vif.arvalid),
        .s_axi_arready (axi_lite_vif.arready),

        .s_axi_rdata   (axi_lite_vif.rdata),
        .s_axi_rresp   (axi_lite_vif.rresp),
        .s_axi_rvalid  (axi_lite_vif.rvalid),
        .s_axi_rready  (axi_lite_vif.rready),


        //========================================================
        // AXI4 READ MASTER
        //========================================================

        .m_axi_araddr  (axi4_vif.araddr),
        .m_axi_arlen   (axi4_vif.arlen),
        .m_axi_arsize  (axi4_vif.arsize),
        .m_axi_arburst (axi4_vif.arburst),
        .m_axi_arvalid (axi4_vif.arvalid),
        .m_axi_arready (axi4_vif.arready),

        .m_axi_rdata   (axi4_vif.rdata),
        .m_axi_rresp   (axi4_vif.rresp),
        .m_axi_rlast   (axi4_vif.rlast),
        .m_axi_rvalid  (axi4_vif.rvalid),
        .m_axi_rready  (axi4_vif.rready),


        //========================================================
        // AXI4 WRITE MASTER
        //========================================================

        .m_axi_awaddr  (axi4_vif.awaddr),
        .m_axi_awlen   (axi4_vif.awlen),
        .m_axi_awsize  (axi4_vif.awsize),
        .m_axi_awburst (axi4_vif.awburst),
        .m_axi_awvalid (axi4_vif.awvalid),
        .m_axi_awready (axi4_vif.awready),

        .m_axi_wdata   (axi4_vif.wdata),
        .m_axi_wstrb   (axi4_vif.wstrb),
        .m_axi_wlast   (axi4_vif.wlast),
        .m_axi_wvalid  (axi4_vif.wvalid),
        .m_axi_wready  (axi4_vif.wready),

        .m_axi_bresp   (axi4_vif.bresp),
        .m_axi_bvalid  (axi4_vif.bvalid),
        .m_axi_bready  (axi4_vif.bready)

    );


    //============================================================
    // UVM Virtual Interface Configuration
    //============================================================

    initial begin

        // AXI-Lite agent
    uvm_config_db#(virtual axi_lite_if)::set(
    null,
    "uvm_test_top.env.axi_lite_ag.*",
    "vif",
    axi_lite_vif
);


        // AXI4 memory/slave agent
        uvm_config_db#(virtual axi4_if.slave)::set(
            null,
            "uvm_test_top.env.axi_master_ag.*",
            "vif",
            axi4_vif
        );


        // Start UVM
        run_test("dma_basic_test");

    end






endmodule

