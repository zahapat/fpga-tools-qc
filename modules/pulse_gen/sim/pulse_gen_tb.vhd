    -- pulse_gen_tb: Test file for the component pulse_gen.vhd

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use std.env.finish;
    use std.textio.all;

    library lib_src;

    entity pulse_gen_tb is
    end pulse_gen_tb;

    architecture sim of pulse_gen_tb is

        constant CLK_HZ : integer := 100e6;
        constant CLK_PERIOD : time := 1 sec / CLK_HZ;

        -- Generics
        constant RST_VAL    : std_logic := '1';
        constant DATA_WIDTH : integer := 2;

        -- I/O ports
        signal CLK      : std_logic := '1';
        signal RST      : std_logic := '0';
        signal WR       : std_logic := '0';
        signal IN_DATA  : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
        signal OUT_DATA : std_logic_vector(DATA_WIDTH-1 downto 0);

        -- Print to console "TEST OK."
        procedure print_test_ok is
            variable str : line;
        begin
            write(str, string'("TEST OK."));
            writeline(output, str);
        end procedure;

    begin

        -- DUT Instance
        dut_pulse_gen : entity lib_src.pulse_gen(rtl)
        generic map (
            RST_VAL    => RST_VAL,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            CLK        => CLK,
            RST        => RST,
            WR         => WR,
            IN_DATA    => IN_DATA,
            OUT_DATA   => OUT_DATA
        );

        --CLK generator
        CLK <= not CLK after CLK_PERIOD / 2;

        -- Sequencer
        proc_sequencer : process
            variable v_delayed_in_data : std_logic_vector(IN_DATA'range);
            variable v_all_data        : unsigned(IN_DATA'range) := (others => '0');
        begin
            -- RST strobe
            wait for 10 * CLK_PERIOD;

            -- release from reset
            RST <= not(RST_VAL);

            loop

                -- remember prev. IN_DATA 1 CLK ago
                v_delayed_in_data := IN_DATA;

                -- Enable writing new data
                WR <= '1';
                wait until rising_edge(CLK); -- All above will be effective before this event

                -- Don't write new data
                WR <= '0';

                -- Send data to input and wait for data to propagate to out
                IN_DATA <= std_logic_vector(v_all_data);
                wait until rising_edge(CLK);

                -- Self checking test (condition): check if not satisfied
                assert v_delayed_in_data = OUT_DATA
                    report "The DUT output does not equal last input after write."
                    severity failure;

                wait for 10 * CLK_PERIOD;

                assert v_delayed_in_data = OUT_DATA
                    report "The DUT output does not equal last input after write."
                    severity failure;

                -- Increment the input bit vector magnitude by 1
                v_all_data := v_all_data + 1;

                -- Exit the loop: Do the last test
                if v_all_data = 0 then

                    -- remember prev. IN_DATA 1 CLK ago
                    v_delayed_in_data := IN_DATA;

                    -- Enable writing new data
                    WR <= '1';
                    wait until rising_edge(CLK); -- All above will be effective before this event

                    -- Don't write new data
                    WR <= '0';

                    -- Send data to input and wait for data to propagate to out
                    IN_DATA <= std_logic_vector(v_all_data);
                    wait until rising_edge(CLK);

                    -- Self checking test (condition): check if not satisfied
                    assert v_delayed_in_data = OUT_DATA
                        report "The DUT output does not equal last input after write."
                        severity failure;

                    wait for 10 * CLK_PERIOD;

                    assert v_delayed_in_data = OUT_DATA
                        report "The DUT output does not equal last input after write."
                        severity failure;
                    exit;
                end if;

            end loop;

            
            print_test_ok;
            finish;
            wait;
        end process;

    end architecture;