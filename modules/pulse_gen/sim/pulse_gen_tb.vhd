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

        constant REAL_CLK_HZ : real := 250.0e6;
        constant CLK_PERIOD : time := 1 sec / REAL_CLK_HZ;

        -- Generics
        constant RST_VAL    : std_logic := '1';
        constant DATA_WIDTH : integer := 2;
        constant PULSE_DURATION_HIGH_NS : integer := 100;
        constant PULSE_DURATION_LOW_NS : integer := 50;

        -- I/O ports
        signal CLK           : std_logic := '1';
        signal RST           : std_logic := '0';
        signal PULSE_TRIGGER : std_logic := '0';
        signal IN_DATA       : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
        signal PULSES_OUT    : std_logic_vector(DATA_WIDTH-1 downto 0);
        signal READY         : std_logic_vector(DATA_WIDTH-1 downto 0);
        signal BUSY          : std_logic_vector(DATA_WIDTH-1 downto 0);

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
            DATA_WIDTH => DATA_WIDTH,
            REAL_CLK_HZ => REAL_CLK_HZ,
            PULSE_DURATION_HIGH_NS => PULSE_DURATION_HIGH_NS,
            PULSE_DURATION_LOW_NS => PULSE_DURATION_LOW_NS
        )
        port map (
            CLK           => CLK,
            RST           => RST,
            PULSE_TRIGGER => PULSE_TRIGGER,
            IN_DATA       => IN_DATA,
            PULSES_OUT    => PULSES_OUT,
            READY         => READY,
            BUSY          => BUSY
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

            wait until rising_edge(CLK);
            PULSE_TRIGGER <= '1';
            IN_DATA <= (others => '1');
            wait for 0.5 us;

            wait until rising_edge(CLK);
            PULSE_TRIGGER <= '1';
            IN_DATA <= "01";
            wait for 0.5 us;

            wait until rising_edge(CLK);
            PULSE_TRIGGER <= '1';
            IN_DATA <= "10";
            wait for 0.5 us;

            wait until rising_edge(CLK);
            PULSE_TRIGGER <= '1';
            IN_DATA <= "00";
            wait for 0.5 us;

            print_test_ok;
            finish;
            wait;
        end process;

    end architecture;