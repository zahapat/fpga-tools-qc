## Description

This module contains the RTL hardware architecture of a feedforward controller project and a testbench. It contains lower level modules and information about how they are interconnected in the design.

The source file, located in 'hdl' directory, is a structural hardware description file with three clock domains: 

1. 600 MHz clock domain for analog pulse sampling from single photon detectors and delay compensation of horizontal and vertical photons.
2. 400 MHz clock domain for performing feedforward, photon counting and probing signals for readout.
3. 200 MHz clock domain for readout using 32-bit csv_readout module, which allows to write to multiple '.csv' files and group multidimensional data together.

The ./hdl folder also consists of 'top_feedforward_ok_wrapper.vhd', which wraps up the 'top_feedforward.vhd' module, and instantiates Opal Kelly Frontpanel Host for high-speed USB 3.0 communication with the FPGA and PC. Once all required source files are loaded in Vivado, the 'top_feedforward_ok_wrapper.vhd' can be dragged-and-dropped into the schematic board designer.


# 500 MHz DSP Clock: Timing Report of Failed Traces
TCL: ----- Timing Report -----

Slack -0.234 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
set_max_delay 1.500 -datapath_only \
-from [get_cells inst_top_gflow/inst_reg_delay_eom_pulse/gen_delay_line[2].slv_buffer_reg_2d_reg[3][0]]\
  -to [get_cells inst_top_gflow/inst_xilinx_obuf_eom/gen_obufs[0].inst_fdre_ologic]

Slack -0.134 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
set_max_delay 1.500 -datapath_only \
-from [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[2][5]]\
  -to [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_state_feedforward_reg[0]]   

Slack -0.088 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
set_max_delay 1.500 -datapath_only \
-from [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[2][2]]\
  -to [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[3][1]]

Slack -0.088 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
set_max_delay 1.500 -datapath_only \
-from [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[2][2]]\
  -to [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[3][2]]

Slack -0.088 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
set_max_delay 1.500 -datapath_only \
-from [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[2][2]]\
  -to [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[3][3]]

Slack -0.088 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
set_max_delay 1.500 -datapath_only \
-from [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[2][2]]\
  -to [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[3][4]]

Slack -0.088 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
set_max_delay 1.500 -datapath_only \
-from [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[2][2]]\
  -to [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[3][5]]

Slack -0.088 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
set_max_delay 1.500 -datapath_only \
-from [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[2][2]]\
  -to [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[3][6]]

Slack -0.028 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
-from [get_cells inst_top_gflow/gen_reg_delays_before_eom[2].inst_shiftreg_delay_eom_pulse/gen_delay_line[0].slv_buffer_shiftreg_reg[1]]\
  -to [get_cells inst_top_gflow/inst_xilinx_obuf_debug1/gen_obufs[0].inst_fdre_ologic]

TCL: ----- End of Timing Report -----


# After applying the above constraints

TCL: ----- Timing Report (can be modified in XDC file) -----

Slack -0.317 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
set_max_delay 1.500 -datapath_only \
-from [get_cells inst_top_gflow/gen_reg_delays_before_eom[2].inst_shiftreg_delay_eom_pulse/gen_delay_line[0].slv_buffer_shiftreg_reg[1]]\
  -to [get_cells inst_top_gflow/inst_xilinx_obuf_debug1/gen_obufs[0].inst_fdre_ologic]

Slack -0.216 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
set_max_delay 1.500 -datapath_only \
-from [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[2][5]_replica]\
  -to [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_state_feedforward_reg[0]]   

Slack -0.190 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
set_max_delay 1.500 -datapath_only \
-from [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[2][2]_replica]\
  -to [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[3][1]]

Slack -0.190 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
set_max_delay 1.500 -datapath_only \
-from [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[2][2]_replica]\
  -to [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[3][2]]

Slack -0.190 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
set_max_delay 1.500 -datapath_only \
-from [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[2][2]_replica]\
  -to [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[3][4]]

Slack -0.190 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
set_max_delay 1.500 -datapath_only \
-from [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[2][2]_replica]\
  -to [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[3][5]]

Slack -0.190 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
set_max_delay 1.500 -datapath_only \
-from [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[2][2]_replica]\
  -to [get_cells inst_top_gflow/inst_fsm_gflow/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_2d_reg[3][6]]

TCL: ----- End of Timing Report -----