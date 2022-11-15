# https://forums.xilinx.com/t5/Implementation/Virtual-pins-without-input-values/td-p/946376


# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
    set origin_dir $::origin_dir_loc
    puts "TCL: ::origin_dir_loc = $origin_dir"
} else {
    puts "TCL: origin_dir = $origin_dir"
}

# Set the project name
set _xil_proj_name_ [file tail [file dirname "[file normalize ./Makefile]"]]

# Use project name variable, if specified in the tcl shell
if { [info exists ::user_project_name] } {
    set _xil_proj_name_ $::user_project_name
    puts "TCL: ::user_project_name = $_xil_proj_name_"
} else {
    puts "TCL: _xil_proj_name_: $_xil_proj_name_"
}

variable script_file
set script_file "[file tail [info script]]"
puts "TCL: Running $script_file for project $_xil_proj_name_."

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/"]"
puts "TCL: orig_proj_dir: $orig_proj_dir"



# Get TCL Command-line arguments: Target FPGA part
puts "TCL: Get TCL Command-line arguments"
if { $::argc == 1 } {
    for {set i 0} {$i < $::argc} {incr i} {
        set target_FPGA_part [ string trim [lindex $::argv $i] ]
        set target_FPGA_part [string tolower $target_FPGA_part]
        puts "$target_FPGA_part"
    }
} else {
    puts "TCL: ERROR: There must be one Command-line argument passed to the TCL script. Total arguments found:  $::argc"
    return 1
}


# Search for the given file in the project
# puts "TCL: Search for the given file in the project"
# set topFileFound [glob */*{$topFile}* */*/*{$topFile}*]

# Assess that the number of occurrences of this file is 1
# puts "TCL: Assess that the number of occurrences of this file is 1"
# if { [llength $topFileFound] == 1 } {
#     puts "TCL: File $topFile exists. "
# } else {
#     puts "TCL: ERROR: File specified by the Command-line argument does not exist or there are multiple files in the project. "
#     return 2
# }

# Delete content in the folder "$origin_dir/vivado/"

# ------------------
# - Create project -
# ------------------
# Delete previous content in the folder ./vivado/

file delete -force "$origin_dir/vivado/{*}"
# file mkdir "$origin_dir/vivado/"

create_project -force ${_xil_proj_name_} -dir "$orig_proj_dir/vivado/"

# create_project -force ${_xil_proj_name_} -dir "$orig_proj_dir/vivado/" -part xc7z020clg400-1
# ${_xil_proj_name_} -part xc7z020clg400-1
# save_project_as -force ${_xil_proj_name_} "$orig_proj_dir/vivado/"

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]
puts "TCL: origin_dir: $origin_dir"
puts "TCL: proj_dir: $proj_dir"
puts "TCL: orig_proj_dir: $orig_proj_dir"
puts "TCL: Project is being created here: $origin_dir/vivado/"



# -----------------------------------
# - Properties for current Project --
# -----------------------------------

set obj [current_project]
puts "TCL: list_property \[current project\]:"
puts "TCL: [list_property $obj]"
set_property source_mgmt_mode All [current_project]
# set_property -name "board_part_repo_paths" -value "[file normalize "$origin_dir/../../../../../AppData/Roaming/Xilinx/Vivado/2020.2/xhub/board_store/xilinx_board_store"]" -objects $obj

# List All Boards
set all_board_parts [get_board_parts]

# Parse Boards and find the correct vlnv for the desired board
set idx 0
set act_board_part_vlnv " "
while {$act_board_part_vlnv ne ""} {
    set act_board_part_vlnv [lindex [split $all_board_parts " "] $idx]
    set act_board_part_name [lindex [split $act_board_part_vlnv ":"] 1]
    incr idx
    puts "TCL DEBUG: act_board_part_vlnv = $act_board_part_vlnv"
    puts "TCL DEBUG: act_board_part_name = $act_board_part_name"
    if {$act_board_part_name eq $target_FPGA_part} {
        set_property -name "board_part" -value $act_board_part_vlnv -objects $obj
        set_property -name "platform.board_id" -value $act_board_part_name -objects $obj
        break;
    }
    if {$act_board_part_vlnv eq ""} {
        puts "TCL: Inputted FPGA part number $target_FPGA_part is not an evaluation board."
        set_property -name part -value $target_FPGA_part -objects $obj
    }
}


