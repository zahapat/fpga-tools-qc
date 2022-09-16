# https://forums.xilinx.com/t5/Implementation/Virtual-pins-without-input-values/td-p/946376


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
if { $::argc == 1 } {
    for {set i 0} {$i < $::argc} {incr i} {
        set topFile [ string trim [lindex $::argv $i] ]
        puts "$topFile"
    }
} else {
    puts "TCL: ERROR: There must be one Command-line argument passed to the TCL script. Total arguments found:  $::argc"
    return 1
}


# Search for the given file in the project
puts "TCL: Search for the given file in the project"
set topFileFound [glob */*{$topFile}* */*/*{$topFile}*]

# Assess that the number of occurrences of this file is 1
puts "TCL: Assess that the number of occurrences of this file is 1"
if { [llength $topFileFound] == 1 } {
    puts "TCL: File $topFile exists. "
} else {
    puts "TCL: ERROR: File specified by the Command-line argument does not exist or there are multiple files in the project. "
    return 2
}

# Open and reset the project
close_project -quiet
puts "TCL: OPENING PROJECT $_xil_proj_name_"
open_project "${origin_dir}/vivado/${_xil_proj_name_}.xpr"
reset_project


# ---------------------------
# - REMOVE ALL SOURCE FILES -
# ---------------------------

# Remove all non-module files if exist to clean-up the project
puts "TCL: Remove all files"
remove_files [get_files -filter {IS_AVAILABLE == 0}]

# Create filesets (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set filesets objects
set objSrc [get_filesets sources_1]
set objSim [get_filesets sim_1]
set objConst [get_filesets constrs_1]

# Remove all previous source files
puts "TCL: Remove all source files in object all filesets"
remove_files [get_files -of_objects $objSrc]
remove_files [get_files -of_objects $objSim]
remove_files [get_files -of_objects $objConst]


# --------------------------------------------------
# - SET A NEW TOP MODULE AND ADD IT TO THE PROJECT -
# --------------------------------------------------

# Set the file graph
# https://www.xilinx.com/support/answers/63488.html
# To find the list of missing sources in a hierarchy using a Tcl script,
# you can use the command "report_compile_order" with the argument "-missing_instance".
puts "TCL: Find missing sources to compule tohe new temp top module and report compile order "
set_property source_mgmt_mode All [current_project]

# Set 'sources_1' fileset TOP module
add_files -norecurse -fileset $objSrc ${origin_dir}/$topFileFound
# set_property TOP $topFile [current_fileset]
set newTop [get_property TOP [current_fileset]]
puts "TCL: New TOP file: $newTop"
puts "TCL: Path to the new Top module: $topFileFound"
# report_compile_order -used_in synthesis
# get_files -compile_order sources_1 -used_in synthesis



# ------------------------
# - Find missing modules -
# ------------------------

# List all missing submodules
report_compile_order -fileset sources_1 -used_in synthesis -missing_instance -of [get_ips $newTop] -file "${origin_dir}/vivado/report_modules_missing.rpt"
set missingFiles [report_compile_order -fileset sources_1 -used_in synthesis -missing_instance -of [get_ips $newTop]]
puts "TCL: Exporting missing modules in design here: ${origin_dir}/vivado/0_report_modules_missing.rpt"

# No missing files = 6 lines, any higher number signifies at least one missing module in hierarchy
set slurp_report [open "${origin_dir}/vivado/0_report_modules_missing.rpt" r]
set file_data [read $slurp_report]
set data_ln [split $file_data "\n"]
set report_lines [llength $data_ln]
# puts "$report_lines"
close $slurp_report

#  Modify the list of missing files in a way to be possible to search for them in the project direcories
set slurp_file [open "${origin_dir}/vivado/0_report_modules_missing.rpt" r]
set out_file_path "${origin_dir}/vivado/0_report_adding_modules.rpt"
set all_modules [open $out_file_path "w"]
close $all_modules
set all_modules [open $out_file_path "a"]
set pattern ")/("

# Iterate over maximal possible levels in hierarchy (= 10)
set hier_levels 50
for {set i 0} {$i < $hier_levels} {incr i} {

    # Find all missing modules in the current level of hierarchy
    while {-1 != [gets $slurp_file line]} {

        if { [string first $pattern $line] != -1} {
            set part 5+$i
            set line_part [lindex [split $line ")/("] $part]
            set line_subpart [lindex [split $line_part "-"] 1]
            set module "$line_subpart.vhd"
            # puts "TCL: Searching for module: $module"

            set foundSrcs [glob -nocomplain -type f */*{$module}* */*/*{$module}*]

            if { [llength $foundSrcs] == 1 } {
                # puts "TCL: Adding module: $module"
                set nameFound [string range $foundSrcs 0 end]
                puts "TCL: Adding source file to fileset sources_1: ${origin_dir}/$nameFound"
                add_files -norecurse -fileset $objSrc ${origin_dir}/$nameFound
                puts -nonewline $all_modules "[file normalize ${origin_dir}/$nameFound]\n"
            } 
            if { [llength $foundSrcs] == 0 } {
                puts "TCL: ERROR: Required module $module not found in searched project directories."
                puts -nonewline $all_modules "Missing module: $module\n"
            }
            if { [llength $foundSrcs] > 1 } {
                if {$module != ".vhd"} {
                    puts "TCL: ERROR: There are multiple files found with the name $module. Ensure there is only one in all the searched project directories."
                }
            }
        }
    }

    # Refresh hierarchy
    update_compile_order

    # Report if some files missing in the next level of hierarchy
    close $slurp_file
    report_compile_order -fileset sources_1 -used_in synthesis -missing_instance -of [get_ips $newTop] -file "${origin_dir}/vivado/report_modules_missing.rpt"
    set slurp_file [open "${origin_dir}/vivado/0_report_modules_missing.rpt" r]

    # Find empty_pattern in the file indicating there are no missing modules
    while {-1 != [gets $slurp_file line]} {
        # If number of occurrences of the word "empty" in a line is 1
        if {[regexp -all {empty} $line] == 1} {
            puts "TCL: No modules are missing. Design hierarchy is complete. DONE!"
            set i $hier_levels
            break
        }
    }
    close $slurp_file
    set slurp_file [open "${origin_dir}/vivado/0_report_modules_missing.rpt" r]


    # No missing files = 6 lines in the report, any higher number signifies at least one missing module in hierarchy
    set missingFiles [report_compile_order -fileset sources_1 -used_in synthesis -missing_instance -of [get_ips $newTop]]
    set slurp_report [open "${origin_dir}/vivado/0_report_modules_missing.rpt" r]
    set file_data [read $slurp_report]
    set data_ln [split $file_data "\n"]
    set report_lines [llength $data_ln]
    close $slurp_report
}
close $slurp_file

# The last module is always the Top module
puts -nonewline $all_modules "[file normalize ${origin_dir}/$topFileFound]"
close $all_modules


# ------------------------------
# - Report resultant hierarchy -
# ------------------------------

# Update and report compile order for synthesis
update_compile_order
set compileOrder [get_files -compile_order sources -used_in synthesis]
puts "TCL: Exporting compile order for synthesis here: ${origin_dir}/vivado/0_report_compile_order.rpt "
puts "Compile order:"
puts "$compileOrder"
report_compile_order -file "${origin_dir}/vivado/0_report_compile_order.rpt"


# Close project
puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "
close_project