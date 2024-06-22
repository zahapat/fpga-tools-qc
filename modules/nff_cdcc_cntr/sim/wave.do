onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: nff_cdcc_tb ALL signals}
add wave -noupdate /nff_cdcc_cntr_tb/rst_write
add wave -noupdate /nff_cdcc_cntr_tb/clk_write
add wave -noupdate /nff_cdcc_cntr_tb/wr_en
add wave -noupdate /nff_cdcc_cntr_tb/wr_ready
add wave -noupdate /nff_cdcc_cntr_tb/rst_read
add wave -noupdate /nff_cdcc_cntr_tb/clk_read
add wave -noupdate /nff_cdcc_cntr_tb/rd_valid
add wave -noupdate /nff_cdcc_cntr_tb/rd_data
add wave -noupdate /nff_cdcc_cntr_tb/sl_detector_clk
add wave -noupdate /nff_cdcc_cntr_tb/slv_detector_qubit
add wave -noupdate /nff_cdcc_cntr_tb/REAL_FREQ_WRITE
add wave -noupdate /nff_cdcc_cntr_tb/REAL_FREQ_READ
add wave -noupdate /nff_cdcc_cntr_tb/TIME_FREQ_WRITE_PERIOD_NS
add wave -noupdate /nff_cdcc_cntr_tb/BYPASS
add wave -noupdate /nff_cdcc_cntr_tb/ASYNC_FLOPS_CNT
add wave -noupdate /nff_cdcc_cntr_tb/CNTR_WIDTH
add wave -noupdate /nff_cdcc_cntr_tb/FLOPS_BEFORE_CROSSING_CNT
add wave -noupdate /nff_cdcc_cntr_tb/WR_READY_DEASSERTED_CYCLES
add wave -noupdate /nff_cdcc_cntr_tb/REAL_NEW_QUBIT_78MHz_HZ
add wave -noupdate /nff_cdcc_cntr_tb/SPCM_OUTPUT_PULSE_DUR
add wave -noupdate /nff_cdcc_cntr_tb/SPCM_DEAD_TIME_DUR
add wave -noupdate -divider DUT
add wave -noupdate /nff_cdcc_cntr_tb/dut_nff_cdcc_cntr/BYPASS
add wave -noupdate /nff_cdcc_cntr_tb/dut_nff_cdcc_cntr/ASYNC_FLOPS_CNT
add wave -noupdate /nff_cdcc_cntr_tb/dut_nff_cdcc_cntr/CNTR_WIDTH
add wave -noupdate /nff_cdcc_cntr_tb/dut_nff_cdcc_cntr/FLOPS_BEFORE_CROSSING_CNT
add wave -noupdate /nff_cdcc_cntr_tb/dut_nff_cdcc_cntr/WR_READY_DEASSERTED_CYCLES
add wave -noupdate /nff_cdcc_cntr_tb/dut_nff_cdcc_cntr/clk_write
add wave -noupdate /nff_cdcc_cntr_tb/dut_nff_cdcc_cntr/wr_en
add wave -noupdate /nff_cdcc_cntr_tb/dut_nff_cdcc_cntr/wr_ready
add wave -noupdate /nff_cdcc_cntr_tb/dut_nff_cdcc_cntr/clk_read
add wave -noupdate /nff_cdcc_cntr_tb/dut_nff_cdcc_cntr/rd_valid
add wave -noupdate /nff_cdcc_cntr_tb/dut_nff_cdcc_cntr/rd_data
add wave -noupdate /nff_cdcc_cntr_tb/dut_nff_cdcc_cntr/slv_data_to_cross_latched
add wave -noupdate /nff_cdcc_cntr_tb/dut_nff_cdcc_cntr/slv_data_to_cross_2d
add wave -noupdate /nff_cdcc_cntr_tb/dut_nff_cdcc_cntr/slv_data_asyncff_2d
add wave -noupdate /nff_cdcc_cntr_tb/dut_nff_cdcc_cntr/slv_data_synchronized
add wave -noupdate /nff_cdcc_cntr_tb/dut_nff_cdcc_cntr/slv_data_synchronized_p1
add wave -noupdate /nff_cdcc_cntr_tb/dut_nff_cdcc_cntr/sl_wr_ready
add wave -noupdate /nff_cdcc_cntr_tb/dut_nff_cdcc_cntr/sl_wr_busy
add wave -noupdate /nff_cdcc_cntr_tb/dut_nff_cdcc_cntr/slv_wr_ready_srl
add wave -noupdate /nff_cdcc_cntr_tb/dut_nff_cdcc_cntr/slv_wr_gray_to_bin
add wave -noupdate /nff_cdcc_cntr_tb/dut_nff_cdcc_cntr/slv_wr_incremented_bin
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {135977 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 390
configure wave -valuecolwidth 100
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
WaveRestoreZoom {183200 ps} {990358 ps}
