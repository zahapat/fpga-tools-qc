onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: pulse_gen_tb ALL signals}
add wave -noupdate /pulse_gen_tb/CLK
add wave -noupdate /pulse_gen_tb/RST
add wave -noupdate /pulse_gen_tb/PULSE_TRIGGER
add wave -noupdate -expand /pulse_gen_tb/READY
add wave -noupdate /pulse_gen_tb/IN_DATA
add wave -noupdate -expand /pulse_gen_tb/PULSES_OUT
add wave -noupdate /pulse_gen_tb/dut_pulse_gen/s_cnt_set_high
add wave -noupdate /pulse_gen_tb/dut_pulse_gen/s_cnt_set_low
add wave -noupdate /pulse_gen_tb/dut_pulse_gen/s_cnt_clk_high_2d
add wave -noupdate /pulse_gen_tb/dut_pulse_gen/s_cnt_clk_low_2d
add wave -noupdate /pulse_gen_tb/dut_pulse_gen/s_pulses_val_high
add wave -noupdate /pulse_gen_tb/dut_pulse_gen/s_pulses_val_low
add wave -noupdate /pulse_gen_tb/dut_pulse_gen/CLK_PERIOD_NS
add wave -noupdate /pulse_gen_tb/dut_pulse_gen/CLK_PERIODS_HIGH
add wave -noupdate /pulse_gen_tb/dut_pulse_gen/CLK_PERIODS_LOW
add wave -noupdate /pulse_gen_tb/dut_pulse_gen/s_galois_cnt_clk_high_2d
add wave -noupdate /pulse_gen_tb/dut_pulse_gen/s_galois_cnt_clk_low_2d
add wave -noupdate /pulse_gen_tb/dut_pulse_gen/MAX_PERIODS_DELAY_BITWIDTH_HIGH
add wave -noupdate /pulse_gen_tb/dut_pulse_gen/MAX_PERIODS_DELAY_BITWIDTH_LOW
add wave -noupdate /pulse_gen_tb/dut_pulse_gen/INT_PRIM_POL_CNTR_HIGH
add wave -noupdate /pulse_gen_tb/dut_pulse_gen/INT_PRIM_POL_CNTR_LOW
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {116343 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 297
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
WaveRestoreZoom {0 ps} {2158800 ps}
