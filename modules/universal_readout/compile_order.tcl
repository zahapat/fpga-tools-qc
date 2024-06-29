

# -------------------------------------------------------
# 2.0) Add TB Package Files
# -------------------------------------------------------
#    * ModelSim



# -------------------------------------------------------
# 2.1) Add TB Files
# -------------------------------------------------------
#    * ModelSim 
add_sim_file ./modules/universal_readout/sim/universal_readout_tb.vhd



# -------------------------------------------------------
# 1.0) Add SRC Package Files
# -------------------------------------------------------
#    * Vivado
#    * ModelSim


# -------------------------------------------------------
# 1.1) Add SRC HDL Files
# -------------------------------------------------------
#    * Vivado
add_src_file lib_src ./modules/universal_readout/hdl/universal_readout.vhd

#    * ModelSim
add_sim_file ./modules/universal_readout/hdl/universal_readout.vhd