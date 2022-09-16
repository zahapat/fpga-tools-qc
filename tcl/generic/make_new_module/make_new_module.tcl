# TO DO: COMPILE TO LIBRARY ... !!

# Find the directory of the current project
set origin_dir "."
if { [info exists ::origin_dir_loc] } {
    set origin_dir $::origin_dir_loc
}

# Get TCL Command-line arguments
puts "TCL: Get TCL Command-line arguments"
set arguments_cnt 7
if { $::argc == $arguments_cnt } {

    # Name
    set file_new [string trim [lindex $::argv 0] ]
    set file_new [string tolower $file_new]
    puts "TCL: Argument 1 lowercase: '$file_new'"
    set name_file [string range [lindex [split $file_new "."] 0] 0 end]
    puts "TCL: Name = '$name_file'"
    set suffix_file [string range [lindex [split $file_new "."] 1] 0 end]
    puts "TCL: Suffix (language) = '$suffix_file'"

    # Arch
    set file_arch [string trim [lindex $::argv 1] ]
    set file_arch [string tolower $file_arch]
    puts "TCL: Argument 2 lowercase: '$file_arch'"

    # Generate up to 4 extra files: srcpack.simpack.constr.tcl
    set additional_files [string trim [lindex $::argv 2] ]
    set additional_files [string tolower $additional_files]
    set gen_srcpack 0
    set gen_simpack 0
    set gen_constr 0
    set gen_tcl 0
    if {$additional_files ne ""} {
        if {[regexp -all {_} $additional_files] == 0} {
            if {$additional_files eq "srcpack"} {
                incr gen_srcpack
            } elseif {$additional_files eq "simpack"} {
                incr gen_simpack
            } elseif {$additional_files eq "constr"} {
                incr gen_constr
            } elseif {$additional_files eq "tcl"} {
                incr gen_tcl
            } else {
                puts "TCL: No extra files will be generated. Invalid keyword '$additional_files' for generation of an extra file/s. Example of generating 4 extra files using makefile: \"EXTRA=srcpack_simpack_constr_tcl\" "
            }
        } else {
            set cnt 0
            set line_part [string range [lindex [split $additional_files "_"] $cnt] 0 end]
            while {$line_part ne ""} {
                if {$line_part eq "srcpack"} {
                    incr gen_srcpack
                } elseif {$line_part eq "simpack"} {
                    incr gen_simpack
                } elseif {$line_part eq "constr"} {
                    incr gen_constr
                } elseif {$line_part eq "tcl"} {
                    incr gen_tcl
                } else {
                    puts "TCL: Invalid keyword '$additional_files' for generation of an extra file/s. Example of generating 4 extra files using makefile: \"EXTRA=srcpack.simpack.constr.tcl\" "
                    quit
                }
                incr cnt
                set line_part [string range [lindex [split $additional_files "_"] $cnt] 0 end]
            } 
        } 
    } else {
        puts "TCL: Argument 3 is empty '$additional_files'. No extra files will be generated."
    }

    # Library src files
    set file_library_src [string trim [lindex $::argv 3] ]
    set file_library_src [string tolower $file_library_src]
    puts "TCL: Argument 4 lowercase: '$file_library_src'"

    # Library sim files
    set file_library_sim [string trim [lindex $::argv 4] ]
    set file_library_sim [string tolower $file_library_sim]
    puts "TCL: Argument 5 lowercase: '$file_library_sim'"

    # Engineer
    set name_author [string trim [lindex $::argv 5] ]
    set name_author [string tolower $name_author]
    puts "TCL: Argument 6 lowercase: '$name_author'"
    set cnt 0
    set line_part [string range [lindex [split $name_author "_"] $cnt] 0 end]
    set engineer_name ""
    puts "TCL: line_part capital = '$engineer_name'"
    while {$line_part ne ""} {
        set line_part [string totitle $line_part]
        puts "TCL: line_part capital = '$line_part'"
        append engineer_name $line_part " "
        incr cnt
        set line_part [string range [lindex [split $name_author "_"] $cnt] 0 end]
    }
    puts "TCL: engineer_name capital = '$engineer_name'"

    # Email
    set email_addr [string trim [lindex $::argv 6] ]
    set email_addr [string tolower $email_addr]
    puts "TCL: Argument 7 lowercase: '$email_addr'"

} else {
    puts "TCL: ERROR: There must be $arguments_cnt Command-line argument(s) passed to the TCL script. Total arguments found: $::argc"

    # Name
    set file_new [string trim [lindex $::argv 0] ]
    set file_new [string tolower $file_new]
    puts "TCL: Argument 1 'file_new' lowercase: '$file_new'"

    # Arch
    set file_arch [string trim [lindex $::argv 1] ]
    set file_arch [string tolower $file_arch]
    puts "TCL: Argument 2 'file_arch' lowercase: '$file_arch'"

    # Generate up to 4 extra files: srcpack.simpack.constr.tcl
    set additional_files [string trim [lindex $::argv 2] ]
    set additional_files [string tolower $additional_files]
    puts "TCL: Argument 3 'additional_files' lowercase: '$additional_files'"

    # Library src files
    set file_library_src [string trim [lindex $::argv 3] ]
    set file_library_src [string tolower $file_library_src]
    puts "TCL: Argument 4 'file_library_src' lowercase: '$file_library_src'"

    # Library sim files
    set file_library_sim [string trim [lindex $::argv 4] ]
    set file_library_sim [string tolower $file_library_sim]
    puts "TCL: Argument 5 'file_library_sim' lowercase: '$file_library_sim'"

    # Engineer
    set name_author [string trim [lindex $::argv 5] ]
    set name_author [string tolower $name_author]
    puts "TCL: Argument 6 'name_author' lowercase: '$name_author'"

    # Email
    set email_addr [string trim [lindex $::argv 6] ]
    set email_addr [string tolower $email_addr]
    puts "TCL: Argument 7 'email_addr' lowercase: '$email_addr'"

    return 1
}

