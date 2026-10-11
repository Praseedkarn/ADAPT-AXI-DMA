# ============================================================
# AXI4 DMA - CLOCK TREE SYNTHESIS
# ============================================================

set LIB "/home/praseed/.ciel/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
set SDC "physical_design/constraints/axi4_dma.sdc"

read_liberty $LIB
read_db physical_design/results/axi4_dma_placement.odb
read_sdc $SDC

puts "============================================================"
puts " AXI4 DMA CLOCK TREE SYNTHESIS"
puts "============================================================"

# ------------------------------------------------------------
# Clock routing RC
# ------------------------------------------------------------

set_wire_rc -clock -layer met3

puts "CLOCK RC CONFIGURED"

# ------------------------------------------------------------
# Repair clock inverters before CTS
# ------------------------------------------------------------

repair_clock_inverters

puts "CLOCK INVERTERS REPAIRED"

# ------------------------------------------------------------
# Clock Tree Synthesis
# ------------------------------------------------------------

clock_tree_synthesis \
    -root_buf sky130_fd_sc_hd__clkbuf_16 \
    -buf_list {sky130_fd_sc_hd__clkbuf_8 sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_2} \
    -sink_clustering_enable \
    -sink_clustering_max_diameter 50

puts "CLOCK TREE SYNTHESIS COMPLETE"

# ------------------------------------------------------------
# Repair clock nets
# ------------------------------------------------------------

repair_clock_nets

puts "CLOCK NET REPAIR COMPLETE"

# ------------------------------------------------------------
# Legalize inserted clock buffers
# ------------------------------------------------------------

detailed_placement

puts "CLOCK BUFFER PLACEMENT COMPLETE"

# ------------------------------------------------------------
# Propagated clock
# ------------------------------------------------------------

set_propagated_clock [all_clocks]

puts "PROPAGATED CLOCK ENABLED"

# ------------------------------------------------------------
# CTS reports
# ------------------------------------------------------------

report_cts \
    -out_file physical_design/reports/cts_report.txt

report_clock_skew

report_checks \
    -path_delay max \
    -digits 3

report_checks \
    -path_delay min \
    -digits 3

# ------------------------------------------------------------
# Save CTS database
# ------------------------------------------------------------

write_db physical_design/results/axi4_dma_cts.odb

puts "============================================================"
puts " CTS DATABASE SAVED"
puts "============================================================"
