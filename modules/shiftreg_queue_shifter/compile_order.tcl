

# -------------------------------------------------------
# 2.0) Add TB Package Files
# -------------------------------------------------------
#    * ModelSim



# -------------------------------------------------------
# 2.1) Add TB Files
# -------------------------------------------------------
#    * ModelSim 
add_sim_file ./modules/shiftreg_queue_shifter/sim/shiftreg_queue_shifter_tb.vhd



# -------------------------------------------------------
# 1.0) Add SRC Package Files
# -------------------------------------------------------
#    * Vivado
#    * ModelSim


# -------------------------------------------------------
# 1.1) Add SRC HDL Files
# -------------------------------------------------------
#    * Vivado
add_src_file lib_src ./modules/shiftreg_queue_shifter/hdl/shiftreg_queue_shifter.vhd

#    * ModelSim
add_sim_file ./modules/shiftreg_queue_shifter/hdl/shiftreg_queue_shifter.vhd