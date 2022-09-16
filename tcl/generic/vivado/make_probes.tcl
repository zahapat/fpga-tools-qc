# My issue:
# https://forums.xilinx.com/t5/Vivado-Debug-and-Power/Issue-while-programming-a-bitstream-with-ILA/td-p/874312

# This file implicitly creates an ILA core, finds signals explicitly marked as MARK_DEBUG in HDL files
# and using the Netlist Insertion Debug Probing Flow will probe the activity on these signals
#
# To do:
#   1. Add ILA probes to the declarative part of the .vhd file:
#       - This prevents trimming nets during synthesis
#       - example:
#           attribute MARK_DEBUG : string;
#           attribute MARK_DEBUG of sine : signal is "true";
#           attribute MARK_DEBUG of sineSel : signal is "true";
#
#   2. Run this TCL script which includes set_property MARK_DEBUG after synthesis:
#       set_property MARK_DEBUG true [get_nets -hier [list {sine[*]}]]
#
#   3. 



# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
    set origin_dir $::origin_dir_loc
}


# Set the project name
set _xil_proj_name_ [file tail [file dirname "[file normalize ./Makefile]"]]

# Use project name variable, if specified in the tcl shell
if { [info exists ::user_project_name] } {
    set _xil_proj_name_ $::user_project_name
}

variable script_file
set script_file "[file tail [info script]]"
puts "TCL: Running $script_file for project $_xil_proj_name_."

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/"]"


