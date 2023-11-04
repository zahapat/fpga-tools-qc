

# -------------------------------------------------------
# 2.1) Add TB Files
# -------------------------------------------------------
#    * ModelSim
add_sim_file ./modules/lfsr_inemul/sim/lfsr_inemul_tb.vhd
add_sim_file ./modules/lfsr_inemul/sim/checkers_lfsr_inemul_tb.vhd
add_sim_file ./modules/lfsr_inemul/sim/monitors_lfsr_inemul_tb.vhd
add_sim_file ./modules/lfsr_inemul/sim/executors_lfsr_inemul_tb.vhd
add_sim_file ./modules/lfsr_inemul/sim/harness_lfsr_inemul_tb.vhd


# -------------------------------------------------------
# 2.0) Add TB Package Files
# -------------------------------------------------------
#    * ModelSim
add_sim_file ./modules/lfsr_inemul/sim/pack/triggers_lfsr_inemul_pack_tb.vhd
add_sim_file ./modules/lfsr_inemul/sim/pack/signals_lfsr_inemul_pack_tb.vhd
add_sim_file ./modules/lfsr_inemul/sim/pack/types_lfsr_inemul_pack_tb.vhd
add_sim_file ./modules/lfsr_inemul/sim/pack/const_lfsr_inemul_pack_tb.vhd




# -------------------------------------------------------
# 1.1) Add SRC HDL Files
# -------------------------------------------------------
#    * Vivado
add_src_file lib_src ./modules/lfsr_inemul/hdl/lfsr_inemul.vhd

#    * ModelSim
add_sim_file ./modules/lfsr_inemul/hdl/lfsr_inemul.vhd


# -------------------------------------------------------
# 1.0) Add SRC Package Files
# -------------------------------------------------------
#    * Vivado
#    * ModelSim

