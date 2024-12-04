    -- xilinx_sdr_sampler_tb: Testbench of the component xilinx_sdr_sampler.vhd

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use std.env.finish;
    use std.textio.all;

    library lib_src;

    entity xilinx_sdr_sampler_tb is
    end xilinx_sdr_sampler_tb;

    architecture sim of xilinx_sdr_sampler_tb is

        constant REAL_CLK_HZ : real := 600.0e6;
        constant CLK_PERIOD : time := 1.0 sec / REAL_CLK_HZ;

        constant IDELAY_REAL_CLK_HZ : real := 200.0e6;
        constant IDELAY_CLK_PERIOD : time := 1.0 sec / REAL_CLK_HZ;

        -- Generics
        constant SELECT_PRIMITIVE : natural := 4; -- 1 = FDRE, 2 = IDDR_2CLK, 3 = ISERDESE2, 4=ISERDESE2+IDELAY, 0 = All (Simulation Purposes)
        constant INT_IDELAY_TAPS : natural := 0;
        constant REAL_IDELAY_REFCLK_FREQUENCY : real := 200.0;

        -- I/O Ports
        signal clk : std_logic := '0';
        signal clk90 : std_logic := '0';
        signal clk180 : std_logic := '0';
        signal clk_idelay : std_logic := '0';
        signal in_pad : std_logic := '0';
        signal in_reset_iserdese2 : std_logic := '0';
        signal in_enable_iserdese2 : std_logic := '0';
        signal out_data_fdre : std_logic := '0';
        signal out_data_iddr_2clk : std_logic_vector(2-1 downto 0) := (others => '0');
        signal out_data_iserdese2 : std_logic_vector(4-1 downto 0) := (others => '0');


        -- Print to console "TEST OK."
        procedure print_test_ok is
            variable str : line;
        begin
            write(str, string'("TEST OK."));
            writeline(output, str);
        end procedure;

    begin

        -- DUT Instance
        dut : entity lib_src.xilinx_sdr_sampler(rtl)
        generic map (
            SELECT_PRIMITIVE => SELECT_PRIMITIVE,       -- 1 = FDRE, 2 = IDDR_2CLK, 3 = ISERDESE2, 4=ISERDESE2+IDELAY, 0 = All (Simulation Purposes)
            INT_IDELAY_TAPS => INT_IDELAY_TAPS,
            REAL_IDELAY_REFCLK_FREQUENCY => REAL_IDELAY_REFCLK_FREQUENCY
        ) port map (
            -- Clocks
            clk => clk,                                 -- 0 degrees phase-shift (always connect)
            clk90 => clk90,                             -- 90 degrees phase-shift (only ISERDESE2)
            clk180 => clk180,                           -- 180 degrees phase-shift (only IDDR_2CLK)
            clk_idelay => clk_idelay,
            -- Input Data
            in_pad => in_pad,                           -- FPGA pad (top-level input)
            in_reset_iserdese2 => in_reset_iserdese2,   -- Reset for ISERDESE2 to initialize outputs
            in_enable_iserdese2 => in_enable_iserdese2, -- Enable for ISERDESE2 to enable clocks
            -- Output Data
            out_data_fdre => out_data_fdre,             -- Data from the FDRE Primitive (maped to IFF)
            out_data_iddr_2clk => out_data_iddr_2clk,   -- Data from the IDDR_2CLK Primitive
            out_data_iserdese2 => out_data_iserdese2
        );

        -- CLK generator
        clk <= not clk after (CLK_PERIOD/2.0);
        clk180 <= not clk;
        proc_clk90 : process
        begin
            wait until rising_edge(clk);
            wait for (CLK_PERIOD/4.0);
            loop
                clk90 <= not clk90;
                wait for (CLK_PERIOD/2.0);
            end loop;
        end process;


        -- TX data
        proc_TX : process
        begin
            -- After reset strobe
            wait for 250 * CLK_PERIOD;
            loop
                in_pad <= '1';
                wait for 5 ns;
                in_pad <= '0';
                wait for 100 ns;
            end loop;
        end process;

        -- Sequencer
        proc_sequencer : process
        begin
            -- RST strobe
            in_reset_iserdese2 <= '1';
            in_enable_iserdese2 <= '0';
            wait for 100 * CLK_PERIOD;
            in_reset_iserdese2 <= '0';
            wait for 12 * CLK_PERIOD;
            in_enable_iserdese2 <= '1';

            wait for 3000 * CLK_PERIOD;
            print_test_ok;
            finish;
            wait;
        end process;

    end architecture;