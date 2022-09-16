# report_environment -file <name>.txt


# Set the reference directory for source file relative paths (by default the value is script directory path)
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
puts "Running $script_file for project $_xil_proj_name_."

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/"]"


# Open the project
close_project -quiet
open_project "${origin_dir}/vivado/${_xil_proj_name_}.xpr"
reset_project


# ------------------------------
# - CLEAN ALL NON_MODULE FILES -
# ------------------------------

# Remove all non-module files if exist to clean-up the project
puts "Remove all non-module files if they exist"
remove_files [get_files -filter {IS_AVAILABLE == 0}]


# -----------------------------------------
# - CLEAN ALL .VHD FILES AND ADD NEW ONES -
# -----------------------------------------

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset object
set objSrc [get_filesets sources_1]
set objSim [get_filesets sim_1]

# Remove all previous .vhd source files
puts "TCL: Remove all .vhd source files in object filesets sources_1 and sim_1"
remove_files [get_files -of_objects $objSrc]
remove_files [get_files -of_objects $objSim]

# Search for all .vhd sources
set foundSrcs [glob -type f */*{.vhd}* */*/*{.vhd}*]

# Add only design .vhd sources to the project
foreach f $foundSrcs {
    set name [string range $f 0 end]
    if {[regexp $name _tb.vhd match] == 1} {
        puts "TCL: Skipping sim file to fileset sim_1: ${origin_dir}/$name"
    } else {
        puts "TCL: Adding source file to fileset sources_1: ${origin_dir}/$name"
        add_files -norecurse -fileset $objSrc ${origin_dir}/$name
    }
}

# # Add all the .vhd sources to the project
# foreach f $foundSrcs {
#     set name [string range $f 0 end]
#     puts "Adding source to fileset sources_1: ${origin_dir}/$name"
#     add_files -norecurse -fileset $objSrc ${origin_dir}/$name
# }


# -----------------------------------------
# - CLEAN ALL .XDC FILES AND ADD NEW ONES -
# -----------------------------------------

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constr_1' fileset object
set objConst [get_filesets constrs_1]

# Remove all previous .xdc source files
puts "TCL: Remove all .xdc source files in object fileset constrs_1"
remove_files [get_files -of_objects $objConst]

# Search for all .xdc sources
set foundConst [glob -type f */*{.xdc}* */*/*{.xdc}*]

# Add all the .xdc sources to the project
foreach f $foundConst {
    set name [string range $f 0 end]
    puts "TCL: Adding source to fileset constrs_1: ${origin_dir}/$name"
    add_files -norecurse -fileset $objConst ${origin_dir}/$name
}

puts "TCL: Update and report compile order "
update_compile_order
report_compile_order -file "${origin_dir}/vivado/0_report_compile_order.rpt"

# ------------------------------------------------------
# - CHECK ALL FILES IN FILESET SOURCES_1 AND CONSTRS_1 -
# ------------------------------------------------------

puts "TCL: ----- REPORTS FOR SOURCES_1 -----"
report_property -all $objSrc

puts "TCL: ----- REPORTS FOR CONSTRS_1 -----"
report_property -all $objConst

puts "TCL: ----- FILES IN SOURCES_1 -----"
set filesSrc [get_files -of_objects $objSrc]
foreach module $filesSrc {
    set file [string range $module 0 end]
    puts "$file"
}

puts "TCL: ----- FILES IN CONSTRS_1 -----"
set filesConst [get_files -of_objects $objConst]
foreach module $filesConst {
    set file [string range $module 0 end]
    puts "$file"
}

puts "TCL: ----- COMPILE ORDER FOR SYNTHESIS (TOP IS ALWAYS AT THE BOTTOM) -----"
set compOrder [get_files -compile_order sources -used_in synthesis]
foreach module $compOrder {
    set file [string range $module 0 end]
    puts "$file"
}

# Close project
puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "
close_project