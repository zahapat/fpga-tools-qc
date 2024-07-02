onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: top_gflow_tb ALL signals}
add wave -noupdate /top_gflow_tb/sys_clk_p
add wave -noupdate /top_gflow_tb/sys_clk_n
add wave -noupdate /top_gflow_tb/led
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
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_gflow_success_done
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_gflow_success_done_transferred
add wave -noupdate -expand /top_gflow_tb/dut_top_gflow/pcd_ctrl_pulse_ready
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/pcd_ctrl_pulse_ready_p1
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/pcd_ctrl_pulse_fedge_latched
add wave -noupdate -divider {TB: top_gflow INTERNAL signals}
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/PHOTON_HV_SYNCHRONIZATION_DELAY
add wave -noupdate /top_gflow_tb/dut_top_gflow/sys_clk
add wave -noupdate /top_gflow_tb/dut_top_gflow/sampl_clk
add wave -noupdate /top_gflow_tb/dut_top_gflow/acq_clk
add wave -noupdate /top_gflow_tb/dut_top_gflow/sl_gflow_success_flag
add wave -noupdate -color Gold /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/int_state_gflow
add wave -noupdate -radix unsigned -childformat {{/top_gflow_tb/dut_top_gflow/inst_fsm_gflow/slv_counter_skip_qubits(0) -radix unsigned}} -subitemconfig {/top_gflow_tb/dut_top_gflow/inst_fsm_gflow/slv_counter_skip_qubits(0) {-height 15 -radix unsigned}} /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/slv_counter_skip_qubits
add wave -noupdate /top_gflow_tb/dut_top_gflow/inst_fsm_gflow/int_main_counter
add wave -noupdate -expand /top_gflow_tb/input_pads
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
add wave -noupdate /top_gflow_tb/s_i_to_fsm_gflow_delay_upper_bound_ns
add wave -noupdate /top_gflow_tb/s_i_to_fsm_gflow_delay_lower_bound_ns
add wave -noupdate /top_gflow_tb/s_i_to_fsm_gflow_delay_avg_ns
add wave -noupdate /top_gflow_tb/int_successful_flows_counter
add wave -noupdate /top_gflow_tb/int_failed_flows_counter
add wave -noupdate /top_gflow_tb/s_qubits_transmitted_cnt
add wave -noupdate /top_gflow_tb/s_photons_allcombinations_acc
add wave -noupdate /top_gflow_tb/dut_top_gflow/slv_unsuccessful_cntr_2d
add wave -noupdate /top_gflow_tb/readout_clk
add wave -noupdate /top_gflow_tb/readout_data_ready
add wave -noupdate /top_gflow_tb/readout_data_valid
add wave -noupdate /top_gflow_tb/readout_enable
add wave -noupdate /top_gflow_tb/readout_data_32b
add wave -noupdate /top_gflow_tb/readout_photons
add wave -noupdate /top_gflow_tb/readout_alpha
add wave -noupdate /top_gflow_tb/readout_random
add wave -noupdate /top_gflow_tb/readout_modulo
add wave -noupdate /top_gflow_tb/readout_timestamps
add wave -noupdate /top_gflow_tb/readout_csv1_line_done_event
add wave -noupdate -childformat {{/top_gflow_tb/readout_coincidences(15) -radix unsigned} {/top_gflow_tb/readout_coincidences(14) -radix unsigned} {/top_gflow_tb/readout_coincidences(13) -radix unsigned} {/top_gflow_tb/readout_coincidences(12) -radix unsigned} {/top_gflow_tb/readout_coincidences(11) -radix unsigned} {/top_gflow_tb/readout_coincidences(10) -radix unsigned} {/top_gflow_tb/readout_coincidences(9) -radix unsigned} {/top_gflow_tb/readout_coincidences(8) -radix unsigned} {/top_gflow_tb/readout_coincidences(7) -radix unsigned} {/top_gflow_tb/readout_coincidences(6) -radix unsigned} {/top_gflow_tb/readout_coincidences(5) -radix unsigned} {/top_gflow_tb/readout_coincidences(4) -radix unsigned} {/top_gflow_tb/readout_coincidences(3) -radix unsigned} {/top_gflow_tb/readout_coincidences(2) -radix unsigned} {/top_gflow_tb/readout_coincidences(1) -radix unsigned} {/top_gflow_tb/readout_coincidences(0) -radix unsigned}} -subitemconfig {/top_gflow_tb/readout_coincidences(15) {-height 15 -radix unsigned} /top_gflow_tb/readout_coincidences(14) {-height 15 -radix unsigned} /top_gflow_tb/readout_coincidences(13) {-height 15 -radix unsigned} /top_gflow_tb/readout_coincidences(12) {-height 15 -radix unsigned} /top_gflow_tb/readout_coincidences(11) {-height 15 -radix unsigned} /top_gflow_tb/readout_coincidences(10) {-height 15 -radix unsigned} /top_gflow_tb/readout_coincidences(9) {-height 15 -radix unsigned} /top_gflow_tb/readout_coincidences(8) {-height 15 -radix unsigned} /top_gflow_tb/readout_coincidences(7) {-height 15 -radix unsigned} /top_gflow_tb/readout_coincidences(6) {-height 15 -radix unsigned} /top_gflow_tb/readout_coincidences(5) {-height 15 -radix unsigned} /top_gflow_tb/readout_coincidences(4) {-height 15 -radix unsigned} /top_gflow_tb/readout_coincidences(3) {-height 15 -radix unsigned} /top_gflow_tb/readout_coincidences(2) {-height 15 -radix unsigned} /top_gflow_tb/readout_coincidences(1) {-height 15 -radix unsigned} /top_gflow_tb/readout_coincidences(0) {-height 15 -radix unsigned}} /top_gflow_tb/readout_coincidences
add wave -noupdate /top_gflow_tb/readout_csv2_line_done_event
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3333019 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 546
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
WaveRestoreZoom {0 ps} {51978938 ps}
