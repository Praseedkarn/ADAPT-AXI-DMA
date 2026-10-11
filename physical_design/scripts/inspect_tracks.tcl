read_lef /home/praseed/.ciel/ciel/sky130/versions/1689ac3f2dc763876eaf967227c7dfe831b031ae/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef
read_lef /home/praseed/.ciel/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef
read_liberty /home/praseed/.ciel/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_db physical_design/results/axi4_dma_routed.odb

set block [ord::get_db_block]
set tech [$block getTech]

foreach name {li1 met1 met2 met3 met4 met5} {
    set layer [$tech findLayer $name]
    if {$layer == "NULL"} {
        puts "$name: LAYER NOT FOUND"
    } else {
        puts "$name: layer loaded"
    }
}
