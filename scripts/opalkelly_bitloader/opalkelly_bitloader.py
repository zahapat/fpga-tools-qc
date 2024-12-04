# This file must be present in the ./output directory

import os
import hashlib

# Locate target bitfile in the outputs directory, create command-line arguments for an csv_readout.exe script to program Opal Kelly FPGA harnessing OK Frontpanel API
def opalkelly_bitloader(design_id, fullpath_to_outputs_dir, generic_parameters_values, QUBITS_COUNT, COMMIT_HASH_SHORT, TOP, RUN_READOUT_SECONDS, PROGRAM_ONLY):

    # Construct the bitfile name
    bitfile_name = f"bitfile_{TOP}.bit"

    # Construct the build directory name if not specified in 'design_id'
    if ((design_id != None) or (design_id != "")):
        make_command = "make"
        build_dir_name = ""
        for (i, gen_val) in enumerate(generic_parameters_values):
            if ((gen_val != "") or (gen_val != None)):
                i+=1
                make_command = make_command + f" GEN{i}_VAL={gen_val}"
                build_dir_name = build_dir_name + f"_{gen_val}"

        build_dir_name = str(build_dir_name).replace('_', '', 1)
        build_dir_name_md5 = hashlib.md5(build_dir_name.encode('utf-8')).hexdigest()
    else:
        build_dir_name = design_id
        build_dir_name_md5 = design_id

    # Pick the right folder with the desired commit hash
    dir_commit_id = list(filter(lambda item: item.endswith(f"_@{COMMIT_HASH_SHORT}"), 
                                os.listdir(fullpath_to_outputs_dir)))[0]
    print(f"dir_commit_id = {dir_commit_id}")

    # Construct the path to the target bitfile
    design_output_dir_is_md5_hash = True
    if design_output_dir_is_md5_hash:
        target_bitfile_path = os.path.normpath(f"{fullpath_to_outputs_dir}\{dir_commit_id}\{TOP}\{build_dir_name_md5}")
    else:
        target_bitfile_path = os.path.normpath(f"{fullpath_to_outputs_dir}\{dir_commit_id}\{TOP}\{build_dir_name}")
    print(f"target_bitfile_path = {target_bitfile_path}")

    # Check if the bitfile exists
    target_bitfile_path_exists = os.path.exists(target_bitfile_path)
    print(f"target_bitfile_path_exists = {target_bitfile_path_exists}")


    # Do not launch the .exe file if file path does not exist
    if os.path.exists(f"{target_bitfile_path}\{bitfile_name}"):
        keep_cmd_window_open = False
        keep_window_open = "/c "
        if keep_cmd_window_open:
            keep_window_open = "/k "
        command_cmd_window = "start /wait cmd " + keep_window_open
        launch_ok_csv_readout_exe = f"..\csv_readout_debug_@{COMMIT_HASH_SHORT}.exe"
        launch_ok_csv_readout_args = f"--qubits_count {QUBITS_COUNT} --float_run_time_seconds {RUN_READOUT_SECONDS} --bitfile_name {bitfile_name} --program_only {PROGRAM_ONLY}"
        goto_directory_and_launch_cmd = f"cd {target_bitfile_path} && pwd && ls && {launch_ok_csv_readout_exe} {launch_ok_csv_readout_args}"
        timeout_before_exit = " & timeout /t 6"
        
        # Launch the .exe file
        os.system(
            command_cmd_window + "\"" + goto_directory_and_launch_cmd + timeout_before_exit + "\""
        )

    else:
        # Launch the .exe file
        emptyline = "echo("
        error_message_line1 = f"echo ERROR: The specified file path does not exist:"
        error_message_line2 = f"echo {target_bitfile_path}\{bitfile_name}"
        help_message_line1 = f"echo NOTE: Run the following make command to generate the bitfile:"
        help_message_line2 = f"echo {make_command}"
        help_message_line3 = f"echo NOTE: Make sure the bitfile is placed in the following folder:"
        help_message_line4 = f"echo {target_bitfile_path}"
        help_message_line5 = f"echo NOTE: And is named:"
        help_message_line6 = f"echo {bitfile_name}"
        help_message_line7 = f"echo NOTE: Open the following file to view which generic parameters can be set using this bitfile loader:"
        help_message_line8 = f"echo {fullpath_to_outputs_dir}\\{dir_commit_id}\\{TOP}\\list_all_designs.csv"

        os.system(
            "start /wait cmd /k " +\
            f"\"" +\
            f"{error_message_line1} & {error_message_line2}" +\
            f" & {emptyline} & " +\
            f"{help_message_line1} & {help_message_line2}" +\
            f" & {emptyline} & " +\
            f"{help_message_line3} & {help_message_line4}" +\
            f" & {emptyline} & " +\
            f"{help_message_line5} & {help_message_line6}" +\
            f" & {emptyline} & " +\
            f"{help_message_line7} & {help_message_line8}" +\
            f"\""
        )



