############################################################################
# XEM7350 - Xilinx constraints file
#
# Pin mappings for the XEM7350.  Use this as a template and comment out 
# the pins that are not used in your design.  (By default, map will fail
# if this file contains constraints for signals not in your design).
#
# Copyright (c) 2004-2014 Opal Kelly Incorporated
############################################################################

set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS True [current_design]

############################################################################
## System Clock
############################################################################
set_property IOSTANDARD LVDS [get_ports sys_clk_p]
set_property IOSTANDARD LVDS [get_ports sys_clk_n]

set_property PACKAGE_PIN AC4 [get_ports sys_clk_p]
set_property PACKAGE_PIN AC3 [get_ports sys_clk_n]

# Differential clock (200 MHz Differential)
create_clock -period 5.0 [get_ports sys_clk_p]
set_input_jitter [get_clocks -of_objects [get_ports sys_clk_p]] 0.05


############################################################################
## PIN ASSIGNMENT ON FMC BREAKOUT BOARD ./pcb/FMC-HPC-BRK/
############################################################################
# U.CL Pin Name   FMC Pin   FPGA Port   I/O Bank   Position (Top->Bot)   Information
# -------------------------------------------------------------------------------------------
# LA32_P1         H37(LA)       H9       16(HR)        1(Left Side)    : Photon 1V
# LA31_P1         G33(LA)      J11       16(HR)        2(L)            : Photon 1H
# LA33_P1         G36(LA)       F9       16(HR)        3(L)            : Photon 2V
# LA22_P1         G24(LA)      G11       16(HR)        4(L)            : Photon 2H
# LA17_P_CC1      D20(LA)      E10       16(HR)        5(L)            : available
# LA21_P1         H25(LA)      G15       15(HR)        6(L)            : Photon 3V
# LA25_P1         G27(LA)      J15       15(HR)        7(L)            : Photon 3H
# LA01_P_CC1       D8(LA)      G17       15(HR)        8(L)            : available
# LA18P_CC1       C22(LA)      F17       15(HR)        9(L)            : available
# LA00_P_CC1       G6(LA)      H17       15(HR)       10(L)            : available
# LA07_P1         H13(LA)      J18       15(HR)       11(L)            : Photon 4V
# LA09_P1         D14(LA)      L19       15(HR)       12(L)            : Photon 4H
# HA10_P1         K13(HA)     AA23       12(HR)       13(L)            : o_photon_sampled, Not on K70T
# HA17_P_CC1      K16(HA)     AC23       12(HR)       14(L)            : o_pcd_ctrl_pulse, Not on K70T
# HA06_P1         K10(HA)     AB22       12(HR)       15(L)            : available, Not on K70T
# HA18_P1         J18(HA)     AD21       12(HR)       16(L)            : available, Not on K70T
# HA04_P1          F7(HA)     AF24       12(HR)       17(L)            : available, NOT on K70T
# HA02_P1          K7(HA)     AE23       12(HR)       18(L)            : available, Not on K70T
# HA13_P1         E12(HA)      Y25       12(HR)       19(L)            : available, Not on K70T
# HA01_P_CC1       E2(HA)      Y23       12(HR)       20(L)            : available, Not on K70T
# HA00_P_CC1       F4(HA)      Y22       12(HR)       21(L)            : available, Not on K70T
# HB21_P1         E36(HB)     AE18       32(HP)        1(Right Side)   : available, Not on K70T
# HB20_P1         F37(HB)     AF19       32(HP)        2(R)            : available, Not on K70T
# HB10_P1         K31(HB)      Y15       32(HP)        3(R)            : available, Not on K70T
# HB00_P_CC1      K25(HB)     AA17       32(HP)        4(R)            : available, Not on K70T
# HB17_P_CC1      K37(HB)     AC18       32(HP)        5(R)            : available, Not on K70T
# HB06_P_CC1      K28(HB)     AB17       32(HP)        6(R)            : available, Not on K70T
# HB06_N_CC1      K29(HB)     AC17       32(HP)        7(R)            : available, Not on K70T
# HB18_P1         J36(HB)     AD20       32(HP)        8(R)            : available, Not on K70T

