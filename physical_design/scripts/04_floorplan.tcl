# ============================================================
# AXI4 DMA - FLOORPLAN
# ============================================================

read_db physical_design/results/axi4_dma_init.odb

puts "============================================================"
puts " AXI4 DMA FLOORPLAN"
puts "============================================================"

initialize_floorplan \
    -utilization 40 \
    -aspect_ratio 1.0 \
    -core_space 5 \
    -site unithd

puts "FLOORPLAN INITIALIZED"
puts "UTILIZATION: 50%"
puts "ASPECT RATIO: 1.0"
puts "CORE SPACE: 5 um"
puts "SITE: unithd"

write_db physical_design/results/axi4_dma_floorplan.odb

puts "============================================================"
puts " FLOORPLAN DATABASE SAVED"
puts "============================================================"
