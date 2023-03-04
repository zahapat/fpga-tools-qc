# Add files to project
if [batch_mode] {
} else {
    # vlib work
    # vmap $lib_src_vhdl work
    # vmap $lib_sim_vhdl work
    # vmap work work

    for {set i 0} {$i < [llength $all_modules]} {incr i} {
        set filepath [string range [lindex $all_modules $i] 0 end]
        project addfile $filepath
    }
}

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
                if { [file exist "$proj_root_dir/simulator/$lib_sim_vhdl"] } {
                    # Compile
                    puts "TCL: Compiling source '$file_fullname' to existing library '$lib_sim_vhdl'."
                    vcom -2008 -work $lib_sim_vhdl $filepath
                    # vcom -2008 -work work $filepath
                } else {
                    # Create the library, remap
                    puts "TCL: * Creating a new library '$lib_sim_vhdl' and compiling source '$file_fullname' to this library."
                    vlib $proj_root_dir/simulator/$lib_sim_vhdl
                    vmap $lib_sim_vhdl $proj_root_dir/simulator/$lib_sim_vhdl

                    # Compile
                    vcom -2008 -work $lib_sim_vhdl $filepath
                    # vcom -2008 -work work $filepath
                }
            } else {
                if { [file exist "$proj_root_dir/simulator/$lib_src_vhdl"] } {
                    # Compile
                    puts "TCL: Compiling source '$file_fullname' to existing library '$lib_src_vhdl'."
                    vcom -work $lib_src_vhdl $filepath
                    # vcom -work work $filepath
                } else {
                    # Create the library, remap
                    puts "TCL: * Creating a new library '$lib_src_vhdl' and compiling source '$file_fullname' to this library."
                    vlib $proj_root_dir/simulator/$lib_src_vhdl
                    vmap $lib_src_vhdl $proj_root_dir/simulator/$lib_src_vhdl

                    # Compile
                    vcom -work $lib_src_vhdl $filepath
                    # vcom -work work $filepath
                }
            }
        } elseif {$file_lang eq "sv"} {
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
        } elseif {$file_lang eq "v"} {
            # Verilog
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