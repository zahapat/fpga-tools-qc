
# -------------------------------------------------------
# 2.0) Add TB Package Files
# -------------------------------------------------------
#    * ModelSim


# -------------------------------------------------------
# 2.1) Add TB Files
# -------------------------------------------------------
#    * ModelSim
add_sim_file ./modules/alu_flowambiguity/sim/alu_flowambiguity_tb.vhd


# -------------------------------------------------------
# 1.0) Add SRC Package Files
# -------------------------------------------------------
#    * Vivado
#    * ModelSim



# -------------------------------------------------------
# 1.1) Add SRC HDL Files
# -------------------------------------------------------
#    * Vivado
add_src_file lib_src ./modules/alu_flowambiguity/hdl/alu_flowambiguity.vhd

#    * ModelSim
add_sim_file ./modules/alu_flowambiguity/hdl/alu_flowambiguity.vhd