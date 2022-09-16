# Automatic management of signals, arrays, subtypes and constants in a VHDL file
# This script scans the VHDL file 'file_to_scan' and: 
#     1) bottom-top approach:
#     1.1) reads all existing [declared] signals -> makes a database of them (can be multiple lines!)
#     1.2) reads all existing [declared] subtypes -> makes a database of them (is one line)
#     1.3) reads all existing [declared] constants -> makes a database of them (is one line)

#     2) bottom-top approach:
#     2.1) reads all missing [to be declared] signals -> makes a database of them (can be multiple lines!)
#     2.2) reads all missing [to be declared] subtypes -> makes a database of them (is one line)
#     2.3) reads all missing [to be declared] constants (First: Declaration part -> Second: architecture part)

#     3) bottom-top approach:
#     3.1) compare, which signals need to be (re)declared
#     3.2) compare, which subtypes need to be (re)declared
#     3.3) compare, which constants need to be (re)declared

#     4) top-bottom approach:
#     4.1) (re)declare constants
#     4.2) (re)declare subtypes
#     4.3) (re)declare signals

puts "TCL: Scanning module './helpers/wrapper_ila.vhd'"

# Details of the scanned module
puts "TCL: file_to_scan = $file_to_scan"
puts "TCL: file_to_scan_path = $file_to_scan_path"

# 1) LIBRARIES: Copy everything from the beginning of the file, ending by beginning of the declaration of the module
set cnt 0
set slurp_file [open "$file_to_scan_path" r]
set end_detected 0
set valid_lines 1
set all_lines_beginning ""
while {(-1 != [gets $slurp_file line]) && ($end_detected == 0)} {
    incr cnt
    if {$end_detected == 0} {
        # Detect end, stop reading these lines
        if {[regexp -all {entity} $line] == 1} {
            if {[regexp -all {is} $line] == 1} {
                if {$valid_lines == 1} {
                    if {[regexp -all { [--]} $line] == 0} {
                        puts "TCL: End detected line $cnt."
                        set valid_lines 0
                        set end_detected 1
                        set line_insert_generics_ifnotexists $cnt
                    }
                }
            }
        }
        # Detect valid lines and read these lines (ignore commented lines)
        if {$valid_lines == 1} {
            # Read only uncommented lines
            if {[regexp -all { [--]} $line] == 0} {
                # Show valid line
                puts "TCL: file '$file_to_scan' line $cnt: $line"

                # Save this line
                if {$line == ""} {
                    set line " "
                }
                append all_lines_beginning $line "|"
            }
        }
    }
}
close $slurp_file
puts "TCL: all_lines_beginning = $all_lines_beginning"


