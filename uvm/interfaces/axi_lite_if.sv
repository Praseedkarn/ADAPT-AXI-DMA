interface axi_lite_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input logic clk,
    input logic rst_n
);

    //============================================================
    // AXI4-Lite WRITE ADDRESS CHANNEL
    //============================================================

    logic [ADDR_WIDTH-1:0] awaddr;
    logic                  awvalid;
    logic                  awready;

    //============================================================
    // AXI4-Lite WRITE DATA CHANNEL
    //============================================================

    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH/8-1:0] wstrb;
    logic                  wvalid;
    logic                  wready;

    //============================================================
    // AXI4-Lite WRITE RESPONSE CHANNEL
    //============================================================

    logic [1:0] bresp;
    logic       bvalid;
    logic       bready;

    //============================================================
    // AXI4-Lite READ ADDRESS CHANNEL
    //============================================================

    logic [ADDR_WIDTH-1:0] araddr;
    logic                  arvalid;
    logic                  arready;

    //============================================================
    // AXI4-Lite READ DATA CHANNEL
    //============================================================

    logic [DATA_WIDTH-1:0] rdata;
    logic [1:0]            rresp;
    logic                  rvalid;
    logic                  rready;


    //============================================================
    // UVM MASTER MODPORT
    //
    // UVM driver drives requests.
    // DUT drives responses.
    //============================================================

    modport master (
        input  clk,
        input  rst_n,

        output awaddr,
        output awvalid,
        input  awready,

        output wdata,
        output wstrb,
        output wvalid,
        input  wready,

        input  bresp,
        input  bvalid,
        output bready,

        output araddr,
        output arvalid,
        input  arready,

        input  rdata,
        input  rresp,
        input  rvalid,
        output rready
    );


    //============================================================
    // DUT SLAVE MODPORT
    //============================================================

    modport slave (
        input  clk,
        input  rst_n,

        input  awaddr,
        input  awvalid,
        output awready,

        input  wdata,
        input  wstrb,
        input  wvalid,
        output wready,

        output bresp,
        output bvalid,
        input  bready,

        input  araddr,
        input  arvalid,
        output arready,

        output rdata,
        output rresp,
        output rvalid,
        input  rready
    );

endinterface