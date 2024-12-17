    -- shiftreg_delay_tb.vhd: Test file for component "delay.vhd"

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    library lib_src; -- contains the DUT delay.vhd

    use std.textio.all;
    use std.env.finish;

    entity shiftreg_delay_tb is
    end shiftreg_delay_tb;

    architecture sim of shiftreg_delay_tb is

        -- Clocks
        constant CLK_HZ : natural := 250e6;
        constant CLK_PERIOD : time := 1 sec / CLK_HZ;

        -- Generics
        constant RST_VAL : std_logic := '1';
        constant DATA_WIDTH : positive := 10;
        constant DELAY_CYCLES : natural := 0; -- If you specify DELAY_CYCLES (is greater than zero), then DELAY_NS value will be ignored
        constant DELAY_NS : natural := 0;      -- This value should be a multiple of clock period for precise results

        -- Signals
        signal clk : std_logic := '1';
        signal i_en : std_logic := '1';
        signal i_data : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
        signal o_data : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

        -- Duration of reset strobe
        constant RST_DURATION : time := 10 * CLK_PERIOD;

        -- Delay by 1 delta


        -- Print to console "TEST OK."
        procedure print_test_ok is
            variable str : line;
        begin
            write(str, string'("TEST OK."));
            writeline(output, str);
        end procedure;

    begin

        -- Clk generator
        clk <= not clk after CLK_PERIOD / 2;

        -- DUT instance
        dut_shiftreg_delay : entity lib_src.shiftreg_delay(rtl)
        generic map (
            RST_VAL => RST_VAL,
            DATA_WIDTH => DATA_WIDTH,
            DELAY_CYCLES => DELAY_CYCLES,
            DELAY_NS => DELAY_NS
        )
        port map (
            clk    => clk,
            i_en   => i_en,
            i_data => i_data,
            o_data => o_data
        );



        -- Sequencer
        proc_sequencer : process

            -- Wait for given number of clock cycles
            procedure wait_cycles (
                constant cycles_cnt : integer
            ) is begin
                if cycles_cnt = 0 then
                    null;
                else
                    for i in 0 to cycles_cnt-1 loop
                        wait until rising_edge(clk);
                    end loop;
                end if;
            end procedure;

            -- Wait for given number of delta cycles
            procedure wait_deltas (
                constant cycles_cnt : integer
            ) is begin
                if cycles_cnt = 0 then
                    null;
                else
                    for i in 0 to cycles_cnt-1 loop
                        wait for 0 ns;
                    end loop;
                end if;
            end procedure;

        begin

            -- Propagate initial values thorugh the design
            wait_cycles(20);

            -- Transmit some data to the DUT
            i_data <= (others => '1'); -- Send data (all ones)
            wait_cycles(DELAY_CYCLES); -- Wait for the required number of clock cycles
            wait_deltas(DELAY_CYCLES+3); -- Update delta cycles

            -- Test if the data is at the output (all ones)
            assert to_integer(unsigned(o_data)) = 2**DATA_WIDTH-1 
                report "Error: Actual result is : " & integer'image(to_integer(unsigned(o_data))) 
                    & " . Expected result is : " & integer'image(2**DATA_WIDTH-1)
                severity failure;

            -- Observe the behavior post assertion
            wait_cycles(20);
            wait_cycles(DELAY_CYCLES);
            wait_deltas(DELAY_CYCLES+3);

            -- Print OK if no error occurred
            print_test_ok;
            finish;
            wait;
        end process;

    end architecture;