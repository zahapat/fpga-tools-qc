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
            -- Setup for 100 MHz sampling of 50 MHz pulses
            RST_VAL        : std_logic := '1';
            BUFFER_DEPTH   : positive := 5;
            PATTERN_WIDTH  : positive := 3;
            BUFFER_PATTERN : positive := 1;
            ZERO_BITS_CNT  : positive := 1;
            HIGH_BITS_CNT  : positive := 2;
            CLK_HZ         : natural := 250e6; -- Should be 2x higher than the input high pulse duration (10ns high pulse dur -> 2.5ns high sample pulse)

            CNT_ONEHOT_WIDTH          : positive := 2;  -- = LONG PULSE CLK CYCLES to keep a signal high for a long time 1xclk = 10 ns -> 2 x 10ns = 20 ns (does not exceed 32 ns => OK)
            DETECTOR_ACTIVE_PERIOD_NS : positive := 10;
            DETECTOR_DEAD_PERIOD_NS   : positive := 22;

            TOLERANCE_KEEP_FASTER_BIT_CYCLES : natural := 1;
            IGNORE_CYCLES_AFTER_TIMEUP       : natural := 2;

            PHOTON_H_DELAY_NS : real := -3177.95;        -- negative number = + delay
            PHOTON_V_DELAY_NS : real := -3181.05;

            PHOTON_COUNTER_WIDTH : positive := 2
        );
        port (
            clk : in  std_logic;
            rst : in  std_logic;
            noisy_channels_in : in std_logic_vector(2-1 downto 0);

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
            constant REAL_DELAY_HORIZ_ABS : real;
            constant REAL_DELAY_VERTI_ABS : real
        ) return real is
        begin
            -- Consistent logic with 'get_faster_photon_index'
            -- Faster = higher number (abs)
            if REAL_DELAY_HORIZ_ABS < REAL_DELAY_VERTI_ABS then
                return REAL_DELAY_VERTI_ABS;
            else
                return REAL_DELAY_HORIZ_ABS;
            end if;
        end function;

        impure function get_slower_photon_real (
            constant REAL_DELAY_HORIZ_ABS : real;
            constant REAL_DELAY_VERTI_ABS : real
        ) return real is
        begin
            -- Consistent logic with 'get_slower_photon_index'
            -- Faster = higher number (abs)
            if REAL_DELAY_HORIZ_ABS < REAL_DELAY_VERTI_ABS then
                return REAL_DELAY_HORIZ_ABS;
            else
                return REAL_DELAY_VERTI_ABS;
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
        constant TIME_DIFFERENCE_PHOTONS_NS_ABS : real := 
        --        higher vlaue              smaller value
            abs(FASTER_PHOTON_REAL_ABS - SLOWER_PHOTON_REAL_ABS);
        constant CLK_PERIODS_DIFFERENCE_DELAY_Q : natural :=
                natural( ceil(TIME_DIFFERENCE_PHOTONS_NS_ABS / CLK_PERIOD_NS) );
            -- constant CLK_PERIODS_DIFFERENCE_DELAY_Q : natural := ;



        -- Ranges for shifters
        subtype st_shifts_for_slower is natural range CLK_PERIODS_DIFFERENCE_DELAY_Q-1 + 2 + TOLERANCE_KEEP_FASTER_BIT_CYCLES downto 0;

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


        -- Use flops for raw data buffering
        all_channels_databuff : for i in 0 to CHANNELS_CNT-1 generate
            channel_databuff : process(clk)
            begin
                if rising_edge(clk) then
                    s_flops_databuff_1(i) <= noisy_channels_in(i);  -- Always pass input signal through a FlipFlop

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
                    s_buff_data(i)(BUFFER_DEPTH-1 downto 0) <= s_buff_data(i)(BUFFER_DEPTH-2 downto 0) & s_flops_databuff_5(i);
                end if;
            end process;
        end generate;



        -- Detect rising edge on all input channels
        all_channels_redge : for i in 0 to CHANNELS_CNT-1 generate
            channel_redge : process(clk)
            begin
                if rising_edge(clk) then
                    -- Defaults
                    s_channels_redge(i) <= '0';

                    -- IF (BUFFER_DEPTH = 3)
                    if s_buff_data(i)(BUFFER_DEPTH-1 downto BUFFER_DEPTH-PATTERN_WIDTH) = std_logic_vector(to_unsigned(BUFFER_PATTERN, PATTERN_WIDTH)) then
                        s_channels_redge(i) <= '1';
                    end if;
                end if;
            end process;
        end generate;



        ----- QUBIT DESKEW -----
        -- Delay: Start shifting faster bit and detect immediately slower bit
        align_valid_qubit : process(clk)
        begin
            if rising_edge(clk) then
                -- If the faster bit has already arrived
                if s_channels_redge(2*0 + FASTEST_EXPECTED_BIT_INDEX) = '1' then
                    s_shiftreg_counter_faster(s_shiftreg_counter_faster'length-1 downto 0) <= std_logic_vector(to_unsigned(1, s_shiftreg_counter_faster'length));
                else
                    s_shiftreg_counter_faster(s_shiftreg_counter_faster'length-1 downto 0) <= s_shiftreg_counter_faster(s_shiftreg_counter_faster'length-2 downto 0) & '0';
                end if;

                -- If the slower bit has already arrived
                s_slower_q1 <= '0';
                if s_channels_redge(2*0 + SLOWEST_EXPECTED_BIT_INDEX) = '1' then
                    s_slower_q1 <= '1';
                end if;
            end if;
        end process;


        -- Synchronization: Based on detected data in time, synchronize faster and slower bits
        output_aligned_qubit : process(clk)
        begin
            if rising_edge(clk) then
                -- If time is up for the next qubit, then it does not matter whether the slow is '1' or '0':
                --          1   (fast)
                --          1/0 (slow)
                -- If detected slow flag first, this means that the slow one is automatically '1' and depends on the content in the shifter of the faster one
                --          1   (slow)
                --          1/0 (fast)

                s_aligned_valid_q1_p1 <= s_aligned_valid_q1;
                s_aligned_valid_q1 <= '0';
                s_out_aligned_qubits(1 downto 0) <= (others => '0');
                s_ignore_nextvalid_q1(s_ignore_nextvalid_q1'length-1 downto 0) <= s_ignore_nextvalid_q1(s_ignore_nextvalid_q1'length-2 downto 0) & '0';

                if s_slower_q1 = '1' then 
                s_aligned_valid_q1 <= '1';
                    s_out_aligned_qubits(2*0 + SLOWEST_EXPECTED_BIT_INDEX) <= s_slower_q1;
                    s_ignore_nextvalid_q1 <= std_logic_vector(to_unsigned(1, s_ignore_nextvalid_q1'length));

                    if s_shiftreg_counter_faster(s_shiftreg_counter_faster'range) /= std_logic_vector(to_unsigned(0, s_shiftreg_counter_faster'length)) then
                        s_out_aligned_qubits(2*0 + FASTEST_EXPECTED_BIT_INDEX) <= '1';
                    end if;
                else
                    if s_shiftreg_counter_faster(s_shiftreg_counter_faster'length-1) = '1' then
                        s_aligned_valid_q1 <= '1';
                        s_out_aligned_qubits(2*0 + FASTEST_EXPECTED_BIT_INDEX) <= '1';
                    end if;
                end if;
            end if;
        end process;


        -- Filter out invalid aligned remaining aligned data
        qubit_valid_250MHz <= s_qubit_valid_out;
        qubit_250MHz(1 downto 0) <= s_stable_channels_oversampled(1 downto 0);
        output_synch_channel : process(clk)
        begin
            if rising_edge(clk) then
                s_stable_channels_oversampled(1 downto 0) <= (others => '0');
                    s_qubit_valid_out <= '0';
                    if s_aligned_valid_q1 = '1' and s_aligned_valid_q1_p1 = '0' then
                        if s_ignore_nextvalid_q1(s_ignore_nextvalid_q1'length-1 downto 1) = std_logic_vector(to_unsigned(0, s_ignore_nextvalid_q1'length-1)) then
                            s_stable_channels_oversampled(1 downto 0) <= s_out_aligned_qubits(1 downto 0);

                            s_qubit_valid_out <= '1';
                            
                        end if;
                    end if;
            end if;
        end process;


    end architecture;