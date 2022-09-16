# This TCL script re/creates an RTL wrapper module for either ZYNQ or pure RTL design
# Is used within "make_probes.tcl" file.
puts "TCL: Creating module './helpers/wrapper_ila.vhd'"

# Details of the wrapped module
set compiled_to_library "work"
set wrapped_module_name [get_property TOP [current_fileset]]
puts "TCL: wrapped_module_name = $wrapped_module_name"

# 1 Copy everything from the beginning of the file, ending by beginning of the module
set cnt 0
set slurp_file [open "$top_file_path" r]
set end_detected 0
set valid_lines 1
set all_lines_beginning ""
while {(-1 != [gets $slurp_file line]) && ($end_detected == 0)} {
    incr cnt
    if {$end_detected == 0} {
        # Detect end
        if {[regexp -all {entity} $line] == 1} {
            if {[regexp -all {is} $line] == 1} {
                if {$valid_lines == 1} {
                    if {[regexp -all { [--]} $line] == 0} {
                        puts "TCL: End detected line $cnt."
                        set valid_lines 0
                        set end_detected 1
                    }
                }
            }
        }
        # Detect valid lines and read these lines (ignore commented lines)
        if {$valid_lines == 1} {
            # Read only uncommented lines
            if {[regexp -all { [--]} $line] == 0} {
                # Show valid line
                puts "TCL: file '$wrapped_module_name' line $cnt: $line"

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

# 2 Copy all the generics
set valid_lines 0
set end_detected 0
set cnt 0
set slurp_file [open "$top_file_path" r]
set all_generic_lines ""
set all_generic_names ""
set all_generic_details ""
while {-1 != [gets $slurp_file line]} {
    incr cnt
    if {$end_detected == 0} {
        # Detect end
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
                    if {[regexp -all {RST_HIGH} $line] == 0} {
                        # Show valid line
                        puts "TCL: file '$wrapped_module_name' line $cnt: $line"

                        append all_generic_lines $line "|"
                    }
                }
            }
        }
        # Detect start and read these lines (ignore commented lines)
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
set all_generic_lines [string map {";" ""} $all_generic_lines]
puts "TCL: all_generic_lines = $all_generic_lines"
close $slurp_file


# 3 Search for input ports (Standard Logic Vector / Standard Logic)
set valid_lines 0
set end_detected 0
set cnt 0
set slurp_file [open "$top_file_path" r]
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
        # Detect end
        if {[regexp -all {architecture} $line] == 1} {
            if {[regexp -all {of} $line] == 1} {
                if {$valid_lines == 1} {
                    if {[regexp -all { [--]} $line] == 0} {
                        puts "TCL: End detected line $cnt"
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
                    puts "TCL: file '$wrapped_module_name' line $cnt: $line"

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
        # Detect start and read these lines (ignore commented lines)
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

# Print all ports
puts "TCL: all_port_names = $all_port_names"
puts "TCL: all_ports = $all_ports"
puts "TCL: all_input_names = $all_input_names"
puts "TCL: all_output_names = $all_output_names"
puts "TCL: all_input_lines = $all_input_lines"
puts "TCL: all_output_lines = $all_output_lines"
puts "TCL: all_input_widths = $all_input_widths"
puts "TCL: all_input_widths_total_resolved = $all_input_widths_total_resolved"
puts "TCL: all_output_widths_total_resolved = $all_output_widths_total_resolved"


# Details for the wrapper
set output_ports_cnt 1
#     Generics (all are based on inputs and outputs to the TOP module)
set rst_high 1
set probe_2_width 2
set probe_3_width 1

# Open or create a file
set out_file_path "${origin_dir}/helpers/wrapper_ila.vhd"
set new_file [open $out_file_path "w"]

# Write desired content to the file
set cnt 0
set all_lines_beginning_i [string range [lindex [split $all_lines_beginning "|"] $cnt] 0 end]
while {$all_lines_beginning_i ne ""} {
    puts -nonewline $new_file "$all_lines_beginning_i\n"
    incr cnt
    set all_lines_beginning_i [string range [lindex [split $all_lines_beginning "|"] $cnt] 0 end]
}
puts -nonewline $new_file "    entity wrapper_ila is\n"
puts -nonewline $new_file "        generic (\n"
set cnt 0
set all_generic_lines_i [string range [lindex [split $all_generic_lines "|"] $cnt] 0 end]
while {$all_generic_lines_i ne ""} {
    puts -nonewline $new_file "$all_generic_lines_i;\n"
    incr cnt
    set all_generic_lines_i [string range [lindex [split $all_generic_lines "|"] $cnt] 0 end]
}
if {$all_generic_lines eq ""} {
    puts -nonewline $new_file "            RST_HIGH : std_logic := '$rst_high;'\n"
} else {
    puts -nonewline $new_file "            RST_HIGH : std_logic := '$rst_high'\n"
}
puts -nonewline $new_file "        );\n"
puts -nonewline $new_file "        port (\n"
puts -nonewline $new_file "            -- Inputs\n"
puts -nonewline $new_file "            in_zynq_clk  : in std_logic;\n"
puts -nonewline $new_file "            in_rst       : in std_logic;\n"
puts -nonewline $new_file "                -- To pass input data to the probed module\n"
set cnt 0
set line_input_i [string range [lindex [split $all_input_lines "|"] $cnt] 0 end]
while {$line_input_i ne ""} {
    set input_i_lower [string tolower $line_input_i]
    puts -nonewline $new_file "            -- $input_i_lower\n"
    incr cnt
    set line_input_i [string range [lindex [split $all_input_lines "|"] $cnt] 0 end]
}
puts -nonewline $new_file "\n"
puts -nonewline $new_file "            -- Output probes to ILA\n"
puts -nonewline $new_file "            probe0_in_zynq : out std_logic;\n"
puts -nonewline $new_file "            probe1_in_rst : out std_logic;\n"
puts -nonewline $new_file "                -- To pass input data to the probed module\n"
set index_hdl_probe 2
set cnt 0
set line_input_i [string range [lindex [split $all_input_lines "|"] $cnt] 0 end]
while {$line_input_i ne ""} {
    set input_i_lower [string tolower $line_input_i]
    set input_i_lower [string map {": in " ": out "} $input_i_lower]
    set input_i_lower [string map {":in " ":out "} $input_i_lower]
    puts -nonewline $new_file "            probe${index_hdl_probe}_$input_i_lower\n"
    incr cnt
    incr index_hdl_probe
    set line_input_i [string range [lindex [split $all_input_lines "|"] $cnt] 0 end]
}
puts -nonewline $new_file "                -- Outputs from the probed module\n"
set cnt 0
set line_output_i [string range [lindex [split $all_output_lines "|"] $cnt] 0 end]
puts "TCL: ADDING LINE $line_output_i"
while {$line_output_i ne ""} {
    set output_i_lower [string tolower $line_output_i]
    if {[string range [lindex [split $all_output_lines "|"] $cnt+1] 0 end] eq ""} {
        set line_output_i_nosemicolon [string map {";" ""} $output_i_lower]
        puts -nonewline $new_file "            probe${index_hdl_probe}_$line_output_i_nosemicolon\n"
    } else {
        puts -nonewline $new_file "            probe${index_hdl_probe}_$output_i_lower\n"
    }
    incr cnt
    incr index_hdl_probe
    set line_output_i [string range [lindex [split $all_output_lines "|"] $cnt] 0 end]
    puts "TCL: ADDING LINE $line_output_i"
}
puts -nonewline $new_file "        );\n"
puts -nonewline $new_file "    end wrapper_ila;\n"
puts -nonewline $new_file "\n"
puts -nonewline $new_file "    architecture rtl of wrapper_ila is\n"
puts -nonewline $new_file "\n"

set cnt 0
set input_name_i [string range [lindex [split $all_input_names "|"] $cnt] 0 end]
while {$input_name_i ne ""} {
    set all_input_widths_total_resolved_i [string range [lindex [split $all_input_widths_total_resolved "|"] $cnt] 0 end]
    set input_name_i_upper [string toupper $input_name_i]
    set input_name_i_lower [string tolower $input_name_i]
    set input_width_i [string range [lindex [split $all_input_widths "|"] $cnt] 0 end]
    set input_width_total_i [string range [lindex [split $all_input_widths_total "|"] $cnt] 0 end]
    puts -nonewline $new_file "        -- Emulate input $input_name_i\n"
    if {$input_width_i == "0"} {
        puts -nonewline $new_file "        subtype st_width_$input_name_i_lower is natural range 1 downto 0;\n"
    } else {
        puts -nonewline $new_file "        subtype st_width_$input_name_i_lower is natural range 1+$input_width_i;\n"
    }
    # puts -nonewline $new_file "        constant CONST_LENGTH_$input_name_i_upper : integer := $input_width_total_i;\n"
    puts -nonewline $new_file "        constant CONST_LENGTH_$input_name_i_upper : integer := 1+$all_input_widths_total_resolved_i;\n"
    puts -nonewline $new_file "        signal slv_$input_name_i_lower : std_logic_vector(CONST_LENGTH_$input_name_i_upper-1 downto 0) := std_logic_vector(to_unsigned(1, CONST_LENGTH_$input_name_i_upper));\n"
    puts -nonewline $new_file "\n"
    incr cnt
    set input_name_i [string range [lindex [split $all_input_names "|"] $cnt] 0 end]
}
puts -nonewline $new_file "    begin\n"
puts -nonewline $new_file "\n"
puts -nonewline $new_file "        --------------------\n"
puts -nonewline $new_file "        -- Emulate Inputs --\n"
puts -nonewline $new_file "        --------------------\n"
set cnt 0
set input_name_i [string range [lindex [split $all_input_names "|"] $cnt] 0 end]
while {$input_name_i ne ""} {
    set input_name_i [string range [lindex [split $all_input_names "|"] $cnt] 0 end]
    set input_name_i_lower [string tolower $input_name_i]
    set line_input_i [string range [lindex [split $all_input_lines "|"] $cnt] 0 end]
    set input_width_i [string range [lindex [split $all_input_widths "|"] $cnt] 0 end]
    set input_width_total_i [string range [lindex [split $all_input_widths_total "|"] $cnt] 0 end]
    puts -nonewline $new_file "        proc_emul_${input_name_i_lower} : process(in_zynq_clk)\n"
    puts -nonewline $new_file "        begin\n"
    puts -nonewline $new_file "            if rising_edge(in_zynq_clk) then\n"
    puts -nonewline $new_file "                if in_rst = RST_HIGH then\n"
    puts -nonewline $new_file "                    slv_${input_name_i_lower}(CONST_LENGTH_$input_name_i_upper-1 downto 0) <= std_logic_vector(to_unsigned(1, CONST_LENGTH_$input_name_i_upper));\n"
    puts -nonewline $new_file "                else\n"
    puts -nonewline $new_file "                    slv_${input_name_i_lower}(CONST_LENGTH_$input_name_i_upper-1 downto 0) <= slv_${input_name_i_lower}(CONST_LENGTH_$input_name_i_upper-2 downto 0) & slv_${input_name_i_lower}(CONST_LENGTH_$input_name_i_upper-1);\n"
    puts -nonewline $new_file "                end if;\n"
    puts -nonewline $new_file "            end if;\n"
    puts -nonewline $new_file "        end process;\n"
    puts -nonewline $new_file "\n"
    incr cnt
    set input_name_i [string range [lindex [split $all_input_names "|"] $cnt] 0 end]
}
puts -nonewline $new_file "        ------------------------------------------------------------\n"
puts -nonewline $new_file "        -- INPUT PROBES 0-2: Probe Inputs from $wrapped_module_name\n"
puts -nonewline $new_file "        ------------------------------------------------------------\n"
puts -nonewline $new_file "        probe0_in_zynq <= in_zynq_clk;\n"
puts -nonewline $new_file "        probe1_in_rst <= in_rst;\n"
set index_hdl_probe 2
set cnt 0
set input_name_i [string range [lindex [split $all_input_names "|"] $cnt] 0 end]
while {$input_name_i ne ""} {
    set input_name_i [string range [lindex [split $all_input_names "|"] $cnt] 0 end]
    set input_name_i_lower [string tolower $input_name_i]
    set input_name_i_upper [string toupper $input_name_i]
    set all_input_widths_total_resolved_i [string range [lindex [split $all_input_widths_total_resolved "|"] $cnt] 0 end]
    if {$all_input_widths_total_resolved_i == 1} {
        puts -nonewline $new_file "        probe${index_hdl_probe}_$input_name_i_lower <= slv_${input_name_i_lower}(0);\n"
    } else {
        puts -nonewline $new_file "        probe${index_hdl_probe}_$input_name_i_lower <= slv_${input_name_i_lower}(slv_${input_name_i_lower}'high-1 downto 0);\n"
    }
    incr cnt
    incr index_hdl_probe
    set input_name_i [string range [lindex [split $all_input_names "|"] $cnt] 0 end]
}
puts -nonewline $new_file "\n"
puts -nonewline $new_file "        ------------------------------------------------------------\n"
puts -nonewline $new_file "        -- OUTPUT PROBES 3-__: Probe Outputs from $wrapped_module_name\n"
puts -nonewline $new_file "        ------------------------------------------------------------\n"
puts -nonewline $new_file "        inst_$wrapped_module_name : entity $compiled_to_library.$wrapped_module_name\n"
puts -nonewline $new_file "        port map (\n"
puts -nonewline $new_file "                -- Emulated inputs to the probed module\n"
set cnt 0
set input_name_i [string range [lindex [split $all_input_names "|"] $cnt] 0 end]
while {$input_name_i ne ""} {
    set input_name_i [string range [lindex [split $all_input_names "|"] $cnt] 0 end]
    set input_name_i_lower [string tolower $input_name_i]
    set all_input_widths_total_resolved_i [string range [lindex [split $all_input_widths_total_resolved "|"] $cnt] 0 end]
    if {$all_input_widths_total_resolved_i == 1} {
        puts -nonewline $new_file "            $input_name_i => slv_${input_name_i_lower}(0),\n"
    } else {
        puts -nonewline $new_file "            $input_name_i => slv_${input_name_i_lower}(slv_${input_name_i_lower}'high-1 downto 0),\n"
    }
    incr cnt
    set input_name_i [string range [lindex [split $all_input_names "|"] $cnt] 0 end]
}

puts -nonewline $new_file "                -- Outputs from the probed module\n"
set cnt 0
set output_name_i [string range [lindex [split $all_output_names "|"] $cnt] 0 end]
while {$output_name_i ne ""} {
    set output_name_i_lower [string tolower $output_name_i]
    if {[string range [lindex [split $all_output_names "|"] [expr ($cnt+1)]] 0 end] eq ""} {
        puts -nonewline $new_file "            $output_name_i => probe${index_hdl_probe}_$output_name_i_lower\n"
    } else {
        puts -nonewline $new_file "            $output_name_i => probe${index_hdl_probe}_$output_name_i_lower,\n"
    }
    incr cnt
    incr index_hdl_probe
    set output_name_i [string range [lindex [split $all_output_names "|"] $cnt] 0 end]
}
puts -nonewline $new_file "        );\n"
puts -nonewline $new_file "\n"
puts -nonewline $new_file "    end architecture;"

puts "TCL: Total ports to ILA: $index_hdl_probe"

close $new_file