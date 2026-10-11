# ============================================================
# AXI4 DMA - POST-ROUTE TIMING ANALYSIS
# ============================================================

set LIB "/home/praseed/.ciel/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
set SDC "physical_design/constraints/axi4_dma.sdc"
set DB  "physical_design/results/axi4_dma_routed.odb"

read_liberty $LIB
read_db $DB
read_sdc $SDC

puts "\n===== CLOCK INFORMATION ====="
report_checks -path_delay max -group_count 1 -digits 3

puts "\n===== ESTIMATING ROUTED INTERCONNECT PARASITICS ====="
estimate_parasitics -global_routing

puts "\n===== PROPAGATED CLOCK ====="
set_propagated_clock [all_clocks]

puts "\n===== SETUP TIMING ====="
report_checks \
    -path_delay max \
    -format full_clock_expanded \
    -fields {slew cap fanout} \
    -group_count 10 \
    -digits 3 \
    > physical_design/reports/post_route_setup.rpt

puts "\n===== HOLD TIMING ====="
report_checks \
    -path_delay min \
    -format full_clock_expanded \
    -fields {slew cap fanout} \
    -group_count 10 \
    -digits 3 \
    > physical_design/reports/post_route_hold.rpt

puts "\n===== TIMING SUMMARY ====="
report_worst_slack -max
report_worst_slack -min

puts "\n===== POST-ROUTE STA COMPLETE ====="
