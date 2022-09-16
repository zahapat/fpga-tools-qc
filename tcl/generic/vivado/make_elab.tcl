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
        puts "TCL: arg1 = $topFile"
    }
} else {
    puts "TCL: ERROR: There must be one Command-line argument passed to the TCL script. Total arguments found:  $::argc"
    return 1
}

# If the Top file name is a testbench file, remove '_tb.' or '_top_tb.' to use source file for synthesis, not the sim file
set topFile [string map {"_top_tb." "."} $topFile]
set topFile [string map {"_tb." "."} $topFile]

# Search for the given file in the project
puts "TCL: Search for the given file in the project"
set topFileFound [glob */*{$topFile}* */*/*{$topFile}*]

# Assess that the number of occurrences of this file is 1
# puts "TCL: Assess that the number of occurrences of this file is 1"
if { [llength $topFileFound] == 1 } {
    puts "TCL: File $topFile exists. "
} else {
    puts "TCL: ERROR: File specified by the Command-line argument does not exist or there are multiple files in the project. "
    return 2
}

#  Create folder for elab reports
set topFileFound "[file normalize $topFileFound]"
set topFileFound "[string trimright $topFileFound $topFile]"
set reports_absdir "[string trimright $topFileFound $topFile]elab_reports"
puts "TCL: path reports_absdir = $reports_absdir"
file mkdir ${reports_absdir}

# Open and reset the project
close_project -quiet
puts "TCL: Opening project $_xil_proj_name_"
open_project "${origin_dir}/vivado/${_xil_proj_name_}.xpr"


# Refresh hierarchy
update_compile_order


# --------------------
# - Report hierarchy -
# --------------------
# Update and report compile order for synthesis
report_compile_order -file "$reports_absdir/0_compile_order.rpt"


# ------------------------------------
# - Synthesis in mode Out-of-context -
# ------------------------------------
# Set Strategy for Synthesis
puts "TCL: Set Strategy for Synthesis "
set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
# set_property CURRENT_STEP "synth_design -mode out_of_context" [get_runs synth_1]

# Get verbose reports about IP status before synthesis
puts "TCL: Get verbose reports about IP status and config affecting timing analysis "
report_property [get_runs synth_1] -file "$reports_absdir/0_report_property.rpt"

# Execute Synthesis
puts "TCL: Running Synthesis "
source "${origin_dir}/tcl/project_specific/vivado/strategy_synth.tcl"
synth_design -rtl
opt_design


puts "TCL: Exporting reports "
# write_checkpoint        -force "${origin_dir}/vivado/checkpoint_post_synth.dcp"
report_timing_summary   -file "$reports_absdir/1_elab_timing.rpt"
report_utilization      -file "$reports_absdir/1_elab_util.rpt"
report_drc              -file "$reports_absdir/1_elab_drc.rpt"

# Get verbose reports about IP status and config affecting timing analysis
puts "TCL: Get verbose reports about what may affect timing analysis "
report_config_timing -all -file "$reports_absdir/1_elab_config_timing.rpt"

# synth_design -generic width=32 -generic depth=512 ... 

# -----------------
# - WRITE NETLIST -
# -----------------
write_edif -force "$reports_absdir/1_elab_netlist.edf"

set topFile [string map {".vhd" ""} $topFile]
set topFile [string map {".sv" ""} $topFile]
set topFile [string map {".v" ""} $topFile]
write_vhdl -force "$topFileFound/${topFile}_elab.vhd" -mode funcsim
write_verilog -force "$topFileFound/${topFile}_elab.sv" -mode funcsim


# ------------------------------------
# - Return to Default Synthesis mode -
# ------------------------------------
# set_property CURRENT_STEP "synth_design -mode default" [get_runs synth_1]


# ----------------------
# - Additional Reports -
# ----------------------

# Get verbose reports about IP status and config affecting timing analysis
# puts "TCL: Get verbose reports about IP status and config affecting timing analysis "
# report_property [get_runs synth_1] -file "${origin_dir}/vivado/report_property.rpt"
# report_config_timing -all -file "${origin_dir}/vivado/report_config_timing.rpt"

report_utilization -spreadsheet_file "$reports_absdir/1_elab_util_sprd.rpt"


# -----------------
# - Print Success -
# -----------------
puts "TCL: Running $script_file for project $_xil_proj_name_ completed successfully. "

# Close project
close_project