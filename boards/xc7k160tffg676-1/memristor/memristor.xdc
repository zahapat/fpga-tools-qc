
# Inputs
set_property IOSTANDARD LVTTL [get_ports in_port]
set_property PACKAGE_PIN B19 [get_ports in_port]

# Outputs
set_property IOSTANDARD LVTTL [get_ports out_port]
set_property SLEW FAST [get_ports {out_port}]
set_property PACKAGE_PIN B19 [get_ports out_port]