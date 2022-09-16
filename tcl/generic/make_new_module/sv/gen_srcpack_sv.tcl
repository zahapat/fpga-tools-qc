# This file generates a template of a HDL source file package (VHDL)

puts $new_file_src_pack ""
puts $new_file_src_pack "    \/\/ ${name_file}_pack.${suffix_file}: <brief description>"
puts $new_file_src_pack "    \/\/ Engineer: $engineer_name"
puts $new_file_src_pack "    \/\/ Email: $email_addr"
set clock_seconds [clock seconds]
set act_date [clock format $clock_seconds -format %D]
puts $new_file_src_pack "    \/\/ Created: $act_date"
puts $new_file_src_pack ""
puts -nonewline $new_file_src_pack "    "