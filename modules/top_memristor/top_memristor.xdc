############################################################################
# XEM7350 - Xilinx constraints file
#
# Pin mappings for the XEM7350.  Use this as a template and comment out 
# the pins that are not used in your design.  (By default, map will fail
# if this file contains constraints for signals not in your design).
#
# Copyright (c) 2004-2014 Opal Kelly Incorporated
############################################################################

# set_property CFGBVS GND [current_design]
# set_property CONFIG_VOLTAGE 1.8 [current_design]
# set_property BITSTREAM.GENERAL.COMPRESS True [current_design]


# set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets memristor_i/clk_wiz_0/inst/clk_out5]
# set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets memristor_i/top_memristor_0/inst_nff_cdcc_fedge_0/slv_level_out_2]
# set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets memristor_i/top_memristor_0/inst_nff_cdcc_fedge_0/slv_level_out_4]



############################################################################
## System Clock
############################################################################
# set_property IOSTANDARD LVDS [get_ports CLK_IN1_D_0_clk_p]
# set_property IOSTANDARD LVDS [get_ports CLK_IN1_D_0_clk_n]

# set_property PACKAGE_PIN AC4 [get_ports CLK_IN1_D_0_clk_p]
# set_property PACKAGE_PIN AC3 [get_ports CLK_IN1_D_0_clk_n]

# create_clock -name sys_clk -period 10 [get_ports SYS_CLK_P]

# create_clock -period 10.000 -name sys_clk [get_ports CLK_IN1_D_0_clk_p]

# CLK0_M2C_P	E18 (HA)
# set_property IOSTANDARD LVTTL [get_ports clk_in_76Mhz]
# set_property PACKAGE_PIN E18 [get_ports clk_in_76Mhz]
# set_property PACKAGE_PIN G9 [get_ports clk_in_76Mhz]

# CLK0_M2C_N	D18 (HA)


############################################################################
## FPGA PINS ON FMC BOARD KAYA INSTRUMENTS
############################################################################

# 01) A17: H35	LA_30_N	G9
# set_property IOSTANDARD LVTTL [get_ports PULSE_OUT_0]
# set_property PACKAGE_PIN G9 [get_ports PULSE_OUT_0]
# set_property PACKAGE_PIN D9 [get_ports PULSE_OUT_0]
# set_property SLEW FAST [get_ports {PULSE_OUT_0}]

# 02) A16: H32	H32	LA_28_N	F12
# set_property IOSTANDARD LVTTL [get_ports PHOTON_1V]
# set_property PACKAGE_PIN F12 [get_ports PHOTON_1V]
# set_property SLEW FAST [get_ports {PHOTON_1V}]

# 03) A15: D27	LA_26_N	B9
# set_property IOSTANDARD LVTTL [get_ports PHOTON_2H]
# set_property PACKAGE_PIN B9 [get_ports PHOTON_2H]
# set_property SLEW FAST [get_ports {PHOTON_2H}]

# 04) A14: H29	LA_24_N	G14
# set_property IOSTANDARD LVTTL [get_ports PHOTON_2V]
# set_property PACKAGE_PIN G14 [get_ports PHOTON_2V]
# set_property SLEW FAST [get_ports {PHOTON_2V}]

# 05) A12: G22	LA_20_N	K18
# set_property IOSTANDARD LVTTL [get_ports PHOTON_3H]
# set_property PACKAGE_PIN K18 [get_ports PHOTON_3H]
# set_property SLEW FAST [get_ports {PHOTON_3H}]

# 06) A10: G19	LA_16_N	A8
# set_property IOSTANDARD LVTTL [get_ports PHOTON_3V]
# set_property PACKAGE_PIN A8 [get_ports PHOTON_3V]
# set_property SLEW FAST [get_ports {PHOTON_3V}]

# 07) A08: G16	LA_12_N	G20
# set_property IOSTANDARD LVTTL [get_ports PHOTON_4H]
# set_property PACKAGE_PIN G20 [get_ports PHOTON_4H]
# set_property SLEW FAST [get_ports {PHOTON_4H}]

# 08) A07: C15	LA_10_N	A17
# set_property IOSTANDARD LVTTL [get_ports PHOTON_4V]
# set_property PACKAGE_PIN A17 [get_ports PHOTON_4V]
# set_property SLEW FAST [get_ports {PHOTON_4V}]

# 09) A05: C11	LA_06_N	B19
# set_property IOSTANDARD LVTTL [get_ports pulse_in]
# set_property PACKAGE_PIN B19 [get_ports pulse_in]
# set_property SLEW FAST [get_ports {pulse_in}]

