    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    -- library lib_src;

    entity shiftreg_redgedetect is
        generic (
            -- Setup for 100 MHz sampling of 50 MHz pulses
            INT_BUFFER_WIDTH   : positive := 3;
            INT_PATTERN_WIDTH  : positive := 3;
            INT_DETECT_PATTERN : positive := 3
        );
        port (
            clk : in  std_logic;

            out_ready : out std_logic;
            out_valid : out std_logic;

            in_noisy_channel : in  std_logic;

            out_event : out std_logic;
            out_pulsed : out std_logic
        );
    end shiftreg_redgedetect;

    architecture rtl of shiftreg_redgedetect is

        -- Signals
        signal sl_flops_databuff_1 : std_logic := '0';
        signal sl_flops_databuff_2 : std_logic := '0';

        signal slv_buff_data : std_logic_vector(INT_BUFFER_WIDTH-1 downto 0);

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
                slv_buff_data(INT_BUFFER_WIDTH-1 downto 0) <= slv_buff_data(INT_BUFFER_WIDTH-2 downto 0) & sl_flops_databuff_2;
            end if;
        end process;



        -- Send an output (event / pulsed) if INT_DETECT_PATTERN detected on a the input channel
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

                if slv_buff_data(INT_BUFFER_WIDTH-1 downto INT_BUFFER_WIDTH-INT_PATTERN_WIDTH) = std_logic_vector(to_unsigned(INT_DETECT_PATTERN, INT_PATTERN_WIDTH)) then
                    sl_channels_redge_event <= not sl_channels_redge_event;
                    sl_channels_redge_pulsed <= '1';
                    sl_out_valid <= '1';
                end if;
            end if;
        end process;


    end architecture;