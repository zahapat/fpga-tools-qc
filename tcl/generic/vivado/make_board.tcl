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
set args_cnt 1
puts "TCL: Get TCL Command-line arguments"
if { $::argc == $args_cnt } {
    for {set i 0} {$i < $::argc} {incr i} {
        set arg1 [ string trim [lindex $::argv $i] ]
        puts "TCL: arg1 = $arg1"
    }
} else {
    puts "TCL: ERROR: There must be $args_cnt Command-line argument/s passed to the TCL script. Total CLI arguments found:  $::argc"
    return 1
}


# Check if the file passed has correct suffix, add the correct suffix otherwise
if { [string first "." $arg1] != -1} {
    set arg1 [lindex [split $arg1 "."] 0]
}
set arg1 "${arg1}.tcl"

# Open project
close_project -quiet
open_project "${origin_dir}/vivado/${_xil_proj_name_}.xpr"


# Find the .tcl board file in the ./boards dir
set foundBoards [glob -nocomplain -type f ./boards/${arg1} ./boards/*/${arg1}]
set foundBoardsCnt [expr ([llength $foundBoards])]
if { $foundBoardsCnt == 0 } {
    puts "TCL ERROR: There is no file named '${arg1}' in the dir ./boards"
    return 2
} elseif { $foundBoardsCnt > 1 } {
    puts "TCL ERROR: There are more files in the ./boards dir named ${arg1}: $foundBoards. Please select a unique name for your .tcl board file"
    return 3
} else {
    foreach b $foundBoards {
        set boardPath [string range $b 0 end]
        puts "TCL DEBUG: boardPath = $boardPath"
        set boardPath "[file normalize $boardPath]"
        puts "TCL DEBUG: boardPath = $boardPath"
        set boardFullName [file tail $boardPath]
        set boardName [lindex [split $boardFullName "."] 0]
        puts "TCL: Reading file: $boardPath"

        # Remove previous folder with output board files if exists
        file delete -force "${orig_proj_dir}/boards/$boardName/$boardName"
        source $boardPath
    }
}

# Add .xdc file related to the board file.
# Note: The .xdc file must have the same name as the board file and be located in the same dir. 
#       I.e. ./boards/flow_ambiguity/flow_ambiguity.tcl -> ./boards/flow_ambiguity/flow_ambiguity.xdc
set foundXdc [glob -nocomplain -type f ./boards/${boardName}/*{.xdc}]
if {[llength $foundXdc] > 0} {
    foreach file_path $foundXdc {
        set vivado_added_scripts_report_path "${origin_dir}/vivado/0_report_added_xdc.rpt"
        set vivado_added_scripts_report [open $vivado_added_scripts_report_path "a"]

        add_files -norecurse -fileset "constrs_1" "$file_path"
        puts -nonewline $vivado_added_scripts_report "$file_path\n"

        close $vivado_added_scripts_report
    }
}

# Close project, print success
puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "
close_project