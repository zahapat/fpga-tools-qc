# Compile Xilinx UNISIM Library (if keyword 'funcsim.' is present in the filename)

set top_file_tb_name [string range [lindex $all_modules [expr [llength $all_modules]-1]] 0 end]
set top_file_tb_name [string map {" " ""} ${top_file_tb_name}]
set top_file_tb_name [file tail $top_file_tb_name]
set top_file_tb_lang [string range [lindex [split $top_file_tb_name "."] 1] 0 end]

# Re/Compile UNISIM
set switch_compile 0
foreach act_file $all_modules {
    if { [string first "funcsim." ${act_file}] != -1} {
        set switch_compile 1
    }
}
set unisim_lib_path "$proj_root_dir/simulator/unisim"
    # set unisim_lib_path "C:/intelFPGA_lite/20.1/modelsim_ase/unisim"

if { [file exist $unisim_lib_path] == 0 } {
    set switch_compile 1
}

if {$switch_compile == 1} {

    # Search for unisim files
    set unisimVHDlocation "C:/Xilinx/Vivado/2020.2/data/vhdl/src/unisims"
    set unisimVERILOGlocation "C:/Xilinx/Vivado/2020.2/data/verilog/src"

    # Avoid Compiling retarget: Error (suppressible): C:/Xilinx/Vivado/2020.2/data/vhdl/src/unisims/retarget/IBUFGDS_BLVDS_25.vhd(42): (vcom-1141) Identifier "IBUFGDS" does not identify a component declaration.
    # Solution: try vcom -93 -work unisim
    # set filesUnisimVHD [glob $unisimVHDlocation/*{.vhd}* $unisimVHDlocation/primitive/*{.vhd}* $unisimVHDlocation/retarget/*{.vhd}* $unisimVHDlocation/secureip/*{.vhd}*]

    # Compile Unisim VComponents and Unisim Primitives only
    set filesUnisimVHD [glob -nocomplain -type f $unisimVHDlocation/*{.vhd}* $unisimVHDlocation/primitive/*{.vhd}*]
    set filesUnisimVERILOG [glob -nocomplain -type f $unisimVERILOGlocation/*{.v}* $unisimVERILOGlocation/unisims/*{.v}*]
    set filesUnisimSYSTEMVERILOG [glob -nocomplain -type f $unisimVERILOGlocation/unisims/*{.sv}*]

    # Compile all files in unisimVHDlocation list to library unisim
    set unisim_lib_path "$proj_root_dir/simulator/unisim"
    set unisim_lib_path_verilog "$proj_root_dir/simulator/unisim_verilog"
    # set unisim_lib_path "C:/intelFPGA_lite/20.1/modelsim_ase/unisim"

    if { ([file exist $unisim_lib_path] == 0) || ([file exist $unisim_lib_path_verilog] == 0) } {
        vlib $unisim_lib_path
        vmap unisim $unisim_lib_path

        vlib $unisim_lib_path_verilog
        vmap unisim_verilog $unisim_lib_path_verilog

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
                if { [file exist $unisim_lib_path_verilog] } {
                    # Compile
                    vlog -work unisim_verilog $unisimFile
                }
            }
            foreach unisimFile $filesUnisimSYSTEMVERILOG {
                if { [file exist $unisim_lib_path_verilog] } {
                    # Compile
                    vlog -sv -work unisim_verilog $unisimFile
                }
            }
        } elseif {$top_file_tb_lang eq "sv"} {
            puts "TCL: Compiling UNISIM Verilog and SystemVerilog files to this directory: $unisim_lib_path"
            foreach unisimFile $filesUnisimVERILOG {
                if { [file exist $unisim_lib_path] } {
                    # Compile
                    vlog -work unisim_verilog $unisimFile
                }
            }
            foreach unisimFile $filesUnisimSYSTEMVERILOG {
                if { [file exist $unisim_lib_path] } {
                    # Compile
                    vlog -sv -work unisim_verilog $unisimFile
                }
            }
        } else {
            puts "TCL: ERROR: Invalid file suffix: top_file_tb_name=$top_file_tb_name;= top_file_tb_lang=$top_file_tb_lang"
            exit
        }
    } else {
        puts "TCL WARNING: The UNISIM path $unisim_lib_path does not exist."
        puts "TCL WARNING: Or The UNISIM path $unisim_lib_path_verilog does not exist."
    }
}