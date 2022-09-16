    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use std.textio.all;
    use std.env.finish;

    library lib_src;

    entity lfsr_bitgen_tb is
    end lfsr_bitgen_tb;

    architecture sim of lfsr_bitgen_tb is

        constant CLK_HZ : integer := 80e6;
        constant CLK_PERIOD : time := 1 sec / CLK_HZ;

        -- Generics
        constant RST_VAL          : std_logic := '1';
        constant PRIM_POL_INT_VAL : positive := 19;
        constant SYMBOL_WIDTH     : positive := 4;
        constant GF_SEED          : positive := 1;

        -- Ports
        signal CLK      : std_logic := '1';
        signal RST      : std_logic := RST_VAL;
        signal RAND_BIT : std_logic;

        -- Bitwise representation of Galois Field Primitive Polynomial
        constant PRIM_POL_BIT_VAL : std_logic_vector(SYMBOL_WIDTH downto 0) := std_logic_vector(to_unsigned(PRIM_POL_INT_VAL, SYMBOL_WIDTH+1));

        -- Store the entire GF
        type t_arr_alpha is array(integer range <>) of std_logic_vector(SYMBOL_WIDTH-1 downto 0);
        function galois_field_generator (
            seed : in integer := 1
        )
        return std_logic_vector is
            variable store_alpha_root           : t_arr_alpha((2**SYMBOL_WIDTH)-1 downto 0) := (others => (others => '0'));
            variable store_alpha_root_bitvector : std_logic_vector(SYMBOL_WIDTH*(2**SYMBOL_WIDTH)-1 downto 0) := (others => '0');
        begin

            store_alpha_root(0)(SYMBOL_WIDTH-1 downto 0) := (others => '0');
            store_alpha_root(1)(SYMBOL_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(seed, SYMBOL_WIDTH));

            const_gf_roots : for i in 2 to (2**SYMBOL_WIDTH)-1 loop
                if store_alpha_root(i-1)(SYMBOL_WIDTH-1) = '1' then
                    store_alpha_root(i)(SYMBOL_WIDTH-1 downto 0) := (store_alpha_root(i-1)(SYMBOL_WIDTH-2 downto 0) & '0' xor PRIM_POL_BIT_VAL(SYMBOL_WIDTH-1 downto 0));
                else 
                    store_alpha_root(i)(SYMBOL_WIDTH-1 downto 0) := store_alpha_root(i-1)(SYMBOL_WIDTH-2 downto 0) & '0';
                end if;
            end loop const_gf_roots;

            create_bitvector : for i in 0 to (2**SYMBOL_WIDTH)-1 loop
                store_alpha_root_bitvector(i*(SYMBOL_WIDTH)+SYMBOL_WIDTH-1 downto i*(SYMBOL_WIDTH)) := store_alpha_root((2**SYMBOL_WIDTH)-1-i)(SYMBOL_WIDTH-1 downto 0);
            end loop create_bitvector;

            return store_alpha_root_bitvector(SYMBOL_WIDTH*(2**SYMBOL_WIDTH-1)-1 downto 0);

        end function;
    
        constant CONST_GF : std_logic_vector(SYMBOL_WIDTH*(2**SYMBOL_WIDTH-1)-1 downto 0) := galois_field_generator(GF_SEED);

        -- Print to console "TEST OK."
        procedure print_test_ok is
            variable str : line;
        begin
            write(str, string'("TEST OK."));
            writeline(output, str);
        end procedure;

    begin

        CLK <= not CLK after CLK_PERIOD / 2;

        dut : entity lib_src.lfsr_bitgen(rtl)
        generic map (
            RST_VAL          => RST_VAL,
            PRIM_POL_INT_VAL => PRIM_POL_INT_VAL,
            SYMBOL_WIDTH     => SYMBOL_WIDTH,
            GF_SEED          => GF_SEED
        )
        port map (
            CLK      => CLK,
            RST      => RST,
            RAND_BIT => RAND_BIT
        );

        proc_sequencer : process
            variable v_record_data : std_logic_vector(SYMBOL_WIDTH*(2**SYMBOL_WIDTH-1)-1 downto 0);
            -- variable v_cnt : integer := 0;
        begin

            -- Reset strobe
            wait for 10 * CLK_PERIOD;

            -- Assert inner registers to be reset correctly
            assert (<< signal dut.s_prev_rand_feedback : std_logic_vector(SYMBOL_WIDTH-1 downto 0) >> 
                and << signal dut.s_reg_act_rand_number : std_logic_vector(SYMBOL_WIDTH-1 downto 0) >>) = std_logic_vector(to_unsigned(GF_SEED, SYMBOL_WIDTH))
            report "Reset values of inner signals 's_prev_rand_feedback' and 's_reg_act_rand_number' are not "
                & integer'image(GF_SEED)
            severity failure;

            -- Assert output to be 0 after reset
            assert RAND_BIT = '0'
                report "Output RST_VAL is not zero after reset."
                severity failure;
            

            -- Releasing Reset
            RST <= not(RST_VAL);

            -- Wait for the generator to propagate data to out
            wait until rising_edge(CLK);
            wait until rising_edge(CLK);

            -- Record and assert pseudorandom output bits and compare them with the generated Galois Field symbol bits
            report "Test #1: After Reset";
            for i in SYMBOL_WIDTH*(2**SYMBOL_WIDTH-1)-1 downto 0 loop

                -- Severity Note for following bits because of the reset property causing shifted values
                if i > SYMBOL_WIDTH*(2**SYMBOL_WIDTH-2)-1 then
                    if RAND_BIT /= CONST_GF(i) then
                        assert false
                            report "Is: " & std_logic'image(RAND_BIT)
                               & "   Expected:" & std_logic'image(CONST_GF(i))
                               & "   Explanation: These bits differ because the reset sets registers to 1, which gives is a value 1 clk in advance and thus first fully valid symbol will be the next one."
                            severity note;
                    end if;
                end if;

                -- Severity Failure for the remaining bits
                if i <= SYMBOL_WIDTH*(2**SYMBOL_WIDTH-2)-1 then
                    if RAND_BIT /= CONST_GF(i) then
                        assert false
                            report "Is: " & std_logic'image(RAND_BIT)
                               & "   Expected:" & std_logic'image(CONST_GF(i))
                               & "   Explanation: Generated bits don't agree with the generated Galois Field in TB."
                            severity failure;
                    end if;
                end if;

                wait until rising_edge(CLK);
            end loop;

            -- Now, we should be able to load the entire Galois Field correctly
            report "Test #2: Normal operation";
            for i in SYMBOL_WIDTH*(2**SYMBOL_WIDTH-1)-1 downto 0 loop
                v_record_data(i) := RAND_BIT;
                wait until rising_edge(CLK);
            end loop;

            -- Assert correct functionality of the generator
            assert v_record_data = CONST_GF
                report "The entire generated Galois Field by the generator doesn't agree with the reference Galois Field in TB."
                severity failure;

            print_test_ok;
            finish;
            wait;
        end process;

    end architecture;