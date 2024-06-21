
    -- nff_cdcc_flag_tb.vhd: Testbench for module qubit_sampler_dual_port.vhd
    -- Engineer: Patrik Zahalka 
    -- Email: patrik.zahalka@univie.ac.at
    -- Created: 10/16/2021

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    library lib_sim;
    use lib_sim.clk_pack_tb.all;
    use lib_sim.random_pack_tb.all;

    use std.env.finish;

    library lib_src;

    entity nff_cdcc_flag_tb is
    end nff_cdcc_flag_tb;

    architecture sim of nff_cdcc_flag_tb is

        constant REAL_FREQ_WRITE : real := 250.0e6;
        -- constant REAL_FREQ_WRITE : real := 450.0e6;
        constant REAL_FREQ_READ  : real := 100.0e6;

        constant TIME_FREQ_WRITE_PERIOD_NS : time := 1 sec / REAL_FREQ_WRITE;

        -- Generics
        constant BYPASS : boolean := false;
        constant ASYNC_FLOPS_CNT : positive := 2;
        constant FLOPS_BEFORE_CROSSING_CNT : positive := 1;
        constant WR_READY_DEASSERTED_CYCLES : positive := 3;

        -- DUT signals
        signal rst_write : std_logic := '1';
        signal clk_write : std_logic := '1';
        signal wr_en : std_logic := '0';
        signal wr_ready : std_logic;

        signal rst_read : std_logic := '1';
        signal clk_read : std_logic := '1';
        signal rd_valid : std_logic := '0';

        -- Simulate Detectors
        constant REAL_NEW_QUBIT_78MHz_HZ : real := 78.0e6;
        constant SPCM_OUTPUT_PULSE_DUR : time := 10 ns;
        constant SPCM_DEAD_TIME_DUR : time := 22 ns;
        signal sl_detector_clk : std_logic := '0';
        signal slv_detector_qubit : std_logic_vector(1 downto 0) := (others => '0');

        constant REPETITIONS : integer := 20;

    begin

        dut_nff_cdcc_flag : entity lib_src.nff_cdcc_flag(rtl)
        generic map (
            BYPASS => BYPASS,
            ASYNC_FLOPS_CNT => ASYNC_FLOPS_CNT,
            FLOPS_BEFORE_CROSSING_CNT => FLOPS_BEFORE_CROSSING_CNT,
            WR_READY_DEASSERTED_CYCLES => WR_READY_DEASSERTED_CYCLES
        )
        port map (

            clk_write => clk_write,
            wr_en => wr_en,
            wr_ready => wr_ready,

            clk_read => clk_read,
            rd_valid => rd_valid
        );

        -- Generate Clocks
        gen_clk_freq_hz_real(clk_write, REAL_FREQ_WRITE);
        gen_clk_freq_hz_real(clk_read, REAL_FREQ_READ);


        -- Driver of the DUT
        proc_driver : process
        begin

            wait for 200 ns;
            for i in 0 to REPETITIONS-1 loop
                wait until rising_edge(clk_write);
                wr_en <= '1';
                wait until rising_edge(clk_write);
                wr_en <= '0';
                wait for 7*TIME_FREQ_WRITE_PERIOD_NS;
            end loop;
            wait;

        end process;

        -- Reading from the the DUT
        proc_reader : process
        begin

            wait for 100 ns;
            for i in 0 to REPETITIONS-1 loop
                wait until rising_edge(rd_valid);
                wait until rising_edge(clk_read);
                wait for 0 ns;

                assert rd_valid = '0'
                    report "proc_reader: 'rd_valid' (" & to_string(rd_valid) & 
                    ") not matching 'expected': '0'" & 
                    " Transaction: " & integer'image(i)
                    severity failure;

            end loop;

            finish;
            wait;

        end process;

    end architecture;