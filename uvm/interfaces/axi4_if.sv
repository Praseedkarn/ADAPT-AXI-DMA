interface axi4_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input logic clk,
    input logic rst_n
);

    //============================================================
    // AXI4 READ ADDRESS CHANNEL
    //============================================================

    logic [ADDR_WIDTH-1:0] araddr;
    logic [7:0]            arlen;
    logic [2:0]            arsize;
    logic [1:0]            arburst;
    logic                  arvalid;
    logic                  arready;

    //============================================================
    // AXI4 READ DATA CHANNEL
    //============================================================

    logic [DATA_WIDTH-1:0] rdata;
    logic [1:0]            rresp;
    logic                  rlast;
    logic                  rvalid;
    logic                  rready;

    //============================================================
    // AXI4 WRITE ADDRESS CHANNEL
    //============================================================

    logic [ADDR_WIDTH-1:0] awaddr;
    logic [7:0]            awlen;
    logic [2:0]            awsize;
    logic [1:0]            awburst;
    logic                  awvalid;
    logic                  awready;

    //============================================================
    // AXI4 WRITE DATA CHANNEL
    //============================================================

    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH/8-1:0] wstrb;
    logic                  wlast;
    logic                  wvalid;
    logic                  wready;

    //============================================================
    // AXI4 WRITE RESPONSE CHANNEL
    //============================================================

    logic [1:0] bresp;
    logic       bvalid;
    logic       bready;


    //============================================================
    // AXI4 SLAVE MODPORT
    //
    // This is the important side for our UVM memory agent.
    //
    // DUT = AXI4 Master
    // UVM = AXI4 Slave
    //============================================================

    modport slave (
        input  clk,
        input  rst_n,

        input  araddr,
        input  arlen,
        input  arsize,
        input  arburst,
        input  arvalid,
        output arready,

        output rdata,
        output rresp,
        output rlast,
        output rvalid,
        input  rready,

        input awaddr,
        input awlen,
        input awsize,
        input awburst,
        input awvalid,
        output awready,

        input wdata,
        input wstrb,
        input wlast,
        input wvalid,
        output wready,

        output bresp,
        output bvalid,
        input bready
    );


    //============================================================
    // AXI4 MASTER MODPORT
    //
    // Useful if we later want a UVM AXI master agent.
    //============================================================

    modport master (
        input  clk,
        input  rst_n,

        output araddr,
        output arlen,
        output arsize,
        output arburst,
        output arvalid,
        input arready,

        input rdata,
        input rresp,
        input rlast,
        input rvalid,
        output rready,

        output awaddr,
        output awlen,
        output awsize,
        output awburst,
        output awvalid,
        input awready,

        output wdata,
        output wstrb,
        output wlast,
        output wvalid,
        input wready,

        input bresp,
        input bvalid,
        output bready
    );

endinterface