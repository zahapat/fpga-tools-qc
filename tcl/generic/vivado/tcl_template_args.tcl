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


# Get TCL Command-line arguments
puts "TCL: Get TCL Command-line arguments"
set arguments_cnt 1
if { $::argc == arguments_cnt } {
    for {set i 0} {$i < $::argc} {incr i} {
        set topFile [ string trim [lindex $::argv $i] ]
        puts "$topFile"
    }
} else {
    puts "TCL: ERROR: There must be $arguments_cnt Command-line argument(s) passed to the TCL script. Total arguments found:  $::argc"
    return 1
}



# Open project
close_project -quiet
open_project "${origin_dir}/vivado/${_xil_proj_name_}.xpr"
 
# ------------------------
# - ADD YOUR SCRIPT HERE -
# ------------------------
puts "TCL: Running user TCL script. "


# Close project, print success
puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "
close_project