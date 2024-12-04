# Get Origin Directory
proc get_origin_dir {} {
    # Use origin directory path location variable, if specified in the tcl shell
    set origin_dir "."
    if { [info exists ::origin_dir_loc] } {
        set origin_dir $::origin_dir_loc
    }
    return $origin_dir
}

# Add a single sorce file
proc add_src_file {src_file_library src_file_path} {
    set origin_dir [get_origin_dir]
    set vivado_added_hdl_report_path "${origin_dir}/vivado/0_report_added_modules.rpt"
    set vivado_added_hdl_report [open $vivado_added_hdl_report_path "a"]
    add_files -fileset "sources_1" -norecurse [file join $src_file_path ""]
    if {$src_file_library ne ""} {
        set_property library [file join $src_file_library ""] [get_files [file join $src_file_path ""]]
        puts -nonewline $vivado_added_hdl_report "${src_file_path}\n"
    }
    close $vivado_added_hdl_report
}

# Add a single simulation file
proc add_sim_file {sim_file_path} {
    set origin_dir [get_origin_dir]
    set simulator_comporder_path "${origin_dir}/simulator/modules.tcl"
    set simulator_comporder [open $simulator_comporder_path "a"]
    puts -nonewline $simulator_comporder "$sim_file_path\n"
    close $simulator_comporder
}

# Add a module (including all its source files, packages, simulation files, etc.)
proc add_module {relpath_to_module} {
    if {[file exist "${relpath_to_module}"]} {
        set origin_dir [get_origin_dir]
        puts "TCL: ------------------------------------------------"
        set this_file_name [file tail $relpath_to_module]
        puts "TCL: Adding module: '$this_file_name' located at: '$relpath_to_module'"

        set simulator_comporder_path "${origin_dir}/simulator/modules.tcl"
        set vivado_added_hdl_report_path "${origin_dir}/vivado/0_report_added_modules.rpt"
        set vivado_added_scripts_report_path "${origin_dir}/vivado/0_report_added_xdc.rpt"

        close [open $simulator_comporder_path a]
        close [open $vivado_added_hdl_report_path a]
        close [open $vivado_added_scripts_report_path a]

        set this_module_compiled 0
        set file_content [read [set FH [open ${vivado_added_hdl_report_path} r]]]
        close $FH

        # Check if this module is in the report of added modules in Vivado
        foreach line_file $file_content {
            if { [string first $relpath_to_module $line_file] != -1} {
                set this_module_compiled 1
                break
            }
        }

        if {$this_module_compiled eq 0} {
            # Open output paths
            puts "TCL: Adding sources of: $relpath_to_module"
            set simulator_comporder [open ${simulator_comporder_path} "a"]
            set vivado_added_hdl_report [open $vivado_added_hdl_report_path "a"]
            set vivado_added_scripts_report [open $vivado_added_scripts_report_path "a"]

            # Add all existing files from the current module directory
            source "${relpath_to_module}/compile_order.tcl"

            # DO NOT TOUCH
            # Add Related XDC/TCL Files in the module directory
            # Search for xdc/tcl foles up to 2 levels of hierarchy
            # Search for all .xdc sources associated with this module
            set foundFiles [glob -nocomplain -type f \
                ${relpath_to_module}/*{.xdc} \
                ${relpath_to_module}/*/*{.xdc} \
            ]
            if {[llength $foundFiles] > 0} {
                foreach file_path $foundFiles {
                    read_xdc $file_path -unmanaged
                    add_files -norecurse -fileset "constrs_1" "$file_path"
                    puts -nonewline $vivado_added_scripts_report "$file_path\n"
                }
            }

            # Search for all .tcl sources associated with this module
            set foundFiles [glob -nocomplain -type f \
                ${relpath_to_module}/*{.tcl} \
                ${relpath_to_module}/*/*{.tcl} \
            ]
            if {[llength $foundFiles] > 0} {
                foreach file_path $foundFiles {
                    if { [string first $this_file_name $file_path] == -1} {
                        # Read lines in the file. This is not an xdc file.
                        source $file_path
                        puts -nonewline $vivado_added_scripts_report "$file_path\n"
                    }
                }
            }

            close $simulator_comporder
            close $vivado_added_hdl_report
            close $vivado_added_scripts_report

            puts "TCL: Adding sources of: $relpath_to_module finished."
            puts "TCL: ------------------------------------------------"
        }

    } else {
        puts "TCL: ERROR: Required module directory '[file normalize ${relpath_to_module}]' does not exist. Quit."
        quit
    }
}


# Tell whether a certain instance exists in the design
proc check_inst_present_in_design {path_to_inst all_insts} {
    if {$all_insts eq ""} {
        set all_insts [get_cells -hier -filter {NAME =~ */* && IS_PRIMITIVE != 1}]
    }
    set target_inst_present 0
    foreach inst $all_insts {
        puts ${inst}
        if {${inst} eq "$path_to_inst"} {
            puts "MATCH"
            set target_inst_present 1
        }
    }
    puts "$target_inst_present"
    return $target_inst_present
}