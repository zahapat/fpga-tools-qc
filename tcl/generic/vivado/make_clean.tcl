# Interesting thread: https://forums.xilinx.com/t5/Vivado-TCL-Community/How-can-I-detect-if-synthesis-needs-to-be-run/td-p/848241

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
    set origin_dir $::origin_dir_loc
}


# Get TCL Command-line arguments
puts "TCL: Get TCL Command-line arguments"
set arguments_cnt 2
if { $::argc == $arguments_cnt } {

    # Library src files
    set lib_src_vhdl [string trim [lindex $::argv 0] ]
    set lib_src_vhdl [string tolower $lib_src_vhdl]
    puts "TCL: Argument 1 lowercase: '$lib_src_vhdl'"

    # Library sim files
    set lib_sim_vhdl [string trim [lindex $::argv 1] ]
    set lib_sim_vhdl [string tolower $lib_sim_vhdl]
    puts "TCL: Argument 2 lowercase: '$lib_sim_vhdl'"

} else {
    puts "TCL: ERROR: There must be $arguments_cnt Command-line argument(s) passed to the TCL script. Total arguments found: $::argc"
    return 1
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


# Delete ILA board files. These can be regennerated after running "make probes"
set ila_default_board_name "board_ila"
set boards_dir "${orig_proj_dir}/boards"
puts "TCL: Removing all links to the board design ${ila_default_board_name}.bd and deleting all files in its folder for its recreation."
file delete -force "${orig_proj_dir}/boards/$ila_default_board_name"


# Before opening the project, remove all links to .xci files to avoid errors in case these files are missing
set del_lines_start 0
set del_lines_end 0
set cnt 0
set slurp_file [open "${origin_dir}/vivado/$_xil_proj_name_.xpr" r]
# set pass_line
set concat_lines ""
set new_line ""
while {-1 != [gets $slurp_file line]} {
    incr cnt 
    if {$del_lines_start == 0} {
        # Detect start where the .xci is included in the .xpr file and skip these lines
        if {[regexp -all {.xci"} $line] == 1} {
            set del_lines_start $cnt
        } else {
            # Pass valid lines
            set new_line [string range $line 0 end]
            set explicit_line "*$new_line"
            # set concat_lines [append $concat_lines "\b$new_line\E"]
            set concat_lines [concat $concat_lines $explicit_line]
            # puts "TCL: PASS $explicit_line"
        }
    } else {
        # Detect end to enable passing valid lines
        if {[regexp -all {</File>} $line] == 1} {
            set del_lines_end $cnt
            incr del_lines_end
            puts "TCL: Removing .xci file from the project $_xil_proj_name_.xpr file detected on lines $del_lines_start-$del_lines_end"
            set del_lines_start 0
        }
    }
}
# puts "TCL: concat_lines:"
# puts "$concat_lines"
close $slurp_file



# Replace the old .xpr with the new lines
set out_file_path "${origin_dir}/vivado/$_xil_proj_name_.xpr"
# set out_file_path "${origin_dir}/vivado/new_xpr_test.xpr"
set xpr_file [open $out_file_path "w"]
set line_part [lindex [split $concat_lines "*"] ]
# while {-1 != [gets $concat_lines line]} {
#     set ln [string range $l 0 "/n"]
#     puts -nonewline $xpr_file "$ln"
# }
foreach l $line_part {
    set ln [string range $l 0 end]
    if {$ln != ""} {
        puts -nonewline $xpr_file "$ln\n"
    }
}
close $xpr_file
# while {-1 != [gets $concat_lines line]} {
# }




# Before opening the project, remove all links to .bd files to avoid errors in case these files are missing
set del_lines_start 0
set del_lines_end 0
set cnt 0
set slurp_file [open "${origin_dir}/vivado/$_xil_proj_name_.xpr" r]
# set pass_line
set concat_lines ""
set new_line ""
while {-1 != [gets $slurp_file line]} {
    incr cnt 
    if {$del_lines_start == 0} {
        # Detect start where the .bd is included in the .xpr file and skip these lines
        if {[regexp -all {.bd"} $line] == 1} {
            set del_lines_start $cnt
        } else {
            # Pass valid lines
            set new_line [string range $line 0 end]
            set explicit_line "*$new_line"
            # set concat_lines [append $concat_lines "\b$new_line\E"]
            set concat_lines [concat $concat_lines $explicit_line]
            # puts "TCL: PASS $explicit_line"
        }
    } else {
        # Detect end to enable passing valid lines
        if {[regexp -all {</File>} $line] == 1} {
            set del_lines_end $cnt
            incr del_lines_end
            puts "TCL: Removing .bd file from the project $_xil_proj_name_.xpr file detected on lines $del_lines_start-$del_lines_end"
            set del_lines_start 0
        }
    }
}
# puts "TCL: concat_lines:"
# puts "$concat_lines"
close $slurp_file

# Replace the old .xpr with the new lines
set out_file_path "${origin_dir}/vivado/$_xil_proj_name_.xpr"
# set out_file_path "${origin_dir}/vivado/new_xpr_test.xpr"
set xpr_file [open $out_file_path "w"]
set line_part [lindex [split $concat_lines "*"] ]
# while {-1 != [gets $concat_lines line]} {
#     set ln [string range $l 0 "/n"]
#     puts -nonewline $xpr_file "$ln"
# }
foreach l $line_part {
    set ln [string range $l 0 end]
    if {$ln != ""} {
        puts -nonewline $xpr_file "$ln\n"
    }
}
close $xpr_file
# while {-1 != [gets $concat_lines line]} {
# }




# Open the project
close_project -quiet
open_project "${origin_dir}/vivado/${_xil_proj_name_}.xpr"

# ------------------
# - CLEAN IP CACHE -
# ------------------
config_ip_cache -clear_output_repo

# ------------------------------
# - CLEAN ALL NON_MODULE FILES -
# ------------------------------

# Remove all non-module files if exist to clean-up the project
puts "TCL: Remove all non-module files if they exist"
remove_files [get_files -filter {IS_AVAILABLE == 0}]


# ------------------------
# - CLEAN ALL .VHD FILES -
# ------------------------

# Set 'sources_1' fileset object
set objSrc [get_filesets sources_1]
set objSim [get_filesets sim_1]
set objConst [get_filesets constrs_1]

# Remove all previous .vhd source files
puts "TCL: Remove all .vhd source files in object fileset sources_1"
remove_files [get_files -of_objects $objSrc]
remove_files [get_files -of_objects $objSim]
remove_files [get_files -of_objects $objConst]


# ------------------------
# - CLEAN ALL .XDC FILES -
# ------------------------

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constr_1' fileset object
set objConst [get_filesets constrs_1]

# Remove all previous .xdc source files
puts "TCL: Remove all .xdc source files in object fileset constrs_1"
remove_files [get_files -of_objects $objConst]


puts "NOTE: Update and report compile order "
update_compile_order
# report_compile_order -file "${origin_dir}/vivado/0_report_compile_order.rpt"

# ------------------------------------------------------
# - CHECK ALL FILES IN FILESET SOURCES_1 AND CONSTRS_1 -
# ------------------------------------------------------

puts "TCL: ----- REPORTS FOR SOURCES_1 -----"
report_property -all $objSrc

puts "TCL: ----- REPORTS FOR SIM_1 -----"
report_property -all $objSim

puts "TCL: ----- REPORTS FOR CONSTRS_1 -----"
report_property -all $objConst

puts "TCL: ----- FILES IN SOURCES_1 -----"
set filesSrc [get_files -of_objects $objSrc]
foreach module $filesSrc {
    set file [string range $module 0 end]
    puts "$file"
}

puts "TCL: ----- FILES IN SIM_1 -----"
set filesSim [get_files -of_objects $objSim]
foreach module $filesSim {
    set file [string range $module 0 end]
    puts "$file"
}

puts "TCL: ----- FILES IN CONSTRS_1 -----"
set filesConst [get_files -of_objects $objConst]
foreach module $filesConst {
    set file [string range $module 0 end]
    puts "$file"
}

puts "TCL: ----- COMPILE ORDER FOR SYNTHESIS (TOP IS ALWAYS AT THE BOTTOM) -----"
set compOrder [get_files -compile_order sources -used_in synthesis]
foreach module $compOrder {
    set file [string range $module 0 end]
    puts "$file"
}

# -----------------------------------------
# - CLEAN OUTPUT FILES, RESET THE PROJECT -
# -----------------------------------------

# Clean project files
reset_project


# --------------------------------------------
# - REMOVE .rpt REPORTS AND CHECKPOINTS .dcp -
# --------------------------------------------
# Delete all .rpt and .dcp files in the vivado folder
puts "TCL: Deleting all .rpt and .dcp files in the vivado folder. "
set files_rpt [glob -nocomplain -type f [file normalize ${origin_dir}]/vivado/*{.rpt}* [file normalize ${origin_dir}]/vivado/*/*{.rpt}*]
if {[llength $files_rpt] != 0} {
    foreach del_file $files_rpt {
        puts "TCL: Deleting file: $del_file"
        file delete $del_file
    }
}
set files_dcp [glob -nocomplain -type f [file normalize ${origin_dir}]/vivado/*{.dcp}* [file normalize ${origin_dir}]/vivado/*/*{.dcp}*]
if {[llength $files_dcp] != 0} {
    foreach del_file $files_dcp {
        puts "TCL: Deleting file: $del_file"
        file delete $del_file
    }
}
set files_edf [glob -nocomplain -type f [file normalize ${origin_dir}]/vivado/*{.edf}* [file normalize ${origin_dir}]/vivado/*/*{.edf}*]
if {[llength $files_edf] != 0} {
    foreach del_file $files_edf {
        puts "TCL: Deleting file: $del_file"
        file delete $del_file
    }
}
set files_bit [glob -nocomplain -type f [file normalize ${origin_dir}]/vivado/*{.bit}* [file normalize ${origin_dir}]/vivado/*/*{.bit}*]
if {[llength $files_bit] != 0} {
    foreach del_file $files_bit {
        puts "TCL: Deleting file: $del_file"
        file delete $del_file
    }
}
set files_hwdef [glob -nocomplain -type f [file normalize ${origin_dir}]/vivado/*{.hwdef}* [file normalize ${origin_dir}]/vivado/*/*{.hwdef}*]
if {[llength $files_hwdef] != 0} {
    foreach del_file $files_hwdef {
        puts "TCL: Deleting file: $del_file"
        file delete $del_file
    }
}
set files_ltx [glob -nocomplain -type f [file normalize ${origin_dir}]/vivado/*{.ltx}* [file normalize ${origin_dir}]/vivado/*/*{.ltx}*]
if {[llength $files_ltx] != 0} {
    foreach del_file $files_ltx {
        puts "TCL: Deleting file: $del_file"
        file delete $del_file
    }
}
set files_edn [glob -nocomplain -type f [file normalize ${origin_dir}]/vivado/*{.edn}* [file normalize ${origin_dir}]/vivado/*/*{.edn}*]
if {[llength $files_edn] != 0} {
    foreach del_file $files_edn {
        puts "TCL: Deleting file: $del_file"
        file delete $del_file
    }
}


# Check if the job has been done
set files_rpt [glob -nocomplain -type f [file normalize ${origin_dir}]/vivado/*{.rpt}* [file normalize ${origin_dir}]/vivado/*/*{.rpt}*]
if {[llength $files_rpt] != 0} {
    puts "TCL: Running $script_file for project $_xil_proj_name_ FAILED. RPT files have not been deleted. "
    # Close project
    close_project
    return 1
}
set files_dcp [glob -nocomplain -type f [file normalize ${origin_dir}]/vivado/*{.dcp}* [file normalize ${origin_dir}]/vivado/*/*{.dcp}*]
if {[llength $files_dcp] != 0} {
    puts "TCL: Running $script_file for project $_xil_proj_name_ FAILED. DCP files have not been deleted. "
    # Close project
    close_project
    return 2
}
set files_edf [glob -nocomplain -type f [file normalize ${origin_dir}]/vivado/*{.edf}* [file normalize ${origin_dir}]/vivado/*/*{.edf}*]
if {[llength $files_edf] != 0} {
    puts "TCL: Running $script_file for project $_xil_proj_name_ FAILED. EDF files have not been deleted. "
    # Close project
    close_project
    return 2
}
set files_bit [glob -nocomplain -type f [file normalize ${origin_dir}]/vivado/*{.bit}* [file normalize ${origin_dir}]/vivado/*/*{.bit}*]
if {[llength $files_bit] != 0} {
    puts "TCL: Running $script_file for project $_xil_proj_name_ FAILED. BIT files have not been deleted. "
    # Close project
    close_project
    return 2
}
set files_hwdef [glob -nocomplain -type f [file normalize ${origin_dir}]/vivado/*{.hwdef}* [file normalize ${origin_dir}]/vivado/*/*{.hwdef}*]
if {[llength $files_hwdef] != 0} {
    puts "TCL: Running $script_file for project $_xil_proj_name_ FAILED. HWDEF files have not been deleted. "
    # Close project
    close_project
    return 2
}
set files_ltx [glob -nocomplain -type f [file normalize ${origin_dir}]/vivado/*{.ltx}* [file normalize ${origin_dir}]/vivado/*/*{.ltx}*]
if {[llength $files_ltx] != 0} {
    puts "TCL: Running $script_file for project $_xil_proj_name_ FAILED. LaTeX LTX files have not been deleted. "
    # Close project
    close_project
    return 2
}
set files_edn [glob -nocomplain -type f [file normalize ${origin_dir}]/vivado/*{.edn}* [file normalize ${origin_dir}]/vivado/*/*{.edn}*]
if {[llength $files_edn] != 0} {
    puts "TCL: Running $script_file for project $_xil_proj_name_ FAILED. ILA Core EDN files have not been deleted. "
    # Close project
    close_project
    return 2
}


# # Remove all the following libraries and mappings
if {[file exist "[file normalize ${origin_dir}]/simulator/work"]} {
    # vmap -del work
    exec vdel -all -lib ${origin_dir}/simulator/work
    puts "TCL: Library 'work' deleted."
}
if {[file exist "[file normalize ${origin_dir}]/simulator/$lib_src_vhdl"]} {
    # vmap -del $lib_src_vhdl
    exec vdel -all -lib ${origin_dir}/simulator/$lib_src_vhdl
    puts "TCL: Library '$lib_src_vhdl' deleted."
}
if {[file exist "[file normalize ${origin_dir}]/simulator/$lib_sim_vhdl"]} {
    # vmap -del $lib_sim_vhdl
    exec vdel -all -lib ${origin_dir}/simulator/$lib_sim_vhdl
    puts "TCL: Library '$lib_sim_vhdl' deleted."
}

# Remove simulator project files, preserve simulator.ini and transctipt
set files_simulator [glob -nocomplain -type f [file normalize ${origin_dir}]/simulator/*]
set required_rundo_file "[file normalize ${origin_dir}]/simulator/run.do"
set required_newdo_file "[file normalize ${origin_dir}]/simulator/new.do"
if {[llength $files_simulator] == 0} {
    puts "TCL: CRITICAL WARNING: Folder ./simulator is empty -> file run.do is not present in the dir ${origin_dir}]/simulator/ . Copy the file to this directory for correct operation of this project environment."
}
if {[llength $files_simulator] != 0} {
    foreach del_file $files_simulator {
        if {$del_file ne "$required_rundo_file"} {
            if {$del_file ne "$required_newdo_file"} {
                puts "TCL: Deleting file from the 'simulator' folder: $del_file"
                file delete $del_file
            }
        }
    }
}

# Remove everything in the .Xil folder!
set files_xil [glob -nocomplain -type f [file normalize ${origin_dir}]/.Xil/*]
if {[llength $files_xil] != 0} {
    foreach del_file $files_xil {
        puts "TCL: Deleting file from the '.Xil' folder: $del_file"
        file delete $del_file
    }
}


# Remove modules.tcl temp file
set del_file "[file normalize ${origin_dir}]/do/modules.tcl"
if {[file exist "$del_file"]} {
    file delete $del_file
    puts "TCL: Deleting modules.tcl file from the 'do' folder: $del_file"
}

# Remove transcript temp file
set del_file "[file normalize ${origin_dir}]/transcript"
if {[file exist "$del_file"]} {
    file delete $del_file
    puts "TCL: Deleting file from the 'root' folder: $del_file"
}

# Remove dump temp file
set del_file "[file normalize ${origin_dir}]/dump.vcd"
if {[file exist "$del_file"]} {
    file delete $del_file
    puts "TCL: Deleting file from the 'root' folder: $del_file"
}

# Remove vsim.wlf temp file
set del_file "[file normalize ${origin_dir}]/vsim.wlf"
if {[file exist "$del_file"]} {
    file delete $del_file
    puts "TCL: Deleting file from the 'root' folder: $del_file"
}



# Close project
puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "
close_project
return 0