# 10) A04: H11	LA_04_N	D20
# set_property IOSTANDARD LVTTL [get_ports clk_out10_0]
# set_property PACKAGE_PIN D20 [get_ports clk_out10_0]



############################################################################
## Set False Paths as Clock Domain Cross Boundaries with CDCC
############################################################################
# set_false_path -from [get_pins {}] -to [get_pins {}]
# set_false_path -from [get_pins {memristor_i/top_memristor_0/inst_nff_cdcc_fedge_0/sl_flop_eventgen_for_samplhz_reg/C}] -to [get_pins {memristor_i/top_memristor_0/inst_nff_cdcc_fedge_0/sl_asyncflop_eventgen_samplhz_1_reg/D}]
set_false_path -from [get_pins {memristor_i/top_memristor_0/U0/inst_nff_cdcc_fedge/slv_bit_to_cross_reg[1]/C}] -to [get_pins {memristor_i/top_memristor_0/U0/inst_nff_cdcc_fedge/slv_bit_asyncff_reg[0]/D}]
                                

# set_false_path -from [get_pins {memristor_i/top_memristor_0/inst_nff_cdcc_fedge_0/slv_sampled_data_reg[0]/C}] -to [get_pins {memristor_i/top_memristor_0/inst_nff_cdcc_fedge_0/sl_asyncflop_data_syshz_1_reg[0]/D}]
# set_false_path -from [get_pins {memristor_i/top_memristor_0/inst_nff_cdcc_fedge_0/slv_sampled_data_reg[2]/C}] -to [get_pins {memristor_i/top_memristor_0/inst_nff_cdcc_fedge_0/sl_asyncflop_data_syshz_1_reg[2]/D}]
# set_false_path -from [get_pins {memristor_i/top_memristor_0/inst_nff_cdcc_fedge_0/slv_sampled_data_reg[1]/C}] -to [get_pins {memristor_i/top_memristor_0/inst_nff_cdcc_fedge_0/sl_asyncflop_data_syshz_1_reg[1]/D}]
# set_false_path -from [get_pins {memristor_i/top_memristor_0/inst_nff_cdcc_fedge_0/sl_wr_en_event_reg/C}] -to [get_pins {memristor_i/top_memristor_0/inst_nff_cdcc_fedge_0/sl_asyncflop_event_syshz_1_reg/D}]

set_false_path -from [get_pins {memristor_i/top_memristor_0/U0/inst_nff_cdcc_fedge/slv_data_to_cross_2d_reg[1][0]/C}] -to [get_pins {memristor_i/top_memristor_0/U0/inst_nff_cdcc_fedge/slv_data_asyncff_2d_reg[0][0]/D}]
set_false_path -from [get_pins {memristor_i/top_memristor_0/U0/inst_nff_cdcc_fedge/slv_data_to_cross_2d_reg[1][1]/C}] -to [get_pins {memristor_i/top_memristor_0/U0/inst_nff_cdcc_fedge/slv_data_asyncff_2d_reg[0][1]/D}]
set_false_path -from [get_pins {memristor_i/top_memristor_0/U0/inst_nff_cdcc_fedge/slv_data_to_cross_2d_reg[1][2]/C}] -to [get_pins {memristor_i/top_memristor_0/U0/inst_nff_cdcc_fedge/slv_data_asyncff_2d_reg[0][2]/D}]
set_false_path -from [get_pins {memristor_i/top_memristor_0/U0/inst_nff_cdcc_fedge/slv_eventgen_to_cross_reg[1]/C}] -to [get_pins {memristor_i/top_memristor_0/U0/inst_nff_cdcc_fedge/slv_bit_asyncff_eventgen_reg[0]/D}]


############################################################################
## FrontPanel Host Interface
############################################################################
# set_property PACKAGE_PIN F23 [get_ports {okHU[0]}]
# set_property PACKAGE_PIN H23 [get_ports {okHU[1]}]
# set_property PACKAGE_PIN J25 [get_ports {okHU[2]}]
# set_property SLEW FAST [get_ports {okHU[*]}]
# set_property IOSTANDARD LVCMOS18 [get_ports {okHU[*]}]

# set_property PACKAGE_PIN F22 [get_ports {okUH[0]}]
# set_property PACKAGE_PIN G24 [get_ports {okUH[1]}]
# set_property PACKAGE_PIN J26 [get_ports {okUH[2]}]
# set_property PACKAGE_PIN G26 [get_ports {okUH[3]}]
# set_property PACKAGE_PIN C23 [get_ports {okUH[4]}]
# set_property IOSTANDARD LVCMOS18 [get_ports {okUH[*]}]

