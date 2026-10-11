set LIB "/home/praseed/.ciel/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

read_liberty $LIB
read_db physical_design/results/axi4_dma_cts.odb

make_tracks li1 -x_pitch 1.3 -y_pitch 1.3 -x_offset 0.0 -y_offset 0.0
make_tracks met1 -x_pitch 1.3 -y_pitch 1.3 -x_offset 0.0 -y_offset 0.0
make_tracks met2 -x_pitch 1.4 -y_pitch 1.4 -x_offset 0.0 -y_offset 0.0
make_tracks met3 -x_pitch 1.3 -y_pitch 1.3 -x_offset 0.0 -y_offset 0.0
make_tracks met4 -x_pitch 1.4 -y_pitch 1.4 -x_offset 0.0 -y_offset 0.0
make_tracks met5 -x_pitch 1.4 -y_pitch 1.4 -x_offset 0.0 -y_offset 0.0

set_wire_rc -layer met3

global_route \
    -guide_file /tmp/batch_test.guide \
    -congestion_iterations 50
