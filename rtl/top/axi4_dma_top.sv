module axi4_dma_top #(
    parameter ADDR_WIDTH = 32 ,
    parameter DATA_WIDTH = 32
)(
    input logic clk ,
    input logic rst_n,

    //============================================================
    // AXI4-Lite Slave Interface
    //============================================================

    input  logic [ADDR_WIDTH-1:0] s_axi_awaddr,
    input  logic                  s_axi_awvalid,
    output logic                  s_axi_awready,

    input  logic [DATA_WIDTH-1:0] s_axi_wdata,
    input  logic [DATA_WIDTH/8-1:0] s_axi_wstrb,
    input  logic                  s_axi_wvalid,
    output logic                  s_axi_wready,

    output logic [1:0]            s_axi_bresp,
    output logic                  s_axi_bvalid,
    input  logic                  s_axi_bready,

    input  logic [ADDR_WIDTH-1:0] s_axi_araddr,
    input  logic                  s_axi_arvalid,
    output logic                  s_axi_arready,

    output logic [DATA_WIDTH-1:0] s_axi_rdata,
    output logic [1:0]            s_axi_rresp,
    output logic                  s_axi_rvalid,
    input  logic                  s_axi_rready,

    //============================================================
    // AXI4 Master Read Interface
    //============================================================

    output logic [ADDR_WIDTH-1:0] m_axi_araddr,
    output logic [7:0]            m_axi_arlen,
    output logic [2:0]            m_axi_arsize,
    output logic [1:0]            m_axi_arburst,
    output logic                  m_axi_arvalid,
    input  logic                  m_axi_arready,

    input  logic [DATA_WIDTH-1:0] m_axi_rdata,
    input  logic [1:0]            m_axi_rresp,
    input  logic                  m_axi_rlast,
    input  logic                  m_axi_rvalid,
    output logic                  m_axi_rready,

    //============================================================
    // AXI4 Master Write Interface
    //============================================================

    output logic [ADDR_WIDTH-1:0] m_axi_awaddr,
    output logic [7:0]            m_axi_awlen,
    output logic [2:0]            m_axi_awsize,
    output logic [1:0]            m_axi_awburst,
    output logic                  m_axi_awvalid,
    input  logic                  m_axi_awready,

    output logic [DATA_WIDTH-1:0] m_axi_wdata,
    output logic [DATA_WIDTH/8-1:0] m_axi_wstrb,
    output logic                  m_axi_wlast,
    output logic                  m_axi_wvalid,
    input  logic                  m_axi_wready,

    input  logic [1:0]            m_axi_bresp,
    input  logic                  m_axi_bvalid,
    output logic                  m_axi_bready

);

     //============================================================
    // Internal Register Interface
    //============================================================

    logic                  reg_write_en;
    logic [ADDR_WIDTH-1:0] reg_write_addr;
    logic [DATA_WIDTH-1:0] reg_write_data;

    logic                  reg_read_en;
    logic [ADDR_WIDTH-1:0] reg_read_addr;
    logic [DATA_WIDTH-1:0] reg_read_data;


    //============================================================
    // DMA Register Signals
    //============================================================

    logic [ADDR_WIDTH-1:0] source_addr;
    logic [ADDR_WIDTH-1:0] dest_addr;
    logic [31:0]           transfer_length;
    logic                  dma_start;

    logic                  dma_busy;
    logic                  dma_done;

    //============================================================
    // DMA Controller Signals
    //============================================================

    logic                  read_request;
    logic                  write_request;

    logic                  read_done;
    logic                  write_done;

    logic [ADDR_WIDTH-1:0] current_source_addr;
    logic [ADDR_WIDTH-1:0] current_dest_addr;


    //============================================================
    // Read Master Signals
    //============================================================

    logic [DATA_WIDTH-1:0] read_data;
    logic                  read_valid;

    //============================================================
    // FIFO Signals
    //============================================================

    logic [DATA_WIDTH-1:0] fifo_rd_data;
    logic                  fifo_full;
    logic                  fifo_empty;
    logic [2:0]            fifo_count;

    logic                  fifo_wr_en;
    logic                  fifo_rd_en;
    logic                  write_data_ready;

    //============================================================
    // AXI4-Lite Slave
    //============================================================

    axi4_lite_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_axi4_lite_slave (

        .clk(clk),
        .rst_n(rst_n),

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

        .reg_write_en(reg_write_en),
        .reg_write_addr(reg_write_addr),
        .reg_write_data(reg_write_data),

        .reg_read_en(reg_read_en),
        .reg_read_addr(reg_read_addr),
        .reg_read_data(reg_read_data)
    );
    //============================================================
    // DMA Registers
    //============================================================

    dma_registers #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_dma_registers (

        .clk(clk),
        .rst_n(rst_n),

        .reg_write_en(reg_write_en),
        .reg_write_addr(reg_write_addr),
        .reg_write_data(reg_write_data),

        .reg_read_en(reg_read_en),
        .reg_read_addr(reg_read_addr),
        .reg_read_data(reg_read_data),

        .dma_busy(dma_busy),
        .dma_done(dma_done),

        .source_addr(source_addr),
        .dest_addr(dest_addr),
        .transfer_length(transfer_length),
        .dma_start(dma_start)
    );

    //============================================================
    // DMA Controller
    //============================================================

    dma_controller #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_dma_controller (

        .clk(clk),
        .rst_n(rst_n),

        .dma_start(dma_start),
        .source_addr(source_addr),
        .dest_addr(dest_addr),
        .transfer_length(transfer_length),

        .read_done(read_done),
        .write_done(write_done),

        .read_request(read_request),
        .write_request(write_request),

        .current_source_addr(current_source_addr),
        .current_dest_addr(current_dest_addr),

        .dma_busy(dma_busy),
        .dma_done(dma_done)
    );

    //============================================================
    // AXI4 Read Master
    //============================================================

    axi4_read_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_axi4_read_master (

        .clk(clk),
        .rst_n(rst_n),

        .read_addr(current_source_addr),
        .read_request(read_request),

        .read_done(read_done),
        .read_data(read_data),
        .read_valid(read_valid),

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
        .m_axi_rready(m_axi_rready)
    );

    //============================================================
    // FIFO
    //============================================================

    dma_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(4)
    ) u_dma_fifo (

        .clk(clk),
        .rst_n(rst_n),

        .wr_data(read_data),
        .wr_en(fifo_wr_en),

        .rd_data(fifo_rd_data),
        .rd_en(fifo_rd_en),

        .full(fifo_full),
        .empty(fifo_empty),
        .count(fifo_count)
    );

    // Read data enters FIFO when AXI read completes.
  assign fifo_wr_en = read_valid && !fifo_full;

    // FIFO data is consumed when AXI W channel handshakes.
assign fifo_rd_en = write_data_ready;
    //============================================================
    // AXI4 Write Master
    //============================================================

    axi4_write_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_axi4_write_master (

        .clk(clk),
        .rst_n(rst_n),

        .write_addr(current_dest_addr),
        .write_request(write_request),

        .write_done(write_done),

        .write_data(fifo_rd_data),
        .write_data_valid(!fifo_empty),
        .write_data_ready(write_data_ready),

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

endmodule