# set_property PACKAGE_PIN B21 [get_ports {okUHU[0]}]
# set_property PACKAGE_PIN C21 [get_ports {okUHU[1]}]
# set_property PACKAGE_PIN E22 [get_ports {okUHU[2]}]
# set_property PACKAGE_PIN A20 [get_ports {okUHU[3]}]
# set_property PACKAGE_PIN B20 [get_ports {okUHU[4]}]
# set_property PACKAGE_PIN C22 [get_ports {okUHU[5]}]
# set_property PACKAGE_PIN D21 [get_ports {okUHU[6]}]
# set_property PACKAGE_PIN C24 [get_ports {okUHU[7]}]
# set_property PACKAGE_PIN C26 [get_ports {okUHU[8]}]
# set_property PACKAGE_PIN D26 [get_ports {okUHU[9]}]
# set_property PACKAGE_PIN A24 [get_ports {okUHU[10]}]
# set_property PACKAGE_PIN A23 [get_ports {okUHU[11]}]
# set_property PACKAGE_PIN A22 [get_ports {okUHU[12]}]
# set_property PACKAGE_PIN B22 [get_ports {okUHU[13]}]
# set_property PACKAGE_PIN A25 [get_ports {okUHU[14]}]
# set_property PACKAGE_PIN B24 [get_ports {okUHU[15]}]
# set_property PACKAGE_PIN G21 [get_ports {okUHU[16]}]
# set_property PACKAGE_PIN E23 [get_ports {okUHU[17]}]
# set_property PACKAGE_PIN E21 [get_ports {okUHU[18]}]
# set_property PACKAGE_PIN H22 [get_ports {okUHU[19]}]
# set_property PACKAGE_PIN D23 [get_ports {okUHU[20]}]
# set_property PACKAGE_PIN J21 [get_ports {okUHU[21]}]
# set_property PACKAGE_PIN K22 [get_ports {okUHU[22]}]
# set_property PACKAGE_PIN D24 [get_ports {okUHU[23]}]
# set_property PACKAGE_PIN K23 [get_ports {okUHU[24]}]
# set_property PACKAGE_PIN H24 [get_ports {okUHU[25]}]
# set_property PACKAGE_PIN F24 [get_ports {okUHU[26]}]
# set_property PACKAGE_PIN D25 [get_ports {okUHU[27]}]
# set_property PACKAGE_PIN J24 [get_ports {okUHU[28]}]
# set_property PACKAGE_PIN B26 [get_ports {okUHU[29]}]
# set_property PACKAGE_PIN H26 [get_ports {okUHU[30]}]
# set_property PACKAGE_PIN E26 [get_ports {okUHU[31]}]
# set_property SLEW FAST [get_ports {okUHU[*]}]
# set_property IOSTANDARD LVCMOS18 [get_ports {okUHU[*]}]

# set_property PACKAGE_PIN R26 [get_ports {okAA}]
# set_property IOSTANDARD LVCMOS33 [get_ports {okAA}]


# create_clock -name okUH0 -period 9.920 [get_ports {okUH[0]}]
# create_clock -name virt_okUH0 -period 9.920

# set_clock_groups -name async-mmcm-user-virt -asynchronous -group {mmcm0_clk0} -group {virt_okUH0}

# set_input_delay -add_delay -max -clock [get_clocks {virt_okUH0}]  8.000 [get_ports {okUH[*]}]
# set_input_delay -add_delay -min -clock [get_clocks {virt_okUH0}]  0.000 [get_ports {okUH[*]}]

# set_input_delay -add_delay -max -clock [get_clocks {virt_okUH0}]  8.000 [get_ports {okUHU[*]}]
# set_input_delay -add_delay -min -clock [get_clocks {virt_okUH0}]  2.000 [get_ports {okUHU[*]}]

# set_output_delay -add_delay -max -clock [get_clocks {okUH0}]  2.000 [get_ports {okHU[*]}]
# set_output_delay -add_delay -min -clock [get_clocks {okUH0}]  -0.500 [get_ports {okHU[*]}]

# set_output_delay -add_delay -max -clock [get_clocks {okUH0}]  2.000 [get_ports {okUHU[*]}]
# set_output_delay -add_delay -min -clock [get_clocks {okUH0}]  -0.500 [get_ports {okUHU[*]}]


# # LEDs #####################################################################
# set_property PACKAGE_PIN T24 [get_ports {led[0]}]
# set_property PACKAGE_PIN T25 [get_ports {led[1]}]
# set_property PACKAGE_PIN R25 [get_ports {led[2]}]
# set_property PACKAGE_PIN P26 [get_ports {led[3]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]
