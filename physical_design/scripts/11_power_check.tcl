read_lef /home/praseed/.ciel/ciel/sky130/versions/1689ac3f2dc763876eaf967227c7dfe831b031ae/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef
read_lef /home/praseed/.ciel/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef
read_liberty /home/praseed/.ciel/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

read_db physical_design/results/axi4_dma_routed.odb

puts "\n===== POWER GRID CONNECTIVITY CHECK ====="
check_power_grid -net VDD
check_power_grid -net VSS

puts "\n===== POWER CHECK COMPLETE ====="
