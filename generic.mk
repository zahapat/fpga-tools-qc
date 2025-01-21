# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
#  Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

GENERIC_ARGS = 	--generic1_name=$(GEN1_NAME)   --generic1_val=$(GEN1_VAL)\
			    --generic2_name=$(GEN2_NAME)   --generic2_val=$(GEN2_VAL)\
			    --generic3_name=$(GEN3_NAME)   --generic3_val=$(GEN3_VAL)\
			    --generic4_name=$(GEN4_NAME)   --generic4_val=$(GEN4_VAL)\
			    --generic5_name=$(GEN5_NAME)   --generic5_val=$(GEN5_VAL)\
			    --generic6_name=$(GEN6_NAME)   --generic6_val=$(GEN6_VAL)\
			    --generic7_name=$(GEN7_NAME)   --generic7_val=$(GEN7_VAL)\
			    --generic8_name=$(GEN8_NAME)   --generic8_val=$(GEN8_VAL)\
			    --generic9_name=$(GEN9_NAME)   --generic9_val=$(GEN9_VAL)\
			    --generic10_name=$(GEN10_NAME) --generic10_val=$(GEN10_VAL)\
			    --generic11_name=$(GEN11_NAME) --generic11_val=$(GEN11_VAL)\
			    --generic12_name=$(GEN12_NAME) --generic12_val=$(GEN12_VAL)\
			    --generic13_name=$(GEN13_NAME) --generic13_val=$(GEN13_VAL)\
			    --generic14_name=$(GEN14_NAME) --generic14_val=$(GEN14_VAL)\
			    --generic15_name=$(GEN15_NAME) --generic15_val=$(GEN15_VAL)\
			    --generic16_name=$(GEN16_NAME) --generic16_val=$(GEN16_VAL)\
			    --generic17_name=$(GEN17_NAME) --generic17_val=$(GEN17_VAL)\
			    --generic18_name=$(GEN18_NAME) --generic18_val=$(GEN18_VAL)\
			    --generic19_name=$(GEN19_NAME) --generic19_val=$(GEN19_VAL)\
			    --generic20_name=$(GEN20_NAME) --generic20_val=$(GEN20_VAL)\
			    --generic21_name=$(GEN21_NAME) --generic21_val=$(GEN21_VAL)\
			    --generic22_name=$(GEN22_NAME) --generic22_val=$(GEN22_VAL)\
			    --generic23_name=$(GEN23_NAME) --generic23_val=$(GEN23_VAL)\
			    --generic24_name=$(GEN24_NAME) --generic24_val=$(GEN24_VAL)\
			    --generic25_name=$(GEN25_NAME) --generic25_val=$(GEN25_VAL)\
			    --generic26_name=$(GEN26_NAME) --generic26_val=$(GEN26_VAL)\
			    --generic27_name=$(GEN27_NAME) --generic27_val=$(GEN27_VAL)\
			    --generic28_name=$(GEN28_NAME) --generic28_val=$(GEN28_VAL)\
			    --generic29_name=$(GEN29_NAME) --generic29_val=$(GEN29_VAL)\
			    --generic30_name=$(GEN30_NAME) --generic30_val=$(GEN30_VAL)\
				--generic31_name=$(GEN31_NAME) --generic31_val=$(GEN31_VAL)\
				--generic32_name=$(GEN32_NAME) --generic32_val=$(GEN32_VAL)\
				--generic33_name=$(GEN33_NAME) --generic33_val=$(GEN33_VAL)\
				--generic34_name=$(GEN34_NAME) --generic34_val=$(GEN34_VAL)\
				--generic35_name=$(GEN35_NAME) --generic35_val=$(GEN35_VAL)\
				--generic36_name=$(GEN36_NAME) --generic36_val=$(GEN36_VAL)\
				--generic37_name=$(GEN37_NAME) --generic37_val=$(GEN37_VAL)\



# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:

# Generate a vhdl/verilog file with Generic variables
generics :
	py -3 ./scripts/generics/genGenericsMain.py \
		$(GENERIC_ARGS)\
		--proj_name=$(PROJ_NAME) \
		--proj_dir=$(PROJ_DIR) \
		--output_dir=$(OUTPUT_DIR)

essentials :
	py -3 ./scripts/essentials/genEssentialsMain.py \
		--proj_name=$(PROJ_NAME) \
		--proj_dir=$(PROJ_DIR) \
		--output_dir=$(OUTPUT_DIR)

# Redis server
redis_start:
	wsl.exe sudo service redis-server start
	wsl.exe echo "Redis Server Started"

redis_stop:
	wsl.exe sudo service redis-server stop
	wsl.exe echo "Redis Server Stopped"


# UVVM Targets
vvc_gen :
	cd ./packages/vip
	py -3 ../uvvm/uvvm_vvc_framework/script/vvc_generator/vvc_generator.py


py_gui_regen:
	make py_gui_pipinstall
	make py_gui_install
	make py_gui_exe

# [make py_gui and below]
PY_GUI_PATH = ./scripts/gui
PY_GUI_MAINFILE = guiMain.py
PY_GUI_INSTALLFILE = install.bat
PY_GUI_EXEFILE = gui.exe
GUI_GEOMETRY = 100x100


py_gui:
	$(info ------- RUNNING PYTHON GUI FROM PYTHON SCRIPT -------)
	py -3 $(PY_GUI_PATH)/$(PY_GUI_MAINFILE)\
		$(GENERIC_ARGS)\
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