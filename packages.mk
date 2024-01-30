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

# Vcpkg C/C++ Libraries
vcpkg_install:
	vcpkg install hiredis:x64-windows
	vcpkg install redis-plus-plus:x64-windows


# Pip
pip_install:
	powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList ('/c py -3 -m pip install') -Verb RunAs"
	pip install --user git
	pip install pillow
	pip freeze
	pip install requests
	pip install numpy
	pip install matplotlib
	pip install pyinstaller
	pip install redis
	pip install walrus
	pip install pyqtgraph
	pip install PyQt6

pip_upgrade:
	powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList ('/c py -3 -m pip install --upgrade pip') -Verb RunAs"
	pip install pillow --upgrade
	pip install requests --upgrade
	pip install numpy --upgrade
	pip install matplotlib --upgrade
	pip install pyinstaller --upgrade
	pip install redis --upgrade
	pip install walrus --upgrade
	pip install pyqtgraph --upgrade
	pip install PyQt6 --upgrade

# Choco requires elevation
choco_install:
	powershell -Command "Start-Process -FilePath 'cmd.exe' \
	-ArgumentList ('/c choco install make gh') -Verb RunAs"

choco_upgrade:
	powershell -Command "Start-Process -FilePath 'cmd.exe' \
	-ArgumentList ('/c choco upgrade chocolatey make gh') -Verb RunAs"

# Winget
winget_install:
	winget install --id Kitware.CMake --source winget

winget_upgrade:
	winget upgrade -h --id Git.Git
	winget upgrade -h --id Microsoft.VisualStudio.2022.Community
	winget upgrade -h --id Kitware.CMake
	winget upgrade -h --id Microsoft.WindowsSDK

# Git
git_update_win:
	git update-git-for-windows


# Linux Subsystem: Disable your Firewall in case issues arise
config_wsl:
	wsl sudo add-apt-repository universe
	wsl sudo apt-get update
	wsl sudo apt-get upgrade
	wsl sudo apt-cache search redis-server
	wsl sudo apt-get install redis-server
	wsl redis-server --version


# All
install_all_pkg:
	make winget_install
	make pip_install
	make choco_install
	make vcpkg_install

upgrade_all_pkg:
	make winget_upgrade
	make pip_upgrade
	make choco_upgrade
	make git_update_win