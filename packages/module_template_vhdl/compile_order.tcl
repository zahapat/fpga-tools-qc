set this_file_name "[file tail [info script]]"
set relpath_to_module ".[string range [file normalize [file dirname [info script]]] [string length [file normalize ${origin_dir}]] end]"
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
#      USER INPUT
add_files -fileset "sources_1" -norecurse {\
    ./modules/srcname/hdl/pack/const_srcname_pack.vhd\
    ./modules/srcname/hdl/pack/types_srcname_pack.vhd\
    ./modules/srcname/hdl/pack/signals_srcname_pack.vhd\
}
set_property library "lib_src" [get_files {\
    ./modules/srcname/hdl/pack/const_srcname_pack.vhd\
    ./modules/srcname/hdl/pack/types_srcname_pack.vhd\
    ./modules/srcname/hdl/pack/signals_srcname_pack.vhd\
}]
puts -nonewline $vivado_added_hdl_report "\
    ./packages/proj_specific_src/const_pack.vhd\n\
    ./packages/proj_specific_src/types_pack.vhd\n\
    ./packages/proj_specific_src/signals_pack.vhd\n"

update_compile_order -fileset "sources_1"

#    * ModelSim
#      USER INPUT
puts -nonewline $simulator_comporder "\
    ./modules/srcname/hdl/pack/const_srcname_pack.vhd\n\
    ./modules/srcname/hdl/pack/types_srcname_pack.vhd\n\
    ./modules/srcname/hdl/pack/signals_srcname_pack.vhd\n"


# -------------------------------------------------------
# 1.1) Add SRC HDL Files
# -------------------------------------------------------
#    * Vivado
#      USER INPUT
add_files -fileset "sources_1" -norecurse {\
    ./modules/srcname/hdl/srcname.vhd\
}
set_property library "lib_src" [get_files {\
    ./modules/srcname/hdl/srcname.vhd\
}]
update_compile_order -fileset "sources_1"

#    * ModelSim
#      USER INPUT
puts -nonewline $simulator_comporder "\
    ./modules/srcname/hdl/srcname.vhd\n"


# -------------------------------------------------------
# 2.0) Add TB Package Files
# -------------------------------------------------------
#    * ModelSim
#      USER INPUT
puts -nonewline $simulator_comporder "\
    ./modules/srcname/sim/pack/const_srcname_pack_tb.vhd\n\
    ./modules/srcname/sim/pack/types_srcname_pack_tb.vhd\n\
    ./modules/srcname/sim/pack/signals_srcname_pack_tb.vhd\n\
    ./modules/srcname/sim/pack/triggers_srcname_pack_tb.vhd\n"


# -------------------------------------------------------
# 2.1) Add TB Files
# -------------------------------------------------------
#    * ModelSim
#      USER INPUT
puts -nonewline $simulator_comporder "\
    ./modules/srcname/sim/harness_srcname_tb.vhd\n\
    ./modules/srcname/sim/executors_srcname_tb.vhd\n\
    ./modules/srcname/sim/monitors_srcname_tb.vhd\n\
    ./modules/srcname/sim/checkers_srcname_tb.vhd\n\
    ./modules/srcname/sim/srcname_tb.vhd\n"


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