# Set name of the folder with all modules
set name_folder_sources "modules"

# [UNCOMMENT] Check if the module already exists to avoid overwriting
set module_exist_check [glob -nocomplain -type d [file normalize "."]/$name_folder_sources/{$name_file}]
if {$module_exist_check ne ""} {
    puts "TCL: WARNING: Module with the name '$name_file' already exists in the folder '$name_folder_sources'.. Delete it manually or use a different name to rewrite it entirely and run this script again."
    puts "TCL: INFO: NONE OF THE EXISTING FILES WILL BE OVERWRITTEN"
}

# ----- PROCEDURES -----
# Procedure: check for some invalid characters in the file name
proc check_invalid_chars {full_name_file} {
    if {[regexp -all { } $full_name_file] != 0} {
        puts "TCL: Invalid character ' ' detected. Enter different name of the module with a valid suffix."
        return 1
    }
    if {[regexp -all {/} $full_name_file] != 0} {
        puts "TCL: Invalid character ' / ' detected. Enter different name of the module with a valid suffix."
        return 1
    }
    if {[regexp -all {\[} $full_name_file] != 0} {
        puts "TCL: Invalid character ' \ ' detected. Enter different name of the module with a valid suffix."
        return 1
    }
}


# Check for valid architecture description: str (structural) or rtl (register transfer level)
proc check_valid_arch {file_arch} {
    if {[regexp -all { } $file_arch] != 0} {
        puts "TCL: Invalid character ' ' detected in the name of the architecture."
        return 1
    }
    if {[regexp -all {/} $file_arch] != 0} {
        puts "TCL: Invalid character ' / ' detected in the name of the architecture."
        return 1
    }
    if {[regexp -all {\[} $file_arch] != 0} {
        puts "TCL: Invalid character ' \ ' detected in the name of the architecture."
        return 1
    }

    # Check correct name of the
    if {[regexp -all {rtl} $file_arch] == 1} {
        puts "TCL: Architecture name: $file_arch"
    } elseif {[regexp -all {str} $file_arch] == 1} {
        puts "TCL: Architecture name: $file_arch"
    } else {
        puts "TCL: ERROR: Name of the architecture must be named 'rtl' or 'str' but is not."
        return 1
    }
}


# Procedure: Check valid suffix
proc check_valid_suffix {suffix_file} {
    if {[regexp -all {vhd} $suffix_file] != 1} {
        puts "TCL: Suffix '$suffix_file' is valid."
    } elseif {[regexp -all {sv} $suffix_file] != 1} {
        puts "TCL: Suffix '$suffix_file' is valid."
    } elseif {[regexp -all {v} $suffix_file] != 1} {
        puts "TCL: Suffix '$suffix_file' is valid."
    } else {
        puts "TCL: Suffix '$suffix_file' is invalid. Expected: .vhd / .sv / .v"
    }
}

# Procedure: Create desired directory for the new files
proc create_module_dir {origin_dir name_file name_folder_sources} {

    # Create the directory for the new files
    set module_dir_abs "[file normalize $origin_dir]/$name_folder_sources/$name_file"
    puts "TCL: Absolute folder for sources: $module_dir_abs"
    file mkdir $module_dir_abs
    puts "TCL: New directory: $module_dir_abs"

    return $module_dir_abs
}

# Procedure: Create source file
proc create_src_file {origin_dir name_file suffix_file file_arch module_dir_abs file_library_src file_library_sim engineer_name email_addr} {
    if {$suffix_file eq "vhd"} {
        set src_file_path "${module_dir_abs}/${name_file}.${suffix_file}"
        set new_file_src [open $src_file_path "w"]
        puts "TCL: New file: $src_file_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/vhdl/gen_src_vhdl.tcl"
        close $new_file_src
    } elseif {$suffix_file eq "sv"} {
        set src_file_path "${module_dir_abs}/${name_file}.${suffix_file}"
        set new_file_src [open $src_file_path "w"]
        puts "TCL: New file: $src_file_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/sv/gen_src_sv.tcl"
        close $new_file_src
    } else {
        puts "TCL: Language $suffix_file is not supported yet."
        quit
    }
    puts "TCL: File ${name_file}.${suffix_file} created."
}

# Procedure: Create sim files (e.g. testbench "name_tb.suffix")
proc create_sim_file {origin_dir name_file suffix_file file_arch module_dir_abs file_library_src file_library_sim engineer_name email_addr} {
    if {$suffix_file eq "vhd"} {
        # Regular Testbench file: Simple or Complex (Sequencer)
        set sim_file_path "${module_dir_abs}/${name_file}_tb.${suffix_file}"
        set new_file_sim [open $sim_file_path "w"]
        puts "TCL: New file: $sim_file_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/vhdl/gen_sim_vhdl.tcl"
        close $new_file_sim

        # Constrained Random Verification (CRV)
        set sim_file_path "${module_dir_abs}/crv_${name_file}_tb.${suffix_file}"
        set new_file_sim [open $sim_file_path "w"]
        puts "TCL: New file: $sim_file_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/vhdl/gen_crv_vhdl.tcl"
        close $new_file_sim

        # Bus Functional Model (BFM)
        set sim_file_path "${module_dir_abs}/bfm_${name_file}_tb.${suffix_file}"
        set new_file_sim [open $sim_file_path "w"]
        puts "TCL: New file: $sim_file_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/vhdl/gen_bfm_vhdl.tcl"
        close $new_file_sim

        # Checkers
        set sim_file_path "${module_dir_abs}/checkers_${name_file}_tb.${suffix_file}"
        set new_file_sim [open $sim_file_path "w"]
        puts "TCL: New file: $sim_file_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/vhdl/gen_checkers_vhdl.tcl"
        close $new_file_sim

        # Executors
        set sim_file_path "${module_dir_abs}/executors_${name_file}_tb.${suffix_file}"
        set new_file_sim [open $sim_file_path "w"]
        puts "TCL: New file: $sim_file_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/vhdl/gen_executors_vhdl.tcl"
        close $new_file_sim

        # Harness
        set sim_file_path "${module_dir_abs}/harness_${name_file}_tb.${suffix_file}"
        set new_file_sim [open $sim_file_path "w"]
        puts "TCL: New file: $sim_file_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/vhdl/gen_harness_vhdl.tcl"
        close $new_file_sim


    } elseif {$suffix_file eq "sv"} {
        # Regular Testbench file for monitoring inputs/outputs
        set sim_file_path "${module_dir_abs}/${name_file}_tb.${suffix_file}"
        set new_file_sim [open $sim_file_path "w"]
        puts "TCL: New file: $sim_file_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/sv/gen_sim_sv.tcl"
        close $new_file_sim

        # Agent
        set sim_file_path "${module_dir_abs}/${name_file}_agent.${suffix_file}"
        set new_file_sim [open $sim_file_path "w"]
        puts "TCL: New file: $sim_file_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/sv/gen_agent.tcl"
        close $new_file_sim

        # Driver
        set sim_file_path "${module_dir_abs}/${name_file}_driver.${suffix_file}"
        set new_file_sim [open $sim_file_path "w"]
        puts "TCL: New file: $sim_file_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/sv/gen_driver.tcl"
        close $new_file_sim

        # Evironment/env
        set sim_file_path "${module_dir_abs}/${name_file}_env.${suffix_file}"
        set new_file_sim [open $sim_file_path "w"]
        puts "TCL: New file: $sim_file_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/sv/gen_environment.tcl"
        close $new_file_sim

        # Generator = generator of sequences = sequencer
        # set sim_file_path "${module_dir_abs}/${name_file}_generator.${suffix_file}"
        # set new_file_sim [open $sim_file_path "w"]
        # puts "TCL: New file: $sim_file_path"
        # source "[file normalize $origin_dir]/tcl/generic/make_new_module/sv/gen_generator.tcl"
        # close $new_file_sim

        # Interface
        set sim_file_path "${module_dir_abs}/${name_file}_interface.${suffix_file}"
        set new_file_sim [open $sim_file_path "w"]
        puts "TCL: New file: $sim_file_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/sv/gen_interface.tcl"
        close $new_file_sim

        # Monitor
        set sim_file_path "${module_dir_abs}/${name_file}_monitor.${suffix_file}"
        set new_file_sim [open $sim_file_path "w"]
        puts "TCL: New file: $sim_file_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/sv/gen_monitor.tcl"
        close $new_file_sim
        
        # Scoreboard
        set sim_file_path "${module_dir_abs}/${name_file}_scoreboard.${suffix_file}"
        set new_file_sim [open $sim_file_path "w"]
        puts "TCL: New file: $sim_file_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/sv/gen_scoreboard.tcl"
        close $new_file_sim
        
        # Sequencer
        set sim_file_path "${module_dir_abs}/${name_file}_sequencer.${suffix_file}"
        set new_file_sim [open $sim_file_path "w"]
        puts "TCL: New file: $sim_file_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/sv/gen_sequencer.tcl"
        close $new_file_sim

        # Test
        set sim_file_path "${module_dir_abs}/${name_file}_test.${suffix_file}"
        set new_file_sim [open $sim_file_path "w"]
        puts "TCL: New file: $sim_file_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/sv/gen_test.tcl"
        close $new_file_sim

        # Transaction
        set sim_file_path "${module_dir_abs}/${name_file}_transaction.${suffix_file}"
        set new_file_sim [open $sim_file_path "w"]
        puts "TCL: New file: $sim_file_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/sv/gen_transaction.tcl"
        close $new_file_sim

        # Testbench top
        set sim_file_path "${module_dir_abs}/${name_file}_top_tb.${suffix_file}"
        set new_file_sim [open $sim_file_path "w"]
        puts "TCL: New file: $sim_file_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/sv/gen_top_tb.tcl"
        close $new_file_sim

    } else {
        puts "TCL: Language $suffix_file is not supported yet."
        quit
    }
    puts "TCL: File ${name_file}_tb.${suffix_file} has been created."
}


# Procedure: Create a separate package for source file (for subprograms, constants, types, subtypes, ...)
proc create_srcpack_file {origin_dir name_file suffix_file file_arch module_dir_abs file_library_src file_library_sim engineer_name email_addr} {
    if {$suffix_file eq "vhd"} {
        set src_file_pack_path "${module_dir_abs}/${name_file}_pack.${suffix_file}"
        set new_file_src_pack [open $src_file_pack_path "w"]
        puts "TCL: New file: $src_file_pack_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/vhdl/gen_srcpack_vhdl.tcl"
        close $new_file_src_pack
    } elseif {$suffix_file eq "sv"} {
        set src_file_pack_path "${module_dir_abs}/${name_file}_pack.${suffix_file}"
        set new_file_src_pack [open $src_file_pack_path "w"]
        puts "TCL: New file: $src_file_pack_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/sv/gen_srcpack_sv.tcl"
        close $new_file_src_pack
    } else {
        puts "TCL: Language $suffix_file is not supported yet."
        quit
    }
    puts "TCL: File ${name_file}_pack.${suffix_file} created."
}


# Procedure: Create a separate package for simulation file (for subprograms, constants, types, subtypes, ...)
proc create_simpack_file {origin_dir name_file suffix_file file_arch module_dir_abs file_library_src file_library_sim engineer_name email_addr} {
    if {$suffix_file eq "vhd"} {
        set sim_file_pack_path "${module_dir_abs}/${name_file}_pack_tb.${suffix_file}"
        set new_file_sim_pack [open $sim_file_pack_path "w"]
        puts "TCL: New file: $sim_file_pack_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/vhdl/gen_simpack_vhdl.tcl"
        close $new_file_sim_pack
    } elseif {$suffix_file eq "sv"} {
        set sim_file_pack_path "${module_dir_abs}/${name_file}_pack_tb.${suffix_file}"
        set new_file_sim_pack [open $sim_file_pack_path "w"]
        puts "TCL: New file: $sim_file_pack_path"
        source "[file normalize $origin_dir]/tcl/generic/make_new_module/sv/gen_simpack_sv.tcl"
        close $new_file_sim_pack
    } else {
        puts "TCL: Language $suffix_file is not supported yet."
        quit
    }
    puts "TCL: File ${name_file}_pack_tb.${suffix_file} created."
}


# Procedure: Create constraints file
proc create_constr_file {origin_dir name_file suffix_file module_dir_abs} {
    set constr_file_path "${module_dir_abs}/${name_file}_constr.xdc"
    set new_file_const [open $constr_file_path "w"]
    puts "TCL: New file: $constr_file_path"
    source "[file normalize $origin_dir]/tcl/generic/make_new_module/gen_constr.tcl"
    close $new_file_const
    puts "TCL: File ${name_file}_const.xdc has been created."
}


# Procedure: Create tickle file
proc create_tcl_file {origin_dir name_file suffix_file file_arch module_dir_abs file_library_src file_library_sim engineer_name email_addr} {
    set tcl_file_path "${module_dir_abs}/${name_file}_tcl.tcl"
    set new_file_tcl [open $tcl_file_path "w"]
    puts "TCL: New file: $tcl_file_path"
    source "[file normalize $origin_dir]/tcl/generic/make_new_module/gen_tcl.tcl"
    close $new_file_tcl
    puts "TCL: File ${name_file}_tcl.tcl has been created."
}


# Procedure: Create README file
proc create_readme_file {origin_dir name_file suffix_file file_arch module_dir_abs file_library_src file_library_sim engineer_name email_addr} {
    set readme_file_path "${module_dir_abs}/README.txt"
    set new_file_readme [open $readme_file_path "w"]
    source "[file normalize $origin_dir]/tcl/generic/make_new_module/gen_readme.tcl"
    close $new_file_readme
    puts "TCL: File README.txt has been created."
}


# Set the reference directory for source file relative paths
# (by default the value is script directory path)
set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
    set origin_dir $::origin_dir_loc
}

# Set the project name
set _xil_proj_name_ [file tail [file dirname "[file normalize ./Makefile]"]]

# Use project name variable, if specified in the tcl shell
if { [info exists ::user_project_name] } {
    set _xil_proj_name_ $::user_project_name
}
variable script_file
set script_file "[file tail [info script]]"
puts "TCL: Running $script_file for project $_xil_proj_name_."


# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/"]"


# ----- MAIN FUNCTION -----
# Open project
close_project -quiet
open_project "${origin_dir}/vivado/${_xil_proj_name_}.xpr"

# Check invalid characters in the name
check_invalid_chars $file_new

# Check valid architecture "str/rtl" and make lowercase
check_valid_arch $file_arch

# Get name of the module and language (suffix)
check_valid_suffix $suffix_file

# Set name of a folder for all modules
set module_dir_abs [create_module_dir $origin_dir $name_file $name_folder_sources]

# Check for existing files to avoid overwriting and enable adding new files
set module_exist_check_src [glob -nocomplain -type f [file normalize "."]/$name_folder_sources/${name_file}/${name_file}.${suffix_file}]
set module_exist_check_srcpack [glob -nocomplain -type f [file normalize "."]/$name_folder_sources/${name_file}/${name_file}_pack.${suffix_file}]
set module_exist_check_sim [glob -nocomplain -type f [file normalize "."]/$name_folder_sources/${name_file}/${name_file}_tb.${suffix_file}]
set module_exist_check_simpack [glob -nocomplain -type f [file normalize "."]/$name_folder_sources/${name_file}/${name_file}_pack_tb.${suffix_file}]
set module_exist_check_tcl [glob -nocomplain -type f [file normalize "."]/$name_folder_sources/${name_file}/${name_file}_tcl.${suffix_file}]
set module_exist_check_constr [glob -nocomplain -type f [file normalize "."]/$name_folder_sources/${name_file}/${name_file}_constr.xdc]
set module_exist_check_readme [glob -nocomplain -type f [file normalize "."]/$name_folder_sources/${name_file}/README.txt]

# Create a new folder and files: source file, sim file, constr file
if {$module_exist_check_src eq ""} {
    # THIS FILE MUST EXIST
    create_src_file $origin_dir $name_file $suffix_file $file_arch $module_dir_abs $file_library_src $file_library_sim $engineer_name $email_addr
} else {
    puts "TCL: File ${name_file}.${suffix_file} already exists. Skip this file."
}

if {$module_exist_check_srcpack eq ""} {
    # Extra file
    if {$gen_srcpack != 0} {
        create_srcpack_file $origin_dir $name_file $suffix_file $file_arch $module_dir_abs $file_library_src $file_library_sim $engineer_name $email_addr   
    }
} else {
    puts "TCL: File ${name_file}_pack.${suffix_file} already exists. Skip this file."
}

if {$module_exist_check_sim eq ""} {
    # THIS FILE MUST EXIST
    create_sim_file $origin_dir $name_file $suffix_file $file_arch $module_dir_abs $file_library_src $file_library_sim $engineer_name $email_addr
} else {
    puts "TCL: File ${name_file}_tb.${suffix_file} already exists. Skip this file."
}

if {$module_exist_check_simpack eq ""} {
    # Extra file
    if {$gen_simpack != 0} {
        create_simpack_file $origin_dir $name_file $suffix_file $file_arch $module_dir_abs $file_library_src $file_library_sim $engineer_name $email_addr   
    }
} else {
    puts "TCL: File ${name_file}_pack_tb.${suffix_file} already exists. Skip this file."
}

if {$module_exist_check_tcl eq ""} {
    # Extra file
    if {$gen_tcl != 0} {
        create_tcl_file $origin_dir $name_file $suffix_file $file_arch $module_dir_abs $file_library_src $file_library_sim $engineer_name $email_addr   
    }
} else {
    puts "TCL: File ${name_file}_tcl.tcl already exists. Skip this file."
}

if {$module_exist_check_constr eq ""} {
    # Extra file
    if {$gen_constr != 0} {
        create_constr_file $origin_dir $name_file $suffix_file $module_dir_abs
    }
} else {
    puts "TCL: File ${name_file}_constr.xdc already exists. Skip this file."
}

if {$module_exist_check_readme eq ""} {
    # THIS FILE MUST EXIST
    create_readme_file $origin_dir $name_file $suffix_file $file_arch $module_dir_abs $file_library_src $file_library_sim $engineer_name $email_addr
} else {
    puts "TCL: File ${name_file}.${suffix_file} already exists. Skip this file."
}

# Close project, print success
puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "
close_project