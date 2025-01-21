
# -------------------------------------------------------
# 2.0) Add TB Package Files
# -------------------------------------------------------
#    * ModelSim


# -------------------------------------------------------
# 2.1) Add TB Files
# -------------------------------------------------------
#    * ModelSim
add_sim_file ./modules/top_gflow/sim/top_gflow_tb.vhd




# -------------------------------------------------------
# 1.0) Add SRC Package Files
# -------------------------------------------------------
#    * ModelSim
#    * Vivado


# -------------------------------------------------------
# 1.1) Add SRC HDL Files
# -------------------------------------------------------
#    * ModelSim
add_sim_file ./modules/top_gflow/hdl/top_gflow.vhd

#    * Vivado
add_src_file lib_src ./modules/top_gflow/hdl/top_gflow_ok_wrapper.vhd
add_src_file lib_src ./modules/top_gflow/hdl/top_gflow.vhd


# -------------------------------------------------------------------------------
# Add accociated compile_order.tcl sumbodule scripts (added before this module) -
# -------------------------------------------------------------------------------
# This is necessary to add required submodules to successfully compile and implement this module
source "${origin_dir}/packages/ok/frontpanel_xem7350_k160t/compile_order.tcl"
