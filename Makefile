# Usage Examples:
# make gacp MSG="fix: Enable commit msg from cli"  <--- YOU  MUST enter the commit message in quotation marks

# Requires Github CLI + git installed


# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
#  Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(shell pwd)


#  Links to source Make files
PROJECT_SPECIFIC_MAKEFILE = project_specific.mk
GENERIC_MAKEFILE = generic.mk
VIVADO_MAKEFILE = vivado.mk
VITIS_MAKEFILE = vitis.mk
GIT_MAKEFILE = git.mk
PACKAGES_MAKEFILE = packages.mk



# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:



# -------------------------------------------------------------
#  "project_specific.mk" targets
# -------------------------------------------------------------
rebuild_proj:
	make -f $(PROJECT_SPECIFIC_MAKEFILE) $@
reset_bitfiles: 3_bitstream_$(PROJ_NAME).bit
	make -f $(PROJECT_SPECIFIC_MAKEFILE) $@
cmd_timeout:
	make -f $(PROJECT_SPECIFIC_MAKEFILE) $@



# -------------------------------------------------------------
#  "vivado.mk" targets
# -------------------------------------------------------------
# TODO



# -------------------------------------------------------------
#  "vitis.mk" targets
# -------------------------------------------------------------
# TODO



# -------------------------------------------------------------
#  "generic.mk" targets
# -------------------------------------------------------------
redis_start:
	make -f $(GENERIC_MAKEFILE) $@
redis_stop:
	make -f $(GENERIC_MAKEFILE) $@
reset :
	make -f $(GENERIC_MAKEFILE) $@
home_path :
	make -f $(GENERIC_MAKEFILE) $@
init_modelsim : home_path
	make -f $(GENERIC_MAKEFILE) $@
init : init_modelsim
	make -f $(GENERIC_MAKEFILE) $@
vvc_gen :
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