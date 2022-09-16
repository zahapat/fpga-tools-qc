# https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_1/ug908-vivado-programming-debugging.pdf
# On page 229/410
# https://www.xilinx.com/support/documentation/sw_manuals/xilinx2013_3/ug908-vivado-programming-debugging.pdf
# On page 34/130
# https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug936-vivado-tutorial-programming-debugging.pdf
# https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_1/ug835-vivado-tcl-commands.pdf
# https://forums.xilinx.com/t5/Vivado-Debug-and-Power/Scripting-the-capture-process-in-Vivado-2015-1-ILA-using-the-tcl/td-p/640139
# https://www.xilinx.com/support/documentation/ip_documentation/system_ila/v1_0/pg261-system-ila.pdf

# https://www.programmersought.com/article/88904969854/
# https://www.programmersought.com/article/72733897848/

# https://forums.xilinx.com/t5/Design-and-Debug-Techniques-Blog/Video-Series-31-Debugging-a-Video-System-using-an-ILA/ba-p/1004299

# --> start the hw_server program in the Vivado bin directory and open a target from the development machine Vivado window. Just specify a remote server host name and use the default port 3121. It couldn’t be simpler.
# ... the above is from https://www.beyond-circuits.com/wordpress/2015/01/remote-jtag-with-vivado/

# https://forums.xilinx.com/t5/Vivado-Debug-and-Power/Message-No-debug-cores-when-trying-to-use-ILA/td-p/924734

# This file implicitly creates an ILA core, finds signals explicitly marked as MARK_DEBUG in HDL files
# and using the Netlist Insertion Debug Probing Flow will probe the activity on these signals
#
# To do:
#   1. Add ILA probes to the declarative part of the .vhdl file:
#       - This prevents trimming nets during synthesis
#       - example:
#           attribute MARK_DEBUG : string;
#           attribute MARK_DEBUG of sine : signal is "true";
#           attribute MARK_DEBUG of sineSel : signal is "true";
#
#   2. Run this TCL script which includes set_property MARK_DEBUG after synthesis:
#       set_property MARK_DEBUG true [get_nets -hier [list {sine[*]}]]
#
#   3. 



# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
    set origin_dir $::origin_dir_loc
}


# Set the project name
set _xil_proj_name_ [file tail [file dirname "[file normalize ./Makefile]"]]

# Use project name variable, if specified in the tcl shell
if { [info exists ::user_project_name] } {
    set _xil_proj_name_ $::user_project_name
}

variable script_file
set script_file "[file tail [info script]]"
puts "TCL: Running $script_file for project $_xil_proj_name_."

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/"]"

# Open the project
close_project -quiet
open_project "${origin_dir}/vivado/${_xil_proj_name_}.xpr"

# Open implemented design and print C_USER_SCAN_CHAIN
open_run impl_1
set dbg_hub_clk [get_pins dbg_hub/clk]
puts "TCL: check existing clock connection dbg_hub/clk: $dbg_hub_clk"
set scan_chain_num [get_property C_USER_SCAN_CHAIN [get_debug_cores dbg_hub]]
puts "TCL: C_USER_SCAN_CHAIN = $scan_chain_num"
# set_property C_USER_SCAN_CHAIN 2 [get_debug_cores dbg_hub]
# set scan_chain_num [get_property C_USER_SCAN_CHAIN [get_debug_cores dbg_hub]]
# puts "TCL: C_USER_SCAN_CHAIN = $scan_chain_num"


# ----- MAKE PROG: PROGRAM DEVICE -----
# -------------------------------------------------
# - Use the required .bit file and program device -
# -------------------------------------------------
puts "TCL: Double-check existing bitfile: [file normalize "$origin_dir"]/vivado/3_bitstream_${_xil_proj_name_}.bit: "
if { [file exists ${origin_dir}/vivado/3_bitstream_${_xil_proj_name_}.bit] } {
    puts "TCL: Using file 3_bitstream_${_xil_proj_name_}.bit "
} else {
    puts "TCL: ERROR: Bitfile 3_bitstream_${_xil_proj_name_}.bit not found in the folder [file normalize "$origin_dir"]/vivado "
    quit
}
set bitfile "[file normalize "$origin_dir"]/vivado/3_bitstream_${_xil_proj_name_}.bit"
set ila_probes_file "${orig_proj_dir}/vivado/2_ila_$_xil_proj_name_.ltx"

set target_FPGA_board [get_property PART [get_runs synth_1]]
puts "TCL: Programming target FPGA board (used for synth & impl $ bit): $target_FPGA_board "


# ----------------------------------------------------------
# - Launch server, double-check the correct FPGA PL target -
# ----------------------------------------------------------
# Lanuch server
puts "TCL: load_features labtools"
# load_features labtools
puts "TCL: open_hw_manager"
open_hw_manager
# puts "TCL: connect_hw_server -url TCP:localhost:3121"
# connect_hw_server -url TCP:localhost:3121

puts "TCL: connect_hw_server -url localhost:3121"
# connect_hw_server -url localhost:3121
connect_hw_server -url TCP:LAPTOP-L2RBBA9J:3121
# puts "TCL: refresh_hw_server"
# refresh_hw_server

# puts "TCL: exec hw_server -e 'set bscan-switch-user-mask 1'"
# exec hw_server -e "set bscan-switch-user-mask 1"
# exec hw_server -e "set xsdb-user-bscan <C_USER_SCAN_CHAIN scan_chain_number>"


