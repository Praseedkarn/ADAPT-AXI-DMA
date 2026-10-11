# ============================================================
# AXI4 DMA - TAPCELL INSERTION
# ============================================================

read_db physical_design/results/axi4_dma_floorplan.odb

puts "============================================================"
puts " AXI4 DMA TAPCELL INSERTION"
puts "============================================================"

tapcell \
    -tapcell_master sky130_fd_sc_hd__tapvpwrvgnd_1 \
    -distance 14.0

puts "TAPCELL INSERTION COMPLETE"

write_db physical_design/results/axi4_dma_tapcells.odb

puts "============================================================"
puts " TAPCELL DATABASE SAVED"
puts "============================================================"
