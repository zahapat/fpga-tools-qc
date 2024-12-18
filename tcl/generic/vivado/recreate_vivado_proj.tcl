# Use origin directory path location variable, if specified in the tcl shell
set origin_dir "."
if { [info exists ::origin_dir_loc] } {
    set origin_dir $::origin_dir_loc
    puts "TCL: ::origin_dir_loc = $origin_dir"
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


# -------------------------
# - Create Vivado project -
# -------------------------
# Remove all redundant files before creating a new project
source "${orig_proj_dir}/tcl/generic/vivado/clean_before_reset.tcl"

create_project -quiet -force ${_xil_proj_name_} -dir "$orig_proj_dir/vivado/"

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
report_property -quiet -file "$origin_dir/vivado/0_newproj_report_property.rpt" [current_project]
set_property -quiet source_mgmt_mode All [current_project]

# List All Boards
set all_board_parts [get_board_parts]

# Parse Boards and find the correct vlnv for the desired board
set idx 0
set act_board_part_vlnv " "
while {$act_board_part_vlnv ne ""} {
    set act_board_part_vlnv [lindex [split $all_board_parts " "] $idx]
    set act_board_part_name [lindex [split $act_board_part_vlnv ":"] 1]
    incr idx
    # puts "TCL DEBUG: act_board_part_vlnv = $act_board_part_vlnv"
    # puts "TCL DEBUG: act_board_part_name = $act_board_part_name"
    if {$act_board_part_name eq $target_FPGA_part} {
        set_property -quiet -name "board_part" -value $act_board_part_vlnv -objects $obj
        set_property -quiet -name "platform.board_id" -value $act_board_part_name -objects $obj
        break
    }
    if {$act_board_part_vlnv eq ""} {
        puts "TCL: Inputted FPGA part number $target_FPGA_part is not an evaluation board."
        set_property -quiet -name part -value $target_FPGA_part -objects $obj
    }
}


# Set additional project properties
set_property IP_REPO_PATHS {./ip} [current_project]
set_property -name IP_OUTPUT_REPO -value "$orig_proj_dir/vivado/" -objects $obj
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
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
remove_files -quiet [get_files -filter {IS_AVAILABLE == 0}]

# Create filesets (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -quiet -srcset sources_1
}
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -quiet -simset sim_1
}
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -quiet -constrset constrs_1
}

# Set filesets objects
set objSrc [get_filesets -quiet sources_1]
set objSim [get_filesets -quiet sim_1]
set objConst [get_filesets -quiet constrs_1]

# Remove all previous source files
puts "TCL: Remove all source files in object all filesets"
remove_files -quiet [get_files -of_objects $objSrc]
remove_files -quiet [get_files -of_objects $objSim]
remove_files -quiet [get_files -of_objects $objConst]

# Set 'utils_1' fileset object
# Empty (no sources present)
set obj [get_filesets -quiet utils_1]

# Set 'utils_1' fileset properties
set obj [get_filesets -quiet utils_1]


# -----------------------------
# - Properties for Synthesis --
# -----------------------------

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
    create_run -quiet -name synth_1 -part $target_FPGA_part -flow {Vivado Synthesis 2020} -strategy "Vivado Synthesis Defaults" -report_strategy {No Reports} -constrset constrs_1
} else {
    set_property -quiet strategy "Vivado Synthesis Defaults" [get_runs synth_1]
    set_property -quiet flow "Vivado Synthesis 2020" [get_runs synth_1]
}
set obj [get_runs synth_1]
set_property -quiet set_report_strategy_name 1 $obj
set_property -quiet report_strategy {Vivado Synthesis Default Reports} $obj
set_property -quiet set_report_strategy_name 0 $obj
# Create 'synth_1_synth_report_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs synth_1] synth_1_synth_report_utilization_0] "" ] } {
    create_report_config -quiet -report_name synth_1_synth_report_utilization_0 -report_type report_utilization:1.0 -steps synth_design -runs synth_1
}
set obj [get_report_configs -quiet -of_objects [get_runs synth_1] synth_1_synth_report_utilization_0]
if { $obj != "" } {

}
set obj [get_runs synth_1]
set_property -quiet -name "needs_refresh" -value "1" -objects $obj
set_property -quiet -name "strategy" -value "Vivado Synthesis Defaults" -objects $obj

# set the current synth run
current_run -quiet -synthesis [get_runs synth_1]


