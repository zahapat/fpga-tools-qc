# This file generates a formal template for README.txt file

# Detect language
if {$suffix_file eq "vhd"} {
    set lang "VHDL"
} elseif {$suffix_file eq "sv"} {
    set lang "SystemVerilog"
} else {
    set lang "Verilog"
}

# Actual date
set clock_seconds [clock seconds]
set act_date [clock format $clock_seconds -format %D]

puts $new_file_readme ""
puts $new_file_readme "    Name: ${name_file}.${suffix_file}"
puts $new_file_readme "    Language: $lang"
puts $new_file_readme "    Engineer: $engineer_name"
puts $new_file_readme "    Email: $email_addr"
puts $new_file_readme "    Date of creation: $act_date"
if {$lang ne "vhd"} {
    puts $new_file_readme "    Library of the source file(s): work"
    puts $new_file_readme "    Library of the simulation file(s): work"
} else {
    puts $new_file_readme "    Library of the source file(s): $file_library_src"
    puts $new_file_readme "    Library of the simulation file(s): $file_library_sim"
}
puts $new_file_readme ""
puts $new_file_readme "    Description of this module: "
puts $new_file_readme ""
puts $new_file_readme "    How to connect this module: "