    -- alu_flowambiguity_tb.vhd: Test file for component "alu_flowambiguity"

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    use std.textio.all;
    use std.env.finish;

    library lib_src;
    use lib_src.types_pack.all;

    entity alu_flowambiguity_tb is
    end alu_flowambiguity_tb;

    architecture sim of alu_flowambiguity_tb is

        -- Generics
        constant QUBITS_CNT : integer := 4;
        constant RST_VAL : std_logic := '1';
        constant SYNCH_FACTORS_CALCULATION : boolean := true;

        constant CLK_HZ      : natural := 80e6;
        constant PC_DELAY_US : natural := 1;      -- Duration of the pulse from PC in usec

        constant CLK_PERIOD : time := 1 sec / CLK_HZ;

        -- Signals
        signal CLK             : std_logic := '1';
        signal RST             : std_logic := RST_VAL;
        signal QUBIT_VALID     : std_logic := '0';
        signal STATE_QUBIT     : natural;
        signal S_X             : std_logic := '0';
        signal S_Z             : std_logic := '0';
        signal ALPHA_POSITIVE  : std_logic_vector(1 downto 0) := (others => '0');
        signal RAND_BIT        : std_logic  := '0';
        signal MATH_TO_MOD     : std_logic_vector(3 downto 0);
        signal RANDOM_BUFFER   : t_random_buffer_2d;
        signal MODULO_BUFFER   : t_modulo_buffer_2d;
        signal DATA_MODULO_OUT : std_logic_vector(1 downto 0);
        signal DATA_VALID      : std_logic;

        -- Number od random inputs INST_B
        constant MAX_RANDOM_NUMBS : natural := 300;

        -- Duration of reset strobe
        constant RST_DURATION : time := 10 * CLK_PERIOD;

        -- PI
        constant PI : natural := 2;

        -- Delay by 1 delta
        

        -- Print to console "TEST OK."
        procedure print_test_ok is
            variable str : line;
        begin
            write(str, string'("TEST OK."));
            writeline(output, str);
        end procedure;

    begin

        -- 1 delta delay


        -- Clk generator
        CLK <= not CLK after CLK_PERIOD / 2;

        -- DUT instance
        dut_alu_flowambiguity : entity lib_src.alu_flowambiguity(rtl)
        generic map (
            RST_VAL => RST_VAL
        )
        port map (
            CLK             => CLK,
            RST             => RST,
            QUBIT_VALID     => QUBIT_VALID,
            STATE_QUBIT     => STATE_QUBIT,
            S_X             => S_X,
            S_Z             => S_Z,
            ALPHA_POSITIVE  => ALPHA_POSITIVE,
            RAND_BIT        => RAND_BIT,
            RANDOM_BUFFER   => RANDOM_BUFFER,
            MODULO_BUFFER   => MODULO_BUFFER,
            DATA_MODULO_OUT => DATA_MODULO_OUT,
            DATA_VALID      => DATA_VALID
        );




        -- Sequencer
        proc_sequencer : process

            variable v_s_x : std_logic_vector(0 downto 0) := "0";
            variable v_s_z : std_logic_vector(0 downto 0) := "0";
            variable v_alpha : std_logic_vector(1 downto 0) := (others => '0');
            variable v_rand_bit : std_logic_vector(0 downto 0) := "0";
            variable v_left_result : integer;

            -- Required for uniform randomization procedure
            variable seed_1, seed_2 : integer := MAX_RANDOM_NUMBS;

            -- Random SLV generator
            impure function rand_slv (
                constant length : integer
            ) return std_logic_vector is
                variable r   : real;
                variable slv : std_logic_vector(length-1 downto 0);
            begin
                for i in slv'range loop
                    uniform(seed_1, seed_2, r);
                    slv(i) := '1' when r > 0.5 else '0';
                end loop;
                return slv;
            end function;

            -- Wait for given number of clock cycles
            procedure wait_cycles (
                constant cycles_cnt : integer
            ) is begin
                for i in 0 to cycles_cnt-1 loop
                    wait until rising_edge(CLK);
                end loop;
            end procedure;

        begin

            -- Reset strobe
            wait for RST_DURATION;

            -- Releasing reset
            RST <= not(RST_VAL);

            -- Exhaustive test
            report "Exhaustive test";
            loop
                loop
                    loop
                        loop
                            -- Send new data
                            QUBIT_VALID <= '1';
                            S_X <= v_s_x(0);
                            S_Z <= v_s_z(0);
                            ALPHA_POSITIVE <= v_alpha;
                            RAND_BIT <= v_rand_bit(0);

                            wait_cycles(1);
                            QUBIT_VALID <= '0';

                            -- Wait for the signal to propagate to output
                            wait until DATA_VALID = '1';
                            wait for 0 ns;
                            wait for 0 ns;

                            v_left_result := (((-1)**to_integer(unsigned(v_s_x)) * to_integer(unsigned(v_alpha)))
                                + (to_integer(unsigned(v_s_z)) + to_integer(unsigned(v_rand_bit)))*PI) mod 4;

                            assert to_integer(signed(DATA_MODULO_OUT)) = v_left_result
                                report "Error: Actual result is : " & integer'image(to_integer(signed(DATA_MODULO_OUT))) 
                                        & " . Expected result is : " & integer'image(v_left_result)
                                severity failure;

                            v_rand_bit := std_logic_vector(unsigned(v_rand_bit) + 1);
                            if unsigned(v_rand_bit) = 0 then
                                exit;
                            end if;
                        end loop;

                        v_alpha := std_logic_vector(unsigned(v_alpha) + 1);
                        if unsigned(v_alpha) = 0 then
                            exit;
                        end if;
                    end loop;

                    v_s_z := std_logic_vector(unsigned(v_s_z) + 1);
                    if unsigned(v_s_z) = 0 then
                        exit;
                    end if;
                end loop;

                v_s_x := std_logic_vector(unsigned(v_s_x) + 1);
                if unsigned(v_s_x) = 0 then
                    exit;
                end if;
            end loop;

            print_test_ok;
            finish;
            wait;
        end process;

    end architecture;