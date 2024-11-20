# XDC constraints for the Xilinx Alveo U200 board
# part: xcu200-fsgd2104-2-e

# General configuration
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]
set_property BITSTREAM.CONFIG.CONFIGFALLBACK ENABLE [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN DISABLE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 63.8 [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLUP [current_design]

set_operating_conditions -design_power_budget 160

# System clocks
# 300 MHz (DDR 0)
#set_property -dict {LOC AY37 IOSTANDARD LVDS} [get_ports clk_300mhz_0_p]
#set_property -dict {LOC AY38 IOSTANDARD LVDS} [get_ports clk_300mhz_0_n]
#create_clock -period 3.333 -name clk_300mhz_0 [get_ports clk_300mhz_0_p]

# 300 MHz (DDR 1)
#set_property -dict {LOC AW20 IOSTANDARD LVDS} [get_ports clk_300mhz_1_p]
#set_property -dict {LOC AW19 IOSTANDARD LVDS} [get_ports clk_300mhz_1_n]
#create_clock -period 3.333 -name clk_300mhz_1 [get_ports clk_300mhz_1_p]

# 300 MHz (DDR 2)
#set_property -dict {LOC F32  IOSTANDARD LVDS} [get_ports clk_300mhz_2_p]
#set_property -dict {LOC E32  IOSTANDARD LVDS} [get_ports clk_300mhz_2_n]
#create_clock -period 3.333 -name clk_300mhz_2 [get_ports clk_300mhz_2_p]

# 300 MHz (DDR 3)
#set_property -dict {LOC J16  IOSTANDARD LVDS} [get_ports clk_300mhz_3_p]
#set_property -dict {LOC H16  IOSTANDARD LVDS} [get_ports clk_300mhz_3_n]
#create_clock -period 3.333 -name clk_300mhz_3 [get_ports clk_300mhz_3_p]

# SI570 user clock
#set_property -dict {LOC AU19 IOSTANDARD LVDS} [get_ports clk_user_p]
#set_property -dict {LOC AV19 IOSTANDARD LVDS} [get_ports clk_user_n]
#create_clock -period 6.400 -name clk_user [get_ports clk_user_p]

# LEDs
set_property -dict {LOC BC21 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[0]}]
set_property -dict {LOC BB21 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[1]}]
set_property -dict {LOC BA20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[2]}]

set_false_path -to [get_ports {led[*]}]
set_output_delay 0.000 [get_ports {led[*]}]

# Reset button
set_property -dict {LOC AL20 IOSTANDARD LVCMOS12} [get_ports reset]

set_false_path -from [get_ports reset]
set_input_delay 0.000 [get_ports reset]

# DIP switches
set_property -dict {LOC AN22 IOSTANDARD LVCMOS12} [get_ports {sw[0]}]
set_property -dict {LOC AM19 IOSTANDARD LVCMOS12} [get_ports {sw[1]}]
set_property -dict {LOC AL19 IOSTANDARD LVCMOS12} [get_ports {sw[2]}]
set_property -dict {LOC AP20 IOSTANDARD LVCMOS12} [get_ports {sw[3]}]

set_false_path -from [get_ports {sw[*]}]
set_input_delay 0.000 [get_ports {sw[*]}]

# UART
set_property PACKAGE_PIN BF18 [get_ports uart_txd]
set_property IOSTANDARD LVCMOS12 [get_ports uart_txd]
set_property -dict {LOC BB20 IOSTANDARD LVCMOS12} [get_ports uart_rxd]

#set_false_path -to [get_ports {uart_txd}]
#set_output_delay 0 [get_ports {uart_txd}]
#set_false_path -from [get_ports {uart_rxd}]
#set_input_delay 0 [get_ports {uart_rxd}]

# BMC
#set_property -dict {LOC AR20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 4} [get_ports {msp_gpio[0]}]
#set_property -dict {LOC AM20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 4} [get_ports {msp_gpio[1]}]
#set_property -dict {LOC AM21 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 4} [get_ports {msp_gpio[2]}]
#set_property -dict {LOC AN21 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 4} [get_ports {msp_gpio[3]}]
#set_property -dict {LOC BB19 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 4} [get_ports {msp_uart_txd}]
#set_property -dict {LOC BA19 IOSTANDARD LVCMOS12} [get_ports {msp_uart_rxd}]

