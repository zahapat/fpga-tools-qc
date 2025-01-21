    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    use std.textio.all;
    use std.env.finish;

    library lib_src;
    use lib_src.types_pack.all;
    use lib_src.const_pack.all;
    use lib_src.generics.all;

    library lib_sim;
    use lib_sim.types_pack_tb.all;
    use lib_sim.const_pack_tb.all;
    use lib_sim.essentials_tb.all;
    use lib_sim.clk_pack_tb.all;

    entity csv_readout_tb is
    end csv_readout_tb;

    architecture sim of csv_readout_tb is

        constant PROJ_DIR : string := PROJ_DIR;

        -- File I/O: Write to ONE file at a time
        constant CSV1_PATH : string := PROJ_DIR & "modules/csv_readout/sim/sim_reports/csv1.csv";
        constant CSV2_PATH : string := PROJ_DIR & "modules/csv_readout/sim/sim_reports/csv2.csv";
        constant CSV3_PATH : string := PROJ_DIR & "modules/csv_readout/sim/sim_reports/csv3.csv";
        file actual_csv : text;
        signal files_recreated : bit := '0';

        -- Generics
        constant INT_QUBITS_CNT : positive := 4;
        constant CLK_HZ : real := 100.0e6;
        constant REGULAR_SAMPLER_SECONDS : real := 1.0e-6;
        constant REGULAR_SAMPLER_SECONDS_2 : real := 2.0e-6;
        constant INT_NUMBER_OF_GFLOWS : natural := 9;

        -- Ports
        signal wr_rst : std_logic := '0'; -- Should be high on device powerup (rst logic)
        signal rd_rst : std_logic := '0'; -- Should be high on device powerup (rst logic)

        -- Data Signals
        signal wr_channels_detections : t_photon_counter_2d := (others => (others => '0'));
        signal wr_photon_losses : std_logic_vector(INT_QUBITS_CNT-2 downto 0) := (others => '0');
        signal wr_valid_feedfwd_success_done : std_logic := '0';
        signal wr_data_qubit_buffer : t_qubit_buffer_2d := (others => (others => '0'));
        signal wr_data_time_stamp_buffer : t_time_stamp_buffer_2d := (others => (others => '0'));
        signal wr_data_alpha_buffer : t_alpha_buffer_2d := (others => (others => '0'));
        signal wr_data_modulo_buffer : t_modulo_buffer_2d := (others => (others => '0'));
        signal wr_data_random_buffer : t_random_buffer_2d := (others => (others => '0'));
        signal wr_data_actual_gflow_buffer : std_logic_vector(
                integer(ceil(log2(real(INT_NUMBER_OF_GFLOWS+1))))-1 downto 0);

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
        procedure print_test_done is
            variable str : line;
        begin
            write(str, string'("TEST DONE."));
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

        dut_csv_readout : entity lib_src.csv_readout(rtl)
        generic map (
            INT_QUBITS_CNT => INT_QUBITS_CNT,
            CLK_HZ => CLK_HZ,
            REGULAR_SAMPLER_SECONDS => REGULAR_SAMPLER_SECONDS,
            REGULAR_SAMPLER_SECONDS_2 => REGULAR_SAMPLER_SECONDS_2,
            INT_NUMBER_OF_GFLOWS => INT_NUMBER_OF_GFLOWS
        )
        port map (
            -- Reset, write clock
            wr_rst => wr_rst,
            rd_rst => rd_rst,
            wr_sys_clk => clk_wr,

            -- Data Signals
            wr_channels_detections => wr_channels_detections,
            wr_photon_losses => wr_photon_losses, 
            wr_valid_feedfwd_success_done => wr_valid_feedfwd_success_done,
            wr_data_qubit_buffer => wr_data_qubit_buffer,
            wr_data_time_stamp_buffer => wr_data_time_stamp_buffer,
            wr_data_alpha_buffer => wr_data_alpha_buffer,
            wr_data_modulo_buffer => wr_data_modulo_buffer,
            wr_data_random_buffer => wr_data_random_buffer,
            wr_data_actual_gflow_buffer => wr_data_actual_gflow_buffer,

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

        -- Emulate wr_photon_losses
        trans_wr_photon_losses : process
        begin
            wait for 260 ns; -- MMCM locking
            loop
                wait for 1000 ns;

                wait until rising_edge(clk_wr);
                wr_photon_losses <= (others => '1');
                wait until rising_edge(clk_wr);
                wr_photon_losses <= (others => '0');
            end loop;
        end process;

        -- Emulate wr_channels_detections
        trans_wr_channels_detections : process
        begin
            wait for 260 ns; -- MMCM locking
            loop
                wait for 25 ns;

                wait until rising_edge(clk_wr);
                for i in INT_QUBITS_CNT*2-1 downto 0 loop
                    wr_channels_detections(i) <= 
                        std_logic_vector(unsigned(wr_channels_detections(i)) + "1");
                end loop;
            end loop;
        end process;

        -- Emulate Successful Feedforward Data Output
        trans_successful_feedfwd_results : process
        begin
            wait for INT_QUBITS_CNT*1000 ns;
            wait until rising_edge(clk_wr);
            wr_valid_feedfwd_success_done <= '1';
            for i in 0 to INT_QUBITS_CNT-1 loop
                wr_data_qubit_buffer(i) <= std_logic_vector(unsigned(wr_data_qubit_buffer(i)) + "1");
                wr_data_alpha_buffer(i) <= std_logic_vector(to_unsigned(i mod 4, 2));
                wr_data_modulo_buffer(i) <= std_logic_vector(unsigned(wr_data_modulo_buffer(i)) + "1");
                wr_data_random_buffer(i) <= std_logic_vector(unsigned(wr_data_random_buffer(i)) + "1");
            end loop;

            for i in 0 to INT_QUBITS_CNT loop
                wr_data_time_stamp_buffer(i) <= std_logic_vector(unsigned(wr_data_time_stamp_buffer(i)) + "1");
            end loop;

            wait until rising_edge(clk_wr);
            wr_valid_feedfwd_success_done <= '0';

        end process;

        proc_sequencer : process
        begin

            wr_rst <= '1';
            rd_rst <= '1';
            wait for 260 ns;

            wr_rst <= '0';
            rd_rst <= '0';
            wait for 40 us;
            -- wait until rising_edge(fifo_full);

            print_test_done;
            finish;
            wait;
        end process;


    -- Readout
    proc_fifo_readout : process
    begin
        wait until rising_edge(clk_rd);
        if readout_data_ready = '1' then
            readout_enable <= '1';
        else
            readout_enable <= '0';
        end if;
    end process;

    -- This readout process should be translated into the target language
    -- performing the RX readout:
    -- Rules:
    --      1. Each transaction is followed by a comma
    --         unless specified by: x"E" in last 4 bits = double comma
    --      2. If last 4 bits are x"F" => perform writeline in the target file
    --      3. To specify the target file: if x"1" in last 4 bits => output file is csv1
    --                                     if x"6" in last 4 bits => output file is csv2
    proc_data_printer : process
        variable v_line_buffer : line;    -- Line buffer
        variable v_file_number : integer; -- Target file pointer
        variable v_line_being_created : bit := '0';
    begin

        -- Recreate files
        file_open(actual_csv, CSV1_PATH, write_mode);
        file_close(actual_csv);
        file_open(actual_csv, CSV2_PATH, write_mode);
        file_close(actual_csv);
        file_open(actual_csv, CSV3_PATH, write_mode);
        file_close(actual_csv);
        files_recreated <= '1';
        report "CSV files have been re-created successfully.";

        -- Acquire data and print to console
        loop
            wait until rising_edge(clk_rd);
            if readout_data_valid = '1' then

                -- Translate the following code to the target language performing the RX readout
                -- 1) Open target output CSV file where new data will be appended
                if v_line_being_created = '0' then
                    if readout_data_32b(4-1 downto 0) = x"1" then
                        file_open(actual_csv, CSV1_PATH, append_mode);
                        v_line_being_created := '1'; -- Job Started
                    elsif readout_data_32b(4-1 downto 0) = x"7" then
                        file_open(actual_csv, CSV2_PATH, append_mode);
                        v_line_being_created := '1'; -- Job Started
                    elsif readout_data_32b(4-1 downto 0) = x"8" then
                        file_open(actual_csv, CSV3_PATH, append_mode);
                        v_line_being_created := '1'; -- Job Started
                    end if;
                end if;

                -- 2) CSV file line creation: append time at each EOF (x"F" = end of frame command)
                if readout_data_32b(4-1 downto 0) = x"F" then -- Print out the line buffer
                    write(v_line_buffer, string'(",") );
                    write(v_line_buffer, string'(
                        to_string(to_integer(unsigned(readout_data_32b(32-1 downto 4))) ) ));
                    -- writeline(output, v_line_buffer);     -- To the console (but this deletes the v_line_buffer content)
                    writeline(actual_csv, v_line_buffer); -- To the CSV file
                    file_close(actual_csv);
                    v_line_being_created := '0';          -- Job Done

                elsif readout_data_32b(4-1 downto 0) = x"E" then -- Extra Comma Delimiter
                    write(v_line_buffer, string'(",") );

                elsif readout_data_32b(4-1 downto 0) = x"1" then -- Event-based data type 1
                    write(v_line_buffer, string'(
                        to_string(to_integer(unsigned(readout_data_32b(32-1 downto 4))) ) ));
                    write(v_line_buffer, string'(",") );

                elsif readout_data_32b(4-1 downto 0) = x"2" then -- Event-based data type 2
                    write(v_line_buffer, string'(
                        to_string(to_integer(unsigned(readout_data_32b(32-1 downto 4))) ) ));
                    write(v_line_buffer, string'(",") );

                elsif readout_data_32b(4-1 downto 0) = x"3" then -- Event-based data type 3
                    write(v_line_buffer, string'(
                        to_string(to_integer(unsigned(readout_data_32b(32-1 downto 4))) ) ));
                    write(v_line_buffer, string'(",") );

                elsif readout_data_32b(4-1 downto 0) = x"4" then -- Event-based data type 4
                    write(v_line_buffer, string'(
                        to_string(to_integer(unsigned(readout_data_32b(32-1 downto 4))) ) ));
                    write(v_line_buffer, string'(",") );

                elsif readout_data_32b(4-1 downto 0) = x"5" then -- Event-based data type 5
                    write(v_line_buffer, string'(
                        to_string(to_integer(unsigned(readout_data_32b(32-1 downto 4))) ) ));
                    write(v_line_buffer, string'(",") );

                elsif readout_data_32b(4-1 downto 0) = x"6" then -- Regular reporting 1
                    write(v_line_buffer, string'(
                        to_string(to_integer(unsigned(readout_data_32b(32-1 downto 4))) ) ));
                    write(v_line_buffer, string'(",") );

                elsif readout_data_32b(4-1 downto 0) = x"7" then -- Regular reporting 2
                    write(v_line_buffer, string'(
                        to_string(to_integer(unsigned(readout_data_32b(32-1 downto 4))) ) ));
                    write(v_line_buffer, string'(",") );

                elsif readout_data_32b(4-1 downto 0) = x"8" then -- Regular reporting 3
                    write(v_line_buffer, string'(
                        to_string(to_integer(unsigned(readout_data_32b(32-1 downto 4))) ) ));
                    write(v_line_buffer, string'(",") );

                elsif readout_data_32b(4-1 downto 0) = x"9" then -- Regular reporting 4
                    write(v_line_buffer, string'(
                        to_string(to_integer(unsigned(readout_data_32b(32-1 downto 4))) ) ));
                    write(v_line_buffer, string'(",") );

                elsif readout_data_32b(4-1 downto 0) = x"A" then -- Regular reporting 5
                    write(v_line_buffer, string'(
                        to_string(to_integer(unsigned(readout_data_32b(32-1 downto 4))) ) ));
                    write(v_line_buffer, string'(",") );
                    
                elsif readout_data_32b(4-1 downto 0) = x"B" then -- Regular reporting 6
                    null;
                elsif readout_data_32b(4-1 downto 0) = x"C" then -- Regular reporting 7
                    null;
                elsif readout_data_32b(4-1 downto 0) = x"D" then -- Regular reporting 8
                    null;

                else
                    -- "0000" Is forbidden!!!
                    report "Last four bits being '0000' is forbidden! It can mean data loss or unwanted behaviour.";
                    assert false severity failure;
                end if;

            end if;
        end loop;
    end process;

    end architecture;