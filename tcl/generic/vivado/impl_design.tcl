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
# reset_project

# open_project C:/Users/Patrik/VHDL/COURSES/MAKEFILE_VIVADO/led_on/vivado/led_on.xpr

# Set the directory path for the current project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [current_project]

# Set the file graph
# puts "TCL: Update and report compile order "
# update_compile_order
# report_compile_order -file "${origin_dir}/vivado/0_report_compile_order.rpt"

# Set Strategy for Implementation
# set_property strategy Flow_PerfOptimized_high [get_runs synth_1]

# Get verbose reports about IP status and config affecting timing analysis
# report_property [get_runs synth_1] -file "${origin_dir}/vivado/1_report_property.rpt"


# Set Strategy for Implementation
# set_property STEPS.SYNTH_DESIGN.ARGS.BUFG 0 [get_runs synth_1] # Example
# set_property strategy Flow_PerfOptimized_high [get_runs synth_1]

# Get verbose reports about IP status
# report_property [get_runs synth_1]

# Execute Synthesis if the design is outdated
if {[get_property NEEDS_REFRESH [get_runs synth_1]]} {
    source "${origin_dir}/tcl/project_specific/vivado/strategy_synth.tcl"
    puts "TCL: Synthesis is out-of-date. Run Synthesis. "
    reset_project
    puts "TCL: Update and report compile order "
    update_compile_order
    report_compile_order -file "${origin_dir}/vivado/0_report_compile_order.rpt"
    set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
    report_property [get_runs synth_1] -file "${origin_dir}/vivado/1_report_property.rpt"
    reset_run synth_1
    launch_runs synth_1 -jobs 4
    wait_on_run synth_1
    open_run synth_1
    write_checkpoint        -force "${origin_dir}/vivado/1_checkpoint_post_synth.dcp"
    report_timing_summary   -file "${origin_dir}/vivado/1_results_post_synth_timing.rpt"
    report_utilization      -file "${origin_dir}/vivado/1_results_post_synth_util.rpt"
    report_drc              -file "${origin_dir}/vivado/1_results_post_synth_drc.rpt"

    # Write netlist
    write_edif -force "${origin_dir}/vivado/1_netlist_post_synth.edf"
} else {
    puts "TCL: Synthesis is up-to-date. Continue to run Implementation. "
}

# Execute Implementation
puts "TCL: Implementation is out-of-date. Run Implementation. "
source "${origin_dir}/tcl/project_specific/vivado/strategy_impl.tcl"
launch_runs impl_1 -to_step route_design -jobs 4
wait_on_run impl_1
open_run impl_1
write_checkpoint            -force "${origin_dir}/vivado/2_checkpoint_post_route.dcp"
write_debug_probes          -force "${origin_dir}/vivado/ila1.ltx"
report_route_status         -file "${origin_dir}/vivado/2_results_post_route_route_status.rpt"
report_timing_summary       -file "${origin_dir}/vivado/2_results_post_route_timing.rpt"
report_utilization          -file "${origin_dir}/vivado/2_results_post_route_util.rpt"
report_drc                  -file "${origin_dir}/vivado/2_results_post_route_drc.rpt"

# Get verbose reports about IP status and config affecting timing analysis
puts "TCL: Get verbose reports about what may affect timing analysis "
report_config_timing -all -file "${origin_dir}/vivado/1_report_config_timing.rpt"

# Close project
puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "
close_project