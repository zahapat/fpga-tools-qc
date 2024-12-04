onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: xilinx_iophase_aligner_tb ALL signals}
add wave -noupdate /xilinx_iophase_aligner_tb/clk_bufio
add wave -noupdate /xilinx_iophase_aligner_tb/clkb_bufio
add wave -noupdate /xilinx_iophase_aligner_tb/clk_bufg
add wave -noupdate /xilinx_iophase_aligner_tb/in_reset
add wave -noupdate /xilinx_iophase_aligner_tb/out_aligned_flag
add wave -noupdate -divider {DUT: 'xilinx_iophase_aligner' IN ports}
add wave -noupdate /xilinx_iophase_aligner_tb/dut/in_reset
add wave -noupdate /xilinx_iophase_aligner_tb/dut/clk_bufg
add wave -noupdate /xilinx_iophase_aligner_tb/dut/clkb_bufio
add wave -noupdate /xilinx_iophase_aligner_tb/dut/clk_bufio
add wave -noupdate /xilinx_iophase_aligner_tb/dut/clk_div_bufg
add wave -noupdate -divider {DUT: 'xilinx_iophase_aligner' OUT ports}
add wave -noupdate /xilinx_iophase_aligner_tb/dut/out_aligned_flag
add wave -noupdate -divider {DUT: 'xilinx_iophase_aligner' INTERNAL signals}
add wave -noupdate /xilinx_iophase_aligner_tb/dut/slv_clock_sampled_last
add wave -noupdate /xilinx_iophase_aligner_tb/dut/slv_clock_sampled_last_reg
add wave -noupdate /xilinx_iophase_aligner_tb/dut/counter_increment
add wave -noupdate /xilinx_iophase_aligner_tb/dut/slv_clock_sampled_p1
add wave -noupdate /xilinx_iophase_aligner_tb/dut/sl_output_feedback_clock
add wave -noupdate /xilinx_iophase_aligner_tb/dut/sl_32b_delayed_reset
add wave -noupdate /xilinx_iophase_aligner_tb/dut/slv_clock_sampled_p2
add wave -noupdate /xilinx_iophase_aligner_tb/dut/counter_enable
add wave -noupdate /xilinx_iophase_aligner_tb/dut/state_next
add wave -noupdate /xilinx_iophase_aligner_tb/dut/sl_clock_sampled_2d
add wave -noupdate /xilinx_iophase_aligner_tb/dut/counter_ctrl
add wave -noupdate /xilinx_iophase_aligner_tb/dut/slv_clock_sampled
add wave -noupdate /xilinx_iophase_aligner_tb/dut/counter
add wave -noupdate /xilinx_iophase_aligner_tb/dut/state
add wave -noupdate /xilinx_iophase_aligner_tb/dut/sl_aligned_flag
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2993098 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 398
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
WaveRestoreZoom {0 ps} {2879420 ps}
