    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    use std.textio.all;
    use std.env.finish;

    library lib_src;
    use lib_src.types_pack.all;

    entity universal_readout_tb is
    end universal_readout_tb;

    architecture sim of universal_readout_tb is

        -- Generics
        constant INT_QUBITS_CNT : positive := 4;
        constant RST_VAL : std_logic := '1';
        constant CLK_HZ : real := 100.0e6;
        constant WRITE_VALID_SIGNALS_CNT : positive := 4;
        constant WRITE_ON_VALID : boolean := true;

        -- Ports
        signal rst : std_logic;

        -- Data Signals
        signal wr_unsuccessful_cnt : t_unsuccessful_cntr_2d := (others => (others => '0'));
        signal wr_valid_gflow_success_done : std_logic := '0';
        signal wr_data_qubit_buffer : t_qubit_buffer_2d := (others => (others => '0'));
        signal wr_data_time_stamp_buffer : t_time_stamp_buffer_2d := (others => (others => '0'));
        signal wr_data_alpha_buffer : t_alpha_buffer_2d := (others => (others => '0'));
        signal wr_data_modulo_buffer : t_modulo_buffer_2d := (others => (others => '0'));
        signal wr_data_random_buffer : t_random_buffer_2d := (others => (others => '0'));

        -- Read endpoint signals: slower CLK, faster rate
        signal readout_enable : std_logic := '0';
        signal readout_data_ready : std_logic;
        signal readout_data_valid : std_logic;
        signal readout_data_32b : std_logic_vector(32-1 downto 0);

        -- Flags
        signal fifo_full : std_logic;
        signal fifo_empty : std_logic;
        signal fifo_prog_empty : std_logic;

        -- LED
        signal fifo_full_latched : std_logic;

        -- Print to console "TEST OK."
        procedure print_test_ok is
            variable str : line;
        begin
            write(str, string'("TEST OK."));
            writeline(output, str);
        end procedure;

        -- Clocks
        constant CLK_RD_HZ : real := 99.8e6;
        constant CLK_PERIOD : time := 1.0 sec / CLK_HZ;
        constant CLK_RD_PERIOD : time := 1.0 sec / CLK_RD_HZ;
        signal clk_wr : std_logic := '0';
        signal clk_rd : std_logic := '0';

    begin

        clk_wr <= not clk_wr after CLK_PERIOD / 2.0;
        clk_rd <= not clk_rd after CLK_RD_PERIOD / 2.0;

        dut_universal_readout : entity lib_src.universal_readout(rtl)
        generic map (
            INT_QUBITS_CNT => INT_QUBITS_CNT,
            RST_VAL => RST_VAL,
            CLK_HZ => CLK_HZ,
            WRITE_VALID_SIGNALS_CNT => WRITE_VALID_SIGNALS_CNT,
            WRITE_ON_VALID => WRITE_ON_VALID
        )
        port map (
            -- Reset, write clock
            rst => rst,
            wr_sys_clk => clk_wr,

            -- Data Signals
            wr_unsuccessful_cnt => wr_unsuccessful_cnt,
            wr_valid_gflow_success_done => wr_valid_gflow_success_done,
            wr_data_qubit_buffer => wr_data_qubit_buffer,
            wr_data_time_stamp_buffer => wr_data_time_stamp_buffer,
            wr_data_alpha_buffer => wr_data_alpha_buffer,
            wr_data_modulo_buffer => wr_data_modulo_buffer,
            wr_data_random_buffer => wr_data_random_buffer,

            -- Read endpoint signals: slower CLK, faster rate
            readout_clk => clk_rd,
            readout_data_ready => readout_data_ready,
            readout_data_valid => readout_data_valid,
            readout_enable => readout_enable,
            readout_data_32b => readout_data_32b,

            -- Flags
            fifo_full => fifo_full,
            fifo_empty => fifo_empty,
            fifo_prog_empty => fifo_prog_empty,

            -- LED
            fifo_full_latched => fifo_full_latched
        );

        proc_sequencer : process
            
        begin

            wait for 50 us;

            print_test_ok;
            finish;
            wait;
        end process;

    end architecture;