    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;
    
    use std.textio.all;
    use ieee.std_logic_textio.all;

    use std.env.finish;

    library lib_src;
    use lib_src.types_pack.all;
    use lib_src.const_pack.all;

    library lib_sim;
    use lib_sim.types_pack_tb.all;
    use lib_sim.const_pack_tb.all;

    library OSVVM;
    use OSVVM.RandomPkg.all;

    entity top_gflow_tb is
    end top_gflow_tb;

    architecture sim of top_gflow_tb is

        -- File I/O
        file sim_result : text;

        -- FPGA System Clock
        constant CLK_HZ : integer := 200e6;
        constant CLK_PERIOD : time := 1 sec / CLK_HZ;

        -- New qubit each 78 MHz
        constant CLK_NEW_QUBIT_78MHz_HZ : integer := 78e6;
        constant LASER_CLK_PERIOD : time := 1 sec / CLK_NEW_QUBIT_78MHz_HZ;
        signal laser_clk : std_logic := '1';

        -- External Detector: Excelitas SPCM (Single Photon Counting Module) SPCM-AQRH-1X
        -- 31.249999999999996 MHz
        constant DETECTOR_PULSE_NS : time := 10 ns;
        constant DETECTOR_DEAD_TIME_NS : time := 22 ns;

        -- Number od random inputs INST_B
        -- THE SEEDS MUST BE MODIFIED!
        constant RAND_NUMBS_SEEDS : natural := 1;

        -- Gflow generics
        constant RST_VAL            : std_logic := '1';
        constant CLK_SYS_HZ         : natural := 100e6;
        constant CLK_SAMPL_HZ       : natural := 250e6;
        constant QUBITS_CNT         : positive := 4;
        constant INPUT_PADS_CNT     : positive := 8;
        constant OUTPUT_PADS_CNT    : positive := 1;
        constant EMULATE_INPUTS     : boolean := false;
        constant PHOTON_1H_DELAY_NS : real := 75.65;     -- zero delay = reference
        constant PHOTON_1V_DELAY_NS : real := 75.01;     -- zero delay = reference
        constant PHOTON_2H_DELAY_NS : real := -2117.95;  -- fibre delay of qubit 2
        constant PHOTON_2V_DELAY_NS : real := -2125.35;  -- fibre delay of qubit 2
        constant PHOTON_3H_DELAY_NS : real := -1030.35;  -- fibre delay of qubit 3
        constant PHOTON_3V_DELAY_NS : real := -1034.45;  -- fibre delay of qubit 3
        constant PHOTON_4H_DELAY_NS : real := -3177.95;  -- fibre delay of qubit 4
        constant PHOTON_4V_DELAY_NS : real := -3181.05;  -- fibre delay of qubit 4
        constant PHOTON_5H_DELAY_NS : real := -3177.95;  -- fibre delay of qubit 5
        constant PHOTON_5V_DELAY_NS : real := -3181.05;  -- fibre delay of qubit 5
        constant PHOTON_6H_DELAY_NS : real := -3177.95;  -- fibre delay of qubit 6
        constant PHOTON_6V_DELAY_NS : real := -3181.05;  -- fibre delay of qubit 6
        constant PHOTON_7H_DELAY_NS : real := -3177.95;  -- fibre delay of qubit 7
        constant PHOTON_7V_DELAY_NS : real := -3181.05;  -- fibre delay of qubit 7
        constant PHOTON_8H_DELAY_NS : real := -3177.95;  -- fibre delay of qubit 8
        constant PHOTON_8V_DELAY_NS : real := -3181.05;  -- fibre delay of qubit 8
        constant WRITE_ON_VALID     : boolean := true;

        -- Top I/O signals
        signal sys_clk_p     : std_logic := '1';
        signal sys_clk_n     : std_logic := '0';

        signal led : std_logic_vector(4-1 downto 0);

        signal input_pads : std_logic_vector(INPUT_PADS_CNT-1 downto 0);
        signal output_pads : std_logic_vector(OUTPUT_PADS_CNT-1 downto 0);

        signal readout_clk        : std_logic := '0';
        signal readout_data_ready : std_logic := '0';
        signal readout_data_valid : std_logic := '0';
        signal readout_enable     : std_logic := '0';
        signal readout_data_32b   : std_logic_vector(31 downto 0);

        signal s_qubits : std_logic_vector(2*QUBITS_CNT-1 downto 0) := (others => '0');

        -- Delta time of the arrival of a single photon
        constant DELTA_ARRIVAL_MIN_NS : real := -0.5;
        constant DELTA_ARRIVAL_MAX_NS : real := 0.5;

        -- Print to console "TEST OK."
        procedure print_test_ok is
            variable str : line;
        begin
            write(str, string'("TEST OK."));
            writeline(output, str);
        end procedure;

    begin

        ------------------
        -- DUT instance --
        ------------------
        dut_top_gflow : entity lib_src.top_gflow(str)
        generic map (
            RST_VAL            => RST_VAL,
            CLK_SYS_HZ         => CLK_SYS_HZ,
            CLK_SAMPL_HZ       => CLK_SAMPL_HZ,
            QUBITS_CNT         => QUBITS_CNT,
            INPUT_PADS_CNT     => INPUT_PADS_CNT,
            OUTPUT_PADS_CNT    => OUTPUT_PADS_CNT,
            EMULATE_INPUTS     => EMULATE_INPUTS,
            PHOTON_1H_DELAY_NS => PHOTON_1H_DELAY_NS,
            PHOTON_1V_DELAY_NS => PHOTON_1V_DELAY_NS,
            PHOTON_2H_DELAY_NS => PHOTON_2H_DELAY_NS,
            PHOTON_2V_DELAY_NS => PHOTON_2V_DELAY_NS,
            PHOTON_3H_DELAY_NS => PHOTON_3H_DELAY_NS,
            PHOTON_3V_DELAY_NS => PHOTON_3V_DELAY_NS,
            PHOTON_4H_DELAY_NS => PHOTON_4H_DELAY_NS,
            PHOTON_4V_DELAY_NS => PHOTON_4V_DELAY_NS,
            PHOTON_5H_DELAY_NS => PHOTON_5H_DELAY_NS,
            PHOTON_5V_DELAY_NS => PHOTON_5V_DELAY_NS,
            PHOTON_6H_DELAY_NS => PHOTON_6H_DELAY_NS,
            PHOTON_6V_DELAY_NS => PHOTON_6V_DELAY_NS,
            PHOTON_7H_DELAY_NS => PHOTON_7H_DELAY_NS,
            PHOTON_7V_DELAY_NS => PHOTON_7V_DELAY_NS,
            PHOTON_8H_DELAY_NS => PHOTON_8H_DELAY_NS,
            PHOTON_8V_DELAY_NS => PHOTON_8V_DELAY_NS,
            WRITE_ON_VALID     => WRITE_ON_VALID
        )
        port map (
            -- External 200MHz oscillator
            sys_clk_p => sys_clk_p,
            sys_clk_n => sys_clk_n,

            -- Readout Endpoint Signals
            readout_clk => readout_clk,
            readout_data_ready => readout_data_ready,
            readout_data_valid => readout_data_valid,
            readout_enable => readout_enable,
            readout_data_32b => readout_data_32b,

            -- Debug LEDs
            led => led,

            -- Inputs from SPCM
            input_pads => input_pads,

            -- PCD Trigger
            output_pads => output_pads
        );

        -----------------------
        -- Clock Oscillators --
        -----------------------
        -- 1) ACQUISITION 250 MHz, 2) NEW_QUBIT 78 MHz, 3) DETECTOR 31 MHz
        -- The Laser frequency of 78 MHz must be downconverted to 31.24999 MHz to prevent detector saturation
        sys_clk_p <= not sys_clk_p after CLK_PERIOD / 2;
        sys_clk_n <= not sys_clk_p;
        laser_clk <= not laser_clk after LASER_CLK_PERIOD / 2;
        readout_clk <= not readout_clk after 5 ns;

        --------------------------------------------------------------
        -- GENERATE RANDOM QUBITS AT MAX DETECTOR FREQ 31.24999 MHz --
        --------------------------------------------------------------
        proc_gen_rand_qbts_detector_maxfreq : process
            -- Random SLV type generator
            variable rand_slv : RandomPType;
        begin
            wait for 0 ns;
            -- Create a unique seed
            rand_slv.InitSeed(rand_slv'instance_name);
            wait for 0 ns;

            loop
                -- Create the randomized values (Normal Distribution)
                s_qubits <= (others => '0');
                wait for 0 ns;
                input_pads <= s_qubits;
                wait for DETECTOR_DEAD_TIME_NS;

                -- Create the randomized values (Normal Distribution)
                s_qubits <= rand_slv.Randslv(0, integer(2**(2*QUBITS_CNT)-1), 2*QUBITS_CNT);
                wait for 0 ns;
                input_pads <= s_qubits;
                wait for DETECTOR_PULSE_NS;
            end loop;
        end process;


        ---------------
        -- SEQUENCER --
        ---------------
        proc_sequencer : process
            -- File I/O
            variable v_file_line_buffer : line;
        begin
            -- Open and Initialize report file
            file_open(sim_result, "C:/Git/zahapat/fpga-tools-qc/modules/top_gflow/sim/sim_reports/sim_result.csv", write_mode);
            write(v_file_line_buffer, string'("q1,q2,q3,q4,,"));
            write(v_file_line_buffer, string'("alpha_q1,alpha_q2,alpha_q3,alpha_q4,,"));
            write(v_file_line_buffer, string'("rand_q1,rand_q2,rand_q3,rand_q4,,"));
            write(v_file_line_buffer, string'("mod_q1,mod_q2,mod_q3,mod_q4,,"));
            write(v_file_line_buffer, string'("q1_time,q1_time_overflows,q2_time,q2_time_overflows,q3_time,q3_time_overflows,q4_time,q4_time_overflows,,"));
            writeline(sim_result, v_file_line_buffer);

            -- Run for ...
            wait for 5000 us; -- make timer: Build Duration: 00:48:59

            if readout_data_valid = '1' then
                wait until falling_edge(readout_data_valid);
                wait for 1 ns;
            end if;

            print_test_ok;
            file_close(sim_result);
            finish;
            wait;
        end process;


        ---------------
        -- READOUT --
        ---------------
        proc_readout : process
            -- Output Vectors
            variable q1, q2, q3, q4 : integer := 0;
            variable alpha_q1, alpha_q2, alpha_q3, alpha_q4 : integer := 0;
            variable rand_q1, rand_q2, rand_q3, rand_q4 : integer := 0;
            variable mod_q1, mod_q2, mod_q3, mod_q4 : integer := 0;
            variable qubit_time : integer := 0;

            -- File I/O
            variable v_file_line_buffer : line;
            variable v_space      : character;
            variable v_comma      : character := ',';
        begin
                readout_enable <= '1';

                -- Do not wait each clk cycle, but on an event
                wait until rising_edge(readout_data_valid);
                -- file_open(sim_result, "C:/Git/zahapat/fpga-tools-qc/modules/top_gflow/sim/sim_reports/sim_result.txt", write_mode);

                -- Synchronize readout with readout clock
                wait until rising_edge(readout_clk);

                while readout_data_valid = '1' loop
                    -- Update deltas to make sure data vectors contain the most recent value

                    -- Parse the data vector
                    if readout_data_32b(3 downto 0) = x"1" then
                        q1 := to_integer(unsigned(readout_data_32b(31 downto 30)));
                        q2 := to_integer(unsigned(readout_data_32b(29 downto 28)));
                        q3 := to_integer(unsigned(readout_data_32b(27 downto 26)));
                        q4 := to_integer(unsigned(readout_data_32b(25 downto 24)));
                        write(v_file_line_buffer, integer'image(q1) & v_comma);
                        write(v_file_line_buffer, integer'image(q2) & v_comma);
                        write(v_file_line_buffer, integer'image(q3) & v_comma);
                        write(v_file_line_buffer, integer'image(q4) & v_comma);
                        write(v_file_line_buffer, v_comma);
                        alpha_q1 := to_integer(unsigned(readout_data_32b(23 downto 22)));
                        alpha_q2 := to_integer(unsigned(readout_data_32b(21 downto 20)));
                        alpha_q3 := to_integer(unsigned(readout_data_32b(19 downto 18)));
                        alpha_q4 := to_integer(unsigned(readout_data_32b(17 downto 16)));
                        write(v_file_line_buffer, integer'image(alpha_q1) & v_comma);
                        write(v_file_line_buffer, integer'image(alpha_q2) & v_comma);
                        write(v_file_line_buffer, integer'image(alpha_q3) & v_comma);
                        write(v_file_line_buffer, integer'image(alpha_q4) & v_comma);
                        write(v_file_line_buffer, v_comma);
                        rand_q1 := to_integer(unsigned(readout_data_32b(15 downto 15)));
                        rand_q2 := to_integer(unsigned(readout_data_32b(14 downto 14)));
                        rand_q3 := to_integer(unsigned(readout_data_32b(13 downto 13)));
                        rand_q4 := to_integer(unsigned(readout_data_32b(12 downto 12)));
                        write(v_file_line_buffer, integer'image(rand_q1) & v_comma);
                        write(v_file_line_buffer, integer'image(rand_q2) & v_comma);
                        write(v_file_line_buffer, integer'image(rand_q3) & v_comma);
                        write(v_file_line_buffer, integer'image(rand_q4) & v_comma);
                        write(v_file_line_buffer, v_comma);
                        mod_q1 := to_integer(unsigned(readout_data_32b(11 downto 10)));
                        mod_q2 := to_integer(unsigned(readout_data_32b(9 downto 8)));
                        mod_q3 := to_integer(unsigned(readout_data_32b(7 downto 6)));
                        mod_q4 := to_integer(unsigned(readout_data_32b(5 downto 4)));
                        write(v_file_line_buffer, integer'image(mod_q1) & v_comma);
                        write(v_file_line_buffer, integer'image(mod_q2) & v_comma);
                        write(v_file_line_buffer, integer'image(mod_q3) & v_comma);
                        write(v_file_line_buffer, integer'image(mod_q4) & v_comma);
                        write(v_file_line_buffer, v_comma);

                        report  "q1=" & to_string(q1) & " " &
                                "q2=" & to_string(q2) & " " &
                                "q3=" & to_string(q3) & " " &
                                "q4=" & to_string(q4) & " " &
                                "alpha_q1=" & to_string(alpha_q1) & " " &
                                "alpha_q2=" & to_string(alpha_q2) & " " &
                                "alpha_q3=" & to_string(alpha_q3) & " " &
                                "alpha_q4=" & to_string(alpha_q4) & " " &
                                "rand_q1=" & to_string(rand_q1) & " " &
                                "rand_q2=" & to_string(rand_q2) & " " &
                                "rand_q3=" & to_string(rand_q3) & " " &
                                "rand_q4=" & to_string(rand_q4) & " " &
                                "mod_q1=" & to_string(mod_q1) & " " &
                                "mod_q2=" & to_string(mod_q2) & " " &
                                "mod_q3=" & to_string(mod_q3) & " " &
                                "mod_q4=" & to_string(mod_q4) ;
                    end if;

                    if readout_data_32b(3 downto 0) = x"2" then
                        qubit_time := to_integer(unsigned(readout_data_32b(31 downto 4)));
                        write(v_file_line_buffer, integer'image(qubit_time) & v_comma);
                        report  "qubit X detection time = " & to_string(qubit_time);
                    end if;

                    if readout_data_32b(3 downto 0) = x"3" then
                        qubit_time := to_integer(unsigned(readout_data_32b(31 downto 4)));
                        write(v_file_line_buffer, integer'image(qubit_time) & v_comma);
                        write(v_file_line_buffer, v_comma);
                        report  "qubit X detection time = " & to_string(qubit_time);
                    end if;

                    if readout_data_32b(3 downto 0) > x"3" then
                        report  "readout_data_32b = " & to_string(readout_data_32b);
                    end if;

                    if readout_data_32b(3 downto 0) = x"0" then
                        report  "Info: Waiting until valid data. Current data: " & to_string(readout_data_32b);
                    end if;

                    -- Parse the next transaction
                    wait until rising_edge(readout_clk);
                end loop;

                -- Parsing done, print out the line to the file
                writeline(sim_result, v_file_line_buffer);
        end process;

    end architecture;