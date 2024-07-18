# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
# Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(dir $(abspath $(firstword $(MAKEFILE_LIST))))



# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:

init:
	make reset
	make src TOP=top_gflow_tb.vhd

distribute_bitfiles: ./vivado/3_bitstream_$(PROJ_NAME).bit
	rm ./scripts/gui/redis/bitfile.bit
	cp ./vivado/3_bitstream_$(PROJ_NAME).bit ./scripts/gui/redis/bitfile.bit

cmd_timeout:
	timeout /t 6