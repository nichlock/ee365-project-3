transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {S:/Courses/EE365/P3/code/top_level.vhd}
vcom -93 -work work {S:/Courses/EE365/P3/code/univ_bin_counter.vhd}
vcom -93 -work work {S:/Courses/EE365/P3/code/debounce.vhd}
vcom -93 -work work {S:/Courses/EE365/P3/code/encoder.vhd}
vcom -93 -work work {S:/Courses/EE365/P3/code/encoder_sm.vhd}

