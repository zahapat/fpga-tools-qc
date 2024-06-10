
# -------------------------------------------------------
# 2.1) Add TB Files
# -------------------------------------------------------
#    * ModelSim


# -------------------------------------------------------
# 2.0) Add TB Package Files
# -------------------------------------------------------
#    * ModelSim



# -------------------------------------------------------
# 1.1) Add SRC HDL Files
# -------------------------------------------------------
#    * Vivado
#    * ModelSim


# -------------------------------------------------------
# 1.0) Add SRC Package Files
# -------------------------------------------------------
#    * ModelSim
add_sim_file ./packages/global_src/signals_pack.vhd
add_sim_file ./packages/global_src/types_pack.vhd
add_sim_file ./packages/global_src/const_pack.vhd
add_sim_file ./packages/global_src/generics.vhd

#    * Vivado
add_src_file lib_src ./packages/global_src/signals_pack.vhd
add_src_file lib_src ./packages/global_src/types_pack.vhd
add_src_file lib_src ./packages/global_src/const_pack.vhd
add_src_file lib_src ./packages/global_src/generics.vhd