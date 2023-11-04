
# 1. Add all signals from the testbench file
if { [string first "_tb." ${file_fullname}] != -1} {
    set dut_name [string map {"_tb" ""} $file_name]
    add wave -divider "TB: ${file_name} ALL signals"
} else {
    set dut_name $file_name
    add wave -divider "TB: ${file_name}_tb ALL signals"
}
puts "TCL: default_wave: dut_name = $dut_name"
puts "TCL: default_wave: file_name = $file_name"


set if_harness_present 0
set slurp_file [open "$proj_root_dir/simulator/modules.tcl" r]
while {-1 != [gets $slurp_file line]} {
    set filepath [string range $line 0 end]
    if { [string first "harness_${file_name}" $filepath] != -1} {
        set if_harness_present 1
    }
    if { [string first "harness_${file_name}_tb" $filepath] != -1} {
        set if_harness_present 1
    }
}
close $slurp_file


# If harness module is used, then look for signals in a separate module "signals_${dut_name}_pack_tb"
if {$if_harness_present == 0} {
    # If harness module is not used
    # add wave sim:/*
    add wave sim:/${file_name}/*
} else {
    # If harness module is used
    add wave sim:/signals_${dut_name}_pack_tb/*
    # add wave sim:/signals_pack_tb/*
}


# 2. Add inputs, outputs, inouts, internal signals from the DUT to wave
set dut_in ""
if {$if_harness_present == 0} {
    set dut_in [find nets -in sim:/${file_name}/DUT/*]
    if {$dut_in eq ""} {
        set dut_in [find nets -in sim:/${file_name}/dut/*]
    }
    if {$dut_in eq ""} {
        set dut_in [find nets -in sim:/${file_name}/inst_dut/*]
    }
    if {$dut_in eq ""} {
        set dut_in [find nets -in sim:/${file_name}/inst_${dut_name}/*]
    }
} else {
    # set dut_in [find nets -in sim:/${file_name}/inst_harness_${file_name}/DUT/*]
    set dut_in [find nets -in sim:/${file_name}/inst_harness_${file_name}/DUT/*]
    if {$dut_in eq ""} {
        set dut_in [find nets -in sim:/${file_name}/inst_harness_${file_name}/dut/*]
    }
    if {$dut_in eq ""} {
        set dut_in [find nets -in sim:/${file_name}/inst_harness_${file_name}/inst_dut/*]
    }
    if {$dut_in eq ""} {
        set dut_in [find nets -in sim:/${file_name}/inst_harness_${file_name}/inst_${dut_name}/*]
    }
}
puts "TCL: dut_in = $dut_in"
if {$dut_in ne ""} {
    add wave -divider "DUT: '${dut_name}' IN ports"
    foreach w $dut_in {
        add wave sim:$w
    }
}


set dut_out ""
if {$if_harness_present == 0} {
    set dut_out [find nets -out sim:/${file_name}/DUT/*]
    if {$dut_out eq ""} {
        set dut_out [find nets -out sim:/${file_name}/dut/*]
    }
    if {$dut_out eq ""} {
        set dut_out [find nets -out sim:/${file_name}/inst_dut/*]
    }
    if {$dut_out eq ""} {
        set dut_out [find nets -out sim:/${file_name}/inst_${dut_name}/*]
    }
} else {
    set dut_out [find nets -out sim:/${file_name}/inst_harness_${file_name}/DUT/*]
    if {$dut_out eq ""} {
        set dut_out [find nets -out sim:/${file_name}/inst_harness_${file_name}/dut/*]
    }
    if {$dut_out eq ""} {
        set dut_out [find nets -out sim:/${file_name}/inst_harness_${file_name}/inst_dut/*]
    }
    if {$dut_out eq ""} {
        set dut_out [find nets -out sim:/${file_name}/inst_harness_${file_name}/inst_${dut_name}/*]
    }
}
puts "TCL: dut_out = $dut_out"
if {$dut_out ne ""} {
    add wave -divider "DUT: '${dut_name}' OUT ports"
    foreach w $dut_out {
        add wave sim:$w
    }
}


set dut_inout ""
if {$if_harness_present == 0} {
    set dut_inout [find nets -inout sim:/${file_name}/DUT/*]
    if {$dut_inout eq ""} {
        set dut_inout [find nets -inout sim:/${file_name}/dut/*]
    }
    if {$dut_inout eq ""} {
        set dut_inout [find nets -inout sim:/${file_name}/inst_dut/*]
    }
    if {$dut_inout eq ""} {
        set dut_inout [find nets -inout sim:/${file_name}/inst_${dut_name}/*]
    }
} else {
    set dut_inout [find nets -inout sim:/${file_name}/inst_harness_${file_name}/DUT/*]
    if {$dut_inout eq ""} {
        set dut_inout [find nets -inout sim:/${file_name}/inst_harness_${file_name}/dut/*]
    }
    if {$dut_inout eq ""} {
        set dut_inout [find nets -inout sim:/${file_name}/inst_harness_${file_name}/inst_dut/*]
    }
    if {$dut_inout eq ""} {
        set dut_inout [find nets -inout sim:/${file_name}/inst_harness_${file_name}/inst_${dut_name}/*]
    }
}
puts "TCL: dut_inout = $dut_inout"
if {$dut_inout ne ""} {
    add wave -divider "DUT: '${dut_name}' INOUT ports"
    foreach w $dut_inout {
        add wave sim:$w
    }
}


set dut_internal ""
if {$if_harness_present == 0} {
    set dut_internal [find signals -internal sim:/${file_name}/DUT/*]
    if {$dut_internal eq ""} {
        set dut_internal [find nets -internal sim:/${file_name}/dut/*]
    }
    if {$dut_internal eq ""} {
        set dut_internal [find nets -internal sim:/${file_name}/inst_dut/*]
    }
    if {$dut_internal eq ""} {
        set dut_internal [find nets -internal sim:/${file_name}/inst_${dut_name}/*]
    }
} else {
    set dut_internal [find signals -internal sim:/${file_name}/inst_harness_${file_name}/DUT/*]
    if {$dut_internal eq ""} {
        set dut_internal [find nets -internal sim:/${file_name}/inst_harness_${file_name}/dut/*]
    }
    if {$dut_internal eq ""} {
        set dut_internal [find nets -internal sim:/${file_name}/inst_harness_${file_name}/inst_dut/*]
    }
    if {$dut_internal eq ""} {
        set dut_internal [find nets -internal sim:/${file_name}/inst_harness_${file_name}/inst_${dut_name}/*]
    }
}
puts "TCL: dut_internal = $dut_internal"
if {$dut_internal ne ""} {
    add wave -divider "DUT: '${dut_name}' INTERNAL signals"
    foreach w $dut_internal {
        add wave sim:$w
    }
}