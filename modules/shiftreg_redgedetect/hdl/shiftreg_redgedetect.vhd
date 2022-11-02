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

    -- Timing Closure Techniques: 
    -- https://www.physicaldesign4u.com/2020/05/time-stealing-and-difference-between.html
    --      Time Borrowing
    --              - get extra time for evaluation by taking it from the previous cycle
    --              - uses leftovers from previous cycles
    --              - using LATCHES & FLIP-FLOPS
    --              - Better for high-perforance designs, offer better flexibility than edge-triggered circuits
    --                because no clock requirements are needed from latches
    --              - Ideal for static logic in a two-phase clocking system latches
    --              - Traditionally used to reduce clock jitter and skew on maximal frequencies
    --              - method: adjusting clock arrival time by widening the active clock time
    --                        (using asymmetric duty cycle) for the capture Flip-Flop
    --                              -> shifting rising_edge earlier
    --                              -> shifting falling_edge later
    --      Time Stealing
    --              - get extra time for evaluation by taking it from the next cycle
    --              - next clock cycle thus must have positive slack!
    --              - can not use leftovers from previous cycles like in time borrowing
    --              - when dealing with SETUP violations
    --              - using FLIP-FLOPS (1x Positive-edge and Negative-edge)
    --              - also used to reduce leakage power
    --              - method: adjusting clock arrival time by widening the active clock time
    --                        (using asymmetric duty cycle) for the capture Flip-Flop
    --                              -> shifting rising_edge earlier
    --                              -> shifting falling_edge later

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
            BUFFER_PATTERN : positive := 1
        );
        port (
            clk : in  std_logic;

            out_ready : out std_logic;
            out_valid : out std_logic;

            in_noisy_channel : in  std_logic;

            out_event : out std_logic;
            out_pulsed : out std_logic
        );
    end qubit_deskew;

    architecture rtl of qubit_deskew is

        -- Signals
        signal sl_flops_databuff_1 : std_logic := '0';
        signal sl_flops_databuff_2 : std_logic := '0';

        signal slv_buff_data : std_logic_vector(BUFFER_DEPTH-1 downto 0);

        signal sl_out_valid : std_logic := '0';

        signal sl_channels_redge_event : std_logic := '0';
        signal sl_channels_redge_pulsed : std_logic := '0';

    begin


        -- This module is always ready to receive data
        out_ready <= '1';



        -- 2-FF Synchronizer
        proc_channel_databuff : process(clk)
        begin
            if rising_edge(clk) then
                sl_flops_databuff_1 <= in_noisy_channel;
                sl_flops_databuff_2 <= sl_flops_databuff_1;
            end if;
        end process;



        -- Raw input data buffering
        proc_channel_oversample : process(clk)
        begin
            if rising_edge(clk) then
                slv_buff_data(BUFFER_DEPTH-1 downto 0) <= slv_buff_data(BUFFER_DEPTH-2 downto 0) & sl_flops_databuff_2;
            end if;
        end process;



        -- Send an output (event / pulsed) if BUFFER_PATTERN detected on a the input channel
        out_event <= sl_channels_redge_event;
        out_pulsed <= sl_channels_redge_pulsed;
        out_valid <= sl_out_valid;
        proc_channel_redge_out : process(clk)
        begin
            if rising_edge(clk) then
                -- Defaults
                sl_channels_redge_event <= sl_channels_redge_event;
                sl_channels_redge_pulsed <= '0';
                sl_out_valid <= '0';

                if slv_buff_data(BUFFER_DEPTH-1 downto BUFFER_DEPTH-PATTERN_WIDTH) = std_logic_vector(to_unsigned(BUFFER_PATTERN, PATTERN_WIDTH)) then
                    sl_channels_redge_event <= not sl_channels_redge_event;
                    sl_channels_redge_pulsed <= '1';
                    sl_out_valid <= '1';
                end if;
            end if;
        end process;


    end architecture;