
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

set target_FPGA_board [get_property PART [get_runs synth_1]]
puts "TCL: Programming target FPGA board (used for synth & impl $ bit): $target_FPGA_board "


# ----------------------------------------------------------
# - Launch server, double-check the correct FPGA PL target -
# ----------------------------------------------------------
# Lanuch server
load_features labtools
open_hw_manager
connect_hw_server -url TCP:localhost:3121
refresh_hw_server

# Find all targets
set local_hw_targets [get_hw_targets *]
puts "TCL: local_hw_targets: "
puts "TCL: $local_hw_targets"
current_hw_target $local_hw_targets
open_hw_target

# Search for up to 10 devices connected to the server
puts "TCL: Select connected device for programming (list 10 devices max): "
set target_prog_fabric [lindex [get_hw_devices $local_hw_targets]]
puts "TCL: target_prog_fabric: $target_prog_fabric"

# Check if valid target has been selected out of the local_hw_targets
for {set i 0} {$i < 10} {incr i} {
    set line_part [lindex [split $target_prog_fabric " "] $i]
    # Number of occurrences of the string "xc7/arm"
    if {[string first "xc7" $line_part] != -1} {
        puts "TCL: $i = $line_part (Programmable fabric of an 7-series Xilinx FPGA)"
        set valid_device_id $i
        break
    } elseif {[string first "arm" $line_part] != -1} {
        puts "TCL: Device no. $i: $line_part (ARM Processor)"
    } elseif {$line_part eq ""} {
        break
    } else {
        puts "TCL: $i = $line_part (Unknown device)"
    }
}

# Choose from the TCL Console
refresh_hw_server
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
current_hw_device [lindex [get_hw_devices] $valid_device_id]

# Link the .bit file with the FPGA PL
set_property PROGRAM.FILE $bitfile $device_to_prog
# if ila included: set_property PROBES.FILE {C:/design.ltx} $device_to_prog

# Program the FPGA
#  - in case of "ERROR: [Labtools 27-3165] End of startup status: LOW"
#    check that bitstream file is for target FPGA
puts "TCL: Programming device $device_to_prog..."
program_hw_devices $device_to_prog
# if ila included: refresh_hw_device $device_to_prog


# Close project, print success
puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "
close_project