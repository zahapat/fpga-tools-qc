# Master XDC for Genesys 2:
# https://github.com/Digilent/digilent-xdc/blob/master/Genesys-2-Master.xdc


############################################################################
## Configuration Design Properties
############################################################################
# Configuration design voltage
set_property CONFIG_VOLTAGE 1.8 [current_design]

# Configuration bank voltage select
set_property CFGBVS GND [current_design]

# Bitstream compression
set_property BITSTREAM.GENERAL.COMPRESS True [current_design]



############################################################################
## System Clock
############################################################################

# ---- On-board Oscillator ----
# Positive
set_property IOSTANDARD LVDS [get_ports CLK_IN1_D_0_clk_p]
set_property PACKAGE_PIN AD12 [get_ports CLK_IN1_D_0_clk_p]

# Negative
set_property IOSTANDARD LVDS [get_ports CLK_IN1_D_0_clk_n]
set_property PACKAGE_PIN AD11 [get_ports CLK_IN1_D_0_clk_n]



############################################################################
## Inputs
############################################################################

# ---- External Input clocks ----
# clk_in1_0_LaserClk [FMCNAME: CLK1_M2C_P, FMCPIN: H4]
# set_property IOSTANDARD LVTTL [get_ports clk_in1_0_LaserClk]
# set_property PACKAGE_PIN E28 [get_ports clk_in1_0_LaserClk]

# clk_in1_1_LaserClk [FMCNAME: CLK0_M2C_P, FMCPIN: G2]
# set_property IOSTANDARD LVTTL [get_ports clk_in1_1_LaserClk]
# set_property PACKAGE_PIN F20 [get_ports clk_in1_1_LaserClk]



# ---- External asynchronous inputs ----
# unnamed_pin [FMCNAME: LA11_P, FMCPIN: H16]
set_property IOSTANDARD LVTTL [get_ports pulse_in_0]
# set_property PACKAGE_PIN A25 [get_ports pulse_in_0]
set_property PACKAGE_PIN G22 [get_ports pulse_in_0]


############################################################################
## Outputs
############################################################################

# ---- clk_wiz_0 ----
# clk_out1_0_PassThrough_0deg [FMCNAME: LA_03_P, FMCPIN: G9]
# set_property IOSTANDARD LVTTL [get_ports clk_out1_0_PassThrough_180deg]
# set_property PACKAGE_PIN E29 [get_ports clk_out1_0_PassThrough_180deg]

# clk_out2_0_PassThrough_180deg [FMCNAME: LA_02_P, FMCPIN: H7]
# set_property IOSTANDARD LVTTL [get_ports clk_out2_0_PassThrough_0deg]
# set_property PACKAGE_PIN H30 [get_ports clk_out2_0_PassThrough_0deg]

# clk_out3_0_10MHz [FMCNAME: LA_07_P, FMCPIN: H13]
# set_property IOSTANDARD LVTTL [get_ports clk_out3_0_10MHz]
# set_property PACKAGE_PIN F25 [get_ports clk_out3_0_10MHz]



# ---- clk_wiz_1 ----
# clk_out1_1_10MHz [FMCNAME: LA_08_P, FMCPIN: G12]
# set_property IOSTANDARD LVTTL [get_ports clk_out1_1_10MHz]
# set_property PACKAGE_PIN C29 [get_ports clk_out1_1_10MHz]

# clk_out2_1_PassThrough_0deg [FMCNAME: LA_16_P, FMCPIN: G18]
# set_property IOSTANDARD LVTTL [get_ports clk_out2_1_PassThrough_0deg]
# set_property PACKAGE_PIN E23 [get_ports clk_out2_1_PassThrough_0deg]

# clk_out3_1_100MHz [FMCNAME: LA_20_P, FMCPIN: G21]
# set_property IOSTANDARD LVTTL [get_ports clk_out3_1_100MHz]
# set_property PACKAGE_PIN G22 [get_ports clk_out3_1_100MHz]



# ---- top_memristor_0 ----
# clk_out3_1_pulse_out [FMCNAME: LA_20_P, FMCPIN: G21]
set_property IOSTANDARD LVTTL [get_ports pulse_out_0]
# set_property PACKAGE_PIN G22 [get_ports pulse_out_0]
set_property PACKAGE_PIN E23 [get_ports pulse_out_0]



############################################################################
## FPGA-specific constraints
############################################################################

# Workaround to enable other BUFGs to be part of a cascade, not only the adjacent ones
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets memristor_i/top_memristor_0/U0/inst_memristor_ctrl/slv_level_out_2]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets memristor_i/top_memristor_0/U0/inst_memristor_ctrl/slv_level_out_4]