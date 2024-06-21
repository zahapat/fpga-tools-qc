    -- charbuf.vhd: sampling incoming bits "IN_DATA"
    --              Reset will be ON when "1" -> will put "reg_buff_inbits" to zero
    --              Reset will be OFF when "0" -> reg_buff_inbits keeps loading IN_DATA if PULSE_TRIGGER = 1

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    entity pulse_gen is
        generic (
            RST_VAL                : std_logic := '1';
            DATA_WIDTH             : positive := 2; -- = Pulses count
            REAL_CLK_HZ            : real := 250.0e6;
            PULSE_DURATION_HIGH_NS : integer := 100;
            PULSE_DURATION_LOW_NS  : integer := 50
        );
        port (
            CLK           : in  std_logic;
            RST           : in  std_logic;
            PULSE_TRIGGER : in  std_logic;
            IN_DATA       : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            PULSES_OUT    : out std_logic_vector(DATA_WIDTH-1 downto 0);
            READY         : out std_logic_vector(DATA_WIDTH-1 downto 0);
            BUSY          : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end entity pulse_gen;

    architecture rtl of pulse_gen is

        signal slv_busy_flag : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

        signal s_cnt_set_high : std_logic_vector(PULSES_OUT'range) := (others => '0');
        signal s_cnt_set_low : std_logic_vector(PULSES_OUT'range) := (others => '0');

        constant CLK_PERIOD_NS : real := 
            (1.0/real(REAL_CLK_HZ) * 1.0e9);
        constant CLK_PERIODS_HIGH : natural :=
                natural( ceil(real(PULSE_DURATION_HIGH_NS) / CLK_PERIOD_NS) );
        constant CLK_PERIODS_LOW : natural :=
                natural( ceil(real(PULSE_DURATION_LOW_NS) / CLK_PERIOD_NS) );
        
        subtype st_periods_repetitions_high is natural range 0 to CLK_PERIODS_HIGH-1;
        subtype st_periods_repetitions_low is natural range 0 to CLK_PERIODS_LOW-1;

        type t_cnt_clk_high_2d is array(PULSES_OUT'range) of natural range 0 to st_periods_repetitions_high'high;
        type t_cnt_clk_low_2d is array(PULSES_OUT'range) of natural range 0 to st_periods_repetitions_low'high;
        signal s_cnt_clk_high_2d : t_cnt_clk_high_2d := (others => 0);
        signal s_cnt_clk_low_2d : t_cnt_clk_low_2d := (others => 0);
        signal s_pulses_val_high : std_logic_vector(PULSES_OUT'range) := (others => '0');
        signal s_pulses_val_low : std_logic_vector(PULSES_OUT'range) := (others => '0');
        signal s_pulses_val : std_logic_vector(PULSES_OUT'range) := (others => '0');



    begin

        ----------------------------
        -- Generate Output Pulses --
        ----------------------------
        PULSES_OUT <= s_pulses_val_high;
        READY <= not slv_busy_flag;
        BUSY <= slv_busy_flag;
        gen_pulses : for i in 0 to DATA_WIDTH-1 generate

            proc_bit_pulse_gen : process(CLK)
            begin
                if rising_edge(CLK) then
                    -- Default values
                    slv_busy_flag(i) <= '0';

                    -- Pulse high modelling
                    if slv_busy_flag(i) = '1' then
                        if s_cnt_clk_high_2d(i) = st_periods_repetitions_high'high then
                            s_cnt_clk_high_2d(i) <= s_cnt_clk_high_2d(i);
                            s_pulses_val_high(i) <= '0';
                            slv_busy_flag(i) <= '1';
                        else
                            s_cnt_clk_high_2d(i) <= s_cnt_clk_high_2d(i) + 1;
                            s_pulses_val_high(i) <= s_pulses_val(i);
                            slv_busy_flag(i) <= '1';
                        end if;
                    end if;

                    -- Dead time modelling
                    if s_cnt_clk_high_2d(i) = st_periods_repetitions_high'high then
                        if s_cnt_clk_low_2d(i) = st_periods_repetitions_low'high then
                            s_cnt_clk_low_2d(i) <= s_cnt_clk_low_2d(i);
                            s_pulses_val_low(i) <= '0';
                            slv_busy_flag(i) <= '0';
                        else
                            s_cnt_clk_low_2d(i) <= s_cnt_clk_low_2d(i) + 1;
                            s_pulses_val_low(i) <= '1';
                            slv_busy_flag(i) <= '1';
                        end if;
                    end if;

                    -- Set the counter and output data from 0 if '1' detected
                    if PULSE_TRIGGER = '1' and slv_busy_flag(i) = '0' then
                        s_cnt_clk_high_2d(i) <= 0;
                        s_cnt_clk_low_2d(i) <= 0;
                        s_pulses_val_high(i) <= IN_DATA(i);
                        slv_busy_flag(i) <= '1';
                        s_pulses_val(i) <= IN_DATA(i);
                    end if;

                end if;
            end process;

        end generate;

    end architecture;