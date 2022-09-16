set this_file_name "[file tail [info script]]"
set relpath_to_module "./[string trimleft [file dirname [info script]] [file normalize ${origin_dir}]]"
puts "TCL: Adding sources of: $relpath_to_module"
set simulator_comporder_path "${origin_dir}/do/modules.tcl"
set simulator_comporder [open ${simulator_comporder_path} "a"]
set vivado_added_hdl_report_path "${origin_dir}/vivado/0_report_added_modules.rpt"
set vivado_added_hdl_report [open $vivado_added_hdl_report_path "a"]
set vivado_added_scripts_report_path "${origin_dir}/vivado/0_report_added_xdc.rpt"
set vivado_added_scripts_report [open $vivado_added_scripts_report_path "a"]

# -------------------------------------------------------
# 1.0) Add SRC Package Files
# -------------------------------------------------------
#    * Vivado
#    * ModelSim


# -------------------------------------------------------
# 1.1) Add SRC HDL Files
# -------------------------------------------------------
#    * Vivado
add_files -fileset "sources_1" -norecurse {\
    ./modules/ok_usb_32b_fifo_ctrl/hdl/ok_usb_32b_fifo_ctrl.vhd\
}
set_property library "lib_src" [get_files {\
    ./modules/ok_usb_32b_fifo_ctrl/hdl/ok_usb_32b_fifo_ctrl.vhd\
}]
puts -nonewline $vivado_added_hdl_report "\
    ./modules/ok_usb_32b_fifo_ctrl/hdl/ok_usb_32b_fifo_ctrl.vhd\n"
update_compile_order -fileset "sources_1"

#    * ModelSim
puts -nonewline $simulator_comporder "\
    ./modules/ok_usb_32b_fifo_ctrl/hdl/ok_usb_32b_fifo_ctrl.vhd\n"


# -------------------------------------------------------
# 2.0) Add TB Package Files
# -------------------------------------------------------
#    * ModelSim



# -------------------------------------------------------
# 2.1) Add TB Files
# -------------------------------------------------------
#    * ModelSim TODO
# puts -nonewline $simulator_comporder "\
    ./modules/ok_usb_32b_fifo_ctrl/sim/ok_usb_32b_fifo_ctrl_tb.vhd\n"



# -------------------------------------------------------
# 3.0) Add XDC/TCL Files
# -------------------------------------------------------
# DO NOT TOUCH
# Search for xdc/tcl foles up to 2 levels of hierarchy
# Search for all .xdc sources associated with this module
set foundFiles [glob -nocomplain -type f \
    ${relpath_to_module}/*{.xdc} \
    ${relpath_to_module}/*/*{.xdc} \
]
if {[llength $foundFiles] > 0} {
    foreach file_path $foundFiles {
        add_files -norecurse -fileset "constrs_1" "$file_path"
        puts -nonewline $vivado_added_scripts_report "$file_path\n"
    }
}

# Search for all .tcl sources associated with this module
set foundFiles [glob -nocomplain -type f \
    ${relpath_to_module}/*{.tcl} \
    ${relpath_to_module}/*/*{.tcl} \
]
if {[llength $foundFiles] > 0} {
    foreach file_path $foundFiles {
        if { [string first $this_file_name $file_path] == -1} {
            source $file_path
            puts -nonewline $vivado_added_scripts_report "$file_path\n"
        }
    }
}


close $simulator_comporder
close $vivado_added_hdl_report
close $vivado_added_scripts_report