# ---------------------------------------------------------------------
#  Enter the full path to outputs directory (where bitfiles are stored)
# ---------------------------------------------------------------------
FULLPATH_TO_OUTPUTS_DIR = "C:\\Git\\zahapat\\fpga-tools-qc\\outputs"



# ---------------------------------------------------------------------
#  Switches between different commits and 
# ---------------------------------------------------------------------
# Switch to bitfile sets generated at different commits
# COMMIT_HASH_SHORT = "428d99b"
COMMIT_HASH_SHORT = "bf92d0a"

# Switch to a differet projects at a given commit
TOP = "top_gflow"



# ---------------------------------------------------------------------
#  Set design parameters to select the bitfile to program the FPGA with
# ---------------------------------------------------------------------
# DESIGN_ID = "4dc0fe311d299c340e63f3bf4937e398" # Pick specific design's MD5 Hash listed in the file 'list_all_designs.csv'
DESIGN_ID = None                                 # Set to: "" or None to select design based on the parameters below

# Set names and values for generic variables
GEN1_VAL = 0        # INT_EMULATE_INPUTS
GEN2_VAL = 4        # INT_QUBITS_CNT

# Photon Delays:
# TLDR: Enter a real number without decimal separator in INT_ALL_DIGITS_PHOTON_XY_DELAY_NS. 
#       Then specify the number of whole digits in INT_WHOLE_DIGITS_CNT_PHOTON_XY_DELAY to reconstruct the real number in the design.
# INT_ALL_DIGITS_PHOTON_XY_DELAY_NS:
#     - Input a positive/negative integer such that it contains both the whole and decimal part of a real number:
#       (e.g. 440.800 -> 440800 (or 4408, preferably without trailing/leading zeros))
#       (e.g. -0.0044 -> -00044 (or -44, preferably without trailing/leading zeros))

# INT_WHOLE_DIGITS_CNT_PHOTON_XY_DELAY:
#     - Positive number specifies the number of whole digits in 'INT_ALL_DIGITS'
#       (e.g. INT_ALL_DIGITS=4408 & INT_WHOLE_DIGITS_CNT=3 -> 440.8)
#       (e.g. INT_ALL_DIGITS=-44  & INT_WHOLE_DIGITS_CNT=1 -> -4.4)
#     - Negative number adds leading zeros to 'INT_ALL_DIGITS'
#       (e.g. INT_ALL_DIGITS=4408 & INT_WHOLE_DIGITS_CNT=-3 -> 0.0004408)
#       (e.g. INT_ALL_DIGITS=-44  & INT_WHOLE_DIGITS_CNT=-1 -> -0.044)
#     - Zero will create a decimal number: 0.'INT_ALL_DIGITS'
#       (e.g. INT_ALL_DIGITS=4408 & INT_WHOLE_DIGITS_CNT=0 -> 0.4408)
#       (e.g. INT_ALL_DIGITS=-44  & INT_WHOLE_DIGITS_CNT=0 -> -0.44)
# Qubit 1H
GEN3_VAL = 7565     # INT_ALL_DIGITS_PHOTON_1H_DELAY_NS
GEN4_VAL = 2        # INT_WHOLE_DIGITS_CNT_PHOTON_1H_DELAY
# Qubit 1V
GEN5_VAL = 7501     # INT_ALL_DIGITS_PHOTON_1V_DELAY_NS
GEN6_VAL = 2        # INT_WHOLE_DIGITS_CNT_PHOTON_1V_DELAY

# Qubit 2H
GEN7_VAL = -103095  # INT_ALL_DIGITS_PHOTON_2H_DELAY_NS
GEN8_VAL = 4        # INT_WHOLE_DIGITS_CNT_PHOTON_2H_DELAY
# Qubit 2V
GEN9_VAL = -103435  # INT_ALL_DIGITS_PHOTON_2V_DELAY_NS
GEN10_VAL = 4       # INT_WHOLE_DIGITS_CNT_PHOTON_2V_DELAY

# Qubit 3H
GEN11_VAL = -211735 # INT_ALL_DIGITS_PHOTON_3H_DELAY_NS
GEN12_VAL = 4       # INT_WHOLE_DIGITS_CNT_PHOTON_3H_DELAY
# Qubit 3V
GEN13_VAL = -212545 # INT_ALL_DIGITS_PHOTON_3V_DELAY_NS
GEN14_VAL = 4       # INT_WHOLE_DIGITS_CNT_PHOTON_3V_DELAY