# ----------------------------------
# - Properties for Implementation --
# ----------------------------------

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
    create_run -quiet -name impl_1 -part $target_FPGA_part -flow {Vivado Implementation 2020} -strategy "Vivado Implementation Defaults" -report_strategy {No Reports} -constrset constrs_1 -parent_run synth_1
} else {
    set_property -quiet strategy "Vivado Implementation Defaults" [get_runs impl_1]
    set_property -quiet flow "Vivado Implementation 2020" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property -quiet set_report_strategy_name 1 $obj
set_property -quiet report_strategy {Vivado Implementation Default Reports} $obj
set_property -quiet set_report_strategy_name 0 $obj

# Create 'impl_1_init_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_init_report_timing_summary_0] "" ] } {
    create_report_config -quiet -report_name impl_1_init_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps init_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_init_report_timing_summary_0]
if { $obj != "" } {
set_property -quiet -name "is_enabled" -value "0" -objects $obj
set_property -quiet -name "options.max_paths" -value "10" -objects $obj

}

# Create 'impl_1_opt_report_drc_0' report (if not found)
if { [ string equal [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_opt_report_drc_0] "" ] } {
    create_report_config -quiet -report_name impl_1_opt_report_drc_0 -report_type report_drc:1.0 -steps opt_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_opt_report_drc_0]
if { $obj != "" } {

}

# Create 'impl_1_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_opt_report_timing_summary_0] "" ] } {
    create_report_config -quiet -report_name impl_1_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps opt_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -quiet -name "is_enabled" -value "0" -objects $obj
set_property -quiet -name "options.max_paths" -value "10" -objects $obj

}

# Create 'impl_1_power_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_power_opt_report_timing_summary_0] "" ] } {
    create_report_config -quiet -report_name impl_1_power_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps power_opt_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_power_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -quiet -name "is_enabled" -value "0" -objects $obj
set_property -quiet -name "options.max_paths" -value "10" -objects $obj

}

# Create 'impl_1_place_report_io_0' report (if not found)
if { [ string equal [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_place_report_io_0] "" ] } {
    create_report_config -quiet -report_name impl_1_place_report_io_0 -report_type report_io:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_place_report_io_0]
if { $obj != "" } {

}

# Create 'impl_1_place_report_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_utilization_0] "" ] } {
    create_report_config -quiet -report_name impl_1_place_report_utilization_0 -report_type report_utilization:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_place_report_utilization_0]
if { $obj != "" } {

}

# Create 'impl_1_place_report_control_sets_0' report (if not found)
if { [ string equal [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_place_report_control_sets_0] "" ] } {
    create_report_config -quiet -report_name impl_1_place_report_control_sets_0 -report_type report_control_sets:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_place_report_control_sets_0]
if { $obj != "" } {
set_property -quiet -name "options.verbose" -value "1" -objects $obj

}

# Create 'impl_1_place_report_incremental_reuse_0' report (if not found)
if { [ string equal [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_0] "" ] } {
    create_report_config -quiet -report_name impl_1_place_report_incremental_reuse_0 -report_type report_incremental_reuse:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_0]
if { $obj != "" } {
set_property -quiet -name "is_enabled" -value "0" -objects $obj

}

# Create 'impl_1_place_report_incremental_reuse_1' report (if not found)
if { [ string equal [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_1] "" ] } {
    create_report_config -quiet -report_name impl_1_place_report_incremental_reuse_1 -report_type report_incremental_reuse:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_1]
if { $obj != "" } {
set_property -quiet -name "is_enabled" -value "0" -objects $obj

}

# Create 'impl_1_place_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_place_report_timing_summary_0] "" ] } {
    create_report_config -quiet -report_name impl_1_place_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_place_report_timing_summary_0]
if { $obj != "" } {
set_property -quiet -name "is_enabled" -value "0" -objects $obj
set_property -quiet -name "options.max_paths" -value "10" -objects $obj

}

# Create 'impl_1_post_place_power_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_post_place_power_opt_report_timing_summary_0] "" ] } {
    create_report_config -quiet -report_name impl_1_post_place_power_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps post_place_power_opt_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_post_place_power_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -quiet -name "is_enabled" -value "0" -objects $obj
set_property -quiet -name "options.max_paths" -value "10" -objects $obj

}

# Create 'impl_1_phys_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_phys_opt_report_timing_summary_0] "" ] } {
    create_report_config -quiet -report_name impl_1_phys_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps phys_opt_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_phys_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -quiet -name "is_enabled" -value "0" -objects $obj
set_property -quiet -name "options.max_paths" -value "10" -objects $obj

}

# Create 'impl_1_route_report_drc_0' report (if not found)
if { [ string equal [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_route_report_drc_0] "" ] } {
    create_report_config -quiet -report_name impl_1_route_report_drc_0 -report_type report_drc:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_route_report_drc_0]
if { $obj != "" } {

}

# Create 'impl_1_route_report_methodology_0' report (if not found)
if { [ string equal [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_route_report_methodology_0] "" ] } {
    create_report_config -quiet -report_name impl_1_route_report_methodology_0 -report_type report_methodology:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_route_report_methodology_0]