#set_false_path -to [get_ports {msp_uart_txd}]
#set_output_delay 0 [get_ports {msp_uart_txd}]
#set_false_path -from [get_ports {msp_gpio[*] msp_uart_rxd}]
#set_input_delay 0 [get_ports {msp_gpio[*] msp_uart_rxd}]

# QSFP28 Interfaces
set_property -dict {LOC N4} [get_ports qsfp0_rx1_p]
set_property -dict {LOC N3} [get_ports qsfp0_rx1_n]
set_property -dict {LOC N9} [get_ports qsfp0_tx1_p]
set_property -dict {LOC N8} [get_ports qsfp0_tx1_n]
set_property -dict {LOC M2} [get_ports qsfp0_rx2_p]
set_property -dict {LOC M1} [get_ports qsfp0_rx2_n]
set_property -dict {LOC M7} [get_ports qsfp0_tx2_p]
set_property -dict {LOC M6} [get_ports qsfp0_tx2_n]
set_property -dict {LOC L4} [get_ports qsfp0_rx3_p]
set_property -dict {LOC L3} [get_ports qsfp0_rx3_n]
set_property -dict {LOC L9} [get_ports qsfp0_tx3_p]
set_property -dict {LOC L8} [get_ports qsfp0_tx3_n]
set_property -dict {LOC K2} [get_ports qsfp0_rx4_p]
set_property -dict {LOC K1} [get_ports qsfp0_rx4_n]
set_property -dict {LOC K7} [get_ports qsfp0_tx4_p]
set_property -dict {LOC K6} [get_ports qsfp0_tx4_n]
#set_property -dict {LOC M11 } [get_ports qsfp0_mgt_refclk_0_p] ;# MGTREFCLK0P_231 from U14.4 via U43.13
#set_property -dict {LOC M10 } [get_ports qsfp0_mgt_refclk_0_n] ;# MGTREFCLK0N_231 from U14.5 via U43.14
set_property -dict {LOC K11} [get_ports qsfp0_mgt_refclk_1_p]
set_property -dict {LOC K10} [get_ports qsfp0_mgt_refclk_1_n]
set_property -dict {LOC BE16 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp0_modsell]
set_property -dict {LOC BE17 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp0_resetl]
set_property PACKAGE_PIN BE20 [get_ports qsfp0_modprsl]
set_property IOSTANDARD LVCMOS12 [get_ports qsfp0_modprsl]
set_property PULLTYPE PULLUP [get_ports qsfp0_modprsl]
set_property PACKAGE_PIN BE21 [get_ports qsfp0_intl]
set_property IOSTANDARD LVCMOS12 [get_ports qsfp0_intl]
set_property PULLTYPE PULLUP [get_ports qsfp0_intl]
set_property -dict {LOC BD18 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp0_lpmode]
set_property -dict {LOC AT22 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp0_refclk_reset]
set_property -dict {LOC AT20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {qsfp0_fs[0]}]
set_property -dict {LOC AU22 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {qsfp0_fs[1]}]

# 156.25 MHz MGT reference clock (from SI570)
#create_clock -period 6.400 -name qsfp0_mgt_refclk_0 [get_ports qsfp0_mgt_refclk_0_p]

# 156.25 MHz MGT reference clock (from SI5335, FS = 0b01)
#create_clock -period 6.400 -name qsfp0_mgt_refclk_1 [get_ports qsfp0_mgt_refclk_1_p]

# 161.1328125 MHz MGT reference clock (from SI5335, FS = 0b10)
create_clock -period 6.206 -name qsfp0_mgt_refclk_1 [get_ports qsfp0_mgt_refclk_1_p]

set_false_path -to [get_ports {qsfp0_modsell qsfp0_resetl qsfp0_lpmode qsfp0_refclk_reset {qsfp0_fs[*]}}]
set_output_delay 0.000 [get_ports {qsfp0_modsell qsfp0_resetl qsfp0_lpmode qsfp0_refclk_reset {qsfp0_fs[*]}}]
set_false_path -from [get_ports {qsfp0_modprsl qsfp0_intl}]
set_input_delay 0.000 [get_ports {qsfp0_modprsl qsfp0_intl}]

