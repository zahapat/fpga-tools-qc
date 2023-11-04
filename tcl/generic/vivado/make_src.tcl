# Use origin directory path location variable, if specified in the tcl shell
set origin_dir "."
if { [info exists ::origin_dir_loc] } {
    set origin_dir $::origin_dir_loc
    puts "TCL: ::origin_dir_loc = $origin_dir"
}

# Load all TCL Functions for Vivado
source "${origin_dir}/tcl/generic/vivado/tcl_functions_vivado.tcl"


# Set the project name
set _xil_proj_name_ [file tail [file dirname "[file normalize ./Makefile]"]]

# Use project name variable, if specified in the tcl shell
if { [info exists ::user_project_name] } {
    set _xil_proj_name_ $::user_project_name
}

# Get name of the current script
variable script_file
set script_file "[file tail [info script]]"
puts "TCL: Running $script_file for project $_xil_proj_name_."


# Get TCL Command-line arguments
puts "TCL: Get TCL Command-line arguments"
set arguments_cnt 3
if { $::argc == $arguments_cnt } {

    # Top file
    set topfile [string trim [lindex $::argv 0] ]
    puts "TCL: Argument 1 topFile: '$topfile'"

    # Library src files
    set file_library_src [string trim [lindex $::argv 1] ]
    set file_library_src [string tolower $file_library_src]
    puts "TCL: Argument 2 lowercase file_library_src: '$file_library_src'"

    # Library sim files
    set file_library_sim [string trim [lindex $::argv 2] ]
    set file_library_sim [string tolower $file_library_sim]
    puts "TCL: Argument 3 lowercase file_library_sim: '$file_library_sim'"

} else {
    puts "TCL: ERROR: There must be $arguments_cnt Command-line argument/s passed to the TCL script. Total arguments found:  $::argc"
    return 1
}


# -------------------------
# - OPEN EXISTING PROJECT -
# -------------------------
# Open and reset the project
puts "TCL: OPENING PROJECT $_xil_proj_name_"
open_project -quiet "${origin_dir}/vivado/${_xil_proj_name_}.xpr"
reset_project

# Set filesets objects
set objSrc [get_filesets sources_1]
set objSim [get_filesets sim_1]
set objConst [get_filesets constrs_1]

# Remove all previous source files
puts "TCL: Remove all source files in object all filesets"


# --------------------------------------------------
# - SET A NEW TOP MODULE AND ADD IT TO THE PROJECT -
# --------------------------------------------------
# Set the file graph
puts "TCL: Find missing sources to compile the new temp top module and report compile order "
set_property source_mgmt_mode All [current_project]
update_compile_order

# Add Top File
puts "TCL: Adding TOP module: $topfile"
set topfile_rootname [file tail [file rootname $topfile]]
add_module ${origin_dir}/modules/$topfile_rootname

# Add IP cores
source "${origin_dir}/tcl/project_specific/vivado/add_ip_cores.tcl"

# Update compile order and set the top module
update_compile_order
set topfile_path [file normalize [get_property TOP [current_fileset]]]
set topfile_tail [file tail $topfile_path]
set topfile_rootname [file rootname $topfile_tail]
set topfile_extension [file extension $topfile_tail]

# Set directories where the main file with all added modules will be located
set out_file_path_added_vivado "${origin_dir}/vivado/0_report_added_modules.rpt"
set out_file_path "${origin_dir}/simulator/do/modules.tcl"


# ------------------------------------
# - Find missing modules -
# ------------------------------------
# List all missing submodules
report_compile_order -quiet -used_in synthesis -missing_instance -file "${origin_dir}/vivado/0_report_modules_missing.rpt"
puts "TCL: Exporting missing modules in design here: ${origin_dir}/vivado/0_report_modules_missing.rpt"

# No missing files = 6 lines, any higher number means there is at least one missing module in hierarchy
set slurp_report [open "${origin_dir}/vivado/0_report_modules_missing.rpt" r]
set file_data [read $slurp_report]
set data_ln [split $file_data "\n"]
set report_lines [llength $data_ln]
close $slurp_report

#  Modify the list of missing files in a way to be possible to search for them in the project direcories
set slurp_file [open "${origin_dir}/vivado/0_report_modules_missing.rpt" r]
set all_modules_added_vivado [open $out_file_path_added_vivado "a"]
set all_modules [open $out_file_path "a"]


# Iterate over maximal possible levels in hierarchy (= 10)
set pattern ")/("
set empty_pattern "< empty >"
set missing_simfiles_cnt 0
set missing_simfiles ""
set hier_levels 5
set act_break_level 0
set break_level 15
set hier_done 0

