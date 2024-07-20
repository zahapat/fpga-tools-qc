# Usage Examples:
# make gacp MSG="fix: Enable commit msg from cli"  <--- YOU  MUST enter the commit message in quotation marks

# Requires Github CLI + git installed


# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
# Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(dir $(abspath $(firstword $(MAKEFILE_LIST))))


# Timer
TIMESTAMP_UTC = $$(date -u +%FT%T%Z)
TIMESTAMP_ACT_TZONE = $$(date +%FT%T%Z)
DATE_ACT_UTC = $$(date -u +%FT%Z)
DATE_ACT_TZONE = $$(date +%FT%Z)
TIMER_START  := $(shell date "+%s")
TIMER_END     = $(shell date "+%s")
TIMER_SECONDS = $(shell expr $(TIMER_END) - $(TIMER_START))
TIMER_FORMAT  = $(shell date --utc --date="@$(TIMER_SECONDS)" "+%H:%M:%S")


# Links to related Makefiles
PROJECT_SPECIFIC_MAKEFILE = project_specific.mk
GENERIC_MAKEFILE = generic.mk
VIVADO_MAKEFILE = vivado.mk
SIM_MAKEFILE = sim.mk
VITIS_MAKEFILE = vitis.mk
GIT_MAKEFILE = git.mk
OPALKELLY_MAKEFILE = opalkelly.mk
PACKAGES_MAKEFILE = packages.mk


# Project author details
ENGINEER ?= patrik_zahalka
EMAIL ?= patrik.zahalka@univie.ac.at


# Last git commit shortened hash and timestamp
LAST_GIT_COMMIT_HASH = $(shell eval "git log --pretty=format:'%h' -n 1")
LAST_GIT_COMMIT_TIMESTAMP = $(shell eval "git show --no-patch --format=%cs $(LAST_GIT_COMMIT_HASH)")


# Libraries for HDL sources and testbenches
LIB_SRC ?= lib_src
LIB_SIM ?= lib_sim


# [make new_module]: Architecture type, generate extra files
ARCH ?= rtl
EXTRA ?= none


# [make src] Actual top module you are working with
TOP ?= top_gflow


# Readout parameters
RUN_READOUT_SECONDS = 10.1


# [make generics] Set names and values for generic variables
GEN1_NAME ?= INT_EMULATE_INPUTS
GEN1_VAL ?= 0

GEN2_NAME ?= INT_QUBITS_CNT
GEN2_VAL ?= 4

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
GEN3_NAME ?= INT_ALL_DIGITS_PHOTON_1H_DELAY_NS
GEN3_VAL ?= 756501
GEN4_NAME ?= INT_WHOLE_DIGITS_CNT_PHOTON_1H_DELAY
GEN4_VAL ?= 2
# Qubit 1V
GEN5_NAME ?= INT_ALL_DIGITS_PHOTON_1V_DELAY_NS
GEN5_VAL ?= 7501
GEN6_NAME ?= INT_WHOLE_DIGITS_CNT_PHOTON_1V_DELAY
GEN6_VAL ?= 2

# Qubit 2H
GEN7_NAME ?= INT_ALL_DIGITS_PHOTON_2H_DELAY_NS
GEN7_VAL ?= -103095
GEN8_NAME ?= INT_WHOLE_DIGITS_CNT_PHOTON_2H_DELAY
GEN8_VAL ?= 4
# Qubit 2V
GEN9_NAME ?= INT_ALL_DIGITS_PHOTON_2V_DELAY_NS
GEN9_VAL ?= -103435
GEN10_NAME ?= INT_WHOLE_DIGITS_CNT_PHOTON_2V_DELAY
GEN10_VAL ?= 4

# Qubit 3H
GEN11_NAME ?= INT_ALL_DIGITS_PHOTON_3H_DELAY_NS
GEN11_VAL ?= -211735
GEN12_NAME ?= INT_WHOLE_DIGITS_CNT_PHOTON_3H_DELAY
GEN12_VAL ?= 4
# Qubit 3V
GEN13_NAME ?= INT_ALL_DIGITS_PHOTON_3V_DELAY_NS
GEN13_VAL ?= -212545
# GEN13_VAL ?= -212745
GEN14_NAME ?= INT_WHOLE_DIGITS_CNT_PHOTON_3V_DELAY
GEN14_VAL ?= 4

