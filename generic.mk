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