if { $obj != "" } {

}

# Create 'impl_1_route_report_power_0' report (if not found)
if { [ string equal [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_route_report_power_0] "" ] } {
    create_report_config -quiet -report_name impl_1_route_report_power_0 -report_type report_power:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_route_report_power_0]
if { $obj != "" } {

}

# Create 'impl_1_route_report_route_status_0' report (if not found)
if { [ string equal [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_route_report_route_status_0] "" ] } {
    create_report_config -quiet -report_name impl_1_route_report_route_status_0 -report_type report_route_status:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_route_report_route_status_0]
if { $obj != "" } {

}

# Create 'impl_1_route_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_route_report_timing_summary_0] "" ] } {
    create_report_config -quiet -report_name impl_1_route_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_route_report_timing_summary_0]
if { $obj != "" } {
set_property -quiet -name "options.max_paths" -value "10" -objects $obj

}

# Create 'impl_1_route_report_incremental_reuse_0' report (if not found)
if { [ string equal [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_route_report_incremental_reuse_0] "" ] } {
    create_report_config -quiet -report_name impl_1_route_report_incremental_reuse_0 -report_type report_incremental_reuse:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_route_report_incremental_reuse_0]
if { $obj != "" } {

}

# Create 'impl_1_route_report_clock_utilization_0' report (if not found)
if { [ string equal [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_route_report_clock_utilization_0] "" ] } {
    create_report_config -quiet -report_name impl_1_route_report_clock_utilization_0 -report_type report_clock_utilization:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_route_report_clock_utilization_0]
if { $obj != "" } {

}

# Create 'impl_1_route_report_bus_skew_0' report (if not found)
if { [ string equal [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_route_report_bus_skew_0] "" ] } {
  create_report_config -quiet -report_name impl_1_route_report_bus_skew_0 -report_type report_bus_skew:1.1 -steps route_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_route_report_bus_skew_0]
if { $obj != "" } {
    set_property -quiet -name "options.warn_on_violation" -value "1" -objects $obj
}

# Create 'impl_1_post_route_phys_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_post_route_phys_opt_report_timing_summary_0] "" ] } {
    create_report_config -quiet -report_name impl_1_post_route_phys_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps post_route_phys_opt_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_post_route_phys_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -quiet -name "options.max_paths" -value "10" -objects $obj
set_property -quiet -name "options.warn_on_violation" -value "1" -objects $obj

}

# Create 'impl_1_post_route_phys_opt_report_bus_skew_0' report (if not found)
if { [ string equal [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_post_route_phys_opt_report_bus_skew_0] "" ] } {
  create_report_config -quiet -report_name impl_1_post_route_phys_opt_report_bus_skew_0 -report_type report_bus_skew:1.1 -steps post_route_phys_opt_design -runs impl_1
}
set obj [get_report_configs -quiet -of_objects [get_runs impl_1] impl_1_post_route_phys_opt_report_bus_skew_0]
if { $obj != "" } {
set_property -quiet -name "options.warn_on_violation" -value "1" -objects $obj

}
set obj [get_runs impl_1]
set_property -quiet -name "needs_refresh" -value "1" -objects $obj
set_property -quiet -name "strategy" -value "Vivado Implementation Defaults" -objects $obj
set_property -quiet -name "steps.write_bitstream.args.readback_file" -value "0" -objects $obj
set_property -quiet -name "steps.write_bitstream.args.verbose" -value "0" -objects $obj

# set the current impl run
current_run -quiet -implementation [get_runs impl_1]

puts "TCL: Project created: ${_xil_proj_name_}"



# ---------------------------
# - Properties for Reports --
# ---------------------------
# Create 'drc_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets -quiet  [ list "drc_1" ] ] ""]} {
    create_dashboard_gadget -quiet -name {drc_1} -type drc
}
set obj [get_dashboard_gadgets [ list "drc_1" ] ]
set_property -quiet -name "reports" -value "impl_1#impl_1_route_report_drc_0" -objects $obj

# Create 'methodology_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets -quiet  [ list "methodology_1" ] ] ""]} {
    create_dashboard_gadget -quiet -name {methodology_1} -type methodology
}
set obj [get_dashboard_gadgets -quiet [ list "methodology_1" ] ]
set_property -quiet -name "reports" -value "impl_1#impl_1_route_report_methodology_0" -objects $obj

# Create 'power_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets -quiet  [ list "power_1" ] ] ""]} {
    create_dashboard_gadget -quiet -name {power_1} -type power
}
set obj [get_dashboard_gadgets -quiet [ list "power_1" ] ]
set_property -quiet -name "reports" -value "impl_1#impl_1_route_report_power_0" -objects $obj

