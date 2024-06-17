set all_modules_lines_cnt [llength $all_modules]

# Compile all files in the modules.tcl file
# Sort the files to repsective libraries based on the compile order in the file modules.tcl
puts "TCL: Compiling sources started..."
set verilog_libname "xil_iplib_verilog"
for {set i 0} {$i <= [llength $all_modules]} {incr i} {

    # Reconstruct the correct normalized path to source files
    set filepath_modules [string range [lindex $all_modules [expr $all_modules_lines_cnt-$i]] 0 end]
    set filepath_correction [concat ${proj_root_dir} ${filepath_modules}]
    set filepath_correction [string map {" " ""} $filepath_correction]
    set filepath_correction [string map {"./" "/"} $filepath_correction]
    set filepath [string map {"//" "/"} $filepath_correction]
    puts "TCL: filepath_correction = $filepath_correction"
    puts "TCL: filepath = $filepath"

    set file_fullname [file tail $filepath]
    puts "TCL: file_fullname = $file_fullname"
    set file_name [string range [lindex [split $file_fullname "."] 0] 0 end]
    puts "TCL: file_name = $file_name"
    set file_lang [string range [lindex [split $filepath "."] 1] 0 end]
    puts "TCL: file_lang = $file_lang"

    # Check for invalid lines
    if {$filepath eq ${proj_root_dir}} {
        puts "TCL: Ignoring invalid empty line."
    } else {

        # Sort files to sim and src libraries, except for verilog files
        if {$file_lang eq "vhd"} {
            # VHDL
            if { [string first "_tb." ${file_fullname}] != -1} {
                if { [file exist "${proj_root_dir}simulator/$lib_sim_vhdl"] } {
                    # Compile
                    puts "TCL: Compiling source '$file_fullname' into the existing library '$lib_sim_vhdl'."
                    vcom -2008 -work ${proj_root_dir}simulator/$lib_sim_vhdl $filepath
                } else {
                    # Create the library, remap
                    puts "TCL: * Creating a new library '$lib_sim_vhdl' and compiling source '$file_fullname' into this library."
                    vlib ${proj_root_dir}simulator/$lib_sim_vhdl
                    vmap $lib_sim_vhdl ${proj_root_dir}simulator/$lib_sim_vhdl

                    # Compile
                    vcom -2008 -work ${proj_root_dir}simulator/$lib_sim_vhdl $filepath
                }
            } else {
                if { [file exist "${proj_root_dir}simulator/$lib_src_vhdl"] } {
                    # Compile
                    puts "TCL: Compiling source '$file_fullname' into the existing library '$lib_src_vhdl'."
                    vcom -work ${proj_root_dir}simulator/$lib_src_vhdl $filepath
                } else {
                    # Create the library, remap
                    puts "TCL: * Creating a new library '$lib_src_vhdl' and compiling source '$file_fullname' into this library."
                    vlib ${proj_root_dir}simulator/$lib_src_vhdl
                    vmap $lib_src_vhdl ${proj_root_dir}simulator/$lib_src_vhdl

                    # Compile
                    vcom -work ${proj_root_dir}simulator/$lib_src_vhdl $filepath
                }
            }
        } elseif {($file_lang eq "sv") || ($file_lang eq "svh")} {
            #  SystemVerilog
            if { [file exist "${proj_root_dir}simulator/${verilog_libname}"] } {
                # Compile
                vlog -sv -work ${proj_root_dir}simulator/${verilog_libname} $filepath
            } else {
                # Create the library, remap
                vlib ${proj_root_dir}simulator/${verilog_libname}
                vmap ${verilog_libname} ${proj_root_dir}simulator/${verilog_libname}
                # Compile
                vlog -sv -work ${proj_root_dir}simulator/${verilog_libname} $filepath
            }
        } elseif {($file_lang eq "v") || ($file_lang eq "vh")} {
            # Verilog
            set verilog_file_present 1
            if { [file exist "${proj_root_dir}simulator/${verilog_libname}"] } {
                # Compile
                vlog -work ${proj_root_dir}${verilog_libname} $filepath
            } else {
                # Recreate the library, remap
                vlib ${proj_root_dir}simulator/${verilog_libname}
                vmap ${verilog_libname} ${proj_root_dir}simulator/${verilog_libname}

                # Compile
	            vlog -work ${proj_root_dir}simulator/${verilog_libname} $filepath
            }
        } else {
                puts "TCL: ERROR: Invalid file suffix."
                exit
        }
    }
}
puts "TCL: Compiling sources finished"