# 2) GENERICS: Find and copy all the generics
set valid_lines 0
set end_detected 0
set cnt 0
set slurp_file [open "$file_to_scan_path" r]
set all_generic_lines ""
set all_generic_names ""
set all_generic_details ""
set line_insert_generics $line_insert_generics_ifnotexists
while {-1 != [gets $slurp_file line]} {
    incr cnt
    if {$end_detected == 0} {
        # Detect end, stop reading these lines
        if {[regexp -all { port [(]} $line] == 1} {
            if {$valid_lines == 1} {
                if {[regexp -all { [--]} $line] == 0} {
                    puts "TCL: End detected line $cnt"
                    set valid_lines 0
                    set end_detected 1
                }
            }
        }
        if {$valid_lines == 1} {
            if {[regexp -all { [--]} $line] == 0} {
                if {[regexp -all { [;)]} $line] == 0} {
                    # Show valid line
                    puts "TCL: file '$file_to_scan' line $cnt: $line"
                    append all_generic_lines $line "|"
                    set generic_name [string range [lindex [split $line ":"] 0] 0 end]
                    set generic_name [string map {" " ""} $generic_name]
                    append all_generic_names $generic_name "|"
                }
            }
        }
        # Detect start and enable reading these lines (ignore commented lines)
        if {[regexp -all { generic [(]} $line] == 1} {
            if {[regexp -all { [--]} $line] == 0} {
                if {$end_detected == 0} {
                    puts "TCL: Valid line $cnt"
                    set valid_lines 1
                    set line_insert_generics $cnt
                }
            }
        }
    }
}
close $slurp_file
set flag_generic_region_exists 1
if {$line_insert_generics == "none"} {
    set line_insert_generics $line_insert_generics_ifnotexists
    set flag_generic_region_exists 0
}
set all_generic_lines [string map {";" ""} $all_generic_lines]
puts "TCL: all_generic_lines = $all_generic_lines"


# 3) PORTS: Search for input/output ports (Standard Logic Vector / Standard Logic)
set valid_lines 0
set end_detected 0
set cnt 0
set slurp_file [open "$file_to_scan_path" r]
set all_port_names ""
set all_ports ""
set all_input_names ""
set all_input_lines ""
set all_input_widths ""
set all_input_widths_total ""
set all_output_names ""
set all_output_lines ""
while {-1 != [gets $slurp_file line]} {
    incr cnt
    if {$end_detected == 0} {
        # Detect end, stop reading these lines
        if {[regexp -all {architecture} $line] == 1} {
            if {[regexp -all {of} $line] == 1} {
                if {$valid_lines == 1} {
                    if {[regexp -all { [--]} $line] == 0} {
                        puts "TCL: End detected line $cnt"
                        set line_declaration_begin $cnt
                        set valid_lines 0
                        set end_detected 1
                    }
                }
            }
        }
        if {$valid_lines == 1} {
            if {[regexp -all { [--]} $line] == 0} {
                if {[regexp -all {:} $line] == 1} {
                    # Show valid port found
                    puts "TCL: file '$file_to_scan' line $cnt: $line"

                    # Show port name
                    # set range_high [string range [lindex [split $range_changed_delimiter .] 0] 0 end]
                    set line_part [string range [lindex [split $line ":"] 0] 0 end]
                    set port_name [string map {" " ""} $line_part]
                    set port_detail [string range [lindex [split $line ":"] 1] 0 end]
                    puts "TCL: Port name = $port_name"
                    puts "TCL: Port details = $port_detail"

                    set port_line "$port_name :$port_detail"
                    puts "TCL: Joined: $port_line"

                    # Add them to the list of ports (separate by |)
                    append all_port_names $port_name "|"
                    append all_ports $port_line "|"

                    # Convert [std_logic] -> [std_logic_vector(0 downto 0)]
                    if {[regexp -all {std_logic;} $port_line] == 1} {
                        set port_width 0
                        set width_total 0
                        set width_total_resolved_plus1 [incr width_total]
                    } elseif {[regexp -all {std_logic } $port_line] == 1} {
                        set port_width 0
                        set width_total 0
                        set width_total_resolved_plus1 [incr width_total]
                    }

                    # Detect Standard Logic Vector and then conduct further port analysis
                    set slv_detected 0
                    if {[regexp -all {std_logic_vector} $port_line] == 1} {
                        set slv_detected 1
                    }
                    # Calculate total width of a standard logic vector
                    if {$slv_detected == 1} {

                        # Find the width of the port (_ dt_t _)
                        set line_part1 [string range [lindex [split $line ");"] 0] 0 end]
                        set line_part2 [string range [lindex [split $line_part1 "("] 1] 0 end]
                        set port_width $line_part2
                        puts "TCL: Width = $port_width"

                        # Get port width (_ downto _) and resolve its width, else take (_ to _)
                        if {[regexp -all { downto } $port_width] == 1} {
                            set range_changed_delimiter [string map {" downto " "."} $port_width]
                            puts "TCL: Changed delimiter: $range_changed_delimiter"
                            set range_high [string range [lindex [split $range_changed_delimiter .] 0] 0 end]
                            puts "TCL: range_high = $range_high"
                            set range_low [string range [lindex [split $range_changed_delimiter .] 1] 0 end]
                            puts "TCL: range_low = $range_low"
                            set width_total "$range_high - ${range_low}"
                            puts "TCL: width_total = $width_total"
                            set width_total_resolved [expr $width_total]
                            puts "TCL: width_total_resolved = $width_total_resolved"
                            set width_total_resolved_plus1 [incr width_total_resolved]
                            puts "TCL: width_total_resolved+1 = $width_total_resolved_plus1"
                        } else {
                            set range_changed_delimiter [string map {" to " "."} $port_width]
                            puts "TCL: Changed delimiter: $range_changed_delimiter"
                            set range_high [string range [lindex [split $range_changed_delimiter .] 1] 0 end]
                            puts "TCL: range_high = $range_high"
                            set range_low [string range [lindex [split $range_changed_delimiter .] 0] 0 end]
                            puts "TCL: range_low = $range_low"
                            set width_total "$range_high - ${range_low}"
                            puts "TCL: width_total = $width_total"
                            set width_total_resolved [expr $width_total]
                            puts "TCL: width_total_resolved = $width_total_resolved"
                            set width_total_resolved_plus1 [incr width_total_resolved]
                            puts "TCL: width_total_resolved+1 = $width_total_resolved_plus1"
                        }
                    }

                    # Find Input ports to determine how many emulators to create
                    if {[regexp -all {: in} $line] == 1} {
                        append all_input_names $port_name "|"
                        append all_input_lines $port_line "|"
                        append all_input_widths $port_width "|"
                        append all_input_widths_total $width_total "|"
                        append all_input_widths_total_resolved $width_total_resolved_plus1 "|"
                    } elseif {[regexp -all {:in} $line] == 1} {
                        append all_input_names $port_name "|"
                        append all_input_lines $port_line "|"
                        append all_input_widths $port_width "|"
                        append all_input_widths_total $width_total "|"
                        append all_input_widths_total_resolved $width_total_resolved_plus1 "|"
                    }

                    # Find Output ports and show their width
                    if {[regexp -all {: out} $line] == 1} {
                        append all_output_names $port_name "|"
                        append all_output_lines $port_line "|"
                        append all_output_widths_total_resolved $width_total_resolved_plus1 "|"
                    } elseif {[regexp -all {:out} $line] == 1} {
                        append all_output_names $port_name "|"
                        append all_output_lines $port_line "|"
                        append all_output_widths_total_resolved $width_total_resolved_plus1 "|"
                    }
                }
            }
        }
        # Detect start and enable reading these lines (ignore commented lines)
        if {[regexp -all {port [(]} $line] == 1} {
            if {[regexp -all { [--]} $line] == 0} {
                if {$end_detected == 0} {
                    puts "TCL: Valid line $cnt"
                    set valid_lines 1
                    set line_port_declaration_begin $cnt
                }
            }
        }
    }
}
close $slurp_file


# 4) # Detect the end of the declaration part
set cnt 0
set slurp_file [open "$file_to_scan_path" r]
# List of keywords used in the declaration part: procedure, signal, function, constant, subtype, record, type
set line_first_occurrence_declaration 0
set line_last_declaration 0
set line_first_occurrence_arch 0
set line_last_occurrence_arch 0
set inside_subprogram 0
set process_detected 0
while {-1 != [gets $slurp_file line]} {
    incr cnt
    # Search for commands, which are illegal in the declaration part, are in the architecture (and oppositely)
    # Beginning of the declaration part is already stored in 'line_declaration_begin'
    if {$cnt >= $line_declaration_begin} {

        # Detect the end of the declaration part, avoid comments
        # Keywords: procedure, signal, function, constant, subtype, record, type
        if {[regexp -all {procedure } $line] == 1} {
            if {[regexp -all { [--]} $line] == 0} {
                set [incr inside_subprogram]
                set line_last_declaration $cnt
            }
        }

        if {[regexp -all {function } $line] == 1} {
            if {[regexp -all { [--]} $line] == 0} {
                set [incr inside_subprogram]
                set line_last_declaration $cnt
            }
        }

        if {[regexp -all { constant } $line] == 1} {
            if {[regexp -all { [--]} $line] == 0} {
                set line_last_declaration $cnt
            }
        }

        if {[regexp -all { subtype } $line] == 1} {
            if {[regexp -all { [--]} $line] == 0} {
                set line_last_declaration $cnt
            }
        }

        if {[regexp -all { record } $line] == 1} {
            if {[regexp -all { [--]} $line] == 0} {
                set line_last_declaration $cnt
            }
        }

        if {[regexp -all { type } $line] == 1} {
            if {[regexp -all { [--]} $line] == 0} {
                set line_last_declaration $cnt
            }
        }

        if {[regexp -all {end procedure} $line] == 1} {
            if {[regexp -all { [--]} $line] == 0} {
                set [expr $inside_subprogram-1]
                set line_last_declaration $cnt
            }
        }

        if {[regexp -all {end function} $line] == 1} {
            if {[regexp -all { [--]} $line] == 0} {
                set [expr $inside_subprogram-1]
                set line_last_declaration $cnt
            }
        }

        if {[regexp -all {process} $line] == 1} {
            if {[regexp -all { [--]} $line] == 0} {
                incr process_detected
            }
        }

        if {[regexp -all {process} $line] == 0} {
            if {[regexp -all {begin} $line] == 1} {
                if {[regexp -all { [--]} $line] == 0} {
                    if {$process_detected == 0} {
                        if {$inside_subprogram == 1} {
                            set line_last_declaration $cnt
                        } elseif {$inside_subprogram > 1} {
                            puts "TCL: HDL line $cnt: 'end procedure' or 'end function' is missing somewhere above. You can be inside one subprogram only. Quit."
                            quit
                        } elseif {$inside_subprogram < 0} {
                            puts "TCL: HDL line $cnt: 'end procedure' or 'end function' without 'end' keyword detected. Quit."
                            quit
                        } elseif {$inside_subprogram == 0} {
                            # Possible end of declaration part
                            set line_last_declaration $cnt
                            puts "TCL: LAST DECLARATION LINE: $cnt = $line"
                        }
                    }
                }
            }
        }
    }
}
close $slurp_file
puts "TCL: line_last_declaration = $line_last_declaration"


# SCAN DECLARATION PART FOR NEW DECLARATIONS
set cnt 0
set slurp_file [open "$file_to_scan_path" r]
set all_declared_slv_names ""
set all_declared_sl_names ""
# set all_declared_slv_dimensions ""
while {-1 != [gets $slurp_file line]} {
    incr cnt
    # Scan from the beginning to the end of declaration part of the VHDL file
    if {$cnt > $line_declaration_begin} {
        if {$cnt <= $line_last_declaration} {

            # Detect declaration of a type
            if {[regexp -all { t_} $line] != 0} {
                if {[regexp -all { [--]} $line] == 0} {
                    puts "TCL:    type declaration ' t_' detected: line $cnt"
                }
            }

            # Detect declaration of a signal [std_logic_vector]
            if {[regexp -all { signal slv_} $line] != 0} {
                if {[regexp -all {: std_logic_vector} $line] != 0} {
                    if {[regexp -all { [--]} $line] == 0} {
                        set line_nosignal [string map {" signal " ""} $line]
                        set line_nospace [string map {" " ""} $line_nosignal]
                        set signal_name [string range [lindex [split $line_nospace ":"] 0] 0 end]
                        puts "TCL:    signal declaration \[std_logic_vector\] ' slv_' detected: line $cnt; signal_name = $signal_name"
                        append all_declared_slv_names $signal_name "|"
                    }
                }
            }

            # Detect declaration of a signal [std_logic]
            if {[regexp -all { signal sl_} $line] != 0} {
                if {[regexp -all {: std_logic } $line] != 0} {
                    if {[regexp -all { [--]} $line] == 0} {
                        set line_nosignal [string map {" signal " ""} $line]
                        set line_nospace [string map {" " ""} $line_nosignal]
                        set signal_name [string range [lindex [split $line_nospace ":"] 0] 0 end]
                        puts "TCL:    signal declaration \[std_logic\] ' sl_' detected: line $cnt; signal_name = $signal_name"
                        append all_declared_sl_names $signal_name "|"
                    }
                }
            }

        }
    }
}
close $slurp_file
puts "TCL:    all_declared_slv_names = $all_declared_slv_names"
puts "TCL:    all_declared_sl_names = $all_declared_sl_names"


# SCAN ARCHITECTURE FOR NEW DECLARATIONS
proc slv_filter_valid {all_slv_names all_slv_dimensions all_slv_to_downto} {
    # The only signal [to be declared], will be the one with the highest dimension found
    set cnt_name_act 0
    set cnt_dim_act 0
    set all_slv_names_act [string range [lindex [split $all_slv_names "|"] $cnt_name_act] 0 end]
    set all_slv_dimensions_act [string range [lindex [split $all_slv_dimensions "|"] $cnt_dim_act] 0 end]
    set all_slv_to_declare ""
    set slv_name_with_dim_max "abc"
    set slv_to_downto_max "abc"
    # Pick one name
    while {$all_slv_names_act ne ""} {
        # Scan through all the 'all_slv_names_i'
        set cnt_name_i 0
        set cnt_dim_i 0
        set all_slv_names_i [string range [lindex [split $all_slv_names "|"] $cnt_name_i] 0 end]
        set all_slv_dimensions_i [string range [lindex [split $all_slv_dimensions "|"] $cnt_dim_i] 0 end]
        set slv_dimension_max $all_slv_dimensions_act
        set enable_appending 0
        while {$all_slv_names_i ne ""} {
            # Compare if actual dimension is higher than the max dimension, then enable appending
            if {$all_slv_names_act eq $all_slv_names_i} {
                # puts "TCL: $all_slv_names_act eq $all_slv_names_i"
                if {$all_slv_dimensions_i >= $slv_dimension_max} {
                    # puts "TCL: $all_slv_dimensions_i >= $slv_dimension_max"
                    set enable_appending 1
                    set slv_name_with_dim_max $all_slv_names_i
                    set slv_dimension_max $all_slv_dimensions_i
                    set slv_to_downto_max [string range [lindex [split $all_slv_to_downto "|"] $cnt_name_i] 0 end]
                    # puts "TCL: name_max = $slv_name_with_dim_max; dim_max = $slv_dimension_max; to/downto = $slv_to_downto_max"
                }
            }
            incr cnt_name_i
            incr cnt_dim_i
            set all_slv_names_i [string range [lindex [split $all_slv_names "|"] $cnt_name_i] 0 end]
            set all_slv_dimensions_i [string range [lindex [split $all_slv_dimensions "|"] $cnt_dim_i] 0 end]
        }

        # Append only if the signal name is not present in the filtered list after searching through the entire list
        # puts "TCL: enable_appending (before) = $enable_appending $slv_name_with_dim_max $slv_dimension_max $slv_to_downto_max"
        if {$enable_appending == 1} {
            # puts "TCL: enable_appending = $enable_appending"
            if { [string first "$slv_name_with_dim_max" $all_slv_to_declare] == -1} {
                puts "TCL: appending $enable_appending $slv_name_with_dim_max $slv_dimension_max $slv_to_downto_max"
                append all_slv_to_declare $slv_name_with_dim_max "=" $slv_dimension_max "=" $slv_to_downto_max "|"
            }
            set enable_appending 0
        }

        # Prepare new ones
        incr cnt_name_act
        incr cnt_dim_act
        set all_slv_names_act [string range [lindex [split $all_slv_names "|"] $cnt_name_act] 0 end]
        set all_slv_dimensions_act [string range [lindex [split $all_slv_dimensions "|"] $cnt_dim_act] 0 end]
    }

    # puts "TCL: all_slv_to_declare = $all_slv_to_declare"
    return $all_slv_to_declare

}

# Filter out repeating names only to avoid multiple declarations
proc sl_filter_valid {all_sl_names} {
    set all_sl_names_filtered ""
    set cnt 0
    set all_sl_names_i [string range [lindex [split $all_sl_names "|"] $cnt] 0 end]
    while {$all_sl_names_i ne ""} {
        if { [string first "$all_sl_names_i" $all_sl_names_filtered] == -1} {
            puts "TCL: appending $all_sl_names_i"
            append all_sl_names_filtered $all_sl_names_i "|"
        }
        incr cnt
        set all_sl_names_i [string range [lindex [split $all_sl_names "|"] $cnt] 0 end]
    }
    # puts "TCL: all_sl_names_filtered = $all_sl_names_filtered"
    return $all_sl_names_filtered
}


proc module_generic_names_vhdl {module_abs_path module_name} {
    # Find and copy all the generic lines, filter out their names only
    set valid_lines 0
    set end_detected 0
    set cnt 0
    set slurp_file [open "$module_abs_path" r]
    set all_generic_lines ""
    while {-1 != [gets $slurp_file line]} {
        incr cnt
        if {$end_detected == 0} {
            # Detect end, stop reading these lines
            if {[regexp -all { port [(]} $line] == 1} {
                if {$valid_lines == 1} {
                    if {[regexp -all { [--]} $line] == 0} {
                        puts "TCL: End detected line $cnt"
                        set valid_lines 0
                        set end_detected 1
                    }
                }
            }
            if {$valid_lines == 1} {
                if {[regexp -all { [--]} $line] == 0} {
                    if {[regexp -all { [;)]} $line] == 0} {
                        # Show valid line
                        puts "TCL: file '$module_name.vhd' line $cnt: $line"
                        append all_generic_lines $line "|"
                    }
                }
            }
            # Detect start and enable reading these lines (ignore commented lines)
            if {[regexp -all { generic [(]} $line] == 1} {
                if {[regexp -all { [--]} $line] == 0} {
                    if {$end_detected == 0} {
                        puts "TCL: Valid line $cnt"
                        set valid_lines 1
                    }
                }
            }
        }
    }
    close $slurp_file
    set all_generic_lines [string map {";" ""} $all_generic_lines]
    puts "TCL: all_generic_lines = $all_generic_lines"

    set cnt 0
    set all_generic_names_file ""
    set all_generic_lines_i [string range [lindex [split $all_generic_lines "|"] $cnt] 0 end]
    while {$all_generic_lines_i ne ""} {
        set generic_line [string map {" " ""} $all_generic_lines_i]
        set generic_name [string range [lindex [split $generic_line ":"] 0] 0 end]
        append all_generic_names_file $generic_name "|"
        incr cnt
        set all_generic_lines_i [string range [lindex [split $all_generic_lines "|"] $cnt] 0 end]
    }

    puts "TCL: all_generic_names_file = $all_generic_names_file"
    return $all_generic_names_file
}

proc module_generic_lines_vhdl {module_abs_path module_name} {
    # Find and copy all the generic lines, filter out their names only
    set valid_lines 0
    set end_detected 0
    set cnt 0
    set slurp_file [open "$module_abs_path" r]
    set all_generic_lines ""
    while {-1 != [gets $slurp_file line]} {
        incr cnt
        if {$end_detected == 0} {
            # Detect end, stop reading these lines
            if {[regexp -all { port [(]} $line] == 1} {
                if {$valid_lines == 1} {
                    if {[regexp -all { [--]} $line] == 0} {
                        puts "TCL: End detected line $cnt"
                        set valid_lines 0
                        set end_detected 1
                    }
                }
            }
            if {$valid_lines == 1} {
                if {[regexp -all { [--]} $line] == 0} {
                    if {[regexp -all { [;)]} $line] == 0} {
                        # Show valid line
                        puts "TCL: file '$module_name.vhd' line $cnt: $line"
                        append all_generic_lines $line "|"
                    }
                }
            }
            # Detect start and enable reading these lines (ignore commented lines)
            if {[regexp -all { generic [(]} $line] == 1} {
                if {[regexp -all { [--]} $line] == 0} {
                    if {$end_detected == 0} {
                        puts "TCL: Valid line $cnt"
                        set valid_lines 1
                    }
                }
            }
        }
    }
    close $slurp_file
    set all_generic_lines [string map {";" ""} $all_generic_lines]
    puts "TCL: all_generic_lines = $all_generic_lines"

    return $all_generic_lines
}


proc module_input_port_names_vhdl {module_abs_path module_name} {

    # Search for input port names (all types)
    set valid_lines 0
    set end_detected 0
    set cnt 0
    set slurp_file [open "$module_abs_path" r]
    set all_port_names ""
    set all_ports ""
    set all_input_names ""
    set all_input_lines ""
    while {-1 != [gets $slurp_file line]} {
        incr cnt
        if {$end_detected == 0} {
            # Detect end, stop reading these lines
            if {[regexp -all {architecture} $line] == 1} {
                if {[regexp -all {of} $line] == 1} {
                    if {$valid_lines == 1} {
                        if {[regexp -all { [--]} $line] == 0} {
                            puts "TCL: End detected line $cnt"
                            set line_declaration_begin $cnt
                            set valid_lines 0
                            set end_detected 1
                        }
                    }
                }
            }
            if {$valid_lines == 1} {
                if {[regexp -all { [--]} $line] == 0} {
                    if {[regexp -all {:} $line] == 1} {
                        # Show valid port found
                        puts "TCL: file '$module_name.vhd' line $cnt: $line"

                        # Show port name
                        # set range_high [string range [lindex [split $range_changed_delimiter .] 0] 0 end]
                        set line_part [string range [lindex [split $line ":"] 0] 0 end]
                        set port_name [string map {" " ""} $line_part]
                        set port_detail [string range [lindex [split $line ":"] 1] 0 end]
                        puts "TCL: Port name = $port_name"
                        puts "TCL: Port details = $port_detail"

                        set port_line "$port_name :$port_detail"
                        puts "TCL: Joined: $port_line"

                        # Add them to the list of ports (separate by |)
                        append all_port_names $port_name "|"
                        append all_ports $port_line "|"

                        # Find Input ports
                        if {[regexp -all {: in} $line] == 1} {
                            append all_input_names $port_name "|"
                            append all_input_lines $port_line "|"
                        } elseif {[regexp -all {:in} $line] == 1} {
                            append all_input_names $port_name "|"
                            append all_input_lines $port_line "|"
                        }
                    }
                }
            }
            # Detect start and enable reading these lines (ignore commented lines)
            if {[regexp -all {port [(]} $line] == 1} {
                if {[regexp -all { [--]} $line] == 0} {
                    if {$end_detected == 0} {
                        puts "TCL: Valid line $cnt"
                        set valid_lines 1
                    }
                }
            }
        }
    }
    close $slurp_file
    puts "TCL: all_input_names = $all_input_names"
    return $all_input_names

}


proc module_output_port_names_vhdl {module_abs_path module_name} {

    # Search for output port names (all types)
    set valid_lines 0
    set end_detected 0
    set cnt 0
    set slurp_file [open "$module_abs_path" r]
    set all_port_names ""
    set all_ports ""
    set all_output_names ""
    set all_output_lines ""
    while {-1 != [gets $slurp_file line]} {
        incr cnt
        if {$end_detected == 0} {
            # Detect end, stop reading these lines
            if {[regexp -all {architecture} $line] == 1} {
                if {[regexp -all {of} $line] == 1} {
                    if {$valid_lines == 1} {
                        if {[regexp -all { [--]} $line] == 0} {
                            puts "TCL: End detected line $cnt"
                            set line_declaration_begin $cnt
                            set valid_lines 0
                            set end_detected 1
                        }
                    }
                }
            }
            if {$valid_lines == 1} {
                if {[regexp -all { [--]} $line] == 0} {
                    if {[regexp -all {:} $line] == 1} {
                        # Show valid port found
                        puts "TCL: file '$module_name.vhd' line $cnt: $line"

                        # Show port name
                        # set range_high [string range [lindex [split $range_changed_delimiter .] 0] 0 end]
                        set line_part [string range [lindex [split $line ":"] 0] 0 end]
                        set port_name [string map {" " ""} $line_part]
                        set port_detail [string range [lindex [split $line ":"] 1] 0 end]
                        puts "TCL: Port name = $port_name"
                        puts "TCL: Port details = $port_detail"

                        set port_line "$port_name :$port_detail"
                        puts "TCL: Joined: $port_line"

                        # Add them to the list of ports (separate by |)
                        append all_port_names $port_name "|"
                        append all_ports $port_line "|"

                        # Find Output ports
                        if {[regexp -all {: out} $line] == 1} {
                            append all_output_names $port_name "|"
                            append all_output_lines $port_line "|"
                        } elseif {[regexp -all {:out} $line] == 1} {
                            append all_output_names $port_name "|"
                            append all_output_lines $port_line "|"
                        }
                    }
                }
            }
            # Detect start and enable reading these lines (ignore commented lines)
            if {[regexp -all {port [(]} $line] == 1} {
                if {[regexp -all { [--]} $line] == 0} {
                    if {$end_detected == 0} {
                        puts "TCL: Valid line $cnt"
                        set valid_lines 1
                    }
                }
            }
        }
    }
    close $slurp_file
    puts "TCL: all_output_names = $all_output_names"
    return $all_output_names

}



# 4) Detect occurrences of the keywords for re/declaration
set cnt 0
set slurp_file [open "$file_to_scan_path" r]
set all_slv_names ""
set all_slv_dimensions ""
set all_slv_to_downto ""
set all_sl_names ""
while {-1 != [gets $slurp_file line]} {
    incr cnt
    # Search for commands, which are illegal in the declaration part, are in the architecture (and oppositely)
    # Beginning of the declaration part is already stored in 'line_declaration_begin'
    if {$cnt > $line_last_declaration} {

        # Detect the keywords, avoid comments
        # Keywords: procedure, signal, function, constant, subtype, record, type

        # signal sl [ sl_]
        if {[regexp -all { sl_} $line] != 0} {
            if {[regexp -all { [--]} $line] == 0} {
                # puts "TCL: keyword signal std_logic ' sl_' detected: line $cnt: $line"
                puts "TCL: keyword signal \[std_logic\] ' sl_' detected: line $cnt"

                # Parse the line and find the dimension of the array/vector
                if {[regexp -all {<=} $line] < 2} {
                    # Slice the row in two parts
                    set line_part1 [string range [lindex [split $line "<="] 0] 0 end]

                    # Rmemove spaces from line_part1
                    set line_part1_nospace [string map {" " ""} $line_part1]
                    puts "TCL: line_part1_nospace \[std_logic\] = $line_part1_nospace"

                    # Append to all sl names
                    append all_sl_names ${line_part1_nospace} "|"
                }
            }
        }

        # signal slv [ slv_] (if [2d/3d/4d...], then )
        if {[regexp -all { slv_} $line] != 0} {
            if {[regexp -all { [--]} $line] == 0} {
                # puts "TCL: keyword signal std_logic_vector ' slv_' detected: line $cnt: $line"
                puts "TCL: keyword signal \[std_logic_vector\] ' slv_' detected: line $cnt"
                
                # Parse the line and find the dimension of the array/vector
                if {[regexp -all {<=} $line] < 2} {
                    # Slice the row in two parts
                    set line_part1 [string range [lindex [split $line "<="] 0] 0 end]

                    # Rmemove spaces from line_part1
                    set line_part1_nospace [string map {" " ""} $line_part1]
                    puts "TCL: line_part1_nospace = $line_part1_nospace"

                    # Signal Target (line_part1): Check if character '(' is present
                    set cnt_dim 0
                    set to_or_downto ""
                    if { [string first "(" $line_part1_nospace] != -1} {
                        # Trim everything behind the first '(' to get the name
                        set line_part1_signame [string range [lindex [split $line_part1_nospace "("] 0] 0 end]
                        puts "TCL: line_part1_signame = $line_part1_signame"

                        # Check if ')(' is present to detect multidimensional array
                        if { [string first ")(" $line_part1_nospace] != -1} {
                            # Trim the string to create this format: <dimN>|<dimN-1>|...|<dim2>|<dim1>|""
                            set line_part1_corrected [string map {"()" "( )"} $line_part1_nospace]
                            set line_part1_corrected [string map {"downto" " downto "} $line_part1_corrected]
                            set line_part1_trimmed [string map {")(" "|"} $line_part1_corrected]
                            set line_part1_trimmed [string map {")" ""} $line_part1_trimmed]
                            set line_part1_trimmed [string range [lindex [split $line_part1_trimmed "("] 1] 0 end]
                            append line_part1_trimmed "|"
                            puts "TCL: line_part1_trimmed = $line_part1_trimmed"

                            # Count number of occurrences of '|' to determine the dimension
                            set act_dim_string [string range [lindex [split $line_part1_trimmed "|"] $cnt_dim] 0 end]
                            puts "TCL: DEBUG: act_dim_string = $act_dim_string"
                            while {$act_dim_string ne ""} {
                                if {[string first "downto" $act_dim_string] != -1} {
                                    if {$act_dim_string eq "downto)"} {
                                        # If only 'downto' keyword has been given in the last string
                                        set to_or_downto "downto"
                                    } else {
                                        # Assume that full width has been given in the last string
                                        set act_dim_string [string map {";" ""} $act_dim_string]
                                        set to_or_downto $act_dim_string
                                    }
                                } elseif {[string first "to" $act_dim_string] != -1} {
                                    if {$act_dim_string eq "to)"} {
                                        # If only 'to' keyword has been given in the last string ()
                                        set to_or_downto "to"
                                    } else {
                                        # Assume that full width has been given in the last string ()
                                        set to_or_downto $act_dim_string
                                    }
                                } else {
                                    # Not defined if to or downto, let default "downto"
                                    set to_or_downto ""
                                }
                                incr cnt_dim
                                set act_dim_string [string range [lindex [split $line_part1_trimmed "|"] $cnt_dim] 0 end]
                            }
                            puts "TCL: dimension of the array-type signal $line_part1_signame is: $cnt_dim"
                            puts "TCL: to_or_downto = $to_or_downto"
                        } else {

                            # slv is not an slv array
                            incr cnt_dim

                            # Trim the string to create this format: <dimN>|<dimN-1>|...|<dim2>|<dim1>|""
                            # set line_part1
                            set line_part1_corrected [string map {"(to)" "( to )"} $line_part1]
                            set line_part1_corrected [string map {" to " "%to%"} $line_part1_corrected]
                            set line_part1_corrected [string map {"downto" " downto "} $line_part1_corrected]
                            set line_part1_corrected [string map {"(downto)" "( downto )"} $line_part1_corrected]
                            set line_part1_corrected [string map {" downto " "%downto%"} $line_part1_corrected]
                            puts "TCL: line_part1_corrected = $line_part1_corrected"
                            set line_part1_corrected_nospace [string map {" " ""} $line_part1_corrected]
                            set line_part1_corrected_nospace [string map {"%downto%" " downto "} $line_part1_corrected_nospace]
                            set line_part1_corrected_nospace [string map {"%to%" " to "} $line_part1_corrected_nospace]
                            set line_part1_corrected_nospace [string map {";" ""} $line_part1_corrected_nospace]
                            puts "TCL: line_part1_corrected_nospace = $line_part1_corrected_nospace"
                            set line_part1_width_corrected [string map {"$line_part1_signame" ""} $line_part1_corrected_nospace]
                            set chars_cnt_name [string length $line_part1_signame]
                            puts "TCL: chars_cnt_name ($line_part1_signame) = $chars_cnt_name"
                            puts "TCL: line_part1_width_corrected ($line_part1_signame) = '$line_part1_width_corrected'"
                            set line_part1_width_corrected [string range $line_part1_width_corrected [expr $chars_cnt_name+1] end-1]
                            puts "TCL: line_part1_width_corrected ($line_part1_signame) = '$line_part1_width_corrected'"
                            if {$line_part1_width_corrected eq " downto "} {
                                set to_or_downto "downto"
                            } elseif {$line_part1_width_corrected eq " to "} {
                                set to_or_downto "to"
                            } elseif {$line_part1_width_corrected ne ""} {
                                if {[string first " downto " $line_part1_width_corrected] != -1} {
                                    set to_or_downto $line_part1_width_corrected
                                    puts "TCL: to_or_downto (DEBUG) = $to_or_downto"
                                } else {
                                    set to_or_downto $line_part1_width_corrected
                                    puts "TCL: to_or_downto (DEBUG) = $to_or_downto"
                                }
                            } else {
                                set to_or_downto ""
                            }
                            puts "TCL: to_or_downto = $to_or_downto"
                        }
                    }

                    # Save to the list of all reads
                    append all_slv_names ${line_part1_signame} "|"
                    append all_slv_dimensions $cnt_dim "|"
                    append all_slv_to_downto $to_or_downto "|"

                } elseif {[regexp -all {<=} $line] > 1} {
                    puts "TCL: ERROR (scan_module_vhdl.tcl): line $cnt: there are more than two \[<=\] signs in a single line. Quit."
                    quit
                }

            }
        }

        # Constant [CONST_]
        if {[regexp -all { CONST_} $line] != 0} {
            if {[regexp -all { [--]} $line] == 0} {
                # puts "TCL: keyword ' CONST_' detected: line $cnt: $line"
                puts "TCL: keyword ' CONST_' detected: line $cnt"
            }
        }

        # Constant [C_]
        if {[regexp -all { C_} $line] != 0} {
            if {[regexp -all { [--]} $line] == 0} {
                # puts "TCL: keyword ' C_' detected: line $cnt: $line"
                puts "TCL: keyword ' C_' detected: line $cnt"
            }
        }

        # Entity [ entity] (detected as instantiated)
        if {[regexp -all { entity} $line] != 0} {
            if {[regexp -all { [--]} $line] == 0} {
                # puts "TCL: keyword ' entity' detected: line $cnt: $line"
                puts "TCL: keyword ' entity' detected: line $cnt"
            }
        }

        # Instance [ inst_] (needed to be instantiated)
        list all_modules_to_inst_line {}
        list all_modules_filenames {}
        list all_modules_generic_names {}
        list all_modules_generic_lines {}
        list all_modules_input_port_names {}
        list all_modules_output_port_names {}
        if {[regexp -all { inst_} $line] != 0} {
            if {[regexp -all { entity} $line] == 0} {
                if {[regexp -all { [--]} $line] == 0} {
                    # puts "TCL: keyword ' inst_' detected: line $cnt: $line"
                    puts "TCL: keyword ' inst_' detected and instance needed: line $cnt"

                    # Save the number of the line where the the module will be instantiated
                    lappend all_modules_to_inst_line "$cnt"

                    # Preserve spaces
                    set line_spaces [string range [lindex [split $line "inst_"] 0] 0 end]
                    set line_spaces_cnt [string length $line_spaces]
                    puts "TCL: line_spaces_cnt = $line_spaces_cnt"
                    lappend all_modules_line_spaces "$line_spaces"

                    # Rmemove spaces from line_part1
                    set line_nospace [string map {" " ""} $line]
                    set module_name [string map {"inst_" ""} $line_nospace]
                    puts "TCL: module_name = $module_name"

                    # Find the module among all project directories
                    set module_path_vhd [glob -nocomplain -type f */*{$module_name.vhd}* */*/*{$module_name.vhd}*]
                    set module_path_v [glob -nocomplain -type f */*{$module_name.v}* */*/*{$module_name.v}*]
                    set module_path_sv [glob -nocomplain -type f */*{$module_name.sv}* */*/*{$module_name.sv}*]

                    # If VHDL file found, then: get filename, generics, get input port names, get output port names
                    if { [llength $module_path_vhd] == 1 } {

                        lappend all_modules_filenames "$module_name.vhd"

                        set module_abs_path "[file normalize ${origin_dir}/$module_path_vhd]"
                        puts "TCL: module_abs_path = $module_abs_path"

                        set module_generic_names [module_generic_names_vhdl $module_abs_path $module_name]
                        lappend all_modules_generic_names "$module_generic_names"

                        set module_generic_lines [module_generic_lines_vhdl $module_abs_path $module_name]
                        lappend all_modules_generic_lines "$module_generic_lines"

                        set module_input_port_names [module_input_port_names_vhdl $module_abs_path $module_name]
                        lappend all_modules_input_port_names "$module_input_port_names"

                        set module_output_port_names [module_output_port_names_vhdl $module_abs_path $module_name]
                        lappend all_modules_output_port_names "$module_output_port_names"

                        # set module_inputs [module_inputs_vhdl $module_abs_path]
                        # set module_outputs [module_outputs_vhdl $module_abs_path]

                    } else {
                        puts "TCL: ERROR: 1) There may be multiple source files with the name $module_name.vhd. 2) Verilog or SystemVerilog is not supported yet. Make sure there is only one file with the same name in all project directories. Quit."
                        quit
                    }

                    # set_property "file_type" SystemVerilog [get_files $file_name]
                    # set_property "library" $library_name [get_files ${abs_path_to_filedir}/$file_name]
                    puts "TCL: set file_library_src = $file_library_src"

                }
            }
        }
    }
}
close $slurp_file




# Save the entire file to memory
set list_all_lines {}
set cnt_max_lines_from1 1
set slurp_file [open "$file_to_scan_path" r]
while {-1 != [gets $slurp_file line]} {
    lappend list_all_lines "$line"
    incr cnt_max_lines_from1
}
close $slurp_file

# WRITING TO THE OUTPUT FILE
set cnt_line 1
set dont_print_next_line 0
set write_file [open "$file_to_scan_path" w]
# set file_to_scan_path_test "[file normalize ${origin_dir}/helpers/test_make_declare.vhd]"
# set write_file [open "$file_to_scan_path_test" w]
set last_line [lindex $list_all_lines end]
# puts $write_file "-- TEST:"
foreach line $list_all_lines {
    if {$cnt_line == [expr $cnt_max_lines_from1-1]} {
        puts "-----END-----: $cnt_line == [expr $cnt_max_lines_from1-1]"
        puts -nonewline $write_file "$line"
    } else {
        # If you want to replace [ inst_] keyword, for instance. (If you don't want to leave it in the file)
        if {$dont_print_next_line == 0} {
            puts $write_file "$line"
        } else {
            set dont_print_next_line 0
        }
        # Declare new missing generics from known new entities to be instantiated in architecture
        if {$cnt_line < $line_declaration_begin} {
            if {$cnt_line == $line_insert_generics} {
                # puts $write_file "            -- INSERT MISSING DECLARATIONS OF GENERICS HERE --"
                source [file normalize ${origin_dir}]/tcl/generic/make_declare/declare_missing_generics.tcl
            }
        }
        # Declare new signals right at the beginning of the declaration part
        if {$cnt_line == $line_declaration_begin} {
            puts $write_file ""
            # puts $write_file "        -- INSERT MISSING DECLARATIONS OF SIGNALS HERE --"
            source [file normalize ${origin_dir}]/tcl/generic/make_declare/declare_missing_signals.tcl
        }
        # Check if next line will be instantiation of an entity, then skip printing this line
        if {$cnt_line >= $line_last_declaration} {
            foreach line_num_to_inst $all_modules_to_inst_line {
                if {[expr $cnt_line+1] == $line_num_to_inst} {
                    set dont_print_next_line 1
                }
            }
        }
        # Print the instantiation of the entity
        foreach line_num_to_inst $all_modules_to_inst_line {
            if {$cnt_line == $line_num_to_inst} {
                # puts $write_file "        -- INSERT MISSING INSTANTIATION OF AN ENTITY HERE --"
                source [file normalize ${origin_dir}]/tcl/generic/make_declare/inst_missing_entity.tcl
            }
        }
    }
    incr cnt_line
}
close $write_file