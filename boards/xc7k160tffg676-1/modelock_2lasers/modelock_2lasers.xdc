############################################################################
## System Clock
############################################################################

# ---- On-board Oscillator ----
# Positive
#set_property IOSTANDARD LVDS [get_ports CLK_IN1_D_0_clk_p]
#set_property PACKAGE_PIN AC4 [get_ports CLK_IN1_D_0_clk_p]

# Negative
#set_property IOSTANDARD LVDS [get_ports CLK_IN1_D_0_clk_n]
#set_property PACKAGE_PIN AC3 [get_ports CLK_IN1_D_0_clk_n]



############################################################################
## Inputs
############################################################################

# ---- External Input clocks ----
# clk_in1_0_LaserClk [FMCNAME: CLK1_M2C_P, FMCPIN: H4]
set_property IOSTANDARD LVTTL [get_ports clk_in1_0_LaserClk]
set_property PACKAGE_PIN E11 [get_ports clk_in1_0_LaserClk]

# clk_in1_1_LaserClk [FMCNAME: CLK0_M2C_P, FMCPIN: G2]
set_property IOSTANDARD LVTTL [get_ports clk_in1_1_LaserClk]
set_property PACKAGE_PIN E18 [get_ports clk_in1_1_LaserClk]



# ---- External asynchronous inputs ----
# Push button
#set_property IOSTANDARD LVCMOS33 [get_ports async_in_0]
#set_property PACKAGE_PIN D9 [get_ports async_in_0]


############################################################################
## Outputs
############################################################################

# ---- clk_wiz_0 ----
# clk_out1_0_PassThrough_0deg [FMCNAME: LA_03_P, FMCPIN: G9]
set_property IOSTANDARD LVTTL [get_ports clk_out1_0_PassThrough_0deg]
set_property PACKAGE_PIN A18 [get_ports clk_out1_0_PassThrough_0deg]

# clk_out2_0_PassThrough_180deg [FMCNAME: LA_02_P, FMCPIN: H7]
set_property IOSTANDARD LVTTL [get_ports clk_out2_0_PassThrough_180deg]
set_property PACKAGE_PIN G19 [get_ports clk_out2_0_PassThrough_180deg]

# clk_out3_0_10MHz [FMCNAME: LA_07_P, FMCPIN: H13]
set_property IOSTANDARD LVTTL [get_ports clk_out3_0_10MHz]
set_property PACKAGE_PIN J18 [get_ports clk_out3_0_10MHz]



# ---- clk_wiz_1 ----
# clk_out1_1_10MHz [FMCNAME: LA_08_P, FMCPIN: G12]
set_property IOSTANDARD LVTTL [get_ports clk_out1_1_10MHz]
set_property PACKAGE_PIN F19 [get_ports clk_out1_1_10MHz]

# clk_out2_1_PassThrough_0deg [FMCNAME: LA_16_P, FMCPIN: G18]
set_property IOSTANDARD LVTTL [get_ports clk_out2_1_PassThrough_0deg]
set_property PACKAGE_PIN A9 [get_ports clk_out2_1_PassThrough_0deg]

# clk_out3_1_100MHz [FMCNAME: LA_20_P, FMCPIN: G21]
set_property IOSTANDARD LVTTL [get_ports clk_out3_1_100MHz]
set_property PACKAGE_PIN L17 [get_ports clk_out3_1_100MHz]