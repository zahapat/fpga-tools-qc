# Usage Examples:
# make gacp MSG="fix: Enable commit msg from cli"  <--- YOU  MUST enter the commit message in quotation marks

# Requires Github CLI + git installed


# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
# Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(shell pwd)


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
TOP ?= top.vhd




# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:



# -------------------------------------------------------------
#  "project_specific.mk" targets
# -------------------------------------------------------------
init:
	make -f $(PROJECT_SPECIFIC_MAKEFILE) $@
build:
	make -f $(PROJECT_SPECIFIC_MAKEFILE) $@
reset_bitfiles:
	make -f $(PROJECT_SPECIFIC_MAKEFILE) $@
cmd_timeout:
	make -f $(PROJECT_SPECIFIC_MAKEFILE) $@



# -------------------------------------------------------------
#  "vivado.mk" targets
# -------------------------------------------------------------
reset :
	make -f $(VIVADO_MAKEFILE) $@
new :
	make -f $(VIVADO_MAKEFILE) $@
new_module :
	make -f $(VIVADO_MAKEFILE) $@
src :
	make -f $(VIVADO_MAKEFILE) $@
board :
	make -f $(VIVADO_MAKEFILE) $@
declare :
	make -f $(VIVADO_MAKEFILE) $@
generics :
	make -f $(VIVADO_MAKEFILE) $@
ooc :
	make -f $(VIVADO_MAKEFILE) $@
synth :
	make -f $(VIVADO_MAKEFILE) $@
impl :
	make -f $(VIVADO_MAKEFILE) $@
outd :
	make -f $(VIVADO_MAKEFILE) $@
bit :
	make -f $(VIVADO_MAKEFILE) $@
xsa :
	make -f $(VIVADO_MAKEFILE) $@
prog :
	make -f $(VIVADO_MAKEFILE) $@
probes :
	make -f $(VIVADO_MAKEFILE) $@
ila :
	make -f $(VIVADO_MAKEFILE) $@
all :
	make -f $(VIVADO_MAKEFILE) $@
old :
	make -f $(VIVADO_MAKEFILE) $@
clean :
	make -f $(VIVADO_MAKEFILE) $@
gui :
	make -f $(VIVADO_MAKEFILE) $@
core :
	make -f $(VIVADO_MAKEFILE) $@
ip :
	make -f $(VIVADO_MAKEFILE) $@



# -------------------------------------------------------------
#  "sim.mk" targets
# -------------------------------------------------------------
sim :
	make -f $(SIM_MAKEFILE) $@
sim_gui :
	make -f $(SIM_MAKEFILE) $@


# -------------------------------------------------------------
#  "vitis.mk" targets
# -------------------------------------------------------------
# Generic Vitis Targets
remove_vitis :
	make -f $(VITIS_MAKEFILE) $@
remove_ws_vitis :
	make -f $(VITIS_MAKEFILE) $@
new_vitis :
	make -f $(VITIS_MAKEFILE) $@
new_app_vitis :
	make -f $(VITIS_MAKEFILE) $@
add_sources_vitis :
	make -f $(VITIS_MAKEFILE) $@
gui_vitis :
	make -f $(VITIS_MAKEFILE) $@
bsp_regen_vitis :
	make -f $(VITIS_MAKEFILE) $@
reset_vitis :
	make -f $(VITIS_MAKEFILE) $@
all_vitis :
	make -f $(VITIS_MAKEFILE) $@



# -------------------------------------------------------------
#  "generic.mk" targets
# -------------------------------------------------------------
redis_start:
	make -f $(GENERIC_MAKEFILE) $@
redis_stop:
	make -f $(GENERIC_MAKEFILE) $@
home_path :
	make -f $(GENERIC_MAKEFILE) $@
init_modelsim :
	make -f $(GENERIC_MAKEFILE) $@
init :
	make -f $(GENERIC_MAKEFILE) $@
vvc_gen :
	make -f $(GENERIC_MAKEFILE) $@
py_gui_regen:
	make -f $(GENERIC_MAKEFILE) $@
py_gui:
	make -f $(GENERIC_MAKEFILE) $@
py_gui_pipinstall:
	make -f $(GENERIC_MAKEFILE) $@
py_gui_install:
	make -f $(GENERIC_MAKEFILE) $@
py_gui_exe: 
	make -f $(GENERIC_MAKEFILE) $@
crc:
	make -f $(GENERIC_MAKEFILE) $@
build_sim_gui_tx:
	make -f $(GENERIC_MAKEFILE) $@
