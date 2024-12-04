# Add library name to searched libraries file to be used with the vlog vsim -L option
proc add_searched_library {library_name_or_path searched_libraries_file_path} {
    puts "TCL: Library '${library_name_or_path}' added to searched libraries."
    if {[ catch {
        set searched_libraries [open ${searched_libraries_file_path} "a"]
    } errorstring]} {
        puts "TCL: The following error was generated while adding a searched library: '[file tail ${library_name_or_path}]': $errorstring . Quit."
        quit
    }
    puts -nonewline $searched_libraries "[file tail ${library_name_or_path}]\n"
    close $searched_libraries
}


# Remove a substring from a string sequence
proc remove_string_sequence {str sequence} {
    set result [string map {$sequence ""} $str]
    return $result
}


# Create and map a missing library and add it to searched_libraries.txt
proc create_lib_if_noexist {lib_path searched_libraries_file_path} {
    if {![file exists $lib_path]} {
        vlib $lib_path
        puts "TCL: Creating a new library: '[file tail $lib_path]' located at: '${lib_path}'"
        vmap [file tail $lib_path] $lib_path
        add_searched_library [file tail $lib_path] $searched_libraries_file_path
    }
}


# Remove a library directory with compilation outputs
proc delete_library_and_mappings {lib_path} {
    if {[file exists $lib_path]} {
        puts "TCL: Deleting library '[file tail $lib_path]' and all mappings located at '${lib_path}'"
        vdel -all -lib $lib_path
        file delete -force $lib_path
    } else {
        puts "TCL: WARNING: Deleting library '[file tail $lib_path]' failed because the specified library location '${lib_path}' does not exist. Pass."
    }
}


# Delete a given file
proc delete_file {file_path} {
    if {[file exists $file_path]} {
        puts "TCL: Deleting file '[file tail $file_path]' located at: '${file_path}'"
        file delete -force $file_path
    } else {
        puts "TCL: WARNING: Deleting file '[file tail $file_path]' failed because the specified file location '${file_path}' does not exist. Pass."
    }
}


# Detect partial match on the detected Xilinx IP source names in the precompiled library, return path
proc parse_filenames_and_find_best_common_pattern {detect_pattern list_of_src_paths} {
    set min_length [string length $detect_pattern]
    set filename_characters_matched_best 0
    foreach found_precompiled_ip_names $list_of_src_paths {
        set file_rootname [file rootname [file tail $found_precompiled_ip_names]]
        set file_tail [file tail $found_precompiled_ip_names]

        set filename_characters_matched 0
        set filename_common_sequence ""
        for {set i 0} {$i < $min_length} {incr i} {
            if {[string index $detect_pattern $i] eq [string index $file_rootname $i]} {
                append filename_common_sequence [string index $detect_pattern $i]
                incr filename_characters_matched
            } else {
                break
            }
        }
        puts "TCL: DEBUG: Match check: filename_characters_matched = $filename_characters_matched"

        # Keep only the best match
        if {$filename_characters_matched > $filename_characters_matched_best} {
            puts "TCL: Found new best common sequence match of the searched pattern '${detect_pattern}' : $filename_common_sequence \($filename_characters_matched characters matched\)"
            set filename_common_sequence_best $filename_common_sequence
            set filename_characters_matched_best $filename_characters_matched
            set filepath_matched_best $found_precompiled_ip_names
        }
    }

    return $filepath_matched_best
}



# Parse the src file and find out if there is a submodule needed (1 level supported), line in file with the best match
proc parse_file_and_find_best_common_pattern {find_pattern path_to_ip_src} {
    set detect_pattern $find_pattern
    set skip_pattern "//"
    set src_file [open "$path_to_ip_src" r]
    while {-1 != [gets $src_file line]} {
        # Ignore commented lines and find common sequence with ip_name on each line of the parsed file
        if { [string first ${skip_pattern} $line] == -1} {
            set common_sequence ""
            set line_modified [string map {" " ""} ${line}]
            set min_length [expr min ([string length $detect_pattern], [string length $line_modified])]
            set characters_matched 0
            set characters_matched_best 0
            for {set i 0} {$i < $min_length} {incr i} {
                if {[string index $detect_pattern $i] eq [string index $line_modified $i]} {
                    append common_sequence [string index $detect_pattern $i]
                    incr characters_matched
                } else {
                    break
                }
            }

            # Keep only the best match
            if {$characters_matched > $characters_matched_best} {
                puts "TCL: Found new best common sequence match of the searched pattern '${detect_pattern}': $common_sequence \($characters_matched characters matched\)"
                set common_sequence_best $common_sequence
                set characters_matched_best $characters_matched
                set line_matched_best $line
            }
        }
    }
    close $src_file

    # Detect partial match on the detected line using wildcards based on the best match 'common_sequence_best'
    # Split on spaces, extract the missing src to be added
    puts "line_matched_best = $line_matched_best"
    set line_matched_best [split $line_matched_best " "]
    foreach splitted_line $line_matched_best {
        if {[string match "$common_sequence_best*" $splitted_line]} {
            set missing_ip_src_to_add $splitted_line
            break
        }
    }

    return $missing_ip_src_to_add
}


