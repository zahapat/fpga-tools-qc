# Filter all irrelevant keywords from the commandline and leave only arguments
proc convert_string_to_list_on_delimiters {str delimiter} {
    set cnt 0
    set list_append {}
    set str_i [string range [lindex [split $str "$delimiter"] $cnt] 0 end]
    while {$str_i ne ""} {
        lappend list_append $str_i
        incr cnt
        set str_i [string range [lindex [split $str "$delimiter"] $cnt] 0 end]
    }
    return $list_append
}


# DO NOT TOUCH
puts "TCL: Get TCL Command-line argument/s"
set correct_arg_num 1
if [batch_mode] {
    set correct_arg_num 2
}
set argline [string trim [lindex $::argv $correct_arg_num] ]
set argline [string range [lindex [split $argline " "] 2] 0 end]
puts "TCL: argline = $argline"


# Get all TCL Command-line arguments
set delimiter ","
set list_all_args [convert_string_to_list_on_delimiters $argline $delimiter]
set arg_count [llength $list_all_args]

set arguments_cnt 4
if { $arg_count == $arguments_cnt } {

    # Library for VHDL src files
    set lib_src_vhdl [string trim [lindex $list_all_args 0] ]
    set lib_src_vhdl [string tolower $lib_src_vhdl]
    puts "TCL: Argument 1 lib_src_vhdl: '$lib_src_vhdl'"

    # Library for VHDL sim files
    set lib_sim_vhdl [string trim [lindex $list_all_args 1] ]
    set lib_sim_vhdl [string tolower $lib_sim_vhdl]
    puts "TCL: Argument 2 lib_sim_vhdl: '$lib_sim_vhdl'"

    # Project root directory
    set proj_root_dir [string trim [lindex $list_all_args 2] ]
    puts "TCL: Argument 3 proj_root_dir: '$proj_root_dir'"
    puts "TCL: proj_root_dir = $proj_root_dir"

    # Vivado Version
    set vivado_version [string trim [lindex $list_all_args 3] ]
    puts "TCL: Argument 4 vivado_version: '$vivado_version'"
    puts "TCL: vivado_version = $vivado_version"

} else {
    puts "TCL: ERROR: There must be $arguments_cnt Command-line argument/s passed to the TCL script. Total arguments found:  $::argc . Quit."
    quit
}


# Load TCL functions
source "${proj_root_dir}simulator/do/tcl_functions.tcl"


# Rebuild the searched libraries output to be used with the vlog vsim -L option
set searched_libraries_file_path "${proj_root_dir}simulator/searched_libraries.txt"
delete_file $searched_libraries_file_path


# Prerequisite for simulation: file ./simulator/modules.tcl is present
# Remove modules.tcl temp file
set required_file "${proj_root_dir}simulator/modules.tcl"
if {![file exist "$required_file"]} {
    puts "TCL: ERROR: Missing required file: ./simulator/modules.tcl . Run 'make src TOP=<testbench_filename>.__' in the commandline to generate it. Quit."
    quit
}


# Remove all the following libraries and mappings
# Add new mandatory library, prevent duplicating
if {[file exist "${proj_root_dir}simulator/work"]} {
    delete_library_and_mappings ${proj_root_dir}simulator/work
}
create_lib_if_noexist ${proj_root_dir}simulator/work $searched_libraries_file_path


# Add new mandatory library, prevent duplicating
if {([file exist "${proj_root_dir}simulator/$lib_src_vhdl"]) && ($lib_src_vhdl ne "work")} {
    vdel -all -lib ${proj_root_dir}simulator/$lib_src_vhdl
    puts "TCL: Library '$lib_src_vhdl' deleted."

    vlib ${proj_root_dir}simulator/$lib_src_vhdl
    vmap $lib_src_vhdl ${proj_root_dir}simulator/$lib_src_vhdl
    add_searched_library $lib_src_vhdl $searched_libraries_file_path
    puts "TCL: Library '$lib_src_vhdl' created."
}


# Add new mandatory library, prevent duplicating
if {([file exist "${proj_root_dir}simulator/$lib_sim_vhdl"]) && ($lib_src_vhdl ne "work") && ($lib_src_vhdl ne $lib_sim_vhdl)} {
    vdel -all -lib ${proj_root_dir}simulator/$lib_sim_vhdl
    puts "TCL: Library '$lib_sim_vhdl' deleted."

    vlib ${proj_root_dir}simulator/$lib_sim_vhdl
    vmap $lib_sim_vhdl ${proj_root_dir}simulator/$lib_sim_vhdl
    add_searched_library $lib_sim_vhdl $searched_libraries_file_path
    puts "TCL: Library '$lib_sim_vhdl' created."
}


# Load all modules into a list
list all_modules {}
set slurp_file [open "${proj_root_dir}simulator/modules.tcl" r]
while {-1 != [gets $slurp_file line]} {
    set filepath [string map {" " ""} ${line}]
    if {$filepath eq ""} {
        puts "TCL: Ignoring invalid line."
    } else {
        lappend all_modules "$filepath"
    }
}
close $slurp_file
puts "TCL: all_modules = $all_modules"


# Compile & Add packages
source "${proj_root_dir}simulator/do/include_packages.tcl"


# Sort the files to repsective libraries based on the compile order in the file modules.tcl
# Compile and proceed to launch sim if no errors occurred
set pass_to_launch_sim 1
puts "TCL: Launching simulation..."
if {[ catch {
    source ${proj_root_dir}/simulator/do/compile_all.tcl
} errorstring]} {
    set pass_to_launch_sim 0
    puts "TCL: The following error was generated while compiling sources: $errorstring . Quit."
    if {[batch_mode]} {quit} else {return 0}
}


# Launch simulation
if {$pass_to_launch_sim == 1} {
    if {[batch_mode]} {
        source "${proj_root_dir}simulator/do/run_batch.tcl"
        quit
    } else {
        source "${proj_root_dir}simulator/do/run_gui.tcl"
    }
}