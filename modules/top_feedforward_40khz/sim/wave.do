onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_feedforward_40khz_tb/files_recreated
add wave -noupdate /top_feedforward_40khz_tb/ctrl_input_emulation_mode
add wave -noupdate /top_feedforward_40khz_tb/ctrl_sim_start
add wave -noupdate /top_feedforward_40khz_tb/laser_clk
add wave -noupdate /top_feedforward_40khz_tb/sys_clk_p
add wave -noupdate /top_feedforward_40khz_tb/sys_clk_n
add wave -noupdate /top_feedforward_40khz_tb/led
add wave -noupdate /top_feedforward_40khz_tb/input_pads
add wave -noupdate /top_feedforward_40khz_tb/output_pads
add wave -noupdate /top_feedforward_40khz_tb/o_eom_ctrl_pulse
add wave -noupdate /top_feedforward_40khz_tb/o_eom_ctrl_pulsegen_busy
add wave -noupdate /top_feedforward_40khz_tb/o_debug_port_1
add wave -noupdate /top_feedforward_40khz_tb/o_debug_port_2
add wave -noupdate /top_feedforward_40khz_tb/o_debug_port_3
add wave -noupdate /top_feedforward_40khz_tb/readout_clk
add wave -noupdate /top_feedforward_40khz_tb/readout_data_ready
add wave -noupdate /top_feedforward_40khz_tb/readout_data_valid
add wave -noupdate /top_feedforward_40khz_tb/readout_enable
add wave -noupdate /top_feedforward_40khz_tb/readout_data_32b
add wave -noupdate /top_feedforward_40khz_tb/s_qubits
add wave -noupdate /top_feedforward_40khz_tb/s_photon_trans_event
add wave -noupdate /top_feedforward_40khz_tb/s_photon_value_latched
add wave -noupdate /top_feedforward_40khz_tb/slv_cdcc_rd_qubits_to_fsm
add wave -noupdate /top_feedforward_40khz_tb/s_photons_allcombinations_acc
add wave -noupdate /top_feedforward_40khz_tb/s_allphotons_transmitted_cnt
add wave -noupdate /top_feedforward_40khz_tb/s_qubits_transmitted_cnt
add wave -noupdate /top_feedforward_40khz_tb/s_photons_sampled_in_flow
add wave -noupdate /top_feedforward_40khz_tb/s_io_delay_upper_bound_ns
add wave -noupdate /top_feedforward_40khz_tb/s_io_delay_lower_bound_ns
add wave -noupdate /top_feedforward_40khz_tb/s_io_delay_avg_ns
add wave -noupdate /top_feedforward_40khz_tb/s_i_to_fsm_feedfwd_delay_lower_bound_ns
add wave -noupdate /top_feedforward_40khz_tb/s_i_to_fsm_feedfwd_delay_upper_bound_ns
add wave -noupdate /top_feedforward_40khz_tb/s_i_to_fsm_feedfwd_delay_avg_ns
add wave -noupdate /top_feedforward_40khz_tb/int_successful_flows_counter
add wave -noupdate /top_feedforward_40khz_tb/int_failed_flows_counter
add wave -noupdate /top_feedforward_40khz_tb/readout_photons
add wave -noupdate /top_feedforward_40khz_tb/readout_alpha
add wave -noupdate /top_feedforward_40khz_tb/readout_random
add wave -noupdate /top_feedforward_40khz_tb/readout_modulo
add wave -noupdate /top_feedforward_40khz_tb/readout_timestamps
add wave -noupdate /top_feedforward_40khz_tb/readout_csv1_line_done_event
add wave -noupdate /top_feedforward_40khz_tb/readout_coincidences
add wave -noupdate /top_feedforward_40khz_tb/readout_csv2_line_done_event
add wave -noupdate /top_feedforward_40khz_tb/readout_photon_counter
add wave -noupdate /top_feedforward_40khz_tb/readout_photon_losses
add wave -noupdate /top_feedforward_40khz_tb/readout_csv3_line_done_event
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/sys_clk_p
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/sys_clk_n
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/readout_clk
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/readout_data_ready
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/readout_data_valid
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/readout_enable
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/readout_data_32b
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/led
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/o_photon_1v_before_cdcc
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/o_eom_ctrl_pulsegen_busy
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/o_debug_port_1
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/o_debug_port_2
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/o_debug_port_3
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/sl_led_fifo_full_latched
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_fifo_wr_valid_qubit_flags
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/sl_usb_fifo_empty
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/sl_usb_fifo_full
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/sl_usb_fifo_prog_empty
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/acq_clk90
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/eval_clk
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inemul_clk
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/apd_emul_clk
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/mmcm_locked
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_idelay_rdy
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_idelay_rst
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_mmcm_not_locked
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_input_pads_v
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_input_channels_v_fdre
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_input_channels_v_iddr_2clk_2d
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_input_channels_v_iserdese2_2d
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_input_pads_h
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_input_channels_h_fdre
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_input_channels_h_iddr_2clk_2d
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_input_channels_h_iserdese2_2d
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_input_channels
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_input_channels_donttouch
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/s_channels_redge_to_cdcc
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/s_valid_qubits_stable_to_cdcc
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/sl_inemul_valid
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_cdcc_rd_valid_to_fsm
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_cdcc_rd_qubits_to_fsm_delayed
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_feedforward_pulse
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/sl_feedfwd_success_flag
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/sl_feedfwd_success_done
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_alpha_to_math
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_sx_sz_to_math
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_actual_qubit
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_actual_qubit_time_stamp
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/state_feedfwd
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/sl_pseudorandom_to_math
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_math_data_modulo
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/sl_math_data_valid
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_feedfwd_eom_pulse
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_feedfwd_eom_pulse_delayed
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/eom_ctrl_pulse_ready
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/eom_ctrl_pulse_ready_delayed
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/eom_ctrl_pulse_busy
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/eom_ctrl_pulse_busy_delayed
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_qubit_buffer_2d
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_time_stamp_buffer_2d
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_alpha_buffer_2d
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_modulo_buffer_2d
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_random_buffer_2d
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_photon_losses_to_cdcc
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_photon_losses
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_channels_detections_cntr
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_qubit_buffer_transferred_2d
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_time_stamp_buffer_transferred_2d
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_alpha_buffer_transferred_2d
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_modulo_buffer_transferred_2d
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_random_buffer_transferred_2d
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_eom_ctrl_pulse
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_eom_ctrl_pulsegen_busy
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_photon_1h
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_photon_1v
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/clk
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/rst
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/qubits_sampled_valid
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/qubits_sampled
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/o_feedforward_pulse
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/o_unsuccessful_qubits
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/feedfwd_success_flag
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/feedfwd_success_done
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/qubit_buffer
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/time_stamp_buffer
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/state_feedfwd
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/actual_qubit
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/time_stamp_counter_overflow
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/eom_ctrl_pulse_ready
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/slv_state_feedforward
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/slv_state_feedforward_two_qubits
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/int_state_feedfwd
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/actual_state_feedfwd
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/actual_state_feedfwd_two_qubits
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/eom_ctrl_pulse_ready_p1
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/eom_ctrl_pulse_fedge_latched
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/slv_o_feedforward_pulse
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/s_feedfwd_success_flag
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/slv_unsuccessful_qubits
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/slv_unsuccessful_qubits_two_qubits
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/slv_qubits_sampled
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/slv_actual_qubit
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/int_main_counter
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/int_main_counter_two_qubits
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/uns_actual_time_stamp_counter
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/sl_time_stamp_counter_counter_en
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/slv_qubit_buffer_2d
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/slv_time_stamp_buffer_2d
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/flag_invalid_qubit_id
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/slv_counter_skip_qubits
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/slv_main_counter_bin
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/int_main_counter_bin
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/slv_main_counter_bin_incr
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/int_main_counter_bin_incr
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/slv_main_counter_gray
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/int_main_counter_gray
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/slv_main_counter_galois
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/slv_main_counter_galois_feedback
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/slv_new_main_cntr
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/slv_new_main_galois_cntr_two_qubits
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/slv_new_main_galois_cntr_2d
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/wr_rst
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/rd_rst
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/wr_sys_clk
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/wr_channels_detections
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/wr_photon_losses
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/wr_valid_feedfwd_success_done
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/wr_data_qubit_buffer
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/wr_data_time_stamp_buffer
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/wr_data_alpha_buffer
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/wr_data_modulo_buffer
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/wr_data_random_buffer
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/readout_clk
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/readout_data_ready
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/readout_data_valid
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/readout_enable
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/readout_data_32b
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/fifo_full
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/fifo_empty
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/fifo_prog_empty
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/fifo_full_latched
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_time_now
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_time_feedfwd_sample_request
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_time_periodic_sample_request
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_time_periodic_sample_request_2
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/rst_wr_and_rd
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/wr_clk
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_wr_en
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_wr_data
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/rd_clk
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_rd_valid
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_rd_data_out
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_full
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_empty
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_prog_empty
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_wr_en_flag_pulsed
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_wr_data_stream_32b
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_full_latched
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/int_periodic_report_counter
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_periodic_report_flag
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_readout_request_periodic
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_periodic_report_sample_request
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/int_periodic_report_counter_2
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_periodic_report_flag_2
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_readout_request_periodic_2
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_periodic_report_sample_request_2
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_combinations_counters_2d
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_higher_bits_qubit_buffer
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_all_channels_detections_2d
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_overflow_counter
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_last_bit_p1
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_all_unsuccessful_coincidences_2d
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/int_readout_counter
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_combinations_counters_sampled
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_ch_detections_sampled
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_photon_losses_sampled
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_flow_photons_buffer_sampled
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_flow_alpha_buffer_sampled
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_flow_modulo_buffer_sampled
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_flow_random_buffer_sampled
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_flow_timestamp_buffer_sampled
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_combinations_counters_shreg
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_ch_detections_shreg
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_photon_losses_shreg
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_flow_photons_buffer_shreg
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_flow_alpha_buffer_shreg
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_flow_modulo_buffer_shreg
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_flow_random_buffer_shreg
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/slv_flow_timestamp_buffer_shreg
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_readout_request_feedfwd
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_request_read_coincidences_shift_enable
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_request_read_ch_detections_shift_enable
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_request_read_photon_losses_shift_enable
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_request_read_photons_shift_enable
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_request_read_alpha_shift_enable
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_request_read_modulo_shift_enable
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_request_read_random_shift_enable
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/sl_request_read_timestamp_shift_enable
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_csv_readout/state_fifo_readout
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/sl_rst_eval_clk
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/sl_rst_readout_clk
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/sl_rst_dsp_clk
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/acq_clk0
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/dsp_clk
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/s_stable_channels_to_cdcc
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/slv_cdcc_rd_qubits_to_fsm
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/int_state_feedfwd_two_qubits
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/sl_feedfwd_success_flag
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/sl_feedfwd_success_done
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/sl_feedfwd_success_done_transferred
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_reg_delay_eom_pulse/CLK_HZ
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_reg_delay_eom_pulse/RST_VAL
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_reg_delay_eom_pulse/DATA_WIDTH
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_reg_delay_eom_pulse/DELAY_CYCLES
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_reg_delay_eom_pulse/DELAY_NS
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_reg_delay_eom_pulse/clk
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_reg_delay_eom_pulse/i_data
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_reg_delay_eom_pulse/o_data
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_reg_delay_eom_pulse/slv_buffer_reg_2d
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_reg_delay_eom_pulse/CLK_PERIOD_NS
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_reg_delay_eom_pulse/TIME_DELAY_PERIODS
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_reg_delay_eom_pulse/DELAY_CYCLES_CALCULATED
add wave -noupdate -expand /top_feedforward_40khz_tb/dut_top_feedforward_40khz/eom_ctrl_pulse_coincidence
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/eom_ctrl_pulse_coincidence(0)
add wave -noupdate -color Yellow /top_feedforward_40khz_tb/dut_top_feedforward_40khz/input_pads
add wave -noupdate -color Yellow /top_feedforward_40khz_tb/dut_top_feedforward_40khz/input_pads(3)
add wave -noupdate -color Yellow /top_feedforward_40khz_tb/dut_top_feedforward_40khz/input_pads(2)
add wave -noupdate -color Yellow /top_feedforward_40khz_tb/dut_top_feedforward_40khz/input_pads(1)
add wave -noupdate -color Yellow /top_feedforward_40khz_tb/dut_top_feedforward_40khz/input_pads(0)
add wave -noupdate -color {Cadet Blue} /top_feedforward_40khz_tb/dut_top_feedforward_40khz/inst_fsm_feedforward/actual_qubit_valid
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/sl_actual_qubit_valid
add wave -noupdate -color {Orange Red} /top_feedforward_40khz_tb/dut_top_feedforward_40khz/o_eom_ctrl_pulse
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/int_cntr
add wave -noupdate /top_feedforward_40khz_tb/dut_top_feedforward_40khz/int_cntr_trig
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {765158 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 549
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
WaveRestoreZoom {0 ps} {53923905 ps}