# Qubit 4H
GEN15_NAME ?= INT_ALL_DIGITS_PHOTON_4H_DELAY_NS
GEN15_VAL ?= -317795
GEN16_NAME ?= INT_WHOLE_DIGITS_CNT_PHOTON_4H_DELAY
GEN16_VAL ?= 4
# Qubit 4V
GEN17_NAME ?= INT_ALL_DIGITS_PHOTON_4V_DELAY_NS
GEN17_VAL ?= -31810
# GEN17_VAL ?= -31920
GEN18_NAME ?= INT_WHOLE_DIGITS_CNT_PHOTON_4V_DELAY
GEN18_VAL ?= 4

# Qubit 5H
GEN19_NAME ?= INT_ALL_DIGITS_PHOTON_5H_DELAY_NS
GEN19_VAL ?= -41771
GEN20_NAME ?= INT_WHOLE_DIGITS_CNT_PHOTON_5H_DELAY
GEN20_VAL ?= 4
# Qubit 5V
GEN21_NAME ?= INT_ALL_DIGITS_PHOTON_5V_DELAY_NS
GEN21_VAL ?= -41811
GEN22_NAME ?= INT_WHOLE_DIGITS_CNT_PHOTON_5V_DELAY
GEN22_VAL ?= 4

# Qubit 6H
GEN23_NAME ?= INT_ALL_DIGITS_PHOTON_6H_DELAY_NS
GEN23_VAL ?= -51771
GEN24_NAME ?= INT_WHOLE_DIGITS_CNT_PHOTON_6H_DELAY
GEN24_VAL ?= 4
# Qubit 6V
GEN25_NAME ?= INT_ALL_DIGITS_PHOTON_6V_DELAY_NS
GEN25_VAL ?= -51811
GEN26_NAME ?= INT_WHOLE_DIGITS_CNT_PHOTON_6V_DELAY
GEN26_VAL ?= 4

# Control Pulse High Duration (Nanoseconds)
GEN27_NAME ?= INT_CTRL_PULSE_HIGH_DURATION_NS
GEN27_VAL ?= 100

# Control Pulse Low Duration (Nanoseconds)
GEN28_NAME ?= INT_CTRL_PULSE_DEAD_DURATION_NS
GEN28_VAL ?= 50

# Control Pulse Delay Duration (Nanoseconds)
GEN29_NAME ?= INT_CTRL_PULSE_EXTRA_DELAY_NS
GEN29_VAL ?= 0

# Skip Feedforward Qubits Control After Successful General Flow
GEN30_NAME ?= INT_DISCARD_QUBITS_TIME_NS
GEN30_VAL ?= 0

# Append additional generic parameters here ...
# GEN31_NAME ?= <INT_GENERIC_NAME>
# GEN31_VAL ?= <integer value>#Must be an integer, it is possible to perform int to real conversion (see the above method)