set_property -dict {LOC U4} [get_ports qsfp1_rx1_p]
set_property -dict {LOC U3} [get_ports qsfp1_rx1_n]
set_property -dict {LOC U9} [get_ports qsfp1_tx1_p]
set_property -dict {LOC U8} [get_ports qsfp1_tx1_n]
set_property -dict {LOC T2} [get_ports qsfp1_rx2_p]
set_property -dict {LOC T1} [get_ports qsfp1_rx2_n]
set_property -dict {LOC T7} [get_ports qsfp1_tx2_p]
set_property -dict {LOC T6} [get_ports qsfp1_tx2_n]
set_property -dict {LOC R4} [get_ports qsfp1_rx3_p]
set_property -dict {LOC R3} [get_ports qsfp1_rx3_n]
set_property -dict {LOC R9} [get_ports qsfp1_tx3_p]
set_property -dict {LOC R8} [get_ports qsfp1_tx3_n]
set_property -dict {LOC P2} [get_ports qsfp1_rx4_p]
set_property -dict {LOC P1} [get_ports qsfp1_rx4_n]
set_property -dict {LOC P7} [get_ports qsfp1_tx4_p]
set_property -dict {LOC P6} [get_ports qsfp1_tx4_n]
#set_property -dict {LOC T11 } [get_ports qsfp1_mgt_refclk_0_p] ;# MGTREFCLK0P_230 from U14.4 via U43.15
#set_property -dict {LOC T10 } [get_ports qsfp1_mgt_refclk_0_n] ;# MGTREFCLK0N_230 from U14.5 via U43.16
set_property -dict {LOC P11} [get_ports qsfp1_mgt_refclk_1_p]
set_property -dict {LOC P10} [get_ports qsfp1_mgt_refclk_1_n]
set_property -dict {LOC AY20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp1_modsell]
set_property -dict {LOC BC18 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp1_resetl]
set_property PACKAGE_PIN BC19 [get_ports qsfp1_modprsl]
set_property IOSTANDARD LVCMOS12 [get_ports qsfp1_modprsl]
set_property PULLTYPE PULLUP [get_ports qsfp1_modprsl]
set_property PACKAGE_PIN AV21 [get_ports qsfp1_intl]
set_property IOSTANDARD LVCMOS12 [get_ports qsfp1_intl]
set_property PULLTYPE PULLUP [get_ports qsfp1_intl]
set_property -dict {LOC AV22 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp1_lpmode]
set_property -dict {LOC AR21 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp1_refclk_reset]
set_property -dict {LOC AR22 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {qsfp1_fs[0]}]
set_property -dict {LOC AU20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {qsfp1_fs[1]}]

# 156.25 MHz MGT reference clock (from SI570)
#create_clock -period 6.400 -name qsfp1_mgt_refclk_0 [get_ports qsfp1_mgt_refclk_0_p]

# 156.25 MHz MGT reference clock (from SI5335, FS = 0b01)
#create_clock -period 6.400 -name qsfp1_mgt_refclk_1 [get_ports qsfp1_mgt_refclk_1_p]

# 161.1328125 MHz MGT reference clock (from SI5335, FS = 0b10)
create_clock -period 6.206 -name qsfp1_mgt_refclk_1 [get_ports qsfp1_mgt_refclk_1_p]

set_false_path -to [get_ports {qsfp1_modsell qsfp1_resetl qsfp1_lpmode qsfp1_refclk_reset {qsfp1_fs[*]}}]
set_output_delay 0.000 [get_ports {qsfp1_modsell qsfp1_resetl qsfp1_lpmode qsfp1_refclk_reset {qsfp1_fs[*]}}]
set_false_path -from [get_ports {qsfp1_modprsl qsfp1_intl}]
set_input_delay 0.000 [get_ports {qsfp1_modprsl qsfp1_intl}]

# I2C interface
#set_property -dict {LOC BF19 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports i2c_mux_reset]
set_property -dict {LOC BF20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports i2c_scl]
set_property -dict {LOC BF17 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports i2c_sda]

set_false_path -to [get_ports {i2c_sda i2c_scl}]
set_output_delay 0.000 [get_ports {i2c_sda i2c_scl}]
set_false_path -from [get_ports {i2c_sda i2c_scl}]
set_input_delay 0.000 [get_ports {i2c_sda i2c_scl}]

