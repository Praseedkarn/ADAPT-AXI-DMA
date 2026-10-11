read_liberty /home/praseed/.ciel/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_db physical_design/results/axi4_dma_routed.odb

set block [ord::get_db_block]
set inst [$block findInst u_dma_controller/_960_]

if {$inst == "NULL"} {
    puts "ERROR: Instance not found"
} else {
    set master [$inst getMaster]
    set origin [$inst getOrigin]

    puts "Instance: [$inst getName]"
    puts "Master cell: [$master getName]"
    puts "Origin (DBU): $origin"
    puts "Cell width (DBU): [$master getWidth]"
    puts "Cell height (DBU): [$master getHeight]"
    puts "Placement status: [$inst getPlacementStatus]"
}
