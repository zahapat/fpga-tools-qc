

# -------------------------------------------------------
# 2.0) Add TB Package Files
# -------------------------------------------------------
#    * ModelSim


# -------------------------------------------------------
# 2.1) Add TB Files
# -------------------------------------------------------
#    * ModelSim
add_sim_file ./modules/xilinx_iophase_aligner/sim/xilinx_iophase_aligner_tb.vhd


# -------------------------------------------------------
# 1.0) Add SRC Package Files
# -------------------------------------------------------
#    * Vivado
#    * ModelSim


# -------------------------------------------------------
# 1.1) Add SRC HDL Files
# -------------------------------------------------------
#    * Vivado
add_src_file lib_src ./modules/clock_synthesizer/hdl/clock_synthesizer.sv
add_src_file lib_src ./modules/xilinx_iophase_aligner/hdl/xilinx_iophase_aligner.vhd

#    * ModelSim
add_sim_file ./modules/clock_synthesizer/hdl/clock_synthesizer.sv
add_sim_file ./modules/xilinx_iophase_aligner/hdl/xilinx_iophase_aligner.vhd