# Prameters for naming output build subdirectories and .bit files ('make reset' will not affect the entire folder)
CSV_LIST_ALL_DESIGNS := list_all_designs.csv
TARGET_NAME_GENERIC_NAMES := $(GEN1_NAME),$(GEN2_NAME),$(GEN3_NAME),$(GEN4_NAME),$(GEN5_NAME),$(GEN6_NAME),$(GEN7_NAME),$(GEN8_NAME),$(GEN9_NAME),$(GEN10_NAME),$(GEN11_NAME),$(GEN12_NAME),$(GEN13_NAME),$(GEN14_NAME),$(GEN15_NAME),$(GEN16_NAME),$(GEN17_NAME),$(GEN18_NAME),$(GEN19_NAME),$(GEN20_NAME),$(GEN21_NAME),$(GEN22_NAME),$(GEN23_NAME),$(GEN24_NAME),$(GEN25_NAME),$(GEN26_NAME),$(GEN27_NAME),$(GEN28_NAME),$(GEN29_NAME),$(GEN30_NAME)
TARGET_NAME_GENERIC_VALS := $(GEN1_VAL)_$(GEN2_VAL)_$(GEN3_VAL)_$(GEN4_VAL)_$(GEN5_VAL)_$(GEN6_VAL)_$(GEN7_VAL)_$(GEN8_VAL)_$(GEN9_VAL)_$(GEN10_VAL)_$(GEN11_VAL)_$(GEN12_VAL)_$(GEN13_VAL)_$(GEN14_VAL)_$(GEN15_VAL)_$(GEN16_VAL)_$(GEN17_VAL)_$(GEN18_VAL)_$(GEN19_VAL)_$(GEN20_VAL)_$(GEN21_VAL)_$(GEN22_VAL)_$(GEN23_VAL)_$(GEN24_VAL)_$(GEN25_VAL)_$(GEN26_VAL)_$(GEN27_VAL)_$(GEN28_VAL)_$(GEN29_VAL)_$(GEN30_VAL)
TARGET_NAME_MD5_HASH := $(shell printf '%s' '$(TARGET_NAME_GENERIC_VALS)' | md5sum | cut -d ' ' -f 1)
TARGET_OUTPUT_DIR := $(PROJ_DIR)outputs# or C:\fpga\outputs
TARGET_OUTPUT_DIR_ARTIFACTS := $(TARGET_OUTPUT_DIR)/$(LAST_GIT_COMMIT_TIMESTAMP)_@$(LAST_GIT_COMMIT_HASH)/$(TOP)/$(TARGET_NAME_MD5_HASH)
BITFILE_NAME := bitfile_$(TOP)


# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:



# -------------------------------------------------------------
#  Default target (everyone should be able to run this target)
# -------------------------------------------------------------
# Default Target: Reset -> Create Pre-build files -> Add SRCs -> Compile -> Generate Bitstream -> Save Outputs -> Distribute Bitfiles -> Attempt to program the FPGA
# Note: Vivado, Python, Cygwin and Makefile are required to run 'make'
$(TARGET_OUTPUT_DIR_ARTIFACTS)/$(BITFILE_NAME).bit:
	@$(MAKE) reset essentials generics src all get_vivado_outputs timer


# -------------------------------------------------------------
#  Provisional targets - changing dynamically over time
# -------------------------------------------------------------
# Build: compile C++ files, build FPGA design if output have not been created + attempt to program the FPGA
# Note: Vivado, Visual Studio, ModelSim, Cygwin and Makefile are required to run 'make build'
build:
	@$(MAKE) ok_rescan_csv_readout 
	@$(MAKE) $(TARGET_OUTPUT_DIR_ARTIFACTS)/$(BITFILE_NAME).bit
	@$(MAKE) get_ok_cpp_outputs ok_run_csv_readout_debug

# Force re-build: force (re-)compile C++ files, (re-)build the desired design + attempt to program the FPGA
# Note: Vivado, Visual Studio, ModelSim, Cygwin and Makefile are required to run 'make rebuild'
rebuild:
	@$(MAKE) ok_force_rescan_csv_readout
	@$(MAKE) reset essentials generics src all get_vivado_outputs timer
	@$(MAKE) get_ok_cpp_outputs ok_run_csv_readout_debug

# Get Vivado output files with *.rpt and .bit artifacts, copy them to the output directory (defined by TARGET_OUTPUT_DIR_ARTIFACTS variable)
get_vivado_outputs: ./vivado/3_bitstream_$(PROJ_NAME).bit
	@mkdir -p $(TARGET_OUTPUT_DIR_ARTIFACTS)
	@$(MAKE) params_to_csv
	@cp -r $(PROJ_DIR)vivado/3_bitstream_$(PROJ_NAME).bit $(TARGET_OUTPUT_DIR_ARTIFACTS)/$(BITFILE_NAME).bit
	@cp -r $(PROJ_DIR)vivado/*.rpt $(TARGET_OUTPUT_DIR_ARTIFACTS)

# Get Opal Lelly latest artifacts
CSV_READOUT_DIR = $(PROJ_DIR)scripts/gui/csv_readout
get_ok_cpp_outputs: $(CSV_READOUT_DIR)/build/Debug/csv_readout_debug_@$(LAST_GIT_COMMIT_HASH).exe $(CSV_READOUT_DIR)/build/Release/csv_readout_release_@$(LAST_GIT_COMMIT_HASH).exe
	@mkdir -p $(TARGET_OUTPUT_DIR_ARTIFACTS)
	@cp -r $(CSV_READOUT_DIR)/build/Release/csv_readout_release_@$(LAST_GIT_COMMIT_HASH).exe $(TARGET_OUTPUT_DIR_ARTIFACTS)/../csv_readout_release_@$(LAST_GIT_COMMIT_HASH).exe
	@cp -r $(CSV_READOUT_DIR)/build/Debug/csv_readout_debug_@$(LAST_GIT_COMMIT_HASH).exe $(TARGET_OUTPUT_DIR_ARTIFACTS)/../csv_readout_debug_@$(LAST_GIT_COMMIT_HASH).exe
	@cp -r $(CSV_READOUT_DIR)/lib/okFrontPanel.dll $(TARGET_OUTPUT_DIR_ARTIFACTS)/../okFrontPanel.dll


print_directories_outputs:
	@dirs=$$(cd $(TARGET_OUTPUT_DIR_ARTIFACTS)/../ && ls -d */)
	@for d in $$dirs; do \
		dir=$${d%/}; \
		ndir=$$(echo $${dir} | tr _ ,); \
		echo "$${ndr}"; \
	done

