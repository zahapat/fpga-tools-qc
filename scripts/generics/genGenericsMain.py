# ----- Libraries -----
import math as lib_math
import random as lib_rand
import csv as lib_csv
import pathlib as lib_path
import os
import sys
import getopt
import re

# ----- Import generator of the TCL file -----
import genGenerics


# ----- Functions -----
generic_names = []
generic_vals = []
def usage():
    print('PY: Correct usage:')
    print('PY: Example #1: python3 CrcGenMain.py -h')
    print('PY: Example #2: python3 CrcGenMain.py --help')
    print('PY: Example #3: python3 CrcGenMain.py -v -p C:/.../projects/project/ -t C:/.../projects/project/tx_crc_symtuppar -r C:/.../projects/project/tx_crc_symtuppar')
    print('PY: Example #4: python3 CrcGenMain.py --verbose -proj_dir C:/.../projects/project/ -output_dir C:/.../projects/project/tx_crc_symtuppar -rx_dir C:/.../projects/project/tx_crc_symtuppar')

def get_arg_generic(currentArg, currentArgValue):

    # Generic name and values are global lists
    global generic_names
    global generic_vals

    # Check if this arg is generic value or name
    if re.search('--generic.+', currentArg):
        argument_is_generic_name = str(currentArg).find("_name")
        argument_is_generic_val = str(currentArg).find("_val")
        if argument_is_generic_name != -1:
            # Append global generic names
            generic_names.append(currentArgValue), generic_vals
        elif argument_is_generic_val != -1:
            # Append global generic values
            generic_names, generic_vals.append(currentArgValue)
        else:
            # Some error
            print("PY: Strange behaviour in 'get_arg_generic'.")


# ----- Main Function -----
def main(argv):

    # Generic name and values are global lists
    global generic_names
    global generic_vals

    # Trim first argument (0) from the list of commandline arguments (which is the file name)
    argumentsList = argv[1:]
    print("PY: Command-line arguments list: ", argumentsList)
    print("PY: Number of command-line arguments: ", len(argumentsList))

    # Set of options (h: means that option '-h' can also be a long option '--help')
    options = "h:v:"

    # List of long options 
    # "Long options which require an argument should be followed by an equal sign ('=')"
    longOptions = [
        "help=",
        "verbose=",

        "proj_name=",
        "proj_dir=",
        "output_dir="
    ]
    for variable_argument in argumentsList:
        if re.search('--generic.+', variable_argument):
            allowed_variable_option = str(variable_argument).rsplit("=", 1)
            allowed_variable_option = str(allowed_variable_option[0] + "=").replace('--', '')
            longOptions.append(allowed_variable_option)

    print("PY: Arguments long options list: ", longOptions)

    # Default values of arguments needed to be passed to this script
    verbose = False

    proj_name = None
    proj_dir = None

    output_dir = None

    # Parsing arguments
    try:
        allArgs, allArgValues = getopt.getopt(argumentsList, options, longOptions)

        for currentArg, currentArgValue in allArgs:

            # ---- Help and Verbose Switches -----
            # Get help
            if currentArg in ('-h', "--help"):
                usage()
                sys.exit()

            # Get verbose
            elif currentArg in ("-v", "--verbose"):
                verbose = True
                print('PY: Verbose flag is enabled.')



            # ----- Constants for generating the file -----
            # All Generics
            get_arg_generic(currentArg, currentArgValue)


            # ----- Project name, Working and Output Directories -----
            # Get project name
            if currentArg in ("--proj_name"):
                proj_name = str(currentArgValue)
                print('PY: proj_name: ', proj_name)

            # Get current root directory
            elif currentArg in ("--proj_dir"):
                proj_dir = str(currentArgValue)
                print('PY: Project root directory: ', proj_dir)

            # Get desired output directory
            elif currentArg in ("--output_dir"):
                output_dir = str(currentArgValue)
                print('PY: Output directory: ', output_dir)



    # Output error and return with an error code if cmdline arg not recognised
    except getopt.GetoptError as errorMsg:
        print("PY: Command-line argument not recognised. Error code: ", str(errorMsg))
        usage()
        sys.exit(2)



    # Re/create nested directories for Tx files if they don't exist
    try:
        os.makedirs(output_dir)
    except FileExistsError:
        # Directory already exists
        print("PY: Directory '", output_dir, "' already exist.")
        pass


    # Assert Default Generics Valid
    # Check error #1: Assert validity of inputted generic parameters from command-line
    if len(generic_vals) == len(generic_names):
        for i in range(len(generic_vals)):
            print("Generic {}: {} = {}".format(i, generic_names[i], generic_vals[i]))

        # genericGen.genTclFileGenerator(
        genGenerics.topfileGenericsGenerator(
            proj_name, proj_dir, output_dir,
            generic_names, generic_vals)
    else:
        # Display error
        command_open_cmd = "start /wait cmd /k"
        command_1 = "echo ERROR: Number of names and values of inputted generic parameters does not match. Check your command-line arguments."
        os.system(command_open_cmd + " " + command_1)


# ----- Executors -----
if __name__ == "__main__":
    main(sys.argv)