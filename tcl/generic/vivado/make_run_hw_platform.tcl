# Interesting_thread: https://forums.xilinx.com/t5/Vivado-TCL-Community/How-can-I-detect-if-synthesis-needs-to-be-run/td-p/848241

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

# Run hardware platform generation
puts "TCL: Attempt to launch write_hw_platform. "
if {[catch {\
    open_run impl_1
    write_hw_platform -fixed -include_bit -force -file "${origin_dir}/vivado/3_hw_platform_${_xil_proj_name_}.xsa"\
} error_msg]} {
    puts "TCL: Export Hardware could not be run. Skipping Hardware Platform generation for Vitis. Message generated: $error_msg"
} else {
    puts "TCL: Generating Hardware Platform for Vitis successful."
}

# Close project
puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "
close_project