# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
# Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(shell pwd)

# Libraries for HDL sources and testbenches
LIB_SRC ?= lib_src
LIB_SIM ?= lib_sim

# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:


# Modelsim
# make sim LIB_SRC=libname LIB_SIM=libname: re/create respective libraries for the project in ModelSim, run all
sim : modelsim.ini 
	$(info ----- RESET SIM ENVIRONMENT, RUN ALL IN BATCH -----)
	vsim -c -do "do ./do/make_sim.tcl $(LIB_SRC),$(LIB_SIM)"


# make sim_gui LIB_SRC=libname LIB_SIM=libname: re/create Questa project, create libraries, add files, compile all, run all
sim_gui : modelsim.ini ./simulator/run.do
	$(info ----- RESET SIM ENVIRONMENT, RUN ALL IN GUI -----)
	vsim -do "do ./do/make_sim.tcl $(LIB_SRC),$(LIB_SIM)"