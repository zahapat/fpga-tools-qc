# Load TCL functions
source "${proj_root_dir}simulator/do/tcl_functions.tcl"


# ---------------------------------------------------------------------------------
# Add missing Xilinx Cores and Map respective precompiled (i.e. existing) libraries
# ---------------------------------------------------------------------------------
delete_file ${proj_root_dir}simulator/xil_iplib_verilog.tcl
delete_library_and_mappings ${proj_root_dir}simulator/xil_iplib_verilog
delete_library_and_mappings ${proj_root_dir}simulator/xil_iplib_vhdl



# ----------------------------------------------------------
# Map precompiled (i.e. existing) mandatory Xilinx libraries
# ----------------------------------------------------------
# Mandatory libraries that will always appear in the vsim -L option (Verilog first)
# NOTE: the 'glbl' need to be added and compiled manually...
# IMPORTANT: The actual generation of precompiled libraries takes place in: 
#            "./tcl/generic/vivado/recreate_vivado_proj.tcl"
# NOTE: vivado_version is defined in "simulator/do/make_sim.tcl"
set vivado_version_alias "[string map {"." "_"} $vivado_version]"
set unisim_location_verilog "C:/Xilinx/Vivado/${vivado_version}/data/verilog/src"
set glbl_file_location "$unisim_location_verilog/glbl.v"
create_lib_if_noexist ${proj_root_dir}simulator/xil_iplib_verilog $searched_libraries_file_path
vlog -work ${proj_root_dir}simulator/xil_iplib_verilog $glbl_file_location

map_precompiled_lib "${proj_root_dir}simulator/vivado_precompiled_ver/${vivado_version_alias}/xpm"
add_searched_library "${proj_root_dir}simulator/vivado_precompiled_ver/${vivado_version_alias}/xpm" $searched_libraries_file_path

map_precompiled_lib "${proj_root_dir}simulator/vivado_precompiled_ver/${vivado_version_alias}/unisims_ver"
add_searched_library "${proj_root_dir}simulator/vivado_precompiled_ver/${vivado_version_alias}/unisims_ver" $searched_libraries_file_path

map_precompiled_lib "${proj_root_dir}simulator/vivado_precompiled_ver/${vivado_version_alias}/unimacro_ver"
add_searched_library "${proj_root_dir}simulator/vivado_precompiled_ver/${vivado_version_alias}/unimacro_ver" $searched_libraries_file_path

map_precompiled_lib "${proj_root_dir}simulator/vivado_precompiled_ver/${vivado_version_alias}/secureip"
add_searched_library "${proj_root_dir}simulator/vivado_precompiled_ver/${vivado_version_alias}/secureip" $searched_libraries_file_path



# Mandatory libraries that will always appear in the vsim -L option (VHDL Second)
# NOTE: the 'glbl' has been precompiled as well. No need to add it manually.
map_precompiled_lib "${proj_root_dir}simulator/vivado_precompiled_ver/${vivado_version_alias}/unisim"
add_searched_library "${proj_root_dir}simulator/vivado_precompiled_ver/${vivado_version_alias}/unisim" $searched_libraries_file_path



