# -------------------------------------------------------
# 1.0) Add SRC Package Files
# -------------------------------------------------------
#    * Vivado
#      USER INPUT
add_src_file "" ./modules/srcname/hdl/srcname.vhd
add_src_file lib_src ./modules/srcname/hdl/srcname.vhd


#    * ModelSim
#      USER INPUT
add_sim_file ./modules/srcname/hdl/pack/const_srcname_pack.vhd
add_sim_file ./modules/srcname/hdl/pack/types_srcname_pack.vhd
add_sim_file ./modules/srcname/hdl/pack/signals_srcname_pack.vhd


# -------------------------------------------------------
# 1.1) Add SRC HDL Files
# -------------------------------------------------------
#    * Vivado
#      USER INPUT
add_src_file "" ./modules/srcname/hdl/srcname.vhd
add_src_file lib_src ./modules/srcname/hdl/srcname.vhd

#    * Modelsim


# -------------------------------------------------------
# 2.0) Add TB Package Files
# -------------------------------------------------------
#    * ModelSim
#      USER INPUT
add_sim_file ./modules/srcname/sim/pack/const_srcname_pack_tb.vhd
add_sim_file ./modules/srcname/sim/pack/types_srcname_pack_tb.vhd
add_sim_file ./modules/srcname/sim/pack/signals_srcname_pack_tb.vhd
add_sim_file ./modules/srcname/sim/pack/triggers_srcname_pack_tb.vhd


# -------------------------------------------------------
# 2.1) Add TB Files
# -------------------------------------------------------
#    * ModelSim
#      USER INPUT
add_sim_file ./modules/srcname/sim/harness_srcname_tb.vhd
add_sim_file ./modules/srcname/sim/executors_srcname_tb.vhd
add_sim_file ./modules/srcname/sim/monitors_srcname_tb.vhd
add_sim_file ./modules/srcname/sim/checkers_srcname_tb.vhd
add_sim_file ./modules/srcname/sim/srcname_tb.vhd