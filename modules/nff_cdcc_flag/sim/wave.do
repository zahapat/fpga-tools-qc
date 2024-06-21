onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: nff_cdcc_tb ALL signals}
add wave -noupdate /nff_cdcc_tb/rst_write
add wave -noupdate /nff_cdcc_tb/clk_write
add wave -noupdate /nff_cdcc_tb/wr_en
add wave -noupdate /nff_cdcc_tb/wr_data
add wave -noupdate /nff_cdcc_tb/wr_ready
add wave -noupdate /nff_cdcc_tb/rst_read
add wave -noupdate /nff_cdcc_tb/clk_read
add wave -noupdate /nff_cdcc_tb/rd_valid
add wave -noupdate /nff_cdcc_tb/rd_data
add wave -noupdate /nff_cdcc_tb/sl_detector_clk
add wave -noupdate /nff_cdcc_tb/slv_detector_qubit
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/sl_wr_busy
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/sl_next_low_srl_bit
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/slv_wr_ready_srl
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/clk_write
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/wr_en
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/wr_data
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/wr_ready
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/clk_read
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/rd_valid
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/rd_data
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/slv_data_to_cross_latched
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/sl_bit_to_cross_latched
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/slv_data_to_cross_2d
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/slv_wr_en_event_to_cross
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/slv_data_asyncff_2d
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/slv_wr_en_event_asyncff
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/slv_data_synchronized
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/sl_wr_en_event_synchronized
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/slv_data_synchronized_p1
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/sl_wr_en_event_synchronized_p1
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/sl_wr_ready
add wave -noupdate /nff_cdcc_tb/dut_nff_cdcc/slv_next_srl
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {852000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 340
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
WaveRestoreZoom {807755 ps} {957487 ps}
