onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: lfsr_inemul_tb ALL signals}
add wave -noupdate /signals_lfsr_inemul_pack_tb/dut1_rst
add wave -noupdate /signals_lfsr_inemul_pack_tb/dut1_tx1
add wave -noupdate /signals_lfsr_inemul_pack_tb/dut1_tx1_valid1
add wave -noupdate /signals_lfsr_inemul_pack_tb/dut1_ready
add wave -noupdate /signals_lfsr_inemul_pack_tb/dut1_rx1
add wave -noupdate /signals_lfsr_inemul_pack_tb/dut1_rx1_valid1
add wave -noupdate /signals_lfsr_inemul_pack_tb/dut1_rx2
add wave -noupdate /signals_lfsr_inemul_pack_tb/dut1_rx2_valid1
add wave -noupdate /signals_lfsr_inemul_pack_tb/clk1
add wave -noupdate /signals_lfsr_inemul_pack_tb/rst1
add wave -noupdate /signals_lfsr_inemul_pack_tb/glob_seed1
add wave -noupdate /signals_lfsr_inemul_pack_tb/tx_dut1_valid
add wave -noupdate /signals_lfsr_inemul_pack_tb/rx_dut1_valid
add wave -noupdate /signals_lfsr_inemul_pack_tb/int_bits_in_error
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {270000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 348
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
WaveRestoreZoom {329952 ps} {330003 ps}
