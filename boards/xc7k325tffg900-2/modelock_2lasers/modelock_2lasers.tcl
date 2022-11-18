# CHANGE DESIGN NAME HERE
variable design_name
set design_name [lindex [split [file tail [info script]] "."] 0]
set fpgaPart [get_property PART [current_project]] 

set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
    set origin_dir $::origin_dir_loc
}

set str_bd_folder [file normalize ${origin_dir}/boards/$fpgaPart/$design_name]
set str_bd_filepath ${str_bd_folder}/${design_name}.bd

# Check if remote design exists on disk
if { [file exists $str_bd_filepath ] == 1 } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2030 -severity "ERROR" "The remote BD file path <$str_bd_filepath> already exists!"}
    common::send_gid_msg -ssname BD::TCL -id 2031 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0>."
    common::send_gid_msg -ssname BD::TCL -id 2032 -severity "INFO" "Also make sure there is no design <$design_name> existing in your current project."

    return 1
}

# Check if design exists in memory
set list_existing_designs [get_bd_designs -quiet $design_name]
if { $list_existing_designs ne "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2033 -severity "ERROR" "The design <$design_name> already exists in this project! Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

    common::send_gid_msg -ssname BD::TCL -id 2034 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

    return 1
}

# Check if design exists on disk within project
set list_existing_designs [get_files -quiet */${design_name}.bd]
if { $list_existing_designs ne "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2035 -severity "ERROR" "The design <$design_name> already exists in this project at location:
    $list_existing_designs"}
    catch {common::send_gid_msg -ssname BD::TCL -id 2036 -severity "ERROR" "Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

    common::send_gid_msg -ssname BD::TCL -id 2037 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

    return 1
}

# Now can create the remote BD
# NOTE - usage of <-dir> will create <$str_bd_folder/$design_name/$design_name.bd>
create_bd_design -dir $str_bd_folder $design_name
current_bd_design $design_name


##################################################################
# DESIGN PROCs
##################################################################
# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

    variable script_folder
    variable design_name

    if { $parentCell eq "" } {
        set parentCell [get_bd_cells /]
    }

    # Get object for parentCell
    set parentObj [get_bd_cells $parentCell]
    if { $parentObj == "" } {
        catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
        return
    }

    # Make sure parentObj is hier blk
    set parentType [get_property TYPE $parentObj]
    if { $parentType ne "hier" } {
        catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
        return
    }

    # Save current instance; Restore later
    set oldCurInst [current_bd_instance .]

    # Set parent object as current
    current_bd_instance $parentObj



    # -------------------------------------------------------------
    #  USER INPUT: Paste the core of the exported .tcl board
    # -------------------------------------------------------------
    # Create interface ports

    # Create ports

    # Create instance: clk_wiz_0, and set properties
    set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
    startgroup
    set_property -dict [list CONFIG.PRIM_IN_FREQ.VALUE_SRC USER] [get_bd_cells clk_wiz_0]
    set_property -dict [list CONFIG.PRIM_IN_FREQ {75.960} \
                            CONFIG.CLKOUT2_USED {true} \
                            CONFIG.CLKOUT3_USED {true} \
                            CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {75.96} \
                            CONFIG.CLKOUT1_REQUESTED_DUTY_CYCLE {5.9000} \
                            CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {75.96} \
                            CONFIG.CLKOUT2_REQUESTED_PHASE {180.000} \
                            CONFIG.CLKOUT2_REQUESTED_DUTY_CYCLE {5.9000} \
                            CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {10.08844} \
                            CONFIG.CLKOUT3_REQUESTED_DUTY_CYCLE {50.0} \
                            CONFIG.USE_LOCKED {false} \
                            CONFIG.USE_RESET {false} \
                            CONFIG.CLKIN1_JITTER_PS {131.64000000000001} \
                            CONFIG.MMCM_CLKFBOUT_MULT_F {17.000} \
                            CONFIG.MMCM_CLKIN1_PERIOD {13.165} \
                            CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
                            CONFIG.MMCM_CLKOUT0_DIVIDE_F {17.000} \
                            CONFIG.MMCM_CLKOUT0_DUTY_CYCLE {0.059} \
                            CONFIG.MMCM_CLKOUT1_DIVIDE {17} \
                            CONFIG.MMCM_CLKOUT1_DUTY_CYCLE {0.059} \
                            CONFIG.MMCM_CLKOUT1_PHASE {180.000} \
                            CONFIG.MMCM_CLKOUT2_DIVIDE {128} \
                            CONFIG.MMCM_CLKOUT2_DUTY_CYCLE {0.500} \
                            CONFIG.NUM_OUT_CLKS {3} \
                            CONFIG.CLKOUT1_JITTER {118.951} \
                            CONFIG.CLKOUT1_PHASE_ERROR {104.761} \
                            CONFIG.CLKOUT2_JITTER {118.951} \
                            CONFIG.CLKOUT2_PHASE_ERROR {104.761} \
                            CONFIG.CLKOUT3_JITTER {186.099} \
                            CONFIG.CLKOUT3_PHASE_ERROR {104.761}] [get_bd_cells clk_wiz_0]
    set_property -dict [list CONFIG.CLKOUT1_DRIVES {BUFG} \
                            CONFIG.CLKOUT2_DRIVES {BUFG} \
                            CONFIG.CLKOUT3_DRIVES {BUFG} \
                            CONFIG.FEEDBACK_SOURCE {FDBK_AUTO}] [get_bd_cells clk_wiz_0]
    endgroup

    # Create port connections
    startgroup
    make_bd_pins_external  [get_bd_pins clk_wiz_0/clk_in1]
    make_bd_pins_external  [get_bd_pins clk_wiz_0/clk_out1]
    make_bd_pins_external  [get_bd_pins clk_wiz_0/clk_out2]
    make_bd_pins_external  [get_bd_pins clk_wiz_0/clk_out3]
    endgroup

    # Create instance: clk_wiz_1, and set properties
    set clk_wiz_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_1 ]
    startgroup
    set_property -dict [list CONFIG.PRIM_IN_FREQ.VALUE_SRC USER] [get_bd_cells clk_wiz_1]
    set_property -dict [list CONFIG.PRIM_IN_FREQ {80.000} \
                            CONFIG.CLKOUT2_USED {true} \
                            CONFIG.CLKOUT3_USED {true} \
                            CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {10.000} \
                            CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {80.000} \
                            CONFIG.USE_LOCKED {false} \
                            CONFIG.USE_RESET {false} \
                            CONFIG.CLKIN1_JITTER_PS {125.0} \
                            CONFIG.MMCM_CLKFBOUT_MULT_F {10.000} \
                            CONFIG.MMCM_CLKIN1_PERIOD {12.500} \
                            CONFIG.MMCM_CLKIN2_PERIOD {10.000} \
                            CONFIG.MMCM_CLKOUT0_DIVIDE_F {80.000} \
                            CONFIG.MMCM_CLKOUT1_DIVIDE {10} \
                            CONFIG.MMCM_CLKOUT2_DIVIDE {8} \
                            CONFIG.NUM_OUT_CLKS {3} \
                            CONFIG.CLKOUT1_JITTER {249.573} \
                            CONFIG.CLKOUT1_PHASE_ERROR {117.521} \
                            CONFIG.CLKOUT2_JITTER {164.206} \
                            CONFIG.CLKOUT2_PHASE_ERROR {117.521} \
                            CONFIG.CLKOUT3_JITTER {156.437} \
                            CONFIG.CLKOUT3_PHASE_ERROR {117.521}] [get_bd_cells clk_wiz_1]
    set_property -dict [list CONFIG.CLKOUT1_DRIVES {BUFG} \
                            CONFIG.CLKOUT2_DRIVES {BUFG} \
                            CONFIG.CLKOUT3_DRIVES {BUFG} \
                            CONFIG.FEEDBACK_SOURCE {FDBK_AUTO}] [get_bd_cells clk_wiz_1]
    endgroup

    # Create port connections
    startgroup
    make_bd_pins_external  [get_bd_pins clk_wiz_1/clk_in1]
    make_bd_pins_external  [get_bd_pins clk_wiz_1/clk_out1]
    make_bd_pins_external  [get_bd_pins clk_wiz_1/clk_out2]
    make_bd_pins_external  [get_bd_pins clk_wiz_1/clk_out3]
    endgroup


    # Rename automatically assigned names of external board ports
    startgroup

    # clk_wiz_0 
    # [IMPORTANT: Clock Synthesizers do not allow shifting phases by 180 deg on other output ports than the first one]
    set_property name clk_in1_0_LaserClk            [get_bd_ports clk_in1_0]
    set_property name clk_out1_0_PassThrough_180deg [get_bd_ports clk_out1_0]
    set_property name clk_out2_0_PassThrough_0deg   [get_bd_ports clk_out2_0]
    set_property name clk_out3_0_10MHz              [get_bd_ports clk_out3_0]

    # clk_wiz_1 
    # [IMPORTANT: Clock Synthesizers do not allow shifting phases by 180 deg on other output ports than the first one]
    set_property name clk_in1_1_LaserClk            [get_bd_ports clk_in1_1]
    set_property name clk_out1_1_10MHz              [get_bd_ports clk_out1_1]
    set_property name clk_out2_1_PassThrough_0deg   [get_bd_ports clk_out2_1]
    set_property name clk_out3_1_100MHz             [get_bd_ports clk_out3_1]

    endgroup



    # Create address segments


    # Restore current instance
    current_bd_instance $oldCurInst

    save_bd_design

    # -------------------------------------------------------------
    #  End of copying
    # -------------------------------------------------------------
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################
proc readd_found_file {abs_path_to_file} {
    set file_full_name [file tail $abs_path_to_file]
    puts "TCL: file_full_name = $file_full_name"

        puts "TCL: Sorting source file to fileset \"sources_1\": ${abs_path_to_file}"
        add_files -force -norecurse -fileset [get_filesets "sources_1"] ${abs_path_to_file}

        if { [string first ".vhd" ${file_full_name}] != -1} {
            read_vhdl -library "xil_defaultlib" ${abs_path_to_file}
            # puts "TCL: VHDL HERE '[string first ".vhd" ${file_full_name}]'"
        } elseif { [string first ".sv" ${file_full_name}] != -1} {
            read_verilog -library "xil_defaultlib" -sv ${abs_path_to_file}
        } elseif { [string first ".v" ${file_full_name}] != -1} {
            read_verilog -library "xil_defaultlib" ${abs_path_to_file}
        }

        set_property "library" "xil_defaultlib" [get_files ${abs_path_to_file}]
        set_property "used_in" {simulation synthesis out_of_context} [get_files ${abs_path_to_file}]

}


create_root_design ""

make_wrapper -files [get_files "[file normalize $str_bd_folder/${design_name}/${design_name}.bd]"] -top

set boardWrapperFound [glob $str_bd_folder/${design_name}/hdl/*{_wrapper.}*]
readd_found_file "[file normalize $boardWrapperFound]"

set_property top ${design_name}_wrapper [current_fileset]