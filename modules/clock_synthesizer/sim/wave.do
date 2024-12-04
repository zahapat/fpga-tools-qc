onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: clock_synthesizer_tb ALL signals}
add wave -noupdate /clock_synthesizer_tb/in_reset
add wave -noupdate /clock_synthesizer_tb/in_clk0_p
add wave -noupdate /clock_synthesizer_tb/in_clk0_n
add wave -noupdate /clock_synthesizer_tb/in_fineps_clk
add wave -noupdate /clock_synthesizer_tb/in_fineps_incr
add wave -noupdate /clock_synthesizer_tb/in_fineps_decr
add wave -noupdate /clock_synthesizer_tb/in_fineps_valid
add wave -noupdate /clock_synthesizer_tb/out_fineps_dready
add wave -noupdate /clock_synthesizer_tb/out_clk0
add wave -noupdate /clock_synthesizer_tb/out_clk1
add wave -noupdate /clock_synthesizer_tb/out_clk2
add wave -noupdate /clock_synthesizer_tb/out_clk3
add wave -noupdate /clock_synthesizer_tb/out_clk4
add wave -noupdate /clock_synthesizer_tb/out_clk5
add wave -noupdate /clock_synthesizer_tb/out_clk6
add wave -noupdate /clock_synthesizer_tb/locked
add wave -noupdate -divider {DUT: 'clock_synthesizer' IN ports}
add wave -noupdate /clock_synthesizer_tb/dut/in_fineps_valid
add wave -noupdate /clock_synthesizer_tb/dut/in_fineps_incr
add wave -noupdate /clock_synthesizer_tb/dut/in_fineps_decr
add wave -noupdate /clock_synthesizer_tb/dut/in_fineps_clk
add wave -noupdate -divider {DUT: 'clock_synthesizer' OUT ports}
add wave -noupdate /clock_synthesizer_tb/dut/locked
add wave -noupdate /clock_synthesizer_tb/dut/out_clk0
add wave -noupdate /clock_synthesizer_tb/dut/out_clk1
add wave -noupdate /clock_synthesizer_tb/dut/out_clk2
add wave -noupdate /clock_synthesizer_tb/dut/out_clk3
add wave -noupdate /clock_synthesizer_tb/dut/out_clk4
add wave -noupdate /clock_synthesizer_tb/dut/out_clk5
add wave -noupdate /clock_synthesizer_tb/dut/out_clk6
add wave -noupdate /clock_synthesizer_tb/dut/out_fineps_dready
add wave -noupdate -divider {DUT: 'clock_synthesizer' INTERNAL signals}
add wave -noupdate /clock_synthesizer_tb/dut/fineps_dready
add wave -noupdate /clock_synthesizer_tb/dut/fineps_incdec
add wave -noupdate /clock_synthesizer_tb/dut/fineps_en
add wave -noupdate /clock_synthesizer_tb/dut/fineps_valid
add wave -noupdate /clock_synthesizer_tb/dut/ps_done
add wave -noupdate -divider {Constants and Generics}
add wave -noupdate /clock_synthesizer_tb/IF_CLKIN1_DIFF
add wave -noupdate /clock_synthesizer_tb/REAL_CLKIN1_MHZ
add wave -noupdate /clock_synthesizer_tb/CLKIN1_PERIOD_NS
add wave -noupdate /clock_synthesizer_tb/INT_VCO_DIVIDE
add wave -noupdate /clock_synthesizer_tb/REAL_VCO_MULTIPLY
add wave -noupdate /clock_synthesizer_tb/REAL_DIVIDE_OUT0
add wave -noupdate /clock_synthesizer_tb/INT_DIVIDE_OUT1
add wave -noupdate /clock_synthesizer_tb/INT_DIVIDE_OUT2
add wave -noupdate /clock_synthesizer_tb/INT_DIVIDE_OUT3
add wave -noupdate /clock_synthesizer_tb/INT_DIVIDE_OUT4
add wave -noupdate /clock_synthesizer_tb/INT_DIVIDE_OUT5
add wave -noupdate /clock_synthesizer_tb/INT_DIVIDE_OUT6
add wave -noupdate /clock_synthesizer_tb/REAL_DUTY_OUT0
add wave -noupdate /clock_synthesizer_tb/REAL_DUTY_OUT1
add wave -noupdate /clock_synthesizer_tb/REAL_DUTY_OUT2
add wave -noupdate /clock_synthesizer_tb/REAL_DUTY_OUT3
add wave -noupdate /clock_synthesizer_tb/REAL_DUTY_OUT4
add wave -noupdate /clock_synthesizer_tb/REAL_DUTY_OUT5
add wave -noupdate /clock_synthesizer_tb/REAL_DUTY_OUT6
add wave -noupdate /clock_synthesizer_tb/REAL_PHASE_OUT0
add wave -noupdate /clock_synthesizer_tb/REAL_PHASE_OUT1
add wave -noupdate /clock_synthesizer_tb/REAL_PHASE_OUT2
add wave -noupdate /clock_synthesizer_tb/REAL_PHASE_OUT3
add wave -noupdate /clock_synthesizer_tb/REAL_PHASE_OUT4
add wave -noupdate /clock_synthesizer_tb/REAL_PHASE_OUT5
add wave -noupdate /clock_synthesizer_tb/REAL_PHASE_OUT6
add wave -noupdate /clock_synthesizer_tb/dut/REF_JITTER1_UI_REAL
add wave -noupdate /clock_synthesizer_tb/dut/REF_JITTER1_UI_REAL_MULTIPLIED
add wave -noupdate /clock_synthesizer_tb/dut/REF_JITTER1_UI_ROUNDED1
add wave -noupdate /clock_synthesizer_tb/dut/REF_JITTER1_UI_DIVIDED
add wave -noupdate /clock_synthesizer_tb/dut/REF_JITTER1_UI_ROUNDED2
add wave -noupdate /clock_synthesizer_tb/dut/REF_JITTER1_UI_REAL_ORIG_ORDER
add wave -noupdate /clock_synthesizer_tb/dut/out_clkfb
add wave -noupdate /clock_synthesizer_tb/out_clkb0
add wave -noupdate /clock_synthesizer_tb/out_clkb1
add wave -noupdate /clock_synthesizer_tb/out_clkb2
add wave -noupdate /clock_synthesizer_tb/out_clkb3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {75499 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 381
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {3185652 ps}
