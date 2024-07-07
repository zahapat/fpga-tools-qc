
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
WINPATH_TO_EXE_FILE = $(WINPATH_TO_DEBUG)

# Launch csv_readout.exe with these CLI arguments
QUBITS_CNT = 4
RUN_TIME_SECONDS = 2.0
BITFILE_NAME = bit_file.bit
PROGRAM_ONLY = true
EXE_FILE_CALL = csv_readout.exe \
				--qubits_count $(QUBITS_CNT) \
				--float_run_time_seconds $(RUN_TIME_SECONDS) \
				--bitfile_name $(BITFILE_NAME) \
				--program_only $(PROGRAM_ONLY)


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

copy_okFrontPaneldll:
	cp ./lib/okFrontPanel.dll $(WINPATH_TO_EXE_FILE)

# cmake -DCMAKE_SYSTEM_VERSION=10.0.17763.0
rescan:
	make clean
	cmake -G "Visual Studio 17 2022" \
		  -A $(ARCH) \
		  -B "build"
	cmake --build build \
	      --config Release
	make build
	make copy_okFrontPaneldll WINPATH_TO_EXE_FILE=$(PATH_TO_DEBUG)
	make copy_okFrontPaneldll WINPATH_TO_EXE_FILE=$(PATH_TO_RELEASE)

build:
	$(WINPATH_TO_MSBUILD)\MSBuild.exe ./build/$(PROJ_NAME).sln

run: $(EXEFILE_PATH_DEBUG)
	$(WINPATH_TO_DEBUG)\$(EXE_FILE_CALL)

run_release: $(EXEFILE_PATH_RELEASE)
	$(WINPATH_TO_RELEASE)\$(EXE_FILE_CALL)




# redis_start:
# 	wsl sudo service redis-server start
# 	wsl echo "Attempting Redis Server Start"

# redis_stop:
# 	wsl sudo service redis-server stop
# 	wsl echo "Attempting Redis Server Stop"