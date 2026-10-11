# ============================================================
# AXI4 DMA - OPENROAD INITIALIZATION
# ============================================================

set TECH_LEF "/home/praseed/.ciel/ciel/sky130/versions/1689ac3f2dc763876eaf967227c7dfe831b031ae/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef"

set CELL_LEF "/home/praseed/.ciel/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef"

set LIB "/home/praseed/.ciel/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

set NETLIST "physical_design/results/axi4_dma_synth.v"

set SDC "physical_design/constraints/axi4_dma.sdc"

# Technology
read_lef $TECH_LEF
read_lef $CELL_LEF

# Timing library
read_liberty $LIB

# Netlist
read_verilog $NETLIST
link_design axi4_dma_top

# Constraints
read_sdc $SDC

puts "============================================================"
puts " AXI4 DMA OPENROAD INITIALIZATION"
puts "============================================================"
puts "TOP DESIGN: axi4_dma_top"
puts "DESIGN LINKED SUCCESSFULLY"

report_checks -path_delay max -digits 3

write_db physical_design/results/axi4_dma_init.odb

puts "============================================================"
puts " INITIALIZATION COMPLETE"
puts " DATABASE SAVED"
puts "============================================================"
