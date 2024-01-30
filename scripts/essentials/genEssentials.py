# ----- Libraries -----
import math as lib_math
import random as lib_rand
import csv as lib_csv
import pathlib as lib_path
import sys
import os


# ----- Functions Declaration -----
# Generate 24-byte wide cryptographically strong pseudorandom number, 
# limited to the maximum natural range in VHDL: 0 to 2147483647
def get_rand():
    return int(os.urandom(24).hex(), 16) % 2147483647

# Generate a VHDL file
def essentialsGenerator(
    proj_name, proj_dir, output_dir):

    _file_gen_name = 'essentials_tb.vhd'
    _file_gen_fullpath = ('{0}{1}{2}'.format(output_dir, "/", _file_gen_name))
    print('new file', _file_gen_name, 'created: ', _file_gen_fullpath)
    _file_gen_line = open(_file_gen_fullpath, 'w')

    _file_gen_line.write("-- "+_file_gen_name+': This is an automatically generated file with information about \n')
    _file_gen_line.write('-- project name and root directory after running \'make generics\' command.\n')
    _file_gen_line.write('package essentials_tb is\n')
    _file_gen_line.write('\n')

    _file_gen_line.write('    constant PROJ_NAME : string := \"{}\";\n'.format(proj_name))
    _file_gen_line.write('    constant PROJ_DIR : string := \"{}\";\n'.format(proj_dir))
    _file_gen_line.write('    constant RANDOM_SEED_1 : natural := {};\n'.format(get_rand()))
    _file_gen_line.write('    constant RANDOM_SEED_2 : natural := {};\n'.format(get_rand()))

    _file_gen_line.write('\n')
    _file_gen_line.write('end package essentials_tb;\n')
    _file_gen_line.write('\n')
    _file_gen_line.write('\n')
    _file_gen_line.write('\n')
    _file_gen_line.write('package body essentials_tb is \n')
    _file_gen_line.write('\n')
    _file_gen_line.write('end package body essentials_tb;')
    _file_gen_line.close()
    print("Generation of the '", _file_gen_name, "' file finished successfully.")