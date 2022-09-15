# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
#  Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(shell pwd)



# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:


# Redis server
redis_start:
	wsl.exe sudo service redis-server start
	wsl.exe echo "Redis Server Started"

redis_stop:
	wsl.exe sudo service redis-server stop
	wsl.exe echo "Redis Server Stopped"


# Project initialization/reset targets
reset :
	make new
	make clean

home_path :
	$(info ----- INITIALIZE CYGWIN HOME DIRECTORY -----)
	py -3 helpers/init.py

init_modelsim : home_path
	$(info ----- INITIALIZE MODELSIM -----)
	vmap -c

init : init_modelsim
	$(info ----- LAUNCH CYGWIN, SET MODELSIM ENV -----)
	C:/cygwin64/cygwin.bat
	set MODELSIM=modelsim.ini


# UVVM Targets
vvc_gen :
	$(info ------- RUNNING UVVM VVC GENERATOR -------)
	$(info RENAME THE OUTPUT FOLDER IN:)
	$(info    ./packages/vip/output)
	$(info TO:)
	$(info    ./packages/vip/vip_<name>)
	$(info ------------------------------------------)
	pwd
	cd ./packages/vip
	pwd
	py -3 ../uvvm/uvvm_vvc_framework/script/vvc_generator/vvc_generator.py
	cd ~
	pwd