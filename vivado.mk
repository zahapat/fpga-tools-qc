# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
#  Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(shell pwd)


# Vivado parameters
VIVADO_VERSION = 2020.2
VIVADO_INSTALLPATH = C:/Xilinx/Vivado/
VIVADO_BINPATH = $(VIVADO_INSTALLPATH)/$(VIVADO_VERSION)/bin


# [make new]: FPGA part number
PART = xc7k160tffg676-1


# Search for .xpr files in ./$(VPATH)
VPATH = vivado


# Prerequisites are located here
OBJDIR := ./vivado


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


# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:


# Generic Vivado/ModelSim Targets
reset :
	make new
	make clean


# make new: to create/recreate a project, set up settings
new :
	$(info ----- RE/CREATE THE VIVADO PROJECT: $(PROJ_NAME) -----)
	rm -r ./.Xil
	rm -r ./vivado
	mkdir ./vivado
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/recreate_vivado_proj.tcl -notrace -tclargs $(PART)


# make new_module (e.g. NAME=top.vhd ARCH=str ...): Create a new VHDL/V/SV rtl module + sim + xdc and its subfolder
new_module : $(PROJ_NAME).xpr
	$(info ----- CREATE A NEW VHDL/VERILOG/SYSTEMVERILOG MODULE -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_new_module/make_new_module.tcl -notrace -tclargs $(NAME) $(ARCH) $(EXTRA) $(LIB_SRC) $(LIB_SIM) $(ENGINEER) $(EMAIL)


# make src TOP=<module>: Set a file graph for synthesis or/and implementation under the given TOP module
src : $(PROJ_NAME).xpr
	$(info ----- SEARCH FOR TOP MODULE AND ALL ITS SUBMODULES -----)
	rm -r ./vivado/0_report_added_modules.rpt
	rm -r ./vivado/0_report_added_xdc.rpt
	rm -r ./do/modules.tcl
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_src.tcl -notrace -tclargs $(TOP) $(LIB_SRC) $(LIB_SIM)


# make board
board : $(PROJ_NAME).xpr
	$(info ----- RE/ADD ALL BOARD FILES -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_board.tcl -notrace


# make declare TOP=<module.suffix>: Find the relative top module, scan for signals, constants, subtypes..., automatically add missing declararions
declare : $(PROJ_NAME).xpr
	$(info ----- ADD MISSING DECLARATIONS -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/make_declare/make_declare.tcl -notrace -tclargs $(TOP) $(LIB_SRC)


# make generics GEN1_NAME = <NAME> GEN1_VAL = <val> ... 
GEN1_NAME ?= EMULATE_INPUTS
GEN1_VAL ?= false
GEN2_NAME ?= PHOTON_2H_DELAY_NS
GEN2_VAL ?= -2117.95
GEN3_NAME ?= PHOTON_2V_DELAY_NS
GEN3_VAL ?= -2125.35
GEN4_NAME ?= PHOTON_3H_DELAY_NS
GEN4_VAL ?= -1030.35
GEN5_NAME ?= PHOTON_3V_DELAY_NS
GEN5_VAL ?= -1034.45
GEN6_NAME ?= PHOTON_4H_DELAY_NS
GEN6_VAL ?= -3177.95
GEN7_NAME ?= PHOTON_4V_DELAY_NS
GEN7_VAL ?= -3181.05
# GEN8_NAME ?= Generic_Name
# GEN8_VAL ?= default_value
# GEN9_NAME ?= Generic_Name
# GEN9_VAL ?= default_value
# GEN10_NAME ?= Generic_Name
# GEN10_VAL ?= default_value
# GEN11_NAME ?= Generic_Name
# GEN11_VAL ?= default_value
# GEN12_NAME ?= Generic_Name
# GEN12_VAL ?= default_value
# GEN13_NAME ?= Generic_Name
# GEN13_VAL ?= default_value
# GEN14_NAME ?= Generic_Name
# GEN14_VAL ?= default_value
# GEN15_NAME ?= Generic_Name
# GEN15_VAL ?= default_value
generics : $(PROJ_NAME).xpr
	$(info ----- SET GENERICS BEFORE SYNTHESIS -----)
	py -3 ./scripts/generics/genTclGenericsMain.py \
		--generic1_name=$(GEN1_NAME)\
		--generic1_val=$(GEN1_VAL)\
		--generic2_name=$(GEN2_NAME)\
		--generic2_val=$(GEN2_VAL)\
		--generic3_name=$(GEN3_NAME)\
		--generic3_val=$(GEN3_VAL)\
		--generic4_name=$(GEN4_NAME)\
		--generic4_val=$(GEN4_VAL)\
		--generic5_name=$(GEN5_NAME)\
		--generic5_val=$(GEN5_VAL)\
		--generic6_name=$(GEN6_NAME)\
		--generic6_val=$(GEN6_VAL)\
		--generic7_name=$(GEN7_NAME)\
		--generic7_val=$(GEN7_VAL)\
		--generic8_name=$(GEN8_NAME)\
		--generic8_val=$(GEN8_VAL)\
		--generic9_name=$(GEN9_NAME)\
		--generic9_val=$(GEN9_VAL)\
		--generic10_name=$(GEN10_NAME)\
		--generic10_val=$(GEN10_VAL)\
		--generic11_name=$(GEN11_NAME)\
		--generic11_val=$(GEN11_VAL)\
		--generic12_name=$(GEN12_NAME)\
		--generic12_val=$(GEN12_VAL)\
		--generic13_name=$(GEN13_NAME)\
		--generic13_val=$(GEN13_VAL)\
		--generic14_name=$(GEN14_NAME)\
		--generic14_val=$(GEN14_VAL)\
		--generic15_name=$(GEN15_NAME)\
		--generic15_val=$(GEN15_VAL)\
		--proj_name=$(PROJ_NAME)\
		--proj_dir=$(PROJ_DIR)\
		--output_dir=./tcl/project_specific/vivado
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/project_specific/vivado/make_generics.tcl -notrace

# make ooc TOP=<module>: Run Synthesis in Out-of-context mode
ooc : $(PROJ_NAME).xpr 0_report_added_modules.rpt
	$(info ----- RUN SYNTHESIS IN OUT-OF-CONTEXT MODE -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_ooc.tcl -notrace -tclargs $(TOP)


# make synth: Run Synthesis only, use current fileset
synth : $(PROJ_NAME).xpr
	$(info ----- RUN SYNTHESIS -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/synth_design.tcl -notrace


# make impl: Run Implementation only, use current fileset
impl : 1_checkpoint_post_synth.dcp $(PROJ_NAME).xpr
	$(info ----- RUN IMPLEMENTATION -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/impl_design.tcl -notrace


# make outd: Run synthesis or/and implementation if out-of-date
outd : 2_checkpoint_post_route.dcp 1_checkpoint_post_synth.dcp $(PROJ_NAME).xpr
	$(info ----- RUN/RERUN OUTDATED STAGES: SYNTH, IMPL -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/run_outdated.tcl  -notrace


# make bit: Run synthesis or/and implementation if out-of-date
bit : 2_checkpoint_post_route.dcp 1_checkpoint_post_synth.dcp $(PROJ_NAME).xpr
	$(info ----- RUN GENERATE BITSTREAM -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/run_bitstream.tcl  -notrace

# make xsa: Run synthesis, implementation, generate bitstream -> generate HW Platform .xsa file form .bit file
xsa : $(PROJ_NAME).xpr
	$(info ----- RUN ALL THE WAY THROUGH BIT GEN AND GENERATE HW PLATFORM -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_run_hw_platform.tcl  -notrace

# make prog: Use 3_bitstream_<PROJ_NAME> to program the target FPGA
prog : 2_checkpoint_post_route.dcp 1_checkpoint_post_synth.dcp $(PROJ_NAME).xpr 3_bitstream_$(PROJ_NAME).bit
	$(info ----- PROGRAM FPGA -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_prog.tcl  -notrace


# make probes: find all nets mark_debug, create ILA probes, make all
probes : $(PROJ_NAME).xpr
	$(info ----- MAKE ALL AND CREATE ILA PROBES -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_probes.tcl  -notrace


# make ila: make prog and trigger ILA (NOT DONE YET)
ila : $(PROJ_NAME).xpr
	$(info ----- PROGRAM FPGA AND TRIGGER ILA -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_ila.tcl  -notrace


# make all: Run Synthesis, Implementation, Generate Bitstream
all : $(PROJ_NAME).xpr
	$(info ----- RUN ALL STAGES: SYNTH, IMPL + BIT -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/run_all.tcl -notrace


# make old: Run Synthesis, Implementation, Generate Bitstream if out-of-date
old : 2_checkpoint_post_route.dcp 1_checkpoint_post_synth.dcp
	$(info ----- RERUN STAGES IF OLD: SYNTH, IMPL + BIT -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/run_old.tcl -notrace


# make clean: Clean project files and ModelSim project folder content
clean : $(PROJ_NAME).xpr
	$(info ----- CLEAN VIVADO & MODELSIM PROJECT JUNK FILES, CLEAN ENVIRONMENT -----)
	rm -r ./.Xil
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_clean.tcl -notrace -tclargs $(LIB_SRC) $(LIB_SIM)


# make gui: Run Vivado in mode GUI and open project in the vivado folder
gui : $(PROJ_NAME).xpr
	$(info ----- RUN VIVADO IN MODE GUI -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode gui -notrace ./vivado/$(PROJ_NAME).xpr


# make core: Packaging VHDL/V/SV files which have been already synthesized and verified
core : $(PROJ_NAME).xpr 0_report_added_modules.rpt 0_report_added_xdc.rpt 1_netlist_post_synth.edf
	$(info ----- CREATE A NEW IP CORE PACKAGE -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_core.tcl -notrace -tclargs $(NAME_IP_PACK)


# make ip: Generate IP output files (xci, xco)
ip : $(PROJ_NAME).xpr 0_report_added_modules.rpt 0_report_added_xdc.rpt 1_netlist_post_synth.edf
	$(info ----- CREATE IP CORE OUTPUT FILES OF AN EXISTING USER IP CORE -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_ip.tcl -notrace -tclargs $(NAME_IP_PACK)
