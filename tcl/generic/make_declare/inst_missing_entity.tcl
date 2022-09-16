# Reconstruct instantiation of the entity
# Instantiate missing entities
set cnt 0
set delimiter "|"
puts "TCL: MISSING INSTANTIATIONS"
foreach line_num_to_inst $all_modules_to_inst_line {

    puts "TCL: line_num_to_inst = $line_num_to_inst"
    if {$cnt_line == $line_num_to_inst} {
        set entity_preserve_spaces [lindex $all_modules_line_spaces $cnt]
        set entity_module_filename [lindex $all_modules_filenames $cnt]
        set inst_module_name [string range [lindex [split $entity_module_filename "."] 0] 0 end]
        set list_entity_module_filename [string_delimiters_to_list $entity_module_filename $delimiter]
        puts "TCL:${entity_preserve_spaces}-- Instantiation of the module $entity_module_filename"
        puts $write_file "${entity_preserve_spaces}-- Instantiation of the module $entity_module_filename"
        puts "TCL:${entity_preserve_spaces}inst_${inst_module_name} : entity ${file_library_src}.${inst_module_name}"
        puts $write_file "${entity_preserve_spaces}inst_${inst_module_name} : entity ${file_library_src}.${inst_module_name}"

        set entity_generic_names [lindex $all_modules_generic_names $cnt]
        set list_entity_generic_names [string_delimiters_to_list $entity_generic_names $delimiter]
        set last_generic_name [lindex $list_entity_generic_names end]
        if {$entity_generic_names ne ""} {

            puts "TCL:${entity_preserve_spaces}generic map ("
            puts $write_file "${entity_preserve_spaces}generic map ("

            foreach g $list_entity_generic_names {
                if {$g ne $last_generic_name} {
                    puts "TCL:${entity_preserve_spaces}    $g  => $g,"
                    puts $write_file "${entity_preserve_spaces}    $g  => $g,"
                } else {
                    puts "TCL:${entity_preserve_spaces}    $g  => $g"
                    puts $write_file "${entity_preserve_spaces}    $g  => $g"
                }
            }
            puts "TCL:${entity_preserve_spaces})"
            puts $write_file "${entity_preserve_spaces})"
        }

        set entity_input_port_names [lindex $all_modules_input_port_names $cnt]
        set list_entity_input_port_names [string_delimiters_to_list $entity_input_port_names $delimiter]
        puts "TCL:${entity_preserve_spaces}port map ("
        puts $write_file "${entity_preserve_spaces}port map ("
        if {$entity_input_port_names ne ""} {
            puts "TCL:${entity_preserve_spaces}    -- input ports:"
            puts $write_file "${entity_preserve_spaces}    -- input ports:"
            foreach i $list_entity_input_port_names {
                puts "TCL:${entity_preserve_spaces}    $i  => ,"
                puts $write_file "${entity_preserve_spaces}    $i  => ,"
            }
        }

        set entity_output_port_names [lindex $all_modules_output_port_names $cnt]
        set list_entity_output_port_names [string_delimiters_to_list $entity_output_port_names $delimiter]
        set last_output_port_name [lindex $list_entity_output_port_names end]
        if {$entity_output_port_names ne ""} {
            puts "TCL:${entity_preserve_spaces}    -- output ports:"
            puts $write_file "${entity_preserve_spaces}    -- output ports:"
            foreach o $list_entity_output_port_names {
                if {$o ne $last_output_port_name} {
                    puts "TCL:${entity_preserve_spaces}    $o => ,"
                    puts $write_file "${entity_preserve_spaces}    $o => ,"
                } else {
                    puts "TCL:${entity_preserve_spaces}    $o => "
                    puts $write_file "${entity_preserve_spaces}    $o => "
                }
            }
        }
        puts "TCL:${entity_preserve_spaces});"
        puts $write_file "${entity_preserve_spaces});"
    }
    incr cnt
}