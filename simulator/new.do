
# Set variables for the simulation project
variable run_time "-all"


set file_fullname [file tail $filepath]
puts "TCL: file_fullname = $file_fullname"
set file_name [string range [lindex [split $file_fullname "."] 0] 0 end]
puts "TCL: file_name = $file_name"
set file_lang [string range [lindex [split $file_fullname "."] 1] 0 end]
puts "TCL: file_lang = $file_lang"


# NEW
set tb_top_abspath [string range [lindex $all_modules 0] 0 end]
set filepath_correction [concat ${proj_root_dir} ${tb_top_abspath}]
set filepath_correction [string map {" " ""} $filepath_correction]
set tb_top_dir_abspath [string map {"./" "/"} $filepath_correction]
set tb_top_dir_abspath [file dirname "[file normalize $tb_top_dir_abspath]"]
puts "TCL: tb_top_dir_abspath: $tb_top_dir_abspath"

# Delete wave.do
file delete "$tb_top_dir_abspath/wave.do"

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

# Recompile
if {[ catch {
    source ${proj_root_dir}/simulator/do/compile_all.tcl
} errorstring]} {
    puts "TCL: The following error was generated while compiling sources: $errorstring - Stop."
    return 0
}

# Run Testbench
puts "TCL: RUN TESTBENCH: Top = ${file_name}.${file_lang}"
set verilog_libname "xil_iplib_verilog"
if {($file_lang eq "sv") || ($file_lang eq "svh")} {
    if { [string first "_tb." ${file_name}] != -1} {

        if {[ catch {
            vsim -lib $proj_root_dir/simulator/${verilog_libname} -onfinish stop -L unisim_verilog ${verilog_libname}.glbl ${verilog_libname}.${file_name}_tb
        } errorstring]} {
            puts "TCL: The following error was generated: $errorstring - Attempting to refresh the library image."
            # Refresh the library image & launch sim
            vlog -work $proj_root_dir/simulator/${verilog_libname} -refresh
            vcom -work $proj_root_dir/simulator/$lib_src_vhdl -refresh
            vcom -work $proj_root_dir/simulator/$lib_sim_vhdl -refresh
            vsim -lib $proj_root_dir/simulator/${verilog_libname} -onfinish stop -L unisim_verilog ${verilog_libname}.glbl ${verilog_libname}.${file_name}_tb
        }

    } else {

        if {[ catch {
            vsim -lib $proj_root_dir/simulator/${verilog_libname} -onfinish stop -L unisim_verilog ${verilog_libname}.glbl ${verilog_libname}.${file_name}
        } errorstring]} {
            puts "TCL: The following error was generated: $errorstring - Attempting to refresh the library image."
            # Refresh the library image & launch sim
            vlog -work $proj_root_dir/simulator/${verilog_libname} -refresh
            vcom -work $proj_root_dir/simulator/$lib_src_vhdl -refresh
            vcom -work $proj_root_dir/simulator/$lib_sim_vhdl -refresh
            vsim -lib $proj_root_dir/simulator/${verilog_libname} -onfinish stop -L unisim_verilog ${verilog_libname}.glbl ${verilog_libname}.${file_name}
        }
    }
} elseif {($file_lang eq "v") || ($file_lang eq "vh")} {
    if { [string first "_tb." ${file_name}] != -1} {
        if {[ catch {
            vsim -lib $proj_root_dir/simulator/${verilog_libname} -onfinish stop -L unisim_verilog ${verilog_libname}.glbl ${verilog_libname}.${file_name}_tb
        } errorstring]} {
            puts "TCL: The following error was generated: $errorstring - Attempting to refresh the library image."
            # Refresh the library image & launch sim
            vlog -work $proj_root_dir/simulator/${verilog_libname} -refresh
            vcom -work $proj_root_dir/simulator/$lib_src_vhdl -refresh
            vcom -work $proj_root_dir/simulator/$lib_sim_vhdl -refresh
            vsim -lib $proj_root_dir/simulator/${verilog_libname} -onfinish stop -L unisim_verilog ${verilog_libname}.glbl ${verilog_libname}.${file_name}_tb
        }
    } else {
        if {[ catch {
            vsim -lib $proj_root_dir/simulator/work -onfinish stop -L unisim_verilog ${verilog_libname}.glbl ${verilog_libname}.${file_name}
        } errorstring]} {
            puts "TCL: The following error was generated: $errorstring - Attempting to refresh the library image."
            # Refresh the library image & launch sim
            vlog -work $proj_root_dir/simulator/${verilog_libname} -refresh
            vcom -work $proj_root_dir/simulator/$lib_src_vhdl -refresh
            vcom -work $proj_root_dir/simulator/$lib_sim_vhdl -refresh
            vsim -lib $proj_root_dir/simulator/${verilog_libname} -onfinish stop -L unisim_verilog ${verilog_libname}.glbl ${verilog_libname}.${file_name}
        }
    }
} elseif {$file_lang eq "vhd"} {
    if { [string first "_tb." ${file_name}] != -1} {
        if {[ catch {
            vsim -lib $lib_sim_vhdl -onfinish stop $lib_sim_vhdl.${file_name}_tb
        } errorstring]} {
            puts "TCL: The following error was generated: $errorstring - Attempting to refresh the library image."
            # Refresh the library image & launch sim
            vlog -work $proj_root_dir/simulator/${verilog_libname} -refresh
            vcom -work $proj_root_dir/simulator/$lib_src_vhdl -refresh
            vcom -work $proj_root_dir/simulator/$lib_sim_vhdl -refresh
            vsim -lib $proj_root_dir/simulator/$lib_sim_vhdl -onfinish stop $lib_sim_vhdl.${file_name}_tb
        }
    } else {
        if {[ catch {
            vsim -lib $proj_root_dir/simulator/$lib_src_vhdl -onfinish stop $lib_src_vhdl.${file_name}
        } errorstring]} {
            puts "TCL: The following error was generated: $errorstring - Attempting to refresh the library image."
            # Refresh the library image & launch sim
            vlog -work $proj_root_dir/simulator/${verilog_libname} -refresh
            vcom -work $proj_root_dir/simulator/$lib_src_vhdl -refresh
            vcom -work $proj_root_dir/simulator/$lib_sim_vhdl -refresh
            vsim -lib $proj_root_dir/simulator/$lib_src_vhdl -onfinish stop $lib_src_vhdl.${file_name}
        }
    }
} else {
    puts "TCL: ERROR: File type $file_lang is not supported."
    return 0
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
    source "$proj_root_dir/simulator/do/default_wave.tcl"
}

source "$proj_root_dir/simulator/run.do"