# Search for all generated Xilinx IP sources
set proj_name "[file tail ${proj_root_dir}]"
set found_xilinx_cores [glob -nocomplain -type d \
    ${proj_root_dir}vivado/${proj_name}.gen/sources_1/ip/*
]

if {[llength $found_xilinx_cores] > 0} {
    # Create the library 'work', then compile into library 'work'

    puts "TCL: Adding Generated Xilinx IP Cores..."
    puts "TCL: Recreating the 'xil_iplib_verilog.tcl' file."
    set simulator_ip_comporder_path "${proj_root_dir}simulator/xil_iplib_verilog.tcl"
    close [open $simulator_ip_comporder_path a]
    set simulator_ip_comporder [open ${simulator_ip_comporder_path} "a"]

    foreach path_to_ip $found_xilinx_cores {
        set ip_name "[file tail $path_to_ip]"
        set relpath_to_ip ".[string range [file normalize $path_to_ip] [string length [file normalize ${proj_root_dir}]] end]"
        puts "TCL: Found Xilinx IP Core: $ip_name"
        puts "TCL: Relative path to the IP Core: $relpath_to_ip"

        # Search for all related Xilinx IPs: single dir or in subdirectories, if top src not found
        set glob_xilinx_core_srcs [glob -nocomplain -type f \
            ${path_to_ip}/{${ip_name}.v} \
            ${path_to_ip}/{${ip_name}.sv} \
        ]
        if {[llength $glob_xilinx_core_srcs] == 0} {
            puts "TCL: Missing sources ${ip_name}.* are distributed in subfolders"
            set glob_xilinx_core_srcs [glob -nocomplain -type f \
                ${path_to_ip}/*/{${ip_name}.v} \
                ${path_to_ip}/*/{${ip_name}.sv} \
            ]
        }

        # Search for all generated Xilinx IP source files
        if {[llength $glob_xilinx_core_srcs] == 1} {
            set relpath_to_ip_src_level1 ".[string range [file normalize $glob_xilinx_core_srcs] [string length [file normalize ${proj_root_dir}]] end]"
            set path_to_ip_src $glob_xilinx_core_srcs
            puts "TCL: Found Xilinx IP Core src: $relpath_to_ip_src_level1"
            
        } elseif {[llength $glob_xilinx_core_srcs] > 1} {
            foreach path_to_ip_src $glob_xilinx_core_srcs {
                set relpath_to_ip_src_level1 ".[string range [file normalize $path_to_ip_src] [string length [file normalize ${proj_root_dir}]] end]"
                # Check first if the module sources are distributed in some subdirectories. 
                # If not, the src will have a unique name, otherwise src instances may have 
                # multiple instances with the same name in the searches directories
                if {[string first "/simulation/" $relpath_to_ip_src_level1] != -1} {
                    puts "TCL: Found Xilinx IP Core src level 1: $relpath_to_ip_src_level1"
                    break
                }
                if {[string first "/sim/" $relpath_to_ip_src_level1] != -1} {
                    puts "TCL: Found Xilinx IP Core src level 1: $relpath_to_ip_src_level1"
                    break
                }
            }

        } else {
            puts "TCL: CRITICAL WARNING: No source found for Xilinx IP Core: $relpath_to_ip_src_level1"
        }

        # Parse the src file and find out if there is a submodule needed (1 level supported)
        # Detect partial match on the detected line using wildcards based on the best match 'common_sequence_best'
        # Split on spaces, extract the missing src to be added
        set missing_ip_src_to_add [\
            parse_file_and_find_best_common_pattern \
            $ip_name $path_to_ip_src \
        ]


        # Try to find the missing source in the precompiled vivado libraries
        set precompiled_vivado_simlib_ips_verilog [glob -nocomplain -type d ${proj_root_dir}simulator/vivado_precompiled_ver/${vivado_version_alias}/$missing_ip_src_to_add]
        set precompiled_vivado_simlib_ips_verilog_name "[file tail $precompiled_vivado_simlib_ips_verilog]"

        set precompiled_vivado_simlib_ips_vhdl [glob -nocomplain -type d ${proj_root_dir}simulator/vivado_precompiled_vhdl/${vivado_version_alias}/$missing_ip_src_to_add]
        set precompiled_vivado_simlib_ips_vhdl_name  "[file tail $precompiled_vivado_simlib_ips_vhdl]"

        # Check if the IP lib is available in VHDL or Verilog precompiled libraries
        if {([llength $precompiled_vivado_simlib_ips_verilog] == 1) } {
            map_precompiled_lib $precompiled_vivado_simlib_ips_verilog
            map_precompiled_lib $precompiled_vivado_simlib_ips_vhdl

            # Create and map a new library 'xil_iplib_verilog', then compile into library 'xil_iplib_verilog'
            create_lib_if_noexist ${proj_root_dir}simulator/xil_iplib_verilog $searched_libraries_file_path

            # Compile IP src found into 'xil_iplib_verilog'
            puts -nonewline $simulator_ip_comporder "$relpath_to_ip_src_level1\n"

            # The IP file mostly contains a reference to a Xilinx IP core that needs to be mapped and included in the lib search
            map_precompiled_lib $precompiled_vivado_simlib_ips_verilog
            add_searched_library $precompiled_vivado_simlib_ips_verilog_name $searched_libraries_file_path

        } else {
            # Search for all related Xilinx IPs: single dir or in subdirectories, if top src not found
            set glob_xilinx_core_srcs [glob -nocomplain -type f \
                ${path_to_ip}/*.v ${path_to_ip}/*.sv ${path_to_ip}/*/*.v ${path_to_ip}/*/*.sv \
            ]

            # # Detect partial match on the detected Xilinx IP source names in the precompiled library
            set filepath_matched_best [\
                parse_filenames_and_find_best_common_pattern \
                $missing_ip_src_to_add $glob_xilinx_core_srcs
            ]

            # Add the missing Xilinx IP source file
            set relpath_to_ip_src_level2 ".[string range [file normalize $filepath_matched_best] [string length [file normalize ${proj_root_dir}]] end]"
            puts "TCL: Found Xilinx IP Core src level 2: $relpath_to_ip_src_level2"
            puts -nonewline $simulator_ip_comporder "$relpath_to_ip_src_level1\n"
            puts -nonewline $simulator_ip_comporder "$relpath_to_ip_src_level2\n"
        }
    }

    close ${simulator_ip_comporder}
    puts "TCL: Adding Generated Xilinx IP Cores finished"


    # Load all non-precompiled Generated Xilinx IP Cores into a list
    puts "TCL: Compiling all added Generated Xilinx IP Cores..."
    list all_modules_ip {}
    set slurp_file_ip [open "${proj_root_dir}simulator/xil_iplib_verilog.tcl" r]
    while {-1 != [gets $slurp_file_ip line]} {
        set ip_filepath [string map {" " ""} ${line}]
        if {$ip_filepath eq ""} {
            puts "TCL: Ignoring invalid empty line."
        } else {
            lappend all_modules_ip "$ip_filepath"
        }
    }
    close $slurp_file_ip
    puts "TCL: all_modules_ip = $all_modules_ip"

    # Compile all core sources that couldn't be found in precompiled libraries in the all_modules_ip list from bottom up
    set all_modules_ip_lines_cnt [llength $all_modules_ip]

    puts "TCL: Compiling Xilinx IP sources started..."
    for {set i 0} {$i <= [llength $all_modules_ip]} {incr i} {

        # Compile all files in the all_modules_ip list based on the xil_iplib_verilog.tcl file
        # Reconstruct the correct normalized path to source files
        set xil_ip_filepath_modules [string range [lindex $all_modules_ip [expr $all_modules_ip_lines_cnt-$i]] 0 end]
        set xil_ip_filepath_correction [concat ${proj_root_dir} ${xil_ip_filepath_modules}]
        set xil_ip_filepath_correction [string map {" " ""} $xil_ip_filepath_correction]
        set xil_ip_filepath_correction [string map {"./" "/"} $xil_ip_filepath_correction]
        set xil_ip_filepath [string map {"//" "/"} $xil_ip_filepath_correction]

        # Check for invalid lines
        if {$xil_ip_filepath eq ${proj_root_dir}} {
            puts "TCL: Ignoring invalid line."
        } else {
            # Compile all sources into the library 'xil_iplib_verilog'
            create_lib_if_noexist ${proj_root_dir}simulator/xil_iplib_verilog $searched_libraries_file_path
            vlog -work ${proj_root_dir}simulator/xil_iplib_verilog $xil_ip_filepath
        }
    }
    puts "TCL: Compiling all added Generated Xilinx IP Cores Finished"

} else {
    puts "TCL: No Xilinx IP cores are available in the ${proj_root_dir}vivado/ip directory. Skip adding IP Sources."
}