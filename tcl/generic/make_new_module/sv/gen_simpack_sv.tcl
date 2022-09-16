# This file generates a template of a HDL simulation file package (VHDL)

puts $new_file_sim_pack ""
puts $new_file_sim_pack "    \/\/ ${name_file}_pack_tb.${suffix_file}: <brief description>"
puts $new_file_sim_pack "    \/\/ Engineer: $engineer_name"
puts $new_file_sim_pack "    \/\/ Email: $email_addr"
set clock_seconds [clock seconds]
set act_date [clock format $clock_seconds -format %D]
puts $new_file_sim_pack "    \/\/ Created: $act_date"
puts $new_file_sim_pack ""
puts -nonewline $new_file_sim_pack "   "