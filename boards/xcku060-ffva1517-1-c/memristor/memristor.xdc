############################################################################
## System Clock
############################################################################
set_property IOSTANDARD LVDS [get_ports CLK_IN1_D_0_clk_p]
set_property IOSTANDARD LVDS [get_ports CLK_IN1_D_0_clk_n]

set_property PACKAGE_PIN AM22 [get_ports CLK_IN1_D_0_clk_p]
set_property PACKAGE_PIN AN22 [get_ports CLK_IN1_D_0_clk_n]

set_property DIFF_TERM FALSE [get_ports {CLK_IN1_D_0_clk_p}]


# Inputs
# pulse_in_0 [MC1PIN: 43; BRKNAME: PORTA_S4_D2P]
set_property IOSTANDARD LVCMOS18 [get_ports pulse_in_0]
# set_property IOSTANDARD LVTTL [get_ports pulse_in_0]
set_property PACKAGE_PIN P26 [get_ports pulse_in_0]
# set_property PACKAGE_PIN P28 [get_ports pulse_in_0]

# Outputs
# pulse_out_0 [MC1PIN: 17; BRKNAME: PORTA_S26]
# set_property IOSTANDARD LVTTL [get_ports pulse_out_0]
set_property IOSTANDARD LVCMOS18 [get_ports pulse_out_0]
# set_property SLEW FAST [get_ports {pulse_out_0}]
set_property SLEW SLOW [get_ports {pulse_out_0}]
set_property PACKAGE_PIN P28 [get_ports pulse_out_0]
# set_property PACKAGE_PIN P26 [get_ports pulse_out_0]