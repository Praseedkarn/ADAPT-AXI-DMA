
# ============================================================
# AXI4 DMA - PLACEMENT
# ============================================================

set LIB "/home/praseed/.ciel/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

read_liberty $LIB
read_db physical_design/results/axi4_dma_pdn.odb

puts "============================================================"
puts " AXI4 DMA PLACEMENT"
puts "============================================================"

# ------------------------------------------------------------
# Sky130 routing tracks
# ------------------------------------------------------------

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

puts "SKY130 ROUTING TRACKS CREATED"

# ------------------------------------------------------------
# Routing RC
# ------------------------------------------------------------

set_wire_rc -layer met3

# ------------------------------------------------------------
# IO PIN PLACEMENT
# ------------------------------------------------------------

place_pins \
    -hor_layers met3 \
    -ver_layers met2 \
    -corner_avoidance 5 \
    -min_distance 2 \
    -annealing

puts "IO PIN PLACEMENT COMPLETE"

# ------------------------------------------------------------
# Global placement
# ------------------------------------------------------------

global_placement \
    -density 0.60

puts "GLOBAL PLACEMENT COMPLETE"

# ------------------------------------------------------------
# Detailed placement
# ------------------------------------------------------------

detailed_placement

puts "DETAILED PLACEMENT COMPLETE"

# ------------------------------------------------------------
# Placement legality
# ------------------------------------------------------------

check_placement

puts "PLACEMENT CHECK COMPLETE"

# ------------------------------------------------------------
# Save
# ------------------------------------------------------------

write_db physical_design/results/axi4_dma_placement.odb

puts "============================================================"
puts " PLACEMENT DATABASE SAVED"
puts "============================================================"
