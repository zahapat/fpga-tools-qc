# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
#  Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(dir $(abspath $(firstword $(MAKEFILE_LIST))))


ifeq ($(OS),Windows_NT)
  VIVADO_EXEC = vivado.bat
  TIMEOUT = timeout /t 12
  VIVADO_INSTALLPATH = C:/Xilinx/Vivado
else ifeq ($(OS),LINUX)
  VIVADO_EXEC = vivado
  TIMEOUT = sleep 12s
  VIVADO_INSTALLPATH = /opt/Xilinx/Vivado
else ifeq ($(OS),LINUX_DOCKER)
  VIVADO_EXEC = vivado
  TIMEOUT = sleep 12s
  VIVADO_INSTALLPATH = /opt/Xilinx/Vivado
  DOCKER_PREFIX = LD_PRELOAD=/lib/x86_64-linux-gnu/libudev.so.1 
endif

# Vivado parameters
VIVADO_BINPATH = $(VIVADO_INSTALLPATH)/$(VIVADO_VERSION)/bin
VIVADO_PATH_EXEC =$(DOCKER_PREFIX) $(VIVADO_INSTALLPATH)/$(VIVADO_VERSION)/bin/$(VIVADO_EXEC)


# [make new]: FPGA part number
PART ?= xc7k160tffg676-1


# [make core/ip]: Name for the new IP package
NAME_IP_PACK ?= $(PROJ_NAME)_ip


# Libraries for HDL sources and testbenches
LIB_SRC ?= lib_src
LIB_SIM ?= lib_sim


# [make new_module]: Architecture type, generate extra files
ARCH ?= rtl
EXTRA ?= none


# [make src] Actual top module you are working with
TOP ?= top.vhd


BOARD ?= top

# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:


# Generic Vivado/Simulator Targets
reset :
	@echo OS=$(OS)
	make new


# make new: to create/recreate a project, set up settings
new :
	$(VIVADO_PATH_EXEC) -nolog -nojou -mode batch -source ./tcl/generic/vivado/recreate_vivado_proj.tcl -notrace -tclargs $(PART)



# make src TOP=<module>: Set a file graph for synthesis or/and implementation under the given TOP module
src : ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_PATH_EXEC) -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_src.tcl -notrace -tclargs $(TOP) $(LIB_SRC) $(LIB_SIM)


# make board
board : ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_PATH_EXEC) -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_board.tcl -notrace -tclargs $(BOARD)


# make declare TOP=<module.suffix>: Find the relative top module, scan for signals, constants, subtypes..., automatically add missing declararions
declare : ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_PATH_EXEC) -nolog -nojou -mode batch -source ./tcl/generic/make_declare/make_declare.tcl -notrace -tclargs $(TOP) $(LIB_SRC)


# make ooc TOP=<module>: Run Synthesis in Out-of-context mode
ooc : ./vivado/$(PROJ_NAME).xpr ./vivado/0_report_added_modules.rpt
	$(VIVADO_PATH_EXEC) -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_ooc.tcl -notrace -tclargs $(TOP)


# make synth: Run Synthesis only, use current fileset
synth : ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_PATH_EXEC) -nolog -nojou -mode batch -source ./tcl/generic/vivado/synth_design.tcl -notrace


# make impl: Run Implementation only, use current fileset
impl : ./vivado/1_checkpoint_post_synth.dcp $(PROJ_NAME).xpr
	$(VIVADO_PATH_EXEC) -nolog -nojou -mode batch -source ./tcl/generic/vivado/impl_design.tcl -notrace


# make outd: Run synthesis or/and implementation if out-of-date
outd : ./vivado/2_checkpoint_post_route.dcp ./vivado/1_checkpoint_post_synth.dcp ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_PATH_EXEC) -nolog -nojou -mode batch -source ./tcl/generic/vivado/run_outdated.tcl  -notrace


# make bit: Run synthesis or/and implementation if out-of-date
bit : ./vivado/2_checkpoint_post_route.dcp ./vivado/1_checkpoint_post_synth.dcp ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_PATH_EXEC) -nolog -nojou -mode batch -source ./tcl/generic/vivado/run_bitstream.tcl  -notrace

# make xsa: Run generate HW Platform .xsa file form .bit file after synthesis, implementation, generate bitstream (or after running make all)
# Note: Not sure why but "timeout /t 12+ seconds" must be executed before make_run_hw_platform.tcl. Maybe, some running threads have not yet
#       completed after generate bitstream step followed by immediately closing vivado. In turn, when attempting to generate hardware platform, 
#       vivado throws an error that implementation has not been run all the way through bitstream generation, which is incorrect. The waiting 
#       then serves to wait long enough for these "processes" to complete. Then, the hardware platform is completed successfully.
xsa : ./vivado/$(PROJ_NAME).xpr
	${TIMEOUT}
	$(VIVADO_PATH_EXEC) -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_run_hw_platform.tcl  -notrace

# make prog: Use 3_bitstream_<PROJ_NAME> to program the target FPGA
prog : ./vivado/2_checkpoint_post_route.dcp ./vivado/1_checkpoint_post_synth.dcp ./vivado/$(PROJ_NAME).xpr ./vivado/3_bitstream_$(PROJ_NAME).bit
	$(VIVADO_PATH_EXEC) -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_prog.tcl  -notrace


# make probes: find all nets mark_debug, create ILA probes, make all
probes : ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_PATH_EXEC) -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_probes.tcl  -notrace


# make ila: make prog and trigger ILA (NOT DONE YET)
ila : ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_PATH_EXEC) -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_ila.tcl  -notrace


# make all: Run Synthesis, Implementation, Generate Bitstream
all : ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_PATH_EXEC) -nolog -nojou -mode batch -source ./tcl/generic/vivado/run_all.tcl -notrace


# make old: Run Synthesis, Implementation, Generate Bitstream if out-of-date
old : ./vivado/2_checkpoint_post_route.dcp ./vivado/1_checkpoint_post_synth.dcp
	$(VIVADO_PATH_EXEC) -nolog -nojou -mode batch -source ./tcl/generic/vivado/run_old.tcl -notrace


# make gui: Run Vivado in mode GUI and open project in the vivado folder
gui : ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_PATH_EXEC) -nolog -nojou -mode gui -source ./tcl/generic/vivado/tcl_functions_vivado.tcl -notrace ./vivado/$(PROJ_NAME).xpr


# make core: Packaging VHDL/V/SV files which have been already synthesized and verified
core : ./vivado/$(PROJ_NAME).xpr ./vivado/0_report_added_modules.rpt ./vivado/0_report_added_xdc.rpt ./vivado/1_netlist_post_synth.edf
	$(VIVADO_PATH_EXEC) -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_core.tcl -notrace -tclargs $(NAME_IP_PACK)


# make ip: Generate IP output files (xci, xco)
ip : $(PROJ_NAME).xpr ./vivado/0_report_added_modules.rpt ./vivado/0_report_added_xdc.rpt ./vivado/1_netlist_post_synth.edf
	$(VIVADO_PATH_EXEC) -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_ip.tcl -notrace -tclargs $(NAME_IP_PACK)