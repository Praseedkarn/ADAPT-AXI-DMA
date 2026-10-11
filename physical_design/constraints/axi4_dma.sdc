# ============================================================
# AXI4 DMA - SYNTHESIS / PHYSICAL DESIGN CONSTRAINTS
# ============================================================

# ------------------------------------------------------------
# Clock
# ------------------------------------------------------------

create_clock -name clk -period 10.0 [get_ports clk]

set_clock_uncertainty 0.20 [get_clocks clk]

# ------------------------------------------------------------
# Input delays
# ------------------------------------------------------------

set_input_delay 2.0 -clock clk [get_ports s_axi_awaddr]
set_input_delay 2.0 -clock clk [get_ports s_axi_awvalid]
set_input_delay 2.0 -clock clk [get_ports s_axi_wdata]
set_input_delay 2.0 -clock clk [get_ports s_axi_wstrb]
set_input_delay 2.0 -clock clk [get_ports s_axi_wvalid]
set_input_delay 2.0 -clock clk [get_ports s_axi_bready]
set_input_delay 2.0 -clock clk [get_ports s_axi_araddr]
set_input_delay 2.0 -clock clk [get_ports s_axi_arvalid]
set_input_delay 2.0 -clock clk [get_ports s_axi_rready]

set_input_delay 2.0 -clock clk [get_ports m_axi_arready]
set_input_delay 2.0 -clock clk [get_ports m_axi_rdata]
set_input_delay 2.0 -clock clk [get_ports m_axi_rresp]
set_input_delay 2.0 -clock clk [get_ports m_axi_rlast]
set_input_delay 2.0 -clock clk [get_ports m_axi_rvalid]
set_input_delay 2.0 -clock clk [get_ports m_axi_awready]
set_input_delay 2.0 -clock clk [get_ports m_axi_wready]
set_input_delay 2.0 -clock clk [get_ports m_axi_bresp]
set_input_delay 2.0 -clock clk [get_ports m_axi_bvalid]

# ------------------------------------------------------------
# Output delays
# ------------------------------------------------------------

set_output_delay 2.0 -clock clk [get_ports s_axi_awready]
set_output_delay 2.0 -clock clk [get_ports s_axi_wready]
set_output_delay 2.0 -clock clk [get_ports s_axi_bresp]
set_output_delay 2.0 -clock clk [get_ports s_axi_bvalid]
set_output_delay 2.0 -clock clk [get_ports s_axi_arready]
set_output_delay 2.0 -clock clk [get_ports s_axi_rdata]
set_output_delay 2.0 -clock clk [get_ports s_axi_rresp]
set_output_delay 2.0 -clock clk [get_ports s_axi_rvalid]

set_output_delay 2.0 -clock clk [get_ports m_axi_araddr]
set_output_delay 2.0 -clock clk [get_ports m_axi_arlen]
set_output_delay 2.0 -clock clk [get_ports m_axi_arsize]
set_output_delay 2.0 -clock clk [get_ports m_axi_arburst]
set_output_delay 2.0 -clock clk [get_ports m_axi_arvalid]
set_output_delay 2.0 -clock clk [get_ports m_axi_rready]
set_output_delay 2.0 -clock clk [get_ports m_axi_awaddr]
set_output_delay 2.0 -clock clk [get_ports m_axi_awlen]
set_output_delay 2.0 -clock clk [get_ports m_axi_awsize]
set_output_delay 2.0 -clock clk [get_ports m_axi_awburst]
set_output_delay 2.0 -clock clk [get_ports m_axi_awvalid]
set_output_delay 2.0 -clock clk [get_ports m_axi_wdata]
set_output_delay 2.0 -clock clk [get_ports m_axi_wstrb]
set_output_delay 2.0 -clock clk [get_ports m_axi_wlast]
set_output_delay 2.0 -clock clk [get_ports m_axi_wvalid]
set_output_delay 2.0 -clock clk [get_ports m_axi_bready]

# ------------------------------------------------------------
# Asynchronous reset
# ------------------------------------------------------------

set_false_path -from [get_ports rst_n]
