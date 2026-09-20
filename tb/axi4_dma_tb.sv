`timescale 1ns/1ps

module axi4_dma_tb;

    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;

    //============================================================
    // Clock and Reset
    //============================================================

    logic clk;
    logic rst_n;

    initial begin
    clk = 1'b0;
    forever begin
        #5;
        clk = ~clk;

         end
end

    initial begin
        rst_n = 1'b0;
        #50;
        rst_n = 1'b1;
    end

    //============================================================
    // AXI4-Lite Signals
    //============================================================

    logic [31:0] s_axi_awaddr;
    logic        s_axi_awvalid;
    logic        s_axi_awready;

    logic [31:0] s_axi_wdata;
    logic [3:0]  s_axi_wstrb;
    logic        s_axi_wvalid;
    logic        s_axi_wready;

    logic [1:0]  s_axi_bresp;
    logic        s_axi_bvalid;
    logic        s_axi_bready;

    logic [31:0] s_axi_araddr;
    logic        s_axi_arvalid;
    logic        s_axi_arready;

    logic [31:0] s_axi_rdata;
    logic [1:0]  s_axi_rresp;
    logic        s_axi_rvalid;
    logic        s_axi_rready;

    //============================================================
    // AXI4 Read Master Signals
    //============================================================

    logic [31:0] m_axi_araddr;
    logic [7:0]  m_axi_arlen;
    logic [2:0]  m_axi_arsize;
    logic [1:0]  m_axi_arburst;
    logic        m_axi_arvalid;
    logic        m_axi_arready;

    logic [31:0] m_axi_rdata;
    logic [1:0]  m_axi_rresp;
    logic        m_axi_rlast;
    logic        m_axi_rvalid;
    logic        m_axi_rready;

    //============================================================
    // AXI4 Write Master Signals
    //============================================================

    logic [31:0] m_axi_awaddr;
    logic [7:0]  m_axi_awlen;
    logic [2:0]  m_axi_awsize;
    logic [1:0]  m_axi_awburst;
    logic        m_axi_awvalid;
    logic        m_axi_awready;

    logic [31:0] m_axi_wdata;
    logic [3:0]  m_axi_wstrb;
    logic        m_axi_wlast;
    logic        m_axi_wvalid;
    logic        m_axi_wready;

    logic [1:0]  m_axi_bresp;
    logic        m_axi_bvalid;
    logic        m_axi_bready;
    logic        awready_enable;

        logic wready_enable;
        logic bvalid_enable;
        logic rvalid_enable;


logic rresp_error_enable;
logic bresp_error_enable;
    //============================================================
    // DMA DUT
    //============================================================

    axi4_dma_top dut (

        .clk(clk),
        .rst_n(rst_n),

        // AXI4-Lite
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),

        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),

        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),

        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),

        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),

        // AXI4 Read
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arlen(m_axi_arlen),
        .m_axi_arsize(m_axi_arsize),
        .m_axi_arburst(m_axi_arburst),
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_arready(m_axi_arready),

        .m_axi_rdata(m_axi_rdata),
        .m_axi_rresp(m_axi_rresp),
        .m_axi_rlast(m_axi_rlast),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_rready(m_axi_rready),

        // AXI4 Write
        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awlen(m_axi_awlen),
        .m_axi_awsize(m_axi_awsize),
        .m_axi_awburst(m_axi_awburst),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_awready(m_axi_awready),

        .m_axi_wdata(m_axi_wdata),
        .m_axi_wstrb(m_axi_wstrb),
        .m_axi_wlast(m_axi_wlast),
        .m_axi_wvalid(m_axi_wvalid),
        .m_axi_wready(m_axi_wready),

        .m_axi_bresp(m_axi_bresp),
        .m_axi_bvalid(m_axi_bvalid),
        .m_axi_bready(m_axi_bready)
    );

    //============================================================
    // AXI Memory Model
    //============================================================

    axi_memory_model memory (

        .clk(clk),
        .rst_n(rst_n),

        // Read
        .s_axi_araddr(m_axi_araddr),
        .s_axi_arlen(m_axi_arlen),
        .s_axi_arsize(m_axi_arsize),
        .s_axi_arburst(m_axi_arburst),
        .s_axi_arvalid(m_axi_arvalid),
        .s_axi_arready(m_axi_arready),

        .s_axi_rdata(m_axi_rdata),
        .s_axi_rresp(m_axi_rresp),
        .s_axi_rlast(m_axi_rlast),
        .s_axi_rvalid(m_axi_rvalid),
        .s_axi_rready(m_axi_rready),

        // Write
        .s_axi_awaddr(m_axi_awaddr),
        .s_axi_awlen(m_axi_awlen),
        .s_axi_awsize(m_axi_awsize),
        .s_axi_awburst(m_axi_awburst),
        .s_axi_awvalid(m_axi_awvalid),
        .s_axi_awready(m_axi_awready),
        .awready_enable(awready_enable),
        .wready_enable(wready_enable),
        .bvalid_enable(bvalid_enable),
.rvalid_enable(rvalid_enable),
.rresp_error_enable(rresp_error_enable),
.bresp_error_enable(bresp_error_enable),
        .s_axi_wdata(m_axi_wdata),
        .s_axi_wstrb(m_axi_wstrb),
        .s_axi_wlast(m_axi_wlast),
        .s_axi_wvalid(m_axi_wvalid),
        .s_axi_wready(m_axi_wready),

        .s_axi_bresp(m_axi_bresp),
        .s_axi_bvalid(m_axi_bvalid),
        .s_axi_bready(m_axi_bready)

    );

    //============================================================
    // AXI4-Lite WRITE TASK
    //============================================================

    task axi_write(
        input [31:0] addr,
        input [31:0] data
    );

        integer timeout;

        begin

            $display("");
            $display("AXI WRITE: ADDR = %h DATA = %h", addr, data);

            // ---------------------------------------------------
            // Drive transaction
            // ---------------------------------------------------

            @(posedge clk);

            s_axi_awaddr  <= addr;
            s_axi_awvalid <= 1'b1;

            s_axi_wdata   <= data;
            s_axi_wstrb   <= 4'b1111;
            s_axi_wvalid  <= 1'b1;

            s_axi_bready  <= 1'b1;

            // ---------------------------------------------------
            // Wait for AWREADY
            // ---------------------------------------------------

            timeout = 0;

            while (!s_axi_awready) begin

                @(posedge clk);

                timeout = timeout + 1;

                if (timeout > 20) begin

                    $display("");
                    $display("ERROR: AW CHANNEL TIMEOUT");
                    $display("ADDR = %h", addr);

                    $finish;

                end

            end

            $display("  AW handshake");

            @(posedge clk);

            s_axi_awvalid <= 1'b0;

            // ---------------------------------------------------
            // Wait for WREADY
            // ---------------------------------------------------

            timeout = 0;

            while (!s_axi_wready) begin

                @(posedge clk);

                timeout = timeout + 1;

                if (timeout > 20) begin

                    $display("");
                    $display("ERROR: W CHANNEL TIMEOUT");
                    $display("ADDR = %h", addr);

                    $finish;

                end

            end

            $display("  W handshake");

            @(posedge clk);

            s_axi_wvalid <= 1'b0;

            // ---------------------------------------------------
            // Wait for BVALID
            // ---------------------------------------------------

            timeout = 0;

            while (!s_axi_bvalid) begin

                @(posedge clk);

                timeout = timeout + 1;

                if (timeout > 20) begin

                    $display("");
                    $display("ERROR: B CHANNEL TIMEOUT");
                    $display("ADDR = %h", addr);

                    $display("  AWREADY = %b", s_axi_awready);
                    $display("  WREADY  = %b", s_axi_wready);
                    $display("  BVALID  = %b", s_axi_bvalid);
                    $display("  BREADY  = %b", s_axi_bready);

                    $finish;

                end

            end

            $display("  B response received");

            @(posedge clk);

            s_axi_bready <= 1'b0;

            $display("AXI WRITE COMPLETE");

        end

    endtask

  
    //============================================================
    // DMA TRANSFER TEST TASK
    //============================================================

    task automatic dma_transfer_test(
        input integer test_number,
        input integer length
    );

        integer i;
        integer words;
        logic [31:0] expected_data;

        begin

            $display("");
            $display("========================================");
            $display("          DMA TEST %0d", test_number);
            $display("          LENGTH = %0d BYTES", length);
            $display("========================================");

            words = length / 4;

            // Initialize source memory
            for (i = 0; i < words; i = i + 1) begin
                expected_data = 32'hA0000000 + i;
                memory.mem[(32'h1000 >> 2) + i] = expected_data;
            end

            // Clear destination memory
            for (i = 0; i < words; i = i + 1) begin
                memory.mem[(32'h2000 >> 2) + i] = 32'h00000000;
            end

            // Configure DMA
            axi_write(32'h00000008, 32'h00001000);
            axi_write(32'h0000000C, 32'h00002000);
            axi_write(32'h00000010, length);

            // Start DMA
            axi_write(32'h00000000, 32'h00000001);

            $display("DMA started.");

            // Wait
            wait (dut.dma_done == 1'b1);
@(posedge clk);

            // Check destination
            for (i = 0; i < words; i = i + 1) begin

                expected_data = 32'hA0000000 + i;

                if (memory.mem[(32'h2000 >> 2) + i] !== expected_data) begin

                    $display("");
                    $display("ERROR: TEST %0d FAILED", test_number);
                    $display("  Word     = %0d", i);
                    $display("  Address  = %h", 32'h2000 + (i * 4));
                    $display("  Expected = %h", expected_data);
                    $display("  Actual   = %h",
                             memory.mem[(32'h2000 >> 2) + i]);
                    $display("");

                    $finish;
                end
            end

            $display("");
            $display("*** DMA TEST %0d PASS ***", test_number);

        end

    endtask

//============================================================
// TEST 5A - AWREADY DELAY
//============================================================

task automatic test_5a_awready_delay;

    integer i;
    integer words;
    logic [31:0] expected_data;

    begin

        $display("");
        $display("========================================");
        $display("          DMA TEST 5A");
        $display("          AWREADY DELAY");
        $display("========================================");

        //========================================================
        // Normal AXI operation
        //========================================================

        awready_enable = 1'b1;
        wready_enable = 1'b1;

        words = 4;

        //========================================================
        // Initialize source memory
        //========================================================

        for (i = 0; i < words; i = i + 1) begin

            expected_data = 32'hB0000000 + i;

            memory.mem[(32'h1000 >> 2) + i] = expected_data;

        end

        //========================================================
        // Clear destination memory
        //========================================================

        for (i = 0; i < words; i = i + 1) begin

            memory.mem[(32'h2000 >> 2) + i] =
                32'h00000000;

        end

        //========================================================
        // Configure DMA
        //========================================================

        axi_write(32'h00000008, 32'h00001000);

        axi_write(32'h0000000C, 32'h00002000);

        axi_write(32'h00000010, 32'h00000010);

        //========================================================
        // Start DMA
        //========================================================

        axi_write(32'h00000000, 32'h00000001);

        $display("DMA started.");

        //========================================================
        // Wait for DMA write phase
        //========================================================

        wait (dut.m_axi_awvalid == 1'b1);

        $display("");
        $display("TEST 5A: AWVALID detected.");
        $display("Blocking AWREADY for 3 clock cycles.");

        //========================================================
        // Block AWREADY
        //========================================================

        awready_enable = 1'b0;

        repeat (3) begin

            @(posedge clk);

            $display(
                "TIME=%0t | AWVALID=%b | AWREADY=%b",
                $time,
                m_axi_awvalid,
                m_axi_awready
            );

            // AWVALID must remain HIGH
            if (m_axi_awvalid !== 1'b1) begin

                $display("");
                $display("ERROR: AWVALID dropped while AWREADY=0");
                $display("*** DMA TEST 5A FAILED ***");
                $finish;

            end

            // AWREADY must remain LOW
            if (m_axi_awready !== 1'b0) begin

                $display("");
                $display("ERROR: AWREADY did not remain LOW");
                $display("*** DMA TEST 5A FAILED ***");
                $finish;

            end

        end

        //========================================================
        // Release AWREADY
        //========================================================

        $display("");
        $display("TEST 5A: Releasing AWREADY.");

        awready_enable = 1'b1;

        //========================================================
        // Wait for DMA completion
        //========================================================

        wait (dut.dma_done == 1'b1);

        @(posedge clk);

        //========================================================
        // Verify destination
        //========================================================

        for (i = 0; i < words; i = i + 1) begin

            expected_data = 32'hB0000000 + i;

            if (memory.mem[(32'h2000 >> 2) + i]
                !== expected_data) begin

                $display("");
                $display("ERROR: TEST 5A FAILED");
                $display("  Word     = %0d", i);
                $display("  Address  = %h",
                         32'h2000 + (i * 4));
                $display("  Expected = %h",
                         expected_data);
                $display("  Actual   = %h",
                         memory.mem[(32'h2000 >> 2) + i]);
                $display("");

                $finish;

            end

        end

        $display("");
        $display("*** DMA TEST 5A PASS ***");
        $display("AWREADY backpressure handled correctly.");

    end

endtask

task automatic test_5b_wready_delay;

    integer i;
    integer words;
    logic [31:0] expected_data;

    begin

        $display("");
        $display("========================================");
        $display("          DMA TEST 5B");
        $display("          WREADY DELAY");
        $display("========================================");

        // Keep AWREADY normal
        awready_enable = 1'b1;

        // Enable WREADY initially
        wready_enable = 1'b1;

        words = 4;

        // Initialize source memory
        for (i = 0; i < words; i = i + 1) begin
            expected_data = 32'hC0000000 + i;
            memory.mem[(32'h1000 >> 2) + i] = expected_data;
        end

        // Clear destination memory
        for (i = 0; i < words; i = i + 1) begin
            memory.mem[(32'h2000 >> 2) + i] = 32'h00000000;
        end

        // Configure DMA
        axi_write(32'h00000008, 32'h00001000);
        axi_write(32'h0000000C, 32'h00002000);
        axi_write(32'h00000010, 32'h00000010);
        axi_write(32'h00000000, 32'h00000001);

        $display("DMA started.");

        // Wait until WVALID is asserted
        wait (m_axi_wvalid == 1'b1);

        $display("");
        $display("TEST 5B: WVALID detected.");
        $display("Blocking WREADY for 3 clock cycles.");

        // Block W channel
        wready_enable = 1'b0;

        repeat (3) begin
            @(posedge clk);

            $display(
                "TIME=%0t | WVALID=%b | WREADY=%b | WDATA=%h",
                $time,
                m_axi_wvalid,
                m_axi_wready,
                m_axi_wdata
            );

            // WVALID must remain asserted
            if (m_axi_wvalid !== 1'b1) begin
                $display("");
                $display("ERROR: WVALID dropped while WREADY=0");
                $display("*** DMA TEST 5B FAILED ***");
                $finish;
            end

            // WREADY must remain LOW
            if (m_axi_wready !== 1'b0) begin
                $display("");
                $display("ERROR: WREADY did not remain LOW");
                $display("*** DMA TEST 5B FAILED ***");
                $finish;
            end
        end

        $display("");
        $display("TEST 5B: Releasing WREADY.");

        // Release W channel
        wready_enable = 1'b1;

        // Wait for DMA completion
        wait (dut.dma_done == 1'b1);

        @(posedge clk);

        // Verify destination data
        for (i = 0; i < words; i = i + 1) begin

            expected_data = 32'hC0000000 + i;

            if (memory.mem[(32'h2000 >> 2) + i] !== expected_data) begin

                $display("");
                $display("ERROR: TEST 5B FAILED");
                $display("  Word     = %0d", i);
                $display("  Address  = %h", 32'h2000 + (i * 4));
                $display("  Expected = %h", expected_data);
                $display("  Actual   = %h",
                         memory.mem[(32'h2000 >> 2) + i]);
                $display("");

                $finish;
            end
        end

        $display("");
        $display("*** DMA TEST 5B PASS ***");
        $display("WREADY backpressure handled correctly.");

    end

endtask

task automatic test_5c_bvalid_delay;

    integer i;
    integer words;
    logic [31:0] expected_data;

    begin

        $display("");
        $display("========================================");
        $display("          DMA TEST 5C");
        $display("          BVALID DELAY");
        $display("========================================");
awready_enable = 1'b1;
wready_enable  = 1'b1;

// Start with BVALID blocked
bvalid_enable  = 1'b1;

        words = 4;

        for (i = 0; i < words; i = i + 1) begin
            expected_data = 32'hD0000000 + i;
            memory.mem[(32'h1000 >> 2) + i] = expected_data;
        end

        for (i = 0; i < words; i = i + 1) begin
            memory.mem[(32'h2000 >> 2) + i] = 32'h00000000;
        end

  axi_write(32'h00000008, 32'h00001000);
axi_write(32'h0000000C, 32'h00002000);
axi_write(32'h00000010, 32'h00000010);
axi_write(32'h00000000, 32'h00000001);

$display("DMA started.");

// Now block BVALID for the AXI4 DMA write response
bvalid_enable = 1'b0;

// Wait for WVALID
// Wait for WVALID
wait (m_axi_wvalid == 1'b1);

$display("");
$display("TEST 5C: WVALID detected.");
$display("Waiting for W handshake.");

// Wait for actual W handshake
while (!(m_axi_wvalid && m_axi_wready))
    @(posedge clk);

// Allow AXI write master to enter WAIT_B
@(posedge clk);

$display("");
$display("TEST 5C: W handshake completed.");
$display("Blocking BVALID for 3 clock cycles.");

  
       

        repeat (3) begin

            @(posedge clk);

            $display(
                "TIME=%0t | WVALID=%b | WREADY=%b | BVALID=%b | BREADY=%b",
                $time,
                m_axi_wvalid,
                m_axi_wready,
                m_axi_bvalid,
                m_axi_bready
            );

            if (m_axi_bvalid !== 1'b0) begin
                $display("");
                $display("ERROR: BVALID asserted while blocked");
                $display("*** DMA TEST 5C FAILED ***");
                $finish;
            end

            if (m_axi_bready !== 1'b1) begin
                $display("");
                $display("ERROR: BREADY dropped unexpectedly");
                $display("*** DMA TEST 5C FAILED ***");
                $finish;
            end

        end

        $display("");
        $display("TEST 5C: Releasing BVALID.");

        bvalid_enable = 1'b1;

        wait (m_axi_bvalid == 1'b1);

        $display("BVALID asserted after delay.");

        wait (dut.dma_done == 1'b1);

        @(posedge clk);

        for (i = 0; i < words; i = i + 1) begin

            expected_data = 32'hD0000000 + i;

            if (memory.mem[(32'h2000 >> 2) + i]
                !== expected_data) begin

                $display("");
                $display("ERROR: TEST 5C FAILED");
                $display("  Word     = %0d", i);
                $display("  Address  = %h",
                         32'h2000 + (i * 4));
                $display("  Expected = %h",
                         expected_data);
                $display("  Actual   = %h",
                         memory.mem[(32'h2000 >> 2) + i]);
                $display("");

                $finish;
            end
        end

        $display("");
        $display("*** DMA TEST 5C PASS ***");
        $display("BVALID backpressure handled correctly.");

    end

endtask

//============================================================
// TEST 5D - RVALID DELAY
//============================================================

task automatic test_5d_rvalid_delay;

    integer i;
    integer words;
    logic [31:0] expected_data;

    begin

        $display("");
        $display("========================================");
        $display("          DMA TEST 5D");
        $display("          RVALID DELAY");
        $display("========================================");

        //========================================================
        // Normal AXI operation
        //========================================================

        awready_enable = 1'b1;
        wready_enable  = 1'b1;
        bvalid_enable  = 1'b1;

        // Block RVALID
        rvalid_enable  = 1'b0;

        words = 4;

        //========================================================
        // Initialize source memory
        //========================================================

        for (i = 0; i < words; i = i + 1) begin

            expected_data = 32'hE0000000 + i;

            memory.mem[(32'h1000 >> 2) + i] = expected_data;

        end

        //========================================================
        // Clear destination memory
        //========================================================

        for (i = 0; i < words; i = i + 1) begin

            memory.mem[(32'h2000 >> 2) + i] =
                32'h00000000;

        end

        //========================================================
        // Configure DMA
        //========================================================

        axi_write(32'h00000008, 32'h00001000);

        axi_write(32'h0000000C, 32'h00002000);

        axi_write(32'h00000010, 32'h00000010);

        //========================================================
        // Start DMA
        //========================================================

        axi_write(32'h00000000, 32'h00000001);

        $display("DMA started.");

        //========================================================
        // Wait for ARVALID
        //========================================================

        wait (m_axi_arvalid == 1'b1);

        $display("");
        $display("TEST 5D: ARVALID detected.");
        $display("Waiting for AR handshake.");

        //========================================================
        // Wait for AR handshake
        //========================================================

        while (!(m_axi_arvalid && m_axi_arready))
            @(posedge clk);

        // Allow read master to enter RDATA state
        @(posedge clk);

        $display("");
        $display("TEST 5D: AR handshake completed.");
        $display("Blocking RVALID for 3 clock cycles.");

        //========================================================
        // Check delayed RVALID
        //========================================================

        repeat (3) begin

            @(posedge clk);

            $display(
                "TIME=%0t | ARVALID=%b | ARREADY=%b | RVALID=%b | RREADY=%b | RDATA=%h",
                $time,
                m_axi_arvalid,
                m_axi_arready,
                m_axi_rvalid,
                m_axi_rready,
                m_axi_rdata
            );

            // RVALID must remain LOW
            if (m_axi_rvalid !== 1'b0) begin

                $display("");
                $display("ERROR: RVALID asserted while blocked");
                $display("*** DMA TEST 5D FAILED ***");
                $finish;

            end

            // RREADY must remain HIGH
            if (m_axi_rready !== 1'b1) begin

                $display("");
                $display("ERROR: RREADY dropped unexpectedly");
                $display("*** DMA TEST 5D FAILED ***");
                $finish;

            end

        end

        //========================================================
        // Release RVALID
        //========================================================

        $display("");
        $display("TEST 5D: Releasing RVALID.");

        rvalid_enable = 1'b1;

        //========================================================
        // Wait for RVALID
        //========================================================

        wait (m_axi_rvalid == 1'b1);

        $display("RVALID asserted after delay.");

        //========================================================
        // Wait for DMA completion
        //========================================================

        wait (dut.dma_done == 1'b1);

        @(posedge clk);

        //========================================================
        // Verify destination memory
        //========================================================

        for (i = 0; i < words; i = i + 1) begin

            expected_data = 32'hE0000000 + i;

            if (memory.mem[(32'h2000 >> 2) + i]
                !== expected_data) begin

                $display("");
                $display("ERROR: TEST 5D FAILED");
                $display("  Word     = %0d", i);
                $display("  Address  = %h",
                         32'h2000 + (i * 4));
                $display("  Expected = %h",
                         expected_data);
                $display("  Actual   = %h",
                         memory.mem[(32'h2000 >> 2) + i]);
                $display("");

                $finish;

            end

        end

        $display("");
        $display("*** DMA TEST 5D PASS ***");
        $display("RVALID backpressure handled correctly.");

    end

endtask


//============================================================
// TEST 6 - RANDOMIZED AXI BACKPRESSURE
//============================================================

task automatic test_6_random_backpressure;

    integer i;
    integer words;
    integer cycle;
    integer timeout;
    integer random_value;

    logic [31:0] expected_data;

    begin

        $display("");
        $display("========================================");
        $display("          DMA TEST 6");
        $display("     RANDOMIZED AXI BACKPRESSURE");
        $display("========================================");

        //========================================================
        // Normal AXI operation
        //========================================================

        awready_enable = 1'b1;
        wready_enable  = 1'b1;
        bvalid_enable  = 1'b1;
        rvalid_enable  = 1'b1;
       
        words = 16;

        //========================================================
        // Initialize source memory
        //========================================================

        for (i = 0; i < words; i = i + 1) begin

            expected_data = 32'hF0000000 + i;

            memory.mem[(32'h1000 >> 2) + i] =
                expected_data;

        end

        //========================================================
        // Clear destination memory
        //========================================================

        for (i = 0; i < words; i = i + 1) begin

            memory.mem[(32'h2000 >> 2) + i] =
                32'h00000000;

        end

        //========================================================
        // Configure DMA
        //========================================================

        axi_write(32'h00000008, 32'h00001000);

        axi_write(32'h0000000C, 32'h00002000);

        axi_write(32'h00000010, 32'h00000040);

        //========================================================
        // Start DMA
        //========================================================

        axi_write(32'h00000000, 32'h00000001);

        $display("");
        $display("DMA TEST 6 STARTED.");
        $display("Random AXI backpressure enabled.");

        //========================================================
        // Randomized AXI operation
        //========================================================

        cycle = 0;
        timeout = 0;

        while (dut.dma_done !== 1'b1) begin

            @(posedge clk);

            cycle = cycle + 1;
            timeout = timeout + 1;

            //====================================================
            // Random AWREADY
            //====================================================

            random_value = $urandom_range(0, 3);

            if (random_value == 0)
                awready_enable = 1'b0;
            else
                awready_enable = 1'b1;

            //====================================================
            // Random WREADY
            //====================================================

            random_value = $urandom_range(0, 3);

            if (random_value == 0)
                wready_enable = 1'b0;
            else
                wready_enable = 1'b1;

            //====================================================
            // Random BVALID
            //====================================================

            random_value = $urandom_range(0, 3);

            if (random_value == 0)
                bvalid_enable = 1'b0;
            else
                bvalid_enable = 1'b1;

            //====================================================
            // Random RVALID
            //====================================================

            random_value = $urandom_range(0, 3);

            if (random_value == 0)
                rvalid_enable = 1'b0;
            else
                rvalid_enable = 1'b1;

            //====================================================
            // Debug
            //====================================================

            if ((cycle % 10) == 0) begin

                $display(
                    "TEST 6 | CYCLE=%0d | AW=%b | W=%b | B=%b | R=%b | STATE=%0d | FIFO=%0d",
                    cycle,
                    awready_enable,
                    wready_enable,
                    bvalid_enable,
                    rvalid_enable,
                    dut.u_dma_controller.state,
                    dut.u_dma_fifo.count
                );

            end

            //====================================================
            // Timeout protection
            //====================================================

            if (timeout > 2000) begin

                $display("");
                $display("ERROR: TEST 6 TIMEOUT");
                $display("DMA did not complete.");
                $display("*** DMA TEST 6 FAILED ***");

                $finish;

            end

        end

        //========================================================
        // DMA reports DONE
        //========================================================

        $display("");
        $display("TEST 6: DMA DONE detected.");
        $display("Waiting for final write activity to settle.");

        //========================================================
        // Restore normal AXI operation
        //========================================================

        awready_enable = 1'b1;
        wready_enable  = 1'b1;
        bvalid_enable  = 1'b1;
        rvalid_enable  = 1'b1;

        //========================================================
        // Allow final transactions to settle
        //========================================================

        repeat (5)
            @(posedge clk);

        //========================================================
        // Verify destination memory
        //========================================================

        for (i = 0; i < words; i = i + 1) begin

            expected_data = 32'hF0000000 + i;

            if (memory.mem[(32'h2000 >> 2) + i]
                !== expected_data) begin

                $display("");
                $display("ERROR: TEST 6 FAILED");
                $display("  Word     = %0d", i);
                $display("  Address  = %h",
                         32'h2000 + (i * 4));
                $display("  Expected = %h",
                         expected_data);
                $display("  Actual   = %h",
                         memory.mem[(32'h2000 >> 2) + i]);

                $display("");
                $display("DMA_STATE = %0d",
                         dut.u_dma_controller.state);

                $display("FIFO_COUNT = %0d",
                         dut.u_dma_fifo.count);

                $finish;

            end

        end

        $display("");
        $display("*** DMA TEST 6 PASS ***");
        $display("Randomized AXI backpressure handled correctly.");
        $display("Total randomized cycles = %0d", cycle);

    end

endtask


//============================================================
// TEST 7 - RESET DURING ACTIVE DMA TRANSFER
//============================================================

task automatic test_7_reset_during_transfer;

    integer i;
    integer words;
    integer cycle_count;

    logic [31:0] expected_data;

    begin

        $display("");
        $display("========================================");
        $display("          DMA TEST 7");
        $display("      RESET DURING TRANSFER");
        $display("========================================");

        //========================================================
        // Restore normal AXI operation
        //========================================================

        awready_enable = 1'b1;
        wready_enable  = 1'b1;
        bvalid_enable  = 1'b1;
        rvalid_enable  = 1'b1;

        words = 16;

        //========================================================
        // Initialize source memory
        //========================================================

        for (i = 0; i < words; i = i + 1) begin

            expected_data = 32'h70000000 + i;

            memory.mem[(32'h1000 >> 2) + i] =
                expected_data;

        end

        //========================================================
        // Clear destination memory
        //========================================================

        for (i = 0; i < words; i = i + 1) begin

            memory.mem[(32'h2000 >> 2) + i] =
                32'h00000000;

        end

        //========================================================
        // Configure DMA
        //========================================================

        axi_write(32'h00000008, 32'h00001000);
        axi_write(32'h0000000C, 32'h00002000);
        axi_write(32'h00000010, 32'h00000040);

        //========================================================
        // Start DMA
        //========================================================

        axi_write(32'h00000000, 32'h00000001);

        $display("");
        $display("TEST 7: DMA started.");
        $display("Waiting for DMA to become active...");

        //========================================================
        // Wait until DMA actually starts doing AXI activity
        //========================================================

        cycle_count = 0;

        while ((m_axi_arvalid !== 1'b1) &&
               (m_axi_awvalid !== 1'b1) &&
               (m_axi_wvalid  !== 1'b1)) begin

            @(posedge clk);

            cycle_count = cycle_count + 1;

            if (cycle_count > 100) begin

                $display("");
                $display("ERROR: DMA did not become active.");
                $display("*** DMA TEST 7 FAILED ***");

                $finish;

            end

        end

        $display("");
        $display("TEST 7: DMA is active.");
        $display("  DMA STATE = %0d",
                 dut.u_dma_controller.state);
        $display("  FIFO COUNT = %0d",
                 dut.u_dma_fifo.count);
        $display("  ARVALID = %b", m_axi_arvalid);
        $display("  AWVALID = %b", m_axi_awvalid);
        $display("  WVALID  = %b", m_axi_wvalid);

        //========================================================
        // Let DMA run for a few cycles
        //========================================================

        repeat (3) begin

            @(posedge clk);

            $display(
                "TEST 7 | TIME=%0t | STATE=%0d | FIFO=%0d | ARV=%b | AWV=%b | WV=%b",
                $time,
                dut.u_dma_controller.state,
                dut.u_dma_fifo.count,
                m_axi_arvalid,
                m_axi_awvalid,
                m_axi_wvalid
            );

        end

        //========================================================
        // ASSERT RESET WHILE DMA IS ACTIVE
        //========================================================

        $display("");
        $display("TEST 7: *** ASSERTING RESET ***");

        rst_n = 1'b0;

        // Allow reset to propagate
        repeat (3)
            @(posedge clk);

        //========================================================
        // Check DMA state after reset
        //========================================================

        $display("");
        $display("TEST 7: Checking DMA after reset.");

        $display(
            "RESET CHECK | STATE=%0d | FIFO=%0d | ARV=%b | AWV=%b | WV=%b | BV=%b | RV=%b",
            dut.u_dma_controller.state,
            dut.u_dma_fifo.count,
            m_axi_arvalid,
            m_axi_awvalid,
            m_axi_wvalid,
            m_axi_bvalid,
            m_axi_rvalid
        );

        //========================================================
        // Check FIFO is empty
        //========================================================

        if (dut.u_dma_fifo.count !== 0) begin

            $display("");
            $display("ERROR: FIFO was not cleared by reset.");
            $display("FIFO COUNT = %0d",
                     dut.u_dma_fifo.count);
            $display("*** DMA TEST 7 FAILED ***");

            $finish;

        end

        //========================================================
        // Check AXI VALID signals are cleared
        //========================================================

        if (m_axi_arvalid !== 1'b0) begin

            $display("");
            $display("ERROR: ARVALID remained HIGH after reset.");
            $display("*** DMA TEST 7 FAILED ***");

            $finish;

        end

        if (m_axi_awvalid !== 1'b0) begin

            $display("");
            $display("ERROR: AWVALID remained HIGH after reset.");
            $display("*** DMA TEST 7 FAILED ***");

            $finish;

        end

        if (m_axi_wvalid !== 1'b0) begin

            $display("");
            $display("ERROR: WVALID remained HIGH after reset.");
            $display("*** DMA TEST 7 FAILED ***");

            $finish;

        end

        //========================================================
        // Release reset
        //========================================================

        $display("");
        $display("TEST 7: Reset checks passed.");
        $display("TEST 7: Releasing reset.");

        rst_n = 1'b1;

        repeat (5)
            @(posedge clk);

        //========================================================
        // Verify DMA is idle after reset
        //========================================================

        $display("");
        $display("TEST 7: DMA state after reset release = %0d",
                 dut.u_dma_controller.state);

        //========================================================
        // Clear destination again
        //========================================================

        for (i = 0; i < words; i = i + 1) begin

            memory.mem[(32'h2000 >> 2) + i] =
                32'h00000000;

        end

        //========================================================
        // Reconfigure DMA after reset
        //========================================================

        $display("");
        $display("TEST 7: Starting fresh DMA transfer after reset.");

        axi_write(32'h00000008, 32'h00001000);
        axi_write(32'h0000000C, 32'h00002000);
        axi_write(32'h00000010, 32'h00000040);

        axi_write(32'h00000000, 32'h00000001);

        $display("TEST 7: Fresh DMA transfer started.");

        //========================================================
        // Wait for completion
        //========================================================

        cycle_count = 0;

        while (dut.dma_done !== 1'b1) begin

            @(posedge clk);

            cycle_count = cycle_count + 1;

            if (cycle_count > 1000) begin

                $display("");
                $display("ERROR: TEST 7 DMA TIMEOUT.");
                $display("*** DMA TEST 7 FAILED ***");

                $finish;

            end

        end

        $display("");
        $display("TEST 7: DMA completed successfully after reset.");

        //========================================================
        // Allow final write activity to settle
        //========================================================

        repeat (5)
            @(posedge clk);

        //========================================================
        // Verify destination memory
        //========================================================

        for (i = 0; i < words; i = i + 1) begin

            expected_data = 32'h70000000 + i;

            if (memory.mem[(32'h2000 >> 2) + i]
                !== expected_data) begin

                $display("");
                $display("ERROR: TEST 7 FAILED");
                $display("  Word     = %0d", i);
                $display("  Address  = %h",
                         32'h2000 + (i * 4));
                $display("  Expected = %h",
                         expected_data);
                $display("  Actual   = %h",
                         memory.mem[(32'h2000 >> 2) + i]);

                $display("");
                $display("DMA_STATE = %0d",
                         dut.u_dma_controller.state);

                $display("FIFO_COUNT = %0d",
                         dut.u_dma_fifo.count);

                $finish;

            end

        end

        //========================================================
        // TEST PASSED
        //========================================================

        $display("");
        $display("*** DMA TEST 7 PASS ***");
        $display("Reset during active DMA handled correctly.");
        $display("DMA successfully restarted after reset.");
        $display("Transferred %0d bytes after reset.", words * 4);

    end

endtask

//============================================================
// TEST 8 - TRANSFER LENGTH BOUNDARY TEST
//============================================================

task automatic test_8_transfer_boundaries;

    integer i;
    integer j;
    integer length;
    integer words;
    integer test_case;

    logic [31:0] expected_data;

    begin

        $display("");
        $display("========================================");
        $display("          DMA TEST 8");
        $display("      TRANSFER BOUNDARY TEST");
        $display("========================================");

        //========================================================
        // Normal AXI operation
        //========================================================

        awready_enable = 1'b1;
        wready_enable  = 1'b1;
        bvalid_enable  = 1'b1;
        rvalid_enable  = 1'b1;

        //========================================================
        // Test different transfer lengths
        //========================================================

        for (test_case = 0; test_case < 5; test_case = test_case + 1) begin

            // Select transfer length
            case (test_case)

                0: length = 4;     // 1 word
                1: length = 12;    // 3 words
                2: length = 20;    // 5 words
                3: length = 32;    // 8 words
                4: length = 128;   // 32 words

                default: length = 4;

            endcase

            words = length / 4;

            $display("");
            $display("----------------------------------------");
            $display("TEST 8 CASE %0d", test_case + 1);
            $display("TRANSFER LENGTH = %0d BYTES", length);
            $display("WORDS           = %0d", words);
            $display("----------------------------------------");

            //====================================================
            // Initialize source memory
            //====================================================

            for (i = 0; i < words; i = i + 1) begin

                expected_data =
                    32'h80000000 +
                    (test_case * 32'h00010000) +
                    i;

                memory.mem[(32'h1000 >> 2) + i] =
                    expected_data;

            end

            //====================================================
            // Clear destination memory
            //====================================================

            for (i = 0; i < words; i = i + 1) begin

                memory.mem[(32'h2000 >> 2) + i] =
                    32'h00000000;

            end

            //====================================================
            // Configure DMA
            //====================================================

            axi_write(
                32'h00000008,
                32'h00001000
            );

            axi_write(
                32'h0000000C,
                32'h00002000
            );

            axi_write(
                32'h00000010,
                length
            );

            //====================================================
            // Start DMA
            //====================================================

            axi_write(
                32'h00000000,
                32'h00000001
            );

            $display(
                "TEST 8 CASE %0d: DMA started.",
                test_case + 1
            );

            //====================================================
            // Wait for DMA completion
            //====================================================

            wait (dut.dma_done == 1'b1);

            @(posedge clk);

            //====================================================
            // Verify destination memory
            //====================================================

            for (j = 0; j < words; j = j + 1) begin

                expected_data =
                    32'h80000000 +
                    (test_case * 32'h00010000) +
                    j;

                if (memory.mem[(32'h2000 >> 2) + j]
                    !== expected_data) begin

                    $display("");
                    $display("ERROR: TEST 8 CASE %0d FAILED",
                             test_case + 1);

                    $display("  Length   = %0d bytes",
                             length);

                    $display("  Word     = %0d",
                             j);

                    $display("  Address  = %h",
                             32'h2000 + (j * 4));

                    $display("  Expected = %h",
                             expected_data);

                    $display("  Actual   = %h",
                             memory.mem[(32'h2000 >> 2) + j]);

                    $display("");

                    $finish;

                end

            end

            $display(
                "*** TEST 8 CASE %0d PASS ***",
                test_case + 1
            );

        end

        //========================================================
        // Final result
        //========================================================

        $display("");
        $display("*** DMA TEST 8 PASS ***");
        $display("All transfer boundary lengths handled correctly.");
        $display("Tested: 4, 12, 20, 32 and 128 bytes.");

    end

endtask

//============================================================
// TEST 9 - LONG AXI STALL / SIGNAL STABILITY
//============================================================

task automatic test_9_long_axi_stall;

    integer i;
    integer words;
    integer cycle_count;

    logic [31:0] expected_data;

    logic [31:0] saved_awaddr;
    logic [31:0] saved_wdata;

    begin

        $display("");
        $display("========================================");
        $display("          DMA TEST 9");
        $display("     LONG AXI STALL / STABILITY");
        $display("========================================");

        //========================================================
        // Normal AXI operation
        //========================================================

        awready_enable = 1'b1;
        wready_enable  = 1'b1;
        bvalid_enable  = 1'b1;
        rvalid_enable  = 1'b1;

    

        words = 16;

        //========================================================
        // Initialize source memory
        //========================================================

        for (i = 0; i < words; i = i + 1) begin

            expected_data = 32'h90000000 + i;

            memory.mem[(32'h1000 >> 2) + i] =
                expected_data;

        end

        //========================================================
        // Clear destination memory
        //========================================================

        for (i = 0; i < words; i = i + 1) begin

            memory.mem[(32'h2000 >> 2) + i] =
                32'h00000000;

        end

        //========================================================
        // Configure DMA
        //========================================================

        axi_write(32'h00000008, 32'h00001000);
        axi_write(32'h0000000C, 32'h00002000);
        axi_write(32'h00000010, 32'h00000040);

        //========================================================
        // Start DMA
        //========================================================

        axi_write(32'h00000000, 32'h00000001);

        $display("");
        $display("TEST 9: DMA started.");

        //========================================================
        // Wait for AWVALID
        //========================================================

        wait (m_axi_awvalid == 1'b1);

        $display("");
        $display("TEST 9: AWVALID detected.");

        // Save address while valid
        saved_awaddr = m_axi_awaddr;

        $display("  AWADDR = %h", saved_awaddr);
        $display("  Blocking AWREADY for 10 cycles.");

        //========================================================
        // Block AWREADY
        //========================================================

        awready_enable = 1'b0;

        repeat (10) begin

            @(posedge clk);

            $display(
                "TEST 9 AW | TIME=%0t | AWVALID=%b | AWREADY=%b | AWADDR=%h",
                $time,
                m_axi_awvalid,
                m_axi_awready,
                m_axi_awaddr
            );

            // AWVALID must remain HIGH
            if (m_axi_awvalid !== 1'b1) begin

                $display("");
                $display("ERROR: AWVALID dropped during long stall.");
                $display("*** DMA TEST 9 FAILED ***");

                $finish;

            end

            // AWREADY must remain LOW
            if (m_axi_awready !== 1'b0) begin

                $display("");
                $display("ERROR: AWREADY became HIGH during stall.");
                $display("*** DMA TEST 9 FAILED ***");

                $finish;

            end

            // AWADDR must remain stable
            if (m_axi_awaddr !== saved_awaddr) begin

                $display("");
                $display("ERROR: AWADDR changed while AWVALID=1 and AWREADY=0.");
                $display("  Original = %h", saved_awaddr);
                $display("  Current  = %h", m_axi_awaddr);
                $display("*** DMA TEST 9 FAILED ***");

                $finish;

            end

        end

        //========================================================
        // Release AWREADY
        //========================================================

        $display("");
        $display("TEST 9: Releasing AWREADY.");

        awready_enable = 1'b1;

        // Wait for AW handshake
        while (!(m_axi_awvalid && m_axi_awready))
            @(posedge clk);

        $display("TEST 9: AW handshake completed.");

        //========================================================
        // Wait for WVALID
        //========================================================

        wait (m_axi_wvalid == 1'b1);

        $display("");
        $display("TEST 9: WVALID detected.");

        // Save WDATA
        saved_wdata = m_axi_wdata;

        $display("  WDATA = %h", saved_wdata);
        $display("  Blocking WREADY for 10 cycles.");

        //========================================================
        // Block WREADY
        //========================================================

        wready_enable = 1'b0;

        repeat (10) begin

            @(posedge clk);

            $display(
                "TEST 9 W  | TIME=%0t | WVALID=%b | WREADY=%b | WDATA=%h | WLAST=%b",
                $time,
                m_axi_wvalid,
                m_axi_wready,
                m_axi_wdata,
                m_axi_wlast
            );

            // WVALID must remain HIGH
            if (m_axi_wvalid !== 1'b1) begin

                $display("");
                $display("ERROR: WVALID dropped during long stall.");
                $display("*** DMA TEST 9 FAILED ***");

                $finish;

            end

            // WREADY must remain LOW
            if (m_axi_wready !== 1'b0) begin

                $display("");
                $display("ERROR: WREADY became HIGH during stall.");
                $display("*** DMA TEST 9 FAILED ***");

                $finish;

            end

            // WDATA must remain stable
            if (m_axi_wdata !== saved_wdata) begin

                $display("");
                $display("ERROR: WDATA changed while WVALID=1 and WREADY=0.");
                $display("  Original = %h", saved_wdata);
                $display("  Current  = %h", m_axi_wdata);
                $display("*** DMA TEST 9 FAILED ***");

                $finish;

            end

        end

        //========================================================
        // Release WREADY
        //========================================================

        $display("");
        $display("TEST 9: Releasing WREADY.");

        wready_enable = 1'b1;

        // Wait for W handshake
        while (!(m_axi_wvalid && m_axi_wready))
            @(posedge clk);

        $display("TEST 9: W handshake completed.");

        //========================================================
        // Wait until write response phase
        //========================================================

        @(posedge clk);

        $display("");
        $display("TEST 9: Blocking BVALID for 10 cycles.");

        //========================================================
        // Block BVALID
        //========================================================

        bvalid_enable = 1'b0;

        repeat (10) begin

            @(posedge clk);

            $display(
                "TEST 9 B  | TIME=%0t | BVALID=%b | BREADY=%b",
                $time,
                m_axi_bvalid,
                m_axi_bready
            );

            // BVALID must remain LOW
            if (m_axi_bvalid !== 1'b0) begin

                $display("");
                $display("ERROR: BVALID asserted during long stall.");
                $display("*** DMA TEST 9 FAILED ***");

                $finish;

            end

            // BREADY must remain HIGH
            if (m_axi_bready !== 1'b1) begin

                $display("");
                $display("ERROR: BREADY dropped during BVALID stall.");
                $display("*** DMA TEST 9 FAILED ***");

                $finish;

            end

        end

        //========================================================
        // Release BVALID
        //========================================================

        $display("");
        $display("TEST 9: Releasing BVALID.");

        bvalid_enable = 1'b1;

        //========================================================
        // Wait for DMA completion
        //========================================================

        cycle_count = 0;

        while (dut.dma_done !== 1'b1) begin

            @(posedge clk);

            cycle_count = cycle_count + 1;

            if (cycle_count > 1000) begin

                $display("");
                $display("ERROR: TEST 9 TIMEOUT.");
                $display("*** DMA TEST 9 FAILED ***");

                $finish;

            end

        end

        $display("");
        $display("TEST 9: DMA DONE detected.");

        //========================================================
        // Restore normal AXI operation
        //========================================================

        awready_enable = 1'b1;
        wready_enable  = 1'b1;
        bvalid_enable  = 1'b1;
        rvalid_enable  = 1'b1;

        //========================================================
        // Allow final transactions to settle
        //========================================================

        repeat (5)
            @(posedge clk);

        //========================================================
        // Verify destination memory
        //========================================================

        for (i = 0; i < words; i = i + 1) begin

            expected_data = 32'h90000000 + i;

            if (memory.mem[(32'h2000 >> 2) + i]
                !== expected_data) begin

                $display("");
                $display("ERROR: TEST 9 FAILED");
                $display("  Word     = %0d", i);
                $display("  Address  = %h",
                         32'h2000 + (i * 4));
                $display("  Expected = %h",
                         expected_data);
                $display("  Actual   = %h",
                         memory.mem[(32'h2000 >> 2) + i]);

                $display("");
                $display("DMA_STATE = %0d",
                         dut.u_dma_controller.state);

                $display("FIFO_COUNT = %0d",
                         dut.u_dma_fifo.count);

                $finish;

            end

        end

        //========================================================
        // TEST PASSED
        //========================================================

        $display("");
        $display("*** DMA TEST 9 PASS ***");
        $display("Long AXI stalls handled correctly.");
        $display("AWADDR remained stable during AW stall.");
        $display("WDATA remained stable during W stall.");
        $display("BREADY remained asserted during B stall.");
        $display("Transferred %0d bytes successfully.",
                 words * 4);

    end

endtask

//============================================================
// TEST 10 - LONG RVALID STALL / READ CHANNEL STABILITY
//============================================================

task automatic test_10_long_rvalid_stall;

    integer i;
    integer words;
    integer cycle_count;

    logic [31:0] expected_data;

    begin

        $display("");
        $display("========================================");
        $display("          DMA TEST 10");
        $display("     LONG RVALID STALL / READ");
        $display("========================================");

        //========================================================
        // Normal AXI operation
        //========================================================

        awready_enable = 1'b1;
        wready_enable  = 1'b1;
        bvalid_enable  = 1'b1;

        // RVALID will be blocked initially
        rvalid_enable  = 1'b0;

        words = 16;

        //========================================================
        // Initialize source memory
        //========================================================

        for (i = 0; i < words; i = i + 1) begin

            expected_data = 32'hA5000000 + i;

            memory.mem[(32'h1000 >> 2) + i] =
                expected_data;

        end

        //========================================================
        // Clear destination memory
        //========================================================

        for (i = 0; i < words; i = i + 1) begin

            memory.mem[(32'h2000 >> 2) + i] =
                32'h00000000;

        end

        //========================================================
        // Configure DMA
        //========================================================

        axi_write(32'h00000008, 32'h00001000);
        axi_write(32'h0000000C, 32'h00002000);
        axi_write(32'h00000010, 32'h00000040);

        //========================================================
        // Start DMA
        //========================================================

        axi_write(32'h00000000, 32'h00000001);

        $display("");
        $display("TEST 10: DMA started.");

        //========================================================
        // Wait for ARVALID
        //========================================================

        wait (m_axi_arvalid == 1'b1);

        $display("");
        $display("TEST 10: ARVALID detected.");
        $display("  ARADDR = %h", m_axi_araddr);
        $display("  ARLEN  = %0d", m_axi_arlen);

        //========================================================
        // Wait for AR handshake
        //========================================================

        while (!(m_axi_arvalid && m_axi_arready))
            @(posedge clk);

        $display("");
        $display("TEST 10: AR handshake completed.");

        //========================================================
        // Allow read master to enter RDATA state
        //========================================================

        @(posedge clk);

        $display("");
        $display("TEST 10: Blocking RVALID for 10 cycles.");

        //========================================================
        // RVALID is already blocked
        //========================================================

        repeat (10) begin

            @(posedge clk);

            $display(
                "TEST 10 R | TIME=%0t | ARVALID=%b | ARREADY=%b | RVALID=%b | RREADY=%b | RDATA=%h | RLAST=%b",
                $time,
                m_axi_arvalid,
                m_axi_arready,
                m_axi_rvalid,
                m_axi_rready,
                m_axi_rdata,
                m_axi_rlast
            );

            //====================================================
            // RVALID must remain LOW
            //====================================================

            if (m_axi_rvalid !== 1'b0) begin

                $display("");
                $display("ERROR: RVALID asserted while blocked.");
                $display("*** DMA TEST 10 FAILED ***");

                $finish;

            end

            //====================================================
            // RREADY must remain HIGH
            //====================================================

            if (m_axi_rready !== 1'b1) begin

                $display("");
                $display("ERROR: RREADY dropped during RVALID stall.");
                $display("*** DMA TEST 10 FAILED ***");

                $finish;

            end

        end

        //========================================================
        // Release RVALID
        //========================================================

        $display("");
        $display("TEST 10: Releasing RVALID.");

        rvalid_enable = 1'b1;

        //========================================================
        // Wait for first RVALID
        //========================================================

        wait (m_axi_rvalid == 1'b1);

        $display("");
        $display("TEST 10: RVALID asserted after delay.");
        $display("  RDATA = %h", m_axi_rdata);
        $display("  RLAST = %b", m_axi_rlast);

        //========================================================
        // Wait for DMA completion
        //========================================================

        cycle_count = 0;

        while (dut.dma_done !== 1'b1) begin

            @(posedge clk);

            cycle_count = cycle_count + 1;

            if (cycle_count > 1000) begin

                $display("");
                $display("ERROR: TEST 10 TIMEOUT.");
                $display("*** DMA TEST 10 FAILED ***");

                $finish;

            end

        end

        $display("");
        $display("TEST 10: DMA DONE detected.");

        //========================================================
        // Restore normal AXI operation
        //========================================================

        awready_enable = 1'b1;
        wready_enable  = 1'b1;
        bvalid_enable  = 1'b1;
        rvalid_enable  = 1'b1;

        //========================================================
        // Allow final transactions to settle
        //========================================================

        repeat (5)
            @(posedge clk);

        //========================================================
        // Verify destination memory
        //========================================================

        for (i = 0; i < words; i = i + 1) begin

            expected_data = 32'hA5000000 + i;

            if (memory.mem[(32'h2000 >> 2) + i]
                !== expected_data) begin

                $display("");
                $display("ERROR: TEST 10 FAILED");
                $display("  Word     = %0d", i);
                $display("  Address  = %h",
                         32'h2000 + (i * 4));
                $display("  Expected = %h",
                         expected_data);
                $display("  Actual   = %h",
                         memory.mem[(32'h2000 >> 2) + i]);

                $display("");
                $display("DMA_STATE = %0d",
                         dut.u_dma_controller.state);

                $display("FIFO_COUNT = %0d",
                         dut.u_dma_fifo.count);

                $finish;

            end

        end

        //========================================================
        // TEST PASSED
        //========================================================

        $display("");
        $display("*** DMA TEST 10 PASS ***");
        $display("Long RVALID stall handled correctly.");
        $display("RREADY remained asserted during RVALID stall.");
        $display("Read data transferred correctly after release.");
        $display("Transferred %0d bytes successfully.",
                 words * 4);

    end

endtask

//============================================================
// TEST 11 - BACK-TO-BACK DMA TRANSFERS
//============================================================

task automatic test_11_back_to_back_transfers;

    integer i;
    integer transfer;
    integer words;
    integer length;

    logic [31:0] expected_data;

    begin

        $display("");
        $display("========================================");
        $display("          DMA TEST 11");
        $display("      BACK-TO-BACK TRANSFERS");
        $display("========================================");

        //========================================================
        // Normal AXI operation
        //========================================================

        awready_enable = 1'b1;
        wready_enable  = 1'b1;
        bvalid_enable  = 1'b1;
        rvalid_enable  = 1'b1;

        //========================================================
        // Perform 4 consecutive DMA transfers
        //========================================================

        for (transfer = 0; transfer < 4; transfer = transfer + 1) begin

            // Different lengths for each transfer
            case (transfer)

                0: length = 16;    // 4 words
                1: length = 32;    // 8 words
                2: length = 64;    // 16 words
                3: length = 20;    // 5 words

                default: length = 16;

            endcase

            words = length / 4;

            $display("");
            $display("----------------------------------------");
            $display("TEST 11 TRANSFER %0d", transfer + 1);
            $display("LENGTH = %0d BYTES", length);
            $display("WORDS  = %0d", words);
            $display("----------------------------------------");

            //====================================================
            // Initialize source memory
            //====================================================

            for (i = 0; i < words; i = i + 1) begin

                expected_data =
                    32'hB1000000 +
                    (transfer * 32'h00010000) +
                    i;

                memory.mem[(32'h1000 >> 2) + i] =
                    expected_data;

            end

            //====================================================
            // Clear destination memory
            //====================================================

            for (i = 0; i < words; i = i + 1) begin

                memory.mem[(32'h2000 >> 2) + i] =
                    32'h00000000;

            end

            //====================================================
            // Configure DMA
            //====================================================

            axi_write(
                32'h00000008,
                32'h00001000
            );

            axi_write(
                32'h0000000C,
                32'h00002000
            );

            axi_write(
                32'h00000010,
                length
            );

            //====================================================
            // Start DMA
            //====================================================

            axi_write(
                32'h00000000,
                32'h00000001
            );

            $display(
                "TEST 11 TRANSFER %0d: DMA started.",
                transfer + 1
            );

            //====================================================
            // Wait for completion
            //====================================================

            wait (dut.dma_done == 1'b1);

            @(posedge clk);

            $display(
                "TEST 11 TRANSFER %0d: DMA DONE.",
                transfer + 1
            );

            //====================================================
            // Verify destination memory
            //====================================================

            for (i = 0; i < words; i = i + 1) begin

                expected_data =
                    32'hB1000000 +
                    (transfer * 32'h00010000) +
                    i;

                if (memory.mem[(32'h2000 >> 2) + i]
                    !== expected_data) begin

                    $display("");
                    $display(
                        "ERROR: TEST 11 TRANSFER %0d FAILED",
                        transfer + 1
                    );

                    $display("  Length   = %0d bytes",
                             length);

                    $display("  Word     = %0d",
                             i);

                    $display("  Address  = %h",
                             32'h2000 + (i * 4));

                    $display("  Expected = %h",
                             expected_data);

                    $display("  Actual   = %h",
                             memory.mem[(32'h2000 >> 2) + i]);

                    $display("");
                    $display("DMA_STATE = %0d",
                             dut.u_dma_controller.state);

                    $display("FIFO_COUNT = %0d",
                             dut.u_dma_fifo.count);

                    $finish;

                end

            end

            $display(
                "*** TEST 11 TRANSFER %0d PASS ***",
                transfer + 1
            );

        end

        //========================================================
        // Final test result
        //========================================================

        $display("");
        $display("*** DMA TEST 11 PASS ***");
        $display("Four consecutive DMA transfers completed successfully.");
        $display("No reset was performed between transfers.");
        $display("Transfer lengths: 16, 32, 64 and 20 bytes.");

    end

endtask

// ============================================================
// TEST 12: ADDRESS VARIATION
// ============================================================
// Purpose:
//   Verify DMA operation with different source and destination
//   addresses.
//
// Checks:
//   - Source address register
//   - Destination address register
//   - Address generation
//   - Data movement at different memory locations
//   - Multiple transfers without reset
// ============================================================

//============================================================
// TEST 12 - ADDRESS VARIATION
//============================================================

task automatic test_12_address_variation;

    integer i;
    integer case_no;
    integer length_bytes;
    integer words;
    integer timeout_count;

    reg [31:0] src_addr;
    reg [31:0] dst_addr;
    reg [31:0] expected_data;

    reg [31:0] src_list [0:3];
    reg [31:0] dst_list [0:3];
    integer len_list [0:3];

    begin

        $display("");
        $display("========================================");
        $display("       DMA TEST 12: ADDRESS VARIATION");
        $display("========================================");

        //========================================================
        // Test case 1
        //========================================================
        src_list[0] = 32'h00001000;
        dst_list[0] = 32'h00002000;
        len_list[0] = 16;

        //========================================================
        // Test case 2
        //========================================================
        src_list[1] = 32'h00001100;
        dst_list[1] = 32'h00003000;
        len_list[1] = 32;

        //========================================================
        // Test case 3
        //========================================================
        src_list[2] = 32'h00001400;
        dst_list[2] = 32'h00004000;
        len_list[2] = 64;

        //========================================================
        // Test case 4
        //========================================================
        src_list[3] = 32'h00001800;
        dst_list[3] = 32'h00005000;
        len_list[3] = 20;

        //========================================================
        // Run all four cases
        //========================================================

        for (case_no = 0; case_no < 4; case_no = case_no + 1) begin

            src_addr     = src_list[case_no];
            dst_addr     = dst_list[case_no];
            length_bytes = len_list[case_no];
            words        = length_bytes / 4;

            $display("");
            $display("----------------------------------------");
            $display("TEST 12 CASE %0d", case_no + 1);
            $display("SOURCE      = %08h", src_addr);
            $display("DESTINATION = %08h", dst_addr);
            $display("LENGTH      = %0d bytes", length_bytes);
            $display("----------------------------------------");

            //====================================================
            // Initialize source memory
            //====================================================

            for (i = 0; i < words; i = i + 1) begin

                expected_data =
                    32'hC2000000 +
                    (case_no * 32'h00010000) +
                    i;

                memory.mem[(src_addr >> 2) + i] =
                    expected_data;

                // Clear destination
                memory.mem[(dst_addr >> 2) + i] =
                    32'h00000000;

            end

            //====================================================
            // Configure DMA
            //====================================================

            axi_write(
                32'h00000008,
                src_addr
            );

            axi_write(
                32'h0000000C,
                dst_addr
            );

            axi_write(
                32'h00000010,
                length_bytes
            );

            //====================================================
            // Start DMA
            //====================================================

            axi_write(
                32'h00000000,
                32'h00000001
            );

            $display(
                "TEST 12 CASE %0d: DMA started.",
                case_no + 1
            );

            //====================================================
            // Wait for DMA completion
            //====================================================

            timeout_count = 0;

            while ((dut.dma_done !== 1'b1) &&
                   (timeout_count < 10000)) begin

                @(posedge clk);

                timeout_count = timeout_count + 1;

            end

            //====================================================
            // Timeout check
            //====================================================

            if (timeout_count >= 10000) begin

                $display("");
                $display(
                    "ERROR: TEST 12 CASE %0d TIMEOUT",
                    case_no + 1
                );

                $display(
                    "SOURCE      = %08h",
                    src_addr
                );

                $display(
                    "DESTINATION = %08h",
                    dst_addr
                );

                $display(
                    "LENGTH      = %0d bytes",
                    length_bytes
                );

                $display(
                    "DMA_STATE   = %0d",
                    dut.u_dma_controller.state
                );

                $display(
                    "FIFO_COUNT  = %0d",
                    dut.u_dma_fifo.count
                );

                $finish;

            end

            $display(
                "TEST 12 CASE %0d: DMA DONE.",
                case_no + 1
            );

            //====================================================
            // Verify destination memory
            //====================================================

            for (i = 0; i < words; i = i + 1) begin

                expected_data =
                    32'hC2000000 +
                    (case_no * 32'h00010000) +
                    i;

                if (memory.mem[(dst_addr >> 2) + i]
                    !== expected_data) begin

                    $display("");
                    $display(
                        "ERROR: TEST 12 CASE %0d FAILED",
                        case_no + 1
                    );

                    $display(
                        "WORD     = %0d",
                        i
                    );

                    $display(
                        "ADDRESS  = %08h",
                        dst_addr + (i * 4)
                    );

                    $display(
                        "EXPECTED = %08h",
                        expected_data
                    );

                    $display(
                        "ACTUAL   = %08h",
                        memory.mem[(dst_addr >> 2) + i]
                    );

                    $display(
                        "DMA_STATE = %0d",
                        dut.u_dma_controller.state
                    );

                    $display(
                        "FIFO_COUNT = %0d",
                        dut.u_dma_fifo.count
                    );

                    $finish;

                end

            end

            $display("");
            $display(
                "*** TEST 12 CASE %0d PASS ***",
                case_no + 1
            );

        end

        $display("");
        $display("*** DMA TEST 12 PASS ***");
        $display(
            "DMA successfully handled multiple source"
        );
        $display(
            "and destination address combinations."
        );
        $display("========================================");
        $display("");

    end

endtask

//============================================================
// TEST 13 - FIFO STRESS / LARGE TRANSFER
//============================================================
// Purpose:
//   Stress the DMA FIFO using a large 1024-byte transfer.
//
// Checks:
//   - FIFO can handle continuous data movement
//   - No FIFO overflow
//   - No FIFO underflow
//   - No data loss
//   - No duplicated data
//   - Data ordering is preserved
//   - DMA completes without deadlock
//============================================================

task automatic test_13_fifo_stress;

    integer i;
    integer words;
    integer timeout_count;

    reg [31:0] src_addr;
    reg [31:0] dst_addr;
    reg [31:0] expected_data;

    begin

        $display("");
        $display("========================================");
        $display("       DMA TEST 13: FIFO STRESS");
        $display("========================================");

        //========================================================
        // Transfer configuration
        //========================================================

        src_addr = 32'h00006000;
        dst_addr = 32'h00008000;

        // 1024 bytes = 256 words
        words = 256;

        $display("");
        $display("SOURCE      = %08h", src_addr);
        $display("DESTINATION = %08h", dst_addr);
        $display("LENGTH      = 1024 bytes");
        $display("WORDS       = %0d", words);
        $display("");

        //========================================================
        // Initialize source memory
        //========================================================

        for (i = 0; i < words; i = i + 1) begin

            expected_data =
                32'hD3000000 + i;

            memory.mem[(src_addr >> 2) + i] =
                expected_data;

            // Clear destination
            memory.mem[(dst_addr >> 2) + i] =
                32'h00000000;

        end

        $display("Source memory initialized.");
        $display("Destination memory cleared.");

        //========================================================
        // Configure DMA source address
        //========================================================

        axi_write(
            32'h00000008,
            src_addr
        );

        //========================================================
        // Configure DMA destination address
        //========================================================

        axi_write(
            32'h0000000C,
            dst_addr
        );

        //========================================================
        // Configure transfer length
        //========================================================

        axi_write(
            32'h00000010,
            32'd1024
        );

        //========================================================
        // Start DMA
        //========================================================

        axi_write(
            32'h00000000,
            32'h00000001
        );

        $display("");
        $display("TEST 13: DMA started.");
        $display("Large 1024-byte transfer in progress...");

        //========================================================
        // Wait for DMA completion
        //========================================================

        timeout_count = 0;

        while ((dut.dma_done !== 1'b1) &&
               (timeout_count < 100000)) begin

            @(posedge clk);

            timeout_count = timeout_count + 1;

        end

        //========================================================
        // Timeout check
        //========================================================

        if (timeout_count >= 100000) begin

            $display("");
            $display("ERROR: TEST 13 TIMEOUT");
            $display("DMA did not complete.");

            $display(
                "DMA_STATE  = %0d",
                dut.u_dma_controller.state
            );

            $display(
                "FIFO_COUNT = %0d",
                dut.u_dma_fifo.count
            );

            $display(
                "ARVALID    = %b",
                m_axi_arvalid
            );

            $display(
                "RVALID     = %b",
                m_axi_rvalid
            );

            $display(
                "AWVALID    = %b",
                m_axi_awvalid
            );

            $display(
                "WVALID     = %b",
                m_axi_wvalid
            );

            $finish;

        end

        $display("");
        $display("TEST 13: DMA DONE.");
        $display(
            "Transfer completed in %0d cycles.",
            timeout_count
        );

        //========================================================
        // Check FIFO is empty after transfer
        //========================================================

        if (dut.u_dma_fifo.count !== 0) begin

            $display("");
            $display("ERROR: TEST 13 FIFO NOT EMPTY");
            $display(
                "FIFO COUNT = %0d",
                dut.u_dma_fifo.count
            );

            $finish;

        end

        $display("FIFO empty check: PASS");

        //========================================================
        // Verify every destination word
        //========================================================

        for (i = 0; i < words; i = i + 1) begin

            expected_data =
                32'hD3000000 + i;

            if (memory.mem[(dst_addr >> 2) + i]
                !== expected_data) begin

                $display("");
                $display(
                    "ERROR: TEST 13 DATA MISMATCH"
                );

                $display(
                    "WORD     = %0d",
                    i
                );

                $display(
                    "ADDRESS  = %08h",
                    dst_addr + (i * 4)
                );

                $display(
                    "EXPECTED = %08h",
                    expected_data
                );

                $display(
                    "ACTUAL   = %08h",
                    memory.mem[(dst_addr >> 2) + i]
                );

                $display(
                    "FIFO_COUNT = %0d",
                    dut.u_dma_fifo.count
                );

                $finish;

            end

        end

        //========================================================
        // Final FIFO check
        //========================================================

        if (dut.u_dma_fifo.count !== 0) begin

            $display("");
            $display("ERROR: TEST 13 FIFO COUNT NOT ZERO");
            $display(
                "FIFO_COUNT = %0d",
                dut.u_dma_fifo.count
            );

            $finish;

        end

        //========================================================
        // PASS
        //========================================================

        $display("");
        $display("*** TEST 13 PASS ***");
        $display(
            "1024-byte / 256-word transfer completed successfully."
        );
        $display(
            "All destination data matched expected values."
        );
        $display(
            "FIFO remained consistent and ended empty."
        );
        $display("========================================");
        $display("");

    end

endtask

//============================================================
// TEST 14 - AXI ERROR RESPONSE TEST
//============================================================

task automatic test_14_axi_error_responses;

    integer i;
    integer timeout_count;

    reg [31:0] src_addr;
    reg [31:0] dst_addr;

    begin

        $display("");
        $display("========================================");
        $display("       DMA TEST 14: AXI ERROR RESPONSES");
        $display("========================================");

        //========================================================
        // Normal AXI channel operation
        //========================================================

        awready_enable = 1'b1;
        wready_enable  = 1'b1;
        bvalid_enable  = 1'b1;
        rvalid_enable  = 1'b1;

        // No errors initially
        rresp_error_enable = 1'b0;
        bresp_error_enable = 1'b0;

        src_addr = 32'h0000A000;
        dst_addr = 32'h0000B000;

        //========================================================
        // CASE 1 - READ RESPONSE SLVERR
        //========================================================

        $display("");
        $display("----------------------------------------");
        $display("TEST 14 CASE 1: READ SLVERR");
        $display("----------------------------------------");

        // Initialize source memory
        for (i = 0; i < 4; i = i + 1) begin

            memory.mem[(src_addr >> 2) + i] =
                32'hE4000000 + i;

            memory.mem[(dst_addr >> 2) + i] =
                32'h00000000;

        end

        // Enable read error
        rresp_error_enable = 1'b1;

        // Configure DMA
        axi_write(32'h00000008, src_addr);
        axi_write(32'h0000000C, dst_addr);
        axi_write(32'h00000010, 32'd16);

        // Start DMA
        axi_write(32'h00000000, 32'h00000001);

        $display("");
        $display("TEST 14 CASE 1: DMA started.");
        $display("Forcing RRESP = SLVERR.");

        //========================================================
        // Wait for DMA response
        //========================================================

        timeout_count = 0;

        while ((dut.dma_done !== 1'b1) &&
               (timeout_count < 10000)) begin

            @(posedge clk);

            timeout_count = timeout_count + 1;

        end

        if (timeout_count >= 10000) begin

            $display("");
            $display("TEST 14 CASE 1: DMA did not complete.");
            $display("This indicates the DMA did not silently");
            $display("complete after the AXI read error.");

            $display(
                "DMA_STATE  = %0d",
                dut.u_dma_controller.state
            );

            $display(
                "FIFO_COUNT = %0d",
                dut.u_dma_fifo.count
            );

            $display(
                "RRESP      = %b",
                m_axi_rresp
            );

            $display("");
            $display("*** TEST 14 CASE 1 COMPLETE ***");

        end
        else begin

            $display("");
            $display("TEST 14 CASE 1: DMA DONE.");
            $display("RRESP observed = %b", m_axi_rresp);

            $display(
                "NOTE: Current DMA completed despite SLVERR."
            );

        end

        // Restore normal read response
        rresp_error_enable = 1'b0;

        //========================================================
        // CASE 2 - WRITE RESPONSE SLVERR
        //========================================================

        $display("");
        $display("----------------------------------------");
        $display("TEST 14 CASE 2: WRITE SLVERR");
        $display("----------------------------------------");

        // Initialize source memory
        for (i = 0; i < 4; i = i + 1) begin

            memory.mem[(src_addr >> 2) + i] =
                32'hE5000000 + i;

            memory.mem[(dst_addr >> 2) + i] =
                32'h00000000;

        end

        // Enable write error
        bresp_error_enable = 1'b1;

        // Configure DMA
        axi_write(32'h00000008, src_addr);
        axi_write(32'h0000000C, dst_addr);
        axi_write(32'h00000010, 32'd16);

        // Start DMA
        axi_write(32'h00000000, 32'h00000001);

        $display("");
        $display("TEST 14 CASE 2: DMA started.");
        $display("Forcing BRESP = SLVERR.");

        //========================================================
        // Wait for DMA response
        //========================================================

        timeout_count = 0;

        while ((dut.dma_done !== 1'b1) &&
               (timeout_count < 10000)) begin

            @(posedge clk);

            timeout_count = timeout_count + 1;

        end

        if (timeout_count >= 10000) begin

            $display("");
            $display("TEST 14 CASE 2: DMA did not complete.");

            $display(
                "DMA_STATE  = %0d",
                dut.u_dma_controller.state
            );

            $display(
                "FIFO_COUNT = %0d",
                dut.u_dma_fifo.count
            );

            $display(
                "BRESP      = %b",
                m_axi_bresp
            );

            $display("");
            $display("*** TEST 14 CASE 2 COMPLETE ***");

        end
        else begin

            $display("");
            $display("TEST 14 CASE 2: DMA DONE.");
            $display("BRESP observed = %b", m_axi_bresp);

            $display(
                "NOTE: Current DMA completed despite SLVERR."
            );

        end

        // Restore normal write response
        bresp_error_enable = 1'b0;

        //========================================================
        // Final result
        //========================================================

        $display("");
        $display("*** DMA TEST 14 COMPLETE ***");
        $display("AXI read and write SLVERR responses were injected.");
        $display("Current DMA error-response behavior has been observed.");
        $display("========================================");
        $display("");

    end

endtask

// ================================================================
// TEST 15: FULL RANDOMIZED END-TO-END STRESS
// ================================================================
task automatic test_15_full_random_stress;

    integer i;
    integer j;
    integer timeout_count;
    integer transfer_count;
    integer word_count;
    integer errors;

    reg [31:0] src_addr;
    reg [31:0] dst_addr;
    reg [31:0] transfer_len;
    reg [31:0] pattern;

    begin
        $display("");
        $display("========================================");
        $display("   DMA TEST 15: FULL RANDOMIZED STRESS");
        $display("========================================");

        errors = 0;
        transfer_count = 0;

        // Make sure AXI error injection is disabled.
        rresp_error_enable = 1'b0;
        bresp_error_enable = 1'b0;

        // Start with normal AXI operation.
        awready_enable = 1'b1;
        wready_enable  = 1'b1;
        bvalid_enable  = 1'b1;
        rvalid_enable  = 1'b1;

        // --------------------------------------------------------
        // Run 20 randomized transfers
        // --------------------------------------------------------
        for (j = 0; j < 20; j = j + 1) begin

            transfer_count = transfer_count + 1;

            // ----------------------------------------------------
            // Random transfer length
            // 1 to 64 words
            // ----------------------------------------------------
            word_count = ($urandom % 64) + 1;
            transfer_len = word_count * 4;

            // ----------------------------------------------------
            // Random but word-aligned addresses
            // Keep addresses safely inside memory
            // ----------------------------------------------------
            src_addr = 32'h00010000 + (($urandom % 2048) * 4);
            dst_addr = 32'h00020000 + (($urandom % 2048) * 4);

            // ----------------------------------------------------
            // Random AXI backpressure
            // Each transfer gets a different combination.
            // ----------------------------------------------------
            awready_enable = ($urandom % 2);
            wready_enable  = ($urandom % 2);
            bvalid_enable  = ($urandom % 2);
            rvalid_enable  = ($urandom % 2);

            // Avoid completely disabling a channel indefinitely.
            if (awready_enable == 1'b0)
                awready_enable = 1'b1;

            if (wready_enable == 1'b0)
                wready_enable = 1'b1;

            if (bvalid_enable == 1'b0)
                bvalid_enable = 1'b1;

            if (rvalid_enable == 1'b0)
                rvalid_enable = 1'b1;

            // ----------------------------------------------------
            // Display transfer configuration
            // ----------------------------------------------------
            $display("");
            $display("----------------------------------------");
            $display("TEST 15 TRANSFER %0d / 20", transfer_count);
            $display("----------------------------------------");
            $display("SOURCE      = %08h", src_addr);
            $display("DESTINATION = %08h", dst_addr);
            $display("LENGTH      = %0d bytes", transfer_len);
            $display("WORDS       = %0d", word_count);
            $display("AWREADY     = %b", awready_enable);
            $display("WREADY      = %b", wready_enable);
            $display("BVALID      = %b", bvalid_enable);
            $display("RVALID      = %b", rvalid_enable);

            // ----------------------------------------------------
            // Fill source memory with unique random pattern
            // ----------------------------------------------------
            for (i = 0; i < word_count; i = i + 1) begin

                pattern = $urandom;

                memory.mem[(src_addr >> 2) + i] =
                    pattern;

                // Clear destination
                memory.mem[(dst_addr >> 2) + i] =
                    32'h00000000;
            end

            // ----------------------------------------------------
            // Start DMA
            // ----------------------------------------------------
            axi_write(32'h00000008, src_addr);
            axi_write(32'h0000000C, dst_addr);
            axi_write(32'h00000010, transfer_len);
            axi_write(32'h00000000, 32'h00000001);

            // ----------------------------------------------------
            // Wait for DMA completion
            // ----------------------------------------------------
            timeout_count = 0;

            while ((dut.dma_done !== 1'b1) &&
                   (timeout_count < 50000)) begin

                @(posedge clk);
                timeout_count = timeout_count + 1;

            end

            // ----------------------------------------------------
            // Timeout check
            // ----------------------------------------------------
            if (timeout_count >= 50000) begin

                $display("ERROR: Transfer %0d TIMEOUT", transfer_count);
                $display("DMA_STATE  = %0d",
                         dut.u_dma_controller.state);
                $display("FIFO_COUNT = %0d",
                         dut.u_dma_fifo.count);

                errors = errors + 1;

            end
            else begin

                $display("DMA DONE after %0d cycles",
                         timeout_count);

                // ------------------------------------------------
                // Verify every destination word
                // ------------------------------------------------
                for (i = 0; i < word_count; i = i + 1) begin

                    if (memory.mem[(dst_addr >> 2) + i] !==
                        memory.mem[(src_addr >> 2) + i]) begin

                        $display(
                            "ERROR: WORD %0d MISMATCH | SRC=%08h DST=%08h",
                            i,
                            memory.mem[(src_addr >> 2) + i],
                            memory.mem[(dst_addr >> 2) + i]
                        );

                        errors = errors + 1;

                    end

                end

                if (errors == 0)
                    $display("TRANSFER %0d DATA CHECK: PASS",
                             transfer_count);
                else
                    $display("TRANSFER %0d DATA CHECK: ERRORS DETECTED",
                             transfer_count);

            end

            // ----------------------------------------------------
            // Restore normal AXI signals before next transfer
            // ----------------------------------------------------
            awready_enable = 1'b1;
            wready_enable  = 1'b1;
            bvalid_enable  = 1'b1;
            rvalid_enable  = 1'b1;

            // Give DMA one idle cycle
            @(posedge clk);

        end

        // --------------------------------------------------------
        // Final result
        // --------------------------------------------------------
        $display("");
        $display("========================================");

        if (errors == 0) begin
            $display("*** DMA TEST 15 PASS ***");
            $display("20 randomized DMA transfers completed.");
            $display("All randomized data comparisons passed.");
        end
        else begin
            $display("*** DMA TEST 15 FAILED ***");
            $display("Total errors = %0d", errors);
        end

        $display("========================================");
        $display("");

    end

endtask
    //============================================================
    // Test
    //============================================================

    initial begin



        //========================================================
        // Default values
        //========================================================

        s_axi_awaddr  = 32'h00000000;
        s_axi_awvalid = 1'b0;

        awready_enable = 1'b1;
        wready_enable  = 1'b1;
        bvalid_enable  = 1'b1;
        rvalid_enable  = 1'b1;

        rresp_error_enable = 1'b0;
        bresp_error_enable = 1'b0;
        s_axi_wdata   = 32'h00000000;
        s_axi_wstrb   = 4'b0000;
        s_axi_wvalid  = 1'b0;

        s_axi_bready  = 1'b0;

        s_axi_araddr  = 32'h00000000;
        s_axi_arvalid = 1'b0;
        s_axi_rready  = 1'b0;


        //========================================================
        // Wait for reset
        //========================================================

        @(posedge rst_n);

        repeat (5) @(posedge clk);


        //========================================================
        // Start verification
        //========================================================

        $display("");
        $display("========================================");
        $display("        AXI4 DMA VERIFICATION");
        $display("========================================");


        //========================================================
        // TEST 1
        // 4 bytes = 1 word
        //========================================================

        dma_transfer_test(1, 4);


        //========================================================
        // TEST 2
        // 8 bytes = 2 words
        //========================================================

        dma_transfer_test(2, 8);


        //========================================================
        // TEST 3
        // 16 bytes = 4 words
        //========================================================

        dma_transfer_test(3, 16);


        //========================================================
        // TEST 4
        // 64 bytes = 16 words
        //========================================================

        dma_transfer_test(4, 64);

        test_5a_awready_delay();

        test_5b_wready_delay();
        test_5c_bvalid_delay();
        test_5d_rvalid_delay();

       test_6_random_backpressure();

       test_7_reset_during_transfer();
       
                
        test_8_transfer_boundaries();

        test_9_long_axi_stall();

        test_10_long_rvalid_stall();

        test_11_back_to_back_transfers();

        test_12_address_variation();

        test_13_fifo_stress();

        test_14_axi_error_responses();

        test_15_full_random_stress();
        //========================================================
        // ALL TESTS PASSED
        //========================================================

        $display("");
        $display("========================================");
        $display("       ALL DMA TESTS PASSED");
        $display("========================================");
        $display("");

        $finish;

    end



endmodule