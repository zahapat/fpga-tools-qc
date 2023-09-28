onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: fsm_gflow_tb ALL signals}
add wave -noupdate /fsm_gflow_tb/CLK_NEW_QUBIT
add wave -noupdate /fsm_gflow_tb/clk
add wave -noupdate /fsm_gflow_tb/rst
add wave -noupdate /fsm_gflow_tb/qubits_sampled_valid
add wave -noupdate /fsm_gflow_tb/qubits_sampled
add wave -noupdate /fsm_gflow_tb/feedback_mod_valid
add wave -noupdate /fsm_gflow_tb/feedback_mod
add wave -noupdate /fsm_gflow_tb/gflow_success_flag
add wave -noupdate /fsm_gflow_tb/gflow_success_done
add wave -noupdate /fsm_gflow_tb/qubit_buffer
add wave -noupdate -expand /fsm_gflow_tb/time_stamp_buffer
add wave -noupdate /fsm_gflow_tb/time_stamp_buffer_overflows
add wave -noupdate /fsm_gflow_tb/alpha_buffer
add wave -noupdate /fsm_gflow_tb/to_math_alpha
add wave -noupdate /fsm_gflow_tb/to_math_sx_xz
add wave -noupdate /fsm_gflow_tb/actual_qubit_valid
add wave -noupdate /fsm_gflow_tb/actual_qubit
add wave -noupdate /fsm_gflow_tb/actual_qubit_time_stamp
add wave -noupdate /fsm_gflow_tb/time_stamp_counter_overflow
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {138025000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 287
configure wave -valuecolwidth 238
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
WaveRestoreZoom {0 ps} {439293750 ps}
