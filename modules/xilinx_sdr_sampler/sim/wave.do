onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: xilinx_sdr_sampler_tb ALL signals}
add wave -noupdate /xilinx_sdr_sampler_tb/clk
add wave -noupdate /xilinx_sdr_sampler_tb/clk90
add wave -noupdate /xilinx_sdr_sampler_tb/clk180
add wave -noupdate /xilinx_sdr_sampler_tb/in_pad
add wave -noupdate /xilinx_sdr_sampler_tb/in_reset_iserdese2
add wave -noupdate /xilinx_sdr_sampler_tb/out_data_fdre
add wave -noupdate /xilinx_sdr_sampler_tb/out_data_iddr_2clk
add wave -noupdate /xilinx_sdr_sampler_tb/out_data_iserdese2
add wave -noupdate -divider {DUT: 'xilinx_sdr_sampler' IN ports}
add wave -noupdate /xilinx_sdr_sampler_tb/dut/in_reset_iserdese2
add wave -noupdate /xilinx_sdr_sampler_tb/dut/in_pad
add wave -noupdate /xilinx_sdr_sampler_tb/dut/clk
add wave -noupdate /xilinx_sdr_sampler_tb/dut/clk90
add wave -noupdate /xilinx_sdr_sampler_tb/dut/clkb
add wave -noupdate /xilinx_sdr_sampler_tb/dut/clk90b
add wave -noupdate -divider {DUT: 'xilinx_sdr_sampler' OUT ports}
add wave -noupdate /xilinx_sdr_sampler_tb/dut/out_data_iserdese2
add wave -noupdate /xilinx_sdr_sampler_tb/dut/out_data_iddr_2clk
add wave -noupdate /xilinx_sdr_sampler_tb/dut/out_data_fdre
add wave -noupdate -divider {DUT: 'xilinx_sdr_sampler' INTERNAL signals}
add wave -noupdate /xilinx_sdr_sampler_tb/dut/clk
add wave -noupdate /xilinx_sdr_sampler_tb/dut/clk90
add wave -noupdate /xilinx_sdr_sampler_tb/dut/clk180
add wave -noupdate /xilinx_sdr_sampler_tb/dut/clkb
add wave -noupdate /xilinx_sdr_sampler_tb/dut/clk90b
add wave -noupdate /xilinx_sdr_sampler_tb/dut/slv_idelay_taps
add wave -noupdate /xilinx_sdr_sampler_tb/dut/in_reset_iserdese2
add wave -noupdate /xilinx_sdr_sampler_tb/dut/in_enable_iserdese2
add wave -noupdate /xilinx_sdr_sampler_tb/dut/in_pad
add wave -noupdate /xilinx_sdr_sampler_tb/dut/sl_pad
add wave -noupdate /xilinx_sdr_sampler_tb/dut/sl_data_ibuf_out
add wave -noupdate /xilinx_sdr_sampler_tb/dut/sl_idelay_to_iserdes
add wave -noupdate /xilinx_sdr_sampler_tb/dut/sl_out_data_fdre
add wave -noupdate /xilinx_sdr_sampler_tb/dut/slv_out_data_iddr_2clk
add wave -noupdate /xilinx_sdr_sampler_tb/dut/sl_out_data_iserdese2_2d
add wave -noupdate /xilinx_sdr_sampler_tb/dut/slv_out_data_iserdese2
add wave -noupdate /xilinx_sdr_sampler_tb/dut/out_data_fdre
add wave -noupdate /xilinx_sdr_sampler_tb/dut/out_data_iddr_2clk
add wave -noupdate /xilinx_sdr_sampler_tb/dut/out_data_iserdese2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {422350 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 313
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
WaveRestoreZoom {0 ps} {5349120 ps}
