# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
# Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(shell pwd)



# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:

init:
	make reset
	make src TOP=top_gflow_tb.vhd

build:
	make reset
	make src TOP=top_gflow_tb.vhd
	make generics
	make all
	make reset_bitfiles

reset_bitfiles: 3_bitstream_$(PROJ_NAME).bit
	rm ./scripts/gui/redis/bitfile.bit
	cp ./vivado/3_bitstream_$(PROJ_NAME).bit ./scripts/gui/redis/bitfile.bit

cmd_timeout:
	timeout /t 6