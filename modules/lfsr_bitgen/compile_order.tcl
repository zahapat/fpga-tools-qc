# -------------------------------------------------------
# 2.0) Add TB Package Files
# -------------------------------------------------------
#    * ModelSim


# -------------------------------------------------------
# 2.1) Add TB Files
# -------------------------------------------------------
#    * ModelSim
add_sim_file ./modules/lfsr_bitgen/sim/lfsr_bitgen_tb.vhd


# -------------------------------------------------------
# 1.0) Add SRC Package Files
# -------------------------------------------------------
#    * Vivado
#    * ModelSim


# -------------------------------------------------------
# 1.1) Add SRC HDL Files
# -------------------------------------------------------
#    * Vivado
add_src_file lib_src ./modules/lfsr_bitgen/hdl/lfsr_bitgen.vhd

#    * ModelSim
add_sim_file ./modules/lfsr_bitgen/hdl/lfsr_bitgen.vhd