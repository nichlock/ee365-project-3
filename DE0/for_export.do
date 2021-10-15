onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Inputs
add wave -noupdate -label clock /encoder_tb/sys_clk
add wave -noupdate -label rst /encoder_tb/rst
add wave -noupdate -label iA /encoder_tb/a
add wave -noupdate -label iB /encoder_tb/b
add wave -noupdate -divider {Top Level Internal}
add wave -noupdate -label {Add Enable} /encoder_tb/DUT/add_this_cycle
add wave -noupdate -label {Subtract Enable} /encoder_tb/DUT/sub_this_cycle
add wave -noupdate -divider Outputs
add wave -noupdate -label {Counter Result} -radix hexadecimal /encoder_tb/count_result
add wave -noupdate -label {Encoder Machine State} /encoder_tb/DUT/state_machine/fstate
add wave -noupdate -label {Max Cars Reached} /encoder_tb/max_cars
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {240000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 155
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1849324 ps}
