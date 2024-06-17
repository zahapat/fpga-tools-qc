    -- qubit_deskew.vhd: This component serves for detecting a rising edge of a signal
    --                                  which is coming from a noisy environment from the outside
    --                                  of the chip, and is being synchronized with the system clk.
    --                                  This component checks for the following pattern:
    --                                                     0 0 0    ? ? ?    0 1 1
    --                                                    |0|0|0|   0|1|0   |0|1|1|
    --                                                      idle    metast.  redge
    --                                  Due to the metastable states on the input, we have to be patient
    --                                  for non-stable values of the input signal until they are fully stable
    --                                  If the pattern shown above has been found, a pulse lasting CNT_ONEHOT_WIDTH
    --                                  will be sent to the output, for each channel respecitvely.


    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    -- library lib_src;

    entity qubit_deskew is
        generic (
            RST_VAL        : std_logic := '1';
            BUFFER_DEPTH   : positive := 3;
            PATTERN_WIDTH  : positive := 3;
            BUFFER_PATTERN : positive := 1;
            CLK_HZ         : real := 250.0e6; -- Should be 2x higher than the input high pulse duration (10ns high pulse dur -> 2.5ns high sample pulse)

            CNT_ONEHOT_WIDTH          : positive := 2;  -- = LONG PULSE CLK CYCLES to keep a signal high for a long time 1xclk = 10 ns -> 2 x 10ns = 20 ns (does not exceed 32 ns => OK)
            DETECTOR_ACTIVE_PERIOD_NS : positive := 10;
            DETECTOR_DEAD_PERIOD_NS   : positive := 22;

            TOLERANCE_KEEP_FASTER_BIT_CYCLES : natural := 0;
            IGNORE_CYCLES_AFTER_TIMEUP       : natural := 3; -- should be ~ BUFFER_DEPTH + 1

            PHOTON_H_DELAY_NS : real := -3177.95;        -- negative number = + delay
            PHOTON_V_DELAY_NS : real := -3181.05;

            PHOTON_COUNTER_WIDTH : positive := 2
        );
        port (
            clk : in  std_logic;
            rst : in  std_logic;
            noisy_channels_in : in std_logic_vector(2-1 downto 0);

            channels_redge_synchronized : out std_logic_vector(2-1 downto 0);

            qubit_valid_250MHz : out std_logic;
            qubit_250MHz : out std_logic_vector(2-1 downto 0)
        );
    end qubit_deskew;

    architecture rtl of qubit_deskew is

        -- Compare which bit arrives the first
        impure function get_faster_photon_index (
            constant REAL_DELAY_HORIZ_ABS : real;
            constant REAL_DELAY_VERTI_ABS : real
        ) return integer is
        begin
            -- Faster = higher number (abs)
            if REAL_DELAY_HORIZ_ABS < REAL_DELAY_VERTI_ABS then
                return 1;
            else
                return 0;
            end if;
        end function;

        -- Compare which photon arrives the second
        impure function get_slower_photon_index (
            constant REAL_DELAY_HORIZ_ABS : real;
            constant REAL_DELAY_VERTI_ABS : real
        ) return integer is
        begin
            -- Faster = higher number (abs)
            if REAL_DELAY_HORIZ_ABS < REAL_DELAY_VERTI_ABS then
                return 0;
            else
                return 1;
            end if;
        end function;


        -- Data buffer: Disable creating SRL primitives for timing closure
        constant CHANNELS_CNT   : positive := 2;
        type t_buff_data is array(CHANNELS_CNT-1 downto 0) of std_logic_vector(BUFFER_DEPTH-1 downto 0);
        signal s_buff_data : t_buff_data := (others => (others => '0'));
        attribute SHREG_EXTRACT : string;
        attribute SHREG_EXTRACT of s_buff_data: signal is "FALSE";


        -- Detect rising edge
        signal s_channels_redge : std_logic_vector(CHANNELS_CNT-1 downto 0) := (others => '0');


        -- Get absolute values: conversion ns to us
        constant PHOTON_H_DELAY_US_REAL_ABS : real := abs(PHOTON_H_DELAY_NS)/1000.0;
        constant PHOTON_V_DELAY_US_REAL_ABS : real := abs(PHOTON_V_DELAY_NS)/1000.0;


        impure function get_faster_photon_real (
            constant REAL_DELAY_A_ABS : real;
            constant REAL_DELAY_B_ABS : real
        ) return real is
        begin
            -- Consistent logic with 'get_faster_photon_index'
            -- Faster = higher number (abs)
            if abs(REAL_DELAY_A_ABS) > abs(REAL_DELAY_B_ABS) then
                return abs(REAL_DELAY_B_ABS);
            else
                return abs(REAL_DELAY_A_ABS);
            end if;
        end function;

        impure function get_slower_photon_real (
            constant REAL_DELAY_A_ABS : real;
            constant REAL_DELAY_B_ABS : real
        ) return real is
        begin
            -- Consistent logic with 'get_slower_photon_index'
            -- Faster = higher number (abs)
            if abs(REAL_DELAY_A_ABS) < abs(REAL_DELAY_B_ABS) then
                return abs(REAL_DELAY_B_ABS);
            else
                return abs(REAL_DELAY_A_ABS);
            end if;
        end function;

        constant PHOTON_H_DELAY_NS_REAL_ABS : real := abs(PHOTON_H_DELAY_NS);
        constant PHOTON_V_DELAY_NS_REAL_ABS : real := abs(PHOTON_V_DELAY_NS);

        constant SLOWER_PHOTON_REAL_ABS : real := 
            get_slower_photon_real(
                PHOTON_H_DELAY_NS_REAL_ABS, 
                PHOTON_V_DELAY_NS_REAL_ABS
        );
        constant FASTER_PHOTON_REAL_ABS : real := 
            get_faster_photon_real(
                PHOTON_H_DELAY_NS_REAL_ABS, 
                PHOTON_V_DELAY_NS_REAL_ABS
        );

        constant CLK_PERIOD_NS : real := 
            (1.0/real(CLK_HZ) * 1.0e9);

        constant TIME_DIFFERENCE_PHOTONS_NS_ABS : real := -- higher vlaue - smaller value
            SLOWER_PHOTON_REAL_ABS-FASTER_PHOTON_REAL_ABS;

        constant CLK_PERIODS_DIFFERENCE_DELAY_Q : natural :=
                natural( ceil(TIME_DIFFERENCE_PHOTONS_NS_ABS / CLK_PERIOD_NS) );
        
        -- Ceil function may increase the difference from the target and generated delay
        impure function correct_periods (
            constant CLK_PERIODS : natural;
            constant CLK_PERIOD_NS : real;
            constant REAL_TARGET_VALUE : real
        ) return natural is
            variable v_periods_plus_one : real := CLK_PERIOD_NS * real(CLK_PERIODS+1);
            variable v_periods_plus_one_abserror : real;

            variable v_periods_actual : real := CLK_PERIOD_NS * real(CLK_PERIODS);
            variable v_periods_actual_abserror : real;

            variable v_periods_minus_one : real := CLK_PERIOD_NS * real(CLK_PERIODS-1);
            variable v_periods_minus_one_abserror : real;
        begin
            -- Compare differences from each case and select the minimum error
            if REAL_TARGET_VALUE < v_periods_plus_one then
                v_periods_plus_one_abserror := v_periods_plus_one - REAL_TARGET_VALUE;
            else
                v_periods_plus_one_abserror := REAL_TARGET_VALUE - v_periods_plus_one;
            end if;

            if REAL_TARGET_VALUE < v_periods_actual then
                v_periods_actual_abserror := v_periods_actual - REAL_TARGET_VALUE;
            else
                v_periods_actual_abserror := REAL_TARGET_VALUE - v_periods_actual;
            end if;

            if REAL_TARGET_VALUE < v_periods_minus_one then
                v_periods_minus_one_abserror := v_periods_minus_one - REAL_TARGET_VALUE;
            else
                v_periods_minus_one_abserror := REAL_TARGET_VALUE - v_periods_minus_one;
            end if;

            -- If CLK_PERIODS+1 gives less error
            if v_periods_plus_one_abserror < v_periods_actual_abserror then
                if v_periods_plus_one_abserror < v_periods_minus_one_abserror then
                    return CLK_PERIODS + 1;
                end if;
            end if;

            -- If CLK_PERIODS-1 gives less error
            if v_periods_minus_one_abserror < v_periods_actual_abserror then
                if v_periods_minus_one_abserror < v_periods_plus_one_abserror then
                    return CLK_PERIODS - 1;
                end if;
            end if;

            -- Otherwise keep ceil value
            return CLK_PERIODS;

        end function;

        -- constant CLK_PERIODS : natural;
        -- constant CLK_PERIOD_NS : real;
        -- constant REAL_TARGET_VALUE : real
        constant CLK_PERIODS_DIFFERENCE_DELAY_CORR : natural :=
            correct_periods(
                CLK_PERIODS_DIFFERENCE_DELAY_Q, 
                CLK_PERIOD_NS, 
                TIME_DIFFERENCE_PHOTONS_NS_ABS
            );



        -- Ranges for shifters
        -- subtype st_shifts_for_slower is natural range CLK_PERIODS_DIFFERENCE_DELAY_Q-1 + 2 + TOLERANCE_KEEP_FASTER_BIT_CYCLES downto 0;
        -- subtype st_shifts_for_slower is natural range CLK_PERIODS_DIFFERENCE_DELAY_Q-1 + TOLERANCE_KEEP_FASTER_BIT_CYCLES downto 0;
        subtype st_shifts_for_slower is natural range CLK_PERIODS_DIFFERENCE_DELAY_Q+2 downto 0;

        -- Buffering detected faster data
        signal s_shiftreg_counter_faster : std_logic_vector(st_shifts_for_slower) := (others => '0');

        -- Detected slower data
        signal s_slower_q1 : std_logic := '0';


        -- Output aligned qubits
        signal s_out_aligned_qubits  : std_logic_vector(CHANNELS_CNT-1 downto 0) := (others => '0');
        signal s_aligned_valid_q1    : std_logic := '0';
        signal s_aligned_valid_q1_p1 : std_logic := '0';

        signal s_qubit_valid_out : std_logic := '0';
        signal s_stable_channels_oversampled : std_logic_vector(CHANNELS_CNT-1 downto 0) := (others => '0');

        -- Prevent Xs in sim
        signal sl_qubit_valid_250MHz : std_logic := '0';
        signal slv_qubit_250MHz : std_logic_vector(qubit_250MHz'range) := (others => '0');


        -- Ignore slower bits if time for the slower bit is up
        signal s_ignore_nextvalid_q1 : std_logic_vector(IGNORE_CYCLES_AFTER_TIMEUP-1 downto 0) := (others => '0');

        constant FASTEST_EXPECTED_BIT_INDEX : natural := get_faster_photon_index(PHOTON_H_DELAY_US_REAL_ABS, PHOTON_V_DELAY_US_REAL_ABS);
        constant SLOWEST_EXPECTED_BIT_INDEX : natural := get_slower_photon_index(PHOTON_H_DELAY_US_REAL_ABS, PHOTON_V_DELAY_US_REAL_ABS);

        -- Use flip-flops instead of a distributed ram
        signal s_flops_databuff_1 : std_logic_vector(CHANNELS_CNT-1 downto 0) := (others => '0');
        signal s_flops_databuff_2 : std_logic_vector(CHANNELS_CNT-1 downto 0) := (others => '0');
        signal s_flops_databuff_3 : std_logic_vector(CHANNELS_CNT-1 downto 0) := (others => '0');
        signal s_flops_databuff_4 : std_logic_vector(CHANNELS_CNT-1 downto 0) := (others => '0');
        signal s_flops_databuff_5 : std_logic_vector(CHANNELS_CNT-1 downto 0) := (others => '0');

        -- Directive for Synthesis: register is capable of receiving asynchronous data in the D input pin relative to the source clock, 
        --     or that the register is a synchronizing register within a synchronization chain.
        attribute ASYNC_REG : string;
        -- attribute ASYNC_REG of s_flops_databuff_1 : signal is "TRUE";
        -- attribute ASYNC_REG of s_ff_timesteal : signal is "TRUE";

        -- attribute ASYNC_REG of s_latch_datakeep_1 : signal is "TRUE";
        -- attribute ASYNC_REG of s_latch_datakeep_2 : signal is "TRUE";

        attribute IOB: string;
        -- attribute IOB of s_flops_databuff_1 : signal is "TRUE";

        -- attribute KEEP: string;
        -- attribute IOB of s_flops_databuff_1 : signal is "TRUE";
        -- attribute ASYNC_REG of s_flops_databuff_2 : signal is "TRUE";
        -- attribute ASYNC_REG of s_flops_databuff_3 : signal is "TRUE";
        -- attribute ASYNC_REG of s_flops_databuff_4 : signal is "TRUE";
        -- attribute ASYNC_REG of s_flops_databuff_5 : signal is "TRUE";

        -- attribute max_fanout : integer;
        -- attribute max_fanout of s_flops_databuff_1 : signal is 1;

    begin

        --                  32 ns
        --        <----------------------->
        --     | 0 | 0 | 0 | 0 | 0 | 1 | 1 |
        --      <-----------------> <----->
        --          25 ns            10 ns


        -- Hypothetical scenario of sampling data (250 MHz):
        --   | 0 | 0 | 1 | (not sampled yet)
        --   | 0 | 1 | 1 | (= keyword for sampling)
        --   | 1 | 1 | 0 | (no phase shift) (sampled)
        --   | 1 | 0 | 0 |
        --   | 0 | 0 | 0 |
        --   | 0 | 0 | 0 |
        --   | 0 | 0 | 0 |
        --   | 0 | 0 | 0 |
        --   | 0 | 0 | 0 |
        --   | 0 | 0 | 1 | (not sampled yet)
        --   | 0 | 1 | 1 | (= keyword for sampling)
        --   | 1 | 1 | 1 | (phase shift)
        --   | 1 | 1 | 0 |
        --   | 1 | 0 | 0 |
        --   | 0 | 0 | 0 |


        -----------------------
        -- RISING EDGE LOGIC --
        -----------------------
        -- Use flops for raw data buffering (do not use registers)
        all_channels_databuff : for i in 0 to CHANNELS_CNT-1 generate
            channel_databuff : process(clk)
            begin
                if rising_edge(clk) then
                    s_flops_databuff_1(i) <= noisy_channels_in(i);  -- Always pass input signal through one of two a flipflops

                    s_flops_databuff_2(i) <= s_flops_databuff_1(i);
                    s_flops_databuff_3(i) <= s_flops_databuff_2(i);
                    s_flops_databuff_4(i) <= s_flops_databuff_3(i); -- Invert in case of pull-up logic
                    s_flops_databuff_5(i) <= s_flops_databuff_4(i);
                end if;
            end process;
        end generate;


        -- Raw input data buffering
        all_channels_oversample : for i in 0 to CHANNELS_CNT-1 generate
            channel_oversample : process(clk)
            begin
                if rising_edge(clk) then
                    -- s_buff_data(i)(BUFFER_DEPTH-1 downto 0) <= s_buff_data(i)(BUFFER_DEPTH-2 downto 0) & s_flops_databuff_5(i); -- Original
                    s_buff_data(i)(BUFFER_DEPTH-1 downto 0) <= s_buff_data(i)(BUFFER_DEPTH-2 downto 0) & s_flops_databuff_1(i);
                end if;
            end process;
        end generate;


        -- Detect rising edge on all input channels
        channels_redge_synchronized <= s_channels_redge;
        all_channels_redge : for i in 0 to CHANNELS_CNT-1 generate
            channel_redge : process(clk)
            begin
                if rising_edge(clk) then
                    -- Defaults
                    s_channels_redge(i) <= '0';

                    -- Search for match pattern
                    if s_buff_data(i)(BUFFER_DEPTH-1 downto BUFFER_DEPTH-PATTERN_WIDTH) = std_logic_vector(to_unsigned(BUFFER_PATTERN, PATTERN_WIDTH)) then
                        s_channels_redge(i) <= '1';
                    end if;
                end if;
            end process;
        end generate;



        --------------------------------
        -- INPUT FILTERING & DESKEW  --
        --------------------------------
        qubit_250MHz <= slv_qubit_250MHz;
        qubit_valid_250MHz <= sl_qubit_valid_250MHz;
        gen_if_photons_diff_delays : if PHOTON_H_DELAY_NS /= PHOTON_V_DELAY_NS generate
            -- Delay: Start shifting faster bit and detect immediately slower bit
            s_shiftreg_counter_faster(0) <= s_channels_redge(2*0 + FASTEST_EXPECTED_BIT_INDEX);
            align_valid_qubit : process(clk)
            begin
                if rising_edge(clk) then
                    -- -- If the faster bit has already arrived
                    -- if s_channels_redge(2*0 + FASTEST_EXPECTED_BIT_INDEX) = '1' then
                    --     s_shiftreg_counter_faster(s_shiftreg_counter_faster'length-1 downto 0) <= std_logic_vector(to_unsigned(1, s_shiftreg_counter_faster'length));
                    -- else
                    --     s_shiftreg_counter_faster(s_shiftreg_counter_faster'length-1 downto 0) <= s_shiftreg_counter_faster(s_shiftreg_counter_faster'length-2 downto 0) & '0';
                    -- end if;

                    -- Delay the rising edge of the fast photon
                    s_shiftreg_counter_faster(s_shiftreg_counter_faster'length-1 downto 1) <= s_shiftreg_counter_faster(s_shiftreg_counter_faster'length-2 downto 0);

                end if;
            end process;

            -- EXPERIMENTAL
            -- Synchronization: Based on detected data in time, synchronize faster and slower bits
            -- Note: It is expected that qubit_valid_250MHz will be asserted for two consecutive clock cycles
            --       (with valid qubit_250MHz H/V click) in case the system clock is not phase locked
            output_deskew_photons : process(clk)
            begin
                if rising_edge(clk) then
                    sl_qubit_valid_250MHz <= s_shiftreg_counter_faster(CLK_PERIODS_DIFFERENCE_DELAY_CORR) or s_channels_redge(2*0 + SLOWEST_EXPECTED_BIT_INDEX);
                    slv_qubit_250MHz <= (s_shiftreg_counter_faster(CLK_PERIODS_DIFFERENCE_DELAY_CORR) & s_channels_redge(2*0 + SLOWEST_EXPECTED_BIT_INDEX));
                end if;
            end process;
        end generate;

        gen_if_photons_equal_delays : if PHOTON_H_DELAY_NS = PHOTON_V_DELAY_NS generate
            sl_qubit_valid_250MHz <= s_channels_redge(0) or s_channels_redge(1);
            slv_qubit_250MHz <= s_channels_redge;
        end generate;


    end architecture;