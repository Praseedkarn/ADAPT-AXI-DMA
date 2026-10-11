read_liberty /home/praseed/.ciel/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_db physical_design/results/axi4_dma_routed.odb

set block [ord::get_db_block]
set inst [$block findInst u_dma_controller/_960_]

if {$inst == "NULL"} {
    puts "ERROR: Instance not found"
} else {
    puts "Instance: [$inst getName]"
    puts "Cell: [[$inst getMaster] getName]"
    puts "Connected ITerms:"

    foreach iterm [$inst getITerms] {
        set net [$iterm getNet]

        if {$net != "NULL"} {
            puts "  Pin: [[$iterm getMTerm] getName] -> Net: [$net getName]"
        } else {
            puts "  Pin: [[$iterm getMTerm] getName] -> Net: unconnected"
        }
    }
}