# PCIe Interface
#set_property -dict {LOC AF2  } [get_ports {pcie_rx_p[0]}]  ;# MGTYRXP3_227 GTYE4_CHANNEL_X1Y35 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AF1  } [get_ports {pcie_rx_n[0]}]  ;# MGTYRXN3_227 GTYE4_CHANNEL_X1Y35 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AF7  } [get_ports {pcie_tx_p[0]}]  ;# MGTYTXP3_227 GTYE4_CHANNEL_X1Y35 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AF6  } [get_ports {pcie_tx_n[0]}]  ;# MGTYTXN3_227 GTYE4_CHANNEL_X1Y35 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AG4  } [get_ports {pcie_rx_p[1]}]  ;# MGTYRXP2_227 GTYE4_CHANNEL_X1Y34 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AG3  } [get_ports {pcie_rx_n[1]}]  ;# MGTYRXN2_227 GTYE4_CHANNEL_X1Y34 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AG9  } [get_ports {pcie_tx_p[1]}]  ;# MGTYTXP2_227 GTYE4_CHANNEL_X1Y34 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AG8  } [get_ports {pcie_tx_n[1]}]  ;# MGTYTXN2_227 GTYE4_CHANNEL_X1Y34 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AH2  } [get_ports {pcie_rx_p[2]}]  ;# MGTYRXP1_227 GTYE4_CHANNEL_X1Y33 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AH1  } [get_ports {pcie_rx_n[2]}]  ;# MGTYRXN1_227 GTYE4_CHANNEL_X1Y33 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AH7  } [get_ports {pcie_tx_p[2]}]  ;# MGTYTXP1_227 GTYE4_CHANNEL_X1Y33 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AH6  } [get_ports {pcie_tx_n[2]}]  ;# MGTYTXN1_227 GTYE4_CHANNEL_X1Y33 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AJ4  } [get_ports {pcie_rx_p[3]}]  ;# MGTYRXP0_227 GTYE4_CHANNEL_X1Y32 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AJ3  } [get_ports {pcie_rx_n[3]}]  ;# MGTYRXN0_227 GTYE4_CHANNEL_X1Y32 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AJ9  } [get_ports {pcie_tx_p[3]}]  ;# MGTYTXP0_227 GTYE4_CHANNEL_X1Y32 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AJ8  } [get_ports {pcie_tx_n[3]}]  ;# MGTYTXN0_227 GTYE4_CHANNEL_X1Y32 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AK2  } [get_ports {pcie_rx_p[4]}]  ;# MGTYRXP3_226 GTYE4_CHANNEL_X1Y31 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AK1  } [get_ports {pcie_rx_n[4]}]  ;# MGTYRXN3_226 GTYE4_CHANNEL_X1Y31 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AK7  } [get_ports {pcie_tx_p[4]}]  ;# MGTYTXP3_226 GTYE4_CHANNEL_X1Y31 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AK6  } [get_ports {pcie_tx_n[4]}]  ;# MGTYTXN3_226 GTYE4_CHANNEL_X1Y31 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AL4  } [get_ports {pcie_rx_p[5]}]  ;# MGTYRXP2_226 GTYE4_CHANNEL_X1Y30 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AL3  } [get_ports {pcie_rx_n[5]}]  ;# MGTYRXN2_226 GTYE4_CHANNEL_X1Y30 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AL9  } [get_ports {pcie_tx_p[5]}]  ;# MGTYTXP2_226 GTYE4_CHANNEL_X1Y30 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AL8  } [get_ports {pcie_tx_n[5]}]  ;# MGTYTXN2_226 GTYE4_CHANNEL_X1Y30 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AM2  } [get_ports {pcie_rx_p[6]}]  ;# MGTYRXP1_226 GTYE4_CHANNEL_X1Y29 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AM1  } [get_ports {pcie_rx_n[6]}]  ;# MGTYRXN1_226 GTYE4_CHANNEL_X1Y29 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AM7  } [get_ports {pcie_tx_p[6]}]  ;# MGTYTXP1_226 GTYE4_CHANNEL_X1Y29 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AM6  } [get_ports {pcie_tx_n[6]}]  ;# MGTYTXN1_226 GTYE4_CHANNEL_X1Y29 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AN4  } [get_ports {pcie_rx_p[7]}]  ;# MGTYRXP0_226 GTYE4_CHANNEL_X1Y28 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AN3  } [get_ports {pcie_rx_n[7]}]  ;# MGTYRXN0_226 GTYE4_CHANNEL_X1Y28 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AN9  } [get_ports {pcie_tx_p[7]}]  ;# MGTYTXP0_226 GTYE4_CHANNEL_X1Y28 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AN8  } [get_ports {pcie_tx_n[7]}]  ;# MGTYTXN0_226 GTYE4_CHANNEL_X1Y28 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AP2  } [get_ports {pcie_rx_p[8]}]  ;# MGTYRXP3_225 GTYE4_CHANNEL_X1Y27 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AP1  } [get_ports {pcie_rx_n[8]}]  ;# MGTYRXN3_225 GTYE4_CHANNEL_X1Y27 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AP7  } [get_ports {pcie_tx_p[8]}]  ;# MGTYTXP3_225 GTYE4_CHANNEL_X1Y27 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AP6  } [get_ports {pcie_tx_n[8]}]  ;# MGTYTXN3_225 GTYE4_CHANNEL_X1Y27 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AR4  } [get_ports {pcie_rx_p[9]}]  ;# MGTYRXP2_225 GTYE4_CHANNEL_X1Y26 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AR3  } [get_ports {pcie_rx_n[9]}]  ;# MGTYRXN2_225 GTYE4_CHANNEL_X1Y26 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AR9  } [get_ports {pcie_tx_p[9]}]  ;# MGTYTXP2_225 GTYE4_CHANNEL_X1Y26 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AR8  } [get_ports {pcie_tx_n[9]}]  ;# MGTYTXN2_225 GTYE4_CHANNEL_X1Y26 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AT2  } [get_ports {pcie_rx_p[10]}] ;# MGTYRXP1_225 GTYE4_CHANNEL_X1Y25 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AT1  } [get_ports {pcie_rx_n[10]}] ;# MGTYRXN1_225 GTYE4_CHANNEL_X1Y25 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AT7  } [get_ports {pcie_tx_p[10]}] ;# MGTYTXP1_225 GTYE4_CHANNEL_X1Y25 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AT6  } [get_ports {pcie_tx_n[10]}] ;# MGTYTXN1_225 GTYE4_CHANNEL_X1Y25 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AU4  } [get_ports {pcie_rx_p[11]}] ;# MGTYRXP0_225 GTYE4_CHANNEL_X1Y24 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AU3  } [get_ports {pcie_rx_n[11]}] ;# MGTYRXN0_225 GTYE4_CHANNEL_X1Y24 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AU9  } [get_ports {pcie_tx_p[11]}] ;# MGTYTXP0_225 GTYE4_CHANNEL_X1Y24 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AU8  } [get_ports {pcie_tx_n[11]}] ;# MGTYTXN0_225 GTYE4_CHANNEL_X1Y24 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AV2  } [get_ports {pcie_rx_p[12]}] ;# MGTYRXP3_224 GTYE4_CHANNEL_X1Y23 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AV1  } [get_ports {pcie_rx_n[12]}] ;# MGTYRXN3_224 GTYE4_CHANNEL_X1Y23 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AV7  } [get_ports {pcie_tx_p[12]}] ;# MGTYTXP3_224 GTYE4_CHANNEL_X1Y23 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AV6  } [get_ports {pcie_tx_n[12]}] ;# MGTYTXN3_224 GTYE4_CHANNEL_X1Y23 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AW4  } [get_ports {pcie_rx_p[13]}] ;# MGTYRXP2_224 GTYE4_CHANNEL_X1Y22 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AW3  } [get_ports {pcie_rx_n[13]}] ;# MGTYRXN2_224 GTYE4_CHANNEL_X1Y22 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BB5  } [get_ports {pcie_tx_p[13]}] ;# MGTYTXP2_224 GTYE4_CHANNEL_X1Y22 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BB4  } [get_ports {pcie_tx_n[13]}] ;# MGTYTXN2_224 GTYE4_CHANNEL_X1Y22 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BA2  } [get_ports {pcie_rx_p[14]}] ;# MGTYRXP1_224 GTYE4_CHANNEL_X1Y21 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BA1  } [get_ports {pcie_rx_n[14]}] ;# MGTYRXN1_224 GTYE4_CHANNEL_X1Y21 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BD5  } [get_ports {pcie_tx_p[14]}] ;# MGTYTXP1_224 GTYE4_CHANNEL_X1Y21 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BD4  } [get_ports {pcie_tx_n[14]}] ;# MGTYTXN1_224 GTYE4_CHANNEL_X1Y21 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BC2  } [get_ports {pcie_rx_p[15]}] ;# MGTYRXP0_224 GTYE4_CHANNEL_X1Y20 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BC1  } [get_ports {pcie_rx_n[15]}] ;# MGTYRXN0_224 GTYE4_CHANNEL_X1Y20 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BF5  } [get_ports {pcie_tx_p[15]}] ;# MGTYTXP0_224 GTYE4_CHANNEL_X1Y20 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BF4  } [get_ports {pcie_tx_n[15]}] ;# MGTYTXN0_224 GTYE4_CHANNEL_X1Y20 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AM11 } [get_ports pcie_refclk_p] ;# MGTREFCLK0P_226
#set_property -dict {LOC AM10 } [get_ports pcie_refclk_n] ;# MGTREFCLK0N_226
#set_property -dict {LOC BD21 IOSTANDARD LVCMOS12 PULLUP true} [get_ports pcie_reset_n]

