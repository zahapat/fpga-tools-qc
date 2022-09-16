# Procedure: Get name of the dir where tb_top module is located


# Set variables for the simulation project
variable run_time "-all"

# Open project
set required_proj_file "$proj_root_dir/modelsim/project.mpf"
if {![file exist "$required_file"]} {
    puts "TCL: Opening existing project: ./modelsim/project.mpf"
    project open $proj_root_dir/modelsim/project.mpf
    project compileall
    exit
} else {
    puts "TCL: Simulation is running in a non-project mode."
}

# Find wave.do file in the top tb module dir
set tb_top_abspath [string range [lindex $all_modules [expr [llength $all_modules]-1]] 0 end]
set tb_top_dir_abspath [file dirname "[file normalize $tb_top_abspath]"]

# Run Testbench
if {$file_lang eq "sv"} {
    if { [string first "_tb." ${file_name}] != -1} {
        vsim -onfinish stop work.${file_name}_tb
    } else {
        vsim -onfinish stop work.${file_name}
    }
} elseif {$file_lang eq "v"} {
    if { [string first "_tb." ${file_name}] != -1} {
        vsim -onfinish stop work.${file_name}_tb
    } else {
        vsim -onfinish stop work.${file_name}
    }
} elseif {$file_lang eq "vhd"} {
    if { [string first "_tb." ${file_name}] != -1} {
        vsim -onfinish stop $lib_sim_vhdl.${file_name}_tb
    } else {
        vsim -onfinish stop $lib_sim_vhdl.${file_name}
    }
} else {
    puts "TCL: ERROR: File type $file_lang is not supported."
}


# List all instances in the tb file
set all_instances_tb [find instances sim:/${file_name}_tb/*]
puts "TCL: all_instances_tb = $all_instances_tb"

run $run_time

# Save output data of the simulation into a list and wave formats
    # write list $tb_top_dir_abspath/sim_output.lst
    # write format list $tb_top_dir_abspath/list.do
    # write format wave $tb_top_dir_abspath/wave.do
    # write report $tb_top_dir_abspath/sim_report.txt