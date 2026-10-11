set LIB "/home/praseed/.ciel/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

read_liberty $LIB
read_db physical_design/results/axi4_dma_routed.odb

puts "========== ROUTED DESIGN =========="
puts "Top design: [ord::get_db_block]"

puts "========== TARGET NET =========="
report_net -connections m_axi_awaddr[28]

puts "========== TARGET CELL =========="
report_checks -path_delay max -format full_clock_expanded -fields {slew cap fanout}
