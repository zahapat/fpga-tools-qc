# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
# Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(dir $(abspath $(firstword $(MAKEFILE_LIST))))


# Set subshell environment
SUBSHELL_ENV = sed -i 's/\r//g' helpers/init.sh; . ./helpers/init.sh; vivado


# Search for .xpr files in ./$(VPATH)
VPATH = vivado


# Prerequisites are located here
OBJDIR := ./vivado


# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:


# Generic Vitis Targets
WORKSPACE_NAME ?= workspace1
PLATFORM_NAME ?= platform1
WORKSPACE_PATH = ./vitis/$(WORKSPACE_NAME)
XSA_PATH ?= ./vivado/4_hw_platform_$(PROJ_NAME).xsa
DOMAIN_NAME ?= domain1
PROCESSOR_NAME ?= microblaze
PROCESSOR_INSTANCE ?= 0
DOMAIN_OS ?= standalone
SYSTEM_NAME ?= system1


remove_vitis :
	rm -r ./vitis/*

remove_ws_vitis :
	rm -r ./vitis/$(WORKSPACE_NAME)

new_vitis :
	$(SUBSHELL_ENV)
	which vitis
	which xsct
	xsct.bat tcl/generic/vitis/recreate_vitis_proj.tcl $(PART) $(BOARD) $(WORKSPACE_NAME) $(PLATFORM_NAME) $(XSA_PATH) $(DOMAIN_NAME) $(PROCESSOR_NAME) $(PROCESSOR_INSTANCE) $(DOMAIN_OS) $(SYSTEM_NAME)

APP_NAME ?= app1
new_app_vitis :
	$(SUBSHELL_ENV)
	which vitis
	which xsct
	xsct.bat tcl/generic/vitis/make_new_app.tcl $(WORKSPACE_NAME) $(PLATFORM_NAME) $(DOMAIN_NAME) $(SYSTEM_NAME) $(APP_NAME)

add_sources_vitis :
	$(SUBSHELL_ENV)
	which vitis
	which xsct
	xsct.bat tcl/generic/vitis/make_new_app.tcl $(WORKSPACE_NAME) $(PLATFORM_NAME) $(DOMAIN_NAME) $(SYSTEM_NAME) $(APP_NAME)

gui_vitis :
	$(SUBSHELL_ENV)
	xsct.bat -interactive -eval "setws -switch $(WORKSPACE_PATH); \
		platform read $(WORKSPACE_PATH)/$(PLATFORM_NAME)/platform.spr; \
 		platform active $(PLATFORM_NAME); \
		vitis; \
		exit;"

bsp_regen_vitis :
	$(SUBSHELL_ENV)
		which vitis
		which xsct
		xsct.bat -eval "setws -switch $(WORKSPACE_PATH); \
			platform read $(WORKSPACE_PATH)/$(PLATFORM_NAME)/platform.spr; \
			platform active $(PLATFORM_NAME); \
			bsp regenerate;"

reset_vitis :
	$(SUBSHELL_ENV)
	which vitis
	which xsct
	make remove_vitis
	make new_vitis
	make new_app_vitis
	make gui_vitis

all_vitis :
	make clean_vitis
	make new_plat
	make new_app
	make build_app
	make vitis_reports