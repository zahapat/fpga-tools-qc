# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
# Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

# Libraries for HDL sources and testbenches
LIB_SRC ?= work
LIB_SIM ?= work

# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:


# Modelsim
# Initialize Simulator (Questa)
$(PROJ_DIR)/simulator/modelsim.ini :
	cd $(PROJ_DIR)simulator; vmap -c
	set MODELSIM=$(PROJ_DIR)simulator/modelsim.ini

# make sim LIB_SRC=libname LIB_SIM=libname: re/create respective libraries for the project in ModelSim, run all
sim_reset : 
	cd $(PROJ_DIR)simulator; vsim -c -do "do ./do/make_sim_clean.tcl $(LIB_SRC),$(LIB_SIM),$(PROJ_DIR),$(VIVADO_VERSION)"

# make sim LIB_SRC=libname LIB_SIM=libname: re/create respective libraries for the project in ModelSim, run all
sim : $(PROJ_DIR)/simulator/modelsim.ini
	cd $(PROJ_DIR)simulator; vsim -c -do "do ./do/make_sim.tcl $(LIB_SRC),$(LIB_SIM),$(PROJ_DIR),$(VIVADO_VERSION)"

# make sim_gui LIB_SRC=libname LIB_SIM=libname: re/create Questa project, create libraries, add files, compile all, run all
sim_gui : $(PROJ_DIR)/simulator/modelsim.ini $(PROJ_DIR)/simulator/run.do $(PROJ_DIR)/simulator/new.do
	cd $(PROJ_DIR)simulator; vsim -do "do ./do/make_sim.tcl $(LIB_SRC),$(LIB_SIM),$(PROJ_DIR),$(VIVADO_VERSION)"

compile: $(PROJ_DIR)/simulator/modelsim.ini
	cd $(PROJ_DIR)simulator; vsim -c -do "do ./do/compile_nosim.tcl $(LIB_SRC),$(LIB_SIM),$(PROJ_DIR),$(VIVADO_VERSION)"