build_sim_tx:
	make -f $(GENERIC_MAKEFILE) $@
build_sim_gui_rx:
	make -f $(GENERIC_MAKEFILE) $@
build_sim_rx:
	make -f $(GENERIC_MAKEFILE) $@
build_sim_txrx:
	make -f $(GENERIC_MAKEFILE) $@
build_sim_gui_crc:
	make -f $(GENERIC_MAKEFILE) $@
build_sim_crc:
	make -f $(GENERIC_MAKEFILE) $@



# -------------------------------------------------------------
#  git.mk targets
# -------------------------------------------------------------
gp:
	make -f $(GIT_MAKEFILE) $@
gac:
	make -f $(GIT_MAKEFILE) $@
gacp: 
	make -f $(GIT_MAKEFILE) $@
gacp_comment:
	make -f $(GIT_MAKEFILE) $@
gacp_refractor:
	make -f $(GIT_MAKEFILE) $@
gac_comment:
	make -f $(GIT_MAKEFILE) $@
gac_refractor:
	make -f $(GIT_MAKEFILE) $@
gacpt:
	make -f $(GIT_MAKEFILE) $@
glive:
	make -f $(GIT_MAKEFILE) $@
git_login_thisdir:
	make -f $(GIT_MAKEFILE) $@
git_login:
	make -f $(GIT_MAKEFILE) $@
git_cli_auth:
	make -f $(GIT_MAKEFILE) $@
git_config:
	make -f $(GIT_MAKEFILE) $@
git_init:
	make -f $(GIT_MAKEFILE) $@
git_branch:
	make -f $(GIT_MAKEFILE) $@
git_add_all:
	make -f $(GIT_MAKEFILE) $@
git_commit_all:
	make -f $(GIT_MAKEFILE) $@
git_commit:
	make -f $(GIT_MAKEFILE) $@
git_change_commit_after_push:
	make -f $(GIT_MAKEFILE) $@
git_change_last_commit_before_push:
	make -f $(GIT_MAKEFILE) $@
git_undo_last_commit_before_push:
	make -f $(GIT_MAKEFILE) $@
git_undo_last_commit_after_push:
	make -f $(GIT_MAKEFILE) $@
git_new_remote_origin_https:
	make -f $(GIT_MAKEFILE) $@
git_new_remote_origin_template_https:
	make -f $(GIT_MAKEFILE) $@
git_history:
	make -f $(GIT_MAKEFILE) $@
git_goto_commit:
	make -f $(GIT_MAKEFILE) $@
git_new_private_repo:
	make -f $(GIT_MAKEFILE) $@
git_new_public_repo:
	make -f $(GIT_MAKEFILE) $@
git_new_private_repo_from_template:
	make -f $(GIT_MAKEFILE) $@
git_new_public_repo_from_template:
	make -f $(GIT_MAKEFILE) $@
git_make_this_repo_template:
	make -f $(GIT_MAKEFILE) $@
git_clone_repo_https:
	make -f $(GIT_MAKEFILE) $@
git_connected_repos:
	make -f $(GIT_MAKEFILE) $@
git_list_branches:
	make -f $(GIT_MAKEFILE) $@
git_new_branch:
	make -f $(GIT_MAKEFILE) $@
git_switch_branch:
	make -f $(GIT_MAKEFILE) $@
git_compare_with_main_branch:
	make -f $(GIT_MAKEFILE) $@
git_merge_to_main_branch:
	make -f $(GIT_MAKEFILE) $@
git_update_changes_thisbranch_projrepo:
	make -f $(GIT_MAKEFILE) $@
git_update_changes_mainbranch_templrepo:
	make -f $(GIT_MAKEFILE) $@


# -------------------------------------------------------------
#  "packages.mk" targets
# -------------------------------------------------------------
pip_install:
	make -f $(PACKAGES_MAKEFILE) $@
pip_upgrade:
	make -f $(PACKAGES_MAKEFILE) $@
choco_install:
	make -f $(PACKAGES_MAKEFILE) $@
choco_upgrade:
	make -f $(PACKAGES_MAKEFILE) $@
winget_install:
	make -f $(PACKAGES_MAKEFILE) $@
winget_upgrade:
	make -f $(PACKAGES_MAKEFILE) $@
git_upgrade:
	make -f $(PACKAGES_MAKEFILE) $@
install_all_pkg:
	make -f $(PACKAGES_MAKEFILE) $@
upgrade_all_pkg:
	make -f $(PACKAGES_MAKEFILE) $@