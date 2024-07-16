# Use this script snippet after running get_cells_to_unplace.tcl located in ./tcl/generic/vivado folder.

# If some cells cause timing violations, run incremental placement
if {[llength $cells_with_negative_slack] > 0} {
    puts "TCL: There are [llength $cells_with_negative_slack] cells causing timing violation. Unplace these cells and place & route them again."
    unplace_cell $cells_with_negative_slack

    # Incremental Implementation
    set_property AUTO_INCREMENTAL_CHECKPOINT 0 [get_runs impl_1]
    # Allow One
    set_property incremental_checkpoint.directive TimingClosure [get_runs impl_1]
    # set_property incremental_checkpoint.directive RuntimeOptimized [get_runs impl_1]
    # set_property incremental_checkpoint.directive Quick [get_runs impl_1]

    # add_files -fileset sources_1 -norecurse "${origin_dir}/vivado/2_checkpoint_post_route.dcp"
    # add_files -fileset utils_1 -norecurse "${origin_dir}/vivado/2_checkpoint_post_route.dcp"
    # add_files -fileset constrs_1 -norecurse "${origin_dir}/vivado/2_checkpoint_post_route.dcp"
    # add_files -fileset sim_1 -norecurse "${origin_dir}/vivado/2_checkpoint_post_route.dcp"

    set_property incremental_checkpoint "${origin_dir}/vivado/2_checkpoint_post_route.dcp" [get_runs impl_1]

    reset_run impl_1
    launch_runs impl_1 -to_step route_design -jobs 1
    wait_on_run impl_1
    open_run impl_1
    write_checkpoint            -force "${origin_dir}/vivado/2_checkpoint_post_route.dcp"
    write_debug_probes          -force "${origin_dir}/vivado/ila1.ltx"
    report_route_status         -file "${origin_dir}/vivado/2_results_post_route_route_status.rpt"
    report_timing_summary       -file "${origin_dir}/vivado/2_results_post_route_timing.rpt"
    report_utilization          -file "${origin_dir}/vivado/2_results_post_route_util.rpt"
    report_drc                  -file "${origin_dir}/vivado/2_results_post_route_drc.rpt"
} else {
    puts "TCL: Timing constraints were met."
}