# Dedicated Clock Pins
# CLK0_M2C_P1      H4(LA)      E18       15(HR)                        : available
# CLK1_M2C_P1      G2(LA)      E11       16(HR)                        : available
# CLK2_BIDIR_P1    K4(HA)      C12       16(HR)                        : available
# CLK3_BIDIR_P1    J2(HB)     AB16       32(HP)                        : available, Not on K70T




# ----- INPUTS -----
# Properties:
set_property IOSTANDARD LVTTL [get_ports input_pads[*]]

# Photon 4H
set_property PACKAGE_PIN L19 [get_ports input_pads[7]]

# Photon 4V
set_property PACKAGE_PIN J18 [get_ports input_pads[6]]

# Photon 3H
set_property PACKAGE_PIN J15 [get_ports input_pads[5]]

# Photon 3V
set_property PACKAGE_PIN G15 [get_ports input_pads[4]]

# Photon 2H
set_property PACKAGE_PIN G11 [get_ports input_pads[3]]

# Photon 2V
set_property PACKAGE_PIN F9  [get_ports input_pads[2]]

# Photon 1H
set_property PACKAGE_PIN J11 [get_ports input_pads[1]]

# Photon 1V
set_property PACKAGE_PIN H9  [get_ports input_pads[0]]



# ----- OUTPUTS -----
# PCD Trigger
set_property IOSTANDARD LVTTL [get_ports o_pcd_ctrl_pulse]
set_property SLEW FAST [get_ports {o_pcd_ctrl_pulse}]
set_property PACKAGE_PIN AC23 [get_ports o_pcd_ctrl_pulse]

# PHOTON X SAMPLED PULSE
set_property IOSTANDARD LVTTL [get_ports o_photon_sampled]
set_property SLEW FAST [get_ports {o_photon_sampled}]
set_property PACKAGE_PIN AA23 [get_ports o_photon_sampled]




############################################################################
## Set Clock Domain Crossing Constraints
############################################################################
# Best = 1.36 -> explore around 1.36 (best found at 625 MHz)
# *** Do not remove this in "nff_cdcc*" modules to pass timing
#       attribute KEEP : string; and attribute DONT_TOUCH : string;

# Setting for 600->300 Mhz and 300->200 MHz crossing domains
set max_delay1 1.6
set max_delay2 1.69

set clk_uncertainty1 0.176
set clk_uncertainty2 0.178

# Uncertainty consideration
set min_delay1 [expr - ${clk_uncertainty1}]
set min_delay2 [expr - ${clk_uncertainty2}]

# Timing Results:
# Time (s): cpu = 00:00:44 ; elapsed = 00:00:42 . Memory (MB): peak = 2246.609 ; gain = 179.996
# INFO: [Route 35-61] The design met the timing requirement.
# INFO: [Route 72-16] Aggressive Explore Summary
# +------+-------+-------+-------+-------+--------+--------------+-------------------+
# | Pass |  WNS  |  TNS  |  WHS  |  THS  | Status | Elapsed Time | Solution Selected |
# +------+-------+-------+-------+-------+--------+--------------+-------------------+
# |  1   | 0.006 | 0.000 | 0.066 | 0.000 |  Pass  |   00:00:26   |         x         |
# +------+-------+-------+-------+-------+--------+--------------+-------------------+
# |  2   |   -   |   -   |   -   |   -   |  Fail  |   00:00:00   |                   |
# +------+-------+-------+-------+-------+--------+--------------+-------------------+


