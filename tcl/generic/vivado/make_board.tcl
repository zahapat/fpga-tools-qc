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

# Open project
close_project -quiet
open_project "${origin_dir}/vivado/${_xil_proj_name_}.xpr"
 

# -------------------------------------------------------------------
# - GET ALL .bd FILES FROM THE PROJECT AND EXPORT THEM AS TCL FILES -
# -------------------------------------------------------------------
# puts "TCL: GET ALL '.bd' FILES FROM THE PROJECT AND EXPORT THEM AS TCL FILES. "
# set all_bd_designs [get_bd_designs -quiet -of_objects [current_project]]
# if {$all_bd_designs eq ""} {
#     puts "TCL: No board '.bd' files are present in the current project for TCL export."
# } else {
#     foreach b $all_bd_designs {
#         set projBoardName [string range $b 0 end]
#         puts "TCL: Exporting '.bd' file $projBoardName as a TCL script here: ./boards/"
#         write_bd_tcl -bd_name $projBoardName -bd_folder "./boards/"
#     }
# }


# -----------------------------------
# - RE/ADD .bd FILES TO THE PROJECT -
# -----------------------------------
# puts "TCL: RE/ADD '.bd' FILES TO THE PROJECT. "
# set foundBoards [glob -nocomplain -type f ./boards/*{.bd}]
# if { [llength $foundBoards] == 0 } {
#     puts "TCL: There are no '.bd' files in the folder ./boards/."
# } else {
#     foreach b $foundBoards {
#         set boardPath [string range $b 0 end]
#         set boardPath "[file normalize $boardPath]"
#         set boardFullName [file tail $boardPath]
#         set boardName [lindex [split $boardFullName "."] 0]
#         puts "TCL: Adding .bd file $boardFullName: $boardPath"
#         read_bd $boardPath
#         # write_bd_tcl -force -bd_name $boardName -bd_folder "./boards/" $boardName
#     }
# }

set foundBoards [glob -nocomplain -type f ./boards/${arg1}.tcl]
if { [llength $foundBoards] == 0 } {
    puts "TCL: There is no ${arg1}.tcl file in the folder ./boards"
} else {
    foreach b $foundBoards {
        set boardPath [string range $b 0 end]
        set boardPath "[file normalize $boardPath]"
        set boardFullName [file tail $boardPath]
        set boardName [lindex [split $boardFullName "."] 0]
        puts "TCL: Reading file: $boardPath"

        # Remove previous folder with board files if exists
        file delete -force "${orig_proj_dir}/boards/$boardName"
        source $boardPath
    }
}


# Close project, print success
puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "
close_project