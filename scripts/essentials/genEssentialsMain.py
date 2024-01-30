# ----- Libraries -----
import math as lib_math
import random as lib_rand
import csv as lib_csv
import pathlib as lib_path
import os
import sys
import getopt

# ----- Import generator of the TCL file -----
import genEssentials


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
    # "Long options which require an argument should be followed by an equal sign ('=')"
    longOptions = [
        "help=",
        "verbose=",

        "proj_name=",
        "proj_dir=",
        "output_dir="
    ]

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
    genEssentials.essentialsGenerator(
            proj_name, proj_dir, output_dir)


# ----- Executors -----
if __name__ == "__main__":
    main(sys.argv)