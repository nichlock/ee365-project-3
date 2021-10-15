# stop any simulation that is currently running
quit -sim
# create the default "work" library
vlib work;
# compile the VHDL source code, and the testbench
vcom *.vhd
vcom *.vht

vsim +altera -do for_export.do -l msim_transcript -gui work.encoder_tb
run 1700ns