# max_delay constraint: to cover/override setup checks
# min_delay constraint: to cover/override hold checks
#    crossing path
set inst_name "inst_nff_cdcc_cntcross_samplclk_bit1"
set_max_delay $max_delay1 -from [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
set_min_delay $min_delay1 -from [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];

set inst_name "inst_nff_cdcc_cntcross_samplclk_bit2"
set_max_delay $max_delay1 -from [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
set_min_delay $min_delay1 -from [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];

set inst_name "inst_nff_cdcc_success_done"
set_max_delay $max_delay2 -from [get_cells inst_gflow/${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
set_min_delay $min_delay2 -from [get_cells inst_gflow/${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
set_max_delay $max_delay2 -from [get_cells inst_gflow/${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_gflow/${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];
set_min_delay $min_delay2 -from [get_cells inst_gflow/${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_gflow/${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];

set inst_name "inst_nff_cdcc_timestamp_buffer"
set_max_delay $max_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
set_min_delay $min_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
set_max_delay $max_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];
set_min_delay $min_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];

set inst_name "inst_nff_cdcc_qubit_buffer"
set_max_delay $max_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
set_min_delay $min_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
set_max_delay $max_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];
set_min_delay $min_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];

set inst_name "inst_nff_cdcc_alpha_buffer"
set_max_delay $max_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
set_min_delay $min_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
set_max_delay $max_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];
set_min_delay $min_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];

set inst_name "inst_nff_cdcc_modulo_buffer"
set_max_delay $max_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
set_min_delay $min_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
set_max_delay $max_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];
set_min_delay $min_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];

set inst_name "inst_nff_cdcc_random_buffer"
set_max_delay $max_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
set_min_delay $min_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
set_max_delay $max_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];
set_min_delay $min_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];

set inst_name "inst_nff_cdcc_cntr_ch_photons"
set_max_delay $max_delay2 -from [get_cells inst_gflow/gen_cdcc_cntr_ch_photons[*].${inst_name}/slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_gflow/gen_cdcc_cntr_ch_photons[*].${inst_name}/slv_data_asyncff_2d_reg[0][*]];
set_min_delay $min_delay2 -from [get_cells inst_gflow/gen_cdcc_cntr_ch_photons[*].${inst_name}/slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_gflow/gen_cdcc_cntr_ch_photons[*].${inst_name}/slv_data_asyncff_2d_reg[0][*]];

