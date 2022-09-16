# Find the directory of the current project
set origin_dir "."
if { [info exists ::origin_dir_loc] } {
    set origin_dir $::origin_dir_loc
}

# Get TCL Command-line arguments
puts "TCL: Get TCL Command-line arguments"
set arguments_cnt 2
if { $::argc == $arguments_cnt } {
    # 1. Name
    set file_to_scan [string trim [lindex $::argv 0] ]
    set file_to_scan [string tolower $file_to_scan]
    puts "TCL: Argument 1 lowercase: '$file_to_scan'"
    set name_file [string range [lindex [split $file_to_scan "."] 0] 0 end]
    puts "TCL: Name = '$name_file'"
    set suffix_file [string range [lindex [split $file_to_scan "."] 1] 0 end]
    puts "TCL: Suffix (language) = '$suffix_file'"

    # 2. Library for sources
    set file_library_src [string trim [lindex $::argv 1] ]
    set file_library_src [string tolower $file_library_src]
    puts "TCL: Argument 2 lowercase: '$file_library_src'"

}

# Check if the module already exists, otherwise quit
set module_exist_check [glob -type f */*{$file_to_scan}* */*/*{$file_to_scan}*]
if {$module_exist_check eq ""} {
    puts "TCL: ERROR: Module with the name '$file_to_scan' does not exist. Run 'make new_module' with respective arguments to create it."
    quit
} else {
    puts "TCL: Module with the name '$file_to_scan' exists: $module_exist_check"
}
set file_to_scan_path "[file normalize ${origin_dir}/$module_exist_check]"

# Check supported language, then run make_declare.tcl
if {$suffix_file eq "vhd"} {
    puts "TCL: [file normalize ${origin_dir}]/tcl/generic/make_declare/scan_module_vhdl.tcl"
    source [file normalize ${origin_dir}]/tcl/generic/make_declare/scan_module_vhdl.tcl
} elseif {$suffix_file eq "sv"} {
    puts "TCL: Language $suffix_file is not supported."
} elseif {$suffix_file eq "v"} {
    puts "TCL: Language $suffix_file is not supported."
} else {
    puts "TCL: Language $suffix_file has not been recognised. Quit."
    quit
}