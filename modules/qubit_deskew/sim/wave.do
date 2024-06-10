onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: qubit_deskew_tb ALL signals}
add wave -noupdate /qubit_deskew_tb/s_clk_100MHz
add wave -noupdate /qubit_deskew_tb/s_clk_new_qubit_78MHz
add wave -noupdate /qubit_deskew_tb/s_qubit_78MHz
add wave -noupdate /qubit_deskew_tb/s_qubit_31MHz
add wave -noupdate /qubit_deskew_tb/s_clk_detector_31MHz
add wave -noupdate /qubit_deskew_tb/clk
add wave -noupdate /qubit_deskew_tb/rst
add wave -noupdate -expand /qubit_deskew_tb/noisy_channels_in
add wave -noupdate /qubit_deskew_tb/qubit_valid_250MHz
add wave -noupdate /qubit_deskew_tb/qubit_250MHz
add wave -noupdate -color Gold /qubit_deskew_tb/slv_input_data
add wave -noupdate /qubit_deskew_tb/s_buff_data_p1
add wave -noupdate /qubit_deskew_tb/s_buff_data_p2
add wave -noupdate /qubit_deskew_tb/s_buff_data
add wave -noupdate -divider {Qubit Deskew DUT}
add wave -noupdate -expand /qubit_deskew_tb/dut_qubit_deskew/s_flops_databuff_1
add wave -noupdate -expand /qubit_deskew_tb/dut_qubit_deskew/s_buff_data
add wave -noupdate -expand /qubit_deskew_tb/dut_qubit_deskew/s_channels_redge
add wave -noupdate -expand /qubit_deskew_tb/dut_qubit_deskew/s_shiftreg_counter_faster
add wave -noupdate /qubit_deskew_tb/dut_qubit_deskew/s_slower_q1
add wave -noupdate /qubit_deskew_tb/dut_qubit_deskew/s_aligned_valid_q1
add wave -noupdate /qubit_deskew_tb/dut_qubit_deskew/s_aligned_valid_q1_p1
add wave -noupdate /qubit_deskew_tb/dut_qubit_deskew/qubit_valid_250MHz
add wave -noupdate -expand /qubit_deskew_tb/dut_qubit_deskew/qubit_250MHz
add wave -noupdate /qubit_deskew_tb/dut_qubit_deskew/s_out_aligned_qubits
add wave -noupdate /qubit_deskew_tb/dut_qubit_deskew/s_qubit_valid_out
add wave -noupdate /qubit_deskew_tb/dut_qubit_deskew/s_stable_channels_oversampled
add wave -noupdate /qubit_deskew_tb/dut_qubit_deskew/s_ignore_nextvalid_q1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {147316000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 388
configure wave -valuecolwidth 244
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
WaveRestoreZoom {14090690098 ps} {14090868332 ps}
