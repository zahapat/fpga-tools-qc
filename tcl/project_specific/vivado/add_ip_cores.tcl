    # 1)   * Add Packages to Filesets + Libraries
    # 1.0) Opal Kelly Frontpanel Package -> sources_1 + default library work (no action)
    # add_files -fileset "sources_1" -norecurse {./packages/ok/frontpanel_xem7350_k160t/okCoreHarness.v\ 
    #                                          ./packages/ok/frontpanel_xem7350_k160t/okTriggerOut.v\
    #                                          ./packages/ok/frontpanel_xem7350_k160t/okWireIn.v\
    #                                          ./packages/ok/frontpanel_xem7350_k160t/okBTPipeOut.v\
    #                                          ./packages/ok/frontpanel_xem7350_k160t/okRegisterBridge.v\
    #                                          ./packages/ok/frontpanel_xem7350_k160t/okLibrary.vhd\
    #                                          ./packages/ok/frontpanel_xem7350_k160t/okWireOut.v\
    #                                          ./packages/ok/frontpanel_xem7350_k160t/okPipeOut.v\
    #                                          ./packages/ok/frontpanel_xem7350_k160t/okBTPipeIn.v\
    #                                          ./packages/ok/frontpanel_xem7350_k160t/okPipeIn.v\
    #                                          ./packages/ok/frontpanel_xem7350_k160t/okTriggerIn.v}

    # # 1.1) Global Project Specific Package -> sources_1 + lib_src library
    # add_files -fileset sources_1 -norecurse {./packages/proj_specific_src/const_pack.vhd\
    #                                          ./packages/proj_specific_src/types_pack.vhd\
    #                                          ./packages/proj_specific_src/signals_pack.vhd}
    # set_property library lib_src [get_files {./packages/proj_specific_src/const_pack.vhd\
    #                                          ./packages/proj_specific_src/types_pack.vhd\
    #                                          ./packages/proj_specific_src/signals_pack.vhd}]
    # update_compile_order -fileset sources_1


    # # 2)   * Add Source Files to Filesets + Libraries
    # # 2.0) Top File -> sources_1 + default library work (no action)
    # add_files -fileset sources_1 -norecurse ./modules/top/top.vhd

    # # 2.1) Source files -> sources_1 + lib_src
    # add_files -fileset sources_1 -norecurse {./modules/clk_delay_counter/clk_delay_counter.vhd\
    #                                          ./modules/galois_counter/galois_counter.vhd 
    #                                          ./modules/math_funct_dependence/math_funct_dependence.vhd\
    #                                          ./modules/output_pulse_gen/output_pulse_gen.vhd\
    #                                          ./modules/pullup_reset/pullup_reset.vhd\
    #                                          ./modules/noisy_rising_edge_detection_v2/noisy_rising_edge_detection_v2.vhd\
    #                                          ./modules/modulo_rom/modulo_rom.vhd\
    #                                          ./modules/gflow_protocol_fsm/gflow_protocol_fsm.vhd\
    #                                          ./modules/qubit_sampler_dual_port_v2/qubit_sampler_dual_port_v2.vhd\
    #                                          ./modules/clk_delay_counter_v2/clk_delay_counter_v2.vhd\
    #                                          ./modules/xilinx_ibufs/xilinx_ibufs.vhd\
    #                                          ./modules/input_emulator/input_emulator.vhd\
    #                                          ./modules/ok_usb_32b_fifo_ctrl/ok_usb_32b_fifo_ctrl.vhd\
    #                                          ./modules/xilinx_obufs/xilinx_obufs.vhd}

    # set_property library lib_src [get_files {./modules/clk_delay_counter/clk_delay_counter.vhd\
    #                                          ./modules/galois_counter/galois_counter.vhd\
    #                                          ./modules/math_funct_dependence/math_funct_dependence.vhd\
    #                                          ./modules/output_pulse_gen/output_pulse_gen.vhd\
    #                                          ./modules/pullup_reset/pullup_reset.vhd\
    #                                          ./modules/noisy_rising_edge_detection_v2/noisy_rising_edge_detection_v2.vhd\
    #                                          ./modules/modulo_rom/modulo_rom.vhd\
    #                                          ./modules/gflow_protocol_fsm/gflow_protocol_fsm.vhd\
    #                                          ./modules/qubit_sampler_dual_port_v2/qubit_sampler_dual_port_v2.vhd\
    #                                          ./modules/clk_delay_counter_v2/clk_delay_counter_v2.vhd\
    #                                          ./modules/xilinx_ibufs/xilinx_ibufs.vhd\
    #                                          ./modules/input_emulator/input_emulator.vhd\
    #                                          ./modules/ok_usb_32b_fifo_ctrl/ok_usb_32b_fifo_ctrl.vhd\
    #                                          ./modules/xilinx_obufs/xilinx_obufs.vhd}]

    # # 3)   * Add Constraint XDC Files
    # add_files -fileset constrs_1 -norecurse ./const/xem7350.xdc


    # Reset Top File
    # set_property top top [current_fileset]
    # update_compile_order -fileset sources_1


    #      * Add Opal Kelly Frontpanel IP - is tied to the top_gflow file
    # source "./packages/ok/frontpanel_xem7350_k160t/compile_order.tcl"


    # 4)   * Add Xilinx IP Cores
    # 4.1) fifo_generator_0
    if {[catch {
        create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name fifo_generator_0\
    } error_msg]} {
        puts "TCL: Skipping adding already existing Xilinx IP Core."
    } else {\
        set_property -dict [list CONFIG.Fifo_Implementation {Independent_Clocks_Builtin_FIFO}\
                                CONFIG.Input_Data_Width {32}\
                                CONFIG.Input_Depth {65536}\
                                CONFIG.Output_Data_Width {32}\
                                CONFIG.Output_Depth {65536}\
                                CONFIG.Reset_Type {Asynchronous_Reset}\
                                CONFIG.Use_Dout_Reset {false}\
                                CONFIG.Data_Count_Width {16}\
                                CONFIG.Write_Data_Count_Width {16}\
                                CONFIG.Read_Data_Count_Width {16}\
                                CONFIG.Full_Threshold_Assert_Value {65536}\
                                CONFIG.Full_Threshold_Negate_Value {65535}\
                                CONFIG.Empty_Threshold_Assert_Value {3}\
                                CONFIG.Empty_Threshold_Negate_Value {4}] [get_ips fifo_generator_0]

        set_property -dict [list CONFIG.Valid_Flag {true}] [get_ips fifo_generator_0]

        set_property -dict [list CONFIG.Programmable_Full_Type {No_Programmable_Full_Threshold}\
                                CONFIG.Programmable_Empty_Type {Single_Programmable_Empty_Threshold_Constant}\
                                CONFIG.Empty_Threshold_Assert_Value {5}\
                                CONFIG.Empty_Threshold_Negate_Value {6}] [get_ips fifo_generator_0]

        set_property -dict [list CONFIG.Read_Clock_Frequency {100.80645} \
                                CONFIG.Write_Clock_Frequency {200} \
                                CONFIG.Full_Threshold_Assert_Value {65536} \
                                CONFIG.Full_Threshold_Negate_Value {65535}] [get_ips fifo_generator_0]
    }


    # 4.2) clk_wiz_0: 200 MHz diff input, out1 = 600.000 MHz, out2 = 300.000 MHz, out3 = 200.000 MHz
    # ug949: "When the MMCM compensation is set to ZHOLD or 
    # BUF_IN, the placer assigns the same clock root to the nets 
    # driven by the feedback buffer and by all buffers directly 
    # connected to the CLKOUT0 pin. This ensures that the 
    # insertion delays are matched so that the I/O ports and 
    # the sequential cells connected to CLKOUT0 are phase-aligned 
    # and hold time is met at the device interface. The Vivado 
    # tools consider all the loads of these nets to optimally 
    # define the clock root."
    if {[catch {
        create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0\
    } error_msg]} {
        puts "TCL: Skipping adding already existing Xilinx IP Core."
    } else {\
        set_property -dict [list CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
                                CONFIG.PRIM_IN_FREQ {200.000} \
                                CONFIG.CLKOUT2_USED {true} \
                                CONFIG.CLKOUT3_USED {true} \
                                CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {600.000} \
                                CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {300.000} \
                                CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {200.000} \
                                CONFIG.USE_RESET {false} \
                                CONFIG.OVERRIDE_MMCM {true} \
                                CONFIG.MMCM_BANDWIDTH {HIGH} \
                                CONFIG.MMCM_CLKFBOUT_MULT_F {6.000} \
                                CONFIG.MMCM_CLKOUT0_DIVIDE_F {2.000} \
                                CONFIG.MMCM_CLKOUT1_DIVIDE {4} \
                                CONFIG.MMCM_CLKOUT2_DIVIDE {6} \
                                CONFIG.CLKIN1_JITTER_PS {50.0} \
                                CONFIG.MMCM_CLKIN1_PERIOD {5.0} \
                                CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
                                CONFIG.NUM_OUT_CLKS {3} \
                                CONFIG.CLKOUT1_JITTER {76.344} \
                                CONFIG.CLKOUT1_PHASE_ERROR {105.563} \
                                CONFIG.CLKOUT2_JITTER {87.344} \
                                CONFIG.CLKOUT2_PHASE_ERROR {105.563} \
                                CONFIG.CLKOUT3_JITTER {94.528} \
                                CONFIG.CLKOUT3_PHASE_ERROR {105.563}] [get_ips clk_wiz_0]
    }


    # 5)   * GenerateOutputs of All Added Xilinx IP Cores Above
    puts "TCL: ------------------------------------------------"
    puts "TCL: Generating all targets for all Xilinx IP Cores"
    generate_target all [get_ips] -force
    puts "TCL: ------------------------------------------------"