# *** UNCOMMENT IF THE PART IS A BOARD OR NOT, THEN FILL IN THE CORRECT BOARD_PART ***
# !!! This influences how the connection automation handles creating and interconnecting new instances !!!
# set_property board_part digilentinc.com:arty-s7-50:part0:1.0 [current_project]
# set_property -name "board_part" -value "tul.com.tw:pynq-z2:part0:1.0" -objects $obj

# set_property -name "platform.board_id" -value "pynq-z2" -objects $obj
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
# set_property -name "ip_output_repo" -value "$proj_dir/vivado/${_xil_proj_name_}.cache/ip" -objects $obj
set_property -name "ip_output_repo" -value "$origin_dir/ip" -objects $obj
# set_property -name "ip_output_repo" -value "$orig_proj_dir/ip_cache/" -objects $obj
# set_property -name "IPDefaultOutputPath" -value "$origin_dir/ip/" -objects $obj
# <Option Name="IPRepoPath" Val="$PPRDIR/../ip/ip_pack_0"/>
# set_property -name "IPRepoPath" -value "$origin_dir/ip/" -objects $obj
set_property -name "mem.enable_memory_map_generation" -value "1" -objects $obj
set_property -name "sim.central_dir" -value "$orig_proj_dir/vivado/${_xil_proj_name_}.ip_user_files" -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj
set_property -name "target_language" -value "VHDL" -objects $obj


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


# # --------------------------------------------------
# # - SET A NEW TOP MODULE AND ADD IT TO THE PROJECT -
# # --------------------------------------------------

# # Set the file graph
# # https://www.xilinx.com/support/answers/63488.html
# # To find the list of missing sources in a hierarchy using a Tcl script,
# # you can use the command "report_compile_order" with the argument "-missing_instance".
# puts "TCL: Find missing sources to compule tohe new temp top module and report compile order "
# set_property source_mgmt_mode All [current_project]

# # Set 'sources_1' fileset TOP module
# add_files -norecurse -fileset $objSrc ${origin_dir}/$topFileFound
# # set_property TOP $topFile [current_fileset]
# set newTop [get_property TOP [current_fileset]]
# puts "TCL: New TOP file: $newTop"
# puts "TCL: Path to the new Top module: $topFileFound"
# # report_compile_order -used_in synthesis
# # get_files -compile_order sources_1 -used_in synthesis



# # -----------------------------
# # - Find missing .vhd modules -
# # -----------------------------

# # List all missing submodules
# report_compile_order -fileset sources_1 -used_in synthesis -missing_instance -of [get_ips $newTop] -file "${origin_dir}/vivado/report_modules_missing.rpt"
# set missingFiles [report_compile_order -fileset sources_1 -used_in synthesis -missing_instance -of [get_ips $newTop]]
# puts "TCL: Exporting missing modules in design here: ${origin_dir}/vivado/report_modules_missing.rpt"

# # No missing files = 6 lines, any higher number signifies at least one missing module in hierarchy
# set slurp_report [open "${origin_dir}/vivado/report_modules_missing.rpt" r]
# set file_data [read $slurp_report]
# set data_ln [split $file_data "\n"]
# set report_lines [llength $data_ln]
# # puts "$report_lines"
# close $slurp_report

# #  Modify the list of missing files in a way to be possible to search for them in the project direcories
# set slurp_file [open "${origin_dir}/vivado/report_modules_missing.rpt" r]
# set out_file_path "${origin_dir}/vivado/report_adding_modules.rpt"
# set all_modules [open $out_file_path "w"]
# close $all_modules
# set all_modules [open $out_file_path "a"]
# set pattern ")/("
# set empty_pattern "< empty >"

# # Iterate over maximal possible levels in hierarchy (= 10)
# set hier_levels 50
# for {set i 0} {$i < $hier_levels} {incr i} {

#     # Find all missing modules in the current level of hierarchy
#     while {-1 != [gets $slurp_file line]} {

#         if { [string first $pattern $line] != -1} {
#             set part 5+$i
#             set line_part [lindex [split $line ")/("] $part]
#             set line_subpart [lindex [split $line_part "-"] 1]
#             set module "$line_subpart.vhd"
#             # puts "TCL: Searching for module: $module"

#             set foundSrcs [glob -nocomplain -type f */*{$module}* */*/*{$module}*]

