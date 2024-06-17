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

# MMCM output clocks
set inst_name "inst_clock_synthesizer"
create_clock -name acq_clk -period 1.666667 [get_ports inst_gflow/${inst_name}/mmcm_out_clk[0]]
create_clock -name sampl_clk -period 3.333334 [get_ports inst_gflow/${inst_name}/mmcm_out_clk[1]]
create_clock -name sys_clk -period 5 [get_ports inst_gflow/${inst_name}/mmcm_out_clk[2]]


############################################################################
## FPGA PINS ON FMC BOARD KAYA INSTRUMENTS
############################################################################

# ----- INPUTS -----
# Properties:
set_property IOSTANDARD LVTTL [get_ports input_pads[*]]


# 01) Photon 1H: (FMC Board Pin A17 | ANSI No. H35 LA_30_N | FPGA Pin G9)
set_property PACKAGE_PIN G9  [get_ports input_pads[7]]

# 02) Photon 1V: (FMC Board Pin A16 | ANSI No. H32 LA_28_N | FPGA Pin F12)
set_property PACKAGE_PIN F12 [get_ports input_pads[6]]

# 03) Photon 2H: (FMC Board Pin A15 | ANSI No. D27 LA_26_N | FPGA Pin B9)
set_property PACKAGE_PIN B9  [get_ports input_pads[5]]

# 04) Photon 2V: (FMC Board Pin A14 | ANSI No. H29 LA_24_N | FPGA Pin G14)
set_property PACKAGE_PIN G14 [get_ports input_pads[4]]

# 05) Photon 3H: (FMC Board Pin A12 | ANSI No. G22 LA_20_N | FPGA Pin K18)
set_property PACKAGE_PIN K18 [get_ports input_pads[3]]

# 06) Photon 3V: (FMC Board Pin A10 | ANSI No. G19 LA_16_N | FPGA Pin A8)
set_property PACKAGE_PIN A8  [get_ports input_pads[2]]

# 07) Photon 4H: (FMC Board Pin A08 | ANSI No. G16 LA_12_N | FPGA Pin G20)
set_property PACKAGE_PIN G20 [get_ports input_pads[1]]

# 08) Photon 4V: (FMC Board Pin A07 | ANSI No. C15 LA_10_N | FPGA Pin A17)
set_property PACKAGE_PIN A17 [get_ports input_pads[0]]



# ----- OUTPUTS -----
# Properties:
set_property IOSTANDARD LVTTL [get_ports output_pads[*]]
set_property SLEW FAST [get_ports {output_pads[*]}]

# 09) PCD Trigger: (FMC Board Pin A05 | ANSI No. C11 LA_06_N | FPGA Pin B19)
set_property PACKAGE_PIN B19 [get_ports output_pads[0]]

# 10) A04: H11 LA_04_N D20
# set_property IOSTANDARD LVTTL [get_ports clk_out10_0]
# set_property PACKAGE_PIN D20 [get_ports clk_out10_0]



############################################################################
## Set Clock Domain Crossing Constraints
############################################################################
# Best = 1.36 -> explore around 1.36 (best found at 625 MHz)
# *** Do not remove this in "nff_cdcc" to pass timing
#       attribute KEEP : string; and attribute DONT_TOUCH : string;

# set max_delay1 1.59 (best found)
set max_delay1 1.59
set max_delay2 1.65

# Uncertainty 0.176
set min_delay1 [expr - 0.176]
set min_delay2 [expr - 0.178]


# max_delay constraint: to cover/override setup checks
# min_delay constraint: to cover/override hold checks
#    crossing path
set inst_name "inst_nff_cdcc_cntcross_samplclk_bit1"
set_max_delay $max_delay1 -from [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
set_min_delay $min_delay1 -from [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
set_max_delay $max_delay1 -from [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];
set_min_delay $min_delay1 -from [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];

set inst_name "inst_nff_cdcc_cntcross_samplclk_bit2"
set_max_delay $max_delay1 -from [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
set_min_delay $min_delay1 -from [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
set_max_delay $max_delay1 -from [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];
set_min_delay $min_delay1 -from [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];

set inst_name "inst_nff_cdcc_cntcross_samplclk_bit2"
set_max_delay $max_delay2 -from [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.rd_valid_reg] -to [get_cells inst_gflow/inst_okHost_fifo_ctrl/slv_wr_valid_qubit_flags_p1_reg[*]];
set_min_delay $min_delay2 -from [get_cells inst_gflow/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.rd_valid_reg] -to [get_cells inst_gflow/inst_okHost_fifo_ctrl/slv_wr_valid_qubit_flags_p1_reg[*]];

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
