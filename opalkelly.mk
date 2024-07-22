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

# Last git commit shortened hash and timestamp
LAST_GIT_COMMIT_HASH = $(shell eval "git log --pretty=format:'%h' -n 1")

# Default Executable CLI arguments which can be modified
QUBITS_CNT = 4
RUN_TIME_SECONDS = 10.1
BITFILE_NAME = bitfile.bit


# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:

.PHONY: rename_artifacts ok_rescan_csv_readout ok_prog_csv_readout ok_run_csv_readout_debug ok_run_csv_readout_release

# Rescan, name artifacts according to the current commit hash
rename_artifacts:
	@mv $(CSV_READOUT_DIR)/build/Debug/csv_readout.exe $(CSV_READOUT_DIR)/build/Debug/csv_readout_debug_@$(LAST_GIT_COMMIT_HASH).exe
	@mv $(CSV_READOUT_DIR)/build/Release/csv_readout.exe $(CSV_READOUT_DIR)/build/Release/csv_readout_release_@$(LAST_GIT_COMMIT_HASH).exe

$(CSV_READOUT_DIR)/build/Debug/csv_readout_debug_@$(LAST_GIT_COMMIT_HASH).exe:
	@cd $(CSV_READOUT_DIR) ; make rescan ; cd $(PROJ_DIR) ; $(MAKE) -f opalkelly.mk rename_artifacts

$(CSV_READOUT_DIR)/build/Release/csv_readout_release_@$(LAST_GIT_COMMIT_HASH).exe:
	@cd $(CSV_READOUT_DIR) ; make rescan ; cd $(PROJ_DIR) ; $(MAKE) -f opalkelly.mk rename_artifacts

ok_rescan_csv_readout: $(CSV_READOUT_DIR)/build/Debug/csv_readout_debug_@$(LAST_GIT_COMMIT_HASH).exe $(CSV_READOUT_DIR)/build/Release/csv_readout_release_@$(LAST_GIT_COMMIT_HASH).exe
	@echo -------------------------------------------
	@echo Target $@ is up-to-date.
	@echo -------------------------------------------

ok_force_rescan_csv_readout:
	@cd $(CSV_READOUT_DIR) ; make rescan ; cd $(PROJ_DIR) ; $(MAKE) -f opalkelly.mk rename_artifacts
	@cd $(PROJ_DIR); $(MAKE) -f opalkelly.mk ok_rescan_csv_readout

# Generate a vhdl/verilog file with Generic variables
ok_prog_csv_readout: $(CSV_READOUT_DIR)/build/Debug/csv_readout_debug_@$(LAST_GIT_COMMIT_HASH).exe $(OUTPUT_DIR)/$(BITFILE_NAME)
	@cd $(OUTPUT_DIR)
	pwd
	$< --qubits_count $(QUBITS_CNT) \
		--float_run_time_seconds 0 \
		--bitfile_name $(BITFILE_NAME) \
		--program_only true

# Execute the csv_readout.exe in debug mode
ok_run_csv_readout_debug: $(CSV_READOUT_DIR)/build/Debug/csv_readout_debug_@$(LAST_GIT_COMMIT_HASH).exe
	@cd $(OUTPUT_DIR)
	pwd
	$< --qubits_count $(QUBITS_CNT) \
		--float_run_time_seconds $(RUN_TIME_SECONDS) \
		--bitfile_name $(BITFILE_NAME) \
		--program_only false

# Execute the csv_readout.exe in release version
ok_run_csv_readout_release: $(CSV_READOUT_DIR)/build/Release/csv_readout_release_@$(LAST_GIT_COMMIT_HASH).exe
	@cd $(OUTPUT_DIR)
	pwd
	$< --qubits_count $(QUBITS_CNT) \
		--float_run_time_seconds $(RUN_TIME_SECONDS) \
		--bitfile_name $(BITFILE_NAME) \
		--program_only false