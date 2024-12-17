onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: shiftreg_delay_tb ALL signals}
add wave -noupdate /shiftreg_delay_tb/clk
add wave -noupdate /shiftreg_delay_tb/i_data
add wave -noupdate /shiftreg_delay_tb/o_data
add wave -noupdate /shiftreg_delay_tb/dut_shiftreg_delay/slv_buffer_shiftreg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {80000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {268800 ps}
