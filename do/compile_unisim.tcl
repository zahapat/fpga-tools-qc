# Compile Xilinx UNISIM Library (if keyword 'funcsim.' is present in the filename)

# Get top file lang
set top_file_tb_name [string range [lindex $all_modules [expr [llength $all_modules]-1]] 0 end]
set top_file_tb_lang [string range [lindex [split $top_file_tb_name "."] 1] 0 end]

# Re/Compile UNISIM
set switch_compile 0
foreach act_file $all_modules {
    if { [string first "funcsim." ${act_file}] != -1} {
        set switch_compile 1
    }
}

if {$switch_compile == 1} {

    # Search for unisim files
    set unisimVHDlocation "C:/Xilinx/Vivado/2020.2/data/vhdl/src/unisims"
    set unisimVERILOGlocation "C:/Xilinx/Vivado/2020.2/data/verilog/src/unisims"

    # Avoid Compiling retarget: Error (suppressible): C:/Xilinx/Vivado/2020.2/data/vhdl/src/unisims/retarget/IBUFGDS_BLVDS_25.vhd(42): (vcom-1141) Identifier "IBUFGDS" does not identify a component declaration.
    # Solution: try vcom -93 -work unisim
    # set filesUnisimVHD [glob $unisimVHDlocation/*{.vhd}* $unisimVHDlocation/primitive/*{.vhd}* $unisimVHDlocation/retarget/*{.vhd}* $unisimVHDlocation/secureip/*{.vhd}*]

    # Compile Unisim VComponents and Unisim Primitives only
    set filesUnisimVHD [glob $unisimVHDlocation/*{.vhd}* $unisimVHDlocation/primitive/*{.vhd}*]
    set filesUnisimVERILOG [glob $unisimVERILOGlocation/*{.v}*]
    set filesUnisimSYSTEMVERILOG [glob $unisimVERILOGlocation/*{.sv}*]

    # Compile all files in unisimVHDlocation list to library unisim
    set unisim_lib_path "$proj_root_dir/simulator/unisim"
    # set unisim_lib_path "C:/intelFPGA_lite/20.1/modelsim_ase/unisim"

    if { [file exist $unisim_lib_path] == 0 } {
        vlib $unisim_lib_path
        vmap unisim $unisim_lib_path

        if {$top_file_tb_lang eq "vhd"} {
            puts "TCL: Compiling UNISIM VHDL files to this directory: $unisim_lib_path"
            foreach unisimFile $filesUnisimVHD {
                if { [file exist $unisim_lib_path] } {
                    # Compile
                    vcom -93 -work unisim $unisimFile
                }
            }
        } elseif {$top_file_tb_lang eq "v"} {
            puts "TCL: Compiling UNISIM Verilog and SystemVerilog files to this directory: $unisim_lib_path"
            foreach unisimFile $filesUnisimVERILOG {
                if { [file exist $unisim_lib_path] } {
                    # Compile
                    vlog -work unisim $unisimFile
                }
            }
            foreach unisimFile $filesUnisimSYSTEMVERILOG {
                if { [file exist $unisim_lib_path] } {
                    # Compile
                    vlog -sv -work unisim $unisimFile
                }
            }
        } elseif {$top_file_tb_lang eq "sv"} {
            puts "TCL: Compiling UNISIM Verilog and SystemVerilog files to this directory: $unisim_lib_path"
            foreach unisimFile $filesUnisimVERILOG {
                if { [file exist $unisim_lib_path] } {
                    # Compile
                    vlog -work unisim $unisimFile
                }
            }
            foreach unisimFile $filesUnisimSYSTEMVERILOG {
                if { [file exist $unisim_lib_path] } {
                    # Compile
                    vlog -sv -work unisim $unisimFile
                }
            }
        } else {
            puts "TCL: ERROR: Invalid file suffix."
            exit
        }
    }
}