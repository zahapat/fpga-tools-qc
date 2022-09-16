# ----- Libraries -----
import math as lib_math
import random as lib_rand
import csv as lib_csv
import pathlib as lib_path
import os
import sys
import getopt

# ----- Import CRC Generator -----
import CrcGen as crcgen

# ----- Functions -----
def usage():
    print('PY: Correct usage:')
    print('PY: Example #1: python3 CrcGenMain.py -h')
    print('PY: Example #2: python3 CrcGenMain.py --help')
    print('PY: Example #3: python3 CrcGenMain.py -v -p C:/.../projects/project/ -t C:/.../projects/project/tx_crc_symtuppar -r C:/.../projects/project/tx_crc_symtuppar')
    print('PY: Example #4: python3 CrcGenMain.py --verbose -proj_dir C:/.../projects/project/ -tx_dir C:/.../projects/project/tx_crc_symtuppar -rx_dir C:/.../projects/project/tx_crc_symtuppar')


# ----- Main Function -----
def main(argv):

    # Trim first argument (0) from the list of commandline arguments (which is the file name)
    argumentsList = argv[1:]
    print("PY: Command-line arguments list: ", argumentsList)
    print("PY: Number of command-line arguments: ", len(argumentsList))

    # Set of options (h: means that option '-h' can also be a long option '--help')
    options = "h:v:"

    # List of long options
    longOptions = ["help", "verbose", "symbol_width=", "symbols_count=", "primitive_polynomial=", "gf_seed=", "genpol_symbols_count=", "tx_submessages_count=", "rx_submessages_count=", "sim_transactions_count=", "proj_dir=", "gfmult_dir=", "tx_dir=", "rx_dir=", "src_lib=", "sim_lib="]

    # Arguments needed to be passed to this script
    verbose = False

    symbol_width = None
    symbols_count = None
    primitive_polynomial = None
    gf_seed = None
    genpol_symbols_count = None
    tx_submessages_count = None
    rx_submessages_count = None
    
    sim_transactions_count = None

    proj_dir = None
    tx_dir = None
    rx_dir = None

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



            # ----- Constants for generating desired hardware -----
            # Get symbol width
            elif currentArg in ("--symbol_width"):
                symbol_width = int(currentArgValue)
                print('PY: Symbol width: ', symbol_width)

            # Get symbols count
            elif currentArg in ("--symbols_count"):
                symbols_count = int(currentArgValue)
                print('PY: Symbols count: ', symbols_count)

            # Get primitive polynomial
            elif currentArg in ("--primitive_polynomial"):
                primitive_polynomial = int(currentArgValue)
                print('PY: Primitive polynomial (decimal): ', primitive_polynomial)

            # Get Seed for Galois Field Creation
            elif currentArg in ("--gf_seed"):
                gf_seed = int(currentArgValue)
                print('PY: Seed for Galois Field (decimal): ', gf_seed)

            # Get Parity Symbols Count
            elif currentArg in ("--genpol_symbols_count"):
                genpol_symbols_count = int(currentArgValue)
                print('PY: Number of parity symbols (= number of symbols in one tuple to be processed in parallel): ', genpol_symbols_count)

            # Get Number of parallel submessages (for TX)
            elif currentArg in ("--tx_submessages_count"):
                tx_submessages_count = int(currentArgValue)
                print('PY: Number of parallel submessages (TX): ', tx_submessages_count)
            
            # Get Number of parallel submessages (for RX)
            elif currentArg in ("--rx_submessages_count"):
                rx_submessages_count = int(currentArgValue)
                print('PY: Number of parallel submessages (RX): ', rx_submessages_count)


            # ----- Libraries -----
            # Src
            elif currentArg in ("--src_lib"):
                src_lib = str(currentArgValue)
                print('PY: Library for source files: ', src_lib)
            
            # Src
            elif currentArg in ("--sim_lib"):
                sim_lib = str(currentArgValue)
                print('PY: Library for simulation files: ', sim_lib)

            # ----- Simulation -----
            # Get  Number transactions for simulation
            elif currentArg in ("--sim_transactions_count"):
                sim_transactions_count = int(currentArgValue)
                print('PY: Number transactions for simulation: ', sim_transactions_count)


            # ----- Working and Output Directories -----
            # Get current root directory
            elif currentArg in ("--proj_dir"):
                proj_dir = str(currentArgValue)
                print('PY: Project root directory: ', proj_dir)
            
            elif currentArg in ("--gfmult_dir"):
                gfmult_dir = str(currentArgValue)
                print('PY: Constant Galois Field Multiplier output directory: ', gfmult_dir)

            # Get root directory
            elif currentArg in ("--tx_dir"):
                tx_dir = str(currentArgValue)
                print('PY: Tx output directory: ', tx_dir)

            # Get desired output folder
            elif currentArg in ("--rx_dir"):
                rx_dir = str(currentArgValue)
                print('PY: Rx output directory: ', rx_dir)


    # Output error and return with an error code if cmdline arg not recognised
    except getopt.GetoptError as errorMsg:
        print("PY: Command-line argument not recognised. Error code: ", str(errorMsg))
        usage()
        sys.exit(2)

    # Re/create nested directories for gfmult_constb if it doesn't exist
    try:
        os.makedirs(gfmult_dir)
    except FileExistsError:
        # Directory already exists
        print("PY: Directory '", gfmult_dir, "' already exist.")
        pass

    # Re/create nested directories for Tx files if they don't exist
    try:
        os.makedirs(tx_dir)
    except FileExistsError:
        # Directory already exists
        print("PY: Directory '", tx_dir, "' already exist.")
        pass

    # Re/create nested directories for Rx files if they don't exist
    try:
        os.makedirs(rx_dir)
    except FileExistsError:
        # Directory already exists
        print("PY: Directory '", rx_dir, "' already exist.")
        pass


    # Execute the CRC Generator
    crcgen.CrcGenerator(symbol_width, symbols_count, primitive_polynomial, gf_seed, genpol_symbols_count, tx_submessages_count, rx_submessages_count, sim_transactions_count, gfmult_dir, tx_dir, rx_dir, src_lib, sim_lib)
    

# ----- Executors -----
if __name__ == "__main__":
    main(sys.argv)