$(TARGET_OUTPUT_DIR_ARTIFACTS)/../$(CSV_LIST_ALL_DESIGNS): 
	cd $(TARGET_OUTPUT_DIR_ARTIFACTS)/../ && touch $(CSV_LIST_ALL_DESIGNS) \
	&& echo "MD5 Hash,$(TARGET_NAME_GENERIC_NAMES)" >> $(TARGET_OUTPUT_DIR_ARTIFACTS)/../$(CSV_LIST_ALL_DESIGNS)

params_to_csv: $(TARGET_OUTPUT_DIR_ARTIFACTS)/../$(CSV_LIST_ALL_DESIGNS)
	@params_appended=0 
	@cd $(TARGET_OUTPUT_DIR_ARTIFACTS)/../
	@while IFS= read -r fline; do \
		if [[ $${fline} == $(TARGET_NAME_MD5_HASH)* ]]; then \
			echo "INFO: Design $(TARGET_NAME_MD5_HASH) has been already generated. Do not modify $(CSV_LIST_ALL_DESIGNS)"; \
			params_appended=1; \
		fi; \
	done < $(CSV_LIST_ALL_DESIGNS)
	@if [ $${params_appended} == 0 ]; then \
		newline=$$( echo $(TARGET_NAME_MD5_HASH)_$(TARGET_NAME_GENERIC_VALS) | tr _ , ); \
		$$( echo $${newline} >> $(TARGET_OUTPUT_DIR_ARTIFACTS)/../$(CSV_LIST_ALL_DESIGNS) ); \
	fi


# "Build over Loop": Building hardware using a loop by assigning a loop variable 'i' to the desired generic parameter
# Example: make loop LOOP_VALS="50 75 100" GEN_NUM=28 
#    Note: GEN28_NAME is INT_CTRL_PULSE_DEAD_DURATION_NS
loop:
	@for i in $(LOOP_VALS); do \
		@$(MAKE) build GEN${GEN_NUM}_VAL=$$i; \
	done

# "Build Enumerated": Building hardware with parameters specified in an enumerated manner
# The below is an example and needs to be modified
# RUN AFTER EVERY git push to generate a fresh new set of bitfiles in 'outputs' directory
enum:
	@$(MAKE) build
	@$(MAKE) build GEN28_VAL=50 GEN1_VAL=1
	@$(MAKE) build GEN28_VAL=50 GEN1_VAL=0
	@$(MAKE) build GEN28_VAL=75 GEN1_VAL=1
	@$(MAKE) build GEN28_VAL=75 GEN1_VAL=0
	@$(MAKE) build GEN28_VAL=100 GEN1_VAL=1
	@$(MAKE) build GEN28_VAL=100 GEN1_VAL=0
	@$(MAKE) build GEN28_VAL=50 RUN_READOUT_SECONDS=10.1
	@$(MAKE) build GEN28_VAL=75 GEN1_VAL=0 RUN_READOUT_SECONDS=20.5
	@$(MAKE) build GEN28_VAL=100 GEN1_VAL=0 RUN_READOUT_SECONDS=30.5



