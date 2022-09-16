# ----- Libraries -----
import math as lib_math
import random as lib_rand
import csv as lib_csv
import pathlib as lib_path
import sys


# ----- Functions Declaration -----

# Generate a VHDL file with a single symbolic-tuple-parallel CRC
def genTclFileGenerator(
    proj_name, proj_dir, output_dir,
    generic_names, generic_vals):

    _file_gen_name = 'make_generics.tcl'
    _file_gen_fullpath = ('{0}{1}{2}'.format(output_dir, "/", _file_gen_name))
    print('new file', _file_gen_name, 'created: ', _file_gen_fullpath)
    _file_gen_line = open(_file_gen_fullpath, 'w')

    _file_gen_line.write('    # Set the reference directory for source file relative paths (by default the value is script directory path)\n')
    _file_gen_line.write('    set origin_dir "."\n')
    _file_gen_line.write('\n')
    _file_gen_line.write('    # Use origin directory path location variable, if specified in the tcl shell\n')
    _file_gen_line.write('    if { [info exists ::origin_dir_loc] } {\n')
    _file_gen_line.write('        set origin_dir $::origin_dir_loc\n')
    _file_gen_line.write('    }\n')
    _file_gen_line.write('\n')
    _file_gen_line.write('    # Set the project name\n')
    _file_gen_line.write('    set _xil_proj_name_ [file tail [file dirname "[file normalize ./Makefile]"]]\n')
    _file_gen_line.write('\n')
    _file_gen_line.write('    # Use project name variable, if specified in the tcl shell\n')
    _file_gen_line.write('    if { [info exists ::user_project_name] } {\n')
    _file_gen_line.write('        set _xil_proj_name_ $::user_project_name\n')
    _file_gen_line.write('    }\n')
    _file_gen_line.write('\n')
    _file_gen_line.write('    variable script_file\n')
    _file_gen_line.write('    set script_file "[file tail [info script]]"\n')
    _file_gen_line.write('    puts "TCL: Running $script_file for project $_xil_proj_name_."\n')
    _file_gen_line.write('\n')
    _file_gen_line.write('\n')
    _file_gen_line.write('    # Open the project\n')
    _file_gen_line.write('    close_project -quiet\n')
    _file_gen_line.write('    open_project "${origin_dir}/vivado/${_xil_proj_name_}.xpr"\n')
    _file_gen_line.write('\n')
    _file_gen_line.write('    # 1) Set the following generic parameters\n')
    _file_gen_line.write('\n')
    _file_gen_line.write('    # Template:\n')
    _file_gen_line.write('    #     By default, a generic is passed to synthesis as "___"\n')
    _file_gen_line.write('    #     A) When passing a string value:\n')
    _file_gen_line.write('    #         set_property generic { GENERIC_NAME={\\"STRING_VALUE\\"} } [current_fileset]\n')
    _file_gen_line.write('    #     B) When passing a numeric value:\n')
    _file_gen_line.write('    #         set_property generic { GENERIC_NAME={NUMERIC_VALUE} } [current_fileset]\n')
    _file_gen_line.write('\n')
    _file_gen_line.write('\n')

    _file_gen_line.write('    set_property generic {\\')
    _file_gen_line.write('\n')
    for i in range(len(generic_names)):
        _file_gen_line.write('        {}={}\\'.format(generic_names[i], generic_vals[i]))
        _file_gen_line.write('\n')
        print('Writing to TCL: Generic {}={}'.format(generic_names[i], generic_vals[i]))
    _file_gen_line.write('    } [current_fileset]\n')

    _file_gen_line.write('\n')    
    _file_gen_line.write('\n')
    _file_gen_line.write('    # Close project\n')
    _file_gen_line.write('    puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "\n')
    _file_gen_line.write('    close_project\n')

    _file_gen_line.close()
    print("Generation of the '", _file_gen_name, "' file finished successfully.")