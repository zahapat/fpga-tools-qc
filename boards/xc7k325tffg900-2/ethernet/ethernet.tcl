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
    # ---- OLD ----
    # startgroup
    # create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0
    # apply_board_connection -board_interface "sys_diff_clock" -ip_intf "clk_wiz_0/CLK_IN1_D" -diagram "ethernet"
    # endgroup

    # startgroup
    # create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:11.0 microblaze_0
    # endgroup

    # apply_bd_automation -rule xilinx.com:bd_rule:microblaze -config { axi_intc {1} axi_periph {Enabled} cache {8KB} clk {/clk_wiz_0/clk_out1 (100 MHz)} cores {1} debug_module {Debug Only} ecc {Basic} local_mem {32KB} preset {Real-time}}  [get_bd_cells microblaze_0]
    # set_property name CLK_IN1_D_0 [get_bd_intf_ports sys_diff_clock]

    # startgroup
    # apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( Reset ) } Manual_Source {Auto}}  [get_bd_pins clk_wiz_0/reset]
    # apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_out1 (100 MHz)} Clk_slave {/clk_wiz_0/clk_out1 (100 MHz)} Clk_xbar {/clk_wiz_0/clk_out1 (100 MHz)} Master {/microblaze_0/M_AXI_DC} Slave {/microblaze_0_axi_intc/s_axi} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins microblaze_0/M_AXI_DC]
    # apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_out1 (100 MHz)} Clk_slave {/clk_wiz_0/clk_out1 (100 MHz)} Clk_xbar {/clk_wiz_0/clk_out1 (100 MHz)} Master {/microblaze_0/M_AXI_IC} Slave {/microblaze_0_axi_intc/s_axi} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins microblaze_0/M_AXI_IC]
    # apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( Reset ) } Manual_Source {Auto}}  [get_bd_pins rst_clk_wiz_0_100M/ext_reset_in]
    # endgroup

    # startgroup
    # create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.2 axi_ethernet_0
    # apply_board_connection -board_interface "eth_rgmii" -ip_intf "axi_ethernet_0/rgmii" -diagram "ethernet"
    # apply_board_connection -board_interface "eth_mdio_mdc" -ip_intf "axi_ethernet_0/mdio" -diagram "ethernet"
    # apply_board_connection -board_interface "phy_reset_out" -ip_intf "axi_ethernet_0/phy_rst_n" -diagram "ethernet"
    # endgroup


    # apply_bd_automation -rule xilinx.com:bd_rule:axi_ethernet -config { FIFO_DMA {DMA} PHY_TYPE {RGMII}}  [get_bd_cells axi_ethernet_0]
    # startgroup
    # apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/clk_wiz_0/clk_out1 (100 MHz)} Freq {100} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins axi_ethernet_0/axis_clk]
    # apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_out1 (100 MHz)} Clk_slave {Auto} Clk_xbar {/clk_wiz_0/clk_out1 (100 MHz)} Master {/microblaze_0 (Periph)} Slave {/axi_ethernet_0/s_axi} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_ethernet_0/s_axi]
    # apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_out1 (100 MHz)} Clk_slave {Auto} Clk_xbar {/clk_wiz_0/clk_out1 (100 MHz)} Master {/microblaze_0 (Periph)} Slave {/axi_ethernet_0_dma/S_AXI_LITE} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_ethernet_0_dma/S_AXI_LITE]
    # endgroup

    # connect_bd_net [get_bd_pins axi_ethernet_0_dma/m_axi_sg_aclk] [get_bd_pins clk_wiz_0/clk_out1]

    # connect_bd_net [get_bd_pins axi_ethernet_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In0]

    # startgroup
    # create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0
    # apply_board_connection -board_interface "usb_uart" -ip_intf "axi_uartlite_0/UART" -diagram "ethernet"
    # endgroup

    # apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_out1 (100 MHz)} Clk_slave {Auto} Clk_xbar {/clk_wiz_0/clk_out1 (100 MHz)} Master {/microblaze_0 (Periph)} Slave {/axi_uartlite_0/S_AXI} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_uartlite_0/S_AXI]

    # connect_bd_net [get_bd_pins axi_uartlite_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In1]

    # startgroup
    # create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 axi_timer_0
    # endgroup

    # startgroup
    # set_property -dict [list CONFIG.NUM_PORTS {3}] [get_bd_cells microblaze_0_xlconcat]
    # endgroup

    # connect_bd_net [get_bd_pins axi_timer_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In2]

    # apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_out1 (100 MHz)} Clk_slave {Auto} Clk_xbar {/clk_wiz_0/clk_out1 (100 MHz)} Master {/microblaze_0 (Periph)} Slave {/axi_timer_0/S_AXI} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_timer_0/S_AXI]


    # delete_bd_objs [get_bd_nets reset_inv_0_Res]
    # delete_bd_objs [get_bd_nets reset_1] [get_bd_cells reset_inv_0]
    # delete_bd_objs [get_bd_ports reset]

    # startgroup
    # set_property -dict [list CONFIG.USE_RESET {false}] [get_bd_cells clk_wiz_0]
    # endgroup


    # ---- NEW ----
    # https://digilent.com/reference/programmable-logic/genesys-2/microblaze-servers
    # Add the DDR3 SDRAM. Vivado will automatically connect the DDR3 SDRAM and system clock to the MIG IP.
    # puts "TCL: mig_7series_0"
    # startgroup
    # create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series:4.2 mig_7series_0
    # apply_board_connection -board_interface "ddr3_sdram" -ip_intf "mig_7series_0/mig_ddr_interface" -diagram "ethernet"
    # endgroup

    # # Run Connection Automation. The Select Board Part Interface = reset (Reset). Vivado will connect your system reset to sys_rst on the MIG.
    # apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( Reset ) } Manual_Source {New External Port (ACTIVE_LOW)}}  [get_bd_pins mig_7series_0/sys_rst]



    # # Add MicroBlaze IP.
    # puts "TCL: microblaze_0"
    # startgroup
    # create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:11.0 microblaze_0
    # endgroup

    # # Run Block Automation: Preset = None, Local Memory = 64KB, Local ECC = None, Cache Configuration: 32KB, Debug Module = Debug Only, Peripheral AXI Port = Enabled, Interrupt Controller = ENABLED, Clock Connection = ui_clk 225 MHz
    # apply_bd_automation -rule xilinx.com:bd_rule:microblaze -config { axi_intc {1} axi_periph {Enabled} cache {32KB} clk {/mig_7series_0/ui_clk (225 MHz)} cores {1} debug_module {Debug Only} ecc {None} local_mem {64KB} preset {None}}  [get_bd_cells microblaze_0]
    
    
    
    # # Do not run Connection Automation yet! Add the required Peripheral Components now.
    # # Add USB UART
    # puts "TCL: axi_uartlite_0"
    # startgroup
    # create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0
    # apply_board_connection -board_interface "usb_uart" -ip_intf "axi_uartlite_0/UART" -diagram "ethernet"
    # endgroup

    # # Add Ethernet PHY
    # puts "TCL: axi_ethernet_0"
    # startgroup
    # create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.2 axi_ethernet_0
    # apply_board_connection -board_interface "eth_rgmii" -ip_intf "axi_ethernet_0/rgmii" -diagram "ethernet"
    # apply_board_connection -board_interface "eth_mdio_mdc" -ip_intf "axi_ethernet_0/mdio" -diagram "ethernet" 
    # apply_board_connection -board_interface "phy_reset_out" -ip_intf "axi_ethernet_0/phy_rst_n" -diagram "ethernet" 
    # endgroup

    # # Add AXI Timer
    # startgroup
    # create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 axi_timer_0
    # endgroup



    # # Run Block Automation: Physical Interface Selection = RGMII, Connect AXI Streaming Interfaces to = DMA (This creates the DMA IP block)
    # apply_bd_automation -rule xilinx.com:bd_rule:axi_ethernet -config { FIFO_DMA {DMA} PHY_TYPE {RGMII}}  [get_bd_cells axi_ethernet_0]



    # # Connect unconnected pin clk_in1 of the "axi_ethernet_0_refclk" and connect it to the ui_clk output on the mig_7series_0 block.
    # connect_bd_net [get_bd_pins axi_ethernet_0_refclk/clk_in1] [get_bd_pins mig_7series_0/ui_clk]



    # # Run Connection Automation: Tick All Automation
    # startgroup
    # apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/axi_ethernet_0_refclk/clk_out1 (200 MHz)} Freq {100} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins axi_ethernet_0/axis_clk]
    # apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/mig_7series_0/ui_clk (225 MHz)} Clk_slave {Auto} Clk_xbar {/mig_7series_0/ui_clk (225 MHz)} Master {/microblaze_0 (Periph)} Slave {/axi_ethernet_0/s_axi} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_ethernet_0/s_axi]
    # apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/mig_7series_0/ui_clk (225 MHz)} Clk_slave {Auto} Clk_xbar {/mig_7series_0/ui_clk (225 MHz)} Master {/microblaze_0 (Periph)} Slave {/axi_ethernet_0_dma/S_AXI_LITE} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_ethernet_0_dma/S_AXI_LITE]
    # apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/mig_7series_0/ui_clk (225 MHz)} Clk_slave {Auto} Clk_xbar {/mig_7series_0/ui_clk (225 MHz)} Master {/microblaze_0 (Periph)} Slave {/axi_timer_0/S_AXI} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_timer_0/S_AXI]
    # apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/mig_7series_0/ui_clk (225 MHz)} Clk_slave {Auto} Clk_xbar {/mig_7series_0/ui_clk (225 MHz)} Master {/microblaze_0 (Periph)} Slave {/axi_uartlite_0/S_AXI} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_uartlite_0/S_AXI]
    # apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/mig_7series_0/ui_clk (225 MHz)} Clk_slave {/mig_7series_0/ui_clk (225 MHz)} Clk_xbar {/mig_7series_0/ui_clk (225 MHz)} Master {/microblaze_0/M_AXI_DC} Slave {/microblaze_0_axi_intc/s_axi} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins microblaze_0/M_AXI_DC]
    # apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/mig_7series_0/ui_clk (225 MHz)} Clk_slave {/mig_7series_0/ui_clk (225 MHz)} Clk_xbar {/mig_7series_0/ui_clk (225 MHz)} Master {/microblaze_0/M_AXI_IC} Slave {/microblaze_0_axi_intc/s_axi} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins microblaze_0/M_AXI_IC]
    # apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/mig_7series_0/ui_clk (225 MHz)} Clk_slave {/mig_7series_0/ui_clk (225 MHz)} Clk_xbar {/mig_7series_0/ui_clk (225 MHz)} Master {/microblaze_0 (Cached)} Slave {/mig_7series_0/S_AXI} ddr_seg {Auto} intc_ip {New AXI SmartConnect} master_apm {0}}  [get_bd_intf_pins mig_7series_0/S_AXI]
    # endgroup

    # # Run Connection Automation: Tick All Automation
    # startgroup
    # apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/axi_ethernet_0_refclk/clk_out1 (200 MHz)} Clk_slave {/mig_7series_0/ui_clk (225 MHz)} Clk_xbar {/mig_7series_0/ui_clk (225 MHz)} Master {/axi_ethernet_0_dma/M_AXI_MM2S} Slave {/mig_7series_0/S_AXI} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_ethernet_0_dma/M_AXI_MM2S]
    # apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/axi_ethernet_0_refclk/clk_out1 (200 MHz)} Clk_slave {/mig_7series_0/ui_clk (225 MHz)} Clk_xbar {/mig_7series_0/ui_clk (225 MHz)} Master {/axi_ethernet_0_dma/M_AXI_S2MM} Slave {/mig_7series_0/S_AXI} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_ethernet_0_dma/M_AXI_S2MM]
    # validate_bd_designapply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {/mig_7series_0/ui_clk (225 MHz)} Clk_xbar {/mig_7series_0/ui_clk (225 MHz)} Master {/axi_ethernet_0_dma/M_AXI_SG} Slave {/mig_7series_0/S_AXI} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_ethernet_0_dma/M_AXI_SG]
    # endgroup



    # # Connecting Interrupts (Concat block), which takes these inputs and sends them to the Microblaze controller
    # startgroup
    # set_property -dict [list CONFIG.NUM_PORTS {5}] [get_bd_cells microblaze_0_xlconcat]
    # endgroup
    # connect_bd_net [get_bd_pins axi_timer_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In0]
    # connect_bd_net [get_bd_pins axi_ethernet_0_dma/mm2s_introut] [get_bd_pins microblaze_0_xlconcat/In1]
    # connect_bd_net [get_bd_pins axi_ethernet_0_dma/s2mm_introut] [get_bd_pins microblaze_0_xlconcat/In2]
    # connect_bd_net [get_bd_pins axi_ethernet_0/mac_irq] [get_bd_pins microblaze_0_xlconcat/In3]
    # connect_bd_net [get_bd_pins axi_ethernet_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In4]


    # ---- NEW2 ----

    # Adding the DDR3 Component
    puts "TCL: mig_7series_0"
    startgroup
    create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series:4.2 mig_7series_0
    apply_board_connection -board_interface "ddr3_sdram" -ip_intf "mig_7series_0/mig_ddr_interface" -diagram "ethernet"
    endgroup

    apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( Reset ) } Manual_Source {New External Port (ACTIVE_LOW)}}  [get_bd_pins mig_7series_0/sys_rst]



    # Adding the Microblaze Processor & Configuration
    puts "TCL: microblaze_0"
    startgroup
    create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:11.0 microblaze_0
    endgroup

    puts "TCL: clk_wiz_0"
    startgroup
    create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0
    endgroup

    connect_bd_net [get_bd_pins mig_7series_0/ui_clk] [get_bd_pins clk_wiz_0/clk_in1]

    startgroup
    set_property -dict [list CONFIG.PRIM_IN_FREQ {225.022502} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {100.01000} CONFIG.USE_RESET {false} CONFIG.CLKIN1_JITTER_PS {44.44} CONFIG.MMCM_DIVCLK_DIVIDE {9} CONFIG.MMCM_CLKFBOUT_MULT_F {40.000} CONFIG.MMCM_CLKIN1_PERIOD {4.444} CONFIG.MMCM_CLKIN2_PERIOD {10.0} CONFIG.CLKOUT1_JITTER {214.188} CONFIG.CLKOUT1_PHASE_ERROR {237.697}] [get_bd_cells clk_wiz_0]
    endgroup

    apply_bd_automation -rule xilinx.com:bd_rule:microblaze -config { axi_intc {1} axi_periph {Enabled} cache {32KB} clk {/clk_wiz_0/clk_out1 (100 MHz)} cores {1} debug_module {Debug Only} ecc {None} local_mem {64KB} preset {None}}  [get_bd_cells microblaze_0]



    # Adding Peripheral Components
    puts "TCL: axi_uartlite_0"
    startgroup
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0
    apply_board_connection -board_interface "usb_uart" -ip_intf "axi_uartlite_0/UART" -diagram "ethernet"
    endgroup


    puts "TCL: axi_ethernet_0"
    startgroup
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.2 axi_ethernet_0
    apply_board_connection -board_interface "eth_rgmii" -ip_intf "axi_ethernet_0/rgmii" -diagram "ethernet"
    apply_board_connection -board_interface "eth_mdio_mdc" -ip_intf "axi_ethernet_0/mdio" -diagram "ethernet" 
    apply_board_connection -board_interface "phy_reset_out" -ip_intf "axi_ethernet_0/phy_rst_n" -diagram "ethernet" 
    endgroup

    puts "TCL: axi_timer_0"
    startgroup
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 axi_timer_0
    endgroup

    apply_bd_automation -rule xilinx.com:bd_rule:axi_ethernet -config { FIFO_DMA {DMA} PHY_TYPE {RGMII}}  [get_bd_cells axi_ethernet_0]

    connect_bd_net [get_bd_pins axi_ethernet_0_refclk/clk_in1] [get_bd_pins clk_wiz_0/clk_out1]
    connect_bd_net [get_bd_pins rst_clk_wiz_0_100M/ext_reset_in] [get_bd_pins mig_7series_0/ui_clk_sync_rst]

    startgroup
    apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/axi_ethernet_0_refclk/clk_out1 (200 MHz)} Freq {100} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins axi_ethernet_0/axis_clk]
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_out1 (100 MHz)} Clk_slave {Auto} Clk_xbar {/clk_wiz_0/clk_out1 (100 MHz)} Master {/microblaze_0 (Periph)} Slave {/axi_ethernet_0/s_axi} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_ethernet_0/s_axi]
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_out1 (100 MHz)} Clk_slave {Auto} Clk_xbar {/clk_wiz_0/clk_out1 (100 MHz)} Master {/microblaze_0 (Periph)} Slave {/axi_ethernet_0_dma/S_AXI_LITE} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_ethernet_0_dma/S_AXI_LITE]
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_out1 (100 MHz)} Clk_slave {Auto} Clk_xbar {/clk_wiz_0/clk_out1 (100 MHz)} Master {/microblaze_0 (Periph)} Slave {/axi_timer_0/S_AXI} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_timer_0/S_AXI]
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_out1 (100 MHz)} Clk_slave {Auto} Clk_xbar {/clk_wiz_0/clk_out1 (100 MHz)} Master {/microblaze_0 (Periph)} Slave {/axi_uartlite_0/S_AXI} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_uartlite_0/S_AXI]
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_out1 (100 MHz)} Clk_slave {/clk_wiz_0/clk_out1 (100 MHz)} Clk_xbar {/clk_wiz_0/clk_out1 (100 MHz)} Master {/microblaze_0/M_AXI_DC} Slave {/microblaze_0_axi_intc/s_axi} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins microblaze_0/M_AXI_DC]
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_out1 (100 MHz)} Clk_slave {/clk_wiz_0/clk_out1 (100 MHz)} Clk_xbar {/clk_wiz_0/clk_out1 (100 MHz)} Master {/microblaze_0/M_AXI_IC} Slave {/microblaze_0_axi_intc/s_axi} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins microblaze_0/M_AXI_IC]
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_out1 (100 MHz)} Clk_slave {/mig_7series_0/ui_clk (225 MHz)} Clk_xbar {Auto} Master {/microblaze_0 (Cached)} Slave {/mig_7series_0/S_AXI} ddr_seg {Auto} intc_ip {New AXI SmartConnect} master_apm {0}}  [get_bd_intf_pins mig_7series_0/S_AXI]
    endgroup

    startgroup
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/axi_ethernet_0_refclk/clk_out1 (200 MHz)} Clk_slave {/mig_7series_0/ui_clk (225 MHz)} Clk_xbar {/clk_wiz_0/clk_out1 (100 MHz)} Master {/axi_ethernet_0_dma/M_AXI_MM2S} Slave {/mig_7series_0/S_AXI} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_ethernet_0_dma/M_AXI_MM2S]
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/axi_ethernet_0_refclk/clk_out1 (200 MHz)} Clk_slave {/mig_7series_0/ui_clk (225 MHz)} Clk_xbar {/clk_wiz_0/clk_out1 (100 MHz)} Master {/axi_ethernet_0_dma/M_AXI_S2MM} Slave {/mig_7series_0/S_AXI} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_ethernet_0_dma/M_AXI_S2MM]
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {/mig_7series_0/ui_clk (225 MHz)} Clk_xbar {/clk_wiz_0/clk_out1 (100 MHz)} Master {/axi_ethernet_0_dma/M_AXI_SG} Slave {/mig_7series_0/S_AXI} ddr_seg {Auto} intc_ip {/microblaze_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_ethernet_0_dma/M_AXI_SG]
    endgroup

    # Connecting Interrupts
    puts "TCL: microblaze_0_xlconcat"
    startgroup
    set_property -dict [list CONFIG.NUM_PORTS {5}] [get_bd_cells microblaze_0_xlconcat]
    endgroup
    connect_bd_net [get_bd_pins axi_timer_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In0]
    connect_bd_net [get_bd_pins axi_ethernet_0_dma/mm2s_introut] [get_bd_pins microblaze_0_xlconcat/In1]
    connect_bd_net [get_bd_pins axi_ethernet_0_dma/s2mm_introut] [get_bd_pins microblaze_0_xlconcat/In2]
    connect_bd_net [get_bd_pins axi_ethernet_0/mac_irq] [get_bd_pins microblaze_0_xlconcat/In3]
    connect_bd_net [get_bd_pins axi_ethernet_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In4]



    # Correct Board Configuration
    puts "TCL: Correcting Default Board Configuration"
    puts "TCL: pwd = [pwd]"
    # NOTE: The following line is a workaround of a BUG in Vivado for addressing the file location "mig_a.prj" needed to configure the DDR3 IP Core
    # Because this path does not work: ./boards/xc7k325tffg900-2/ethernet/mig_a.prj
    set_property -name {CONFIG.XML_INPUT_FILE} -value  {./boards/xc7k325tffg900-2/ethernet/../../../../../../mig_a.prj} -objects [get_bd_cells mig_7series_0]
    set_property -name {CONFIG.RESET_BOARD_INTERFACE} -value  {reset} -objects [get_bd_cells mig_7series_0]
    set_property -name {CONFIG.MIG_DONT_TOUCH_PARAM} -value  {Custom} -objects [get_bd_cells mig_7series_0]
    set_property -name {CONFIG.BOARD_MIG_PARAM} -value  {ddr3_sdram} -objects [get_bd_cells mig_7series_0]

    disconnect_bd_net /mig_7series_0_ui_clk [get_bd_pins clk_wiz_0/clk_in1]
    connect_bd_net [get_bd_pins mig_7series_0/ui_addn_clk_0] [get_bd_pins clk_wiz_0/clk_in1]

    startgroup
    set_property -dict [list CONFIG.PRIM_IN_FREQ.VALUE_SRC PROPAGATED] [get_bd_cells clk_wiz_0]
    set_property -dict [list CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {100.00000} CONFIG.CLKIN1_JITTER_PS {100.0} CONFIG.MMCM_DIVCLK_DIVIDE {1} CONFIG.MMCM_CLKFBOUT_MULT_F {10.000} CONFIG.MMCM_CLKIN1_PERIOD {10.000} CONFIG.MMCM_CLKIN2_PERIOD {10.000} CONFIG.CLKOUT1_JITTER {130.958} CONFIG.CLKOUT1_PHASE_ERROR {98.575}] [get_bd_cells clk_wiz_0]
    endgroup

    startgroup
    set_property -dict [list CONFIG.PRIM_IN_FREQ.VALUE_SRC PROPAGATED] [get_bd_cells axi_ethernet_0_refclk]
    set_property -dict [list CONFIG.CLKIN1_JITTER_PS {100.0} CONFIG.MMCM_CLKIN1_PERIOD {10.000} CONFIG.CLKOUT1_JITTER {114.829} CONFIG.CLKOUT1_PHASE_ERROR {98.575} CONFIG.CLKOUT2_JITTER {125.247} CONFIG.CLKOUT2_PHASE_ERROR {98.575}] [get_bd_cells axi_ethernet_0_refclk]
    endgroup

    connect_bd_net [get_bd_pins rst_axi_ethernet_0_refclk_200M/ext_reset_in] [get_bd_pins mig_7series_0/ui_clk_sync_rst]



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