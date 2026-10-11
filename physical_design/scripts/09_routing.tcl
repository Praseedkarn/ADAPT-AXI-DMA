# ============================================================
# AXI4 DMA - ROUTING
# ============================================================

set LIB "/home/praseed/.ciel/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

read_liberty $LIB
read_db physical_design/results/axi4_dma_cts.odb

puts "============================================================"
puts " AXI4 DMA ROUTING"
puts "============================================================"

# ------------------------------------------------------------
# Sky130 routing tracks
# ------------------------------------------------------------

make_tracks li1 \
    -x_pitch 1.3 \
    -y_pitch 1.3 \
    -x_offset 0.0 \
    -y_offset 0.0

make_tracks met1 \
    -x_pitch 1.3 \
    -y_pitch 1.3 \
    -x_offset 0.0 \
    -y_offset 0.0

make_tracks met2 \
    -x_pitch 1.4 \
    -y_pitch 1.4 \
    -x_offset 0.0 \
    -y_offset 0.0

make_tracks met3 \
    -x_pitch 1.3 \
    -y_pitch 1.3 \
    -x_offset 0.0 \
    -y_offset 0.0

make_tracks met4 \
    -x_pitch 1.4 \
    -y_pitch 1.4 \
    -x_offset 0.0 \
    -y_offset 0.0

make_tracks met5 \
    -x_pitch 1.4 \
    -y_pitch 1.4 \
    -x_offset 0.0 \
    -y_offset 0.0

puts "SKY130 ROUTING TRACKS CREATED"

# ------------------------------------------------------------
# Routing RC
# ------------------------------------------------------------

set_wire_rc -layer met3

puts "ROUTING RC CONFIGURED"

# ------------------------------------------------------------
# Global routing
# ------------------------------------------------------------

global_route \
    -guide_file physical_design/results/axi4_dma_route.guide \
    -congestion_iterations 50

puts "GLOBAL ROUTING COMPLETE"

# ------------------------------------------------------------
# Detailed routing
# ------------------------------------------------------------

detailed_route \
    -droute_end_iter 1 \
    -output_drc physical_design/reports/routing_drc.rpt \
    -output_maze physical_design/reports/routing_maze.log

puts "DETAILED ROUTING COMPLETE"

# ------------------------------------------------------------
# Save routed database
# ------------------------------------------------------------

write_db physical_design/results/axi4_dma_routed.odb

puts "============================================================"
puts " ROUTING DATABASE SAVED"
puts "============================================================"
