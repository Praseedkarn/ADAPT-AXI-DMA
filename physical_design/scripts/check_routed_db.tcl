set LIB "/home/praseed/.ciel/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

read_liberty $LIB
read_db physical_design/results/axi4_dma_routed.odb

puts "ROUTED DATABASE LOADED SUCCESSFULLY"