#             if { [llength $foundSrcs] == 1 } {
#                 # puts "TCL: Adding module: $module"
#                 set nameFound [string range $foundSrcs 0 end]
#                 puts "TCL: Adding source file to fileset sources_1: ${origin_dir}/$nameFound"
#                 add_files -norecurse -fileset $objSrc ${origin_dir}/$nameFound
#                 puts -nonewline $all_modules "[file normalize ${origin_dir}/$nameFound]\n"
#             } 
#             if { [llength $foundSrcs] == 0 } {
#                 puts "TCL: ERROR: Required module $module not found in searched project directories."
#                 puts -nonewline $all_modules "Missing module: $module\n"
#             }
#             if { [llength $foundSrcs] > 1 } {
#                 if {$module != ".vhd"} {
#                     puts "TCL: ERROR: There are multiple files found with the name $module. Ensure there is only one in all the searched project directories."
#                 }
#             }
#         }
#     }

#     # Refresh hierarchy
#     update_compile_order

#     # Report if some files missing in the next level of hierarchy
#     close $slurp_file
#     report_compile_order -fileset sources_1 -used_in synthesis -missing_instance -of [get_ips $newTop] -file "${origin_dir}/vivado/report_modules_missing.rpt"
#     set slurp_file [open "${origin_dir}/vivado/report_modules_missing.rpt" r]

#     # Find empty_pattern in the file indicating there are no missing modules
#     while {-1 != [gets $slurp_file line]} {
#         # If number of occurrences of the word "empty" in a line is 1
#         if {[regexp -all {empty} $line] == 1} {
#             puts "TCL: No modules are missing. Design hierarchy is complete. DONE!"
#             set i $hier_levels
#             break
#         }
#     }
#     close $slurp_file
#     set slurp_file [open "${origin_dir}/vivado/report_modules_missing.rpt" r]


#     # No missing files = 6 lines in the report, any higher number signifies at least one missing module in hierarchy
#     set missingFiles [report_compile_order -fileset sources_1 -used_in synthesis -missing_instance -of [get_ips $newTop]]
#     set slurp_report [open "${origin_dir}/vivado/report_modules_missing.rpt" r]
#     set file_data [read $slurp_report]
#     set data_ln [split $file_data "\n"]
#     set report_lines [llength $data_ln]
#     close $slurp_report
# }
# close $slurp_file

# # The last module is always the Top module
# puts -nonewline $all_modules "[file normalize ${origin_dir}/$topFileFound]"
# close $all_modules


# # ---------------------------
# # - Find and add all .xdc files -
# # ---------------------------

# # Search for all .xdc sources
# set foundConst [glob -type f */*{.xdc}* */*/*{.xdc}*]

# # Add all the .xdc sources to the project
# foreach f $foundConst {
#     set name [string range $f 0 end]
#     puts "TCL: Adding source to fileset constrs_1: ${origin_dir}/$name"
#     add_files -norecurse -fileset $objConst ${origin_dir}/$name
# }

# puts "TCL: ----- FILES IN CONSTRS_1 -----"
# set filesConst [get_files -of_objects $objConst]
# foreach module $filesConst {
#     set file [string range $module 0 end]
#     puts "$file"
# }


# # -----------------
# # - Print Success -
# # -----------------
# puts "TCL: ----- ADDING SOURCES UNDER TOP=$topFile FINISHED -----"



# # --------------------
# # - Report hierarchy -
# # --------------------

# # Update and report compile order for synthesis
# update_compile_order
# set compileOrder [get_files -compile_order sources -used_in synthesis]
# puts "TCL: Exporting compile order for synthesis here: ${origin_dir}/vivado/report_compile_order.rpt "
# puts "Compile order:"
# puts "$compileOrder"
# report_compile_order -file "${origin_dir}/vivado/report_compile_order.rpt"


# ----------------
# - Utilisation --
# ----------------

# Set 'utils_1' fileset object
set obj [get_filesets utils_1]
# Empty (no sources present)

# Set 'utils_1' fileset properties
set obj [get_filesets utils_1]


