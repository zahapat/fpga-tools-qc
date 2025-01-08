onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: shiftreg_queue_shifter_tb ALL signals}
add wave -noupdate /shiftreg_queue_shifter_tb/i_wr_data_valid
add wave -noupdate -radix decimal /shiftreg_queue_shifter_tb/i_wr_data
add wave -noupdate /shiftreg_queue_shifter_tb/i_rd_valid
add wave -noupdate /shiftreg_queue_shifter_tb/o_rd_data_rdy
add wave -noupdate -radix decimal /shiftreg_queue_shifter_tb/o_rd_data
add wave -noupdate /shiftreg_queue_shifter_tb/o_queue_empty
add wave -noupdate /shiftreg_queue_shifter_tb/o_queue_full
add wave -noupdate /shiftreg_queue_shifter_tb/o_queue_full_latched
add wave -noupdate /shiftreg_queue_shifter_tb/o_buffer_full
add wave -noupdate /shiftreg_queue_shifter_tb/o_buffer_empty
add wave -noupdate /shiftreg_queue_shifter_tb/o_data_loss
add wave -noupdate /shiftreg_queue_shifter_tb/clk
add wave -noupdate -divider DUT
add wave -noupdate /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/clk
add wave -noupdate /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/i_wr_data_valid
add wave -noupdate -radix hexadecimal /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/i_wr_data
add wave -noupdate -radix hexadecimal /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/o_rd_data
add wave -noupdate /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/o_data_loss
add wave -noupdate /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/o_buffer_empty
add wave -noupdate /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/o_queue_empty
add wave -noupdate /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/o_buffer_full
add wave -noupdate /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/o_queue_full
add wave -noupdate /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/sl_buffer_full_latched
add wave -noupdate /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/o_queue_full_latched
add wave -noupdate /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_valid_buffer_shreg
add wave -noupdate -radix hexadecimal -childformat {{/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(159) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(158) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(157) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(156) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(155) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(154) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(153) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(152) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(151) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(150) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(149) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(148) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(147) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(146) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(145) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(144) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(143) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(142) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(141) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(140) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(139) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(138) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(137) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(136) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(135) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(134) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(133) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(132) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(131) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(130) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(129) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(128) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(127) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(126) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(125) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(124) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(123) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(122) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(121) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(120) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(119) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(118) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(117) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(116) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(115) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(114) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(113) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(112) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(111) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(110) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(109) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(108) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(107) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(106) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(105) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(104) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(103) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(102) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(101) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(100) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(99) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(98) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(97) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(96) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(95) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(94) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(93) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(92) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(91) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(90) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(89) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(88) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(87) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(86) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(85) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(84) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(83) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(82) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(81) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(80) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(79) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(78) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(77) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(76) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(75) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(74) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(73) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(72) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(71) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(70) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(69) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(68) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(67) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(66) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(65) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(64) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(63) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(62) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(61) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(60) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(59) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(58) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(57) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(56) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(55) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(54) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(53) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(52) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(51) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(50) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(49) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(48) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(47) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(46) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(45) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(44) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(43) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(42) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(41) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(40) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(39) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(38) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(37) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(36) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(35) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(34) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(33) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(32) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(31) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(30) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(29) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(28) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(27) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(26) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(25) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(24) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(23) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(22) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(21) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(20) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(19) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(18) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(17) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(16) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(15) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(14) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(13) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(12) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(11) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(10) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(9) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(8) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(7) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(6) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(5) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(4) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(3) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(2) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(1) -radix hexadecimal} {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(0) -radix hexadecimal}} -subitemconfig {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(159) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(158) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(157) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(156) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(155) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(154) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(153) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(152) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(151) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(150) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(149) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(148) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(147) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(146) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(145) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(144) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(143) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(142) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(141) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(140) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(139) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(138) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(137) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(136) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(135) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(134) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(133) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(132) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(131) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(130) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(129) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(128) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(127) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(126) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(125) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(124) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(123) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(122) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(121) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(120) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(119) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(118) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(117) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(116) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(115) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(114) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(113) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(112) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(111) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(110) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(109) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(108) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(107) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(106) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(105) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(104) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(103) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(102) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(101) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(100) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(99) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(98) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(97) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(96) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(95) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(94) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(93) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(92) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(91) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(90) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(89) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(88) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(87) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(86) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(85) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(84) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(83) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(82) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(81) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(80) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(79) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(78) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(77) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(76) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(75) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(74) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(73) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(72) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(71) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(70) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(69) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(68) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(67) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(66) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(65) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(64) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(63) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(62) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(61) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(60) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(59) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(58) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(57) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(56) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(55) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(54) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(53) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(52) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(51) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(50) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(49) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(48) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(47) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(46) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(45) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(44) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(43) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(42) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(41) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(40) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(39) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(38) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(37) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(36) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(35) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(34) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(33) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(32) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(31) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(30) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(29) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(28) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(27) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(26) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(25) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(24) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(23) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(22) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(21) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(20) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(19) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(18) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(17) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(16) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(15) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(14) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(13) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(12) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(11) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(10) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(9) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(8) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(7) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(6) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(5) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(4) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(3) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(2) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(1) {-height 15 -radix hexadecimal} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg(0) {-height 15 -radix hexadecimal}} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_buffer_shreg
add wave -noupdate -color Salmon -expand -subitemconfig {/shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_valid_queue_shreg(4) {-color Salmon -height 15} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_valid_queue_shreg(3) {-color Salmon -height 15} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_valid_queue_shreg(2) {-color Salmon -height 15} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_valid_queue_shreg(1) {-color Salmon -height 15} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_valid_queue_shreg(0) {-color Salmon -height 15}} /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_valid_queue_shreg
add wave -noupdate -radix hexadecimal /shiftreg_queue_shifter_tb/dut_shiftreg_queue_shifter/slv_data_queue_shreg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {378796 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 428
configure wave -valuecolwidth 297
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {42202596 ps} {42895916 ps}