# Create 'timing_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets -quiet  [ list "timing_1" ] ] ""]} {
    create_dashboard_gadget -quiet -name {timing_1} -type timing
}
set obj [get_dashboard_gadgets -quiet [ list "timing_1" ] ]
set_property -quiet -name "reports" -value "impl_1#impl_1_route_report_timing_summary_0" -objects $obj

# Create 'utilization_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets -quiet  [ list "utilization_1" ] ] ""]} {
    create_dashboard_gadget -quiet -name {utilization_1} -type utilization
}
set obj [get_dashboard_gadgets -quiet [ list "utilization_1" ] ]
set_property -quiet -name "reports" -value "synth_1#synth_1_synth_report_utilization_0" -objects $obj
set_property -quiet -name "run.step" -value "synth_design" -objects $obj
set_property -quiet -name "run.type" -value "synthesis" -objects $obj

# Create 'utilization_2' gadget (if not found)
if {[string equal [get_dashboard_gadgets -quiet [ list "utilization_2" ] ] ""]} {
    create_dashboard_gadget -quiet -name {utilization_2} -type utilization
}
set obj [get_dashboard_gadgets -quiet [ list "utilization_2" ] ]
set_property -quiet -name "reports" -value "impl_1#impl_1_place_report_utilization_0" -objects $obj

move_dashboard_gadget -quiet -name {utilization_1} -row 0 -col 0
move_dashboard_gadget -quiet -name {power_1} -row 1 -col 0
move_dashboard_gadget -quiet -name {drc_1} -row 2 -col 0
move_dashboard_gadget -quiet -name {timing_1} -row 0 -col 1
move_dashboard_gadget -quiet -name {utilization_2} -row 1 -col 1
move_dashboard_gadget -quiet -name {methodology_1} -row 2 -col 1


# Generate & Compile Xilinx Simulation Libraries (Verilog) for ModelSim
set device_family [get_property FAMILY [get_property PART [current_project]]]
set vivado_version "[version -short]"
set vivado_version_alias "[string map {"." "_"} $vivado_version]"
set precompile_lib_outdir "${orig_proj_dir}/simulator/vivado_precompiled_ver/${vivado_version_alias}"

# Create directories
if {![file exists $precompile_lib_outdir]} {
    exec mkdir -p $precompile_lib_outdir
    puts "TCL: Generate & Compile Xilinx Simulation Libraries \(Verilog\) for ModelSim"
    if {[ catch {
        compile_simlib \
            -simulator modelsim \
            -family all \
            -language verilog \
            -library all \
            -dir [file join $precompile_lib_outdir ""]
    } errorstring]} {
        puts "TCL: IP Precompiled Libraries 'vivado_precompiled_ver' generation ended with some errors: $errorstring . Pass."
    }
}

# Close project
close_project



# ---------------------------------------------
# Parse .xci file to modify IPDefaultOutputPath
# ---------------------------------------------
# You can't change the IPDefaultOutputPath - it must be $PGENDIR/sources_1
set detect_pattern "IPDefaultOutputPath"
set replace_by_line "    <Option Name=\"IPDefaultOutputPath\" Val=\"\$PGENDIR/sources_1\"/>"
set detected_line 0
set cnt 0
set proj_xpr_file [open "${origin_dir}/vivado/${_xil_proj_name_}.xpr" r]
set concat_all_lines ""
while {-1 != [gets $proj_xpr_file line]} {
    incr cnt 
    # Detect where the keyword file is present in the .xpr file, then modiify it
    if {$detected_line == 0} {
        # Detect where to modify the file
        if { [string first $detect_pattern $line] != -1} {
            set detected_line $cnt
            set detected_line 0
            set explicit_line "*$replace_by_line"
            set concat_all_lines [concat $concat_all_lines $explicit_line]
        } else {
            # Pass valid lines
            set new_line [string range $line 0 end]
            set explicit_line "*$new_line"
            set concat_all_lines [concat $concat_all_lines $explicit_line]
        }
    }
}
close $proj_xpr_file

# Replace the old .xpr with the new lines
set out_file_path "${origin_dir}/vivado/${_xil_proj_name_}.xpr"
set xpr_file [open $out_file_path "w"]
set line_part [lindex [split $concat_all_lines "*"] ]
foreach l $line_part {
    set ln [string range $l 0 end]
    if {$ln != ""} {
        puts -nonewline $xpr_file "$ln\n"
    }
}
close $xpr_file


# Remove all redundant files after creating this project
source "${orig_proj_dir}/tcl/generic/vivado/clean_after_reset.tcl"


# -----------------
# - Print Success -
# -----------------
puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "