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

# Run with user-defined strategies for synthesis and implementation
source "${origin_dir}/tcl/project_specific/vivado/strategy_synth.tcl"
source "${origin_dir}/tcl/project_specific/vivado/strategy_impl.tcl"

puts "TCL: Launch runs all the way through write_bitstream and then write_hw_platform. "
reset_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
write_hw_platform -fixed -include_bit -force -file "${origin_dir}/vivado/4_hw_platform_$_xil_proj_name_.xsa"

# Close project
puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "
close_project