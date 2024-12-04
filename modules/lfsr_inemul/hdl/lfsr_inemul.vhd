    -- File "lfsr_inemul.vhd": Input generator based on a Galois Field in pulsed mode (return to zero)
    -- Engineer: Patrik Zahalka (patrik.zahalka@univie.ac.at; zahalka.patrik@gmail.com)
    -- More irreducible primitive polynomials: 
    -- https://link.springer.com/content/pdf/bbm%3A978-1-4615-1509-8%2F1.pdf

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    -- SRC Packages
    library lib_src;
    --     * Global project-specific SRC Packages
    use lib_src.const_pack.all;
    use lib_src.types_pack.all;
    use lib_src.signals_pack.all;

    entity lfsr_inemul is
        generic (
            RST_VAL                 : std_logic := '1';
            SYMBOL_WIDTH            : integer := 8; -- Channels count / Data width
            -- PRIM_POL_INT_VAL        : positive := 285; -- Too sparse field
            -- PRIM_POL_INT_VAL        : positive := 501;
            GF_SEED                 : positive := 1;
            DATA_PULLDOWN_ENABLE    : boolean := true;
            PULLDOWN_CYCLES         : positive := 2 -- min 2
        );
        port (
            -- In
            clk                     : in std_logic;
            rst                     : in std_logic;
            -- data_in                 : out std_logic_vector(IN_DATA_WIDTH-1 downto 0);
            -- valid_in                : in std_logic;

            -- Out
            ready                   : out std_logic;
            data_out                : out std_logic_vector(SYMBOL_WIDTH-1 downto 0);
            valid_out               : out std_logic
        );
    end lfsr_inemul;

    architecture rtl of lfsr_inemul is

        -------------------------------------------------------------------
        -- lfsr_inemul: Declare constants, subtypes, const functions
        -------------------------------------------------------------------
        -- ** USER INPUT
        -- Shiftreg: for data pulldown & prevent inferring carry logic
        constant SHIFTREG_WIDTH : positive := PULLDOWN_CYCLES+1;

        -- LFSR
        -- More irreducible primitive polynomials: 
        -- https://link.springer.com/content/pdf/bbm%3A978-1-4615-1509-8%2F1.pdf
        function incr_galois_cntr (
            slv_galois_cntr_feedback : std_logic_vector(SYMBOL_WIDTH-1 downto 0) := (others => '0');
            INT_PRIMPOL : positive
        ) return std_logic_vector is
            variable v_slv_galois_cntr : std_logic_vector(SYMBOL_WIDTH-1 downto 0) := (others => '0');
            variable v_slv_primpol : std_logic_vector(SYMBOL_WIDTH downto 0) := std_logic_vector(to_unsigned(INT_PRIMPOL, SYMBOL_WIDTH+1));
        begin
            -- Calculate a new iteration
            v_slv_galois_cntr(SYMBOL_WIDTH-1 downto 0) 
                := slv_galois_cntr_feedback(SYMBOL_WIDTH-2 downto 0) & '0';
            if slv_galois_cntr_feedback(SYMBOL_WIDTH-1) = '1' then
                v_slv_galois_cntr(SYMBOL_WIDTH-1 downto 0) 
                    := slv_galois_cntr_feedback(SYMBOL_WIDTH-2 downto 0) 
                        & '0' xor v_slv_primpol(SYMBOL_WIDTH-1 downto 0);
            end if;

            return v_slv_galois_cntr;
        end function;
        signal slv_main_counter_galois : std_logic_vector(SYMBOL_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(GF_SEED, SYMBOL_WIDTH)); -- NEW
        signal slv_main_counter_galois_feedback : std_logic_vector(SYMBOL_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(GF_SEED, SYMBOL_WIDTH)); -- NEW

        -- Assign a primitive polynomial based on counter width
        function get_int_primpol return positive is
            variable v_int_primpol : positive := 7;
        begin
            -- Set primitive polynomials for these bit widths
            if SYMBOL_WIDTH = 2 then v_int_primpol := 7; end if;
            if SYMBOL_WIDTH = 3 then v_int_primpol := 13; end if;
            if SYMBOL_WIDTH = 4 then v_int_primpol := 25; end if;
            if SYMBOL_WIDTH = 5 then v_int_primpol := 41; end if;
            if SYMBOL_WIDTH = 6 then v_int_primpol := 97; end if;
            if SYMBOL_WIDTH = 7 then v_int_primpol := 137; end if;
            if SYMBOL_WIDTH = 8 then v_int_primpol := 425; end if;
            if SYMBOL_WIDTH = 9 then v_int_primpol := 529; end if;
            if SYMBOL_WIDTH = 10 then v_int_primpol := 1033; end if;
            if SYMBOL_WIDTH = 11 then v_int_primpol := 2053; end if;
            if SYMBOL_WIDTH = 12 then v_int_primpol := 4179; end if;
            if SYMBOL_WIDTH = 13 then v_int_primpol := 8357; end if;
            if SYMBOL_WIDTH = 14 then v_int_primpol := 16553; end if;
            if SYMBOL_WIDTH = 15 then v_int_primpol := 32785; end if;
            if SYMBOL_WIDTH = 16 then v_int_primpol := 66193; end if;
            if SYMBOL_WIDTH = 17 then v_int_primpol := 131137; end if;
            if SYMBOL_WIDTH = 18 then v_int_primpol := 262273; end if;
            if SYMBOL_WIDTH = 19 then v_int_primpol := 524377; end if;
            if SYMBOL_WIDTH = 20 then v_int_primpol := 1048585; end if;
            if SYMBOL_WIDTH = 21 then v_int_primpol := 2097157; end if;

            -- Else, let the HW generation fail
            if SYMBOL_WIDTH < 2 then v_int_primpol := 1; end if;
            if SYMBOL_WIDTH > 21 then v_int_primpol := 1; end if;
            return v_int_primpol;
        end function;

        constant INT_PRIM_POL : positive := get_int_primpol; -- NEW
        -- constant PRIM_POL_BIT_VAL : std_logic_vector := std_logic_vector(to_unsigned(INT_PRIM_POL, SYMBOL_WIDTH+1));


        -------------------------------------------------------------------
        -- lfsr_inemul: Declare signals
        -------------------------------------------------------------------
        -- ** USER INPUT
        -- Pulses On and Off
        signal slv_data_out : std_logic_vector(SYMBOL_WIDTH-1 downto 0) := (others => '0');
        signal sl_valid : std_logic := '0';

        -- Shiftreg
        signal slv_shiftreg_trigger : std_logic_vector(SHIFTREG_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(1, SHIFTREG_WIDTH));

        -- LFSR
        signal slv_reg_act_rand_number : std_logic_vector(SYMBOL_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(GF_SEED, SYMBOL_WIDTH));
        -- signal slv_prev_rand_feedback : std_logic_vector(SYMBOL_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(GF_SEED, SYMBOL_WIDTH));

        -- 2-FF synchronizer / delay for better placement
        signal slv_2ff_data_out_p1 : std_logic_vector(SYMBOL_WIDTH-1 downto 0) := (others => '0');
        signal sl_2ff_valid_p1 : std_logic := '0';


        -------------------------------------------------------------------
        -- lfsr_inemul: Directives for synthesis and implementation
        -------------------------------------------------------------------
        -- ** USER INPUT
        attribute max_fanout : integer;
        attribute max_fanout of slv_2ff_data_out_p1 : signal is 1;

        attribute KEEP: string;
        attribute KEEP of slv_2ff_data_out_p1 : signal is "TRUE";

        -- attribute IOB: string;
        -- attribute IOB of s_buff_pulses_val_2 : signal is "TRUE";


    begin

        -- Requited by the simulator environment
        ready <= '1';


        -- Shift register for counting (do not infer carry logic)
        gen_pulldown_logic_true : if DATA_PULLDOWN_ENABLE = true generate
            proc_pulses_pulldown_true : process(clk)
            begin
                if rising_edge(clk) then
                    if rst = RST_VAL then
                        slv_shiftreg_trigger <= std_logic_vector(to_unsigned(1, SHIFTREG_WIDTH));
                        slv_data_out <= (others => '0');
                        sl_valid <= '0';
                    else

                        -- Default
                        slv_data_out <= (others => '0');
                        sl_valid <= '0';
                        slv_shiftreg_trigger(SHIFTREG_WIDTH-1 downto 0) <= slv_shiftreg_trigger(SHIFTREG_WIDTH-2 downto 0) & slv_shiftreg_trigger(SHIFTREG_WIDTH-1);

                        -- Make the output pulsed to create redges
                        if slv_shiftreg_trigger(slv_shiftreg_trigger'high) = '1' then
                            slv_data_out <= slv_reg_act_rand_number;
                            sl_valid <= '1';
                        end if;

                    end if;
                end if;
            end process;
        end generate;

        gen_pulldown_logic_false : if DATA_PULLDOWN_ENABLE = false generate
            slv_data_out <= slv_reg_act_rand_number;
            sl_valid <= '1';
        end generate;


        -- LFSR (Galois Counter with pulldown)
        proc_bit_pulse_gen_1 : process (clk)
        begin
            if rising_edge(clk) then
                -- OLD - incorrect slv_prev_rand_feedback behaviour
                -- if rst = RST_VAL then
                --     slv_reg_act_rand_number <= std_logic_vector(to_unsigned(GF_SEED, SYMBOL_WIDTH));
                --     slv_prev_rand_feedback <= std_logic_vector(to_unsigned(GF_SEED, SYMBOL_WIDTH));
                -- else

                --     -- Default
                --     slv_reg_act_rand_number(SYMBOL_WIDTH-1 downto 0) <= slv_prev_rand_feedback(SYMBOL_WIDTH-2 downto 0) & '0';
                --     slv_prev_rand_feedback <= slv_reg_act_rand_number;

                --     -- Galois Counter
                --     if slv_prev_rand_feedback(SYMBOL_WIDTH-1) = '1' then
                --         slv_reg_act_rand_number(SYMBOL_WIDTH-1 downto 0) <= slv_prev_rand_feedback(SYMBOL_WIDTH-2 downto 0) & '0' xor PRIM_POL_BIT_VAL(SYMBOL_WIDTH-1 downto 0);
                --     end if;

                -- end if;

                -- NEW
                if rst = RST_VAL then
                    slv_reg_act_rand_number <= std_logic_vector(to_unsigned(GF_SEED, SYMBOL_WIDTH));
                else
                    slv_reg_act_rand_number <= incr_galois_cntr(slv_reg_act_rand_number, INT_PRIM_POL);
                end if;
            end if;
        end process;


        -- 2-FF synchronizer / delay for better placement
        proc_buff_data_out : process (clk)
        begin
            if rising_edge(clk) then
                if rst = RST_VAL then
                    slv_2ff_data_out_p1 <= (others => '0');
                    data_out <= (others => '0');
                    sl_2ff_valid_p1 <= '0';
                    valid_out <= '0';
                else
                    -- 2FF Data
                    slv_2ff_data_out_p1 <= slv_data_out;
                    data_out <= slv_2ff_data_out_p1;
                    -- 2FF Valid
                    sl_2ff_valid_p1 <= sl_valid;
                    valid_out <= sl_2ff_valid_p1;
                end if;
            end if;
        end process;

    end architecture;
