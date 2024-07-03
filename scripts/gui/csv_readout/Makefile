
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(shell pwd)

WINPATH_TO_MSBUILD = C:\Program Files\Microsoft Visual Studio\2022\Community\Msbuild\Current\Bin

GENERATOR = "Visual Studio 17 2022"
ARCH = x64


WINPATH_TO_DEBUG = .\build\Debug
PATH_TO_DEBUG = ./build/Debug
EXEFILE_PATH_DEBUG = $(PATH_TO_DEBUG)/$(PROJ_NAME).exe
WINPATH_TO_RELEASE = .\build\Release
PATH_TO_RELEASE = ./build/Release
EXEFILE_PATH_RELEASE = $(PATH_TO_RELEASE)/$(PROJ_NAME).exe


# Set subshell environment (If needed)
# SUBSHELL_ENV = sed -i 's/\r//g' subshell_env.sh; . ./subshell_env.sh


.ONESHELL:

all:
	make rescan
	make build
	make redis_start
	make run_release


compile: 
	make rescan
	make build


.PHONY: clean rescan build run launch_wsl redis_start redis_stop

clean:
	rm -r ./build/

# cp ./lib/okFrontPanel.dll ./build/Release/okFrontPanel.dll
copy_okFrontPaneldll:
	cp ./lib/okFrontPanel.dll $(WINPATH_TO_RELEASE)\okFrontPanel.dll

# cmake -DCMAKE_SYSTEM_VERSION=10.0.17763.0
rescan:
	make clean
	cmake -G "Visual Studio 17 2022" \
		  -A $(ARCH) \
		  -B "build"
	cmake --build build \
	      --config Release
	make copy_okFrontPaneldll
	make build

build:
	$(WINPATH_TO_MSBUILD)\MSBuild.exe ./build/$(PROJ_NAME).sln

run: $(EXEFILE_PATH_DEBUG)
	$(shell $(WINPATH_TO_DEBUG)\$(PROJ_NAME).exe)
	echo Run Done

run_release: $(EXEFILE_PATH_RELEASE)
	$(shell $(WINPATH_TO_RELEASE)\$(PROJ_NAME).exe)
	echo Run Release Done




redis_start:
	wsl sudo service redis-server start
	wsl echo "Attempting Redis Server Start"

redis_stop:
	wsl sudo service redis-server stop
	wsl echo "Attempting Redis Server Stop"