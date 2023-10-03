# Procedure: Get name of the dir where tb_top module is located


# Set variables for the simulation project
variable run_time "-all"

# Open project
set required_proj_file "$proj_root_dir/simulator/project.mpf"
if {![file exist "$required_file"]} {
    puts "TCL: Opening existing project: ./simulator/project.mpf"
    project open $proj_root_dir/simulator/project.mpf
    project compileall
    exit
} else {
    puts "TCL: Simulation is running in non-project mode."
}

# Find wave.do file in the top tb module dir
# set tb_top_abspath [string range [lindex $all_modules [expr [llength $all_modules]-1]] 0 end]
set tb_top_abspath [string range [lindex $all_modules 0] 0 end]
set tb_top_dir_abspath [file dirname "[file normalize $tb_top_abspath]"]

# Run Testbench
if {($file_lang eq "sv") || ($file_lang eq "svh")} {
    if { [string first "_tb." ${file_name}] != -1} {
        vsim -lib work -onfinish stop -L unisim_verilog work.glbl work.${file_name}_tb
    } else {
        vsim -lib work -onfinish stop -L unisim_verilog work.glbl work.${file_name}
    }
} elseif {($file_lang eq "v") || ($file_lang eq "vh")} {
    if { [string first "_tb." ${file_name}] != -1} {
        vsim -lib work -onfinish stop -L unisim_verilog work.glbl work.${file_name}_tb
    } else {
        vsim -lib work -onfinish stop -L unisim_verilog work.glbl work.${file_name}
    }
} elseif {$file_lang eq "vhd"} {
    if { [string first "_tb." ${file_name}] != -1} {
        vsim -lib $lib_sim_vhdl -onfinish stop $lib_sim_vhdl.${file_name}_tb
    } else {
        vsim -lib $lib_src_vhdl -onfinish stop $lib_src_vhdl.${file_name}
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