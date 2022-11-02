    -- johnson_cnt.vhd: This component serves for detecting a rising edge of a signal
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

    entity johnson_cnt is
        generic (
            RST_VAL         : std_logic := '1';
            JOHNS_CNT_WIDTH : natural := 3
        );
        port (
            clk : in  std_logic;
            rst : in  std_logic;

            out_ready : out std_logic;
            out_valid : out std_logic;

            in_event : in std_logic;
            out_data : out std_logic_vector(JOHNS_CNT_WIDTH-1 downto 0)
        );
    end johnson_cnt;

    architecture rtl of johnson_cnt is

        -- Signals
        signal sl_channels_redge_event : std_logic := '0';
        signal sl_channels_redge_event_p1 : std_logic := '0';
        signal slv_johnson_counter : std_logic_vector(JOHNS_CNT_WIDTH-1 downto 0) := (others => '0');
        signal sl_out_valid : std_logic := '0';

        -- Increment Johnson Counter
        procedure incr_johnson_counter (signal johnson_counter : inout std_logic_vector(JOHNS_CNT_WIDTH-1 downto 0))
        is
        begin
            johnson_counter(johnson_counter'high downto 0) <=
                johnson_counter(johnson_counter'high-1 downto 0) 
                & not johnson_counter(johnson_counter'high);
        end procedure;

    begin


        -- This module is always ready to receive data
        out_ready <= '1';


        -- Johnson counter increments on each signal change (both '1'->'0' and '0'->'1')
        sl_channels_redge_event <= in_event;
        out_data <= slv_johnson_counter;
        out_valid <= sl_out_valid;
        proc_click_counter : process(clk)
        begin
            if rising_edge(clk) then
                if rst = RST_VAL then
                    sl_channels_redge_event_p1 <= '0';
                    sl_out_valid <= '0';
                    slv_johnson_counter <= (others => '0');

                else
                    -- Defaults
                    sl_channels_redge_event_p1 <= sl_channels_redge_event;
                    sl_out_valid <= '0';

                    -- If there is an event on "sl_channels_redge" signal
                    if sl_channels_redge_event /= sl_channels_redge_event_p1 then
                        incr_johnson_counter(slv_johnson_counter);
                        sl_out_valid <= '1';
                    end if;
                end if;
            end if;
        end process;


    end architecture;