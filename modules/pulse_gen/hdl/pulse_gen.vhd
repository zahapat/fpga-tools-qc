    -- charbuf.vhd: sampling incoming bits "IN_DATA"
    --              Reset will be ON when "1" -> will put "reg_buff_inbits" to zero
    --              Reset will be OFF when "0" -> reg_buff_inbits keeps loading IN_DATA if PULSE_TRIGGER = 1

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    entity pulse_gen is
        generic (
            RST_VAL           : std_logic := '1';
            DATA_WIDTH        : positive := 2; -- = Pulses count
            REQUESTED_FREQ_HZ : real := 1.0e6;
            SYSTEMCLK_FREQ_HZ : real := 100.0e6
        );
        port (
            CLK           : in  std_logic;
            RST           : in  std_logic;
            PULSE_TRIGGER : in  std_logic;
            IN_DATA       : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            PULSES_OUT    : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end entity pulse_gen;

    architecture rtl of pulse_gen is

        constant HALF_PERIOD_CNTS : natural := natural((SYSTEMCLK_FREQ_HZ / REQUESTED_FREQ_HZ) / 2.0);

        subtype st_periods_repetitions is natural range 0 to HALF_PERIOD_CNTS-1;
        type t_cnt_clk_2d is array(PULSES_OUT'range) of natural range 0 to st_periods_repetitions'high;
        signal s_cnt_clk_2d : t_cnt_clk_2d := (others => 0);
        signal s_pulses_val : std_logic_vector(PULSES_OUT'range) := (others => '0');

        signal s_cnt_set : std_logic_vector(PULSES_OUT'range) := (others => '0');

    begin

        ----------------------------
        -- Generate Output Pulses --
        ----------------------------
        PULSES_OUT <= s_pulses_val;
        gen_pulses : for i in 0 to DATA_WIDTH-1 generate

            proc_bit_pulse_gen : process(CLK)
            begin
                if rising_edge(CLK) then
                    if RST = RST_VAL then
                        s_cnt_clk_2d(i) <= 0;
                        s_pulses_val(i) <= '0';
                        s_cnt_set(i) <= '0';
                    else

                        -- Default values
                        s_cnt_clk_2d(i) <= s_cnt_clk_2d(i);
                        s_pulses_val(i) <= s_pulses_val(i);
                        s_cnt_set(i) <= s_cnt_set(i);

                        -- Count and keep zero if necessary
                        if s_cnt_set(i) = '1' then
                            if s_cnt_clk_2d(i) = st_periods_repetitions'high then
                                s_cnt_clk_2d(i) <= s_cnt_clk_2d(i);
                                s_pulses_val(i) <= '0';
                                s_cnt_set(i) <= '0';
                            else
                                s_cnt_clk_2d(i) <= s_cnt_clk_2d(i) + 1;
                                s_pulses_val(i) <= '1';
                                s_cnt_set(i) <= s_cnt_set(i);
                            end if;
                        end if;

                        -- Set the counter and output data from 0 if '1' detected
                        if PULSE_TRIGGER = '1' and IN_DATA(i) = '1' then
                            s_cnt_clk_2d(i) <= 0;
                            s_pulses_val(i) <= '1';
                            s_cnt_set(i) <= '1';
                        end if;

                    end if;
                end if;
            end process;

        end generate;

    end architecture;