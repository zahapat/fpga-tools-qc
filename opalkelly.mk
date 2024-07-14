# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
#  Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

# Output dir already contains .bit file
OUTPUT_DIR = $(PROJ_DIR)scripts/gui/csv_readout

# CSV readout folder containing subdirectories with Debug and Release executables 'csv_readout.exe' utilising Opal Kelly API
CSV_READOUT_DIR = $(PROJ_DIR)scripts/gui/csv_readout

# Default Executable CLI arguments which can be modified
QUBITS_CNT = 4
RUN_TIME_SECONDS = 10.1
BITFILE_NAME = bitfile.bit


# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:

# Generate a vhdl/verilog file with Generic variables
ok_prog: $(CSV_READOUT_DIR)/build/Debug/csv_readout.exe $(OUTPUT_DIR)/$(BITFILE_NAME)
	@cd $(OUTPUT_DIR)
	pwd
	$< --qubits_count $(QUBITS_CNT) \
		--float_run_time_seconds 0 \
		--bitfile_name $(BITFILE_NAME) \
		--program_only true

# Execute the csv_readout.exe in debug mode
ok_read_debug: $(CSV_READOUT_DIR)/build/Debug/csv_readout.exe $(OUTPUT_DIR)/$(BITFILE_NAME)
	@cd $(OUTPUT_DIR)
	pwd
	$< --qubits_count $(QUBITS_CNT) \
		--float_run_time_seconds $(RUN_TIME_SECONDS) \
		--bitfile_name $(BITFILE_NAME) \
		--program_only false

# Execute the csv_readout.exe in release version
ok_read_release: $(CSV_READOUT_DIR)/build/Release/csv_readout.exe $(OUTPUT_DIR)/$(BITFILE_NAME)
	@cd $(OUTPUT_DIR)
	pwd
	$< --qubits_count $(QUBITS_CNT) \
		--float_run_time_seconds $(RUN_TIME_SECONDS) \
		--bitfile_name $(BITFILE_NAME) \
		--program_only false