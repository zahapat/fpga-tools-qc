
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
set orig_proj_dir "."

# Get TCL Command-line arguments
puts "TCL: Get TCL Command-line arguments"
set arguments_cnt 3
if { $::argc == $arguments_cnt } {

    # Top file
    set topFile [string trim [lindex $::argv 0] ]
    puts "TCL: Argument 1 topFile: '$topFile'"

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


# Identify whether a testbench file has been added, otherwise do not add the file
set find_tb_file 0
if { [string first "_top_tb." $topFile] != -1} {
    set topFileTb $topFile
    puts "TCL: topFileTb = $topFileTb"
    set topFile [string map {"_top_tb." "."} $topFile]
    puts "TCL: topFile = $topFile"
    set find_tb_file 1
} elseif { [string first "_tb." $topFile] != -1} {
    set topFileTb $topFile
    puts "TCL: topFileTb = $topFileTb"
    set topFile [string map {"_tb." "."} $topFile]
    puts "TCL: topFile = $topFile"
    set find_tb_file 1
}

if {${find_tb_file} == 1} {
    # Search for the given file in the project
    puts "TCL: Search for the given file in the project"
    set topFileTbFound_path [glob modules/*/{$topFileTb}* modules/*/*/{$topFileTb}* modules/*/*/*/{$topFileTb}* modules/*/*/*/*/{$topFileTb}*]

    # Assess that the number of occurrences of this file is 1
    puts "TCL: Assess that the number of occurrences of this file is 1"
    if { [llength $topFileTbFound_path] == 1 } {
        puts "TCL: TB File $topFileTb exists: $topFileTbFound_path"
    } else {
        puts "TCL: ERROR: TB File specified by the Command-line argument does not exist or there are multiple files in the project. "
        return 2
    }
}


# -------------------------
# - OPEN EXISTING PROJECT -
# -------------------------

# Open and reset the project
# close_project -quiet
puts "TCL: OPENING PROJECT $_xil_proj_name_"
open_project "${origin_dir}/vivado/${_xil_proj_name_}.xpr"
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

# Add IP cores
source "./tcl/project_specific/vivado/add_ip_cores.tcl"

# Add Top File
puts "TCL: Searching for module: $topFile"
set topFile_noposix [lindex [split $topFile "."] 0]
set foundTopSrc [glob -nocomplain -type f modules/*/{${topFile}}* modules/${topFile_noposix}/*/{${topFile}}* modules/${topFile_noposix}/*/*/{${topFile}}* modules/${topFile_noposix}/*/*/*/{${topFile}}*]

if { [llength $foundTopSrc] == 1 } {
    set srcPathFound [string range $foundTopSrc 0 end]
    set abs_path_to_topFile [file dirname "[file normalize ${origin_dir}/$srcPathFound]"]
    puts "TCL: abs_path_to_topFile = $abs_path_to_topFile"

    # Add all existing files from the current module directory (COUNT 1)
    source "$abs_path_to_topFile/../compile_order.tcl"
} else {
    puts "TCL: ERROR: There are multiple files with the name $topFile. Ensure there is only one in all searched project directories."
    quit
}
# lappend ModelSim_SrcsComporder $topFileFound_normalized
# set_property TOP $topFile [current_fileset]
set topFileFound_path $foundTopSrc
set topFileFound_normalized "[file normalize $topFileFound_path]"
set path_to_topfile "[string trimright $topFileFound_normalized $topFile]"
puts "TCL: path_to_topfile = $path_to_topfile"

update_compile_order
set newTop [get_property TOP [current_fileset]]
puts "TCL: New TOP file reported after update_compile_order: $newTop"
puts "TCL: Path to the new Top module: $topFileFound_normalized"
# report_compile_order -used_in synthesis
# get_files -compile_order sources_1 -used_in synthesis


# Set target language of the project based on the TOP file (Verilog, VHDL)
set ip_name [lindex [split $topFileFound_normalized "."] 0]
set file_type [lindex [split $topFileFound_normalized "."] 1]
if {$file_type eq "vhd"} {
    set_property target_language VHDL [current_project]
    puts "TCL: Target language = VHDL"
} elseif {$file_type eq "v"} {
    set_property target_language Verilog [current_project]
    puts "TCL: Target language = Verilog"
} elseif {$file_type eq "sv"} {
    set_property target_language Verilog [current_project]
    puts "TCL: Target language = SystemVerilog (=Verilog)"
} else {
    puts "TCL: Invalid TOP file suffix $file_type. Please enter full name of the TOP file."
    return 3
}



# -------------------------------------
# - Add all files in the packages dir -
# -------------------------------------
set out_file_path_added_vivado "${origin_dir}/vivado/0_report_added_modules.rpt"
set out_file_path "${origin_dir}/do/modules.tcl"



# --------------------------------
# - Detect and find UVVM Sources -
# --------------------------------
report_compile_order -used_in simulation -missing_instance -file "${origin_dir}/vivado/0_report_modules_missing.rpt"

set f_comporder [open "${origin_dir}/vivado/0_report_modules_missing.rpt" r]
set file_data [read $f_comporder]
close $f_comporder

set uvvm_detected_done 0
set detect_uvvm_pattern "uvvm"

set idx 0
foreach item $file_data {
    # puts "TCL: DEBUG: item = $item"
    if { [string first "uvvm" $item] != -1} {
        set uvvm_detected_done 1
        puts "TCL: UVVM DETECTED. Compiling all UVVM-related srcs to separate libraries."
        break
    }
}

# Detect UVVM and add all sources. This will not be added to comporder modules.tcl. Place them in libs.
set unsupported_module "bitvis_vip_ethernet"
set unsupported_skip 0
if {$uvvm_detected_done == 1} {
    set uvvm_all_lib_names [glob -nocomplain -directory "${origin_dir}/packages/uvvm/" type d *]
    foreach act_uvvm_dirpath $uvvm_all_lib_names {
        # Libname = actual dir name
        set act_uvvm_lib [file tail "[file normalize $act_uvvm_dirpath]"]
        puts "TCL: Adding UVVM source = $act_uvvm_lib"

        if {$act_uvvm_lib eq $unsupported_module} {
            set unsupported_skip 1
            puts "TCL: ... unsupported source."
        }

        # Add all files except for the ones xilinx has troubles to compile
        if {$unsupported_skip == 0} {
            set uvvm_files_in_dirpath [glob -nocomplain -directory "$act_uvvm_dirpath" type d src/*{.vhd}]   
            foreach f $uvvm_files_in_dirpath {
                read_vhdl -library "$act_uvvm_lib" -vhdl2008 $f
            }
        }
        set unsupported_skip 0
    }
    set uvvm_detected_done 1
    report_compile_order -used_in simulation -missing_instance -file "${origin_dir}/vivado/0_report_modules_missing.rpt"
    set missingFiles [report_compile_order -used_in simulation -missing_instance]
}

# Compile User VIPs (if there are any)
if {$uvvm_detected_done == 1} {
    set uvvm_all_lib_names [glob -nocomplain -directory "${origin_dir}/packages/vip/" type d *]
    foreach act_uvvm_dirpath $uvvm_all_lib_names {
        # Libname = actual dir name
        set act_uvvm_lib [file tail "[file normalize $act_uvvm_dirpath]"]
        puts "TCL: Adding UVVM source = $act_uvvm_lib"

        # Add all files
        set uvvm_files_in_dirpath [glob -nocomplain -directory "$act_uvvm_dirpath" type d *{.vhd} */*{.vhd}]
        foreach f $uvvm_files_in_dirpath {
            read_vhdl -library "$act_uvvm_lib" -vhdl2008 $f
        }
    }
    report_compile_order -used_in simulation -missing_instance -file "${origin_dir}/vivado/0_report_modules_missing.rpt"
    set missingFiles [report_compile_order -used_in simulation -missing_instance]
}




# ------------------------------------
# - Find missing .vhd/.v/.sv modules -
# ------------------------------------
# List all missing submodules
report_compile_order -used_in synthesis -missing_instance -file "${origin_dir}/vivado/0_report_modules_missing.rpt"
set missingFiles [report_compile_order -used_in synthesis -missing_instance]
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
    report_compile_order -used_in synthesis -missing_instance
    set slurp_file [open "${origin_dir}/vivado/0_report_modules_missing.rpt" r]
    while {-1 != [gets $slurp_file line]} {
        # If number of occurrences of the word "empty" in a line is 1
        if { [string first $empty_pattern $line] != -1} {
            puts "TCL: Design hierarchy is complete. DONE!"
            set hier_done 1
        }
        # do not add the else branch
    }
    close $slurp_file

    if {$hier_done eq 1} {
        break
    }

    # Find all missing modules in the current level of hierarchy
    puts "TCL: ===== ADDING MISSING MODULES ====="
    set slurp_file [open "${origin_dir}/vivado/0_report_modules_missing.rpt" r]
    while {-1 != [gets $slurp_file line]} {

        # Search for modules in each hierarchy level
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
            puts "TCL: Searching for module name: $line_missing_module_name"

            
            set line_missing_module_name_verilog [lindex [split $line_missing_module_name "."] 1]

            # Scan for invalid characters: space " "
            set line_missing_module_name [string map {" " "*"} $line_missing_module_name]
            set line_missing_module_name_verilog [string map {" " "*"} $line_missing_module_name_verilog]

            # puts "TCL: DEBUG: line_missing_module_name = $line_missing_module_name"

            # Check for invalid beginning of the name - if the name is ""
            if {$line_missing_module_name eq ""} {
                puts "TCL: Invalid file name for both verilog and VHDL files. Changing level of hierarchy by 1 up to get the correct file name."
                quit
            } elseif {$line_missing_module_name eq "vhd"} {
                puts "TCL: Invalid file name for both verilog and VHDL files. Changing level of hierarchy by 1 up to get the correct file name."
                quit
            } elseif {$line_missing_module_name eq "sv"} {
                puts "TCL: Invalid file name for both verilog and VHDL files. Changing level of hierarchy by 1 up to get the correct file name."
                quit
            } elseif {$line_missing_module_name eq "v"} {
                puts "TCL: Invalid file name for both verilog and VHDL files. Changing level of hierarchy by 1 up to get the correct file name."
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

            # Top=VHD/SV/V, Looking for VHDL
            if {$file_type eq "vhd"} {
                set moduleVHD "${line_missing_module_name}.vhd"
                set moduleVHDpack "${line_missing_module_name}_pack.vhd"
                set moduleVHDsim "${line_missing_module_name}_tb.vhd"
                set moduleVHDsimpack "${line_missing_module_name}_pack_tb.vhd"
            } elseif {$file_type eq "sv"} {
                set moduleVHD "${line_missing_module_name}.vhd"
                set moduleVHDpack "${line_missing_module_name}_pack.vhd"
                set moduleVHDsim "${line_missing_module_name}_tb.vhd"
                set moduleVHDsimpack "${line_missing_module_name}_pack_tb.vhd"
            } elseif {$file_type eq "v"} {
                set moduleVHD "${line_missing_module_name}.vhd"
                set moduleVHDpack "${line_missing_module_name}_pack.vhd"
                set moduleVHDsim "${line_missing_module_name}_tb.vhd"
                set moduleVHDsimpack "${line_missing_module_name}_pack_tb.vhd"
            } else {
                puts "TCL: ERROR: Invalid file type '$file_type' of the specified TOP file. Quit."
                quit
            }

            # Top=VHD/SV/V, Looking for SystemVerilog
            if {$file_type eq "vhd"} {
                set moduleSV "${line_missing_module_name}.sv"
                set moduleSVpack "${line_missing_module_name}_pack.sv"
                set moduleSVsim "${line_missing_module_name}_tb.sv"
                set moduleSVsimpack "${line_missing_module_name}_pack_tb.sv"
            } elseif {$file_type eq "sv"} {
                set moduleSV "${line_missing_module_name}.sv"
                set moduleSVpack "${line_missing_module_name}_pack.sv"
                set moduleSVsim "${line_missing_module_name}_tb.sv"
                set moduleSVsimpack "${line_missing_module_name}_pack_tb.sv"
            } elseif {$file_type eq "v"} {
                set moduleSV "${line_missing_module_name}.sv"
                set moduleSVpack "${line_missing_module_name}_pack.sv"
                set moduleSVsim "${line_missing_module_name}_tb.sv"
                set moduleSVsimpack "${line_missing_module_name}_pack_tb.sv"
            } else {
                puts "TCL: ERROR: Invalid file type '$file_type' of the specified TOP file. Quit."
                quit
            }

            # Top=VHD/SV/V, Looking for Verilog
            if {$file_type eq "vhd"} {
                set moduleV "${line_missing_module_name}.v"
                set moduleVpack "${line_missing_module_name}_pack.v"
                set moduleVsim "${line_missing_module_name}_tb.v"
                set moduleVsimpack "${line_missing_module_name}_pack_tb.v"
            } elseif {$file_type eq "sv"} {
                set moduleV "${line_missing_module_name}.v"
                set moduleVpack "${line_missing_module_name}_pack.v"
                set moduleVsim "${line_missing_module_name}_tb.v"
                set moduleVsimpack "${line_missing_module_name}_pack_tb.v"
            } elseif {$file_type eq "v"} {
                set moduleV "${line_missing_module_name}.v"
                set moduleVpack "${line_missing_module_name}_pack.v"
                set moduleVsim "${line_missing_module_name}_tb.v"
                set moduleVsimpack "${line_missing_module_name}_pack_tb.v"
            } else {
                puts "TCL: ERROR: Invalid file type '$file_type' of the specified TOP file. Quit."
                quit
            }

            # ----------------------------
            # - SEARCHING FOR .VHD FILES -
            # ----------------------------
            puts "TCL: Searching for module: $moduleVHD"
            set foundSrcsVHD [glob -nocomplain -type f modules/*/{$moduleVHD}* modules/$line_missing_module_name/*/{$moduleVHD}* modules/$line_missing_module_name/*/*/{$moduleVHD}* modules/$line_missing_module_name/*/*/*/{$moduleVHD}*]

            if { [llength $foundSrcsVHD] == 1 } {
                set srcPathFound [string range $foundSrcsVHD 0 end]
                set abs_path_to_filedir [file dirname "[file normalize ${origin_dir}/$srcPathFound]"]
                puts "TCL: abs_path_to_filedir = $abs_path_to_filedir"

                # Add all existing files from the current module directory
                source "$abs_path_to_filedir/../compile_order.tcl"

            }
            if { [llength $foundSrcsVHD] > 1 } {
                if {$moduleVHD != ".vhd"} {
                    puts "TCL: ERROR: There are multiple files with the name $moduleVHD. Ensure there is only one in all searched project directories."
                    quit
                }
            }
            if { [llength $foundSrcsVHD] == 0 } {

                # ---------------------------
                # - SEARCHING FOR .SV FILES -
                # ---------------------------
                puts "TCL: Module $moduleVHD not found; searching for $moduleSV file. "
                set foundSrcsSV [glob -nocomplain -type f modules/*/{$moduleSV}* modules/$line_missing_module_name/*/{$moduleSV}* modules/$line_missing_module_name/*/*/{$moduleSV}* modules/$line_missing_module_name/*/*/*/{$moduleSV}*]

                if { [llength $foundSrcsSV] == 1 } {
                    set srcPathFound [string range $foundSrcsSV 0 end]
                    set abs_path_to_filedir [file dirname "[file normalize ${origin_dir}/$srcPathFound]"]
                    puts "TCL: abs_path_to_filedir = $abs_path_to_filedir"

                    # Add all existing files from the current module directory
                    source "$abs_path_to_filedir/../compile_order.tcl"

                } elseif { [llength $foundSrcsSV] > 1 } {
                    if {$moduleSV != ".sv"} {
                        puts "TCL: ERROR: There are multiple files with the name $moduleSV. Ensure there is only one in all searched project directories."
                        quit
                    }
                } elseif { [llength $foundSrcsSV] == 0 } {

                    # --------------------------
                    # - SEARCHING FOR .V FILES -
                    # --------------------------
                    puts "TCL: Module $moduleSV not found; searching for $moduleV file. "
                    set foundSrcsV [glob -nocomplain -type f modules/*/{$moduleV}* modules/$line_missing_module_name/*/{$moduleV}* modules/$line_missing_module_name/*/*/{$moduleV}* modules/$line_missing_module_name/*/*/*/{$moduleV}*]

                    if { [llength $foundSrcsV] == 1 } {
                        set srcPathFound [string range $foundSrcsV 0 end]
                        set abs_path_to_filedir [file dirname "[file normalize ${origin_dir}/$srcPathFound]"]
                        puts "TCL: abs_path_to_filedir = $abs_path_to_filedir"

                        # Add all existing files from the current module directory
                        source "$abs_path_to_filedir/../compile_order.tcl"


                    } elseif { [llength $foundSrcsV] > 1 } {
                        if {$moduleV != ".v"} {
                            puts "TCL: ERROR: There are multiple files with the name $moduleV. Ensure there is only one in all searched project directories."
                            quit
                        }
                    } elseif { [llength $foundSrcsV] == 0 } {
                        puts "TCL: ERROR: Required module $line_missing_module_name (.vhd/.v/.sv) not found in all searched project directories."
                        quit
                    }
                }
            }
        }
    }
    close $slurp_file

    set line_missing_module_name_last $line_missing_module_name



    # Report if some files missing in the next level of hierarchy
    # Refresh hierarchy
    update_compile_order
    report_compile_order -used_in synthesis -missing_instance -file "${origin_dir}/vivado/0_report_modules_missing.rpt"


    # Break if lost in infinite loop
    incr act_break_level
    if {$act_break_level == $break_level} {
        puts "TCL: ERROR: Modules could not be found. Design hierarchy is incomplete. Quit."
        quit
    }

    # No missing files = 6 lines in the report, any higher number signifies at least one missing module in hierarchy
    set missingFiles [report_compile_order -used_in synthesis -missing_instance]
    set slurp_report [open "${origin_dir}/vivado/0_report_modules_missing.rpt" r]
    set file_data [read $slurp_report]
    set data_ln [split $file_data "\n"]
    set report_lines [llength $data_ln]
    close $slurp_report
}

# The last module after search is always the Top module
puts -nonewline $all_modules_added_vivado "./$topFileFound_path"
close $all_modules_added_vivado


# Add Global Packages: used by every module
source "./packages/proj_specific_sim/compile_order.tcl"
source "./packages/proj_specific_src/compile_order.tcl"
source "./packages/sim_tools/compile_order.tcl"


# Set the new top module after all required sources have been added
set_property TOP $topFile [current_fileset]
close $all_modules


# Update and report compile order for synthesis
puts "TCL: Let vivado choose the correct TOP module"
set_property source_mgmt_mode All [current_project]
update_compile_order


# -----------------
# - Print Success -
# -----------------
puts "TCL: All sources under TOP=$topFile have been added. "
puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "


# Close project
close_project