# Find all targets
puts "TCL: ALL local_hw_targets: "
set local_hw_targets [get_hw_targets *]
puts "$local_hw_targets"
current_hw_target $local_hw_targets

# IMPORTANT: Set the JTAG Frequency
# Allowed values (Hz): 750000, 1500000, 3000000, 6000000, 12000000, 15000000
set jtag_frequency_hz [get_property PARAM.FREQUENCY [get_hw_targets $local_hw_targets]]
puts "TCL: jtag_frequency_hz = $jtag_frequency_hz"
set_property PARAM.FREQUENCY 30000000 [get_hw_targets $local_hw_targets]
set jtag_frequency_hz [get_property PARAM.FREQUENCY [get_hw_targets $local_hw_targets]]
puts "TCL: jtag_frequency_hz (Modified) = $jtag_frequency_hz"

# set sys_clk_name "sys_clk"
# set sys_clk_frequency_hz [get_property FREQUENCY [get_clocks $sys_clk_name]]
# puts "TCL: sys_clk_frequency_hz = $sys_clk_frequency_hz"

set ila_clk_pin_name "dbg_hub/clk"
set ila_clk_pin_period_ns [get_property PERIOD [get_clocks -of_objects [get_pins $ila_clk_pin_name]]]
puts "TCL: ila_clk_pin_period_ns = $ila_clk_pin_period_ns"
# if {sys_clk_frequency_hz > jtag_frequency_hz} {

# } else {
#     puts "The ILA Frequency $sys_clk_frequency_hz should be twice higher than JTAG frequency $jtag_frequency_hz"
#     return 1
# }
# set_property PARAM.FREQUENCY 15000000 [get_hw_targets $local_hw_targets]

open_hw_target

# Search for up to 10 devices connected to the server
puts "TCL: Select connected device for programming (list 10 devices max): "
set target_prog_fabric [lindex [get_hw_devices $local_hw_targets]]
puts "TCL: target_prog_fabric: "
puts "$target_prog_fabric"

# Check if valid target has been selected out of the local_hw_targets
for {set i 0} {$i < 10} {incr i} {
    set line_part [lindex [split $target_prog_fabric " "] $i]
    # Number of occurrences of the string "xc7/arm"
    if {[regexp -all {xc7} $line_part] == 1} {
        puts "TCL: $i = $line_part (Programmable fabric of an 7-series Xilinx FPGA)"
        puts "TCL: Valid device found."
        set valid_device_id $i
        break
    } elseif {[regexp -all {arm} $line_part] == 1} {
        puts "TCL: $i = $line_part (ARM Processor)"
    } elseif {$line_part eq ""} {
        break
    } else {
        puts "TCL: $i = $line_part (Unknown device)"
    }
}

# BSCAN_SWITCH_USER_MASK and C_USER_SCAN_CHAIN must match
set scan_switch_mask_num [get_property BSCAN_SWITCH_USER_MASK [current_hw_device [lindex [get_hw_devices] $valid_device_id]]]
puts "TCL: BSCAN_SWITCH_USER_MASK = $scan_switch_mask_num"

# Choose from the TCL Console
# refresh_hw_server
set device_selected [lindex [split $target_prog_fabric " "] $valid_device_id]
puts "TCL: Selected target device for programming: $device_selected"
set device_to_prog [current_hw_device [lindex [get_hw_devices] $valid_device_id]]
if {$device_selected eq $device_to_prog} {
    puts "TCL: Devices match double-check OK. Continue."
} else {
    puts "TCL: Devices do not match. Quit."
    puts "TCL: Running $script_file for project $_xil_proj_name_ FAILED. "
    return 1
}
set device_to_prog [current_hw_device [lindex [get_hw_devices] $valid_device_id]]
current_hw_device [lindex [get_hw_devices] $valid_device_id]
refresh_hw_device -update_hw_probes "true" $device_to_prog

# Link the .bit file with the FPGA PL
set_property PROGRAM.FILE $bitfile $device_to_prog
set_property PROBES.FILE $ila_probes_file $device_to_prog

puts "TCL: report_hw_targets: "
report_hw_targets

# BSCAN_SWITCH_USER_MASK
# set_property BSCAN_SWITCH_USER_MASK 1
# hw_server -exec "set bscan-switch-user-mask 1"

# Program the FPGA
#  - in case of "ERROR: [Labtools 27-3165] End of startup status: LOW"
#    check that bitstream file is for target FPGA
puts "Programming device $device_to_prog..."
program_hw_devices $device_to_prog

puts "Refreshing device $device_to_prog for ILA ..."
refresh_hw_device $device_to_prog

# List all present ILAs in the device
puts "TCL: hw_present_ilas:"
set hw_present_ilas [get_hw_ilas -of_objects [current_hw_device]]
puts "$hw_present_ilas"



# Arm the ILA and let it
set ila_blkbox_name "ila_0_CV"
run_hw_ila $ila_blkbox_name
wait_on_hw_ila $ila_blkbox_name

# Upload the captured ILA data, display it, and write it to a file
# display_hw_ila_data [current_hw_ila_data]
# write_hw_ila_data my_hw_ila_data [current_hw_ila_data]
current_hw_ila_data [upload_hw_ila_data $ila_blkbox_name]
write_hw_ila_data -force -csv_file "${origin_dir}/vivado/3_ila_result.csv" [current_hw_ila_data]

# Close project, print success
puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "
close_project