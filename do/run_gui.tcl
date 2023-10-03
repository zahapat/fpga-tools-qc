# Set variables for the simulation project
variable run_time "-all"

# Open project
if {$lib_sim_vhdl eq "work"} {
    if {$lib_src_vhdl eq "work"} {
        project open $proj_root_dir/simulator/project.mpf
        project compileall
    }
}

# vlib work
# vmap work work
# puts "TCL: vmap $lib_src_vhdl."
# vmap work $lib_src_vhdl
# vmap work $lib_sim_vhdl

# NEW
# set tb_top_abspath [string range [lindex $all_modules [expr [llength $all_modules]-1]] 0 end]
set tb_top_abspath [string range [lindex $all_modules 0] 0 end]
set filepath_correction [concat ${proj_root_dir} ${tb_top_abspath}]
set filepath_correction [string map {" " ""} $filepath_correction]
set tb_top_dir_abspath [string map {"./" "/"} $filepath_correction]
set tb_top_dir_abspath [file dirname "[file normalize $tb_top_dir_abspath]"]
puts "TCL: tb_top_dir_abspath: $tb_top_dir_abspath"


# Check if harness module is used
set if_harness_present 0
set slurp_file [open "$proj_root_dir/do/modules.tcl" r]
while {-1 != [gets $slurp_file line]} {
    set filepath [string range $line 0 end]
    if { [string first "harness" $filepath] != -1} {
        set if_harness_present 1
    }
}
close $slurp_file


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

# Find wave.do file in the top tb module dir
if {[file exists "$tb_top_dir_abspath/wave.do"]} {
    do $tb_top_dir_abspath/wave.do
} else {
    # List all instances in the tb file
    if {$if_harness_present == 0} {
        set all_instances_tb [find instances sim:/${file_name}/*]
        puts "TCL: all_instances_tb = $all_instances_tb"
    } else {
        set all_instances_tb [find instances sim:/${file_name}/inst_harness_tb/*]
        puts "TCL: find instances sim:/${file_name}/inst_harness_tb/*"
        puts "TCL: all_instances_tb = $all_instances_tb"
    }

    # Load default view for waveforms
    source "$proj_root_dir/do/default_wave.tcl"
}


# if {$if_harness_present == 0} {
#     puts "TCL: Harness module is not used."
#     log sim:/*
# } else {
#     puts "TCL: Harness module is used."
#     log sim:/signals_pack_tb/*
# }

run $run_time

# Zoom Fit the waveform
wave zoom full

# Some commands do not work in batch mode, then consider using this:
write format wave $tb_top_dir_abspath/wave.do

# Save output data of the simulation into a list and wave formats
file mkdir "$tb_top_dir_abspath/sim_reports"
# if {$if_harness_present == 0} {
#     # If harness module is not used
#     add list sim:/*
# } else {
#     # If harness module is used
#     add list sim:/signals_pack_tb/*
#     # add list sim:/signals_pack_tb/*
# }

write report $tb_top_dir_abspath/sim_reports/sim_report.txt
# write list $tb_top_dir_abspath/sim_reports/sim_list.lst