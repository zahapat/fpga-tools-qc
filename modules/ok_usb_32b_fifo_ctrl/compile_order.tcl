

# -------------------------------------------------------
# 2.0) Add TB Package Files
# -------------------------------------------------------
#    * ModelSim



# -------------------------------------------------------
# 2.1) Add TB Files
# -------------------------------------------------------
#    * ModelSim 
# TODO
# puts -nonewline $simulator_comporder "\
    # ./modules/ok_usb_32b_fifo_ctrl/sim/ok_usb_32b_fifo_ctrl_tb.vhd\n"



# -------------------------------------------------------
# 1.0) Add SRC Package Files
# -------------------------------------------------------
#    * Vivado
#    * ModelSim


# -------------------------------------------------------
# 1.1) Add SRC HDL Files
# -------------------------------------------------------
#    * Vivado
add_src_file lib_src ./modules/ok_usb_32b_fifo_ctrl/hdl/ok_usb_32b_fifo_ctrl.vhd

#    * ModelSim
add_sim_file ./modules/ok_usb_32b_fifo_ctrl/hdl/ok_usb_32b_fifo_ctrl.vhd


