# ----- Libraries -----
import math as lib_math
import random as lib_rand
import csv as lib_csv
import pathlib as lib_path
import sys


# ----- Functions Declaration -----

# Generate a VHDL file
def topfileGenericsGenerator(
    proj_name, proj_dir, output_dir,
    generic_names, generic_vals):

    _file_gen_name = 'generics.vhd'
    _file_gen_fullpath = ('{0}{1}{2}'.format(output_dir, "/", _file_gen_name))
    print('new file', _file_gen_name, 'created: ', _file_gen_fullpath)
    _file_gen_line = open(_file_gen_fullpath, 'w')

    _file_gen_line.write("-- "+_file_gen_name+': This is an automatically generated file with generic parameters \n')
    _file_gen_line.write('-- after running \'make generics\' command.\n')
    _file_gen_line.write('package generics is\n')
    _file_gen_line.write('\n')

    for i in range(len(generic_names)):
        if bool(generic_names[i] and not generic_names[i].isspace()):
            if bool(generic_vals[i] and not generic_vals[i].isspace()):
                _file_gen_line.write('    constant {} : integer := {};'.format(generic_names[i], generic_vals[i]))
                _file_gen_line.write('\n')
                print('Writing to TCL: Generic {}={}'.format(generic_names[i], generic_vals[i]))

    _file_gen_line.write('\n')
    _file_gen_line.write('end package generics;\n')
    _file_gen_line.write('\n')
    _file_gen_line.write('\n')
    _file_gen_line.write('\n')
    _file_gen_line.write('package body generics is \n')
    _file_gen_line.write('\n')
    _file_gen_line.write('end package body generics;')
    _file_gen_line.close()
    print("Generation of the '", _file_gen_name, "' file finished successfully.")