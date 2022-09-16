# --------------------------------------------------------------------------------------
# Reconstruct the declaration of all sl signals and append these lines one after another
# Check all all_sl_names
puts "TCL: all_sl_names = $all_sl_names"
set all_sl_names_filtered [sl_filter_valid $all_sl_names]
puts "TCL: all_sl_names_filtered = $all_sl_names_filtered"
set cnt_name_act 0
set all_sl_names_filtered_i [string range [lindex [split $all_sl_names_filtered "|"] $cnt_name_act] 0 end]
while {$all_sl_names_filtered_i ne ""} {
    # Check if the SL has not been found among declared SLs yet. If not found, declare it.
    if { [string first "$all_sl_names_filtered_i" $all_declared_sl_names] == -1} {
        puts "TCL: \[to be declared\] missing sl: signal ${all_sl_names_filtered_i} : std_logic := '0';"
        puts $write_file "        signal ${all_sl_names_filtered_i} : std_logic := '0';"
    }
    incr cnt_name_act
    set all_sl_names_filtered_i [string range [lindex [split $all_sl_names_filtered "|"] $cnt_name_act] 0 end]
}


# Reconstruct the declaration of all missing slv signals and append these lines one after another
# List all valid missing slv:
set all_slv_to_declare [slv_filter_valid $all_slv_names $all_slv_dimensions $all_slv_to_downto]
puts "TCL: all_slv_to_declare = $all_slv_to_declare"
# List all [declared] slv:
puts "TCL: all_declared_slv_names = $all_declared_slv_names"
set cnt_name_act 0
set all_slv_to_declare_i [string range [lindex [split $all_slv_to_declare "|"] $cnt_name_act] 0 end]
while {$all_slv_to_declare_i ne ""} {

    set all_slv_to_declare_name_i [string range [lindex [split $all_slv_to_declare_i "="] 0] 0 end]
    set all_slv_to_declare_dimension_i [string range [lindex [split $all_slv_to_declare_i "="] 1] 0 end]
    set all_slv_to_declare_to_downto_i [string range [lindex [split $all_slv_to_declare_i "="] 2] 0 end]

    # Check if the SLV has not been found among declared SLVs yet. If not found, declare it.
    if { [string first "$all_slv_to_declare_name_i" $all_declared_slv_names] == -1} {
        if {$all_slv_to_declare_dimension_i > 1} {
            # If an array has been detected
            for {set d 2} {$d < [expr $all_slv_to_declare_dimension_i+1]} {incr d} {
                # First row of declaration
                if {$d == 2} {
                    # Insert to or downto
                    if {$all_slv_to_declare_to_downto_i eq "downto"} {
                        puts "TCL: \[to be declared\] missing slv: type t_${all_slv_to_declare_name_i}_${d}d is array(_ $all_slv_to_declare_to_downto_i 0) of std_logic_vector(_ $all_slv_to_declare_to_downto_i 0);"
                        puts $write_file "        type t_${all_slv_to_declare_name_i}_${d}d is array(_ $all_slv_to_declare_to_downto_i 0) of std_logic_vector(_ $all_slv_to_declare_to_downto_i 0);"
                    } elseif {$all_slv_to_declare_to_downto_i eq "to"} {
                        puts "TCL: \[to be declared\] missing slv: type t_${all_slv_to_declare_name_i}_${d}d is array(0 $all_slv_to_declare_to_downto_i ) of std_logic_vector(0 $all_slv_to_declare_to_downto_i _);"
                        puts $write_file "        type t_${all_slv_to_declare_name_i}_${d}d is array(0 $all_slv_to_declare_to_downto_i ) of std_logic_vector(0 $all_slv_to_declare_to_downto_i _);"
                    } elseif {$all_slv_to_declare_to_downto_i ne ""} {
                        if {$all_slv_to_declare_to_downto_i ne " "} {
                            if { [string first " to " $all_slv_to_declare_to_downto_i] != -1} {
                                puts "TCL: \[to be declared\] missing st:  subtype st_${all_slv_to_declare_name_i}_${d}d is integer range 0 to _;"
                                puts "TCL: \[to be declared\] missing slv: type t_${all_slv_to_declare_name_i}_${d}d is array(st_${all_slv_to_declare_name_i}_${d}d) of std_logic_vector($all_slv_to_declare_to_downto_i);"
                                puts $write_file "        subtype st_${all_slv_to_declare_name_i}_${d}d is integer range 0 to _;"
                                puts $write_file "        type t_${all_slv_to_declare_name_i}_${d}d is array(st_${all_slv_to_declare_name_i}_${d}d) of std_logic_vector($all_slv_to_declare_to_downto_i);"
                            } else {
                                puts "TCL: \[to be declared\] missing st:  subtype st_${all_slv_to_declare_name_i}_${d}d is integer range _ downto 0;"
                                puts "TCL: \[to be declared\] missing slv: type t_${all_slv_to_declare_name_i}_${d}d is array(st_${all_slv_to_declare_name_i}_${d}d) of std_logic_vector($all_slv_to_declare_to_downto_i);"
                                puts $write_file "        subtype st_${all_slv_to_declare_name_i}_${d}d is integer range _ downto 0;"
                                puts $write_file "        type t_${all_slv_to_declare_name_i}_${d}d is array(st_${all_slv_to_declare_name_i}_${d}d) of std_logic_vector($all_slv_to_declare_to_downto_i);"
                            }
                        }
                    } else {
                        puts "TCL: \[to be declared\] missing st:  subtype st_${all_slv_to_declare_name_i}_1d is integer range _ downto 0;"
                        puts "TCL: \[to be declared\] missing st:  subtype st_${all_slv_to_declare_name_i}_${d}d is integer range _ downto 0;"
                        puts "TCL: \[to be declared\] missing slv: type t_${all_slv_to_declare_name_i}_${d}d is array(st_${all_slv_to_declare_name_i}_${d}d) of std_logic_vector(st_${all_slv_to_declare_name_i}_1d);"
                        puts $write_file "        subtype st_${all_slv_to_declare_name_i}_1d is integer range _ downto 0;"
                        puts $write_file "        subtype st_${all_slv_to_declare_name_i}_${d}d is integer range _ downto 0;"
                        puts $write_file "        type t_${all_slv_to_declare_name_i}_${d}d is array(st_${all_slv_to_declare_name_i}_${d}d) of std_logic_vector(st_${all_slv_to_declare_name_i}_1d);"
                    }
                } else {
                    # Insert to or downto
                    if {$all_slv_to_declare_to_downto_i eq "downto"} {
                        puts "TCL: \[to be declared\] missing slv: type t_${all_slv_to_declare_name_i}_${d}d is array(_ $all_slv_to_declare_to_downto_i 0) of t_${all_slv_to_declare_name_i}_[expr ${d}-1]d;"
                        puts $write_file "        type t_${all_slv_to_declare_name_i}_${d}d is array(_ $all_slv_to_declare_to_downto_i 0) of t_${all_slv_to_declare_name_i}_[expr ${d}-1]d;"
                    } elseif {$all_slv_to_declare_to_downto_i eq "to"} {
                        puts "TCL: \[to be declared\] missing slv: type t_${all_slv_to_declare_name_i}_${d}d is array(0 $all_slv_to_declare_to_downto_i _) of t_${all_slv_to_declare_name_i}_[expr ${d}-1]d;"
                        puts $write_file "        type t_${all_slv_to_declare_name_i}_${d}d is array(0 $all_slv_to_declare_to_downto_i _) of t_${all_slv_to_declare_name_i}_[expr ${d}-1]d;"
                    } elseif {$all_slv_to_declare_to_downto_i ne ""} {
                        if {$all_slv_to_declare_to_downto_i ne " "} {
                            if { [string first " to " $all_slv_to_declare_to_downto_i] != -1} {
                                puts "TCL: \[to be declared\] missing st:  subtype st_${all_slv_to_declare_name_i}_${d}d is integer range 0 to _;"
                                puts "TCL: \[to be declared\] missing slv: type t_${all_slv_to_declare_name_i}_${d}d is array(st_${all_slv_to_declare_name_i}_${d}d) of t_${all_slv_to_declare_name_i}_[expr ${d}-1]d;"
                                puts $write_file "        subtype st_${all_slv_to_declare_name_i}_${d}d is integer range 0 to _;"
                                puts $write_file "        type t_${all_slv_to_declare_name_i}_${d}d is array(st_${all_slv_to_declare_name_i}_${d}d) of t_${all_slv_to_declare_name_i}_[expr ${d}-1]d;"
                            } else {
                                puts "TCL: \[to be declared\] missing st:  subtype st_${all_slv_to_declare_name_i}_${d}d is integer range _ downto 0;"
                                puts "TCL: \[to be declared\] missing slv: type t_${all_slv_to_declare_name_i}_${d}d is array(st_${all_slv_to_declare_name_i}_${d}d) of t_${all_slv_to_declare_name_i}_[expr ${d}-1]d;"
                                puts $write_file "        subtype st_${all_slv_to_declare_name_i}_${d}d is integer range _ downto 0;"
                                puts $write_file "        type t_${all_slv_to_declare_name_i}_${d}d is array(st_${all_slv_to_declare_name_i}_${d}d) of t_${all_slv_to_declare_name_i}_[expr ${d}-1]d;"
                            }
                        }
                    } else {
                        puts "TCL: \[to be declared\] missing st:  subtype st_${all_slv_to_declare_name_i}_${d}d is integer range _ downto 0;"
                        puts "TCL: \[to be declared\] missing slv: type t_${all_slv_to_declare_name_i}_${d}d is array(st_${all_slv_to_declare_name_i}_${d}d) of t_${all_slv_to_declare_name_i}_[expr ${d}-1]d;"
                        puts $write_file "        subtype st_${all_slv_to_declare_name_i}_${d}d is integer range _ downto 0;"
                        puts $write_file "        type t_${all_slv_to_declare_name_i}_${d}d is array(st_${all_slv_to_declare_name_i}_${d}d) of t_${all_slv_to_declare_name_i}_[expr ${d}-1]d;"
                    }
                }
                if {$d == $all_slv_to_declare_dimension_i} {
                    # Assign zeros as initial values
                    set init_zeros_dim "(others => "
                    for {set i 2} {$i < [expr $all_slv_to_declare_dimension_i+1]} {incr i} {
                        append init_zeros_dim "(others => "
                    }

                    # Close brackets
                    set init_zeros_dim_brackets "'0')"
                    for {set i 2} {$i < [expr $all_slv_to_declare_dimension_i+1]} {incr i} {
                        append init_zeros_dim_brackets ")"
                    }

                    puts "TCL: \[to be declared\] missing slv: signal ${all_slv_to_declare_name_i} : t_${all_slv_to_declare_name_i}_${d}d := ${init_zeros_dim}${init_zeros_dim_brackets};"
                    puts $write_file "        signal ${all_slv_to_declare_name_i} : t_${all_slv_to_declare_name_i}_${d}d := ${init_zeros_dim}${init_zeros_dim_brackets};"
                }
                
            }
        } elseif {$all_slv_to_declare_dimension_i == 1} {
            # If it is only an std_logic_vector
            # Insert to, downto or subtype
            if {$all_slv_to_declare_to_downto_i eq "downto"} {
                puts "TCL: \[to be declared\] missing slv: signal ${all_slv_to_declare_name_i} : std_logic_vector(_ $all_slv_to_declare_to_downto_i 0) := (others => '0');"
                puts $write_file "        signal ${all_slv_to_declare_name_i} : std_logic_vector(_ $all_slv_to_declare_to_downto_i 0) := (others => '0');"
            } elseif {$all_slv_to_declare_to_downto_i eq "to"} {
                puts "TCL: \[to be declared\] missing slv: signal ${all_slv_to_declare_name_i} : std_logic_vector(0 $all_slv_to_declare_to_downto_i _) := (others => '0');"
                puts $write_file "        signal ${all_slv_to_declare_name_i} : std_logic_vector(0 $all_slv_to_declare_to_downto_i _) := (others => '0');"
            } elseif {$all_slv_to_declare_to_downto_i ne ""} {
                if { [string first " to " $all_slv_to_declare_to_downto_i] != -1} {
                    puts "TCL: \[to be declared\] missing slv: signal ${all_slv_to_declare_name_i} : std_logic_vector($all_slv_to_declare_to_downto_i) := (others => '0');"
                    puts $write_file "        signal ${all_slv_to_declare_name_i} : std_logic_vector($all_slv_to_declare_to_downto_i) := (others => '0');"
                } elseif { [string first " downto " $all_slv_to_declare_to_downto_i] != -1} {
                    puts "TCL: \[to be declared\] missing slv: signal ${all_slv_to_declare_name_i} : std_logic_vector($all_slv_to_declare_to_downto_i) := (others => '0');"
                    puts $write_file "        signal ${all_slv_to_declare_name_i} : std_logic_vector($all_slv_to_declare_to_downto_i) := (others => '0');"
                }
            } else {
                puts "TCL: \[to be declared\] missing st:  subtype st_${all_slv_to_declare_name_i}_1d is integer range _ downto 0;"
                puts "TCL: \[to be declared\] missing slv: signal ${all_slv_to_declare_name_i} : std_logic_vector(st_${all_slv_to_declare_name_i}_1d) := (others => '0');"
                puts $write_file "        subtype st_${all_slv_to_declare_name_i}_1d is integer range _ downto 0;"
                puts $write_file "        signal ${all_slv_to_declare_name_i} : std_logic_vector(st_${all_slv_to_declare_name_i}_1d) := (others => '0');"
            }
        }
    }

    incr cnt_name_act
    set all_slv_to_declare_i [string range [lindex [split $all_slv_to_declare "|"] $cnt_name_act] 0 end]
}

puts "TCL: all_modules_filenames = $all_modules_filenames"