set inst_name "inst_nff_cdcc_photon_loss_event"
set_max_delay $max_delay2 -from [get_cells inst_gflow/gen_cdcc_photon_losses_flags[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_cdcc_photon_losses_flags[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
set_min_delay $min_delay2 -from [get_cells inst_gflow/gen_cdcc_photon_losses_flags[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_cdcc_photon_losses_flags[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];

# set inst_name "inst_module_name"
# set_max_delay $max_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
# set_min_delay $min_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
# set_max_delay $max_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];
# set_min_delay $min_delay2 -from [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_gflow/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];


# set_max_delay $max_delay1 -from [get_cells ] -to [get_cells ];
# set_min_delay $min_delay1 -from [get_cells ] -to [get_cells ];

# set_max_delay $max_delay2 -from [get_cells ] -to [get_cells ];
# set_min_delay $min_delay2 -from [get_cells ] -to [get_cells ];



############################################################################
## FrontPanel Host Interface
############################################################################
set_property PACKAGE_PIN F23 [get_ports {okHU[0]}]
set_property PACKAGE_PIN H23 [get_ports {okHU[1]}]
set_property PACKAGE_PIN J25 [get_ports {okHU[2]}]
set_property SLEW FAST [get_ports {okHU[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {okHU[*]}]

set_property PACKAGE_PIN F22 [get_ports {okUH[0]}]
set_property PACKAGE_PIN G24 [get_ports {okUH[1]}]
set_property PACKAGE_PIN J26 [get_ports {okUH[2]}]
set_property PACKAGE_PIN G26 [get_ports {okUH[3]}]
set_property PACKAGE_PIN C23 [get_ports {okUH[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {okUH[*]}]

set_property PACKAGE_PIN B21 [get_ports {okUHU[0]}]
set_property PACKAGE_PIN C21 [get_ports {okUHU[1]}]
set_property PACKAGE_PIN E22 [get_ports {okUHU[2]}]
set_property PACKAGE_PIN A20 [get_ports {okUHU[3]}]
set_property PACKAGE_PIN B20 [get_ports {okUHU[4]}]
set_property PACKAGE_PIN C22 [get_ports {okUHU[5]}]
set_property PACKAGE_PIN D21 [get_ports {okUHU[6]}]
set_property PACKAGE_PIN C24 [get_ports {okUHU[7]}]
set_property PACKAGE_PIN C26 [get_ports {okUHU[8]}]
set_property PACKAGE_PIN D26 [get_ports {okUHU[9]}]
set_property PACKAGE_PIN A24 [get_ports {okUHU[10]}]
set_property PACKAGE_PIN A23 [get_ports {okUHU[11]}]
set_property PACKAGE_PIN A22 [get_ports {okUHU[12]}]
set_property PACKAGE_PIN B22 [get_ports {okUHU[13]}]
set_property PACKAGE_PIN A25 [get_ports {okUHU[14]}]
set_property PACKAGE_PIN B24 [get_ports {okUHU[15]}]
set_property PACKAGE_PIN G21 [get_ports {okUHU[16]}]
set_property PACKAGE_PIN E23 [get_ports {okUHU[17]}]
set_property PACKAGE_PIN E21 [get_ports {okUHU[18]}]
set_property PACKAGE_PIN H22 [get_ports {okUHU[19]}]
set_property PACKAGE_PIN D23 [get_ports {okUHU[20]}]
set_property PACKAGE_PIN J21 [get_ports {okUHU[21]}]
set_property PACKAGE_PIN K22 [get_ports {okUHU[22]}]
set_property PACKAGE_PIN D24 [get_ports {okUHU[23]}]
set_property PACKAGE_PIN K23 [get_ports {okUHU[24]}]
set_property PACKAGE_PIN H24 [get_ports {okUHU[25]}]
set_property PACKAGE_PIN F24 [get_ports {okUHU[26]}]
set_property PACKAGE_PIN D25 [get_ports {okUHU[27]}]
set_property PACKAGE_PIN J24 [get_ports {okUHU[28]}]
set_property PACKAGE_PIN B26 [get_ports {okUHU[29]}]
set_property PACKAGE_PIN H26 [get_ports {okUHU[30]}]
set_property PACKAGE_PIN E26 [get_ports {okUHU[31]}]
set_property SLEW FAST [get_ports {okUHU[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {okUHU[*]}]

set_property PACKAGE_PIN R26 [get_ports {okAA}]
set_property IOSTANDARD LVCMOS33 [get_ports {okAA}]


create_clock -name okUH0 -period 9.920 [get_ports {okUH[0]}]
create_clock -name virt_okUH0 -period 9.920

set_clock_groups -name async-mmcm-user-virt -asynchronous -group {mmcm0_clk0} -group {virt_okUH0}

# [Constraints 18-96] Setting input delay on a clock pin 'okUH[0]' is not supported, ignoring it ["C:/Git/zahapat/fpga-tools-qc/modules/top_gflow/xem7350_gflow.xdc":156]
# set_input_delay -add_delay -max -clock [get_clocks {virt_okUH0}]  8.000 [get_ports {okUH[*]}]
# set_input_delay -add_delay -min -clock [get_clocks {virt_okUH0}]  0.000 [get_ports {okUH[*]}]

set_input_delay -add_delay -max -clock [get_clocks {virt_okUH0}]  8.000 [get_ports {okUHU[*]}]
set_input_delay -add_delay -min -clock [get_clocks {virt_okUH0}]  2.000 [get_ports {okUHU[*]}]

set_output_delay -add_delay -max -clock [get_clocks {okUH0}]  2.000 [get_ports {okHU[*]}]
set_output_delay -add_delay -min -clock [get_clocks {okUH0}]  -0.500 [get_ports {okHU[*]}]

set_output_delay -add_delay -max -clock [get_clocks {okUH0}]  2.000 [get_ports {okUHU[*]}]
set_output_delay -add_delay -min -clock [get_clocks {okUH0}]  -0.500 [get_ports {okUHU[*]}]


############################################################################
## LEDs
############################################################################
set_property PACKAGE_PIN T24 [get_ports {led[0]}]
set_property PACKAGE_PIN T25 [get_ports {led[1]}]
set_property PACKAGE_PIN R25 [get_ports {led[2]}]
set_property PACKAGE_PIN P26 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]
