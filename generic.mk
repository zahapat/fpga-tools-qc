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


# Initialize Simulator (Questa)
sim_init :
	$(info ----- INITIALIZE SIMULATOR -----)
	vmap -c
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


# Generic Python GUI
PY_GUI_PATH = ./scripts/gui
PY_GUI_MAINFILE = guiMain.py
PY_GUI_INSTALLFILE = install.bat
PY_GUI_EXEFILE = gui.exe
GUI_GEOMETRY = 100x100
PY_GUI_GENERIC_ARGS = 	--generic1_name=$(GEN1_NAME) --generic1_val=$(GEN1_VAL) \
						--generic2_name=$(GEN2_NAME) --generic2_val=$(GEN2_VAL) \
						--generic3_name=$(GEN3_NAME) --generic3_val=$(GEN3_VAL) \
						--generic4_name=$(GEN4_NAME) --generic4_val=$(GEN4_VAL) \
						--generic5_name=$(GEN5_NAME) --generic5_val=$(GEN5_VAL) \
						--generic6_name=$(GEN6_NAME) --generic6_val=$(GEN6_VAL) \
						--generic7_name=$(GEN7_NAME) --generic7_val=$(GEN7_VAL) \
						--generic8_name=$(GEN8_NAME) --generic8_val=$(GEN8_VAL) \
						--generic9_name=$(GEN9_NAME) --generic9_val=$(GEN9_VAL) \
						--generic10_name=$(GEN10_NAME) --generic10_val=$(GEN10_VAL) \
						--generic11_name=$(GEN11_NAME) --generic11_val=$(GEN11_VAL) \
						--generic12_name=$(GEN12_NAME) --generic12_val=$(GEN12_VAL) \
						--generic13_name=$(GEN13_NAME) --generic13_val=$(GEN13_VAL) \
						--generic14_name=$(GEN14_NAME) --generic14_val=$(GEN14_VAL) \
						--generic15_name=$(GEN15_NAME) --generic15_val=$(GEN15_VAL) \

py_gui_regen:
	make py_gui_pipinstall
	make py_gui_install
	make py_gui_exe

py_gui:
	$(info ------- RUNNING PYTHON GUI FROM PYTHON SCRIPT -------)
	py -3 $(PY_GUI_PATH)/$(PY_GUI_MAINFILE)\
		$(PY_GUI_GENERIC_ARGS)\
		--geometry=$(GUI_GEOMETRY)\
		--proj_name=$(PROJ_NAME)\
		--proj_dir=.\
		--verbose

py_gui_install:
	$(info ------- GENERATING EXECUTABLE USING PYTHONINSTALLER -------)
	cd $(PY_GUI_PATH)
	./$(PY_GUI_INSTALLFILE)
	cd ~

py_gui_exe: 
	$(info ------- RUNNING PROJECT GUI EXECUTABLE -------)
	$(PY_GUI_PATH)/$(PY_GUI_EXEFILE) $(PY_GUI_GENERIC_ARGS)


#  CRC Generator
SYMBOL_WIDTH = 4
SYMBOLS_COUNT = 11
PRIMITIVE_POLYNOMIAL_DECIMAL = 19
GF_SEED = 1
GENPOL_SYMBOLS_COUNT = 4
TX_SUBMESSAGES_COUNT = 3
RX_SUBMESSAGES_COUNT = 3
SIM_TRANSACTIONS_COUNT = 20

crc:
	$(info ----- GENERATE CRC VHDL FILES -----)
	python3 ./scripts/crc_gen/CrcGenMain.py \
	    --symbol_width=$(SYMBOL_WIDTH) \
		--symbols_count=$(SYMBOLS_COUNT) \
		--primitive_polynomial=$(PRIMITIVE_POLYNOMIAL_DECIMAL) \
		--gf_seed=$(GF_SEED) \
		--genpol_symbols_count=$(GENPOL_SYMBOLS_COUNT) \
		--tx_submessages_count=$(TX_SUBMESSAGES_COUNT) \
		--rx_submessages_count=$(TX_SUBMESSAGES_COUNT) \
		--sim_transactions_count=$(SIM_TRANSACTIONS_COUNT) \
	    --proj_dir=$(PROJ_DIR) \
		--gfmult_dir=$(PROJ_DIR)/modules/gfmult_constb \
		--tx_dir=$(PROJ_DIR)/modules/tx_crc_symtuppar \
		--rx_dir=$(PROJ_DIR)/modules/rx_crc_symtuppar \
		--src_lib=$(LIB_SRC) \
		--sim_lib=$(LIB_SIM)

# TX CRC
build_sim_gui_tx:
	make reset
	make crc
	make src TOP=tx_crc_symtuppar_tb.vhd
	make sim_gui

build_sim_tx:
	make reset
	make crc
	make src TOP=tx_crc_symtuppar_tb.vhd
	make sim_gui

# RX CRC
build_sim_gui_rx:
	make reset
	make crc
	make src TOP=rx_crc_symtuppar_tb.vhd
	make sim_gui

build_sim_rx:
	make reset
	make crc
	make src TOP=rx_crc_symtuppar_tb.vhd
	make sim_gui

# TX + RX CRC sim cli
build_sim_txrx:
	make reset
	make crc
	make src TOP=tx_crc_symtuppar_tb.vhd
	make sim
	make src TOP=rx_crc_symtuppar_tb.vhd
	make sim

# CRC sim gui
build_sim_gui_crc:
	make reset
	make crc
	make src TOP=crc_tb.vhd
	make sim_gui

build_sim_crc:
	make reset
	make crc
	make src TOP=crc_tb.vhd
	make sim