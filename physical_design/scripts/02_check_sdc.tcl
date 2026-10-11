read_liberty /home/praseed/.ciel/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

read_verilog physical_design/results/axi4_dma_synth.v

link_design axi4_dma_top

read_sdc physical_design/constraints/axi4_dma.sdc

report_clock_properties
report_checks -path_delay max