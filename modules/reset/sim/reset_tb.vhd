    -- reset_tb.vhd: Testing of module reset.vhd

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use std.textio.all;
    use std.env.finish;

    -- Libraries, Packages
    library lib_src;


    entity reset_tb is
    end reset_tb;

    architecture sim of reset_tb is

        -- TB Constants
        constant CLK_HZ : integer := 80e6;
        constant CLK_PERIOD : time := 1 sec / CLK_HZ;

        -- Min and Max allowed duration of the reset strobe
        constant MIN_ALLOWED_DURATION : time := 20 * CLK_PERIOD;
        -- constant MAX_ALLOWED_DURATION : time := 30 * CLK_PERIOD;
        constant MAX_ALLOWED_DURATION : time := 100 us; -- more than 20 clk periods
        constant QUIET_DURATION       : time := 5 * MAX_ALLOWED_DURATION; -- To make sure that the module is not performing reset or going to perform reset

        -- DUT reset generics 
        constant RST_STROBE_COUNTER_WIDTH : integer := 8;

        -- DUT module ports
        signal clk     : std_logic := '1';
        signal in_rst  : std_logic := '1';  -- Pullup
        signal out_rst : std_logic;

        -- Print to console "TEST OK."
        procedure print_test_ok is
            variable str : line;
        begin
            write(str, string'("TEST OK."));
            writeline(output, str);
        end procedure;

    begin

        -- Reset module inst
        dut_reset : entity lib_src.reset(rtl)
        generic map (
            RST_STROBE_COUNTER_WIDTH => RST_STROBE_COUNTER_WIDTH
        )
        port map (
            CLK     => clk,
            IN_RST  => in_rst,  -- Pullup
            OUT_RST => out_rst
        );

        CLK <= not CLK after CLK_PERIOD / 2;

        proc_sequencer : process

            -- Check if the duration of the reset strobe is within min/max allowed duration
            procedure check_duration_rst is
            begin
                -- Prerequisite for running this procedure!
                assert out_rst = '1'
                    report "'out_rst' should be '1' before calling procedure 'check_duration_rst'."
                    severity failure;

                -- Don't change the value 'out_rst' for MIN_ALLOWED_DURATION
                wait on out_rst for MIN_ALLOWED_DURATION;

                -- Check if the value was really stable for the MIN_ALLOWED_DURATION
                assert out_rst'stable(MIN_ALLOWED_DURATION)
                    report "'out_rst' was stable for less than MIN_ALLOWED_DURATION: " & time'image(MIN_ALLOWED_DURATION)
                    severity failure;

                -- We can wait now for the rest = MAX_ALLOWED_DURATION; And, we have already waited for the MIN_ALLOWED_DURATION
                -- so we can subtract it
                wait for MAX_ALLOWED_DURATION - MIN_ALLOWED_DURATION;

                -- After the MAX_ALLOWED_DURATION, out_rst must be '0'
                assert out_rst = '0'
                    report "'out_rst' did not change back to '0' after MAX_ALLOWED_DURATION: " & time'image(MAX_ALLOWED_DURATION)
                    severity failure;

            end procedure;

            -- Test that a new reset strobe will be generated after the trigger signal 'in_rst' was grounded
            -- We don't call this procedure on the power-on
            procedure check_grounded_btn is
            begin

                -- Prerequisite for running this procedure!
                assert out_rst = '0'
                    report "'out_rst' should be '1' before calling procedure 'check_grounded_btn'."
                    severity failure;
                
                -- Make sure that the component is not in reset for quite a while
                wait for QUIET_DURATION;

                -- Check that there was no activity in 'out_rst' during QUIET_DURATION
                assert out_rst = '0' and out_rst'stable(QUIET_DURATION)
                    report "There should be no activity on 'out_rst' during past QUIET_DURATION: " & time'image(QUIET_DURATION)
                    severity failure;

                -- Press the reset button
                report "Triggering reset.";
                wait until rising_edge(clk);
                in_rst <= '0';                   -- reset btn press
                wait until rising_edge(clk);
                in_rst <= '1';                   -- reset btn release, back to idle (pullup)
                wait until rising_edge(clk);

                -- The reset strobe should be active now
                assert out_rst = '1'
                    report "The reset strobe is not active out_rst = '1' after reset button pulse 'in_rst' was triggered."
                    severity failure;

                -- Check for how long the reset was active
                check_duration_rst;

            end procedure;

        begin


            -----------------------
            -- ADD 1 DELTA CYCLE --
            -----------------------
            -- This will cause the FPGA to load initial values to its signals
            -- We need to create a time step for the following signal assignment/assertion to be planned to change its value
            wait for 0 ns;

            ----------------------------
            -- Test the initial value --
            ----------------------------
            assert out_rst = '1'
                report "The initial value of 'out_rst' was not asserted on simulation start = FPGA power-up."
                severity failure;


            -- Check that the reset last at least some number of clock cycles
            -- And that the duration does not exceed a fixed time value
            -- Check the duration of the power-on reset strobe:
            check_duration_rst;


            -- Test that a new reset strobe will be generated after the trigger signal 'in_rst' was grounded
            -- For two reset cycles = simulate two button presses
            check_grounded_btn;
            check_grounded_btn;


            wait for 1 us;

            print_test_ok;
            finish;
            wait;
        end process;

    end architecture;