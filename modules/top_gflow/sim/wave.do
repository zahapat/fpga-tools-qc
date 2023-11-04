onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: top_gflow_tb ALL signals}
add wave -noupdate /top_gflow_tb/sys_clk_p
add wave -noupdate /top_gflow_tb/sys_clk_n
add wave -noupdate /top_gflow_tb/led
add wave -noupdate /top_gflow_tb/input_pads
add wave -noupdate /top_gflow_tb/output_pads
add wave -noupdate /top_gflow_tb/readout_clk
add wave -noupdate /top_gflow_tb/readout_data_ready
add wave -noupdate /top_gflow_tb/readout_data_valid
add wave -noupdate /top_gflow_tb/readout_enable
add wave -noupdate /top_gflow_tb/readout_data_32b
add wave -noupdate -divider {TB: top_gflow INTERNAL signals}
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_led_fifo_full_latched
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_fifo_wr_valid_qubit_flags
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_usb_fifo_empty
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_usb_fifo_full
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_usb_fifo_prog_empty
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_usb3_transaction_32b
add wave -noupdate /top_gflow_tb/dut_top_gflow/sys_clk
add wave -noupdate /top_gflow_tb/dut_top_gflow/sampl_clk
add wave -noupdate /top_gflow_tb/dut_top_gflow/locked
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_rst
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_rst_sysclk
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_rst_samplclk
add wave -noupdate /top_gflow_tb/dut_top_gflow/s_noisy_channels
add wave -noupdate /top_gflow_tb/dut_top_gflow/s_stable_channels_to_cdcc
add wave -noupdate /top_gflow_tb/dut_top_gflow/s_valid_qubits_stable_to_cdcc
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_inemul_valid
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_cdcc_rd_valid_to_fsm
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_cdcc_rd_qubits_to_fsm
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_gflow_success_flag
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_gflow_success_done
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_alpha_to_math
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_sx_sz_to_math
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_actual_qubit_time_stamp
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_pseudorandom_to_math
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_math_data_modulo
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_math_data_valid
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_out_1MHz_pulses
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_actual_qubit
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_actual_qubit_valid
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/int_state_gflow
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_qubit_buffer_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_time_stamp_buffer_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_time_stamp_buffer_overflows_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_alpha_buffer_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_modulo_buffer_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_random_buffer_2d
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12355100 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 395
configure wave -valuecolwidth 196
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
WaveRestoreZoom {21386713 ps} {51505963 ps}
