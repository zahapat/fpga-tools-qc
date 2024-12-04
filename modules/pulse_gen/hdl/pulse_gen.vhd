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



        -- Assign a primitive polynomial based on counter width
        function get_int_primpol (
            SYMBOL_WIDTH : positive
        ) return positive is
            variable v_int_primpol : positive := 7;
        begin
            -- Set primitive polynomials for these bit widths
            if SYMBOL_WIDTH = 2 then v_int_primpol := 7; end if;  -- 0b111 OK
            if SYMBOL_WIDTH = 3 then v_int_primpol := 13; end if; -- 0b1101 OK
            if SYMBOL_WIDTH = 4 then v_int_primpol := 25; end if; -- 0b11001 OK
            if SYMBOL_WIDTH = 5 then v_int_primpol := 41; end if; -- 0b101001 perfect
            if SYMBOL_WIDTH = 6 then v_int_primpol := 97; end if; -- 0b1100001 OK
            if SYMBOL_WIDTH = 7 then v_int_primpol := 137; end if;-- 0b10001001 perfect
            if SYMBOL_WIDTH = 8 then v_int_primpol := 425; end if;-- 0b110101001 suboptimal
            if SYMBOL_WIDTH = 9 then v_int_primpol := 529; end if;-- 0b1000010001 perfect
            if SYMBOL_WIDTH = 10 then v_int_primpol := 1033; end if; -- 0b10000001001 perfect
            if SYMBOL_WIDTH = 11 then v_int_primpol := 2053; end if; -- 0b100000000101 perfect
            if SYMBOL_WIDTH = 12 then v_int_primpol := 6289; end if; -- 0b1100010010001 suboptimal
            if SYMBOL_WIDTH = 13 then v_int_primpol := 8357; end if; -- 0b10000010100101 suboptimal
            if SYMBOL_WIDTH = 14 then v_int_primpol := 16553; end if;-- 0b100000010101001 suboptimal
            if SYMBOL_WIDTH = 15 then v_int_primpol := 32785; end if;-- 0b1000000000010001 perfect
            if SYMBOL_WIDTH = 16 then v_int_primpol := 66193; end if;-- 0b10000001010010001 suboptimal
            if SYMBOL_WIDTH = 17 then v_int_primpol := 131137; end if;  -- 0b100000000001000001 perfect
            if SYMBOL_WIDTH = 18 then v_int_primpol := 262273; end if;  -- 0b1000000000010000001 perfect
            if SYMBOL_WIDTH = 19 then v_int_primpol := 524377; end if;  -- 0b10000000000001011001 bad
            if SYMBOL_WIDTH = 20 then v_int_primpol := 1048585; end if; -- 0b100000000000000001001 perfect
            if SYMBOL_WIDTH = 21 then v_int_primpol := 2097157; end if; -- 0b1000000000000000000101 perfect

            -- Else, let the HW generation fail
            if SYMBOL_WIDTH < 2 then v_int_primpol := 1; end if;
            if SYMBOL_WIDTH > 21 then v_int_primpol := 1; end if;
            return v_int_primpol;
        end function;

        constant MAX_PERIODS_DELAY_BITWIDTH_HIGH : positive := integer(ceil(log2(real(CLK_PERIODS_HIGH+1)))); -- NEW
        constant MAX_PERIODS_DELAY_BITWIDTH_LOW : positive := integer(ceil(log2(real(CLK_PERIODS_LOW+1)))); -- NEW

        constant INT_PRIM_POL_CNTR_HIGH : positive := get_int_primpol(MAX_PERIODS_DELAY_BITWIDTH_HIGH); -- NEW
        constant INT_PRIM_POL_CNTR_LOW : positive := get_int_primpol(MAX_PERIODS_DELAY_BITWIDTH_LOW); -- NEW


        -- NEW
        -- Galois Counter
        -- More irreducible primitive polynomials: 
        -- https://link.springer.com/content/pdf/bbm%3A978-1-4615-1509-8%2F1.pdf
        function incr_galois_cntr (
            int_galois_cntr_feedback : natural;
            SYMBOL_WIDTH : positive;
            INT_PRIMPOL : positive
        ) return std_logic_vector is
            variable v_slv_galois_cntr_feedback : std_logic_vector(SYMBOL_WIDTH-1 downto 0) := (others => '0');
            variable v_slv_galois_cntr : std_logic_vector(SYMBOL_WIDTH-1 downto 0) := (others => '0');
            variable v_slv_primpol : std_logic_vector(SYMBOL_WIDTH downto 0) := std_logic_vector(to_unsigned(INT_PRIMPOL, SYMBOL_WIDTH+1));
        begin
            -- Convert int to slv
            v_slv_galois_cntr_feedback := std_logic_vector(to_unsigned(int_galois_cntr_feedback, SYMBOL_WIDTH));
            
            -- Calculate a new iteration
            v_slv_galois_cntr(SYMBOL_WIDTH-1 downto 0) 
                := v_slv_galois_cntr_feedback(SYMBOL_WIDTH-2 downto 0) & '0';
            if v_slv_galois_cntr_feedback(SYMBOL_WIDTH-1) = '1' then
                v_slv_galois_cntr(SYMBOL_WIDTH-1 downto 0) 
                    := v_slv_galois_cntr_feedback(SYMBOL_WIDTH-2 downto 0) 
                        & '0' xor v_slv_primpol(SYMBOL_WIDTH-1 downto 0);
            end if;

            return v_slv_galois_cntr;
        end function;

        -- NEW
        function int_to_slvgalois (
            INT_TARGET_VALUE : natural;
            INT_SYMBOL_WIDTH : positive;
            INT_PRIMPOL : positive
        ) return std_logic_vector is
            variable v_slv_act_galois_cntr : std_logic_vector(INT_SYMBOL_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(1, INT_SYMBOL_WIDTH)); -- NEW
        begin
            -- if INT_TARGET_VALUE = 0 then return the first valid GF element (=v_slv_act_galois_cntr, which is 1)
            if INT_TARGET_VALUE > 0 then
                -- else if, for example, INT_TARGET_VALUE = 1, then increment v_slv_act_galois_cntr(=1) once (then then output will be 2)
                for i in 1 to INT_TARGET_VALUE-1 loop
                    v_slv_act_galois_cntr := incr_galois_cntr(to_integer(unsigned(v_slv_act_galois_cntr)), INT_SYMBOL_WIDTH, INT_PRIMPOL); -- NEW
                end loop;
            end if;
            return v_slv_act_galois_cntr;
        end function;

        type t_galois_cnt_clk_high_2d is array(PULSES_OUT'range) of std_logic_vector(MAX_PERIODS_DELAY_BITWIDTH_HIGH-1 downto 0);
        type t_galois_cnt_clk_low_2d is array(PULSES_OUT'range) of std_logic_vector(MAX_PERIODS_DELAY_BITWIDTH_LOW-1 downto 0);
        signal s_galois_cnt_clk_high_2d : t_galois_cnt_clk_high_2d := (others => (others => '0'));
        signal s_galois_cnt_clk_low_2d : t_galois_cnt_clk_low_2d := (others => (others => '0'));


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
                        -- if s_cnt_clk_high_2d(i) = st_periods_repetitions_high'high then
                        if s_galois_cnt_clk_high_2d(i) = int_to_slvgalois(CLK_PERIODS_HIGH, MAX_PERIODS_DELAY_BITWIDTH_HIGH, INT_PRIM_POL_CNTR_HIGH) then -- NEW
                            -- s_cnt_clk_high_2d(i) <= s_cnt_clk_high_2d(i);
                            s_galois_cnt_clk_high_2d(i) <= s_galois_cnt_clk_high_2d(i);
                            s_pulses_val_high(i) <= '0';
                            slv_busy_flag(i) <= '1';
                        else
                            -- s_cnt_clk_high_2d(i) <= s_cnt_clk_high_2d(i) + 1;
                            s_galois_cnt_clk_high_2d(i) <= incr_galois_cntr(to_integer(unsigned(s_galois_cnt_clk_high_2d(i))), MAX_PERIODS_DELAY_BITWIDTH_HIGH, INT_PRIM_POL_CNTR_HIGH);
                            s_pulses_val_high(i) <= s_pulses_val(i);
                            slv_busy_flag(i) <= '1';
                        end if;
                    end if;

                    -- Dead time modelling
                    -- if s_cnt_clk_high_2d(i) = st_periods_repetitions_high'high then
                    if s_galois_cnt_clk_high_2d(i) = int_to_slvgalois(CLK_PERIODS_HIGH, MAX_PERIODS_DELAY_BITWIDTH_HIGH, INT_PRIM_POL_CNTR_HIGH) then -- NEW

                        -- if s_cnt_clk_low_2d(i) = st_periods_repetitions_low'high then
                        if s_galois_cnt_clk_low_2d(i) = int_to_slvgalois(CLK_PERIODS_LOW, MAX_PERIODS_DELAY_BITWIDTH_LOW, INT_PRIM_POL_CNTR_LOW) then -- NEW
                            -- s_cnt_clk_low_2d(i) <= s_cnt_clk_low_2d(i);
                            s_galois_cnt_clk_low_2d(i) <= s_galois_cnt_clk_low_2d(i);
                            s_pulses_val_low(i) <= '0';
                            slv_busy_flag(i) <= '0';
                        else
                            -- s_cnt_clk_low_2d(i) <= s_cnt_clk_low_2d(i) + 1;
                            s_galois_cnt_clk_low_2d(i) <= incr_galois_cntr(to_integer(unsigned(s_galois_cnt_clk_low_2d(i))), MAX_PERIODS_DELAY_BITWIDTH_LOW, INT_PRIM_POL_CNTR_LOW);
                            s_pulses_val_low(i) <= '1';
                            slv_busy_flag(i) <= '1';
                        end if;
                    end if;

                    -- Set the counter and output data from 0 if '1' detected
                    if PULSE_TRIGGER = '1' and slv_busy_flag(i) = '0' then
                        -- s_cnt_clk_high_2d(i) <= 0;
                        -- s_cnt_clk_low_2d(i) <= 0;

                        s_galois_cnt_clk_high_2d(i) <= std_logic_vector(to_unsigned(1, MAX_PERIODS_DELAY_BITWIDTH_HIGH));
                        s_galois_cnt_clk_low_2d(i) <= std_logic_vector(to_unsigned(1, MAX_PERIODS_DELAY_BITWIDTH_LOW));

                        s_pulses_val_high(i) <= IN_DATA(i);
                        slv_busy_flag(i) <= '1';
                        s_pulses_val(i) <= IN_DATA(i);
                    end if;

                end if;
            end process;

        end generate;

    end architecture;