# -------------------------------------------------------------
#  "project_specific.mk" targets
# -------------------------------------------------------------
init:
	@$(MAKE) -f $(PROJECT_SPECIFIC_MAKEFILE) $@
distribute_bitfiles:
	@$(MAKE) -f $(PROJECT_SPECIFIC_MAKEFILE) $@
cmd_timeout:
	@$(MAKE) -f $(PROJECT_SPECIFIC_MAKEFILE) $@



# -------------------------------------------------------------
#  "vivado.mk" targets
# -------------------------------------------------------------
reset:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
new:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
new_module:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
src:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@ TOP=$(TOP)
board:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
declare:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
ooc:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
synth:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
impl:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
outd:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
bit:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
xsa:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
prog:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
probes:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
ila:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
all:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
old:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
clean:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
gui:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
core:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
ip:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@



# -------------------------------------------------------------
#  "sim.mk" targets
# -------------------------------------------------------------
sim_init:
	@$(MAKE) -f $(SIM_MAKEFILE) $@
sim_reset:
	@$(MAKE) -f $(SIM_MAKEFILE) $@ LIB_SRC=$(LIB_SRC) LIB_SIM=$(LIB_SIM)
sim:
	@$(MAKE) -f $(SIM_MAKEFILE) $@ LIB_SRC=$(LIB_SRC) LIB_SIM=$(LIB_SIM)
sim_gui:
	@$(MAKE) -f $(SIM_MAKEFILE) $@ LIB_SRC=$(LIB_SRC) LIB_SIM=$(LIB_SIM)
compile:
	@$(MAKE) -f $(SIM_MAKEFILE) $@ LIB_SRC=$(LIB_SRC) LIB_SIM=$(LIB_SIM)



# -------------------------------------------------------------
#  "vitis.mk" targets
# -------------------------------------------------------------
# Generic Vitis Targets
remove_vitis:
	@$(MAKE) -f $(VITIS_MAKEFILE) $@
remove_ws_vitis:
	@$(MAKE) -f $(VITIS_MAKEFILE) $@
new_vitis:
	@$(MAKE) -f $(VITIS_MAKEFILE) $@
new_app_vitis:
	@$(MAKE) -f $(VITIS_MAKEFILE) $@
add_sources_vitis:
	@$(MAKE) -f $(VITIS_MAKEFILE) $@
gui_vitis:
	@$(MAKE) -f $(VITIS_MAKEFILE) $@
bsp_regen_vitis:
	@$(MAKE) -f $(VITIS_MAKEFILE) $@
reset_vitis:
	@$(MAKE) -f $(VITIS_MAKEFILE) $@
all_vitis:
	@$(MAKE) -f $(VITIS_MAKEFILE) $@