proc map_precompiled_lib {lib_path} {
    if {![file exists $lib_path]} {
        puts "TCL: WARNING: Unable to map library '[file tail $lib_path]' that should already exist at the specified location: '$lib_path'. Pass."
    } else {
        puts "TCL: Mapping precompiled library '[file tail $lib_path]' located at: '$lib_path'"
        vlib $lib_path
        vmap [file tail $lib_path] $lib_path
    }
}


# Launch VSIM command with searched directories listed in the separate file
proc get_list_item {list list_item_number} {
    if {[ catch {
        puts "TCL: DEBUG: Item ${list_item_number} in the list is: [lindex $list $list_item_number]"
    }]} else {
        return ""
    }
    return "[lindex $list $list_item_number]"
}

proc exec_vsim {file_lib_and_name file_lib_path glbl_lib_and_name searched_libraries_file_path} {
    # Read the file and extract data on every line
    set read_file [open $searched_libraries_file_path r]
    set data_line [split [read $read_file] "\n"]
    close $read_file
    list all_searched_libraries {}
    foreach library $data_line {
        set library_nospaces [string map {" " ""} ${library}]
        if {$library_nospaces ne ""} {
            puts "TCL: DEBUG: Requesting library ${library_nospaces} to be used with \-L option."
            lappend all_searched_libraries $library_nospaces
        }
    }


    # Supress warnings in IPs requiring warning supression (warnings that can't be resolved any other way)
    list ips_requiring_warning_supression {}
    lappend ips_requiring_warning_supression "fifo_generator_v13_2_5"
    lappend ips_requiring_warning_supression "fifo_generator_v13_2_6"
    set supress_warning_msg_id ""
    foreach xil_ip $data_line {
        foreach ip_requiring_warning_supression $ips_requiring_warning_supression {
            if {$xil_ip eq $ip_requiring_warning_supression} {
                puts "TCL: Xilinx IP Core '$ip_requiring_warning_supression' is known to produce 'vsim-8683' warnings \
                    one can not resolve by modifying the encrypted source code. Supress these warnings."
                set supress_warning_msg_id "+nowarnvsim-8683"
            }
        }
    }

    # Execute the vsim command: Max 20 Searched Libraries
    # NOTE: Suppressed warning vsim-8683 (... has no driver) 
    #       because the there is no way to open and debug
    #       encrypted Xilinx IP Core files.
    vsim -lib $file_lib_path -onfinish stop ${supress_warning_msg_id} \
        -L "[lindex $all_searched_libraries 0]" \
        -L "[lindex $all_searched_libraries 1]" \
        -L "[lindex $all_searched_libraries 2]" \
        -L "[lindex $all_searched_libraries 3]" \
        -L "[lindex $all_searched_libraries 4]" \
        -L "[lindex $all_searched_libraries 5]" \
        -L "[lindex $all_searched_libraries 6]" \
        -L "[lindex $all_searched_libraries 7]" \
        -L "[lindex $all_searched_libraries 8]" \
        -L "[lindex $all_searched_libraries 9]" \
        -L "[lindex $all_searched_libraries 10]" \
        -L "[lindex $all_searched_libraries 11]" \
        -L "[lindex $all_searched_libraries 12]" \
        -L "[lindex $all_searched_libraries 13]" \
        -L "[lindex $all_searched_libraries 14]" \
        -L "[lindex $all_searched_libraries 15]" \
        -L "[lindex $all_searched_libraries 16]" \
        -L "[lindex $all_searched_libraries 17]" \
        -L "[lindex $all_searched_libraries 18]" \
        -L "[lindex $all_searched_libraries 19]" \
        $glbl_lib_and_name \
        xil_iplib_verilog.glbl \
        $file_lib_and_name
}