source ${proj_root_dir}simulator/do/tcl_functions.tcl

puts "TCL: -----------------------------------------------------"
puts "TCL: LAUNCHING TESTBENCH: Top = $file_full_name"
puts "TCL: -----------------------------------------------------"

set verilog_libname "xil_iplib_verilog"
if {($file_lang eq "sv") || ($file_lang eq "svh")} {
    set glbl_lib_and_filename ""
    if { [string first "_tb." ${file_full_name}] != -1} {
        if {[ catch {
            exec_vsim \
                "${verilog_libname}.${file_name}" \
                ${proj_root_dir}simulator/${verilog_libname} \
                $glbl_lib_and_filename \
                $searched_libraries_file_path
        } errorstring]} {
            puts "TCL: The following error was generated: $errorstring - Attempting to refresh the library image."
            # Refresh the library image & launch sim
            vlog -work ${proj_root_dir}simulator/${verilog_libname} -refresh
            exec_vsim \
                "${verilog_libname}.${file_name}" \
                ${proj_root_dir}simulator/${verilog_libname} \
                $glbl_lib_and_filename \
                $searched_libraries_file_path
        }

    } else {
        if {[ catch {
            exec_vsim \
                "${verilog_libname}.${file_name}" \
                ${proj_root_dir}simulator/${verilog_libname} \
                $glbl_lib_and_filename \
                $searched_libraries_file_path
        } errorstring]} {
            puts "TCL: The following error was generated: $errorstring - Attempting to refresh the library image."
            # Refresh the library image & launch sim
            vlog -work ${proj_root_dir}simulator/${verilog_libname} -refresh
            exec_vsim \
                "${verilog_libname}.${file_name}" \
                ${proj_root_dir}simulator/${verilog_libname} \
                $glbl_lib_and_filename \
                $searched_libraries_file_path
        }
    }

} elseif {($file_lang eq "v") || ($file_lang eq "vh")} {
    set glbl_lib_and_filename ""
    if { [string first "_tb." ${file_full_name}] != -1} {
        if {[ catch {
            exec_vsim \
                "${verilog_libname}.${file_name}" \
                ${proj_root_dir}simulator/${verilog_libname} \
                $glbl_lib_and_filename \
                $searched_libraries_file_path
        } errorstring]} {
            puts "TCL: The following error was generated: $errorstring - Attempting to refresh the library image."
            # Refresh the library image & launch sim
            vlog -work ${proj_root_dir}simulator/${verilog_libname} -refresh
            exec_vsim \
                "${verilog_libname}.${file_name}" \
                ${proj_root_dir}simulator/${verilog_libname} \
                $glbl_lib_and_filename \
                $searched_libraries_file_path
        }

    } else {
        if {[ catch {
            exec_vsim \
                "${verilog_libname}.${file_name}" \
                ${proj_root_dir}simulator/${verilog_libname} \
                $glbl_lib_and_filename \
                $searched_libraries_file_path
        } errorstring]} {
            puts "TCL: The following error was generated: $errorstring - Attempting to refresh the library image."
            # Refresh the library image & launch sim
            vlog -work ${proj_root_dir}simulator/${verilog_libname} -refresh
            exec_vsim \
                "${verilog_libname}.${file_name}" \
                ${proj_root_dir}simulator/${verilog_libname} \
                $glbl_lib_and_filename \
                $searched_libraries_file_path
        }
    }

} elseif {$file_lang eq "vhd"} {
    set glbl_lib_and_filename "unisim.glbl_vhd"
    if { [string first "_tb." ${file_full_name}] != -1} {
        if {[ catch {
            exec_vsim \
                $lib_sim_vhdl.${file_name} \
                ${proj_root_dir}simulator/$lib_sim_vhdl \
                $glbl_lib_and_filename \
                $searched_libraries_file_path
        } errorstring]} {
            puts "TCL: The following error was generated: $errorstring - Attempting to refresh the library image."
            # Refresh the library image & launch sim
            vcom -work ${proj_root_dir}simulator/${verilog_libname} -refresh
            vcom -work ${proj_root_dir}simulator/$lib_src_vhdl -refresh
            vcom -work ${proj_root_dir}simulator/$lib_sim_vhdl -refresh
            exec_vsim \
                $lib_sim_vhdl.${file_name} \
                ${proj_root_dir}simulator/$lib_sim_vhdl \
                $glbl_lib_and_filename \
                $searched_libraries_file_path
        }

    } else {
        if {[ catch {
            exec_vsim \
                $file_full_name \
                ${proj_root_dir}simulator/$lib_src_vhdl \
                $glbl_lib_and_filename \
                $searched_libraries_file_path
        } errorstring]} {
            puts "TCL: The following error was generated: $errorstring - Attempting to refresh the library image."
            # Refresh the library image & launch sim
            vcom -work ${proj_root_dir}simulator/${verilog_libname} -refresh
            vcom -work ${proj_root_dir}simulator/$lib_src_vhdl -refresh
            vcom -work ${proj_root_dir}simulator/$lib_sim_vhdl -refresh
            exec_vsim \
                $file_full_name \
                ${proj_root_dir}simulator/$lib_src_vhdl \
                $glbl_lib_and_filename \
                $searched_libraries_file_path
        }
    }
} else {
    puts "TCL: ERROR: File type $file_lang is not supported."
    return 0
}