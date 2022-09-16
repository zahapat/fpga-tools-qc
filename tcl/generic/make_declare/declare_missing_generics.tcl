# Declare missing generics to fully instantiate an entity

proc print_string_in_lines {str delimiter} {
    set cnt 0
    set str_i [string range [lindex [split $str "$delimiter"] $cnt] 0 end]
    while {$str_i ne ""} {
        puts "TCL (print_string_in_lines): '$str_i'"
        incr cnt
        set str_i [string range [lindex [split $str "$delimiter"] $cnt] 0 end]
    }
}
proc string_delimiters_to_list {str delimiter} {
    set cnt 0
    set list_append {}
    set str_i [string range [lindex [split $str "$delimiter"] $cnt] 0 end]
    while {$str_i ne ""} {
        lappend list_append $str_i
        incr cnt
        set str_i [string range [lindex [split $str "$delimiter"] $cnt] 0 end]
    }
    return $list_append
}

set cnt 0
set delimiter "|"
puts "TCL: MISSING DECLARATIONS OF NEW GENERICS"

# Check if all strings are empty or if there is something new to add, then add a new region as well, if it does not exist yet
set nothing_to_declare 1
foreach line_num_to_inst $all_modules_to_inst_line {

    puts "TCL: line_num_to_inst = $line_num_to_inst"

    set entity_module_filename [lindex $all_modules_filenames $cnt]
    set entity_generic_lines [lindex $all_modules_generic_lines $cnt]
    set list_entity_generic_lines [string_delimiters_to_list $entity_generic_lines $delimiter]
    set last_generic_list [lindex $list_entity_generic_lines end]
    foreach i $list_entity_generic_lines {
        if {$i ne ""} {
            set nothing_to_declare 0
        }
    }
}
puts "TCL: nothing_to_declare = $nothing_to_declare"

if {$flag_generic_region_exists == 0} {
    if {$nothing_to_declare == 0} {
        puts $write_file "        generic ("
    }
}

foreach line_num_to_inst $all_modules_to_inst_line {

    puts "TCL: line_num_to_inst = $line_num_to_inst"

    set entity_module_filename [lindex $all_modules_filenames $cnt]
    set entity_generic_lines [lindex $all_modules_generic_lines $cnt]
    set list_existing_generics [string_delimiters_to_list $all_generic_names $delimiter]
    set list_entity_generic_lines [string_delimiters_to_list $entity_generic_lines $delimiter]
    set last_generic_list [lindex $list_entity_generic_lines end]
    if {$entity_generic_lines ne ""} {
        puts "TCL:            -- Generics of the module $entity_module_filename"
    }
    # TODO: Skip declarations of already existing generics
    puts "TCL: all_generic_names = $all_generic_names"
    foreach i $list_entity_generic_lines {
        set skip_declaration_generics 0
        foreach u $list_existing_generics {
            if { [string first " $u " $i] != -1} {
                puts "TCL: Skipping declaration of '$i' ('$u' is already declared)"
                set skip_declaration_generics 1
            }
        }

        if {$skip_declaration_generics == 0} {
            if {$i ne $last_generic_list} {
                puts "TCL:$i;"
                puts $write_file "$i;"
            } else {
                puts "TCL:$i"
                puts $write_file "$i"
            }
        }
    }

    incr cnt
}

if {$flag_generic_region_exists == 0} {
    if {$nothing_to_declare == 0} {
        puts $write_file "        );"
    }
}