# 100 MHz MGT reference clock
#create_clock -period 10 -name pcie_mgt_refclk_1 [get_ports pcie_refclk_p]

#set_false_path -from [get_ports {pcie_reset_n}]
#set_input_delay 0 [get_ports {pcie_reset_n}]



set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[32]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[24]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[18]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[20]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[22]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[26]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[28]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[30]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[34]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[36]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[38]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[40]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[42]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[44]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[46]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[48]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[50]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[52]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[54]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[56]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[58]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[60]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[62]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[7]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[0]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[2]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[4]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[6]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[10]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[16]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[14]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[12]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[33]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[25]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[21]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[19]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[23]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[27]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[29]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[31]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[35]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[37]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[39]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[41]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[43]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[45]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[47]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[49]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[51]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[53]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[55]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[57]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[59]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[61]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[63]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[9]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[1]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[3]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[5]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[8]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[17]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[15]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[11]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[13]}]
set_property MARK_DEBUG true [get_nets qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req_valid]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[37]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[1]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[47]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[61]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[63]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[45]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[31]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[57]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[59]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[53]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[55]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[49]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[51]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[29]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[35]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[33]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[39]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[43]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[41]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[15]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[13]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[19]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[17]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[23]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[21]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[27]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[25]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[3]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[5]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[8]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[9]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[11]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[12]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[2]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[4]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[0]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[14]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[28]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[30]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[56]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[58]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[52]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[54]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[44]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[46]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[60]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[62]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[48]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[50]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[34]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[32]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[38]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[36]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[42]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[40]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[18]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[16]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[22]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[20]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[26]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[24]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[6]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[7]}]
set_property MARK_DEBUG true [get_nets {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[10]}]
set_property MARK_DEBUG true [get_nets qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rresp_valid]
set_property MARK_DEBUG true [get_nets qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rreq_valid]
create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list {qsfp0_phy_1_inst/xcvr.eth_xcvr_gt_full_inst/inst/gen_gtwizard_gtye4_top.eth_xcvr_gt_full_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_tx_user_clocking_internal.gen_single_instance.gtwiz_userclk_tx_inst/gtwiz_userclk_tx_usrclk2_out[0]}]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 64 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[0]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[1]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[2]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[3]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[4]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[5]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[6]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[7]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[8]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[9]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[10]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[11]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[12]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[13]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[14]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[15]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[16]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[17]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[18]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[19]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[20]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[21]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[22]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[23]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[24]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[25]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[26]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[27]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[28]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[29]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[30]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[31]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[32]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[33]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[34]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[35]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[36]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[37]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[38]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[39]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[40]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[41]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[42]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[43]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[44]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[45]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[46]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[47]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[48]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[49]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[50]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[51]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[52]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[53]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[54]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[55]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[56]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[57]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[58]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[59]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[60]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[61]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[62]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rx_ipg_data[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 64 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[0]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[1]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[2]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[3]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[4]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[5]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[6]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[7]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[8]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[9]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[10]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[11]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[12]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[13]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[14]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[15]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[16]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[17]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[18]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[19]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[20]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[21]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[22]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[23]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[24]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[25]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[26]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[27]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[28]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[29]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[30]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[31]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[32]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[33]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[34]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[35]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[36]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[37]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[38]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[39]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[40]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[41]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[42]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[43]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[44]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[45]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[46]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[47]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[48]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[49]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[50]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[51]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[52]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[53]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[54]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[55]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[56]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[57]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[58]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[59]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[60]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[61]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[62]} {qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 1 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rreq_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 1 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list qsfp0_phy_1_inst/phy_inst/eth_phy_10g_rx_inst/inst_ipg_rx/rresp_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list qsfp0_phy_1_inst/phy_inst/eth_phy_10g_tx_inst/inst_ipg_tx/tx_ipg_req_valid]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_gtwiz_userclk_tx_usrclk2_out[0]]