# Before opening the project, remove all links to board_ila.bd files to avoid errors in case these files are missing
# Use CTRL+SHIFT+L to rename the "ila_default_board_name" in all the tcl script
# DO NOT CHANGE ila_default_board_name "board_ila". Other scripts use "board_ila" it without access to this file.
set ila_default_board_name "board_ila"
set boards_dir "${orig_proj_dir}/boards"
puts "TCL: Removing all links to the board design ${ila_default_board_name}.bd in the .xpr file and deleting all files in the board folder for its re/creation."
file delete -force "${orig_proj_dir}/boards/$ila_default_board_name"
set del_lines_start 0
set del_lines_end 0
set cnt 0
set slurp_file [open "${origin_dir}/vivado/$_xil_proj_name_.xpr" r]
set concat_lines ""
set new_line ""
while {-1 != [gets $slurp_file line]} {
    incr cnt 
    if {$del_lines_start == 0} {
        # Detect start where the .bd is included in the .xpr file and skip these lines
        if {[regexp -all {board_ila.bd"} $line] == 1} {
            set del_lines_start $cnt
        } else {
            # Pass valid lines
            set new_line [string range $line 0 end]
            set explicit_line "*$new_line"
            set concat_lines [concat $concat_lines $explicit_line]
        }
    } else {
        # Detect end to enable passing valid lines
        if {[regexp -all {</File>} $line] == 1} {
            set del_lines_end $cnt
            incr del_lines_end
            puts "TCL: Removing $ila_default_board_name.bd file from the project $_xil_proj_name_.xpr file detected on lines $del_lines_start-$del_lines_end"
            set del_lines_start 0
        }
    }
}
close $slurp_file

# Replace the old .xpr with the new lines
set out_file_path "${origin_dir}/vivado/$_xil_proj_name_.xpr"
set xpr_file [open $out_file_path "w"]
set line_part [lindex [split $concat_lines "*"] ]
foreach l $line_part {
    set ln [string range $l 0 end]
    if {$ln != ""} {
        puts -nonewline $xpr_file "$ln\n"
    }
}
close $xpr_file


# Open the project
# close_project -quiet
open_project "${origin_dir}/vivado/${_xil_proj_name_}.xpr"
set_property source_mgmt_mode All [current_project]

# Ask for current board. If ZYNQ is detected, it affects the entire procedure
set zynq_design 0
set board_part [get_property PART [current_project]]
puts "TCL: Current PART = $board_part"
if {[regexp -all {xc7z} $board_part] == 1} {
    puts "TCL: Target device is ZYNQ -> create wrapper_ila -> make board_ila design for ILA."
    set zynq_design 1

    # Update compile order to set it as a new TOP module
    update_compile_order -fileset sources_1
}

# ------------------
# - Add ILA probes -
# ------------------
# 1. Add ILA probes in the declarative part of the HDL file. Example for the .vhd file:
#    attribute MARK_DEBUG : string;
#    attribute MARK_DEBUG of sine : signal is "true";
#    attribute MARK_DEBUG of sineSel : signal is "true";
# puts "TCL: INFO: ILA probes must be inserted/instantiated in the declarative part of HDL sources."
# puts "TCL: INFO: Otherwise, some signals for probing can be trimmed by synthesis."
# puts "TCL: INFO: Example: (replace ' by double quotes)"
# puts "TCL: INFO: ----- ILA_PROBES_BEGIN -----"
# puts "TCL: INFO: attribute MARK_DEBUG : string;"
# puts "TCL: INFO: attribute MARK_DEBUG of sine : signal is 'true';"
# puts "TCL: INFO: attribute MARK_DEBUG of sineSel : signal is 'true';"
# puts "TCL: INFO: ----- ILA_PROBES_END -----"


# ----- MAKE BOARD -----
# https://extgit.iaik.tugraz.at/sip2020/zybo_z7_base_design/-/blob/master/HW/bd.tcl
# Make a simple Block Design with PS7 (ZYNQ Processing System) which allows to activate the differential clock for ILA

# 1. Create a new Block Design (.bd file) with given name, delete previous if exists
if {$zynq_design == 1} {
    # Check if "0_report_added_modules.rpt" exists and find TOP file path in the end of the list
    if { [file exist "${origin_dir}/vivado/0_report_added_modules.rpt"] == false} {
        puts "TCL: ERROR: File not found: ${origin_dir}/vivado/0_report_added_modules.rpt"
        return 5
    }
    puts "TCL: Looking for dir of the TOP module. It is always at the bottom of the '0_report_added_modules.rpt'"
    set slurp_file [open "${origin_dir}/vivado/0_report_added_modules.rpt" r]
    while {-1 != [gets $slurp_file line]} {
        set top_file_path $line
    }
    puts "TCL: Top file directory = $top_file_path"

    # Find the top file name.suffix
    set top_file_i [string range [lindex [split $top_file_path "/"] 0] 0 end]
    set cnt 0
    while {$top_file_i ne ""} {
        set top_file_i [string range [lindex [split $top_file_path "/"] $cnt] 0 end]
        set top_file $top_file_i
        puts "TCL: $top_file"
        incr cnt
        set top_file_i [string range [lindex [split $top_file_path "/"] $cnt] 0 end]
    }
    puts "TCL: TOP file name.suffix = $top_file"

    # Check correct top module for wrapping
    set wrapped_module_name [get_property TOP [current_fileset]]
    if {[regexp -all "$wrapped_module_name" $top_file] == 1} {
        puts "TCL: OK, top file is set correctly. Continue"

        # Create wrapper for current TOP module and add it to the project
        source ${orig_proj_dir}/tcl/generic/vivado/create_wrapper_ila.tcl

        add_files -norecurse -fileset sources_1 "${origin_dir}/helpers/wrapper_ila.vhd"
    } else {
        puts "TCL: TOP file is not set correctly. Should be $top_file, is $wrapped_module_name. Break all."
        return 1
    }

    # Generate script to generate board for ILA and automatically interconnect all probes
    if {[get_files -quiet ${ila_default_board_name}.bd] eq ""} {
        puts "TCL: Board file '${ila_default_board_name}.bd' is not included or has been removed from the project as expected. ILA probes can be (re)created."
        source ${orig_proj_dir}/tcl/generic/vivado/${ila_default_board_name}_gen_bd.tcl
        source ${orig_proj_dir}/helpers/$ila_default_board_name.tcl
    } else {
        puts "TCL: Recreation of the ILA probes is not possible. Board file '${ila_default_board_name}.bd' is already included in the design. "
        return 1
    }
    puts "TCL: boards_dir = $boards_dir"
    update_compile_order -fileset sources_1

    # Default name of the "wrapper_ila.vhd" instance in the "board_ila.bd" block board design, refresh
    set inst_name_wrapper_ila "board_ila_wrapper_ila_0_0"
    update_module_reference $inst_name_wrapper_ila
    puts "TCL: update_module_reference $inst_name_wrapper_ila"


    # Make wrapper after refreshing changes of the module, make it top, update compile order
    # set_property TOP $ila_default_board_name [current_fileset]
    # set_property source_mgmt_mode None [current_project]
    make_wrapper -fileset sources_1 -files [get_files "$boards_dir/$ila_default_board_name/$ila_default_board_name.bd"] -top
    puts "TCL: Making wrapper: $boards_dir/$ila_default_board_name/$ila_default_board_name.bd"

    # Return to automatic top level selection after this script, but this time it is important to leave it manual
    # since vivado automatically selects invalid top file
    add_files -norecurse -fileset sources_1 "$boards_dir/$ila_default_board_name/hdl/board_ila_wrapper.vhd"
    update_compile_order -fileset sources_1
    set_property source_mgmt_mode None [current_project]
    puts "TCL: Automatic compile order DISABLED."
    set_property TOP "board_ila_wrapper" [current_fileset]
    puts "TCL: MANUALLY SET TOP FILE: board_ila_wrapper"
}


# ----- RUN ALL: SYNTHESIS -> IMPL -> BIT -----
# Set the directory path for the current project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [current_project]

# Set the file graph
puts "TCL: Update and report compile order "
# update_compile_order
report_compile_order -file "${origin_dir}/vivado/0_report_compile_order.rpt"

# Set Strategy for Implementation
set_property strategy Flow_PerfOptimized_high [get_runs synth_1]

# Get verbose reports about IP status
report_property [get_runs synth_1] -file "${origin_dir}/vivado/1_report_property.rpt"
# set_property STEPS.SYNTH_DESIGN.ARGS.BUFG 0 [get_runs synth_1] # Example

# Set Strategy for Implementation
set_property strategy Flow_PerfOptimized_high [get_runs synth_1]

# Execute Synthesis if out of date
puts "TCL: Run Synthesis. "
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1
open_run synth_1
write_checkpoint        -force "${origin_dir}/vivado/1_checkpoint_post_synth.dcp"
report_timing_summary   -file "${origin_dir}/vivado/1_results_post_synth_timing.rpt"
report_utilization      -file "${origin_dir}/vivado/1_results_post_synth_util.rpt"
report_drc              -file "${origin_dir}/vivado/1_results_post_synth_drc.rpt"

if {$zynq_design == 0} {
    # ----------------------- ILA (for pure FPGA platform) -------------------------
    # 2. Create a new ILA debug core Black Box, set its properties 
    #    and automatically create a port for clocking the ILA
    set ila_blkbox_name "ila_0"
    puts "TCL: Creating ILA debug core '$ila_blkbox_name'"
    create_debug_core "$ila_blkbox_name" ila

    # 2.1 Maximum number of data samples to be stored by ILA (can affect performance)
    #     Possible values: (Default = 1024), 2048, 4096, 8192, 16384, 32768, 65536, 131072
    set samples_cnt 1024
    set_property C_DATA_DEPTH "$samples_cnt" [get_debug_cores $ila_blkbox_name]

    # 2.2 C_TRIGIN_EN enables the TRIG_IN and TRIG_IN_ACK ports of the ILA core (Default = false).
    #     Note that you need to use the advanced netlist change commands to connect these ports
    #     to nets in your design. If you wish to use the ILA trigger input or output signals, 
    #     you should consider using the HDL instantiation method of adding ILA cores to your design.
    #     Use HDL commands to use this feature.
    set_property C_TRIGIN_EN "false" [get_debug_cores $ila_blkbox_name]

    # 2.3 C_TRIGOUT_EN enables the TRIG_OUT and TRIG_OUT_ACK ports of the ILA core (Default = false).
    #     Note that you need to use the advanced netlist change commands to connect these ports
    #     to nets in your design. If you wish to use the ILA trigger input or output signals, 
    #     you should consider using the HDL instantiation method of adding ILA cores to your design.
    #     Use HDL commands to use this feature.
    set_property C_TRIGOUT_EN "false" [get_debug_cores $ila_blkbox_name]

    # 2.4 Add extra levels of pipe stages (for example, flip-flop registers) on the PROBE inputs 
    #     of the ILA core. 
    #     This feature can be used to IMPROVE TIMING performance of your design by allowing the
    #     Vivado tools to place the ILA core away from critical sections of the design.
    #     Possible values: (Default = 0), 1, 2, 3, 4, 5, 6
    set pipeline_stages_cnt 0
    set_property C_INPUT_PIPE_STAGES "$pipeline_stages_cnt" [get_debug_cores $ila_blkbox_name]

    # 2.5 C_ADV_TRIGGER enables the advanced trigger mode of the ILA core. (Default = false)
    #     Use HDL commands to use this feature.
    set_property C_ADV_TRIGGER "false" [get_debug_cores $ila_blkbox_name]

    # 2.6 C_EN_STRG_QUAL enables the basic capture control mode of the ILA core. (Default = false)
    set_property C_EN_STRG_QUAL "true" [get_debug_cores $ila_blkbox_name]

    # 2.7 Number of comparators (or match units) per PROBE input of the ILA core. 
    #     The number ALL_PROBE_SAME_MU_CNT required depends on the settings of the 
    #     following C_ADV_TRIGGER and C_EN_STRG_QUAL properties:
    #       - If C_ADV_TRIGGER = "false";   C_EN_STRG_QUAL = "false",   => set to 2
    #       - If C_ADV_TRIGGER = "false";   C_EN_STRG_QUAL = "true"     => set to 2
    #       - If C_ADV_TRIGGER = "true";    C_EN_STRG_QUAL = "false"    => set to 1 - 4 (4=recommended)
    #       - If C_ADV_TRIGGER = "true";    C_EN_STRG_QUAL = "true"     => set to 2 - 4 (4=recommended)
    #     IMPORTANT: if you do not follow the rules above,
    #     you will encounter an error during implementation
    #     when the ILA core is generated.
    set_property ALL_PROBE_SAME_MU_CNT "2" [get_debug_cores $ila_blkbox_name]

    #set_property TRIGGER_COMPARE_VALUE "true" [get_debug_cores $ila_blkbox_name]

    # 2.8 Set C_USER_SCAN_CHAIN for hw_server (Default = 1)
    #     The C_USER_SCAN_CHAIN property of the debug hub instance dbg_hub is set to 2. Recommend is 1 or 3. 
    #     Setting it to 2 or 4 will cause the debug cores to not be detected by the hw_server at runtime.
    #     Resolution: Change the debug hub C_USER_SCAN_CHAIN property to 1 or 3 (recommended).  
    #     Alternatively, you can relaunch the hw_server to scan user scan chains 2 or 4.  
    #     For instance, to scan for user scan chain 2 run hw_server as follows: 
    #         hw_server -e "set xsdb_user_bscan 2"
    set scan_chain_num 1
    puts "TCL: set C_USER_SCAN_CHAIN = $scan_chain_num"
    set_property C_USER_SCAN_CHAIN $scan_chain_num [get_debug_cores dbg_hub]


    # 3. List ALL the nets with property MARK_DEBUG "true".
    set ila_debug_nets [get_nets -hier -filter {MARK_DEBUG==1}]
    set ila_debug_nets_cnt [llength [get_nets [list $ila_debug_nets]]]
    puts "TCL: ila_debug_nets: $ila_debug_nets"
    puts "TCL: ila_debug_nets_cnt: $ila_debug_nets_cnt"
    if {$ila_debig_nets eq ""} {
        puts "TCL: ERROR: ila_debug_nets = $ila_debug_nets -> Signals to be probed by ILA must be inserted/instantiated in the declarative part of the respective HDL sources!"
        puts "TCL: INFO: Otherwise, some signals for probing can be trimmed by synthesis."
        puts "TCL: INFO: Example: (replace all single quotes (') by double quotes!)"
        puts "TCL: INFO: ----- ILA_PROBES_BEGIN -----"
        puts "TCL: INFO: attribute MARK_DEBUG : string;"
        puts "TCL: INFO: attribute MARK_DEBUG of signal_name1 : signal is 'true';"
        puts "TCL: INFO: attribute MARK_DEBUG of signal_name2 : signal is 'true';"
        puts "TCL: INFO: ----- ILA_PROBES_END -----"
        return 1
    }
}

# 4. Set the width of the clk port of the ILA core to 1, connect it to the desired clock net (here sys_clk)
    #    IMPORTANT: All debug port NAMES of the debug cores MUST BE LOWER CASE.
    #    IMPORTANT: For the name of clock signals use the name out of the setup debug wizzard (not from report_clocks)
    #       open synthesized design
    #       connect_debug_port dbg_hub/clk [get_nets [list <name of free running clock>]]
    #       connect_debug_port u_ila_0/clk [get_nets [list <name of free running clock>]]
    #       connect_debug_port u_ila_1/clk [get_nets [list <name of non-free running clock>]]
    #       delete flow generated connect-commands out of the xdc file, save xdc file, force desin up to date. and build it.
    # INFO: [Opt 31-194] Inserted BUFG sys_clk_BUFG_inst_1 to drive 1281 load(s) on clock net sys_clk_BUFG_1
set ila_clock_port_name "clk"
if {$zynq_design == 1} {
    # Use generated clock from PS7
    puts "TCL: INFO: ILA must be instantiated from the board file 'board_ila.bd' to make it work -> Check file 'board_ila.tcl' if ila_0 has been instantiated there and all ports connected."
} else {
    # Use oscillator clock on FPGA board
    set system_clock_name "sys_clk"
    set found_debug_hub_clk [get_nets [list $system_clock_name ]]
    if {$found_debug_hub_clk eq ""} {
        puts "TCL: ERROR: Net $system_clock_name NOT FOUND (found_debug_hub_clk = $found_debug_hub_clk). Debug_hub clk port can not be assigned to this net."
        return 1
    } else {
        puts "TCL: Looking for net $system_clock_name; Found found_debug_hub_clk = $found_debug_hub_clk"
    }
    connect_debug_port dbg_hub/$ila_clock_port_name [get_nets [list $system_clock_name ]]
    set_property port_width 1 [get_debug_ports $ila_blkbox_name/$ila_clock_port_name]
    connect_debug_port $ila_blkbox_name/$ila_clock_port_name [get_nets [list $system_clock_name ]]

    # 5. Set the width of the probe0 ILA port to the number of nets you plan to connect to the port
    #    and attach ALL the MARK_DEBUG nets to the probe0.
    # create_debug_port $ila_clock_port_name probe
    set_property port_width $ila_debug_nets_cnt [get_debug_ports $ila_blkbox_name/probe0]
    connect_debug_port $ila_blkbox_name/probe0 [lsort -dictionary [get_nets [list $ila_debug_nets ]]]

    # Connect "system_clock_name" to the ILA port "ila_clock_port_name"
    # get_nets [list $ila_debug_nets]
    # connect_debug_port $ila_blkbox_name/$ila_clock_port_name [get_nets [list $system_clock_name ]]

    # 5.1 Optionally, create more probe ports under the current ILA Black Box,
    #     set their width, and connect them to the nets you want to debug.
    # create_debug_port $ila_blkbox_name probe
    # set_property port_width 2 [get_debug_ports $ila_blkbox_name/probe1]
    # connect_debug_port $ila_blkbox_name/probe1 [get_nets [list {signal_a[0]} {signal_b[1]}]]

    # 6.0 Save design: Prerequisite for implement_debug_core
    # save_design

    # 6. Optionally, generate and synthesize the debug cores so you can floorplan them with the 
    # rest of your synthesized design.
    # implement_debug_core [get_debug_cores]


    # 7. Set Up ILA Core Trigger Position and Probe Compare Values
    # set_property CONTROL.TRIGGER_POSITION 512 [get_hw_ilas $ila_blkbox_name]
    # set_property COMPARE_VALUE.0 eq4'b0000 [get_hw_probes counter]
    # ----------------------- /ILA -------------------------
}

# Get verbose reports about IP status and config affecting timing analysis
puts "TCL: Get verbose reports about what may affect timing analysis "
report_config_timing -all -file "${origin_dir}/vivado/1_report_config_timing.rpt"

# Write netlist
write_edif -force "${origin_dir}/vivado/1_netlist_post_synth.edf"


# Run Implementation + Generate Bitstream if out-of-date
puts "TCL: Run Implementation and Generate Bitstream. "
launch_runs impl_1 -to_step route_design -jobs 4
wait_on_run impl_1
open_run impl_1
write_checkpoint            -force "${origin_dir}/vivado/2_checkpoint_post_route.dcp"
write_debug_probes          -force "${origin_dir}/vivado/2_ila_$_xil_proj_name_.ltx"
report_route_status         -verbose -file "${origin_dir}/vivado/2_results_post_route_route_status.rpt"
report_timing_summary       -file "${origin_dir}/vivado/2_results_post_route_timing.rpt"
report_utilization          -file "${origin_dir}/vivado/2_results_post_route_util.rpt"
report_drc                  -file "${origin_dir}/vivado/2_results_post_route_drc.rpt"

# Run Generate Bitstream
if {[string equal [get_files -quiet constrs_1] ""]} {
    puts "TCL: ERROR: Unable to run bitstream. There are no constrain files present in the project."
} else {
    # Run Generate Bitstream, Export Hardware Definition, IF ZYNQ has been detected
    open_run impl_1
    set_property BITSTREAM.GENERAL.COMPRESS FALSE [current_design]
    write_bitstream -verbose    -force "${origin_dir}/vivado/3_bitstream_$_xil_proj_name_.bit"
}

if {$zynq_design == 1} {
    # Export hw to Vitis
    write_hwdef  -force "${origin_dir}/vivado/3_hwdef_$_xil_proj_name_.hwdef"
    # write_sysdef -force -hwdef "${origin_dir}/vivado/3_hwdef_$_xil_proj_name_.hwdef" -bitfile "${origin_dir}/vivado/3_bitstream_$_xil_proj_name_.bit" -file "${origin_dir}/vivado/3_sysdef_$_xil_proj_name_.sysdef"
}

# C_USER_SCAN_CHAIN
set chain [get_property C_USER_SCAN_CHAIN [get_debug_cores dbg_hub]]
puts "TCL: C_USER_SCAN_CHAIN = $chain"


# Set back automatic compile order
set_property source_mgmt_mode All [current_project]


# Close project, print success
puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "
close_project