# -------------------------------------------------------------
#  "generic.mk" targets
# -------------------------------------------------------------
generics:
	@$(MAKE) -f $(GENERIC_MAKEFILE) $@ \
		GEN1_NAME=$(GEN1_NAME)   GEN1_VAL=$(GEN1_VAL) \
		GEN2_NAME=$(GEN2_NAME)   GEN2_VAL=$(GEN2_VAL) \
		GEN3_NAME=$(GEN3_NAME)   GEN3_VAL=$(GEN3_VAL) \
		GEN4_NAME=$(GEN4_NAME)   GEN4_VAL=$(GEN4_VAL) \
		GEN5_NAME=$(GEN5_NAME)   GEN5_VAL=$(GEN5_VAL) \
		GEN6_NAME=$(GEN6_NAME)   GEN6_VAL=$(GEN6_VAL) \
		GEN7_NAME=$(GEN7_NAME)   GEN7_VAL=$(GEN7_VAL) \
		GEN8_NAME=$(GEN8_NAME)   GEN8_VAL=$(GEN8_VAL) \
		GEN9_NAME=$(GEN9_NAME)   GEN9_VAL=$(GEN9_VAL) \
		GEN10_NAME=$(GEN10_NAME) GEN10_VAL=$(GEN10_VAL) \
		GEN11_NAME=$(GEN11_NAME) GEN11_VAL=$(GEN11_VAL) \
		GEN12_NAME=$(GEN12_NAME) GEN12_VAL=$(GEN12_VAL) \
		GEN13_NAME=$(GEN13_NAME) GEN13_VAL=$(GEN13_VAL) \
		GEN14_NAME=$(GEN14_NAME) GEN14_VAL=$(GEN14_VAL) \
		GEN15_NAME=$(GEN15_NAME) GEN15_VAL=$(GEN15_VAL) \
		GEN16_NAME=$(GEN16_NAME) GEN16_VAL=$(GEN16_VAL) \
		GEN17_NAME=$(GEN17_NAME) GEN17_VAL=$(GEN17_VAL) \
		GEN18_NAME=$(GEN18_NAME) GEN18_VAL=$(GEN18_VAL) \
		GEN19_NAME=$(GEN19_NAME) GEN19_VAL=$(GEN19_VAL) \
		GEN20_NAME=$(GEN20_NAME) GEN20_VAL=$(GEN20_VAL) \
		GEN21_NAME=$(GEN21_NAME) GEN21_VAL=$(GEN21_VAL) \
		GEN22_NAME=$(GEN22_NAME) GEN22_VAL=$(GEN22_VAL) \
		GEN23_NAME=$(GEN23_NAME) GEN23_VAL=$(GEN23_VAL) \
		GEN24_NAME=$(GEN24_NAME) GEN24_VAL=$(GEN24_VAL) \
		GEN25_NAME=$(GEN25_NAME) GEN25_VAL=$(GEN25_VAL) \
		GEN26_NAME=$(GEN26_NAME) GEN26_VAL=$(GEN26_VAL) \
		GEN27_NAME=$(GEN27_NAME) GEN27_VAL=$(GEN27_VAL) \
		GEN28_NAME=$(GEN28_NAME) GEN28_VAL=$(GEN28_VAL) \
		GEN29_NAME=$(GEN29_NAME) GEN29_VAL=$(GEN29_VAL) \
		GEN30_NAME=$(GEN30_NAME) GEN30_VAL=$(GEN30_VAL) \
		GEN31_NAME=$(GEN31_NAME) GEN31_VAL=$(GEN31_VAL) \
		GEN32_NAME=$(GEN32_NAME) GEN32_VAL=$(GEN32_VAL) \
		GEN33_NAME=$(GEN33_NAME) GEN33_VAL=$(GEN33_VAL) \
		GEN34_NAME=$(GEN34_NAME) GEN34_VAL=$(GEN34_VAL) \
		OUTPUT_DIR=$(PROJ_DIR)packages/global_src
essentials:
	@$(MAKE) -f $(GENERIC_MAKEFILE) $@ OUTPUT_DIR=$(PROJ_DIR)packages/global_sim
redis_start:
	@$(MAKE) -f $(GENERIC_MAKEFILE) $@
redis_stop:
	@$(MAKE) -f $(GENERIC_MAKEFILE) $@
vvc_gen:
	@$(MAKE) -f $(GENERIC_MAKEFILE) $@
py_gui_regen:
	@$(MAKE) -f $(GENERIC_MAKEFILE) $@