# Qubit 4H
GEN15_VAL = -317795 # INT_ALL_DIGITS_PHOTON_4H_DELAY_NS
GEN16_VAL = 4       # INT_WHOLE_DIGITS_CNT_PHOTON_4H_DELAY
# Qubit 4V
GEN17_VAL = -31810  # INT_ALL_DIGITS_PHOTON_4V_DELAY_NS
GEN18_VAL = 4       # INT_WHOLE_DIGITS_CNT_PHOTON_4V_DELAY

# Qubit 5H
GEN19_VAL = -41771  # INT_ALL_DIGITS_PHOTON_5H_DELAY_NS
GEN20_VAL = 4       # INT_WHOLE_DIGITS_CNT_PHOTON_5H_DELAY
# Qubit 5V
GEN21_VAL = -41811  # INT_ALL_DIGITS_PHOTON_5V_DELAY_NS
GEN22_VAL = 4       # INT_WHOLE_DIGITS_CNT_PHOTON_5V_DELAY

# Qubit 6H
GEN23_VAL = -51771  # INT_ALL_DIGITS_PHOTON_6H_DELAY_NS
GEN24_VAL = 4       # INT_WHOLE_DIGITS_CNT_PHOTON_6H_DELAY
# Qubit 6V
GEN25_VAL = -51811  # INT_ALL_DIGITS_PHOTON_6V_DELAY_NS
GEN26_VAL = 4       # INT_WHOLE_DIGITS_CNT_PHOTON_6V_DELAY

# Control Pulse High Duration (Nanoseconds)
GEN27_VAL = 100     # INT_CTRL_PULSE_HIGH_DURATION_NS

# Control Pulse Low Duration (Nanoseconds)
GEN28_VAL = 50      # INT_CTRL_PULSE_DEAD_DURATION_NS

# Control Pulse Delay Duration (Nanoseconds)
GEN29_VAL = 0       # INT_CTRL_PULSE_EXTRA_DELAY_NS

# Skip Feedforward Qubits Control After Successful General Flow
GEN30_VAL = 0       # INT_DISCARD_QUBITS_TIME_NS

# Create a list out of all generic values
generic_parameters_values = [GEN1_VAL,GEN2_VAL,GEN3_VAL,GEN4_VAL,GEN5_VAL,
                             GEN6_VAL,GEN7_VAL,GEN8_VAL,GEN9_VAL,GEN10_VAL,
                             GEN11_VAL,GEN12_VAL,GEN13_VAL,GEN14_VAL,GEN15_VAL,
                             GEN16_VAL,GEN17_VAL,GEN18_VAL,GEN19_VAL,GEN20_VAL,
                             GEN21_VAL,GEN22_VAL,GEN23_VAL,GEN24_VAL,GEN25_VAL,
                             GEN26_VAL,GEN27_VAL,GEN28_VAL,GEN29_VAL,GEN30_VAL]


# ---------------------------------------------------------------------
#  Run the programmer and readout script with OK Frontpanel API
# ---------------------------------------------------------------------
# Verify the outputs directory location variable
if ((FULLPATH_TO_OUTPUTS_DIR == "") or (FULLPATH_TO_OUTPUTS_DIR == None)):
    raise ValueError(f"PY: ERROR: Variable FULLPATH_TO_OUTPUTS_DIR = {FULLPATH_TO_OUTPUTS_DIR} is invalid.")
elif (not(os.path.exists(FULLPATH_TO_OUTPUTS_DIR))):
    raise ValueError(
        f"PY: ERROR: Unable to find path specified for FULLPATH_TO_OUTPUTS_DIR = {FULLPATH_TO_OUTPUTS_DIR}. Make sure you entered a valid win path and that you escaped all backslashes."
    )
else:
    # Readout API parameters
    RUN_READOUT_SECONDS = 10.1
    PROGRAM_ONLY = True

    opalkelly_bitloader(
        design_id=DESIGN_ID,
        fullpath_to_outputs_dir=FULLPATH_TO_OUTPUTS_DIR,
        generic_parameters_values=generic_parameters_values, 
        QUBITS_COUNT=GEN2_VAL, 
        COMMIT_HASH_SHORT=COMMIT_HASH_SHORT, 
        TOP=TOP, 
        RUN_READOUT_SECONDS=RUN_READOUT_SECONDS, 
        PROGRAM_ONLY=PROGRAM_ONLY
    )