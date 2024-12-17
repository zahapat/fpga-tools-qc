
# -------------------------------------------------------
# 2.0) Add TB Package Files
# -------------------------------------------------------
#    * ModelSim


# -------------------------------------------------------
# 2.1) Add TB Files
# -------------------------------------------------------
#    * ModelSim
add_sim_file ./modules/shiftreg_delay/sim/shiftreg_delay_tb.vhd


# -------------------------------------------------------
# 1.0) Add SRC Package Files
# -------------------------------------------------------
#    * ModelSim
#    * Vivado



# -------------------------------------------------------
# 1.1) Add SRC HDL Files
# -------------------------------------------------------
#    * ModelSim
add_sim_file ./modules/shiftreg_delay/hdl/shiftreg_delay.vhd

#    * Vivado
add_src_file lib_src ./modules/shiftreg_delay/hdl/shiftreg_delay.vhd