py_gui:
	@$(MAKE) -f $(GENERIC_MAKEFILE) $@ \
		GEN1_NAME=$(GEN1_NAME)   GEN1_VAL=$(GEN1_VAL) \
		GEN2_NAME=$(GEN2_NAME)   GEN2_VAL=$(GEN2_VAL) \
		GEN3_NAME=$(GEN3_NAME)   GEN3_VAL=$(GEN3_VAL) \
		GEN4_NAME=$(GEN4_NAME)   GEN4_VAL=$(GEN4_VAL) \
		GEN5_NAME=$(GEN5_NAME)   GEN5_VAL=$(GEN5_VAL) \
		GEN6_NAME=$(GEN6_NAME)   GEN6_VAL=$(GEN6_VAL) \
		GEN7_NAME=$(GEN7_NAME)   GEN7_VAL=$(GEN7_VAL) \
		GEN8_NAME=$(GEN8_NAME)   GEN8_VAL=$(GEN8_VAL) \
		GEN9_NAME=$(GEN9_NAME)   GEN9_VAL=$(GEN9_VAL) \
		GEN10_NAME=$(GEN10_NAME) GEN10_VAL=$(GEN10_VAL) \
		GEN11_NAME=$(GEN11_NAME) GEN11_VAL=$(GEN11_VAL) \
		GEN12_NAME=$(GEN12_NAME) GEN12_VAL=$(GEN12_VAL) \
		GEN13_NAME=$(GEN13_NAME) GEN13_VAL=$(GEN13_VAL) \
		GEN14_NAME=$(GEN14_NAME) GEN14_VAL=$(GEN14_VAL) \
		GEN15_NAME=$(GEN15_NAME) GEN15_VAL=$(GEN15_VAL) \
		GEN16_NAME=$(GEN16_NAME) GEN16_VAL=$(GEN16_VAL) \
		GEN17_NAME=$(GEN17_NAME) GEN17_VAL=$(GEN17_VAL) \
		GEN18_NAME=$(GEN18_NAME) GEN18_VAL=$(GEN18_VAL) \
		GEN19_NAME=$(GEN19_NAME) GEN19_VAL=$(GEN19_VAL) \
		GEN20_NAME=$(GEN20_NAME) GEN20_VAL=$(GEN20_VAL) \
		GEN21_NAME=$(GEN21_NAME) GEN21_VAL=$(GEN21_VAL) \
		GEN22_NAME=$(GEN22_NAME) GEN22_VAL=$(GEN22_VAL) \
		GEN23_NAME=$(GEN23_NAME) GEN23_VAL=$(GEN23_VAL) \
		GEN24_NAME=$(GEN24_NAME) GEN24_VAL=$(GEN24_VAL) \
		GEN25_NAME=$(GEN25_NAME) GEN25_VAL=$(GEN25_VAL) \
		GEN26_NAME=$(GEN26_NAME) GEN26_VAL=$(GEN26_VAL) \
		GEN27_NAME=$(GEN27_NAME) GEN27_VAL=$(GEN27_VAL) \
		GEN28_NAME=$(GEN28_NAME) GEN28_VAL=$(GEN28_VAL) \
		GEN29_NAME=$(GEN29_NAME) GEN29_VAL=$(GEN29_VAL) \
		GEN30_NAME=$(GEN30_NAME) GEN30_VAL=$(GEN30_VAL) \
		GEN31_NAME=$(GEN31_NAME) GEN31_VAL=$(GEN31_VAL) \
		GEN32_NAME=$(GEN32_NAME) GEN32_VAL=$(GEN32_VAL) \
		GEN33_NAME=$(GEN33_NAME) GEN33_VAL=$(GEN33_VAL) \
		GEN34_NAME=$(GEN34_NAME) GEN34_VAL=$(GEN34_VAL)
py_gui_pipinstall:
	@$(MAKE) -f $(GENERIC_MAKEFILE) $@
py_gui_install:
	@$(MAKE) -f $(GENERIC_MAKEFILE) $@
py_gui_exe: 
	@$(MAKE) -f $(GENERIC_MAKEFILE) $@
crc:
	@$(MAKE) -f $(GENERIC_MAKEFILE) $@
build_sim_gui_tx:
	@$(MAKE) -f $(GENERIC_MAKEFILE) $@
build_sim_tx:
	@$(MAKE) -f $(GENERIC_MAKEFILE) $@
build_sim_gui_rx:
	@$(MAKE) -f $(GENERIC_MAKEFILE) $@
build_sim_rx:
	@$(MAKE) -f $(GENERIC_MAKEFILE) $@
build_sim_txrx:
	@$(MAKE) -f $(GENERIC_MAKEFILE) $@
build_sim_gui_crc:
	@$(MAKE) -f $(GENERIC_MAKEFILE) $@
build_sim_crc:
	@$(MAKE) -f $(GENERIC_MAKEFILE) $@



# -------------------------------------------------------------
#  git.mk targets
# -------------------------------------------------------------
gp:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
gac:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
gacp: 
	@$(MAKE) -f $(GIT_MAKEFILE) $@
gacpt:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
glive:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_login_thisdir:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_login:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_cli_auth:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_config:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_init:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_branch:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_add_all:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_commit_all:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_commit:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_change_commit_after_push:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_change_last_commit_before_push:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_undo_last_commit_before_push:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_undo_last_commit_after_push:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_new_remote_origin_https:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_new_remote_origin_template_https:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_history:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_goto_commit:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_new_private_repo:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_new_public_repo:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_new_private_repo_from_template:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_new_public_repo_from_template:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_make_this_repo_template:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_clone_repo_https:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_connected_repos:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_list_branches:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_new_branch:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_switch_branch:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_compare_with_main_branch:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_merge_to_main_branch:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_update_changes_thisbranch_projrepo:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_update_changes_mainbranch_templrepo:
	@$(MAKE) -f $(GIT_MAKEFILE) $@



