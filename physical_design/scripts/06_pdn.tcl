# ============================================================
# AXI4 DMA - POWER DISTRIBUTION NETWORK
# ============================================================

read_db physical_design/results/axi4_dma_tapcells.odb

puts "============================================================"
puts " AXI4 DMA POWER DISTRIBUTION NETWORK"
puts "============================================================"

# ------------------------------------------------------------
# Global power connections
# ------------------------------------------------------------

add_global_connection -net VDD -inst_pattern {.*} -pin_pattern {^VDD$} -power
add_global_connection -net VDD -inst_pattern {.*} -pin_pattern {^VDDCE$}
add_global_connection -net VDD -inst_pattern {.*} -pin_pattern {^VPWR$}
add_global_connection -net VDD -inst_pattern {.*} -pin_pattern {^VPB$}

add_global_connection -net VSS -inst_pattern {.*} -pin_pattern {^VSS$} -ground
add_global_connection -net VSS -inst_pattern {.*} -pin_pattern {^VSSE$}
add_global_connection -net VSS -inst_pattern {.*} -pin_pattern {^VGND$}
add_global_connection -net VSS -inst_pattern {.*} -pin_pattern {^VNB$}

global_connect

puts "GLOBAL POWER CONNECTIONS COMPLETE"

# ------------------------------------------------------------
# Voltage domain
# ------------------------------------------------------------

set_voltage_domain \
    -name CORE \
    -power VDD \
    -ground VSS

puts "VOLTAGE DOMAIN CREATED"

# ------------------------------------------------------------
# Standard-cell PDN grid
# ------------------------------------------------------------

define_pdn_grid \
    -name grid \
    -voltage_domains CORE \
    -pins {met5}

# Standard-cell power rails
add_pdn_stripe \
    -grid grid \
    -layer met1 \
    -width 0.48 \
    -pitch 5.44 \
    -offset 0 \
    -followpins

# Horizontal/vertical upper-level straps
add_pdn_stripe \
    -grid grid \
    -layer met4 \
    -width 1.60 \
    -pitch 27.14 \
    -offset 13.57

add_pdn_stripe \
    -grid grid \
    -layer met5 \
    -width 1.60 \
    -pitch 27.20 \
    -offset 13.60

# Connect PDN layers
add_pdn_connect \
    -grid grid \
    -layers {met1 met4}

add_pdn_connect \
    -grid grid \
    -layers {met4 met5}

puts "PDN GRID DEFINED"

# ------------------------------------------------------------
# Generate PDN
# ------------------------------------------------------------

pdngen

puts "============================================================"
puts " PDN GENERATION COMPLETE"
puts "============================================================"

write_db physical_design/results/axi4_dma_pdn.odb

puts "PDN DATABASE SAVED"
puts "============================================================"
