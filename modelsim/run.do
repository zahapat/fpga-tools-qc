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


# Before runing the test, save current wave.do config
write format wave $tb_top_dir_abspath/wave.do

# Stop any ongoing simulation
if {[runStatus] != "nodesign"} {
  quit -sim
}

# Set variables for the simulation project
variable run_time "-all"

# Recompile Out of Date
if {$lib_sim_vhdl eq "work"} {
    if {$lib_src_vhdl eq "work"} {
        project compileoutofdate
    }
}

# Recompile All
if {$lib_sim_vhdl ne "work"} {
    if {$lib_src_vhdl ne "work"} {
        # Compile all files in the modules.tcl file
        # Sort the files to repsective libraries based on the compile order in the file modules.tcl
        for {set i 0} {$i < [llength $all_modules]} {incr i} {

            # Reconstruct the correct normalized path to source files
            set filepath_modules [string range [lindex $all_modules $i] 0 end]
            set filepath_correction [concat ${proj_root_dir}${filepath_modules}]
            puts "TCL: filepath_correction = $filepath_correction"
            set filepath [string map {" ./" "/"} $filepath_correction]
            puts "TCL: filepath = $filepath "

            set file_fullname [file tail $filepath]
            puts "TCL: file_fullname = $file_fullname"
            set file_name [string range [lindex [split $file_fullname "."] 0] 0 end]
            puts "TCL: file_name = $file_name"
            set file_lang [string range [lindex [split $filepath "."] 1] 0 end]
            puts "TCL: file_lang = $file_lang"

            # Check for empty lines
            if {$filepath eq ""} {
                puts "TCL: Ignoring empty line."
            } else {

                # Sort files to sim and src libraries, except for verilog files
                if {$file_lang eq "vhd"} {
                    # VHDL
                    if { [string first "_tb." ${file_fullname}] != -1} {
                        if { [file exist "$proj_root_dir/modelsim/$lib_sim_vhdl"] } {
                            # Compile
                            puts "TCL: Compiling source '$file_fullname' to existing library '$lib_sim_vhdl'."
                            vcom -2008 -work $lib_sim_vhdl $filepath
                            # vcom -2008 -work work $filepath
                        } else {
                            # Create the library, remap
                            puts "TCL: * Create a new library '$lib_sim_vhdl' and compile source '$file_fullname' to this library."
                            vlib $proj_root_dir/modelsim/$lib_sim_vhdl
                            vmap $lib_sim_vhdl $proj_root_dir/modelsim/$lib_sim_vhdl

                            # Compile
                            vcom -2008 -work $lib_sim_vhdl $filepath
                            # vcom -2008 -work work $filepath
                        }
                    } else {
                        if { [file exist "$proj_root_dir/modelsim/$lib_src_vhdl"] } {
                            # Compile
                            puts "TCL: Compiling source '$file_fullname' to existing library '$lib_src_vhdl'."
                            vcom -work $lib_src_vhdl $filepath
                            # vcom -work work $filepath
                        } else {
                            # Create the library, remap
                            puts "TCL: * Create a new library '$lib_src_vhdl' and compile source '$file_fullname' to this library."
                            vlib $proj_root_dir/modelsim/$lib_src_vhdl
                            vmap $lib_src_vhdl $proj_root_dir/modelsim/$lib_src_vhdl

                            # Compile
                            vcom -work $lib_src_vhdl $filepath
                            # vcom -work work $filepath
                        }
                    }
                } elseif {$file_lang eq "sv"} {
                    #  SystemVerilog
                    if { [file exist "$proj_root_dir/modelsim/work"] } {
                        # Compile
                        vlog -sv -work work $filepath
                    } else {
                        # Create the library, remap
                        vlib $proj_root_dir/modelsim/work
                        vmap work $proj_root_dir/modelsim/work
                        # Compile
                        vlog -sv -work work $filepath
                    }
                } elseif {$file_lang eq "v"} {
                    # Verilog
                    if { [file exist "$proj_root_dir/modelsim/work"] } {
                        # Compile
                        vlog -work work $filepath
                    } else {
                        # Recreate the library, remap
                        vlib $proj_root_dir/modelsim/work
                        vmap work $proj_root_dir/modelsim/work

                        # Compile
                        vlog -work work $filepath
                    }
                    else {
                        puts "TCL: ERROR: Invalid file suffix."
                        exit
                    }
                }
            }
        }
    }
}




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

do $tb_top_dir_abspath/wave.do

# Log, run
# if {$if_harness_present == 0} {
#     puts "TCL: Harness module is not used."
#     log sim:/*
# } else {
#     puts "TCL: Harness module is used."
#     add wave sim:/signals_${dut_name}_pack_tb/*
#     # log sim:/signals_pack_tb/*
# }
run $run_time

# Some commands do not work in batch mode, then consider using this:
write format wave $tb_top_dir_abspath/wave.do

# Save output data of the simulation into a list and wave formats
file mkdir "$tb_top_dir_abspath/sim_reports"

# if {$if_harness_present == 0} {
#     # If harness module is not used
#     add list sim:/*
# } else {
#     # If harness module is used
#     add wave sim:/signals_${dut_name}_pack_tb/*
#     # add list sim:/signals_pack_tb/*
# }

write report $tb_top_dir_abspath/sim_reports/sim_report.txt
# write list $tb_top_dir_abspath/sim_reports/sim_list.lst