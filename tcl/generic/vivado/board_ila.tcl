# Create board for ILA creation on ZYNQ

# To test this script, run the following commands from Vivado Tcl console:
# source board_ila.tcl


# CHANGE DESIGN NAME HERE
set board_name "board_ila"

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $board_name

# 0. CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
    puts "ERROR: Please open or create a project!"
    return 1
}


# 1. Creating design if needed
set errMsg ""
set nRet 0
set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]
if { ${board_name} ne "" && ${cur_design} eq ${board_name} } {
   # Checks if design is empty or not
   if { $list_cells ne "" } {
        set errMsg "ERROR: Design <$board_name> already exists in your project, please set the variable <board_name> to another value."
        set nRet 1
   } else {
        puts "INFO: Constructing design in IPI design <$board_name>..."
   }
} elseif { ${cur_design} ne "" && ${cur_design} ne ${board_name} } {
   if { $list_cells eq "" } {
        puts "INFO: You have an empty design <${cur_design}>. Will go ahead and create design..."
   } else {
        set errMsg "ERROR: Design <${cur_design}> is not empty! Please do not source this script on non-empty designs."
        set nRet 1
   }
} else {
    if { [get_files -quiet ${board_name}.bd] eq "" } {
        puts "INFO: Currently there is no design <$board_name> in project, so creating one..."
        # the -dir option is not part of write_bd_tcl - added by GD to create a remote bd
        # create_bd_design -dir $proj_dir/.. $board_name
        create_bd_design -dir $boards_dir $ila_default_board_name
        current_bd_design $ila_default_board_name
        puts "INFO: Making design <$board_name> as current_bd_design."
        current_bd_design $board_name
    } else {
        set errMsg "ERROR: Design <$board_name> already exists in your project, please set the variable <board_name> to another value."
        set nRet 3
    }
}

puts "INFO: Currently the variable <board_name> is equal to \"$board_name\"."

if { $nRet != 0 } {
    puts $errMsg
    return $nRet
}


# 2. Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
# if { $parentCell eq "" } {
#     set parentCell [get_bd_cells /]
# }
# Get object for parentCell
# set parentObj [get_bd_cells $parentCell]
# if { $parentObj == "" } {
#         puts "ERROR: Unable to find parent cell <$parentCell>!"
#         return 1
# }
# Make sure parentObj is hier blk
# set parentType [get_property TYPE $parentObj]
# if { $parentType ne "hier" } {
#     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
#     return 2
# }
# Save current instance; Restore later
# set oldCurInst [current_bd_instance .]
# Set parent object as current
# current_bd_instance $parentObj


# 2.1 Create interface ports
# set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
# set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]

# 2.2 Create ports


# 2.3.0 Create instance: processing_system7_0, and set properties
set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

# 2.3.1 Create instance: wrapper_ila.vhd
create_bd_cell -type module -reference wrapper_ila wrapper_ila_0

# 2.3.2 Create instance: ila_0 (native = non-axi), and set properties
create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_0
set static_probes_type_width "CONFIG.C_PROBE0_TYPE {0} CONFIG.C_PROBE0_WIDTH {1} CONFIG.C_PROBE1_TYPE {0} CONFIG.C_PROBE1_WIDTH {1} "

set index_probe 2
set cnt 0
foreach i $all_input_names {
    if {$line_input_i ne ""} {
        set port_resolved_width [lindex [split $all_input_widths_total_resolved " "] $cnt]
        append variable_probes_type_width "CONFIG.C_PROBE${index_probe}_TYPE {0} CONFIG.C_PROBE${index_probe}_WIDTH {1} "
        incr cnt
        incr index_probe
    }
}
set cnt 0
foreach i $all_output_names {
    if {$line_output_i ne ""} {
        set port_resolved_width [lindex [split $all_output_widths_total_resolved " "] $cnt]
        append variable_probes_type_width "CONFIG.C_PROBE${index_probe}_TYPE {0} CONFIG.C_PROBE${index_probe}_WIDTH {1} "
        incr cnt
        incr index_probe
    }
}
variable num_of_probes 4
set width 1
set type 0
puts "TCL: $num_of_probes"
puts "TCL: variable_probes_type_width = $variable_probes_type_width"
#  !!!!!!!!!!!!!!!! IT MUST BE EVERYTHING HARDCODED !!!!!!!!!!!!!!!!!!!!!!!
#  !!!!!!!!!!!!!!!! NO VARIABLES ARE POSSIBLE !!!!!!!!!!!!!!!!!!!!!!!
set_property -dict [list CONFIG.C_NUM_OF_PROBES {1} CONFIG.C_ENABLE_ILA_AXI_MON {false} CONFIG.C_MONITOR_TYPE {Native}] [get_bd_cells ila_0]
set_property -dict [list CONFIG.C_PROBE0_TYPE {$type} CONFIG.C_PROBE0_WIDTH {$width}] [get_bd_cells ila_0]
# set_property -dict [list $static_probes_type_width $variable_probes_type_width] [get_bd_cells ila_0]
# set_property -dict [list CONFIG.C_PROBE0_TYPE {0} CONFIG.C_PROBE0_WIDTH {1} CONFIG.C_NUM_OF_PROBES {$index_hdl_probe} CONFIG.C_ENABLE_ILA_AXI_MON {false} CONFIG.C_MONITOR_TYPE {Native}] [get_bd_cells ila_0]


# 2.4 Create interface connections
# connect_bd_intf_net -intf_net processing_system7_0_ddr [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
# connect_bd_intf_net -intf_net processing_system7_0_fixed_io [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]

# 2.5 Make external
make_bd_pins_external [get_bd_pins wrapper_ila_0/probe3_out_data]
make_bd_pins_external [get_bd_pins wrapper_ila_0/in_rst]

# 2.6 Create port connections
# FCLK_CLK0 => ...
connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK]
connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins wrapper_ila_0/in_zynq_clk]
connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins ila_0/clk]

# wrapper_ila_0 => ...
connect_bd_net [get_bd_pins wrapper_ila_0/probe0_in_zynq_clk] [get_bd_pins ila_0/probe0]
connect_bd_net [get_bd_pins wrapper_ila_0/probe1_in_rst] [get_bd_pins ila_0/probe1]
set index_probe 2
set cnt 0
foreach i $all_input_names {
    if {$line_input_i ne ""} {
        set input_name_i [lindex [split $all_input_names " "] $cnt]
        set input_name_i_lower [string tolower $input_name_i]
        connect_bd_net [get_bd_pins wrapper_ila_0/probe${index_probe}_$input_name_i_lower] [get_bd_pins ila_0/probe${index_probe}]
        incr cnt
        incr index_probe
    }
}
set cnt 0
foreach i $all_output_names {
    if {$line_output_i ne ""} {
        set output_name_i [lindex [split $all_output_names " "] $cnt]
        set output_name_i_lower [string tolower $output_name_i]
        connect_bd_net [get_bd_pins wrapper_ila_0/probe${index_probe}_$output_name_i_lower] [get_bd_pins ila_0/probe${index_probe}]
        incr cnt
        incr index_probe
    }
}

# 2.7 Create address segments


# Restore current instance and save board design
# current_bd_instance $oldCurInst
save_bd_design