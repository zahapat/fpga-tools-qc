# Check if harness module is used
set if_harness_present 0
set slurp_file [open "$proj_root_dir/simulator/modules.tcl" r]
while {-1 != [gets $slurp_file line]} {
    set filepath [string range $line 0 end]
    if { [string first "harness" $filepath] != -1} {
        set if_harness_present 1
    }
}
close $slurp_file

# Set variables for the simulation project
variable run_time "-all"


if {[ catch {
    source ${proj_root_dir}/simulator/do/compile_all.tcl
} errorstring]} {
    puts "TCL: The following error was generated while compiling sources: $errorstring - Stop."
    return 0
}
write format wave $tb_top_dir_abspath/wave.do


# Run Testbench
source ${proj_root_dir}/simulator/do/launch_vsim.tcl

do $tb_top_dir_abspath/wave.do

# Log, run
run $run_time

# Some commands do not work in batch mode, then consider using this:
write format wave $tb_top_dir_abspath/wave.do

# Save output data of the simulation into a list and wave formats
file mkdir "$tb_top_dir_abspath/sim_reports"

write report $tb_top_dir_abspath/sim_reports/sim_report.txt