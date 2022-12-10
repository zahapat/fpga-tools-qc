# Master XDC for Genesys 2:
# https://github.com/Digilent/digilent-xdc/blob/master/Genesys-2-Master.xdc

############################################################################
## System Clock
############################################################################

# ---- On-board Oscillator ----
# Positive
# set_property IOSTANDARD LVDS [get_ports sys_diff_clock_clk_p]
# set_property PACKAGE_PIN AD11 [get_ports sys_diff_clock_clk_p]

# Negative
# set_property IOSTANDARD LVDS [get_ports sys_diff_clock_clk_n]
# set_property PACKAGE_PIN AD12 [get_ports sys_diff_clock_clk_n]



############################################################################
## Inputs
############################################################################

# ---- External Input clocks ----

# ---- External asynchronous inputs ----



############################################################################
## Outputs
############################################################################


############################################################################
## Ethernet
############################################################################

# Ethernet
# set_property -dict { PACKAGE_PIN AK16  IOSTANDARD LVCMOS18 } [get_ports { eth_int_b }]; #IO_L1P_T0_32 Sch=eth_intb
# set_property -dict { PACKAGE_PIN AF12  IOSTANDARD LVCMOS15 } [get_ports { eth_mdc }]; #IO_L23P_T3_33 Sch=eth_mdc
# set_property -dict { PACKAGE_PIN AG12  IOSTANDARD LVCMOS15 } [get_ports { eth_mdio }]; #IO_L23N_T3_33 Sch=eth_mdio
# set_property -dict { PACKAGE_PIN AH24  IOSTANDARD LVCMOS33 } [get_ports { ETH_PHYRST_N }]; #IO_L14N_T2_SRCC_12 Sch=eth_phyrst_n
# set_property -dict { PACKAGE_PIN AK15  IOSTANDARD LVCMOS18 } [get_ports { eth_pme_b }]; #IO_L1N_T0_32 Sch=eth_pmeb
# set_property -dict { PACKAGE_PIN AG10  IOSTANDARD LVCMOS15 } [get_ports { eth_rxck }]; #IO_L13P_T2_MRCC_33 Sch=eth_rx_clk
# set_property -dict { PACKAGE_PIN AH11  IOSTANDARD LVCMOS15 } [get_ports { eth_rxctl }]; #IO_L18P_T2_33 Sch=eth_rx_ctl
# set_property -dict { PACKAGE_PIN AJ14  IOSTANDARD LVCMOS15 } [get_ports { eth_rxd[0] }]; #IO_L21N_T3_DQS_33 Sch=eth_rx_d[0]
# set_property -dict { PACKAGE_PIN AH14  IOSTANDARD LVCMOS15 } [get_ports { eth_rxd[1] }]; #IO_L21P_T3_DQS_33 Sch=eth_rx_d[1]
# set_property -dict { PACKAGE_PIN AK13  IOSTANDARD LVCMOS15 } [get_ports { eth_rxd[2] }]; #IO_L20N_T3_33 Sch=eth_rx_d[2]
# set_property -dict { PACKAGE_PIN AJ13  IOSTANDARD LVCMOS15 } [get_ports { eth_rxd[3] }]; #IO_L22P_T3_33 Sch=eth_rx_d[3]
# set_property -dict { PACKAGE_PIN AE10  IOSTANDARD LVCMOS15 } [get_ports { eth_txck }]; #IO_L14P_T2_SRCC_33 Sch=eth_tx_clk
# set_property -dict { PACKAGE_PIN AJ12  IOSTANDARD LVCMOS15 } [get_ports { eth_txd[0] }]; #IO_L22N_T3_33 Sch=eth_tx_d[0]
# set_property -dict { PACKAGE_PIN AK11  IOSTANDARD LVCMOS15 } [get_ports { eth_txd[1] }]; #IO_L17P_T2_33 Sch=eth_tx_d[1]
# set_property -dict { PACKAGE_PIN AJ11  IOSTANDARD LVCMOS15 } [get_ports { eth_txd[2] }]; #IO_L18N_T2_33 Sch=eth_tx_d[2]
# set_property -dict { PACKAGE_PIN AK10  IOSTANDARD LVCMOS15 } [get_ports { eth_txd[3] }]; #IO_L17N_T2_33 Sch=eth_tx_d[3]
# set_property -dict { PACKAGE_PIN AK14  IOSTANDARD LVCMOS15 } [get_ports { ETH_TX_EN }]; #IO_L20P_T3_33 Sch=eth_tx_en


############################################################################
## UART
############################################################################
set_property -dict { PACKAGE_PIN Y23   IOSTANDARD LVCMOS33 } [get_ports { uart_rx_out }]; #IO_L1P_T0_12 Sch=uart_rx_out
set_property -dict { PACKAGE_PIN Y20   IOSTANDARD LVCMOS33 } [get_ports { uart_tx_in }]; #IO_0_12 Sch=uart_tx_in