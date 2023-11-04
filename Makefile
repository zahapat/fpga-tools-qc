# Usage Examples:
# make gacp MSG="fix: Enable commit msg from cli"  <--- YOU  MUST enter the commit message in quotation marks

# Requires Github CLI + git installed


# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
# Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(shell pwd)

# Timer
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
PACKAGES_MAKEFILE = packages.mk


# Project author details
ENGINEER ?= patrik_zahalka
EMAIL ?= patrik.zahalka@univie.ac.at


# Libraries for HDL sources and testbenches
LIB_SRC ?= lib_src
LIB_SIM ?= lib_sim


# [make new_module]: Architecture type, generate extra files
ARCH ?= rtl
EXTRA ?= none


# [make src] Actual top module you are working with
TOP ?= top_gflow.vhd


# [make generics] Set names and values for generic variables
GEN1_NAME ?= EMULATE_INPUTS
GEN1_VAL ?= true
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

# GEN8_NAME ?= PHOTON_5H_DELAY_NS
# GEN8_VAL ?= -4177.95
# GEN9_NAME ?= PHOTON_5V_DELAY_NS
# GEN9_VAL ?= -4181.05
# GEN10_NAME ?= PHOTON_6H_DELAY_NS
# GEN10_VAL ?= -5177.95
# GEN11_NAME ?= PHOTON_6V_DELAY_NS
# GEN11_VAL ?= -5181.05

# GEN12_NAME ?= Generic_Name
# GEN12_VAL ?= default_value
# GEN13_NAME ?= Generic_Name
# GEN13_VAL ?= default_value
# GEN14_NAME ?= Generic_Name
# GEN14_VAL ?= default_value
# GEN15_NAME ?= Generic_Name
# GEN15_VAL ?= default_value



# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:



# -------------------------------------------------------------
#  Default target
# -------------------------------------------------------------
default_target:
	@make py_gui



# -------------------------------------------------------------
#  Auxiliary targets
# -------------------------------------------------------------
timer:
	@echo "-------------------------------------------"
	@echo "make timer: Build Duration: $(TIMER_FORMAT)"
	@echo "-------------------------------------------"


# -------------------------------------------------------------
#  "project_specific.mk" targets
# -------------------------------------------------------------
init:
	@$(MAKE) -f $(PROJECT_SPECIFIC_MAKEFILE) $@
build:
	@$(MAKE) -f $(PROJECT_SPECIFIC_MAKEFILE) $@
distribute_bitfiles:
	@$(MAKE) -f $(PROJECT_SPECIFIC_MAKEFILE) $@
cmd_timeout:
	@$(MAKE) -f $(PROJECT_SPECIFIC_MAKEFILE) $@



# -------------------------------------------------------------
#  "vivado.mk" targets
# -------------------------------------------------------------
reset :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
new :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
new_module :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
src :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@ TOP=$(TOP)
board :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
declare :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
generics :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@ \
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
		GEN15_NAME=$(GEN15_NAME) GEN15_VAL=$(GEN15_VAL)
ooc :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
synth :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
impl :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
outd :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
bit :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
xsa :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
prog :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
probes :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
ila :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
all :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
old :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
clean :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
gui :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
core :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
ip :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@



# -------------------------------------------------------------
#  "sim.mk" targets
# -------------------------------------------------------------
sim_init :
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
remove_vitis :
	@$(MAKE) -f $(VITIS_MAKEFILE) $@
remove_ws_vitis :
	@$(MAKE) -f $(VITIS_MAKEFILE) $@
new_vitis :
	@$(MAKE) -f $(VITIS_MAKEFILE) $@
new_app_vitis :
	@$(MAKE) -f $(VITIS_MAKEFILE) $@
add_sources_vitis :
	@$(MAKE) -f $(VITIS_MAKEFILE) $@
gui_vitis :
	@$(MAKE) -f $(VITIS_MAKEFILE) $@
bsp_regen_vitis :
	@$(MAKE) -f $(VITIS_MAKEFILE) $@
reset_vitis :
	@$(MAKE) -f $(VITIS_MAKEFILE) $@
all_vitis :
	@$(MAKE) -f $(VITIS_MAKEFILE) $@



# -------------------------------------------------------------
#  "generic.mk" targets
# -------------------------------------------------------------
redis_start:
	@$(MAKE) -f $(GENERIC_MAKEFILE) $@
redis_stop:
	@$(MAKE) -f $(GENERIC_MAKEFILE) $@
vvc_gen :
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
		GEN15_NAME=$(GEN15_NAME) GEN15_VAL=$(GEN15_VAL)
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