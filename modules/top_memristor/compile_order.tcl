
# -------------------------------------------------------
# 2.0) Add TB Package Files
# -------------------------------------------------------
#    * ModelSim


# -------------------------------------------------------
# 2.1) Add TB Files
# -------------------------------------------------------
#    * ModelSim
puts -nonewline $simulator_comporder "\
    ./modules/top_memristor/sim/top_memristor_tb.vhd\n"


# -------------------------------------------------------
# 1.0) Add SRC Package Files
# -------------------------------------------------------
#    * Vivado
#    * ModelSim


# -------------------------------------------------------
# 1.1) Add SRC HDL Files
# -------------------------------------------------------
#    * Vivado
add_src_file lib_src ./modules/top_memristor/hdl/top_memristor.vhd

#    * ModelSim
add_sim_file ./modules/top_memristor/hdl/top_memristor.vhd