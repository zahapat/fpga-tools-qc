
set all_modules_lines_cnt [llength $all_modules]

# Add files to project
if [batch_mode] {
} else {
    for {set i 0} {$i <= [llength $all_modules]} {incr i} {
        set filepath_modules [string range [lindex $all_modules [expr $all_modules_lines_cnt-$i]] 0 end]
        set filepath_correction [concat ${proj_root_dir} ${filepath_modules}]
        set filepath_correction [string map {" " ""} $filepath_correction]
        set filepath [string map {"./" "/"} $filepath_correction]

        if {$filepath eq ${proj_root_dir}} {
            puts "TCL: Ignoring invalid line."
        } else {
            project addfile $filepath
        }
    }
}

# Compile all files in the modules.tcl file
# Sort the files to repsective libraries based on the compile order in the file modules.tcl
vlib $proj_root_dir/simulator/$lib_src_vhdl
# vmap work $proj_root_dir/simulator/$lib_src_vhdl
vlib $proj_root_dir/simulator/$lib_sim_vhdl
# vmap work $proj_root_dir/simulator/$lib_sim_vhdl
for {set i 0} {$i <= [llength $all_modules]} {incr i} {


    # Reconstruct the correct normalized path to source files
    set filepath_modules [string range [lindex $all_modules [expr $all_modules_lines_cnt-$i]] 0 end]
    set filepath_correction [concat ${proj_root_dir} ${filepath_modules}]
    set filepath_correction [string map {" " ""} $filepath_correction]
    set filepath [string map {"./" "/"} $filepath_correction]
    puts "TCL: filepath_correction = $filepath_correction"
    puts "TCL: filepath = $filepath"

    set file_fullname [file tail $filepath]
    puts "TCL: file_fullname = $file_fullname"
    set file_name [string range [lindex [split $file_fullname "."] 0] 0 end]
    puts "TCL: file_name = $file_name"
    set file_lang [string range [lindex [split $filepath "."] 1] 0 end]
    puts "TCL: file_lang = $file_lang"

    # Check for empty lines
    if {$filepath eq ${proj_root_dir}} {
        puts "TCL: Ignoring invalid line."
    } else {

        # Sort files to sim and src libraries, except for verilog files
        if {$file_lang eq "vhd"} {
            # VHDL
            if { [string first "_tb." ${file_fullname}] != -1} {
                if { [file exist "$proj_root_dir/simulator/$lib_sim_vhdl"] } {
                    # Compile
                    puts "TCL: Compiling source '$file_fullname' to existing library '$lib_sim_vhdl'."
                    vcom -2008 -work $lib_sim_vhdl $filepath
                } else {
                    # Create the library, remap
                    puts "TCL: * Creating a new library '$lib_sim_vhdl' and compiling source '$file_fullname' to this library."
                    vlib $proj_root_dir/simulator/$lib_sim_vhdl
                    vmap $lib_sim_vhdl $proj_root_dir/simulator/$lib_sim_vhdl

                    # Compile
                    vcom -2008 -work $lib_sim_vhdl $filepath
                }
            } else {
                if { [file exist "$proj_root_dir/simulator/$lib_src_vhdl"] } {
                    # Compile
                    puts "TCL: Compiling source '$file_fullname' to existing library '$lib_src_vhdl'."
                    vcom -work $lib_src_vhdl $filepath
                } else {
                    # Create the library, remap
                    puts "TCL: * Creating a new library '$lib_src_vhdl' and compiling source '$file_fullname' to this library."
                    vlib $proj_root_dir/simulator/$lib_src_vhdl
                    vmap $lib_src_vhdl $proj_root_dir/simulator/$lib_src_vhdl

                    # Compile
                    vcom -work $lib_src_vhdl $filepath
                }
            }
        } elseif {($file_lang eq "sv") || ($file_lang eq "svh")} {
            #  SystemVerilog
            if { [file exist "$proj_root_dir/simulator/work"] } {
                # Compile
                vlog -sv -work work $filepath
            } else {
                # Create the library, remap
                vlib $proj_root_dir/simulator/work
                vmap work $proj_root_dir/simulator/work
                # Compile
                vlog -sv -work work $filepath
            }
        } elseif {($file_lang eq "v") || ($file_lang eq "vh")} {
            # Verilog
            set verilog_file_present 1
            if { [file exist "$proj_root_dir/simulator/work"] } {
                # Compile
                vlog -work work $filepath
            } else {
                # Recreate the library, remap
                vlib $proj_root_dir/simulator/work
                vmap work $proj_root_dir/simulator/work

                # Compile
	            vlog -work work $filepath
            }
        } else {
                puts "TCL: ERROR: Invalid file suffix."
                exit
        }
    }
}

# Link UNISIM Library
puts "TCL: Linking UNISIM Library"
set unisim_lib_path "$proj_root_dir/simulator/unisim"
set unisim_lib_path_verilog "$proj_root_dir/simulator/unisim_verilog"
if { ([file exist $unisim_lib_path] == 1) || ([file exist $unisim_lib_path_verilog] == 1) } {
    if { [file exist "$proj_root_dir/simulator/$lib_src_vhdl"] } {
        puts "TCL: Linking UNISIM VHDL Src Library"
        vmap $lib_sim_vhdl "$proj_root_dir/simulator/$lib_sim_vhdl"
        vmap $lib_src_vhdl "$proj_root_dir/simulator/unisim"
    }
    if { [file exist "$proj_root_dir/simulator/$lib_sim_vhdl"] } {
        puts "TCL: Linking UNISIM VHDL Sim Library"
        vmap $lib_sim_vhdl "$proj_root_dir/simulator/$lib_sim_vhdl"
        vmap $lib_sim_vhdl "$proj_root_dir/simulator/unisim"
    }
    if { [file exist "$proj_root_dir/simulator/work"] } {
        puts "TCL: Linking UNISIM Verilog Library"
        vmap work "$proj_root_dir/simulator/work"
        vmap work "$proj_root_dir/simulator/unisim_verilog"
    }
}