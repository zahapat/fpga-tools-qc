# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
#  Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(shell pwd)


# Vivado parameters
VIVADO_VERSION = 2020.2
VIVADO_INSTALLPATH = C:/Xilinx/Vivado
VIVADO_BINPATH = $(VIVADO_INSTALLPATH)/$(VIVADO_VERSION)/bin


# [make new]: FPGA part number
PART = xc7k160tffg676-1


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
	make new
	make sim_reset


# make new: to create/recreate a project, set up settings
new :
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/recreate_vivado_proj.tcl -notrace -tclargs $(PART)



# make new_module (e.g. NAME=top.vhd ARCH=str ...): Create a new VHDL/V/SV rtl module + sim + xdc and its subfolder
new_module : ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_new_module/make_new_module.tcl -notrace -tclargs $(NAME) $(ARCH) $(EXTRA) $(LIB_SRC) $(LIB_SIM) $(ENGINEER) $(EMAIL)


# make src TOP=<module>: Set a file graph for synthesis or/and implementation under the given TOP module
src : ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_src.tcl -notrace -tclargs $(TOP) $(LIB_SRC) $(LIB_SIM)


# make board
board : ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_board.tcl -notrace -tclargs $(BOARD)


# make declare TOP=<module.suffix>: Find the relative top module, scan for signals, constants, subtypes..., automatically add missing declararions
declare : ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/make_declare/make_declare.tcl -notrace -tclargs $(TOP) $(LIB_SRC)


# make generics GEN1_NAME = <NAME> GEN1_VAL = <val> ... 
generics : ./vivado/$(PROJ_NAME).xpr
	py -3 ./scripts/generics/genTclGenericsMain.py \
		--generic1_name=$(GEN1_NAME)   --generic1_val=$(GEN1_VAL)\
		--generic2_name=$(GEN2_NAME)   --generic2_val=$(GEN2_VAL)\
		--generic3_name=$(GEN3_NAME)   --generic3_val=$(GEN3_VAL)\
		--generic4_name=$(GEN4_NAME)   --generic4_val=$(GEN4_VAL)\
		--generic5_name=$(GEN5_NAME)   --generic5_val=$(GEN5_VAL)\
		--generic6_name=$(GEN6_NAME)   --generic6_val=$(GEN6_VAL)\
		--generic7_name=$(GEN7_NAME)   --generic7_val=$(GEN7_VAL)\
		--generic8_name=$(GEN8_NAME)   --generic8_val=$(GEN8_VAL)\
		--generic9_name=$(GEN9_NAME)   --generic9_val=$(GEN9_VAL)\
		--generic10_name=$(GEN10_NAME) --generic10_val=$(GEN10_VAL)\
		--generic11_name=$(GEN11_NAME) --generic11_val=$(GEN11_VAL)\
		--generic12_name=$(GEN12_NAME) --generic12_val=$(GEN12_VAL)\
		--generic13_name=$(GEN13_NAME) --generic13_val=$(GEN13_VAL)\
		--generic14_name=$(GEN14_NAME) --generic14_val=$(GEN14_VAL)\
		--generic15_name=$(GEN15_NAME) --generic15_val=$(GEN15_VAL)\
		--proj_name=$(PROJ_NAME)
		--proj_dir=$(PROJ_DIR)\
		--output_dir=./tcl/project_specific/vivado
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/project_specific/vivado/make_generics.tcl -notrace

# make ooc TOP=<module>: Run Synthesis in Out-of-context mode
ooc : ./vivado/$(PROJ_NAME).xpr ./vivado/0_report_added_modules.rpt
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_ooc.tcl -notrace -tclargs $(TOP)


# make synth: Run Synthesis only, use current fileset
synth : ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/synth_design.tcl -notrace


# make impl: Run Implementation only, use current fileset
impl : ./vivado/1_checkpoint_post_synth.dcp $(PROJ_NAME).xpr
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/impl_design.tcl -notrace


# make outd: Run synthesis or/and implementation if out-of-date
outd : ./vivado/2_checkpoint_post_route.dcp ./vivado/1_checkpoint_post_synth.dcp ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/run_outdated.tcl  -notrace


# make bit: Run synthesis or/and implementation if out-of-date
bit : ./vivado/2_checkpoint_post_route.dcp ./vivado/1_checkpoint_post_synth.dcp ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/run_bitstream.tcl  -notrace

# make xsa: Run synthesis, implementation, generate bitstream -> generate HW Platform .xsa file form .bit file
xsa : ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_run_hw_platform.tcl  -notrace

# make prog: Use 3_bitstream_<PROJ_NAME> to program the target FPGA
prog : ./vivado/2_checkpoint_post_route.dcp ./vivado/1_checkpoint_post_synth.dcp ./vivado/$(PROJ_NAME).xpr ./vivado/3_bitstream_$(PROJ_NAME).bit
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_prog.tcl  -notrace


# make probes: find all nets mark_debug, create ILA probes, make all
probes : ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_probes.tcl  -notrace


# make ila: make prog and trigger ILA (NOT DONE YET)
ila : ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_ila.tcl  -notrace


# make all: Run Synthesis, Implementation, Generate Bitstream
all : ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/run_all.tcl -notrace


# make old: Run Synthesis, Implementation, Generate Bitstream if out-of-date
old : ./vivado/2_checkpoint_post_route.dcp ./vivado/1_checkpoint_post_synth.dcp
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/run_old.tcl -notrace


# make gui: Run Vivado in mode GUI and open project in the vivado folder
gui : ./vivado/$(PROJ_NAME).xpr
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode gui -source ./tcl/generic/vivado/tcl_functions_vivado.tcl -notrace ./vivado/$(PROJ_NAME).xpr


# make core: Packaging VHDL/V/SV files which have been already synthesized and verified
core : ./vivado/$(PROJ_NAME).xpr ./vivado/0_report_added_modules.rpt ./vivado/0_report_added_xdc.rpt ./vivado/1_netlist_post_synth.edf
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_core.tcl -notrace -tclargs $(NAME_IP_PACK)


# make ip: Generate IP output files (xci, xco)
ip : $(PROJ_NAME).xpr ./vivado/0_report_added_modules.rpt ./vivado/0_report_added_xdc.rpt ./vivado/1_netlist_post_synth.edf
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_ip.tcl -notrace -tclargs $(NAME_IP_PACK)
