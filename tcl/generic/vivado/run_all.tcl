# Interesting_thread: https://forums.xilinx.com/t5/Vivado-TCL-Community/How-can-I-detect-if-synthesis-needs-to-be-run/td-p/848241

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

# Open the project
close_project -quiet
open_project "${origin_dir}/vivado/${_xil_proj_name_}.xpr"
reset_project

# Set the directory path for the current project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [current_project]

# Set the file graph
puts "TCL: Update and report compile order "
update_compile_order
report_compile_order -file "${origin_dir}/vivado/0_report_compile_order.rpt"

# Set Strategy for Implementation
set_property strategy Flow_PerfOptimized_high [get_runs synth_1]

# Get verbose reports about IP status
report_property [get_runs synth_1] -file "${origin_dir}/vivado/1_report_property.rpt"
# set_property STEPS.SYNTH_DESIGN.ARGS.BUFG 0 [get_runs synth_1] # Example

# Set Strategy for Implementation
set_property strategy Flow_PerfOptimized_high [get_runs synth_1]

# Execute Synthesis if out of date
puts "TCL: Run Synthesis. "
source "${origin_dir}/tcl/project_specific/vivado/strategy_synth.tcl"
reset_run synth_1
launch_runs synth_1 -jobs 1
wait_on_run synth_1
open_run synth_1
write_checkpoint        -force "${origin_dir}/vivado/1_checkpoint_post_synth.dcp"
report_timing_summary   -file "${origin_dir}/vivado/1_results_post_synth_timing.rpt"
report_utilization      -file "${origin_dir}/vivado/1_results_post_synth_util.rpt"
report_drc              -file "${origin_dir}/vivado/1_results_post_synth_drc.rpt"


# Get verbose reports about IP status and config affecting timing analysis
puts "TCL: Get verbose reports about what may affect timing analysis "
report_config_timing -all -file "${origin_dir}/vivado/1_report_config_timing.rpt"

# Write netlist
write_edif -force "${origin_dir}/vivado/1_netlist_post_synth.edf"

# Write Hardware Definition (hwdef or hdf file)
if {[catch {\
    write_hwdef -force ${origin_dir}/vivado/3_hwdef_${_xil_proj_name_}.hdf \
} error_msg]} {
    puts "TCL: This project does not contain any Board files. Skipping Hardware Definition generation. Message generated: $error_msg"
} else {
    puts "TCL: Generating Hardware Definition file."
}



# Run Implementation + Generate Bitstream if out-of-date
puts "TCL: Run Implementation and Generate Bitstream."
source "${origin_dir}/tcl/project_specific/vivado/strategy_impl.tcl"
launch_runs impl_1 -to_step route_design -jobs 1
wait_on_run impl_1
open_run impl_1
write_checkpoint            -force "${origin_dir}/vivado/2_checkpoint_post_route.dcp"
write_debug_probes          -force "${origin_dir}/vivado/ila1.ltx"
report_route_status         -file "${origin_dir}/vivado/2_results_post_route_route_status.rpt"
report_timing_summary       -file "${origin_dir}/vivado/2_results_post_route_timing.rpt"
report_utilization          -file "${origin_dir}/vivado/2_results_post_route_util.rpt"
report_drc                  -file "${origin_dir}/vivado/2_results_post_route_drc.rpt"

# Attempt to unplace cells that cause timing violation before bitstream generation
source "${origin_dir}/tcl/generic/vivado/get_cells_with_wns.tcl"
source "${origin_dir}/tcl/generic/vivado/run_incremental_impl.tcl"

# Run Generate Bitstream if timing constraints were met
source "${origin_dir}/tcl/generic/vivado/get_cells_with_wns.tcl"
if {[llength $cells_with_negative_slack] == 0} {
    set constrs [get_files -of_objects [get_filesets constrs_1]]
    puts "TCL: constrs = $constrs"
    if {$constrs eq ""} {
        puts "TCL: ERROR: Unable to run bitstream. There are no constraint files present in the project."
        quit
    } else {
        # Run Generate Bitstream
        open_run impl_1
        set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
        write_bitstream -verbose -force ${origin_dir}/vivado/3_bitstream_${_xil_proj_name_}.bit
        write_cfgmem -force -format bin -interface smapx32 -disablebitswap -loadbit "up 0 ${origin_dir}/vivado/3_bitstream_${_xil_proj_name_}.bit" ${origin_dir}/vivado/3_binary_${_xil_proj_name_}.bin

        # To generate hardware platform for an SoC project (if applicable), you must re-run 
        # bitstream generation since non-project mode "write_bitstream" command is incompatible 
        # with it.
        # Thus, the project-based command "launch_runs -to step write_bitstream" needs to be 
        # executed before "write_hw_platform". 
        # Note: "write_hw_platform" must be executed in a new shell. Thus, run "make xsa" after running this script.
        if {[catch {\
            write_hw_platform -fixed -include_bit -force -file "${origin_dir}/vivado/3_hw_platform_${_xil_proj_name_}.xsa"\
        } error_msg]} {
            puts "TCL: This project does not contain any Vitis modules. Skipping Hardware Platform generation for Vitis. Message generated: $error_msg"
        } else {
            puts "**************************************************"
            puts "TCL: To generate the .xsa hardware platform, "
            puts "     run \"make xsa\" command after running"
            puts "     this script with successful bitstream"
            puts "     generation."
            puts "**************************************************"
            puts "TCL: Generate bitstream once again to successfully generate the .xsa file later."
            launch_runs impl_1 -to_step write_bitstream
        }
    }
} else {
    puts "TCL: CRITICAL WARNING: Bitgen skipped due to timing violations even after one attempt to unplace the problem cells."
    puts "TCL: Try to redesign the problem part of your design, alter the timing constraints, or increase the number of unplace_cell attempts."
}

# Get verbose reports about config affecting timing analysis
# report_config_timing -all -file "${origin_dir}/vivado/report_config_timing.rpt"

# Close project and print success
puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "
close_project