# -------------------------------------------------------------
#  opalkelly.mk targets
# -------------------------------------------------------------
$(CSV_READOUT_DIR)/build/Debug/csv_readout_debug_@$(LAST_GIT_COMMIT_HASH).exe:
	@$(MAKE) -f $(OPALKELLY_MAKEFILE) $@
$(CSV_READOUT_DIR)/build/Release/csv_readout_release_@$(LAST_GIT_COMMIT_HASH).exe:
	@$(MAKE) -f $(OPALKELLY_MAKEFILE) $@
ok_rescan_csv_readout:
	@$(MAKE) -f $(OPALKELLY_MAKEFILE) $@
ok_force_rescan_csv_readout:
	@$(MAKE) -f $(OPALKELLY_MAKEFILE) $@
ok_prog_csv_readout: $(TARGET_OUTPUT_DIR_ARTIFACTS)/$(BITFILE_NAME).bit
	@$(MAKE) -f $(OPALKELLY_MAKEFILE) $@ \
		OUTPUT_DIR=$(TARGET_OUTPUT_DIR_ARTIFACTS) RUN_TIME_SECONDS=$(RUN_READOUT_SECONDS) \
		BITFILE_NAME=$(BITFILE_NAME).bit QUBITS_CNT=$(GEN2_VAL)
ok_run_csv_readout_debug: $(TARGET_OUTPUT_DIR_ARTIFACTS)/$(BITFILE_NAME).bit
	@$(MAKE) -f $(OPALKELLY_MAKEFILE) $@ \
		OUTPUT_DIR=$(TARGET_OUTPUT_DIR_ARTIFACTS) RUN_TIME_SECONDS=$(RUN_READOUT_SECONDS) \
		BITFILE_NAME=$(BITFILE_NAME).bit QUBITS_CNT=$(GEN2_VAL)
ok_run_csv_readout_release: $(TARGET_OUTPUT_DIR_ARTIFACTS)/$(BITFILE_NAME).bit
	@$(MAKE) -f $(OPALKELLY_MAKEFILE) $@ \
		OUTPUT_DIR=$(TARGET_OUTPUT_DIR_ARTIFACTS) RUN_TIME_SECONDS=$(RUN_READOUT_SECONDS) \
		BITFILE_NAME=$(BITFILE_NAME).bit QUBITS_CNT=$(GEN2_VAL)



# -------------------------------------------------------------
#  "packages.mk" targets
# -------------------------------------------------------------
config_wsl:
	@$(MAKE) -f $(PACKAGES_MAKEFILE) $@
vcpkg_install:
	@$(MAKE) -f $(PACKAGES_MAKEFILE) $@
pip_install:
	@$(MAKE) -f $(PACKAGES_MAKEFILE) $@
pip_upgrade:
	@$(MAKE) -f $(PACKAGES_MAKEFILE) $@
choco_install:
	@$(MAKE) -f $(PACKAGES_MAKEFILE) $@
choco_upgrade:
	@$(MAKE) -f $(PACKAGES_MAKEFILE) $@
winget_install:
	@$(MAKE) -f $(PACKAGES_MAKEFILE) $@
winget_upgrade:
	@$(MAKE) -f $(PACKAGES_MAKEFILE) $@
git_upgrade:
	@$(MAKE) -f $(PACKAGES_MAKEFILE) $@
install_all_pkg:
	@$(MAKE) -f $(PACKAGES_MAKEFILE) $@
upgrade_all_pkg:
	@$(MAKE) -f $(PACKAGES_MAKEFILE) $@



# -------------------------------------------------------------
#  Auxiliary targets
# -------------------------------------------------------------
# Put this at the end of yout make command sequence to measure execution time
# Example: make reset essentials generics src sim timer
timer:
	@echo "-------------------------------------------"
	@echo "make timer: Build Duration: $(TIMER_FORMAT)"
	@echo "-------------------------------------------"