# -----------------------------
# - Properties for Synthesis --
# -----------------------------

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
    create_run -name synth_1 -part $target_FPGA_part -flow {Vivado Synthesis 2020} -strategy "Vivado Synthesis Defaults" -report_strategy {No Reports} -constrset constrs_1
    # create_run -name synth_1 -part xc7z020clg400-1 -flow {Vivado Synthesis 2020} -strategy "Vivado Synthesis Defaults" -report_strategy {No Reports} -constrset constrs_1
} else {
    set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
    set_property flow "Vivado Synthesis 2020" [get_runs synth_1]
}
set obj [get_runs synth_1]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Synthesis Default Reports} $obj
set_property set_report_strategy_name 0 $obj
# Create 'synth_1_synth_report_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs synth_1] synth_1_synth_report_utilization_0] "" ] } {
    create_report_config -report_name synth_1_synth_report_utilization_0 -report_type report_utilization:1.0 -steps synth_design -runs synth_1
}
set obj [get_report_configs -of_objects [get_runs synth_1] synth_1_synth_report_utilization_0]
if { $obj != "" } {

}
set obj [get_runs synth_1]
set_property -name "needs_refresh" -value "1" -objects $obj
set_property -name "strategy" -value "Vivado Synthesis Defaults" -objects $obj

# set the current synth run
current_run -synthesis [get_runs synth_1]


# ----------------------------------
# - Properties for Implementation --
# ----------------------------------

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
    create_run -name impl_1 -part $target_FPGA_part -flow {Vivado Implementation 2020} -strategy "Vivado Implementation Defaults" -report_strategy {No Reports} -constrset constrs_1 -parent_run synth_1
    # create_run -name impl_1 -part xc7z020clg400-1 -flow {Vivado Implementation 2020} -strategy "Vivado Implementation Defaults" -report_strategy {No Reports} -constrset constrs_1 -parent_run synth_1
} else {
    set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
    set_property flow "Vivado Implementation 2020" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Implementation Default Reports} $obj
set_property set_report_strategy_name 0 $obj
# Create 'impl_1_init_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_init_report_timing_summary_0] "" ] } {
    create_report_config -report_name impl_1_init_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps init_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_init_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_opt_report_drc_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_opt_report_drc_0] "" ] } {
    create_report_config -report_name impl_1_opt_report_drc_0 -report_type report_drc:1.0 -steps opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_opt_report_drc_0]
if { $obj != "" } {

}
# Create 'impl_1_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_opt_report_timing_summary_0] "" ] } {
    create_report_config -report_name impl_1_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_power_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_power_opt_report_timing_summary_0] "" ] } {
    create_report_config -report_name impl_1_power_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps power_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_power_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_place_report_io_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_io_0] "" ] } {
    create_report_config -report_name impl_1_place_report_io_0 -report_type report_io:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_io_0]
if { $obj != "" } {

}
# Create 'impl_1_place_report_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_utilization_0] "" ] } {
    create_report_config -report_name impl_1_place_report_utilization_0 -report_type report_utilization:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_utilization_0]
if { $obj != "" } {

}
# Create 'impl_1_place_report_control_sets_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_control_sets_0] "" ] } {
    create_report_config -report_name impl_1_place_report_control_sets_0 -report_type report_control_sets:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_control_sets_0]
if { $obj != "" } {
set_property -name "options.verbose" -value "1" -objects $obj

}
# Create 'impl_1_place_report_incremental_reuse_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_0] "" ] } {
    create_report_config -report_name impl_1_place_report_incremental_reuse_0 -report_type report_incremental_reuse:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj

}
# Create 'impl_1_place_report_incremental_reuse_1' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_1] "" ] } {
    create_report_config -report_name impl_1_place_report_incremental_reuse_1 -report_type report_incremental_reuse:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_1]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj

}
# Create 'impl_1_place_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_timing_summary_0] "" ] } {
    create_report_config -report_name impl_1_place_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_post_place_power_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_post_place_power_opt_report_timing_summary_0] "" ] } {
    create_report_config -report_name impl_1_post_place_power_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps post_place_power_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_post_place_power_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_phys_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_phys_opt_report_timing_summary_0] "" ] } {
    create_report_config -report_name impl_1_phys_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps phys_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_phys_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_route_report_drc_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_drc_0] "" ] } {
    create_report_config -report_name impl_1_route_report_drc_0 -report_type report_drc:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_drc_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_methodology_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_methodology_0] "" ] } {
    create_report_config -report_name impl_1_route_report_methodology_0 -report_type report_methodology:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_methodology_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_power_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_power_0] "" ] } {
    create_report_config -report_name impl_1_route_report_power_0 -report_type report_power:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_power_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_route_status_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_route_status_0] "" ] } {
    create_report_config -report_name impl_1_route_report_route_status_0 -report_type report_route_status:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_route_status_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_timing_summary_0] "" ] } {
    create_report_config -report_name impl_1_route_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_timing_summary_0]
