set this_file_name "[file tail [info script]]"
set relpath_to_module ".[string range [file normalize [file dirname [info script]]] [string length [file normalize ${origin_dir}]] end]"
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
#      USER INPUT
# 1.0) Opal Kelly Frontpanel Package -> sources_1 + default library work (no action)
add_files -fileset "sources_1" -norecurse {\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okCoreHarness.v\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okTriggerOut.v\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okWireIn.v\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okBTPipeOut.v\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okRegisterBridge.v\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okLibrary.vhd\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okWireOut.v\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okPipeOut.v\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okBTPipeIn.v\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okPipeIn.v\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okTriggerIn.v\
}

set_property library "lib_src" [get_files {\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okCoreHarness.v\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okTriggerOut.v\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okWireIn.v\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okBTPipeOut.v\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okRegisterBridge.v\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okLibrary.vhd\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okWireOut.v\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okPipeOut.v\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okBTPipeIn.v\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okPipeIn.v\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okTriggerIn.v\
}]

puts -nonewline $vivado_added_hdl_report "\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okCoreHarness.v\n\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okTriggerOut.v\n\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okWireIn.v\n\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okBTPipeOut.v\n\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okRegisterBridge.v\n\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okLibrary.vhd\n\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okWireOut.v\n\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okPipeOut.v\n\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okBTPipeIn.v\n\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okPipeIn.v\n\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okTriggerIn.v\n"

update_compile_order -fileset "sources_1"

#    * ModelSim
#      USER INPUT
puts -nonewline $simulator_comporder "\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okCoreHarness.v\n\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okTriggerOut.v\n\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okWireIn.v\n\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okBTPipeOut.v\n\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okRegisterBridge.v\n\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okLibrary.vhd\n\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okWireOut.v\n\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okPipeOut.v\n\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okBTPipeIn.v\n\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okPipeIn.v\n\
    ./packages/ok/frontpanel_xem7350_k160t/hdl/okTriggerIn.v\n"


# -------------------------------------------------------
# 1.1) Add SRC HDL Files
# -------------------------------------------------------
#    * Vivado
#      USER INPUT

#    * ModelSim
#      USER INPUT


# -------------------------------------------------------
# 2.0) Add TB Package Files
# -------------------------------------------------------
#    * ModelSim
#      USER INPUT


# -------------------------------------------------------
# 2.1) Add TB Files
# -------------------------------------------------------
#    * ModelSim
#      USER INPUT


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
puts "Adding sources of $relpath_to_module done."