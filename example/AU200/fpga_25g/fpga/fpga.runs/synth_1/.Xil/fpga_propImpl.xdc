set_property SRC_FILE_INFO {cfile:/home/weigao/PHY-Project/example/AU200/fpga_10g/fpga.xdc rfile:../../../../fpga.xdc id:1} [current_design]
set_property src_info {type:XDC file:1 line:16 export:INPUT save:INPUT read:READ} [current_design]
set_operating_conditions -design_power_budget 160
set_property src_info {type:XDC file:1 line:45 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC BC21 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[0]}]
set_property src_info {type:XDC file:1 line:46 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC BB21 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[1]}]
set_property src_info {type:XDC file:1 line:47 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC BA20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[2]}]
set_property src_info {type:XDC file:1 line:53 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC AL20 IOSTANDARD LVCMOS12} [get_ports reset]
set_property src_info {type:XDC file:1 line:59 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC AN22 IOSTANDARD LVCMOS12} [get_ports {sw[0]}]
set_property src_info {type:XDC file:1 line:60 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC AM19 IOSTANDARD LVCMOS12} [get_ports {sw[1]}]
set_property src_info {type:XDC file:1 line:61 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC AL19 IOSTANDARD LVCMOS12} [get_ports {sw[2]}]
set_property src_info {type:XDC file:1 line:62 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC AP20 IOSTANDARD LVCMOS12} [get_ports {sw[3]}]
set_property src_info {type:XDC file:1 line:68 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC BF18 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports uart_txd]
set_property src_info {type:XDC file:1 line:69 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC BB20 IOSTANDARD LVCMOS12} [get_ports uart_rxd]
set_property src_info {type:XDC file:1 line:90 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC N4  } [get_ports qsfp0_rx1_p] ;# MGTYRXP0_231 GTYE4_CHANNEL_X1Y48 / GTYE4_COMMON_X1Y12
set_property src_info {type:XDC file:1 line:91 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC N3  } [get_ports qsfp0_rx1_n] ;# MGTYRXN0_231 GTYE4_CHANNEL_X1Y48 / GTYE4_COMMON_X1Y12
set_property src_info {type:XDC file:1 line:92 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC N9  } [get_ports qsfp0_tx1_p] ;# MGTYTXP0_231 GTYE4_CHANNEL_X1Y48 / GTYE4_COMMON_X1Y12
set_property src_info {type:XDC file:1 line:93 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC N8  } [get_ports qsfp0_tx1_n] ;# MGTYTXN0_231 GTYE4_CHANNEL_X1Y48 / GTYE4_COMMON_X1Y12
set_property src_info {type:XDC file:1 line:94 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC M2  } [get_ports qsfp0_rx2_p] ;# MGTYRXP1_231 GTYE4_CHANNEL_X1Y49 / GTYE4_COMMON_X1Y12
set_property src_info {type:XDC file:1 line:95 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC M1  } [get_ports qsfp0_rx2_n] ;# MGTYRXN1_231 GTYE4_CHANNEL_X1Y49 / GTYE4_COMMON_X1Y12
set_property src_info {type:XDC file:1 line:96 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC M7  } [get_ports qsfp0_tx2_p] ;# MGTYTXP1_231 GTYE4_CHANNEL_X1Y49 / GTYE4_COMMON_X1Y12
set_property src_info {type:XDC file:1 line:97 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC M6  } [get_ports qsfp0_tx2_n] ;# MGTYTXN1_231 GTYE4_CHANNEL_X1Y49 / GTYE4_COMMON_X1Y12
set_property src_info {type:XDC file:1 line:98 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC L4  } [get_ports qsfp0_rx3_p] ;# MGTYRXP2_231 GTYE4_CHANNEL_X1Y50 / GTYE4_COMMON_X1Y12
set_property src_info {type:XDC file:1 line:99 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC L3  } [get_ports qsfp0_rx3_n] ;# MGTYRXN2_231 GTYE4_CHANNEL_X1Y50 / GTYE4_COMMON_X1Y12
set_property src_info {type:XDC file:1 line:100 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC L9  } [get_ports qsfp0_tx3_p] ;# MGTYTXP2_231 GTYE4_CHANNEL_X1Y50 / GTYE4_COMMON_X1Y12
set_property src_info {type:XDC file:1 line:101 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC L8  } [get_ports qsfp0_tx3_n] ;# MGTYTXN2_231 GTYE4_CHANNEL_X1Y50 / GTYE4_COMMON_X1Y12
set_property src_info {type:XDC file:1 line:102 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC K2  } [get_ports qsfp0_rx4_p] ;# MGTYRXP3_231 GTYE4_CHANNEL_X1Y51 / GTYE4_COMMON_X1Y12
set_property src_info {type:XDC file:1 line:103 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC K1  } [get_ports qsfp0_rx4_n] ;# MGTYRXN3_231 GTYE4_CHANNEL_X1Y51 / GTYE4_COMMON_X1Y12
set_property src_info {type:XDC file:1 line:104 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC K7  } [get_ports qsfp0_tx4_p] ;# MGTYTXP3_231 GTYE4_CHANNEL_X1Y51 / GTYE4_COMMON_X1Y12
set_property src_info {type:XDC file:1 line:105 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC K6  } [get_ports qsfp0_tx4_n] ;# MGTYTXN3_231 GTYE4_CHANNEL_X1Y51 / GTYE4_COMMON_X1Y12
set_property src_info {type:XDC file:1 line:108 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC K11 } [get_ports qsfp0_mgt_refclk_1_p] ;# MGTREFCLK1P_231 from U9.18
set_property src_info {type:XDC file:1 line:109 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC K10 } [get_ports qsfp0_mgt_refclk_1_n] ;# MGTREFCLK1N_231 from U9.17
set_property src_info {type:XDC file:1 line:110 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC BE16 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp0_modsell]
set_property src_info {type:XDC file:1 line:111 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC BE17 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp0_resetl]
set_property src_info {type:XDC file:1 line:112 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC BE20 IOSTANDARD LVCMOS12 PULLUP true} [get_ports qsfp0_modprsl]
set_property src_info {type:XDC file:1 line:113 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC BE21 IOSTANDARD LVCMOS12 PULLUP true} [get_ports qsfp0_intl]
set_property src_info {type:XDC file:1 line:114 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC BD18 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp0_lpmode]
set_property src_info {type:XDC file:1 line:115 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC AT22 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp0_refclk_reset]
set_property src_info {type:XDC file:1 line:116 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC AT20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {qsfp0_fs[0]}]
set_property src_info {type:XDC file:1 line:117 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC AU22 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {qsfp0_fs[1]}]
set_property src_info {type:XDC file:1 line:133 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC U4  } [get_ports qsfp1_rx1_p] ;# MGTYRXP0_230 GTYE4_CHANNEL_X1Y44 / GTYE4_COMMON_X1Y11
set_property src_info {type:XDC file:1 line:134 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC U3  } [get_ports qsfp1_rx1_n] ;# MGTYRXN0_230 GTYE4_CHANNEL_X1Y44 / GTYE4_COMMON_X1Y11
set_property src_info {type:XDC file:1 line:135 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC U9  } [get_ports qsfp1_tx1_p] ;# MGTYTXP0_230 GTYE4_CHANNEL_X1Y44 / GTYE4_COMMON_X1Y11
set_property src_info {type:XDC file:1 line:136 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC U8  } [get_ports qsfp1_tx1_n] ;# MGTYTXN0_230 GTYE4_CHANNEL_X1Y44 / GTYE4_COMMON_X1Y11
set_property src_info {type:XDC file:1 line:137 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC T2  } [get_ports qsfp1_rx2_p] ;# MGTYRXP1_230 GTYE4_CHANNEL_X1Y45 / GTYE4_COMMON_X1Y11
set_property src_info {type:XDC file:1 line:138 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC T1  } [get_ports qsfp1_rx2_n] ;# MGTYRXN1_230 GTYE4_CHANNEL_X1Y45 / GTYE4_COMMON_X1Y11
set_property src_info {type:XDC file:1 line:139 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC T7  } [get_ports qsfp1_tx2_p] ;# MGTYTXP1_230 GTYE4_CHANNEL_X1Y45 / GTYE4_COMMON_X1Y11
set_property src_info {type:XDC file:1 line:140 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC T6  } [get_ports qsfp1_tx2_n] ;# MGTYTXN1_230 GTYE4_CHANNEL_X1Y45 / GTYE4_COMMON_X1Y11
set_property src_info {type:XDC file:1 line:141 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC R4  } [get_ports qsfp1_rx3_p] ;# MGTYRXP2_230 GTYE4_CHANNEL_X1Y46 / GTYE4_COMMON_X1Y11
set_property src_info {type:XDC file:1 line:142 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC R3  } [get_ports qsfp1_rx3_n] ;# MGTYRXN2_230 GTYE4_CHANNEL_X1Y46 / GTYE4_COMMON_X1Y11
set_property src_info {type:XDC file:1 line:143 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC R9  } [get_ports qsfp1_tx3_p] ;# MGTYTXP2_230 GTYE4_CHANNEL_X1Y46 / GTYE4_COMMON_X1Y11
set_property src_info {type:XDC file:1 line:144 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC R8  } [get_ports qsfp1_tx3_n] ;# MGTYTXN2_230 GTYE4_CHANNEL_X1Y46 / GTYE4_COMMON_X1Y11
set_property src_info {type:XDC file:1 line:145 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC P2  } [get_ports qsfp1_rx4_p] ;# MGTYRXP3_230 GTYE4_CHANNEL_X1Y47 / GTYE4_COMMON_X1Y11
set_property src_info {type:XDC file:1 line:146 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC P1  } [get_ports qsfp1_rx4_n] ;# MGTYRXN3_230 GTYE4_CHANNEL_X1Y47 / GTYE4_COMMON_X1Y11
set_property src_info {type:XDC file:1 line:147 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC P7  } [get_ports qsfp1_tx4_p] ;# MGTYTXP3_230 GTYE4_CHANNEL_X1Y47 / GTYE4_COMMON_X1Y11
set_property src_info {type:XDC file:1 line:148 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC P6  } [get_ports qsfp1_tx4_n] ;# MGTYTXN3_230 GTYE4_CHANNEL_X1Y47 / GTYE4_COMMON_X1Y11
set_property src_info {type:XDC file:1 line:151 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC P11 } [get_ports qsfp1_mgt_refclk_1_p] ;# MGTREFCLK1P_230 from U12.18
set_property src_info {type:XDC file:1 line:152 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC P10 } [get_ports qsfp1_mgt_refclk_1_n] ;# MGTREFCLK1N_230 from U12.17
set_property src_info {type:XDC file:1 line:153 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC AY20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp1_modsell]
set_property src_info {type:XDC file:1 line:154 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC BC18 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp1_resetl]
set_property src_info {type:XDC file:1 line:155 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC BC19 IOSTANDARD LVCMOS12 PULLUP true} [get_ports qsfp1_modprsl]
set_property src_info {type:XDC file:1 line:156 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC AV21 IOSTANDARD LVCMOS12 PULLUP true} [get_ports qsfp1_intl]
set_property src_info {type:XDC file:1 line:157 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC AV22 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp1_lpmode]
set_property src_info {type:XDC file:1 line:158 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC AR21 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp1_refclk_reset]
set_property src_info {type:XDC file:1 line:159 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC AR22 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {qsfp1_fs[0]}]
set_property src_info {type:XDC file:1 line:160 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC AU20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {qsfp1_fs[1]}]
set_property src_info {type:XDC file:1 line:178 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC BF20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports i2c_scl]
set_property src_info {type:XDC file:1 line:179 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {LOC BF17 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports i2c_sda]
