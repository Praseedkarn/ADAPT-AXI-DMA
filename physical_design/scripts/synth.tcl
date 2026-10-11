# ============================================================
# AXI4 DMA - SYNTHESIS
# ============================================================

read_verilog -sv physical_design/rtl/axi4_lite_slave.sv
read_verilog -sv physical_design/rtl/axi4_read_master.sv
read_verilog -sv physical_design/rtl/axi4_write_master.sv
read_verilog -sv physical_design/rtl/dma_controller.sv
read_verilog -sv physical_design/rtl/dma_fifo.sv
read_verilog -sv physical_design/rtl/dma_registers.sv
read_verilog -sv physical_design/rtl/axi4_dma_top.sv

hierarchy -check -top axi4_dma_top

proc
opt
fsm
opt
memory
opt
techmap
opt

dfflibmap -liberty /home/praseed/.ciel/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

abc -liberty /home/praseed/.ciel/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

clean
stat

write_verilog -noattr physical_design/results/axi4_dma_synth.v
write_json physical_design/results/axi4_dma_synth.json
