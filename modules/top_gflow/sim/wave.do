onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_gflow_tb/input_pads(0)
add wave -noupdate /top_gflow_tb/input_pads(1)
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_input_channels
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_input_pads_v
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_input_pads_h
add wave -noupdate -divider {TB: top_gflow_tb ALL signals}
add wave -noupdate /top_gflow_tb/dut_top_gflow/inemul_clk
add wave -noupdate /top_gflow_tb/dut_top_gflow/eval_clk
add wave -noupdate /top_gflow_tb/dut_top_gflow/dsp_clk
add wave -noupdate /top_gflow_tb/sys_clk_p
add wave -noupdate /top_gflow_tb/sys_clk_n
add wave -noupdate /top_gflow_tb/led
add wave -noupdate -expand /top_gflow_tb/dut_top_gflow/eom_ctrl_pulse_ready
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/eom_ctrl_pulse_ready_p1
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/eom_ctrl_pulse_fedge_latched
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_rst_eval_clk
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_rst_readout_clk
add wave -noupdate /top_gflow_tb/s_i_to_fsm_feedfwd_delay_lower_bound_ns
add wave -noupdate /top_gflow_tb/s_i_to_fsm_feedfwd_delay_upper_bound_ns
add wave -noupdate /top_gflow_tb/s_i_to_fsm_feedfwd_delay_avg_ns
add wave -noupdate /top_gflow_tb/s_i_to_delay_comp_delay_lower_bound_ns
add wave -noupdate /top_gflow_tb/s_i_to_delay_comp_delay_upper_bound_ns
add wave -noupdate /top_gflow_tb/s_i_to_delay_comp_delay_avg_ns
add wave -noupdate -color Violet /top_gflow_tb/s_i_to_delay_comp_delay_now_ns
add wave -noupdate -color Violet /top_gflow_tb/s_i_to_delay_comp_delay_now_diff_ns
add wave -noupdate -color Violet /top_gflow_tb/s_i_to_delay_comp_delay_now_diff_max_ns
add wave -noupdate -color Violet /top_gflow_tb/s_i_to_delay_comp_delay_now_diff_min_ns
add wave -noupdate -color Violet /top_gflow_tb/s_i_to_delay_comp_delay_now_diff_avg_ns
add wave -noupdate /top_gflow_tb/input_pads
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_input_channels_donttouch
add wave -noupdate /top_gflow_tb/dut_top_gflow/s_stable_channels_to_cdcc
add wave -noupdate -divider {TB: top_gflow INTERNAL signals}
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/PHOTON_HV_SYNCHRONIZATION_DELAY
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/int_main_counter
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_cdcc_rd_qubits_to_fsm
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_cdcc_rd_valid_to_fsm
add wave -noupdate -color {Violet Red} -radix unsigned /top_gflow_tb/dut_top_gflow/slv_actual_qubit_time_stamp
add wave -noupdate -radix unsigned -childformat {{/top_gflow_tb/dut_top_gflow/slv_actual_qubit(1) -radix unsigned} {/top_gflow_tb/dut_top_gflow/slv_actual_qubit(0) -radix unsigned}} -subitemconfig {/top_gflow_tb/dut_top_gflow/slv_actual_qubit(1) {-height 15 -radix unsigned} /top_gflow_tb/dut_top_gflow/slv_actual_qubit(0) {-height 15 -radix unsigned}} /top_gflow_tb/dut_top_gflow/slv_actual_qubit
add wave -noupdate /top_gflow_tb/dut_top_gflow/s_valid_qubits_stable_to_cdcc
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_actual_qubit_valid
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_math_data_valid
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_led_fifo_full_latched
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_fifo_wr_valid_qubit_flags
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_usb_fifo_empty
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_usb_fifo_full
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_usb_fifo_prog_empty
add wave -noupdate /top_gflow_tb/dut_top_gflow/s_stable_channels_to_cdcc
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_inemul_valid
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_alpha_to_math
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_sx_sz_to_math
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_pseudorandom_to_math
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_math_data_modulo
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_qubit_buffer_2d
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
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_qubit_buffer_transferred_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_time_stamp_buffer_transferred_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_alpha_buffer_transferred_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_modulo_buffer_transferred_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_random_buffer_transferred_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/MAX_PERIODS_CORR
add wave -noupdate -divider {Analysis Signals}
add wave -noupdate /top_gflow_tb/s_allphotons_transmitted_cnt
add wave -noupdate /top_gflow_tb/s_io_delay_upper_bound_ns
add wave -noupdate /top_gflow_tb/s_io_delay_lower_bound_ns
add wave -noupdate /top_gflow_tb/s_io_delay_avg_ns
add wave -noupdate /top_gflow_tb/int_successful_flows_counter
add wave -noupdate /top_gflow_tb/int_failed_flows_counter
add wave -noupdate /top_gflow_tb/s_qubits_transmitted_cnt
add wave -noupdate /top_gflow_tb/s_photons_allcombinations_acc
add wave -noupdate /top_gflow_tb/readout_clk
add wave -noupdate /top_gflow_tb/readout_data_ready
add wave -noupdate /top_gflow_tb/readout_data_valid
add wave -noupdate /top_gflow_tb/readout_csv2_line_done_event
add wave -noupdate /top_gflow_tb/readout_enable
add wave -noupdate /top_gflow_tb/readout_data_32b
add wave -noupdate /top_gflow_tb/readout_photons
add wave -noupdate /top_gflow_tb/readout_alpha
add wave -noupdate /top_gflow_tb/readout_random
add wave -noupdate /top_gflow_tb/readout_modulo
add wave -noupdate /top_gflow_tb/readout_timestamps
add wave -noupdate /top_gflow_tb/readout_csv1_line_done_event
add wave -noupdate -childformat {{/top_gflow_tb/readout_coincidences(3) -radix unsigned} {/top_gflow_tb/readout_coincidences(2) -radix unsigned} {/top_gflow_tb/readout_coincidences(1) -radix unsigned} {/top_gflow_tb/readout_coincidences(0) -radix unsigned}} -subitemconfig {/top_gflow_tb/readout_coincidences(3) {-height 15 -radix unsigned} /top_gflow_tb/readout_coincidences(2) {-height 15 -radix unsigned} /top_gflow_tb/readout_coincidences(1) {-height 15 -radix unsigned} /top_gflow_tb/readout_coincidences(0) {-height 15 -radix unsigned}} /top_gflow_tb/readout_coincidences
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_input_channels_v_iserdese2_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_input_channels_h_iserdese2_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/o_debug_port_1
add wave -noupdate /top_gflow_tb/dut_top_gflow/o_debug_port_2
add wave -noupdate /top_gflow_tb/dut_top_gflow/o_debug_port_3
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_v0/clk
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_v0/clk90
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_v0/clkb
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_v0/clk90b
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_v0/in_pad
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_v0/in_reset_iserdese2
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_v0/in_enable_iserdese2
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_v0/out_data_fdre
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_v0/out_data_iddr_2clk
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_v0/out_data_iserdese2
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_v0/sl_pad
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_v0/sl_data_ibuf_out
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_v0/sl_out_data_fdre
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_v0/slv_out_data_iddr_2clk
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_v0/sl_out_data_iserdese2_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_v0/slv_out_data_iserdese2
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_h0/clk
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_h0/clk90
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_h0/clkb
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_h0/clk90b
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_h0/in_pad
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_h0/in_reset_iserdese2
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_h0/in_enable_iserdese2
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_h0/out_data_fdre
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_h0/out_data_iddr_2clk
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_h0/out_data_iserdese2
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_h0/sl_pad
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_h0/sl_data_ibuf_out
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_h0/sl_out_data_fdre
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_h0/slv_out_data_iddr_2clk
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_h0/sl_out_data_iserdese2_2d
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_emul_false0/inst_xilinx_sdr_sampler_h0/slv_out_data_iserdese2
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_mmcm_not_locked
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_idelay_rdy
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_mmcm_not_locked
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_photon_delay_compensation(0)/inst_photon_delay_compensation/clk
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_photon_delay_compensation(0)/inst_photon_delay_compensation/rst
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_photon_delay_compensation(0)/inst_photon_delay_compensation/noisy_channels_in
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_photon_delay_compensation(0)/inst_photon_delay_compensation/qubit_valid
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_photon_delay_compensation(0)/inst_photon_delay_compensation/s_buff_data
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_photon_delay_compensation(0)/inst_photon_delay_compensation/s_channels_redge
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_photon_delay_compensation(0)/inst_photon_delay_compensation/s_shiftreg_delay_h
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_photon_delay_compensation(0)/inst_photon_delay_compensation/s_shiftreg_delay_v
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_photon_delay_compensation(0)/inst_photon_delay_compensation/s_slower_q1
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_photon_delay_compensation(0)/inst_photon_delay_compensation/s_out_aligned_qubits
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_photon_delay_compensation(0)/inst_photon_delay_compensation/s_aligned_valid_q1
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_photon_delay_compensation(0)/inst_photon_delay_compensation/s_aligned_valid_q1_p1
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_photon_delay_compensation(0)/inst_photon_delay_compensation/s_qubit_valid_out
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_photon_delay_compensation(0)/inst_photon_delay_compensation/s_stable_channels_oversampled
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_photon_delay_compensation(0)/inst_photon_delay_compensation/sl_qubit_valid_out
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_photon_delay_compensation(0)/inst_photon_delay_compensation/slv_qubit_out
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_photon_delay_compensation(0)/inst_photon_delay_compensation/s_flops_databuff_1
add wave -noupdate /top_gflow_tb/dut_top_gflow/gen_photon_delay_compensation(0)/inst_photon_delay_compensation/s_flops_databuff_2
add wave -noupdate -color Magenta /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/slv_sx_buffer
add wave -noupdate -color Magenta /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/slv_sz_buffer
add wave -noupdate -color Magenta /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/slv_sx_all_qubits
add wave -noupdate -color Magenta -expand -subitemconfig {/top_gflow_tb/dut_top_gflow/inst_fsm_gflow/state_feedfwd(3) {-color Magenta -height 15} /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/state_feedfwd(2) {-color Magenta -height 15} /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/state_feedfwd(1) {-color Magenta -height 15} /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/state_feedfwd(0) {-color Magenta -height 15}} /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/state_feedfwd
add wave -noupdate -color Gold /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/actual_qubit_valid
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/o_sx_next
add wave -noupdate -color Magenta /top_gflow_tb/dut_top_gflow/slv_o_sx_next_to_math
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_feedfwd_eom_pulse
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_feedfwd_eom_pulse_en
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_feedfwd_eom_pulse_delayed
add wave -noupdate /top_gflow_tb/o_eom_ctrl_pulse
add wave -noupdate -color Coral -radix decimal -childformat {{/top_gflow_tb/dut_top_gflow/slv_time_stamp_buffer_2d(6) -radix decimal} {/top_gflow_tb/dut_top_gflow/slv_time_stamp_buffer_2d(5) -radix decimal} {/top_gflow_tb/dut_top_gflow/slv_time_stamp_buffer_2d(4) -radix decimal} {/top_gflow_tb/dut_top_gflow/slv_time_stamp_buffer_2d(3) -radix decimal} {/top_gflow_tb/dut_top_gflow/slv_time_stamp_buffer_2d(2) -radix decimal} {/top_gflow_tb/dut_top_gflow/slv_time_stamp_buffer_2d(1) -radix decimal} {/top_gflow_tb/dut_top_gflow/slv_time_stamp_buffer_2d(0) -radix decimal}} -expand -subitemconfig {/top_gflow_tb/dut_top_gflow/slv_time_stamp_buffer_2d(6) {-color Coral -height 15 -radix decimal} /top_gflow_tb/dut_top_gflow/slv_time_stamp_buffer_2d(5) {-color Coral -height 15 -radix decimal} /top_gflow_tb/dut_top_gflow/slv_time_stamp_buffer_2d(4) {-color Coral -height 15 -radix decimal} /top_gflow_tb/dut_top_gflow/slv_time_stamp_buffer_2d(3) {-color Coral -height 15 -radix decimal} /top_gflow_tb/dut_top_gflow/slv_time_stamp_buffer_2d(2) {-color Coral -height 15 -radix decimal} /top_gflow_tb/dut_top_gflow/slv_time_stamp_buffer_2d(1) {-color Coral -height 15 -radix decimal} /top_gflow_tb/dut_top_gflow/slv_time_stamp_buffer_2d(0) {-color Coral -height 15 -radix decimal}} /top_gflow_tb/dut_top_gflow/slv_time_stamp_buffer_2d
add wave -noupdate -color Magenta /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/slv_sx_all_qubits_ored
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/ROM_SX_MASK_2D
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/ROM_SZ_MASK_2D
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/slv_actual_sx_mask
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/slv_actual_sz_mask
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/slv_cntr_mask
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_actual_gflow_buffer
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_actual_gflow_buffer_to_transfer
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_actual_gflow_buffer_to_transfer_rd_rdy
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_actual_gflow_buffer_to_transfer_rd_valid
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_actual_gflow_buffer_transferred
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {40900000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 644
configure wave -valuecolwidth 185
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
WaveRestoreZoom {0 ps} {169323105 ps}
