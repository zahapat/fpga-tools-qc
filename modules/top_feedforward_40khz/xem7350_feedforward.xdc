# Tell whether a certain instance exists in the design
proc check_inst_present_in_design {path_to_inst all_insts} {
    if {$all_insts eq ""} {
        set all_insts [get_cells -hier -filter {NAME =~ */* && IS_PRIMITIVE != 1}]
    }
    puts "XDC: Searching for instance: ${path_to_inst}"
    puts "XDC: ${path_to_inst}"
    set target_inst_present 0
    foreach inst $all_insts {
        if {${inst} eq "$path_to_inst"} {
            puts "XDC: ${inst}"
            set target_inst_present 1
        }
    }
    puts "$target_inst_present"
    return $target_inst_present
}


# When the CFGBVS pin is connected to 
# the VCCO_0 supply, the I/O on bank 0 
# support operation at 3.3V or 2.5V 
# during configuration. When the CFGBVS 
# pin is connected to GND, the I/O in 
# bank 0 support operation at 1.8V or 
# 1.5V during configuration.
# set_property CFGBVS GND [current_design]
# set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS True [current_design]

############################################################################
## System Clock
############################################################################
set_property IOSTANDARD LVDS [get_ports sys_clk_p]
set_property IOSTANDARD LVDS [get_ports sys_clk_n]

set_property PACKAGE_PIN AC4 [get_ports sys_clk_p]
set_property PACKAGE_PIN AC3 [get_ports sys_clk_n]

# All timing for that clock and its progeny (including clocks on MMCMs' outputs) will be constrained
# NOTE: Without this constraint, IDELAYE2 and IDELAYCTRL will throw critical warning [Timing 38-472]
create_clock -name sys_clk_p -period 5.000 -waveform {0.000 2.500} [get_ports sys_clk_p]




############################################################################
## PIN ASSIGNMENT ON FMC BREAKOUT BOARD ./pcb/FMC-HPC-BRK/
############################################################################
# U.CL Pin Name   FMC Pin   FPGA Port   I/O Bank   Position (Top->Bot)   Information
# -------------------------------------------------------------------------------------------
# LA32_P1         H37(LA)       H9       16(HR)        1(Left Side)    : Photon 1V
# LA31_P1         G33(LA)      J11       16(HR)        2(L)            : Photon 1H
# LA33_P1         G36(LA)       F9       16(HR)        3(L)            : Photon 2V
# LA22_P1         G24(LA)      G11       16(HR)        4(L)            : Photon 2H
# LA17_P_CC1      D20(LA)      E10       16(HR)        5(L)            : o_debug_port_1
# LA21_P1         H25(LA)      G15       15(HR)        6(L)            : Photon 3V
# LA25_P1         G27(LA)      J15       15(HR)        7(L)            : Photon 3H
# LA01_P_CC1       D8(LA)      G17       15(HR)        8(L)            : o_debug_port_2
# LA18P_CC1       C22(LA)      F17       15(HR)        9(L)            : o_debug_port_3
# LA00_P_CC1       G6(LA)      H17       15(HR)       10(L)            : available
# LA07_P1         H13(LA)      J18       15(HR)       11(L)            : Photon 4V
# LA09_P1         D14(LA)      L19       15(HR)       12(L)            : Photon 4H
# HA10_P1         K13(HA)     AA23       12(HR)       13(L)            : available, Not on K70T
# HA17_P_CC1      K16(HA)     AC23       12(HR)       14(L)            : o_eom_ctrl_pulse, Not on K70T
# HA06_P1         K10(HA)     AB22       12(HR)       15(L)            : available, Not on K70T 
# HA18_P1         J18(HA)     AD21       12(HR)       16(L)            : available, Not on K70T (Reserved for Photon 5V)
# HA04_P1          F7(HA)     AF24       12(HR)       17(L)            : available, NOT on K70T (Reserved for Photon 5H)
# HA02_P1          K7(HA)     AE23       12(HR)       18(L)            : available, Not on K70T (Reserved for Photon 6V)
# HA13_P1         E12(HA)      Y25       12(HR)       19(L)            : available, Not on K70T (Reserved for Photon 6H)
# HA01_P_CC1       E2(HA)      Y23       12(HR)       20(L)            : available, Not on K70T
# HA00_P_CC1       F4(HA)      Y22       12(HR)       21(L)            : available, Not on K70T
# HB21_P1         E36(HB)     AE18       32(HP)        1(Right Side)   : available, Not on K70T
# HB20_P1         F37(HB)     AF19       32(HP)        2(R)            : available, Not on K70T
# HB10_P1         K31(HB)      Y15       32(HP)        3(R)            : available, Not on K70T
# HB00_P_CC1      K25(HB)     AA17       32(HP)        4(R)            : available, Not on K70T
# HB17_P_CC1      K37(HB)     AC18       32(HP)        5(R)            : available, Not on K70T
# HB06_P_CC1      K28(HB)     AB17       32(HP)        6(R)            : available, Not on K70T
# HB06_N_CC1      K29(HB)     AC17       32(HP)        7(R)            : available, Not on K70T
# HB18_P1         J36(HB)     AD20       32(HP)        8(R)            : available, Not on K70T

# Dedicated Clock Pins
# CLK0_M2C_P1      H4(LA)      E18       15(HR)                        : available
# CLK1_M2C_P1      G2(LA)      E11       16(HR)                        : available
# CLK2_BIDIR_P1    K4(HA)      C12       16(HR)                        : available
# CLK3_BIDIR_P1    J2(HB)     AB16       32(HP)                        : available, Not on K70T




# ----- INPUTS -----
# Properties:
# Sets an on-chip input impedance of 50 Ohms to all input_pads (supported by only SSTL standard)
# set_property IN_TERM UNTUNED_SPLIT_50 [get_ports input_pads[*]]
# Sets IOSTANDATD LVTTL to all input_pads
set_property IOSTANDARD LVTTL [get_ports input_pads[*]]

# Photon 6H
catch {
    set_property PACKAGE_PIN Y25 [get_ports input_pads[11]]
}
# Photon 6V
catch {
    set_property PACKAGE_PIN AE23 [get_ports input_pads[10]]
}

# Photon 5H
catch {
    set_property PACKAGE_PIN AF24 [get_ports input_pads[9]]
}
# Photon 5V
catch {
    set_property PACKAGE_PIN AD21 [get_ports input_pads[8]]
}

# Photon 4H
catch {
    set_property PACKAGE_PIN L19 [get_ports input_pads[7]]
}
# Photon 4V
catch {
    set_property PACKAGE_PIN J18 [get_ports input_pads[6]]
}

# Photon 3H
catch {
    set_property PACKAGE_PIN J15 [get_ports input_pads[5]]
}
# Photon 3V
catch {
    set_property PACKAGE_PIN G15 [get_ports input_pads[4]]
}

# Photon 2H
catch {
    set_property PACKAGE_PIN G11 [get_ports input_pads[3]]
}
# Photon 2V
catch {
    set_property PACKAGE_PIN F9  [get_ports input_pads[2]]
}

# Photon 1H
catch {
    set_property PACKAGE_PIN J11 [get_ports input_pads[1]]
}
# Photon 1V
catch {
    set_property PACKAGE_PIN H9  [get_ports input_pads[0]]
}


# ----- OUTPUTS -----
# EOM Trigger
# LVTTL
# LVCMOS33
set_property IOSTANDARD LVCMOS33 [get_ports o_eom_ctrl_pulse]
# set_property SLEW FAST [get_ports {o_eom_ctrl_pulse}]
set_property PACKAGE_PIN AC23 [get_ports o_eom_ctrl_pulse]

# EOM Trigger pulse generator busy
set_property IOSTANDARD LVCMOS33 [get_ports o_debug_port_1]
# set_property SLEW FAST [get_ports {o_debug_port_1}]
set_property PACKAGE_PIN E10 [get_ports o_debug_port_1]

# Probing Photon 1V after going through acquisition logic and CDCC
set_property IOSTANDARD LVCMOS33 [get_ports o_debug_port_2]
# set_property SLEW FAST [get_ports {o_debug_port_2}]
set_property PACKAGE_PIN G17 [get_ports o_debug_port_2]

# Probing Photon 1H after going through acquisition logic and CDCC
set_property IOSTANDARD LVCMOS33 [get_ports o_debug_port_3]
# set_property SLEW FAST [get_ports {o_debug_port_3}]
set_property PACKAGE_PIN F17 [get_ports o_debug_port_3]


############################################################################
## Location Constraints
############################################################################
# to find a suitable physical site of a BUFR, run:
#     show_objects -name find_1 [get_sites -filter { SITE_TYPE == "BUFR" } ]
# Place Cascaded MMCMs
# set_property LOC "MMCME2_ADV_X0Y4" [get_cells inst_top_feedforward_40khz/inst_clock_synthesizer_X0Y4/MMCME2_ADV_inst]
# set_property LOC "MMCME2_ADV_X0Y3" [get_cells inst_top_feedforward_40khz/inst_clock_synthesizer_X0Y3/MMCME2_ADV_inst]
# set_property LOC "MMCME2_ADV_X0Y2" [get_cells inst_top_feedforward_40khz/inst_clock_synthesizer_X0Y2/MMCME2_ADV_inst]

# [Place 30-806] Clock placer fails to converge to a solution. Please try to LOC the following instances, which may allow clock placer to converge and find a legal solution:
#  Driver inst: inst_top_feedforward_40khz/inst_clock_synthesizer_X0Y4/BUFIO_inst_clkout1
#  Load inst: inst_top_feedforward_40khz/inst_xilinx_iophase_aligner_X0Y4/inst_ISERDESE2_phase_aligner
#  Load inst: inst_top_feedforward_40khz/inst_xilinx_iophase_aligner_X0Y4/inst_ISERDESE2_phase_aligner
# set_property LOC "ILOGIC_X0Y222" [get_cells inst_top_feedforward_40khz/inst_xilinx_iophase_aligner_X0Y4/inst_ISERDESE2_phase_aligner]
# set_property LOC "ILOGIC_X0Y174" [get_cells inst_top_feedforward_40khz/inst_xilinx_iophase_aligner_X0Y3/inst_ISERDESE2_phase_aligner]

# Place BUFRs
# Not needed
# set_property LOC "BUFR_X0Y18" [get_cells inst_top_feedforward_40khz/inst_clock_synthesizer_X0Y4/BUFR_inst_clkout0]
# set_property LOC "BUFR_X0Y14" [get_cells inst_top_feedforward_40khz/inst_clock_synthesizer_X0Y3/BUFR_inst_clkout0]
# set_property LOC "BUFR_X0Y10" [get_cells inst_top_feedforward_40khz/inst_clock_synthesizer_X0Y2/BUFR_inst_clkout0]

# TPWS
# inst_top_feedforward_40khz/inst_clock_synthesizer_X0Y4/BUFR_inst_0/I
# see https://support.xilinx.com/s/question/0D54U00007DvAqySAF/what-is-pulse-width-slack-how-to-calculate-how-to-rectify-if-negative-slack-occurs?language=en_US


# [Place 30-575] Sub-optimal placement for a clock-capable IO pin and MMCM pair. If this sub optimal condition is acceptable for this design, you may use the CLOCK_DEDICATED_ROUTE constraint in the .xdc file to demote this message to a WARNING. However, the use of this override is highly discouraged. These examples can be used directly in the .xdc file to override this clock rule.
# For now, use this constraint:
# set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets inst_ok_host_interf/okUH0_ibufg]





############################################################################
## Set Clock Domain Crossing Constraints
############################################################################
# Goal: Force the PAR tool to use short nets with as little capacitance as possible
# set_max_delay constraint: just enough delay to cover/override setup checks
# set_min_delay constraint: just enough delay to cover/override hold checks

# A. Domain crossing constraint: 1st metastable flip-flop (source ff must charge as little capacitance as possible):
#    Note: Take ~ 0.4*(faster clock period) but not more than 1.5
#    Note: Example: 0.4*(1.600 ns) = 0.666
#    Note: Example: 0.4*(3.333 ns) = 1.333
#    Note: Apply '-datapath_only' switch to 'set_max_delay' constraint to exclude clock constraints checks
set ff1_cdc_1to2_max_delay 0.666
set ff1_cdc_2to3_max_delay 1.333

# B. Paranoid constraint: 2nd metastable flip-flop (ff1 and ff2 must be placed close together):
#    Note: Take ~ 0.4*(destination clock period) but not more than 1.5
#    Note: Example: 0.4*(3.0 ns) = 1.2 (can be reduced to 0.900)
#    Note: Example: 0.4*(5.0 ns) = 2.0 -> 1.5
#    see https://support.xilinx.com/s/question/0D52E00006iHlQYSA0/how-to-constrain-a-cdc?language=en_US
set ff2_domain2_max_delay_paranoid 0.9
set ff2_domain3_max_delay_paranoid 1.5


# Mandatory Constraints for the Asynchronous Input Sampler (ISERDESE2 output FFs placement)
# XAPP881: "The next stage of data capture is to transfer the data from 
#           ISERDESE1 to the CLB flip-flops. It is important that the delay 
#           from ISERDESE1 to all the registers being used does not exceed 
#           600 ps." [note: was set to 666 ps for -1 speed grade Kintex 7 FPGA]
#          "The important part of this transfer is that it moves from the 
#           BUFIO clock network to the BUFG [BUFH] clock network; the BUFIO 
#           clock network only spans to the ISERDESE1 but does not span to 
#           the CLBs."
set ISERDES_to_FFs_max_delay 0.950

# set_false_path to exclude the following paths from timing analysis 
#     - This is to emulate analog pulses from single photon detectors, which are naturally not synchronized with FPGA's clock
set inst_source "inst_lfsr_inemul"
set inst_destination "inst_photon_delay_compensation"


if {[check_inst_present_in_design "inst_top_feedforward_40khz/gen_emul_true.${inst_source}" ""] == 1} {
    set_false_path -from [get_cells inst_top_feedforward_40khz/gen_emul_true.${inst_source}/data_out_reg[*]] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[*].${inst_destination}/all_channels_metastable[*].s_flops_databuff_1_reg[*]];
}


# ISERDESE2 output to CLB FFs placement constraints
set inst_source "inst_ISERDESE2_sdr_sampler"
set inst_destination "inst_photon_delay_compensation"

# # Qubit 1
# if {[check_inst_present_in_design "inst_top_feedforward_40khz/gen_emul_false0.inst_xilinx_sdr_sampler_v0" ""] == 1} {
#     set_max_delay -datapath_only ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false0.inst_xilinx_sdr_sampler_v0/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[0].${inst_destination}/all_channels_metastable[0].s_flops_databuff_1_reg[0]]
#     set_max_delay -datapath_only ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false0.inst_xilinx_sdr_sampler_h0/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[0].${inst_destination}/all_channels_metastable[1].s_flops_databuff_1_reg[1]]

#     # set_max_delay ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false0.inst_xilinx_sdr_sampler_v0/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[0].${inst_destination}/all_channels_metastable[0].s_flops_databuff_1_reg[0]]
#     # set_max_delay ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false0.inst_xilinx_sdr_sampler_h0/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[0].${inst_destination}/all_channels_metastable[1].s_flops_databuff_1_reg[1]]
# }

# # Qubit 2
# if {[check_inst_present_in_design "inst_top_feedforward_40khz/gen_emul_false1.inst_xilinx_sdr_sampler_v1" ""] == 1} {
#     set_max_delay -datapath_only ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false1.inst_xilinx_sdr_sampler_v1/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[1].${inst_destination}/all_channels_metastable[0].s_flops_databuff_1_reg[0]]
#     set_max_delay -datapath_only ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false1.inst_xilinx_sdr_sampler_h1/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[1].${inst_destination}/all_channels_metastable[1].s_flops_databuff_1_reg[1]]

#     # set_max_delay ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false1.inst_xilinx_sdr_sampler_v1/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[1].${inst_destination}/all_channels_metastable[0].s_flops_databuff_1_reg[0]]
#     # set_max_delay ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false1.inst_xilinx_sdr_sampler_h1/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[1].${inst_destination}/all_channels_metastable[1].s_flops_databuff_1_reg[1]]
# }

# # Qubit 3
# if {[check_inst_present_in_design "inst_top_feedforward_40khz/gen_emul_false2.inst_xilinx_sdr_sampler_v2" ""] == 1} {
#     set_max_delay -datapath_only ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false2.inst_xilinx_sdr_sampler_v2/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[2].${inst_destination}/all_channels_metastable[0].s_flops_databuff_1_reg[0]]
#     set_max_delay -datapath_only ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false2.inst_xilinx_sdr_sampler_h2/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[2].${inst_destination}/all_channels_metastable[1].s_flops_databuff_1_reg[1]]

#     # set_max_delay ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false2.inst_xilinx_sdr_sampler_v2/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[2].${inst_destination}/all_channels_metastable[0].s_flops_databuff_1_reg[0]]
#     # set_max_delay ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false2.inst_xilinx_sdr_sampler_h2/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[2].${inst_destination}/all_channels_metastable[1].s_flops_databuff_1_reg[1]]
# }

# # Qubit 4
# if {[check_inst_present_in_design "inst_top_feedforward_40khz/gen_emul_false3.inst_xilinx_sdr_sampler_v3" ""] == 1} {
#     set_max_delay -datapath_only ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false3.inst_xilinx_sdr_sampler_v3/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[3].${inst_destination}/all_channels_metastable[0].s_flops_databuff_1_reg[0]]
#     set_max_delay -datapath_only ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false3.inst_xilinx_sdr_sampler_h3/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[3].${inst_destination}/all_channels_metastable[1].s_flops_databuff_1_reg[1]]

#     # set_max_delay ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false3.inst_xilinx_sdr_sampler_v3/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[3].${inst_destination}/all_channels_metastable[0].s_flops_databuff_1_reg[0]]
#     # set_max_delay ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false3.inst_xilinx_sdr_sampler_h3/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[3].${inst_destination}/all_channels_metastable[1].s_flops_databuff_1_reg[1]]
# }

# # Qubit 5
# if {[check_inst_present_in_design "inst_top_feedforward_40khz/gen_emul_false4.inst_xilinx_sdr_sampler_v4" ""] == 1} {
#     set_max_delay -datapath_only ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false4.inst_xilinx_sdr_sampler_v4/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[4].${inst_destination}/all_channels_metastable[0].s_flops_databuff_1_reg[0]]
#     set_max_delay -datapath_only ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false4.inst_xilinx_sdr_sampler_h4/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[4].${inst_destination}/all_channels_metastable[1].s_flops_databuff_1_reg[1]]

#     # set_max_delay ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false4.inst_xilinx_sdr_sampler_v4/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[4].${inst_destination}/all_channels_metastable[0].s_flops_databuff_1_reg[0]]
#     # set_max_delay ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false4.inst_xilinx_sdr_sampler_h4/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[4].${inst_destination}/all_channels_metastable[1].s_flops_databuff_1_reg[1]]
# }

# # Qubit 6
# if {[check_inst_present_in_design "inst_top_feedforward_40khz/gen_emul_false5.inst_xilinx_sdr_sampler_v5" ""] == 1} {
#     set_max_delay -datapath_only ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false5.inst_xilinx_sdr_sampler_v5/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[5].${inst_destination}/all_channels_metastable[0].s_flops_databuff_1_reg[0]]
#     set_max_delay -datapath_only ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_emul_false5.inst_xilinx_sdr_sampler_h5/gen_ISERDESE2_IDELAY.${inst_source}] -to [get_cells inst_top_feedforward_40khz/gen_photon_delay_compensation[5].${inst_destination}/all_channels_metastable[1].s_flops_databuff_1_reg[1]]
# }



# Constraining 600->300 Mhz domain crossing
#    crossing path
set inst_name "inst_nff_cdcc_cntcross_samplclk_bit1"
if {[check_inst_present_in_design "inst_top_feedforward_40khz/gen_nff_cdcc_sysclk[0].${inst_name}" ""] == 1} {
    set_max_delay -datapath_only ${ff1_cdc_1to2_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_top_feedforward_40khz/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
    set_max_delay ${ff2_domain2_max_delay_paranoid} -from [get_cells inst_top_feedforward_40khz/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]] -to [get_cells inst_top_feedforward_40khz/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[1]];
}


set inst_name "inst_nff_cdcc_cntcross_samplclk_bit2"
if {[check_inst_present_in_design "inst_top_feedforward_40khz/gen_nff_cdcc_sysclk[0].${inst_name}" ""] == 1} {
    set_max_delay -datapath_only ${ff1_cdc_1to2_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_top_feedforward_40khz/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
    set_max_delay ${ff2_domain2_max_delay_paranoid} -from [get_cells inst_top_feedforward_40khz/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]] -to [get_cells inst_top_feedforward_40khz/gen_nff_cdcc_sysclk[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[1]];
}


# Constraining 300->200 MHz domain crossing
set inst_name "inst_nff_cdcc_success_done"
if {[check_inst_present_in_design "inst_top_feedforward_40khz/${inst_name}" ""] == 1} {
    set_max_delay -datapath_only ${ff1_cdc_2to3_max_delay} -from [get_cells inst_top_feedforward_40khz/${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_top_feedforward_40khz/${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
    set_max_delay -datapath_only ${ff1_cdc_2to3_max_delay} -from [get_cells inst_top_feedforward_40khz/${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_top_feedforward_40khz/${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];

    set_max_delay ${ff2_domain3_max_delay_paranoid} -from [get_cells inst_top_feedforward_40khz/${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]] -to [get_cells inst_top_feedforward_40khz/${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[1]];
    set_max_delay ${ff2_domain3_max_delay_paranoid} -from [get_cells inst_top_feedforward_40khz/${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]] -to [get_cells inst_top_feedforward_40khz/${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[1][*]];
}


set inst_name "inst_nff_cdcc_qubit_buffer"
if {[check_inst_present_in_design "inst_top_feedforward_40khz/gen_cdcc_transfer_data[0].${inst_name}" ""] == 1} {
    set_max_delay -datapath_only ${ff1_cdc_2to3_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
    set_max_delay -datapath_only ${ff1_cdc_2to3_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];

    set_max_delay ${ff2_domain3_max_delay_paranoid} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[1]];
    set_max_delay ${ff2_domain3_max_delay_paranoid} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[1][*]];
}


set inst_name "inst_nff_cdcc_alpha_buffer"
if {[check_inst_present_in_design "inst_top_feedforward_40khz/gen_cdcc_transfer_data[0].${inst_name}" ""] == 1} {
    set_max_delay -datapath_only ${ff1_cdc_2to3_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
    set_max_delay -datapath_only ${ff1_cdc_2to3_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];

    set_max_delay ${ff2_domain3_max_delay_paranoid} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[1]];
    set_max_delay ${ff2_domain3_max_delay_paranoid} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[1][*]];
}


set inst_name "inst_nff_cdcc_modulo_buffer"
if {[check_inst_present_in_design "inst_top_feedforward_40khz/gen_cdcc_transfer_data[0].${inst_name}" ""] == 1} {
    set_max_delay -datapath_only ${ff1_cdc_2to3_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
    set_max_delay -datapath_only ${ff1_cdc_2to3_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];

    set_max_delay ${ff2_domain3_max_delay_paranoid} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[1]];
    set_max_delay ${ff2_domain3_max_delay_paranoid} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[1][*]];
}


set inst_name "inst_nff_cdcc_random_buffer"
if {[check_inst_present_in_design "inst_top_feedforward_40khz/gen_cdcc_transfer_data[0].${inst_name}" ""] == 1} {
    set_max_delay -datapath_only ${ff1_cdc_2to3_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
    set_max_delay -datapath_only ${ff1_cdc_2to3_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];

    set_max_delay ${ff2_domain3_max_delay_paranoid} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[1]];
    set_max_delay ${ff2_domain3_max_delay_paranoid} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[1][*]];
}


set inst_name "inst_nff_cdcc_timestamp_buffer"
if {[check_inst_present_in_design "inst_top_feedforward_40khz/gen_cdcc_transfer_feedfwd_timestamps[0].${inst_name}" ""] == 1} {
    set_max_delay -datapath_only ${ff1_cdc_2to3_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_feedfwd_timestamps[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_feedfwd_timestamps[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
    set_max_delay -datapath_only ${ff1_cdc_2to3_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_feedfwd_timestamps[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_feedfwd_timestamps[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];

    set_max_delay ${ff2_domain3_max_delay_paranoid} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_feedfwd_timestamps[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_feedfwd_timestamps[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[1]];
    set_max_delay ${ff2_domain3_max_delay_paranoid} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_feedfwd_timestamps[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_feedfwd_timestamps[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[1][*]];
}

set inst_name "inst_nff_cdcc_cntr_ch_photons"
if {[check_inst_present_in_design "inst_top_feedforward_40khz/gen_cdcc_cntr_ch_photons[0].${inst_name}" ""] == 1} {
    set_max_delay -datapath_only ${ff1_cdc_2to3_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_cntr_ch_photons[*].${inst_name}/slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_cntr_ch_photons[*].${inst_name}/slv_data_asyncff_2d_reg[0][*]];

    set_max_delay ${ff2_domain3_max_delay_paranoid} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_cntr_ch_photons[*].${inst_name}/slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_cntr_ch_photons[*].${inst_name}/slv_data_asyncff_2d_reg[0][*]];
}

set inst_name "inst_nff_cdcc_photon_loss_event"
if {[check_inst_present_in_design "inst_top_feedforward_40khz/gen_cdcc_photon_losses_flags[0].${inst_name}" ""] == 1} {
    set_max_delay -datapath_only ${ff1_cdc_2to3_max_delay} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_photon_losses_flags[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_photon_losses_flags[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];

    set_max_delay ${ff2_domain3_max_delay_paranoid} -from [get_cells inst_top_feedforward_40khz/gen_cdcc_photon_losses_flags[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_photon_losses_flags[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[1]];
}

# set ISERDES_to_FFs_max_delay 0.600
# set inst_name "inst_xilinx_iophase_aligner_X0Y4"
# set_max_delay -datapath_only ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/${inst_name}/inst_ISERDESE2_phase_aligner] -to [get_cells inst_top_feedforward_40khz/${inst_name}/slv_clock_sampled_reg[0]]
# set_max_delay -datapath_only ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/${inst_name}/inst_ISERDESE2_phase_aligner] -to [get_cells inst_top_feedforward_40khz/${inst_name}/slv_clock_sampled_reg[1]]
# set_max_delay -datapath_only ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/${inst_name}/inst_ISERDESE2_phase_aligner] -to [get_cells inst_top_feedforward_40khz/${inst_name}/slv_clock_sampled_reg[2]]
# set_max_delay -datapath_only ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/${inst_name}/inst_ISERDESE2_phase_aligner] -to [get_cells inst_top_feedforward_40khz/${inst_name}/slv_clock_sampled_reg[3]]
# set_max_delay -datapath_only ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/${inst_name}/slv_oserdes_pattern_reg[0]] -to [get_cells inst_top_feedforward_40khz/${inst_name}/inst_OSERDESE2_phase_aligner]
# set_max_delay -datapath_only ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/${inst_name}/slv_oserdes_pattern_reg[1]] -to [get_cells inst_top_feedforward_40khz/${inst_name}/inst_OSERDESE2_phase_aligner]
# set_max_delay -datapath_only ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/${inst_name}/slv_oserdes_pattern_reg[2]] -to [get_cells inst_top_feedforward_40khz/${inst_name}/inst_OSERDESE2_phase_aligner]
# set_max_delay -datapath_only ${ISERDES_to_FFs_max_delay} -from [get_cells inst_top_feedforward_40khz/${inst_name}/slv_oserdes_pattern_reg[3]] -to [get_cells inst_top_feedforward_40khz/${inst_name}/inst_OSERDESE2_phase_aligner]


# CDCC TEMPLATE
# set inst_name "inst_module_name"
# CDCC FF Stage 1
# set_max_delay $ff1_cdc_2to3_max_delay -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
# set_min_delay $min_delay2 -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_to_cross_reg[1]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]];
# set_max_delay $ff1_cdc_2to3_max_delay -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];
# set_min_delay $min_delay2 -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_to_cross_2d_reg[1][*]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]];
# CDCC FF Stage 2
# set_max_delay $ff1_cdc_2to3_max_delay -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[1]];
# set_min_delay $min_delay2 -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[0]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_wr_en_event_asyncff_reg[1]];
# set_max_delay $ff1_cdc_2to3_max_delay -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[1][*]];
# set_min_delay $min_delay2 -from [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[0][*]] -to [get_cells inst_top_feedforward_40khz/gen_cdcc_transfer_data[*].${inst_name}/gen_if_clocks_different.slv_data_asyncff_2d_reg[1][*]];

# CDCC FF Stage 1
# set_max_delay $ff1_cdc_1to2_max_delay -from [get_cells ] -to [get_cells ];
# set_min_delay $min_delay1 -from [get_cells ] -to [get_cells ];
# CDCC FF Stage 2
# set_max_delay $ff1_cdc_1to2_max_delay -from [get_cells ] -to [get_cells ];
# set_min_delay $min_delay1 -from [get_cells ] -to [get_cells ];

# CDCC FF Stage 1
# set_max_delay $ff1_cdc_2to3_max_delay -from [get_cells ] -to [get_cells ];
# set_min_delay $min_delay2 -from [get_cells ] -to [get_cells ];
# CDCC FF Stage 2
# set_max_delay $ff1_cdc_2to3_max_delay -from [get_cells ] -to [get_cells ];
# set_min_delay $min_delay2 -from [get_cells ] -to [get_cells ];



############################################################################
## FrontPanel Host Interface
############################################################################
set_property PACKAGE_PIN F23 [get_ports {okHU[0]}]
set_property PACKAGE_PIN H23 [get_ports {okHU[1]}]
set_property PACKAGE_PIN J25 [get_ports {okHU[2]}]
set_property SLEW FAST [get_ports {okHU[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {okHU[*]}]

set_property PACKAGE_PIN F22 [get_ports {okUH[0]}]
set_property PACKAGE_PIN G24 [get_ports {okUH[1]}]
set_property PACKAGE_PIN J26 [get_ports {okUH[2]}]
set_property PACKAGE_PIN G26 [get_ports {okUH[3]}]
set_property PACKAGE_PIN C23 [get_ports {okUH[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {okUH[*]}]

set_property PACKAGE_PIN B21 [get_ports {okUHU[0]}]
set_property PACKAGE_PIN C21 [get_ports {okUHU[1]}]
set_property PACKAGE_PIN E22 [get_ports {okUHU[2]}]
set_property PACKAGE_PIN A20 [get_ports {okUHU[3]}]
set_property PACKAGE_PIN B20 [get_ports {okUHU[4]}]
set_property PACKAGE_PIN C22 [get_ports {okUHU[5]}]
set_property PACKAGE_PIN D21 [get_ports {okUHU[6]}]
set_property PACKAGE_PIN C24 [get_ports {okUHU[7]}]
set_property PACKAGE_PIN C26 [get_ports {okUHU[8]}]
set_property PACKAGE_PIN D26 [get_ports {okUHU[9]}]
set_property PACKAGE_PIN A24 [get_ports {okUHU[10]}]
set_property PACKAGE_PIN A23 [get_ports {okUHU[11]}]
set_property PACKAGE_PIN A22 [get_ports {okUHU[12]}]
set_property PACKAGE_PIN B22 [get_ports {okUHU[13]}]
set_property PACKAGE_PIN A25 [get_ports {okUHU[14]}]
set_property PACKAGE_PIN B24 [get_ports {okUHU[15]}]
set_property PACKAGE_PIN G21 [get_ports {okUHU[16]}]
set_property PACKAGE_PIN E23 [get_ports {okUHU[17]}]
set_property PACKAGE_PIN E21 [get_ports {okUHU[18]}]
set_property PACKAGE_PIN H22 [get_ports {okUHU[19]}]
set_property PACKAGE_PIN D23 [get_ports {okUHU[20]}]
set_property PACKAGE_PIN J21 [get_ports {okUHU[21]}]
set_property PACKAGE_PIN K22 [get_ports {okUHU[22]}]
set_property PACKAGE_PIN D24 [get_ports {okUHU[23]}]
set_property PACKAGE_PIN K23 [get_ports {okUHU[24]}]
set_property PACKAGE_PIN H24 [get_ports {okUHU[25]}]
set_property PACKAGE_PIN F24 [get_ports {okUHU[26]}]
set_property PACKAGE_PIN D25 [get_ports {okUHU[27]}]
set_property PACKAGE_PIN J24 [get_ports {okUHU[28]}]
set_property PACKAGE_PIN B26 [get_ports {okUHU[29]}]
set_property PACKAGE_PIN H26 [get_ports {okUHU[30]}]
set_property PACKAGE_PIN E26 [get_ports {okUHU[31]}]
set_property SLEW FAST [get_ports {okUHU[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {okUHU[*]}]

set_property PACKAGE_PIN R26 [get_ports {okAA}]
set_property IOSTANDARD LVCMOS33 [get_ports {okAA}]


create_clock -name okUH0 -period 9.920 [get_ports {okUH[0]}]
create_clock -name virt_okUH0 -period 9.920

set_clock_groups -name async-mmcm-user-virt -asynchronous -group {mmcm0_clk0} -group {virt_okUH0}

# [Constraints 18-96] Setting input delay on a clock pin 'okUH[0]' is not supported, ignoring it ["C:/Git/zahapat/fpga-tools-qc/modules/top_feedforward_40khz/xem7350_feedforward.xdc":156]
# set_input_delay -add_delay -max -clock [get_clocks {virt_okUH0}]  8.000 [get_ports {okUH[*]}]
# set_input_delay -add_delay -min -clock [get_clocks {virt_okUH0}]  0.000 [get_ports {okUH[*]}]

set_input_delay -add_delay -max -clock [get_clocks {virt_okUH0}]  8.000 [get_ports {okUHU[*]}]
set_input_delay -add_delay -min -clock [get_clocks {virt_okUH0}]  2.000 [get_ports {okUHU[*]}]

set_output_delay -add_delay -max -clock [get_clocks {okUH0}]  2.000 [get_ports {okHU[*]}]
set_output_delay -add_delay -min -clock [get_clocks {okUH0}]  -0.500 [get_ports {okHU[*]}]

set_output_delay -add_delay -max -clock [get_clocks {okUH0}]  2.000 [get_ports {okUHU[*]}]
set_output_delay -add_delay -min -clock [get_clocks {okUH0}]  -0.500 [get_ports {okUHU[*]}]


############################################################################
## LEDs
############################################################################
set_property PACKAGE_PIN T24 [get_ports {led[0]}]
set_property PACKAGE_PIN T25 [get_ports {led[1]}]
set_property PACKAGE_PIN R25 [get_ports {led[2]}]
set_property PACKAGE_PIN P26 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]




# Slack -0.206 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
# set_max_delay 1.900 -datapath_only \
# -from [get_cells inst_top_feedforward_40khz/inst_fsm_feedforward/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_reg[5]]\
#   -to [get_cells inst_top_feedforward_40khz/inst_fsm_feedforward/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_reg[4]]

# # Slack -0.206 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
# set_max_delay 1.900 -datapath_only \
# -from [get_cells inst_top_feedforward_40khz/inst_fsm_feedforward/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_reg[5]]\
#   -to [get_cells inst_top_feedforward_40khz/inst_fsm_feedforward/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_reg[7]]

# # Slack -0.164 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
# set_max_delay 1.900 -datapath_only \
# -from [get_cells inst_top_feedforward_40khz/inst_fsm_feedforward/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_reg[4]]\
#   -to [get_cells inst_top_feedforward_40khz/inst_fsm_feedforward/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_reg[1]]

# # Slack -0.164 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
# set_max_delay 1.900 -datapath_only \
# -from [get_cells inst_top_feedforward_40khz/inst_fsm_feedforward/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_reg[4]]\
#   -to [get_cells inst_top_feedforward_40khz/inst_fsm_feedforward/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_reg[2]]
 
# # Slack -0.164 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
# set_max_delay 1.900 -datapath_only \
# -from [get_cells inst_top_feedforward_40khz/inst_fsm_feedforward/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_reg[4]]\
#   -to [get_cells inst_top_feedforward_40khz/inst_fsm_feedforward/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_reg[5]]

# # Slack -0.164 on clocks MMCME2_ADV_inst_n_4 -> MMCME2_ADV_inst_n_4
# set_max_delay 1.900 -datapath_only \
# -from [get_cells inst_top_feedforward_40khz/inst_fsm_feedforward/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_reg[4]]\
#   -to [get_cells inst_top_feedforward_40khz/inst_fsm_feedforward/gen_feedfwd_more_qubits.slv_new_main_galois_cntr_reg[6]]