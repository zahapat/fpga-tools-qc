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
        puts "TCL: arg1 = $topFile"
    }
} else {
    puts "TCL: ERROR: There must be one Command-line argument passed to the TCL script. Total arguments found:  $::argc"
    return 1
}


# Open and reset the project
close_project -quiet
puts "TCL: OPENING PROJECT $_xil_proj_name_"
open_project "${origin_dir}/vivado/${_xil_proj_name_}.xpr"

# Remember what the top module was at the beginning, so that no changes are made to the hierarchy after OOC
set originalTop [get_property TOP [current_fileset]]
puts "TCL: The original top module before OOC Synthesis is: $originalTop"

# Make sure only path tail is extracted from the file path, extract then the file name
set top_file_full_name [file tail $topFile]
set top_file_noposix [lindex [split $top_file_full_name "."] 0]
puts "TCL: top_file_noposix = $top_file_noposix"

# Find the desired module in the current fileset
set all_srcs [get_files -of [get_filesets sources_1]]
set found_future_top_full_path ""
foreach abs_path_to_file $all_srcs {
    puts "DEBUG: abs_path_to_file $abs_path_to_file"
    set file_full_name [file tail $abs_path_to_file]
    set file_noposix [lindex [split $file_full_name "."] 0]
    if {[string equal $file_noposix $top_file_noposix]} {
        set found_future_top_full_name $file_full_name
        set found_future_top_full_path $abs_path_to_file
        puts "DEBUG: found_future_top_full_path = $abs_path_to_file"
        set found_future_top_noposix $file_noposix
    }
}

if {$found_future_top_full_path eq ""} {
    puts "TCL ERROR: The top file has not been found in added sources in Vivado. Quit."
    quit
}


# Set a new top module. It is a must to update compile order straight after.
# update_compile_order
set_property source_mgmt_mode DisplayOnly [current_project]
set_property TOP "${found_future_top_noposix}" [current_fileset]
set_property source_mgmt_mode All [current_project]
update_compile_order -fileset sources_1

# update_compile_order
# set newTop [get_property TOP [current_fileset]]
# puts "TCL: New TOP file reported after update_compile_order: $newTop"
# set_property source_mgmt_mode None [current_project]
# set_property TOP $found_future_top_full_path [current_fileset]
# set newTop [get_property TOP [current_fileset]]
# puts "TCL: New TOP file reported after update_compile_order: $newTop"

# Make sure the Top file name is not a testbench file, remove '_tb.' or '_top_tb.' to use source file for synthesis
set found_future_top_full_path [string map {"_top_tb." "."} $found_future_top_full_path]
set found_future_top_full_path [string map {"_tb." "."} $found_future_top_full_path]

#  Create folder for ooc reports
set topFileDir "[string trimright $found_future_top_full_path $top_file_full_name]"
set reports_absdir "${topFileDir}ooc"
puts "TCL: path reports_absdir = $reports_absdir"
file delete -force "${reports_absdir}"
file mkdir ${reports_absdir}


# --------------------
# - Report hierarchy -
# --------------------
# Update and report compile order for synthesis
report_compile_order -file "$reports_absdir/0_ooc_compile_order.rpt"


# ------------------------------------
# - Synthesis in mode Out-of-context -
# ------------------------------------
# Set Strategy for Synthesis
puts "TCL: Set Strategy for Synthesis "
source "${origin_dir}/tcl/project_specific/vivado/strategy_synth.tcl"
# set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
# set_property CURRENT_STEP "synth_design -mode out_of_context" [get_runs synth_1]

# Get verbose reports about IP status before synthesis
puts "TCL: Get verbose reports about IP status and config affecting timing analysis "
report_property [get_runs synth_1] -file "$reports_absdir/0_ooc_report_property.rpt"

# Start synthesis in OOC mode
puts "TCL: Running Synthesis "
reset_run synth_1
synth_design -mode out_of_context
opt_design


puts "TCL: Exporting reports "
# write_checkpoint        -force "${origin_dir}/vivado/checkpoint_post_synth.dcp"
report_timing_summary   -file "$reports_absdir/1_ooc_post_synth_timing.rpt"
report_utilization      -file "$reports_absdir/1_ooc_post_synth_util.rpt"
report_drc              -file "$reports_absdir/1_ooc_post_synth_drc.rpt"

# Get verbose reports about IP status and config affecting timing analysis
puts "TCL: Get verbose reports about what may affect timing analysis "
report_config_timing -all -file "$reports_absdir/1_ooc_post_synth_config_timing.rpt"

# synth_design -generic width=32 -generic depth=512 ... 

# -----------------
# - WRITE NETLIST -
# -----------------
write_edif -force "$reports_absdir/1_ooc_post_synth_netlist.edf"
# write_vhdl -force "$reports_absdir/${found_future_top_noposix}_func.vhd" -mode funcsim
# write_verilog -force "$reports_absdir/${found_future_top_noposix}_func.sv" -mode funcsim


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

report_utilization -spreadsheet_file "$reports_absdir/1_ooc_post_synth_util_sprd.rpt"


# ------------------------------------
# - Reset to the original TOP module -
# ------------------------------------
# set_property source_mgmt_mode DisplayOnly [current_project]
set_property TOP "${originalTop}" [current_fileset]
# set_property source_mgmt_mode All [current_project]
# update_compile_order -fileset sources_1

puts "TCL: Top module before OOC: $originalTop"
puts "TCL: Top module after OOC:  [get_property TOP [current_fileset]]"
puts "TCL: The two modules above should match."



# -----------------
# - Print Success -
# -----------------
puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "

# Close project
close_project