onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: top_gflow_tb ALL signals}
add wave -noupdate /top_gflow_tb/sys_clk_p
add wave -noupdate /top_gflow_tb/sys_clk_n
add wave -noupdate /top_gflow_tb/led
add wave -noupdate /top_gflow_tb/readout_clk
add wave -noupdate /top_gflow_tb/readout_data_ready
add wave -noupdate /top_gflow_tb/readout_data_valid
add wave -noupdate /top_gflow_tb/readout_enable
add wave -noupdate /top_gflow_tb/readout_data_32b
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_alu_gflow/CLK
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_alu_gflow/RST
add wave -noupdate -color Blue /top_gflow_tb/dut_top_gflow/inst_alu_gflow/QUBIT_VALID
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_alu_gflow/ALPHA_POSITIVE
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_alu_gflow/RAND_BIT
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_alu_gflow/RANDOM_BUFFER
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_alu_gflow/s_alpha_multiplied_signed
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_alu_gflow/s_added_random_multiplied_unsigned
add wave -noupdate -color Salmon /top_gflow_tb/dut_top_gflow/inst_alu_gflow/sl_data_valid
add wave -noupdate -color {Indian Red} /top_gflow_tb/dut_top_gflow/inst_alu_gflow/DATA_VALID
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_alu_gflow/MODULO_BUFFER
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_alu_gflow/sl_alpha_positive_p1
add wave -noupdate -color Salmon /top_gflow_tb/dut_top_gflow/inst_alu_gflow/sl_alpha_positive_p2
add wave -noupdate -color Plum /top_gflow_tb/dut_top_gflow/inst_alu_gflow/s_modulo
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_alu_gflow/S_X
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_alu_gflow/S_Z
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_alu_gflow/DATA_MODULO_OUT
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_alu_gflow/sl_valid_factors
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_alu_gflow/minus_one_power_simplified
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_alu_gflow/s_added_random_unsigned
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_alu_gflow/slv_random_buffer_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_alu_gflow/slv_modulo_buffer_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_gflow_success_flag
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_gflow_success_done
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_gflow_success_done_transferred
add wave -noupdate -expand /top_gflow_tb/dut_top_gflow/pcd_ctrl_pulse_ready
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/pcd_ctrl_pulse_ready_p1
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/pcd_ctrl_pulse_fedge_latched
add wave -noupdate -divider {TB: top_gflow INTERNAL signals}
add wave -noupdate /top_gflow_tb/dut_top_gflow/sys_clk
add wave -noupdate /top_gflow_tb/dut_top_gflow/sampl_clk
add wave -noupdate /top_gflow_tb/output_pads
add wave -noupdate -color Gold /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/int_state_gflow
add wave -noupdate -radix unsigned -childformat {{/top_gflow_tb/dut_top_gflow/inst_fsm_gflow/slv_counter_skip_qubits(0) -radix unsigned}} -subitemconfig {/top_gflow_tb/dut_top_gflow/inst_fsm_gflow/slv_counter_skip_qubits(0) {-height 15 -radix unsigned}} /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/slv_counter_skip_qubits
add wave -noupdate /top_gflow_tb/input_pads
add wave -noupdate -expand /top_gflow_tb/dut_top_gflow/slv_cdcc_rd_qubits_to_fsm
add wave -noupdate -expand /top_gflow_tb/dut_top_gflow/slv_cdcc_rd_valid_to_fsm
add wave -noupdate -color {Violet Red} -radix unsigned /top_gflow_tb/dut_top_gflow/slv_actual_qubit_time_stamp
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_qubit4_deskew/s_buff_data
add wave -noupdate -radix unsigned -childformat {{/top_gflow_tb/dut_top_gflow/slv_actual_qubit(1) -radix unsigned} {/top_gflow_tb/dut_top_gflow/slv_actual_qubit(0) -radix unsigned}} -subitemconfig {/top_gflow_tb/dut_top_gflow/slv_actual_qubit(1) {-height 15 -radix unsigned} /top_gflow_tb/dut_top_gflow/slv_actual_qubit(0) {-height 15 -radix unsigned}} /top_gflow_tb/dut_top_gflow/slv_actual_qubit
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_qubit2_deskew/s_buff_data
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_qubit3_deskew/s_buff_data
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_qubit1_deskew/s_buff_data
add wave -noupdate /top_gflow_tb/dut_top_gflow/s_valid_qubits_stable_to_cdcc
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_actual_qubit_valid
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_math_data_valid
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_led_fifo_full_latched
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_fifo_wr_valid_qubit_flags
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_usb_fifo_empty
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_usb_fifo_full
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_usb_fifo_prog_empty
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_usb3_transaction_32b
add wave -noupdate /top_gflow_tb/dut_top_gflow/locked
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_rst
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_rst_samplclk
add wave -noupdate /top_gflow_tb/dut_top_gflow/s_noisy_channels
add wave -noupdate /top_gflow_tb/dut_top_gflow/s_stable_channels_to_cdcc
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_inemul_valid
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_alpha_to_math
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_sx_sz_to_math
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_pseudorandom_to_math
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_math_data_modulo
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_qubit_buffer_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_time_stamp_buffer_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_alpha_buffer_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_modulo_buffer_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_random_buffer_2d
add wave -noupdate /top_gflow_tb/PHOTON_1H_DELAY_ABS_NS
add wave -noupdate /top_gflow_tb/PHOTON_1V_DELAY_ABS_NS
add wave -noupdate /top_gflow_tb/PHOTON_2H_DELAY_ABS_NS
add wave -noupdate /top_gflow_tb/PHOTON_2V_DELAY_ABS_NS
add wave -noupdate /top_gflow_tb/PHOTON_3H_DELAY_ABS_NS
add wave -noupdate /top_gflow_tb/PHOTON_3V_DELAY_ABS_NS
add wave -noupdate /top_gflow_tb/PHOTON_4H_DELAY_ABS_NS
add wave -noupdate /top_gflow_tb/PHOTON_4V_DELAY_ABS_NS
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/wr_sys_clk
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/wr_valid_gflow_success_done
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/wr_valid_gflow_success_done_p1
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/wr_valid_gflow_success_done_p2
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/wr_valid_gflow_success_done_p3
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/wr_valid_qubit_flags
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/wr_data_qubit_buffer
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/wr_data_time_stamp_buffer
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/wr_data_alpha_buffer
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/wr_data_modulo_buffer
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/wr_data_random_buffer
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/readout_clk
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/readout_data_ready
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/readout_data_valid
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/readout_enable
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/readout_data_32b
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/fifo_full
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/fifo_empty
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/fifo_prog_empty
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/fifo_full_latched
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/sl_rst
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/wr_clk
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/sl_wr_en
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/slv_wr_data
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/rd_clk
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/sl_rd_valid
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/slv_rd_data_out
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/sl_full
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/sl_empty
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/sl_prog_empty
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/slv_wr_valid_qubit_flags_p1
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/sl_wr_en_flag_pulsed
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/slv_wr_data_stream_32b
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/slv_wr_data_stream_32b_1
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/slv_wr_data_stream_32b_2
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/sl_full_latched
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/sl_at_least_one_qubit_valid
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/sl_at_least_one_qubit_valid_p1
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/sl_readout_endp_ready
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/slv_ok_rd_endp_data
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/wr_data_time_stamp_buffer_p1
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/slv_qubit_buffer_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/slv_time_stamp_buffer_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/slv_alpha_buffer_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/slv_modulo_buffer_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/slv_random_buffer_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/int_one_second_counter
add wave -noupdate -radix unsigned /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/uns_counts_in_one_second_counter
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/uns_counts_in_one_second_latched
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/sl_one_second_flag
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/state_write_data_transac
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/COUNT_UNTIL_SECOND
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_okHost_fifo_ctrl/CLK_PERIODS_ONE_SECOND
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_qubit_buffer_transferred_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_time_stamp_buffer_transferred_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_alpha_buffer_transferred_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_modulo_buffer_transferred_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_random_buffer_transferred_2d
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9475138 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 476
configure wave -valuecolwidth 213
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
WaveRestoreZoom {0 ps} {52500 ns}
