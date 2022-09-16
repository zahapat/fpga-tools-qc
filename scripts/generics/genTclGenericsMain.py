# ----- Libraries -----
import math as lib_math
import random as lib_rand
import csv as lib_csv
import pathlib as lib_path
import os
import sys
import getopt

# ----- Import generator of the TCL file -----
import genTclGenerics as genericGen

# ----- Functions -----
def usage():
    print('PY: Correct usage:')
    print('PY: Example #1: python3 CrcGenMain.py -h')
    print('PY: Example #2: python3 CrcGenMain.py --help')
    print('PY: Example #3: python3 CrcGenMain.py -v -p C:/.../projects/project/ -t C:/.../projects/project/tx_crc_symtuppar -r C:/.../projects/project/tx_crc_symtuppar')
    print('PY: Example #4: python3 CrcGenMain.py --verbose -proj_dir C:/.../projects/project/ -output_dir C:/.../projects/project/tx_crc_symtuppar -rx_dir C:/.../projects/project/tx_crc_symtuppar')


# ----- Main Function -----
def main(argv):

    # Trim first argument (0) from the list of commandline arguments (which is the file name)
    argumentsList = argv[1:]
    print("PY: Command-line arguments list: ", argumentsList)
    print("PY: Number of command-line arguments: ", len(argumentsList))

    # Set of options (h: means that option '-h' can also be a long option '--help')
    options = "h:v:"

    # List of long options
    longOptions = [
        "help",
        "verbose",
        "proj_name=",
        "proj_dir=",
        
        "generic1_name=",
        "generic1_val=",
        "generic2_name=",
        "generic2_val=",
        "generic3_name=",
        "generic3_val=",
        "generic4_name=",
        "generic4_val=",
        "generic5_name=",
        "generic5_val=",
        "generic6_name=",
        "generic6_val=",
        "generic7_name=",
        "generic7_val=",
        "generic8_name=",
        "generic8_val=",
        "generic9_name=",
        "generic9_val=",
        "generic10_name=",
        "generic10_val=",
        "generic11_name=",
        "generic11_val=",
        "generic12_name=",
        "generic12_val=",
        "generic13_name=",
        "generic13_val=",
        "generic14_name=",
        "generic14_val=",
        "generic15_name=",
        "generic15_val=",
        
        "output_dir="
    ]

    # Default values of arguments needed to be passed to this script
    verbose = False

    proj_name = None
    proj_dir = None
    generic1_name = None
    generic1_val = None
    generic2_name = None
    generic2_val = None
    generic3_name = None
    generic3_val = None

    output_dir = "./tcl/project_specific/vivado"
    
    generic_names = []
    generic_vals = []

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
            # Generic 1
            elif currentArg in ("--generic1_name"):
                if currentArgValue != "":
                    generic_names.append(currentArgValue)
            elif currentArg in ("--generic1_val"):
                if currentArgValue != "":
                    generic_vals.append(currentArgValue)

            # Generic 2
            elif currentArg in ("--generic2_name"):
                if currentArgValue != "":
                    generic_names.append(currentArgValue)
            elif currentArg in ("--generic2_val"):
                if currentArgValue != "":
                    generic_vals.append(currentArgValue)

            # Generic 3
            elif currentArg in ("--generic3_name"):
                if currentArgValue != "":
                    generic_names.append(currentArgValue)
            elif currentArg in ("--generic3_val"):
                if currentArgValue != "":
                    generic_vals.append(currentArgValue)

            # Generic 4
            elif currentArg in ("--generic4_name"):
                if currentArgValue != "":
                    generic_names.append(currentArgValue)
            elif currentArg in ("--generic4_val"):
                if currentArgValue != "":
                    generic_vals.append(currentArgValue)

            # Generic 5
            elif currentArg in ("--generic5_name"):
                if currentArgValue != "":
                    generic_names.append(currentArgValue)
            elif currentArg in ("--generic5_val"):
                if currentArgValue != "":
                    generic_vals.append(currentArgValue)

            # Generic 6
            elif currentArg in ("--generic6_name"):
                if currentArgValue != "":
                    generic_names.append(currentArgValue)
            elif currentArg in ("--generic6_val"):
                if currentArgValue != "":
                    generic_vals.append(currentArgValue)

            # Generic 7
            elif currentArg in ("--generic7_name"):
                if currentArgValue != "":
                    generic_names.append(currentArgValue)
            elif currentArg in ("--generic7_val"):
                if currentArgValue != "":
                    generic_vals.append(currentArgValue)

            # Generic 8
            elif currentArg in ("--generic8_name"):
                if currentArgValue != "":
                    generic_names.append(currentArgValue)
            elif currentArg in ("--generic8_val"):
                if currentArgValue != "":
                    generic_vals.append(currentArgValue)

            # Generic 9
            elif currentArg in ("--generic9_name"):
                if currentArgValue != "":
                    generic_names.append(currentArgValue)
            elif currentArg in ("--generic9_val"):
                if currentArgValue != "":
                    generic_vals.append(currentArgValue)

            # Generic 10
            elif currentArg in ("--generic10_name"):
                if currentArgValue != "":
                    generic_names.append(currentArgValue)
            elif currentArg in ("--generic10_val"):
                if currentArgValue != "":
                    generic_vals.append(currentArgValue)

            # Generic 11
            elif currentArg in ("--generic11_name"):
                if currentArgValue != "":
                    generic_names.append(currentArgValue)
            elif currentArg in ("--generic11_val"):
                if currentArgValue != "":
                    generic_vals.append(currentArgValue)

            # Generic 12
            elif currentArg in ("--generic12_name"):
                if currentArgValue != "":
                    generic_names.append(currentArgValue)
            elif currentArg in ("--generic12_val"):
                if currentArgValue != "":
                    generic_vals.append(currentArgValue)

            # Generic 13
            elif currentArg in ("--generic13_name"):
                if currentArgValue != "":
                    generic_names.append(currentArgValue)
            elif currentArg in ("--generic13_val"):
                if currentArgValue != "":
                    generic_vals.append(currentArgValue)

            # Generic 14
            elif currentArg in ("--generic14_name"):
                if currentArgValue != "":
                    generic_names.append(currentArgValue)
            elif currentArg in ("--generic14_val"):
                if currentArgValue != "":
                    generic_vals.append(currentArgValue)

            # Generic 15
            elif currentArg in ("--generic15_name"):
                if currentArgValue != "":
                    generic_names.append(currentArgValue)
            elif currentArg in ("--generic15_val"):
                if currentArgValue != "":
                    generic_vals.append(currentArgValue)



            # ----- Project name, Working and Output Directories -----
            # Get project name
            elif currentArg in ("--proj_name"):
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
        
        genericGen.genTclFileGenerator(
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