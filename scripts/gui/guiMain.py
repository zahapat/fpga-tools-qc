# ----- Libraries -----
import re
import os
import sys
import getopt

# ----- Import generator of the TCL file -----
import guiLayout

# ----- Functions -----
generic_names = []
generic_vals = []
def usage():
    print('PY: Correct usage:')
    print('PY: Example #1: python3 guiMain.py -h')
    print('PY: Example #2: python3 guiMain.py --help')


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
    print("PY: Command-line arguments list before parsing: ", argumentsList)
    print("PY: Number of command-line arguments: ", len(argumentsList))

    # Set of options (h: means that option '-h' can also be a long option '--help')
    options = "h:v:"

    # List of long options
    longOptions = [
        "help",
        "verbose",
        "geometry=",
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

    geometry = "640x480"

    proj_name = ""
    proj_dir = ""

    output_dir = "./scripts/gui"

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


            # ----- Root Window Geometry -----
            # Dimensions of the Root Window
            elif currentArg in ("--geometry"):
                geometry = str(currentArgValue)
                print('PY: geometry: ', geometry)


            # ----- Constants for generating the file -----
            # All Generics
            get_arg_generic(currentArg, currentArgValue)



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
    # String: 
    error = 0
    # Check error #1: Assert validity of inputted generic parameters from command-line
    if len(generic_vals) == len(generic_names):
        for i in range(len(generic_vals)):
            print("Generic {}: {} = {}".format(i, generic_names[i], generic_vals[i]))
    else:
        # Display error
        # command_open_cmd = "start /wait cmd /k"
        # command_1 = "echo ERROR: Number of names and values of inputted generic parameters does not match. Check your command-line arguments."
        # os.system(command_open_cmd + " " + command_1)
        error = 1
        
        
    # Launch the GUI
    guiLayout.root_window(
        error,
        verbose,
        geometry,
        proj_name, proj_dir, output_dir,
        generic_names, generic_vals
    )


# ----- Executors -----
if __name__ == "__main__":
    main(sys.argv)