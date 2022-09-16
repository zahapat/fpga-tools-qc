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

# Pip
pip_install:
	py -3 -m pip install
	pip install --user git

pip_upgrade:
	py -3 -m pip install --upgrade pip

# Choco requires elevation
choco_install:
	powershell -Command "Start-Process -FilePath 'cmd.exe' \
	-ArgumentList ('/c choco install make gh') -Verb RunAs"

choco_upgrade:
	powershell -Command "Start-Process -FilePath 'cmd.exe' \
	-ArgumentList ('/c choco upgrade chocolatey make gh') -Verb RunAs"

# Winget
winget_install:
	winget install --id Git.Git -e --source winget
	winget install --id Microsoft.VisualStudio.2022.Community --source winget
	winget install --id Microsoft.VisualStudio.2022.BuildTools --source winget
	winget install --id Kitware.CMake --source winget
	winget install --id Microsoft.WindowsSDK --source winget

winget_upgrade:
	winget upgrade -h --id Git.Git
	winget upgrade -h --id Microsoft.VisualStudio.2022.Community
	winget upgrade -h --id Microsoft.VisualStudio.2022.BuildTools
	winget upgrade -h --id Kitware.CMake
	winget upgrade -h --id Microsoft.WindowsSDK

# Git
git_update_win:
	git update-git-for-windows

# All
install_all_pkg:
	make winget_install
	make pip_install
	make choco_install

upgrade_all_pkg:
	make winget_upgrade
	make pip_upgrade
	make choco_upgrade
	make git_update_win