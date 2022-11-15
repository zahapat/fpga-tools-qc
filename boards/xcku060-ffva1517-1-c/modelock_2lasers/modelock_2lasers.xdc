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
# clk_in1_0_LaserClk
set_property IOSTANDARD LVCMOS18 [get_ports clk_in1_0_LaserClk]
set_property PACKAGE_PIN AL27 [get_ports clk_in1_0_LaserClk]

# clk_in1_1_LaserClk
set_property IOSTANDARD LVCMOS18 [get_ports clk_in1_1_LaserClk]
set_property PACKAGE_PIN AL30 [get_ports clk_in1_1_LaserClk]



# ---- External asynchronous inputs ----
# Push button
#set_property IOSTANDARD LVCMOS33 [get_ports async_in_0]
#set_property PACKAGE_PIN D9 [get_ports async_in_0]


############################################################################
## Outputs
############################################################################

# ---- clk_wiz_0 ----
# clk_out1_0_PassThrough_0deg
set_property IOSTANDARD LVCMOS18 [get_ports clk_out1_0_PassThrough_0deg]
set_property PACKAGE_PIN AU29 [get_ports clk_out1_0_PassThrough_0deg]

# clk_out2_0_PassThrough_180deg
set_property IOSTANDARD LVCMOS18 [get_ports clk_out2_0_PassThrough_180deg]
set_property PACKAGE_PIN AW30 [get_ports clk_out2_0_PassThrough_180deg]

# clk_out3_0_10MHz
set_property IOSTANDARD LVCMOS18 [get_ports clk_out3_0_10MHz]
set_property PACKAGE_PIN AJ33 [get_ports clk_out3_0_10MHz]



# ---- clk_wiz_1 ----
# clk_out1_1_10MHz
set_property IOSTANDARD LVCMOS18 [get_ports clk_out1_1_10MHz]
set_property PACKAGE_PIN AH28 [get_ports clk_out1_1_10MHz]

# clk_out2_1_PassThrough_0deg
set_property IOSTANDARD LVCMOS18 [get_ports clk_out2_1_PassThrough_0deg]
set_property PACKAGE_PIN AF29 [get_ports clk_out2_1_PassThrough_0deg]

# clk_out3_1_100MHz
set_property IOSTANDARD LVCMOS18 [get_ports clk_out3_1_100MHz]
set_property PACKAGE_PIN AJ31 [get_ports clk_out3_1_100MHz]