if { $obj != "" } {
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_route_report_incremental_reuse_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_incremental_reuse_0] "" ] } {
    create_report_config -report_name impl_1_route_report_incremental_reuse_0 -report_type report_incremental_reuse:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_incremental_reuse_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_clock_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_clock_utilization_0] "" ] } {
    create_report_config -report_name impl_1_route_report_clock_utilization_0 -report_type report_clock_utilization:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_clock_utilization_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_bus_skew_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_bus_skew_0] "" ] } {
  create_report_config -report_name impl_1_route_report_bus_skew_0 -report_type report_bus_skew:1.1 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_bus_skew_0]
if { $obj != "" } {
    set_property -name "options.warn_on_violation" -value "1" -objects $obj
}
# Create 'impl_1_post_route_phys_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_post_route_phys_opt_report_timing_summary_0] "" ] } {
    create_report_config -report_name impl_1_post_route_phys_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps post_route_phys_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_post_route_phys_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.warn_on_violation" -value "1" -objects $obj

}
# Create 'impl_1_post_route_phys_opt_report_bus_skew_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_post_route_phys_opt_report_bus_skew_0] "" ] } {
  create_report_config -report_name impl_1_post_route_phys_opt_report_bus_skew_0 -report_type report_bus_skew:1.1 -steps post_route_phys_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_post_route_phys_opt_report_bus_skew_0]
if { $obj != "" } {
set_property -name "options.warn_on_violation" -value "1" -objects $obj

}
set obj [get_runs impl_1]
set_property -name "needs_refresh" -value "1" -objects $obj
set_property -name "strategy" -value "Vivado Implementation Defaults" -objects $obj
set_property -name "steps.write_bitstream.args.readback_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.verbose" -value "0" -objects $obj

# set the current impl run
current_run -implementation [get_runs impl_1]

puts "TCL: Project created: ${_xil_proj_name_}"



# ---------------------------
# - Properties for Reports --
# ---------------------------
# Create 'drc_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "drc_1" ] ] ""]} {
    create_dashboard_gadget -name {drc_1} -type drc
}
set obj [get_dashboard_gadgets [ list "drc_1" ] ]
set_property -name "reports" -value "impl_1#impl_1_route_report_drc_0" -objects $obj

# Create 'methodology_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "methodology_1" ] ] ""]} {
    create_dashboard_gadget -name {methodology_1} -type methodology
}
set obj [get_dashboard_gadgets [ list "methodology_1" ] ]
set_property -name "reports" -value "impl_1#impl_1_route_report_methodology_0" -objects $obj

# Create 'power_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "power_1" ] ] ""]} {
    create_dashboard_gadget -name {power_1} -type power
}
set obj [get_dashboard_gadgets [ list "power_1" ] ]
set_property -name "reports" -value "impl_1#impl_1_route_report_power_0" -objects $obj

# Create 'timing_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "timing_1" ] ] ""]} {
    create_dashboard_gadget -name {timing_1} -type timing
}
set obj [get_dashboard_gadgets [ list "timing_1" ] ]
set_property -name "reports" -value "impl_1#impl_1_route_report_timing_summary_0" -objects $obj

# Create 'utilization_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "utilization_1" ] ] ""]} {
    create_dashboard_gadget -name {utilization_1} -type utilization
}
set obj [get_dashboard_gadgets [ list "utilization_1" ] ]
set_property -name "reports" -value "synth_1#synth_1_synth_report_utilization_0" -objects $obj
set_property -name "run.step" -value "synth_design" -objects $obj
set_property -name "run.type" -value "synthesis" -objects $obj

# Create 'utilization_2' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "utilization_2" ] ] ""]} {
    create_dashboard_gadget -name {utilization_2} -type utilization
}
set obj [get_dashboard_gadgets [ list "utilization_2" ] ]
set_property -name "reports" -value "impl_1#impl_1_place_report_utilization_0" -objects $obj

move_dashboard_gadget -name {utilization_1} -row 0 -col 0
move_dashboard_gadget -name {power_1} -row 1 -col 0
move_dashboard_gadget -name {drc_1} -row 2 -col 0
move_dashboard_gadget -name {timing_1} -row 0 -col 1
move_dashboard_gadget -name {utilization_2} -row 1 -col 1
move_dashboard_gadget -name {methodology_1} -row 2 -col 1


# -----------------
# - Print Success -
# -----------------
puts "TCL: ----- NEW PROJECT HAS BEEN CREATED -----"


# Close project
close_project