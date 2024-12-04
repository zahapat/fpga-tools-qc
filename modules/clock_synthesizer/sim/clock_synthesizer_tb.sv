// `timescale 1 ps / 1 ps  // time-unit = 1 ns, precision = 10 ps

module clock_synthesizer_tb;

    timeunit 1ns;  timeprecision 1ps;

    // ------------------------------------------------
    // DUT IO Signals and Instance
    // ------------------------------------------------
    // Generics
    // If input clk is differential
    parameter IF_CLKIN1_DIFF = 1;

    // Set input clk parameters
    localparam REAL_CLKIN1_MHZ = 200.0;

    // Setup the VCO frequency for the entire device
    localparam INT_VCO_DIVIDE = 1;
    localparam REAL_VCO_MULTIPLY = 6.000;

    // 0 = output port off
    localparam REAL_DIVIDE_OUT0 = 2.000;
    localparam INT_DIVIDE_OUT1 = 4;
    localparam INT_DIVIDE_OUT2 = 6;
    localparam INT_DIVIDE_OUT3 = 0;
    localparam INT_DIVIDE_OUT4 = 0;
    localparam INT_DIVIDE_OUT5 = 0;
    localparam INT_DIVIDE_OUT6 = 0;

    localparam REAL_DUTY_OUT0 = 0.500;
    localparam REAL_DUTY_OUT1 = 0.500;
    localparam REAL_DUTY_OUT2 = 0.500;
    localparam REAL_DUTY_OUT3 = 0.500;
    localparam REAL_DUTY_OUT4 = 0.500;
    localparam REAL_DUTY_OUT5 = 0.500;
    localparam REAL_DUTY_OUT6 = 0.500;

    localparam REAL_PHASE_OUT0 = 0.000;
    localparam REAL_PHASE_OUT1 = 0.000;
    localparam REAL_PHASE_OUT2 = 0.000;
    localparam REAL_PHASE_OUT3 = 0.000;
    localparam REAL_PHASE_OUT4 = 0.000;
    localparam REAL_PHASE_OUT5 = 0.000;
    localparam REAL_PHASE_OUT6 = 0.000;

    localparam CLKFBOUT_USE_FINE_PS = 0;
    localparam CLKOUT0_USE_FINE_PS = 0;
    localparam CLKOUT1_USE_FINE_PS = 0;
    localparam CLKOUT2_USE_FINE_PS = 0;
    localparam CLKOUT3_USE_FINE_PS = 0;
    localparam CLKOUT4_USE_FINE_PS = 0;
    localparam CLKOUT5_USE_FINE_PS = 0;
    localparam CLKOUT6_USE_FINE_PS = 0;
    

    localparam INT_BUF_CLKFB = -1; // 0=No Buffer; 1=BUFH; 2=BUFIO; 3=BUFR; else=BUFG (default)
    localparam INT_BUF_OUT0 = -1;  // 0=No Buffer; 1=BUFH; 2=BUFIO; 3=BUFR; else=BUFG (default)
    localparam INT_BUF_OUT1 = -1;
    localparam INT_BUF_OUT2 = -1;
    localparam INT_BUF_OUT3 = -1;
    localparam INT_BUF_OUT4 = -1;
    localparam INT_BUF_OUT5 = -1;
    localparam INT_BUF_OUT6 = -1;
    localparam INT_BUF_OUTB0 = 0;  // 0=No Buffer (Default); 1=BUFH; 2=BUFIO; 3=BUFR; else=BUFG
    localparam INT_BUF_OUTB1 = 0;
    localparam INT_BUF_OUTB2 = 0;
    localparam INT_BUF_OUTB3 = 0;
    
    localparam INT_COMPENSATION = 0;        // Delay Compensation 0=ZHOLD, 1=BUF_IN, 2=EXTERNAL, 3=INTERNAL
    localparam REAL_CLKIN1_PKPK_JITTER_PS = 20.0;
    localparam INT_BANDWIDTH = 1;           // Target Bandwidth 0=LOW, 1=HIGH, others=OPTIMIZED

    localparam INT_SELECT_PRIMITIVE = -1;   // 0 = PLL, else MMCM

    // Inputs
    logic in_reset = 1'b0;
    logic in_clk0_p = 1'b0;
    logic in_clk0_n = 1'b0;

    // Fine Phase Shift
    logic in_fineps_clk = 1'b0;

    logic in_fineps_incr = 1'b0;
    logic in_fineps_decr = 1'b0;
    logic in_fineps_valid = 1'b0;
    logic out_fineps_dready;

    // Outputs
    logic out_clkfb;
    logic out_clk0;
    logic out_clk1;
    logic out_clk2;
    logic out_clk3;
    logic out_clk4;
    logic out_clk5;
    logic out_clk6;
    logic out_clkb0;
    logic out_clkb1;
    logic out_clkb2;
    logic out_clkb3;
    logic out_clk0_inv;
    logic out_clk1_inv;
    logic out_clk2_inv;
    logic out_clk3_inv;
    logic out_clk0_nobuf;
    logic out_clk1_nobuf;
    logic out_clk2_nobuf;
    logic out_clk3_nobuf;
    logic locked;

    // DUT Instance
    clock_synthesizer #(
        .INT_SELECT_PRIMITIVE(INT_SELECT_PRIMITIVE),

        // Output buffering - place BUFR or BUFG
        .INT_BUF_CLKFB(INT_BUF_CLKFB),
        .INT_BUF_OUT0(INT_BUF_OUT0),
        .INT_BUF_OUT1(INT_BUF_OUT1),
        .INT_BUF_OUT2(INT_BUF_OUT2),
        .INT_BUF_OUT3(INT_BUF_OUT3),
        .INT_BUF_OUT4(INT_BUF_OUT4),
        .INT_BUF_OUT5(INT_BUF_OUT5),
        .INT_BUF_OUT6(INT_BUF_OUT6),
        .INT_BUF_OUTB0(INT_BUF_OUTB0),
        .INT_BUF_OUTB1(INT_BUF_OUTB1),
        .INT_BUF_OUTB2(INT_BUF_OUTB2),
        .INT_BUF_OUTB3(INT_BUF_OUTB3),

        // Select algorithm for target bandwidth and performance characteristics (affects jitter, phase margin and others)
        .INT_BANDWIDTH(INT_BANDWIDTH), // 0=LOW, 1=HIGH, others=OPTIMIZED
        
        // Delay Compensation
        .INT_COMPENSATION(INT_COMPENSATION),
        
        // If input clk is differential
        .IF_CLKIN1_DIFF(IF_CLKIN1_DIFF),
        
        // Set input clk parameters
        .REAL_CLKIN1_MHZ(REAL_CLKIN1_MHZ),
        .REAL_CLKIN1_PKPK_JITTER_PS(REAL_CLKIN1_PKPK_JITTER_PS),

        // Setup the VCO frequency for the entire device
        .INT_VCO_DIVIDE(INT_VCO_DIVIDE),
        .REAL_VCO_MULTIPLY(REAL_VCO_MULTIPLY),

        .REAL_DIVIDE_OUT0(REAL_DIVIDE_OUT0),
        .INT_DIVIDE_OUT1(INT_DIVIDE_OUT1),
        .INT_DIVIDE_OUT2(INT_DIVIDE_OUT2),
        .INT_DIVIDE_OUT3(INT_DIVIDE_OUT3),
        .INT_DIVIDE_OUT4(INT_DIVIDE_OUT4),
        .INT_DIVIDE_OUT5(INT_DIVIDE_OUT5),
        .INT_DIVIDE_OUT6(INT_DIVIDE_OUT6),

        .REAL_DUTY_OUT0(REAL_DUTY_OUT0),
        .REAL_DUTY_OUT1(REAL_DUTY_OUT1),
        .REAL_DUTY_OUT2(REAL_DUTY_OUT2),
        .REAL_DUTY_OUT3(REAL_DUTY_OUT3),
        .REAL_DUTY_OUT4(REAL_DUTY_OUT4),
        .REAL_DUTY_OUT5(REAL_DUTY_OUT5),
        .REAL_DUTY_OUT6(REAL_DUTY_OUT6),

        .REAL_PHASE_OUT0(REAL_PHASE_OUT0),
        .REAL_PHASE_OUT1(REAL_PHASE_OUT1),
        .REAL_PHASE_OUT2(REAL_PHASE_OUT2),
        .REAL_PHASE_OUT3(REAL_PHASE_OUT3),
        .REAL_PHASE_OUT4(REAL_PHASE_OUT4),
        .REAL_PHASE_OUT5(REAL_PHASE_OUT5),
        .REAL_PHASE_OUT6(REAL_PHASE_OUT6),

        .CLKFBOUT_USE_FINE_PS(CLKFBOUT_USE_FINE_PS),
        .CLKOUT0_USE_FINE_PS(CLKOUT0_USE_FINE_PS),
        .CLKOUT1_USE_FINE_PS(CLKOUT1_USE_FINE_PS),
        .CLKOUT2_USE_FINE_PS(CLKOUT2_USE_FINE_PS),
        .CLKOUT3_USE_FINE_PS(CLKOUT3_USE_FINE_PS),
        .CLKOUT4_USE_FINE_PS(CLKOUT4_USE_FINE_PS),
        .CLKOUT5_USE_FINE_PS(CLKOUT5_USE_FINE_PS),
        .CLKOUT6_USE_FINE_PS(CLKOUT6_USE_FINE_PS)
    ) dut (
        // Reset
        .in_reset(in_reset),

        // Inputs
        .in_clk0_p(in_clk0_p),
        .in_clk0_n(in_clk0_n),

        // Fine Phase Shift
        .in_fineps_clk(in_fineps_clk),
        .in_fineps_incr(in_fineps_incr),
        .in_fineps_decr(in_fineps_decr),
        .in_fineps_valid(in_fineps_valid),
        .out_fineps_dready(out_fineps_dready),

        // Outputs
        .out_clkfb(out_clkfb),
        .out_clk0(out_clk0),
        .out_clk1(out_clk1),
        .out_clk2(out_clk2),
        .out_clk3(out_clk3),
        .out_clk4(out_clk4),
        .out_clk5(out_clk5),
        .out_clk6(out_clk6),
        .out_clkb0(out_clkb0),
        .out_clkb1(out_clkb1),
        .out_clkb2(out_clkb2),
        .out_clkb3(out_clkb3),
        .out_clk0_inv(out_clk0_inv),
        .out_clk1_inv(out_clk1_inv),
        .out_clk2_inv(out_clk2_inv),
        .out_clk3_inv(out_clk3_inv),
        .out_clk0_nobuf(out_clk0_nobuf),
        .out_clk1_nobuf(out_clk1_nobuf),
        .out_clk2_nobuf(out_clk2_nobuf),
        .out_clk3_nobuf(out_clk3_nobuf),
        .locked(locked)
    );

    // Clocks
    localparam CLKIN1_PERIOD_NS = (1.0/REAL_CLKIN1_MHZ * 1000.0)/1.0ns;
    initial forever begin #(CLKIN1_PERIOD_NS/2.0) in_clk0_p = ~in_clk0_p; end
    initial forever begin #(CLKIN1_PERIOD_NS/2.0) in_clk0_n = ~in_clk0_p; end

    parameter fineps_clk_period_ns = 8.0/1.0ns; // * 1 ns on timescale
    initial forever begin #(fineps_clk_period_ns/2.0) in_fineps_clk = ~in_fineps_clk; end

    // ------------------------------------------------
    // Tasks
    // ------------------------------------------------

    // ------------------------------------------------
    // Stimulus
    // ------------------------------------------------
    localparam SIM_TIMEOUT = 1500ns;
    initial begin #SIM_TIMEOUT $finish; end // End of Simulation (timeout)

    initial begin

        in_reset <= 1'b1;
        #100ns;
        in_reset <= 1'b0;

        in_fineps_incr = 0;
        in_fineps_decr = 0;
        // in_fineps_valid = 0; // Uncomment if valid signal needs to be used, comment in constant valid mode
        in_fineps_valid = 1'b1;// Valid constantly high, use only incr and decr 1clk pulses

        // Wait until Fine PS is controllable
        wait (out_fineps_dready == 1'b1);

        // Wait until out_clk0 is running
        @(posedge locked);
        @(posedge in_clk0_p);
        @(posedge in_fineps_clk);
        @(posedge out_clk0);

        // Test delimiter
        #100ns;
        @(posedge in_fineps_clk);


        // Controlling the Fine Phase Shift: Increment
        for (int i = 0; i < 360; i = i + 1) begin
            // Prepare values
            if (out_fineps_dready == 1'b1) begin
                in_fineps_incr = 1'b1;
                in_fineps_decr = 0;
                // in_fineps_valid = 1'b1; // comment in constant valid mode
            end
            @(posedge in_fineps_clk);
            $display($time, "                       in_fineps_incr  = ", in_fineps_incr);
            $display($time, "                       in_fineps_decr  = ", in_fineps_decr);
            $display($time, "                       in_fineps_valid  = ", in_fineps_valid);

            // Pull down
            in_fineps_incr = 0;
            in_fineps_decr = 0;
            // in_fineps_valid = 0; // uncomment if valid mode, comment in constant valid mode
            wait (out_fineps_dready == 1'b1);
            @(posedge in_fineps_clk);
        end

        #1000ns;
        @(posedge in_fineps_clk);

        // Controlling the Fine Phase Shift: Decrement
        for (int i = 0; i < 360; i = i + 1) begin
            // Prepare values
            if (out_fineps_dready == 1'b1) begin
                in_fineps_incr = 0;
                in_fineps_decr = 1'b1;
                // in_fineps_valid = 1'b1; // comment in constant valid mode
            end
            @(posedge in_fineps_clk);
            $display($time, "                       in_fineps_incr  = ", in_fineps_incr);
            $display($time, "                       in_fineps_decr  = ", in_fineps_decr);
            $display($time, "                       in_fineps_valid  = ", in_fineps_valid);

            // Pull down
            in_fineps_incr = 0;
            in_fineps_decr = 0;
            // in_fineps_valid = 0; // uncomment if valid mode, comment in constant valid mode
            wait (out_fineps_dready == 1'b1);
            @(posedge in_fineps_clk);
        end

        
        @(posedge in_clk0_p);
        #100ns;

    end


endmodule