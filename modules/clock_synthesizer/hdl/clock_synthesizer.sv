// To set parameters to set up this core according to your
// specifications, it is possible to use the "mmcm_analysis.py"
// script. This script will generate set of parameters to set
// up this core as possible to your output clock requirements

`timescale 1 ns / 1 ps

module clock_synthesizer
    #(
        // Select Primitive: 0=PLL; else MMCM (default)
        parameter INT_SELECT_PRIMITIVE = -1,

        // Output Buffering
        parameter INT_BUF_CLKFB = -1, // 0=No Buffer; 1=BUFH; 2=BUFIO; 3=BUFR; else=BUFG (default)
        parameter INT_BUF_OUT0 = -1,  // 0=No Buffer; 1=BUFH; 2=BUFIO; 3=BUFR; else=BUFG (default)
        parameter INT_BUF_OUT1 = -1,
        parameter INT_BUF_OUT2 = -1,
        parameter INT_BUF_OUT3 = -1,
        parameter INT_BUF_OUT4 = -1,
        parameter INT_BUF_OUT5 = -1,
        parameter INT_BUF_OUT6 = -1,
        parameter INT_BUF_OUTB0 = 0,  // 0=No Buffer (default); 1=BUFH; 2=BUFIO; 3=BUFR; else=BUFG
        parameter INT_BUF_OUTB1 = 0,
        parameter INT_BUF_OUTB2 = 0,
        parameter INT_BUF_OUTB3 = 0,

        // Select algorithm for target bandwidth and performance characteristics (affects jitter, phase margin and others)
        parameter INT_BANDWIDTH = 1, // 0=LOW, 1=HIGH, others=OPTIMIZED
        
        // Delay Compensation
        parameter INT_COMPENSATION = 0, // 0=ZHOLD(default), 1=BUF_IN, 2=EXTERNAL, 3=INTERNAL

         // If input clk is differential
        parameter IF_CLKIN1_DIFF = 1,

        // Set input clk parameters
        parameter REAL_CLKIN1_MHZ = 200.0,
        parameter REAL_CLKIN1_PKPK_JITTER_PS = 50,

        // Setup the VCO frequency for the entire device
        parameter INT_VCO_DIVIDE = 1,
        parameter REAL_VCO_MULTIPLY = 6.000,

        // Set INT_DIVIDE_OUTX to 1 or a higher valid value to activate the output
        parameter REAL_DIVIDE_OUT0 = 2.000,
        parameter INT_DIVIDE_OUT1 = 0,
        parameter INT_DIVIDE_OUT2 = 0,
        parameter INT_DIVIDE_OUT3 = 0,
        parameter INT_DIVIDE_OUT4 = 0,
        parameter INT_DIVIDE_OUT5 = 0,
        parameter INT_DIVIDE_OUT6 = 0,

        parameter REAL_DUTY_OUT0 = 0.500,
        parameter REAL_DUTY_OUT1 = 0.500,
        parameter REAL_DUTY_OUT2 = 0.500,
        parameter REAL_DUTY_OUT3 = 0.500,
        parameter REAL_DUTY_OUT4 = 0.500,
        parameter REAL_DUTY_OUT5 = 0.500,
        parameter REAL_DUTY_OUT6 = 0.500,

        parameter REAL_PHASE_OUT0 = 0.000,
        parameter REAL_PHASE_OUT1 = 0.000,
        parameter REAL_PHASE_OUT2 = 0.000,
        parameter REAL_PHASE_OUT3 = 0.000,
        parameter REAL_PHASE_OUT4 = 0.000,
        parameter REAL_PHASE_OUT5 = 0.000,
        parameter REAL_PHASE_OUT6 = 0.000,

        // Fine Phase Shifting
        parameter CLKFBOUT_USE_FINE_PS = 0,
        parameter CLKOUT0_USE_FINE_PS = 0,
        parameter CLKOUT1_USE_FINE_PS = 0,
        parameter CLKOUT2_USE_FINE_PS = 0,
        parameter CLKOUT3_USE_FINE_PS = 0,
        parameter CLKOUT4_USE_FINE_PS = 0,
        parameter CLKOUT5_USE_FINE_PS = 0,
        parameter CLKOUT6_USE_FINE_PS = 0
    )(
        // Reset
        input  logic in_reset,

        // Inputs
        input  logic in_clk0_p,
        input  logic in_clk0_n,

        // Fine Phase Shift
        input  logic in_fineps_clk,
        input  logic in_fineps_incr,
        input  logic in_fineps_decr,
        input  logic in_fineps_valid,
        output logic out_fineps_dready,

        // Outputs
        // Note from Xilinx forum: "if you need an internal clock 
        //                          that is the same frequency as 
        //                          your input clock, it is legal 
        //                          to clock flip-flops on the output 
        //                          of the BUFG connected to the 
        //                          CLKFBOUT [= out_clkfb] port of 
        //                          the MMCM [or PLL]."
        output logic out_clkfb,
        output logic out_clk0,
        output logic out_clk1,
        output logic out_clk2,
        output logic out_clk3,
        output logic out_clk4,
        output logic out_clk5,
        output logic out_clk6,
        output logic out_clkb0,
        output logic out_clkb1,
        output logic out_clkb2,
        output logic out_clkb3,
        output logic out_clk0_inv,
        output logic out_clk1_inv,
        output logic out_clk2_inv,
        output logic out_clk3_inv,
        output logic out_clk0_nobuf,
        output logic out_clk1_nobuf,
        output logic out_clk2_nobuf,
        output logic out_clk3_nobuf,
        output logic locked
    );

    // Constants
    localparam CLKIN1_PERIOD_NS = 1.0/REAL_CLKIN1_MHZ * 1000.0;
    localparam REAL_DIVIDE_OUT0_CORR = REAL_DIVIDE_OUT0 <= 0.0 ? 1.0 : REAL_DIVIDE_OUT0;
    localparam INT_DIVIDE_OUT1_CORR = INT_DIVIDE_OUT1 <= 0 ? 1 : INT_DIVIDE_OUT1;
    localparam INT_DIVIDE_OUT2_CORR = INT_DIVIDE_OUT2 <= 0 ? 1 : INT_DIVIDE_OUT2;
    localparam INT_DIVIDE_OUT3_CORR = INT_DIVIDE_OUT3 <= 0 ? 1 : INT_DIVIDE_OUT3;
    localparam INT_DIVIDE_OUT4_CORR = INT_DIVIDE_OUT4 <= 0 ? 1 : INT_DIVIDE_OUT4;
    localparam INT_DIVIDE_OUT5_CORR = INT_DIVIDE_OUT5 <= 0 ? 1 : INT_DIVIDE_OUT5;
    localparam INT_DIVIDE_OUT6_CORR = INT_DIVIDE_OUT6 <= 0 ? 1 : INT_DIVIDE_OUT6;

    // Signals
    logic clkin1;
    logic s_locked;
    logic out_feedback;
    logic out_feedback_bufx;
    logic [6:0] out_clk;
    logic [6:0] out_clk_bufx;
    logic [3:0] out_clkb;
    logic [3:0] out_clkb_bufx;

    // Connect output signals to output pins and default them to zero
    initial begin 
        out_feedback_bufx = 0;
        out_clk_bufx = 0; 
        out_clkb_bufx = 0; 
        s_locked = 0; 
    end
    assign out_clkfb = out_feedback_bufx;
    assign out_clk0 = out_clk_bufx[0];
    assign out_clk1 = out_clk_bufx[1];
    assign out_clk2 = out_clk_bufx[2];
    assign out_clk3 = out_clk_bufx[3];
    assign out_clk4 = out_clk_bufx[4];
    assign out_clk5 = out_clk_bufx[5];
    assign out_clk6 = out_clk_bufx[6];
    assign out_clkb0 = out_clkb_bufx[0];
    assign out_clkb1 = out_clkb_bufx[1];
    assign out_clkb2 = out_clkb_bufx[2];
    assign out_clkb3 = out_clkb_bufx[3];
    assign out_clk0_inv = ~out_clk_bufx[0];
    assign out_clk1_inv = ~out_clk_bufx[1];
    assign out_clk2_inv = ~out_clk_bufx[2];
    assign out_clk3_inv = ~out_clk_bufx[3];
    assign out_clk0_nobuf = out_clk[0];
    assign out_clk1_nobuf = out_clk[1];
    assign out_clk2_nobuf = out_clk[2];
    assign out_clk3_nobuf = out_clk[3];
    assign locked = s_locked;
    

    // Place BUFG behind all outputs, including the feedback clock
    // INT_BUF_CLKFB=0=No Buffer; INT_BUF_CLKFB=1=BUFH INT_BUF_CLKFB=2=BUFIO; INT_BUF_CLKFB=3=BUFR; INT_BUF_CLKFB=else=BUFG
    generate
        if (INT_BUF_CLKFB == 0) begin
            assign out_feedback_bufx = out_feedback;
        end
        else if (INT_BUF_CLKFB == 1) begin
            // BUFH allows access to unused portions of the global clocking 
            // network to be used as high-speed, low skew local (single 
            // clock region) routing resources.
            BUFH BUFH_inst_fb (
                .I(out_feedback),       // 1-bit input
                .O(out_feedback_bufx)   // 1-bit output
            );
        end 
        else if (INT_BUF_CLKFB == 2) begin
            BUFIO BUFIO_inst_fb (
                .I(out_feedback),       // 1-bit input: Clock input (connect to an IBUF or BUFMR).
                .O(out_feedback_bufx)   // 1-bit output: Clock output (connect to I/O clock loads).
            );
        end
        else if (INT_BUF_CLKFB == 3) begin
            BUFR #(
                .BUFR_DIVIDE("BYPASS"), // Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8"
                .SIM_DEVICE("7SERIES")  // Must be set to "7SERIES"
            ) BUFR_inst_fb (
                .I(out_feedback),       // 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
                .CE(1'b1),              // 1-bit input: Active high, clock enable (Divided modes only)
                .CLR(1'b0),             // 1-bit input: Active high, asynchronous clear (Divided modes only)
                .O(out_feedback_bufx)   // 1-bit output: Clock output port
            );
        end
        else begin
            BUFG BUFG_inst_fb (
                .I(out_feedback),
                .O(out_feedback_bufx)
            );
        end
    endgenerate

    // Place the desired buffer on the given MMCM output pin
    // INT_BUF_OUTX=0=No Buffer; INT_BUF_OUTX=1=BUFH; INT_BUF_OUTX=2=BUFIO; INT_BUF_OUTX=3=BUFR; INT_BUF_OUTX=else=BUFG
    generate
        if (REAL_DIVIDE_OUT0 >= 1.0) begin 
            if (INT_BUF_OUT0 == 0) begin
                assign out_clk_bufx[0] = out_clk[0];
            end
            else if (INT_BUF_OUT0 == 1) begin
                // BUFH allows access to unused portions of the global clocking 
                // network to be used as high-speed, low skew local (single 
                // clock region) routing resources.
                BUFH BUFH_inst_clkout0 (
                    .I(out_clk[0]),         // 1-bit input
                    .O(out_clk_bufx[0])     // 1-bit output
                );
            end 
            else if (INT_BUF_OUT0 == 2) begin
                BUFIO BUFIO_inst_clkout0 (
                    .I(out_clk[0]),         // 1-bit input: Clock input (connect to an IBUF or BUFMR).
                    .O(out_clk_bufx[0])     // 1-bit output: Clock output (connect to I/O clock loads).
                );
            end 
            else if (INT_BUF_OUT0 == 3) begin
                BUFR #(
                    .BUFR_DIVIDE("BYPASS"), // Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8"
                    .SIM_DEVICE("7SERIES")  // Must be set to "7SERIES"
                ) BUFR_inst_clkout0 (
                    .I(out_clk[0]),         // 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
                    .CE(1'b1),              // 1-bit input: Active high, clock enable (Divided modes only)
                    .CLR(1'b0),             // 1-bit input: Active high, asynchronous clear (Divided modes only)
                    .O(out_clk_bufx[0])     // 1-bit output: Clock output port
                );
            end 
            else begin
                BUFG BUFG_inst_clkout0 (
                    .I(out_clk[0]),
                    .O(out_clk_bufx[0])
                );
            end

            // Inverted port
            if (INT_BUF_OUTB0 == 0) begin
                assign out_clkb_bufx[0] = out_clkb[0];
            end
            else if (INT_BUF_OUTB0 == 1) begin
                // BUFH allows access to unused portions of the global clocking 
                // network to be used as high-speed, low skew local (single 
                // clock region) routing resources.
                BUFH BUFH_inst_clkoutb0 (
                    .I(out_clkb[0]),        // 1-bit input
                    .O(out_clkb_bufx[0])    // 1-bit output
                );
            end 
            else if (INT_BUF_OUTB0 == 2) begin
                BUFIO BUFIO_inst_clkoutb0 (
                    .I(out_clkb[0]),        // 1-bit input: Clock input (connect to an IBUF or BUFMR).
                    .O(out_clkb_bufx[0])    // 1-bit output: Clock output (connect to I/O clock loads).
                );
            end 
            else if (INT_BUF_OUTB0 == 3) begin
                BUFR #(
                    .BUFR_DIVIDE("BYPASS"), // Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8"
                    .SIM_DEVICE("7SERIES")  // Must be set to "7SERIES"
                ) BUFR_inst_clkoutb0 (
                    .I(out_clkb[0]),        // 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
                    .CE(1'b1),              // 1-bit input: Active high, clock enable (Divided modes only)
                    .CLR(1'b0),             // 1-bit input: Active high, asynchronous clear (Divided modes only)
                    .O(out_clkb_bufx[0])    // 1-bit output: Clock output port
                );
            end 
            else begin
                BUFG BUFG_inst_clkoutb0 (
                    .I(out_clkb[0]),
                    .O(out_clkb_bufx[0])
                );
            end
        end

        if (INT_DIVIDE_OUT1 >= 1) begin
            if (INT_BUF_OUT1 == 0) begin
                assign out_clk_bufx[1] = out_clk[1];
            end
            else if (INT_BUF_OUT1 == 1) begin
                // BUFH allows access to unused portions of the global clocking 
                // network to be used as high-speed, low skew local (single 
                // clock region) routing resources.
                BUFH BUFH_inst_clkout1 (
                    .I(out_clk[1]),         // 1-bit input
                    .O(out_clk_bufx[1])     // 1-bit output
                );
            end 
            else if (INT_BUF_OUT1 == 2) begin
                BUFIO BUFIO_inst_clkout1 (
                    .I(out_clk[1]),         // 1-bit input: Clock input (connect to an IBUF or BUFMR).
                    .O(out_clk_bufx[1])     // 1-bit output: Clock output (connect to I/O clock loads).
                );
            end 
            else if (INT_BUF_OUT1 == 3) begin
                BUFR #(
                    .BUFR_DIVIDE("BYPASS"), // Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8"
                    .SIM_DEVICE("7SERIES")  // Must be set to "7SERIES"
                ) BUFR_inst_clkout1 (
                    .I(out_clk[1]),         // 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
                    .CE(1'b1),              // 1-bit input: Active high, clock enable (Divided modes only)
                    .CLR(1'b0),             // 1-bit input: Active high, asynchronous clear (Divided modes only)
                    .O(out_clk_bufx[1])     // 1-bit output: Clock output port
                );
            end 
            else begin
                BUFG BUFG_inst_clkout1 (
                    .I(out_clk[1]),
                    .O(out_clk_bufx[1])
                );
            end

            // Inverted port
            if (INT_BUF_OUTB1 == 0) begin
                assign out_clkb_bufx[1] = out_clkb[1];
            end
            else if (INT_BUF_OUTB1 == 1) begin
                // BUFH allows access to unused portions of the global clocking 
                // network to be used as high-speed, low skew local (single 
                // clock region) routing resources.
                BUFH BUFH_inst_clkoutb1 (
                    .I(out_clkb[1]),        // 1-bit input
                    .O(out_clkb_bufx[1])    // 1-bit output
                );
            end 
            else if (INT_BUF_OUTB1 == 2) begin
                BUFIO BUFIO_inst_clkoutb1 (
                    .I(out_clkb[1]),        // 1-bit input: Clock input (connect to an IBUF or BUFMR).
                    .O(out_clkb_bufx[1])    // 1-bit output: Clock output (connect to I/O clock loads).
                );
            end 
            else if (INT_BUF_OUTB1 == 3) begin
                BUFR #(
                    .BUFR_DIVIDE("BYPASS"), // Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8"
                    .SIM_DEVICE("7SERIES")  // Must be set to "7SERIES"
                ) BUFR_inst_clkoutb1 (
                    .I(out_clkb[1]),        // 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
                    .CE(1'b1),              // 1-bit input: Active high, clock enable (Divided modes only)
                    .CLR(1'b0),             // 1-bit input: Active high, asynchronous clear (Divided modes only)
                    .O(out_clkb_bufx[1])    // 1-bit output: Clock output port
                );
            end 
            else begin
                BUFG BUFG_inst_clkoutb1 (
                    .I(out_clkb[1]),
                    .O(out_clkb_bufx[1])
                );
            end
        end


        if (INT_DIVIDE_OUT2 >= 1) begin
            if (INT_BUF_OUT2 == 0) begin
                assign out_clk_bufx[2] = out_clk[2];
            end
            else if (INT_BUF_OUT2 == 1) begin
                // BUFH allows access to unused portions of the global clocking 
                // network to be used as high-speed, low skew local (single 
                // clock region) routing resources.
                BUFH BUFH_inst_clkout2 (
                    .I(out_clk[2]),         // 1-bit input
                    .O(out_clk_bufx[2])     // 1-bit output
                );
            end 
            else if (INT_BUF_OUT2 == 2) begin
                BUFIO BUFIO_inst_clkout2 (
                    .I(out_clk[2]),         // 1-bit input: Clock input (connect to an IBUF or BUFMR).
                    .O(out_clk_bufx[2])     // 1-bit output: Clock output (connect to I/O clock loads).
                );
            end 
            else if (INT_BUF_OUT2 == 3) begin
                BUFR #(
                    .BUFR_DIVIDE("BYPASS"), // Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8"
                    .SIM_DEVICE("7SERIES")  // Must be set to "7SERIES"
                ) BUFR_inst_clkout2 (
                    .I(out_clk[2]),         // 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
                    .CE(1'b1),              // 1-bit input: Active high, clock enable (Divided modes only)
                    .CLR(1'b0),             // 1-bit input: Active high, asynchronous clear (Divided modes only)
                    .O(out_clk_bufx[2])     // 1-bit output: Clock output port
                );
            end 
            else begin
                BUFG BUFG_inst_clkout2 (
                    .I(out_clk[2]),
                    .O(out_clk_bufx[2])
                );
            end

            // Inverted port
            if (INT_BUF_OUTB2 == 0) begin
                assign out_clkb_bufx[2] = out_clkb[2];
            end
            else if (INT_BUF_OUTB2 == 1) begin
                // BUFH allows access to unused portions of the global clocking 
                // network to be used as high-speed, low skew local (single 
                // clock region) routing resources.
                BUFH BUFH_inst_clkoutb2 (
                    .I(out_clkb[2]),        // 1-bit input
                    .O(out_clkb_bufx[2])    // 1-bit output
                );
            end 
            else if (INT_BUF_OUTB2 == 2) begin
                BUFIO BUFIO_inst_clkoutb2 (
                    .I(out_clkb[2]),        // 1-bit input: Clock input (connect to an IBUF or BUFMR).
                    .O(out_clkb_bufx[2])    // 1-bit output: Clock output (connect to I/O clock loads).
                );
            end 
            else if (INT_BUF_OUTB2 == 3) begin
                BUFR #(
                    .BUFR_DIVIDE("BYPASS"), // Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8"
                    .SIM_DEVICE("7SERIES")  // Must be set to "7SERIES"
                ) BUFR_inst_clkoutb2 (
                    .I(out_clkb[2]),        // 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
                    .CE(1'b1),              // 1-bit input: Active high, clock enable (Divided modes only)
                    .CLR(1'b0),             // 1-bit input: Active high, asynchronous clear (Divided modes only)
                    .O(out_clkb_bufx[2])    // 1-bit output: Clock output port
                );
            end 
            else begin
                BUFG BUFG_inst_clkoutb2 (
                    .I(out_clkb[2]),
                    .O(out_clkb_bufx[2])
                );
            end
        end


        if (INT_DIVIDE_OUT3 >= 1)  begin
            if (INT_BUF_OUT3 == 0) begin
                assign out_clk_bufx[3] = out_clk[3];
            end
            else if (INT_BUF_OUT3 == 1) begin
                // BUFH allows access to unused portions of the global clocking 
                // network to be used as high-speed, low skew local (single 
                // clock region) routing resources.
                BUFH BUFH_inst_clkout3 (
                    .I(out_clk[3]),         // 1-bit input
                    .O(out_clk_bufx[3])     // 1-bit output
                );
            end 
            else if (INT_BUF_OUT3 == 2) begin
                BUFIO BUFIO_inst_clkout3 (
                    .I(out_clk[3]),         // 1-bit input: Clock input (connect to an IBUF or BUFMR).
                    .O(out_clk_bufx[3])     // 1-bit output: Clock output (connect to I/O clock loads).
                );
            end 
            else if (INT_BUF_OUT3 == 3) begin
                BUFR #(
                    .BUFR_DIVIDE("BYPASS"), // Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8"
                    .SIM_DEVICE("7SERIES")  // Must be set to "7SERIES"
                ) BUFR_inst_clkout3 (
                    .I(out_clk[3]),         // 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
                    .CE(1'b1),              // 1-bit input: Active high, clock enable (Divided modes only)
                    .CLR(1'b0),             // 1-bit input: Active high, asynchronous clear (Divided modes only)
                    .O(out_clk_bufx[3])     // 1-bit output: Clock output port
                );
            end 
            else begin
                BUFG BUFG_inst_clkout3 (
                    .I(out_clk[3]),
                    .O(out_clk_bufx[3])
                );
            end

            // Inverted port
            if (INT_BUF_OUTB3 == 0) begin
                assign out_clkb_bufx[3] = out_clkb[3];
            end
            else if (INT_BUF_OUTB3 == 1) begin
                // BUFH allows access to unused portions of the global clocking 
                // network to be used as high-speed, low skew local (single 
                // clock region) routing resources.
                BUFH BUFH_inst_clkoutb3 (
                    .I(out_clkb[3]),        // 1-bit input
                    .O(out_clkb_bufx[3])    // 1-bit output
                );
            end 
            else if (INT_BUF_OUTB3 == 2) begin
                BUFIO BUFIO_inst_clkoutb3 (
                    .I(out_clkb[3]),        // 1-bit input: Clock input (connect to an IBUF or BUFMR).
                    .O(out_clkb_bufx[3])    // 1-bit output: Clock output (connect to I/O clock loads).
                );
            end 
            else if (INT_BUF_OUTB3 == 3) begin
                BUFR #(
                    .BUFR_DIVIDE("BYPASS"), // Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8"
                    .SIM_DEVICE("7SERIES")  // Must be set to "7SERIES"
                ) BUFR_inst_clkoutb3 (
                    .I(out_clkb[3]),        // 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
                    .CE(1'b1),              // 1-bit input: Active high, clock enable (Divided modes only)
                    .CLR(1'b0),             // 1-bit input: Active high, asynchronous clear (Divided modes only)
                    .O(out_clkb_bufx[3])    // 1-bit output: Clock output port
                );
            end 
            else begin
                BUFG BUFG_inst_clkoutb3 (
                    .I(out_clkb[3]),
                    .O(out_clkb_bufx[3])
                );
            end
        end 


        if (INT_DIVIDE_OUT4 >= 1) begin
            if (INT_BUF_OUT4 == 0) begin
                assign out_clk_bufx[4] = out_clk[4];
            end
            else if (INT_BUF_OUT4 == 1) begin
                // BUFH allows access to unused portions of the global clocking 
                // network to be used as high-speed, low skew local (single 
                // clock region) routing resources.
                BUFH BUFH_inst_clkout4 (
                    .I(out_clk[4]),         // 1-bit input
                    .O(out_clk_bufx[4])     // 1-bit output
                );
            end 
            else if (INT_BUF_OUT4 == 2) begin
                BUFIO BUFIO_inst_clkout4 (
                    .I(out_clk[4]),        // 1-bit input: Clock input (connect to an IBUF or BUFMR).
                    .O(out_clk_bufx[4])    // 1-bit output: Clock output (connect to I/O clock loads).
                );
            end 
            else if (INT_BUF_OUT4 == 3) begin
                BUFR #(
                    .BUFR_DIVIDE("BYPASS"), // Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8"
                    .SIM_DEVICE("7SERIES")  // Must be set to "7SERIES"
                ) BUFR_inst_clkout4 (
                    .I(out_clk[4]),         // 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
                    .CE(1'b1),              // 1-bit input: Active high, clock enable (Divided modes only)
                    .CLR(1'b0),             // 1-bit input: Active high, asynchronous clear (Divided modes only)
                    .O(out_clk_bufx[4])     // 1-bit output: Clock output port
                );
            end 
            else begin
                BUFG BUFG_inst_clkout4 (
                    .I(out_clk[4]),
                    .O(out_clk_bufx[4])
                );
            end
        end


        if (INT_DIVIDE_OUT5 >= 1) begin
            if (INT_BUF_OUT5 == 0) begin
                assign out_clk_bufx[5] = out_clk[5];
            end
            else if (INT_BUF_OUT5 == 1) begin
                // BUFH allows access to unused portions of the global clocking 
                // network to be used as high-speed, low skew local (single 
                // clock region) routing resources.
                BUFH BUFH_inst_clkout5 (
                    .I(out_clk[5]),         // 1-bit input
                    .O(out_clk_bufx[5])     // 1-bit output
                );
            end 
            else if (INT_BUF_OUT5 == 2) begin
                BUFIO BUFIO_inst_clkout5 (
                    .I(out_clk[5]),         // 1-bit input: Clock input (connect to an IBUF or BUFMR).
                    .O(out_clk_bufx[5])     // 1-bit output: Clock output (connect to I/O clock loads).
                );
            end 
            else if (INT_BUF_OUT5 == 3) begin
                BUFR #(
                    .BUFR_DIVIDE("BYPASS"), // Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8"
                    .SIM_DEVICE("7SERIES")  // Must be set to "7SERIES"
                ) BUFR_inst_clkout5 (
                    .I(out_clk[5]),         // 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
                    .CE(1'b1),              // 1-bit input: Active high, clock enable (Divided modes only)
                    .CLR(1'b0),             // 1-bit input: Active high, asynchronous clear (Divided modes only)
                    .O(out_clk_bufx[5])     // 1-bit output: Clock output port
                );
            end 
            else begin
                BUFG BUFG_inst_clkout5 (
                    .I(out_clk[5]),
                    .O(out_clk_bufx[5])
                );
            end
        end


        if (INT_DIVIDE_OUT6 >= 1) begin
            if (INT_BUF_OUT6 == 0) begin
                assign out_clk_bufx[6] = out_clk[6];
            end
            else if (INT_BUF_OUT6 == 1) begin
                // BUFH allows access to unused portions of the global clocking 
                // network to be used as high-speed, low skew local (single 
                // clock region) routing resources.
                BUFH BUFH_inst_clkout6 (
                    .I(out_clk[6]),         // 1-bit input
                    .O(out_clk_bufx[6])     // 1-bit output
                );
            end 
            else if (INT_BUF_OUT6 == 2) begin
                BUFIO BUFIO_inst_clkout6 (
                    .I(out_clk[6]),         // 1-bit input: Clock input (connect to an IBUF or BUFMR).
                    .O(out_clk_bufx[6])     // 1-bit output: Clock output (connect to I/O clock loads).
                );
            end 
            else if (INT_BUF_OUT6 == 2) begin
                BUFR #(
                    .BUFR_DIVIDE("BYPASS"), // Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8"
                    .SIM_DEVICE("7SERIES")  // Must be set to "7SERIES"
                ) BUFR_inst_clkout6 (
                    .I(out_clk[6]),         // 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
                    .CE(1'b1),              // 1-bit input: Active high, clock enable (Divided modes only)
                    .CLR(1'b0),             // 1-bit input: Active high, asynchronous clear (Divided modes only)
                    .O(out_clk_bufx[6])     // 1-bit output: Clock output port
                );
            end 
            else begin
                BUFG BUFG_inst_clkout6 (
                    .I(out_clk[6]),
                    .O(out_clk_bufx[6])
                );
            end
        end
    endgenerate

    generate
        if (IF_CLKIN1_DIFF == 1) begin
            IBUFDS #(
                .DIFF_TERM("FALSE"),    // Differential Termination
                .IBUF_LOW_PWR("FALSE"), // Low power="TRUE", Highest performance="FALSE"
                .IOSTANDARD("DEFAULT")  // Specify the input I/O standard
            ) inst_IBUFDS_clkin1 (
                .I(in_clk0_p),          // Diff_p buffer input (connect directly to top-level port)
                .IB(in_clk0_n),         // Diff_n buffer input (connect directly to top-level port)
                .O(clkin1)              // Buffer output
            );
        end
        else begin
            assign clkin1 = in_clk0_p;
        end

    endgenerate


    // Fine Phase Shift Logic
    logic ps_done;
    logic fineps_dready;
    logic fineps_en;
    logic fineps_incdec;
    logic fineps_valid;
    initial begin 
        fineps_en = 0; 
        fineps_incdec = 0; 
        fineps_valid = 0; 
        fineps_dready = 0;
        ps_done = 0;
    end
    assign out_fineps_dready = (fineps_dready | ps_done);

    enum int unsigned {
            // One-hot encoding
            WAIT_FIRST_TRIGGER            = 0,
            WAIT_READY_AGAIN              = 1
    } state = WAIT_FIRST_TRIGGER;

    always @(posedge in_fineps_clk) begin

        // Incr Decr Ready Logic
        fineps_en <= 0;
        

        case (state)
            // Configure phase shift cmd detected -> ignore all valid signals
            WAIT_FIRST_TRIGGER: begin
                fineps_dready <= 1'b1;
                if (in_fineps_valid == 1'b1) begin
                    // Allows only one of incr and decr signals to perform the shift
                    if (in_fineps_incr^in_fineps_decr == 1'b1) begin
                        fineps_incdec <= in_fineps_incr;
                        fineps_en <= 1'b1;
                        fineps_dready <= 0;
                        state <= WAIT_READY_AGAIN;
                    end
                end
            end

            // Configure phase shift cmd done -> enable next valid signal
            WAIT_READY_AGAIN: begin
                if (ps_done == 1'b1) begin
                    fineps_dready <= ps_done;
                    state <= WAIT_FIRST_TRIGGER;
                end
            end

            default: begin
                fineps_incdec <= 0;
                fineps_en <= 0;
                fineps_dready <= 0;
                state <= WAIT_FIRST_TRIGGER;
            end

        endcase

    end

    // Compensation Selector: Update Integer 'INT_COMPENSATION' value to Appropriate String 'COMPENSATION' read by MMCME2_ADV core
    localparam COMPENSATION = (INT_COMPENSATION == 1) ? "BUF_IN" : (INT_COMPENSATION == 2) ? "EXTERNAL" : (INT_COMPENSATION == 3) ? "INTERNAL" : "ZHOLD";

    // Select algorithm for target bandwidth and performance characteristics (affects jitter, phase margin and others)
    localparam BANDWIDTH = (INT_BANDWIDTH == 0) ? "LOW" : (INT_BANDWIDTH == 1) ? "HIGH" : "OPTIMIZED";


    // Define REF_JITTER1 in UI: Convert pk-to-pk Jitter (ps) to UI
    // Example: pk-to-pk Jitter (ps) = 20 ps; 
    //          Input Clock Period (ns) = 5 ns;
    //          UI = pk-to-pk Jitter (ps) / Input Clock Period (ns)
    //             = 20*10^(-12) / (5*10^(-9)) = 0.004
    // How the below works: The goal is to round a float with to obtain a decimal value with 3 significant digits precision
    // Example: Assume REF_JITTER1_UI_REAL            = 0.01188
    //                 REF_JITTER1_UI_REAL_MULTIPLIED = 118.8
    //                 REF_JITTER1_UI_ROUNDED1        = 119
    //                 REF_JITTER1_UI_DIVIDED         = 11.9
    //                 REF_JITTER1_UI_ROUNDED2        = 12
    //                 REF_JITTER1_UI_REAL_ORIG_ORDER = 0.012
    // Other Examples:
    //          REF_JITTER1_UI_REAL  |  UI 
    //                 0.0078          0.008
    //                 0.0074          0.007
    //                 0.0018          0.002
    //                 0.0006          0.001
    localparam REF_JITTER1_UI_REAL = (REAL_CLKIN1_PKPK_JITTER_PS == 0.0) ? 0.010 : ((REAL_CLKIN1_PKPK_JITTER_PS * 10.0**(-12)) / (CLKIN1_PERIOD_NS * 10.0**(-9)));
    localparam REF_JITTER1_UI_REAL_MULTIPLIED = REF_JITTER1_UI_REAL * 10000.0;
    localparam int REF_JITTER1_UI_ROUNDED1 = int'(REF_JITTER1_UI_REAL_MULTIPLIED);
    localparam REF_JITTER1_UI_DIVIDED = REF_JITTER1_UI_ROUNDED1 / 10.0;
    localparam int REF_JITTER1_UI_ROUNDED2 = int'(REF_JITTER1_UI_DIVIDED);
    localparam shortreal REF_JITTER1_UI_REAL_ORIG_ORDER = REF_JITTER1_UI_ROUNDED2 / 1000.0;

    // Convert integer parameter to string
    localparam CLKFBOUT_USE_FINE_PS_BOOL = (CLKFBOUT_USE_FINE_PS == 0) ? "FALSE" : "TRUE";
    localparam CLKOUT0_USE_FINE_PS_BOOL = (CLKOUT0_USE_FINE_PS == 0) ? "FALSE" : "TRUE";
    localparam CLKOUT1_USE_FINE_PS_BOOL = (CLKOUT1_USE_FINE_PS == 0) ? "FALSE" : "TRUE";
    localparam CLKOUT2_USE_FINE_PS_BOOL = (CLKOUT2_USE_FINE_PS == 0) ? "FALSE" : "TRUE";
    localparam CLKOUT3_USE_FINE_PS_BOOL = (CLKOUT3_USE_FINE_PS == 0) ? "FALSE" : "TRUE";
    localparam CLKOUT4_USE_FINE_PS_BOOL = (CLKOUT4_USE_FINE_PS == 0) ? "FALSE" : "TRUE";
    localparam CLKOUT5_USE_FINE_PS_BOOL = (CLKOUT5_USE_FINE_PS == 0) ? "FALSE" : "TRUE";
    localparam CLKOUT6_USE_FINE_PS_BOOL = (CLKOUT6_USE_FINE_PS == 0) ? "FALSE" : "TRUE";

    
    // Create the desired primitive (INT_SELECT_PRIMITIVE=0 = PLLE2_ADV; else MMCM2_ADV)
    generate
        if (INT_SELECT_PRIMITIVE == 0) begin
            // Convert REAL_VCO_MULTIPLY to a properly rounded integer value
            localparam REAL_VCO_MULTIPLY_MULTIPLIED = REAL_VCO_MULTIPLY * 100.0;
            localparam int REAL_VCO_MULTIPLY_ROUNDED1 = int'(REAL_VCO_MULTIPLY_MULTIPLIED);
            localparam REAL_VCO_MULTIPLY_DIVIDED1 = REAL_VCO_MULTIPLY_ROUNDED1 / 10.0;
            localparam int REAL_VCO_MULTIPLY_ROUNDED2 = int'(REAL_VCO_MULTIPLY_DIVIDED1);
            localparam REAL_VCO_MULTIPLY_DIVIDED2 = REAL_VCO_MULTIPLY_ROUNDED2 / 10.0;
            localparam int INT_VCO_MULTIPLY = int'(REAL_VCO_MULTIPLY_DIVIDED2);

            // Convert REAL_DIVIDE_OUT0_CORR to a properly rounded integer value
            localparam REAL_DIVIDE_OUT0_CORR_MULTIPLIED = REAL_DIVIDE_OUT0_CORR * 100.0;
            localparam int REAL_DIVIDE_OUT0_CORR_ROUNDED1 = int'(REAL_DIVIDE_OUT0_CORR_MULTIPLIED);
            localparam REAL_DIVIDE_OUT0_CORR_DIVIDED1 = REAL_DIVIDE_OUT0_CORR_ROUNDED1 / 10.0;
            localparam int REAL_DIVIDE_OUT0_CORR_ROUNDED2 = int'(REAL_DIVIDE_OUT0_CORR_DIVIDED1);
            localparam REAL_DIVIDE_OUT0_CORR_DIVIDED2 = REAL_DIVIDE_OUT0_CORR_ROUNDED2 / 10.0;
            localparam int INT_DIVIDE_OUT0_CORR = int'(REAL_DIVIDE_OUT0_CORR_DIVIDED2);

            // PLLE2_ADV: Advanced Phase Locked Loop (PLL)
            //            7 Series
            // Xilinx HDL Language Template, version 2021.2
            PLLE2_ADV #(
                .BANDWIDTH(BANDWIDTH),              // OPTIMIZED, HIGH, LOW
                .CLKFBOUT_MULT(INT_VCO_MULTIPLY),   // Multiply value for all CLKOUT, (2-64)
                .CLKFBOUT_PHASE(0.0),               // Phase offset in degrees of CLKFB, (-360.000-360.000).
                                                    // CLKIN_PERIOD: Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
                .CLKIN1_PERIOD(CLKIN1_PERIOD_NS),
                .CLKIN2_PERIOD(0.0),
                                                    // CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT (1-128)
                .CLKOUT0_DIVIDE(INT_DIVIDE_OUT0_CORR),
                .CLKOUT1_DIVIDE(INT_DIVIDE_OUT1_CORR),
                .CLKOUT2_DIVIDE(INT_DIVIDE_OUT2_CORR),
                .CLKOUT3_DIVIDE(INT_DIVIDE_OUT3_CORR),
                .CLKOUT4_DIVIDE(INT_DIVIDE_OUT4_CORR),
                .CLKOUT5_DIVIDE(INT_DIVIDE_OUT5_CORR),
                                                    // CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.001-0.999).
                .CLKOUT0_DUTY_CYCLE(REAL_DUTY_OUT0),
                .CLKOUT1_DUTY_CYCLE(REAL_DUTY_OUT0),
                .CLKOUT2_DUTY_CYCLE(REAL_DUTY_OUT0),
                .CLKOUT3_DUTY_CYCLE(REAL_DUTY_OUT0),
                .CLKOUT4_DUTY_CYCLE(REAL_DUTY_OUT0),
                .CLKOUT5_DUTY_CYCLE(REAL_DUTY_OUT0),
                                                    // CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
                .CLKOUT0_PHASE(REAL_PHASE_OUT0),
                .CLKOUT1_PHASE(REAL_PHASE_OUT1),
                .CLKOUT2_PHASE(REAL_PHASE_OUT2),
                .CLKOUT3_PHASE(REAL_PHASE_OUT3),
                .CLKOUT4_PHASE(REAL_PHASE_OUT4),
                .CLKOUT5_PHASE(REAL_PHASE_OUT5),
                .COMPENSATION(COMPENSATION),        // ZHOLD, BUF_IN, EXTERNAL, INTERNAL
                .DIVCLK_DIVIDE(INT_VCO_DIVIDE),     // Master division value (1-56)
                                                    // REF_JITTER: Reference input jitter in UI (0.000-0.999).
                .REF_JITTER1(REF_JITTER1_UI_REAL_ORIG_ORDER),
                .REF_JITTER2(0.0),
                .STARTUP_WAIT("FALSE")              // Delay DONE until PLL Locks, ("TRUE"/"FALSE")
            )
            PLLE2_ADV_inst (
                // Clock Outputs: 1-bit (each) output: User configurable clock outputs
                .CLKOUT0(out_clk[0]),       // 1-bit output: CLKOUT0
                .CLKOUT1(out_clk[1]),       // 1-bit output: CLKOUT1
                .CLKOUT2(out_clk[2]),       // 1-bit output: CLKOUT2
                .CLKOUT3(out_clk[3]),       // 1-bit output: CLKOUT3
                .CLKOUT4(out_clk[4]),       // 1-bit output: CLKOUT4
                .CLKOUT5(out_clk[5]),       // 1-bit output: CLKOUT5
                                            // DRP Ports: 16-bit (each) output: Dynamic reconfiguration ports
                .DO(),                      // 16-bit output: DRP data
                .DRDY(),                    // 1-bit output: DRP ready
                                            // Feedback Clocks: 1-bit (each) output: Clock feedback ports
                .CLKFBOUT(out_feedback),    // 1-bit output: Feedback clock
                .LOCKED(s_locked),          // 1-bit output: LOCK
                                            // Clock Inputs: 1-bit (each) input: Clock inputs
                .CLKIN1(clkin1),            // 1-bit input: Primary clock
                .CLKIN2(),                  // 1-bit input: Secondary clock
                                            // Control Ports: 1-bit (each) input: PLL control ports
                .CLKINSEL(),                // 1-bit input: Clock select, High=CLKIN1 Low=CLKIN2
                .PWRDWN(),                  // 1-bit input: Power-down
                .RST(in_reset),             // 1-bit input: Reset
                                            // DRP Ports: 7-bit (each) input: Dynamic reconfiguration ports
                .DADDR(),                   // 7-bit input: DRP address
                .DCLK(),                    // 1-bit input: DRP clock
                .DEN(),                     // 1-bit input: DRP enable
                .DI(),                      // 16-bit input: DRP data
                .DWE(),                     // 1-bit input: DRP write enable
                                            // Feedback Clocks: 1-bit (each) input: Clock feedback ports
                .CLKFBIN(out_feedback_bufx) // 1-bit input: Feedback clock
            );
        end

        else begin
            // MMCME2_ADV: Advanced Mixed Mode Clock Manager
            //             7 Series
            // Xilinx HDL Language Template, version 2021.2
            MMCME2_ADV #(
                .BANDWIDTH(BANDWIDTH),                       // Jitter programming (OPTIMIZED, HIGH, LOW)
                .CLKFBOUT_MULT_F(REAL_VCO_MULTIPLY),         // Multiply value for all CLKOUT (2.000-64.000).
                .CLKFBOUT_PHASE(0.0),                        // Phase offset in degrees of CLKFB (-360.000-360.000).
                                                             // CLKIN_PERIOD: Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
                .CLKIN1_PERIOD(CLKIN1_PERIOD_NS),
                .CLKIN2_PERIOD(0.0),
        
                // 0 = output port off                       // CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for CLKOUT (1-128)
                .CLKOUT0_DIVIDE_F(REAL_DIVIDE_OUT0_CORR),    // Divide amount for CLKOUT0 (1.000-128.000).
                .CLKOUT1_DIVIDE(INT_DIVIDE_OUT1_CORR),
                .CLKOUT2_DIVIDE(INT_DIVIDE_OUT2_CORR),
                .CLKOUT3_DIVIDE(INT_DIVIDE_OUT3_CORR),
                .CLKOUT4_DIVIDE(INT_DIVIDE_OUT4_CORR),
                .CLKOUT5_DIVIDE(INT_DIVIDE_OUT5_CORR),
                .CLKOUT6_DIVIDE(INT_DIVIDE_OUT6_CORR),
                                                            // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.01-0.99).
                .CLKOUT0_DUTY_CYCLE(REAL_DUTY_OUT0),
                .CLKOUT1_DUTY_CYCLE(REAL_DUTY_OUT1),
                .CLKOUT2_DUTY_CYCLE(REAL_DUTY_OUT2),
                .CLKOUT3_DUTY_CYCLE(REAL_DUTY_OUT3),
                .CLKOUT4_DUTY_CYCLE(REAL_DUTY_OUT4),
                .CLKOUT5_DUTY_CYCLE(REAL_DUTY_OUT5),
                .CLKOUT6_DUTY_CYCLE(REAL_DUTY_OUT6),
                                                            // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
                                                            // Specifies the phase offset in degrees of the clock feedback output. Shifting the feedback clock results in a negative phase shift of all output clocks to the MMCM.
                .CLKOUT0_PHASE(REAL_PHASE_OUT0),
                .CLKOUT1_PHASE(REAL_PHASE_OUT1),
                .CLKOUT2_PHASE(REAL_PHASE_OUT2),
                .CLKOUT3_PHASE(REAL_PHASE_OUT3),
                .CLKOUT4_PHASE(REAL_PHASE_OUT4),
                .CLKOUT5_PHASE(REAL_PHASE_OUT5),
                .CLKOUT6_PHASE(REAL_PHASE_OUT6),
                .CLKOUT4_CASCADE("FALSE"),                   // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
                .COMPENSATION(COMPENSATION),                 // ZHOLD, BUF_IN, EXTERNAL, INTERNAL
                .DIVCLK_DIVIDE(INT_VCO_DIVIDE),              // Master division value (1-106)
                                                             // REF_JITTER: Reference input jitter in UI (0.000-0.999).
                .REF_JITTER1(REF_JITTER1_UI_REAL_ORIG_ORDER),
                .REF_JITTER2(0.010),
                .STARTUP_WAIT("FALSE"),                      // Delays DONE until MMCM is locked (FALSE, TRUE)
                                                             // Spread Spectrum: Spread Spectrum Attributes
                .SS_EN("FALSE"),                             // Enables spread spectrum (FALSE, TRUE)
                .SS_MODE("CENTER_HIGH"),                     // CENTER_HIGH, CENTER_LOW, DOWN_HIGH, DOWN_LOW
                .SS_MOD_PERIOD(10000),                       // Spread spectrum modulation period (ns) (VALUES)
                                                             // USE_FINE_PS: Fine phase shift enable (TRUE/FALSE)
                .CLKFBOUT_USE_FINE_PS(CLKFBOUT_USE_FINE_PS_BOOL),
                .CLKOUT0_USE_FINE_PS(CLKOUT0_USE_FINE_PS_BOOL),
                .CLKOUT1_USE_FINE_PS(CLKOUT1_USE_FINE_PS_BOOL),
                .CLKOUT2_USE_FINE_PS(CLKOUT2_USE_FINE_PS_BOOL),
                .CLKOUT3_USE_FINE_PS(CLKOUT3_USE_FINE_PS_BOOL),
                .CLKOUT4_USE_FINE_PS(CLKOUT4_USE_FINE_PS_BOOL),
                .CLKOUT5_USE_FINE_PS(CLKOUT5_USE_FINE_PS_BOOL),
                .CLKOUT6_USE_FINE_PS(CLKOUT6_USE_FINE_PS_BOOL)
            ) MMCME2_ADV_inst (
                                               // Clock Outputs: 1-bit (each) output: User configurable clock outputs
                .CLKOUT0(out_clk[0]),          // 1-bit output: CLKOUT0
                .CLKOUT0B(out_clkb[0]),        // 1-bit output: Inverted CLKOUT0
                .CLKOUT1(out_clk[1]),          // 1-bit output: CLKOUT1
                .CLKOUT1B(out_clkb[1]),        // 1-bit output: Inverted CLKOUT1
                .CLKOUT2(out_clk[2]),          // 1-bit output: CLKOUT2
                .CLKOUT2B(out_clkb[2]),        // 1-bit output: Inverted CLKOUT2
                .CLKOUT3(out_clk[3]),          // 1-bit output: CLKOUT3
                .CLKOUT3B(out_clkb[3]),        // 1-bit output: Inverted CLKOUT3
                .CLKOUT4(out_clk[4]),          // 1-bit output: CLKOUT4
                .CLKOUT5(out_clk[5]),          // 1-bit output: CLKOUT5
                .CLKOUT6(out_clk[6]),          // 1-bit output: CLKOUT6
                                               // DRP Ports: 16-bit (each) output: Dynamic reconfiguration ports
                .DO(),                         // 16-bit output: DRP data
                .DRDY(),                       // 1-bit output: DRP ready
                                               // Feedback Clocks: 1-bit (each) output: Clock feedback ports
                .CLKFBOUT(out_feedback),       // 1-bit output: Feedback clock
                .CLKFBOUTB(),                  // 1-bit output: Inverted CLKFBOUT
                                               // Status Ports: 1-bit (each) output: MMCM status ports
                .CLKFBSTOPPED(),               // 1-bit output: Feedback clock stopped
                .CLKINSTOPPED(),               // 1-bit output: Input clock stopped
                .LOCKED(s_locked),             // 1-bit output: LOCK
                                               // Clock Inputs: 1-bit (each) input: Clock inputs
                .CLKIN1(clkin1),               // 1-bit input: Primary clock
                .CLKIN2(),                     // 1-bit input: Secondary clock
                                               // Control Ports: 1-bit (each) input: MMCM control ports
                .CLKINSEL(),                   // 1-bit input: Clock select, High=CLKIN1 Low=CLKIN2
                .PWRDWN(),                     // 1-bit input: Power-down
                .RST(in_reset),                // 1-bit input: Reset
                                               // DRP Ports: 7-bit (each) input: Dynamic reconfiguration ports
                .DADDR(),                      // 7-bit input: DRP address
                .DCLK(),                       // 1-bit input: DRP clock
                .DEN(),                        // 1-bit input: DRP enable
                .DI(),                         // 16-bit input: DRP data
                .DWE(),                        // 1-bit input: DRP write enable
                                               // Dynamic Phase Shift Ports: 1-bit (each) input: Ports used for dynamic phase shifting of the outputs
                .PSDONE(ps_done),              // 1-bit output: Phase shift done
                .PSCLK(in_fineps_clk),         // 1-bit input: Phase shift clock
                .PSEN(fineps_en),              // 1-bit input: Phase shift enable
                .PSINCDEC(fineps_incdec),      // 1-bit input: Phase shift increment/decrement
                                               // Feedback Clocks: 1-bit (each) input: Clock feedback ports
                .CLKFBIN(out_feedback_bufx)    // 1-bit input: Feedback clock
            );
        end
    endgenerate


endmodule