for {set i 0} {$i < $hier_levels} {incr i} {

    # Find empty_pattern in the file indicating there are no missing modules
    report_compile_order -quiet -used_in synthesis -missing_instance
    set slurp_file [open "${origin_dir}/vivado/0_report_modules_missing.rpt" r]
    while {-1 != [gets $slurp_file line]} {
        # If number of occurrences of the word "empty" in a line is 1
        if { [string first $empty_pattern $line] != -1} {
            puts "TCL: Design hierarchy is complete. DONE!"
            puts "TCL: ======= ADDING MISSING MODULES FINISHED ========"
            set hier_done 1
        }
        # do not add the else branch
    }
    close $slurp_file

    if {$hier_done eq 1} {
        break
    }

    # Find all missing modules in the current level of hierarchy
    puts "TCL: ============ ADDING MISSING MODULES ============"
    set slurp_file [open "${origin_dir}/vivado/0_report_modules_missing.rpt" r]
    set line_missing_module_name_prev ""
    while {-1 != [gets $slurp_file line]} {
        # Parse the '0_report_modules_missing' to get list the missing modules
        if { [string first $pattern $line] != -1} {
            set line_part [string map {"\)/\(" "|"} $line]
            set line_missing_module_name [string map {"\)" "|"} $line_part]

            set line_part_trim 1
            if { [string first "|" ${line_missing_module_name}] != -1} {
                while {[lindex [split $line_missing_module_name "|"] $line_part_trim] != ""} {
                    set line_part_trim [expr $line_part_trim+1]
                }
                set line_part_trim [expr $line_part_trim-2]
                set line_missing_module_name [lindex [split $line_missing_module_name "|"] $line_part_trim]
            }

            set line_part_trim 1
            if { [string first "." ${line_missing_module_name}] != -1} {
                while {[lindex [split $line_missing_module_name "."] $line_part_trim] != ""} {
                    set line_part_trim [expr $line_part_trim+1]
                }
                set line_part_trim [expr $line_part_trim-1]
                set line_missing_module_name [lindex [split $line_missing_module_name "."] $line_part_trim]
            }
            set line_missing_module_name [lindex [split $line_missing_module_name "-"] 0]


            set line_missing_module_name_verilog [lindex [split $line_missing_module_name "."] 1]

            # Scan for invalid characters: space " "
            set line_missing_module_name [string map {" " "*"} $line_missing_module_name]
            set line_missing_module_name_verilog [string map {" " "*"} $line_missing_module_name_verilog]

            # Check for invalid beginning of the name - if the name is ""
            if {$line_missing_module_name eq ""} {
                puts "TCL: Invalid file name '$line_missing_module_name' for both verilog and VHDL files. Changing level of hierarchy by 1 up to get the correct file name."
                quit
            } elseif {$line_missing_module_name eq "vhd"} {
                puts "TCL: Invalid file name '$line_missing_module_name' for both verilog and VHDL files. Changing level of hierarchy by 1 up to get the correct file name."
                quit
            } elseif {$line_missing_module_name eq "sv"} {
                puts "TCL: Invalid file name '$line_missing_module_name' for both verilog and VHDL files. Changing level of hierarchy by 1 up to get the correct file name."
                quit
            } elseif {$line_missing_module_name eq "v"} {
                puts "TCL: Invalid file name '$line_missing_module_name' for both verilog and VHDL files. Changing level of hierarchy by 1 up to get the correct file name."
                quit
            } elseif {$i > 0} {
                if {$line_missing_module_name eq $line_missing_module_name_last} {
                    puts "TCL: Module searched for the second time. Quit."
                    quit
                }
            }

            # Check for invalid beginning of the name - if the name contains space " "
            if { [string first " " ${line_missing_module_name}] != -1} {
                puts "TCL: Spaces detected in the filename during searching for sourcefiles. Changing level of hierarchy by 1 up to get the correct file name."
                quit
            }

            # --------------------------------------------
            # - ADDING THE MISSING SOURCE FILE IF EXISTS -
            # --------------------------------------------
            if {$line_missing_module_name_prev ne $line_missing_module_name} {
                add_module ${origin_dir}/modules/$line_missing_module_name
                set line_missing_module_name_prev ${line_missing_module_name}
            }
        }
    }
    close $slurp_file

    set line_missing_module_name_last $line_missing_module_name



    # Report if some files missing in the next level of hierarchy
    # Refresh hierarchy
    update_compile_order
    report_compile_order -quiet -used_in synthesis -missing_instance -file "${origin_dir}/vivado/0_report_modules_missing.rpt"


    # Break if lost in infinite loop
    incr act_break_level
    if {$act_break_level == $break_level} {
        puts "TCL: ERROR: Modules could not be found. Design hierarchy is incomplete. Quit."
        quit
    }

    # No missing files = 6 lines in the report, any higher number signifies at least one missing module in hierarchy
    set slurp_report [open "${origin_dir}/vivado/0_report_modules_missing.rpt" r]
    set file_data [read $slurp_report]
    set data_ln [split $file_data "\n"]
    set report_lines [llength $data_ln]
    close $slurp_report
}

# The last module after search is always the Top module
close $all_modules_added_vivado

# Add global SIM package files (Launch the compile_order.tcl script)
add_module ${origin_dir}/packages/global_sim

# Add global SRC package files (Launch the compile_order.tcl script)
add_module ${origin_dir}/packages/global_src

# Add Sim Tools package files (Launch the compile_order.tcl script)
add_module ${origin_dir}/packages/sim_tools

# Set the new top module after all required sources have been added
set_property TOP $topfile_rootname [current_fileset]
close $all_modules

# Update and report compile order for synthesis
puts "TCL: Let vivado set the required TOP module automatically."
set_property source_mgmt_mode All [current_project]
update_compile_order


# -----------------
# - Print Success -
# -----------------
puts "TCL: All sources under TOP=$topfile_rootname have been added. "
puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "


# Close project
close_project