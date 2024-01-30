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
    use lib_src.generics.all;

    library lib_sim;
    use lib_sim.types_pack_tb.all;
    use lib_sim.const_pack_tb.all;
    use lib_sim.essentials_tb.all;

    library OSVVM;
    use OSVVM.RandomPkg.all;

    entity top_gflow_tb is
    end top_gflow_tb;

    architecture sim of top_gflow_tb is

        constant PROJ_DIR : string := PROJ_DIR;

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
        constant QUBITS_CNT         : positive := INT_QUBITS_CNT;
        constant INPUT_PADS_CNT     : positive := 8;
        constant OUTPUT_PADS_CNT    : positive := 1;
        constant INT_EMULATE_INPUTS : integer := INT_EMULATE_INPUTS;
        constant INT_WHOLE_PHOTON_2H_DELAY_NS : integer := INT_WHOLE_PHOTON_2H_DELAY_NS;
        constant INT_DECIM_PHOTON_2H_DELAY_NS : integer := INT_DECIM_PHOTON_2H_DELAY_NS;
        constant INT_WHOLE_PHOTON_2V_DELAY_NS : integer := INT_WHOLE_PHOTON_2V_DELAY_NS;
        constant INT_DECIM_PHOTON_2V_DELAY_NS : integer := INT_DECIM_PHOTON_2V_DELAY_NS;
        constant INT_WHOLE_PHOTON_3H_DELAY_NS : integer := INT_WHOLE_PHOTON_3H_DELAY_NS;
        constant INT_DECIM_PHOTON_3H_DELAY_NS : integer := INT_DECIM_PHOTON_3H_DELAY_NS;
        constant INT_WHOLE_PHOTON_3V_DELAY_NS : integer := INT_WHOLE_PHOTON_3V_DELAY_NS;
        constant INT_DECIM_PHOTON_3V_DELAY_NS : integer := INT_DECIM_PHOTON_3V_DELAY_NS;
        constant INT_WHOLE_PHOTON_4H_DELAY_NS : integer := INT_WHOLE_PHOTON_4H_DELAY_NS;
        constant INT_DECIM_PHOTON_4H_DELAY_NS : integer := INT_DECIM_PHOTON_4H_DELAY_NS;
        constant INT_WHOLE_PHOTON_4V_DELAY_NS : integer := INT_WHOLE_PHOTON_4V_DELAY_NS;
        constant INT_DECIM_PHOTON_4V_DELAY_NS : integer := INT_DECIM_PHOTON_4V_DELAY_NS;
        constant INT_WHOLE_PHOTON_5H_DELAY_NS : integer := INT_WHOLE_PHOTON_5H_DELAY_NS;
        constant INT_DECIM_PHOTON_5H_DELAY_NS : integer := INT_DECIM_PHOTON_5H_DELAY_NS;
        constant INT_WHOLE_PHOTON_5V_DELAY_NS : integer := INT_WHOLE_PHOTON_5V_DELAY_NS;
        constant INT_DECIM_PHOTON_5V_DELAY_NS : integer := INT_DECIM_PHOTON_5V_DELAY_NS;
        constant INT_WHOLE_PHOTON_6H_DELAY_NS : integer := INT_WHOLE_PHOTON_6H_DELAY_NS;
        constant INT_DECIM_PHOTON_6H_DELAY_NS : integer := INT_DECIM_PHOTON_6H_DELAY_NS;
        constant INT_WHOLE_PHOTON_6V_DELAY_NS : integer := INT_WHOLE_PHOTON_6V_DELAY_NS;
        constant INT_DECIM_PHOTON_6V_DELAY_NS : integer := INT_DECIM_PHOTON_6V_DELAY_NS;
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
            RST_VAL                      => RST_VAL,
            CLK_SYS_HZ                   => CLK_SYS_HZ,
            CLK_SAMPL_HZ                 => CLK_SAMPL_HZ,
            QUBITS_CNT                   => QUBITS_CNT,
            INPUT_PADS_CNT               => INPUT_PADS_CNT,
            OUTPUT_PADS_CNT              => OUTPUT_PADS_CNT,
            INT_EMULATE_INPUTS           => INT_EMULATE_INPUTS,
            INT_WHOLE_PHOTON_2H_DELAY_NS => INT_WHOLE_PHOTON_2H_DELAY_NS,
            INT_DECIM_PHOTON_2H_DELAY_NS => INT_DECIM_PHOTON_2H_DELAY_NS,
            INT_WHOLE_PHOTON_2V_DELAY_NS => INT_WHOLE_PHOTON_2V_DELAY_NS,
            INT_DECIM_PHOTON_2V_DELAY_NS => INT_DECIM_PHOTON_2V_DELAY_NS,
            INT_WHOLE_PHOTON_3H_DELAY_NS => INT_WHOLE_PHOTON_3H_DELAY_NS,
            INT_DECIM_PHOTON_3H_DELAY_NS => INT_DECIM_PHOTON_3H_DELAY_NS,
            INT_WHOLE_PHOTON_3V_DELAY_NS => INT_WHOLE_PHOTON_3V_DELAY_NS,
            INT_DECIM_PHOTON_3V_DELAY_NS => INT_DECIM_PHOTON_3V_DELAY_NS,
            INT_WHOLE_PHOTON_4H_DELAY_NS => INT_WHOLE_PHOTON_4H_DELAY_NS,
            INT_DECIM_PHOTON_4H_DELAY_NS => INT_DECIM_PHOTON_4H_DELAY_NS,
            INT_WHOLE_PHOTON_4V_DELAY_NS => INT_WHOLE_PHOTON_4V_DELAY_NS,
            INT_DECIM_PHOTON_4V_DELAY_NS => INT_DECIM_PHOTON_4V_DELAY_NS,
            INT_WHOLE_PHOTON_5H_DELAY_NS => INT_WHOLE_PHOTON_5H_DELAY_NS,
            INT_DECIM_PHOTON_5H_DELAY_NS => INT_DECIM_PHOTON_5H_DELAY_NS,
            INT_WHOLE_PHOTON_5V_DELAY_NS => INT_WHOLE_PHOTON_5V_DELAY_NS,
            INT_DECIM_PHOTON_5V_DELAY_NS => INT_DECIM_PHOTON_5V_DELAY_NS,
            INT_WHOLE_PHOTON_6H_DELAY_NS => INT_WHOLE_PHOTON_6H_DELAY_NS,
            INT_DECIM_PHOTON_6H_DELAY_NS => INT_DECIM_PHOTON_6H_DELAY_NS,
            INT_WHOLE_PHOTON_6V_DELAY_NS => INT_WHOLE_PHOTON_6V_DELAY_NS,
            INT_DECIM_PHOTON_6V_DELAY_NS => INT_DECIM_PHOTON_6V_DELAY_NS,
            WRITE_ON_VALID               => WRITE_ON_VALID
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
            -- rand_slv.InitSeed(rand_slv'instance_name);
            rand_slv.InitSeed(RANDOM_SEED_1);
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
            file_open(sim_result, PROJ_DIR & "modules/top_gflow/sim/sim_reports/sim_result.csv", write_mode);
            write(v_file_line_buffer, string'("q1,q2,q3,q4,,"));
            write(v_file_line_buffer, string'("alpha_q1,alpha_q2,alpha_q3,alpha_q4,,"));
            write(v_file_line_buffer, string'("rand_q1,rand_q2,rand_q3,rand_q4,,"));
            write(v_file_line_buffer, string'("mod_q1,mod_q2,mod_q3,mod_q4,,"));
            write(v_file_line_buffer, string'("q5,q6,q7,q8,,"));
            write(v_file_line_buffer, string'("alpha_q5,alpha_q6,alpha_q7,alpha_q8,,"));
            write(v_file_line_buffer, string'("rand_q5,rand_q6,rand_q7,rand_q8,,"));
            write(v_file_line_buffer, string'("mod_q5,mod_q6,mod_q7,mod_q8,,"));
            write(v_file_line_buffer, string'("q1_time,q1_time_overflows,q2_time,q2_time_overflows,q3_time,q3_time_overflows,q4_time,q4_time_overflows,q5_time,q5_time_overflows,q6_time,q6_time_overflows,q7_time,q7_time_overflows,q8_time,q8_time_overflows,,"));
            writeline(sim_result, v_file_line_buffer);

            -- Run for ...
            wait for 50 us; -- make timer: Build Duration: 00:00:37
            -- wait for 500 us; -- make timer: Build Duration: 00:05:00
            -- wait for 5000 us; -- make timer: Build Duration: 00:48:59
            -- wait for 50000 us; -- make timer: Build Duration: 07:45:01

            if readout_data_valid = '1' then
                wait until falling_edge(readout_data_valid);
                wait for 1 ns;
            end if;

            print_test_ok;
            file_close(sim_result);
            finish;
            wait;
        end process;


        -------------
        -- READOUT --
        -------------
        proc_readout : process
            -- Output Vectors
            variable q1, q2, q3, q4 : integer := 0;
            variable q5, q6, q7, q8 : integer := 0;
            variable alpha_q1, alpha_q2, alpha_q3, alpha_q4 : integer := 0;
            variable alpha_q5, alpha_q6, alpha_q7, alpha_q8 : integer := 0;
            variable rand_q1, rand_q2, rand_q3, rand_q4 : integer := 0;
            variable rand_q5, rand_q6, rand_q7, rand_q8 : integer := 0;
            variable mod_q1, mod_q2, mod_q3, mod_q4 : integer := 0;
            variable mod_q5, mod_q6, mod_q7, mod_q8 : integer := 0;
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
                                "q4=" & to_string(q4) & " ";
                        report  "alpha_q1=" & to_string(alpha_q1) & " " &
                                "alpha_q2=" & to_string(alpha_q2) & " " &
                                "alpha_q3=" & to_string(alpha_q3) & " " &
                                "alpha_q4=" & to_string(alpha_q4) & " ";
                        report  "rand_q1=" & to_string(rand_q1) & " " &
                                "rand_q2=" & to_string(rand_q2) & " " &
                                "rand_q3=" & to_string(rand_q3) & " " &
                                "rand_q4=" & to_string(rand_q4) & " ";
                        report  "mod_q1=" & to_string(mod_q1) & " " &
                                "mod_q2=" & to_string(mod_q2) & " " &
                                "mod_q3=" & to_string(mod_q3) & " " &
                                "mod_q4=" & to_string(mod_q4) ;
                    end if;

                    -- Parse the data vector
                    if readout_data_32b(3 downto 0) = x"5" then
                        q5 := to_integer(unsigned(readout_data_32b(31 downto 30)));
                        q6 := to_integer(unsigned(readout_data_32b(29 downto 28)));
                        q7 := to_integer(unsigned(readout_data_32b(27 downto 26)));
                        q8 := to_integer(unsigned(readout_data_32b(25 downto 24)));
                        write(v_file_line_buffer, integer'image(q5) & v_comma);
                        write(v_file_line_buffer, integer'image(q6) & v_comma);
                        write(v_file_line_buffer, integer'image(q7) & v_comma);
                        write(v_file_line_buffer, integer'image(q8) & v_comma);
                        write(v_file_line_buffer, v_comma);
                        alpha_q5 := to_integer(unsigned(readout_data_32b(23 downto 22)));
                        alpha_q6 := to_integer(unsigned(readout_data_32b(21 downto 20)));
                        alpha_q7 := to_integer(unsigned(readout_data_32b(19 downto 18)));
                        alpha_q8 := to_integer(unsigned(readout_data_32b(17 downto 16)));
                        write(v_file_line_buffer, integer'image(alpha_q5) & v_comma);
                        write(v_file_line_buffer, integer'image(alpha_q6) & v_comma);
                        write(v_file_line_buffer, integer'image(alpha_q7) & v_comma);
                        write(v_file_line_buffer, integer'image(alpha_q8) & v_comma);
                        write(v_file_line_buffer, v_comma);
                        rand_q5 := to_integer(unsigned(readout_data_32b(15 downto 15)));
                        rand_q6 := to_integer(unsigned(readout_data_32b(14 downto 14)));
                        rand_q7 := to_integer(unsigned(readout_data_32b(13 downto 13)));
                        rand_q8 := to_integer(unsigned(readout_data_32b(12 downto 12)));
                        write(v_file_line_buffer, integer'image(rand_q5) & v_comma);
                        write(v_file_line_buffer, integer'image(rand_q6) & v_comma);
                        write(v_file_line_buffer, integer'image(rand_q7) & v_comma);
                        write(v_file_line_buffer, integer'image(rand_q8) & v_comma);
                        write(v_file_line_buffer, v_comma);
                        mod_q5 := to_integer(unsigned(readout_data_32b(11 downto 10)));
                        mod_q6 := to_integer(unsigned(readout_data_32b(9 downto 8)));
                        mod_q7 := to_integer(unsigned(readout_data_32b(7 downto 6)));
                        mod_q8 := to_integer(unsigned(readout_data_32b(5 downto 4)));
                        write(v_file_line_buffer, integer'image(mod_q5) & v_comma);
                        write(v_file_line_buffer, integer'image(mod_q6) & v_comma);
                        write(v_file_line_buffer, integer'image(mod_q7) & v_comma);
                        write(v_file_line_buffer, integer'image(mod_q8) & v_comma);
                        write(v_file_line_buffer, v_comma);

                        report  "q5=" & to_string(q5) & " " &
                                "q6=" & to_string(q6) & " " &
                                "q7=" & to_string(q7) & " " &
                                "q8=" & to_string(q8) & " ";
                        report  "alpha_q5=" & to_string(alpha_q5) & " " &
                                "alpha_q6=" & to_string(alpha_q6) & " " &
                                "alpha_q7=" & to_string(alpha_q7) & " " &
                                "alpha_q8=" & to_string(alpha_q8) & " ";
                        report  "rand_q5=" & to_string(rand_q5) & " " &
                                "rand_q6=" & to_string(rand_q6) & " " &
                                "rand_q7=" & to_string(rand_q7) & " " &
                                "rand_q8=" & to_string(rand_q8) & " ";
                        report  "mod_q5=" & to_string(mod_q5) & " " &
                                "mod_q6=" & to_string(mod_q6) & " " &
                                "mod_q7=" & to_string(mod_q7) & " " &
                                "mod_q8=" & to_string(mod_q8) ;
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

                    if readout_data_32b(3 downto 0) > x"5" then
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


        -------------
        -- CHECKER --
        -------------
        proc_checker_fsm_gflow : process
            variable rand_q1, rand_q2, rand_q3, rand_q4 : integer;
            variable rand_q5, rand_q6, rand_q7, rand_q8 : integer;
            variable mod_q1, mod_q2, mod_q3, mod_q4 : integer;
            variable mod_q5, mod_q6, mod_q7, mod_q8 : integer;

            variable sx_sz_q1 : std_logic_vector(1 downto 0);
            variable result_q1 : integer; -- mod_q1

            variable sx_sz_q2 : std_logic_vector(1 downto 0);
            variable result_q2 : integer; -- mod_q2

            variable sx_sz_q3 : std_logic_vector(1 downto 0);
            variable result_q3 : integer; -- mod_q3

            variable sx_sz_q4 : std_logic_vector(1 downto 0);
            variable result_q4 : integer; -- mod_q4

            variable sx_sz_q5 : std_logic_vector(1 downto 0);
            variable result_q5 : integer; -- mod_q5

            variable sx_sz_q6 : std_logic_vector(1 downto 0);
            variable result_q6 : integer; -- mod_q6

            variable sx_sz_q7 : std_logic_vector(1 downto 0);
            variable result_q7 : integer; -- mod_q7

            variable sx_sz_q8 : std_logic_vector(1 downto 0);
            variable result_q8 : integer; -- mod_q8

            constant PI : natural := 2;
        begin
            -- Wait until readout transaction
            wait until rising_edge(readout_data_valid);
            wait until rising_edge(readout_clk);

            while readout_data_valid = '1' loop
                -- Update deltas to make sure data vectors contain the most recent value

                -- Parse the data vector
                if readout_data_32b(3 downto 0) = x"1" then
                    rand_q1 := to_integer(unsigned(readout_data_32b(15 downto 15)));
                    rand_q2 := to_integer(unsigned(readout_data_32b(14 downto 14)));
                    rand_q3 := to_integer(unsigned(readout_data_32b(13 downto 13)));
                    rand_q4 := to_integer(unsigned(readout_data_32b(12 downto 12)));

                    mod_q1 := to_integer(unsigned(readout_data_32b(11 downto 10)));
                    mod_q2 := to_integer(unsigned(readout_data_32b(9 downto 8)));
                    mod_q3 := to_integer(unsigned(readout_data_32b(7 downto 6)));
                    mod_q4 := to_integer(unsigned(readout_data_32b(5 downto 4)));

                    if QUBITS_CNT > 1 then
                        sx_sz_q1 := (others => '0');
                        result_q1 := (((-1)**to_integer(unsigned(sx_sz_q1(0 downto 0))) * 0)
                                    + (to_integer(unsigned(sx_sz_q1(1 downto 1))) + rand_q1)*PI) mod 4;
                        assert mod_q1 = result_q1
                            report "Error: Qubit 1: Actual result is : " & integer'image(mod_q1) 
                                    & " . Expected result is : " & integer'image(result_q1)
                            severity failure;

                        sx_sz_q2 := std_logic_vector(to_unsigned(mod_q1, 2));
                        result_q2 := (((-1)**to_integer(unsigned(sx_sz_q2(0 downto 0))) * 1)
                                    + (to_integer(unsigned(sx_sz_q2(1 downto 1))) + rand_q2)*PI) mod 4;
                        assert mod_q2 = result_q2
                            report "Error: Qubit 2: Actual result is : " & integer'image(mod_q2)
                                    & " . Expected result is : " & integer'image(result_q2)
                            severity failure;
                    end if;

                    if QUBITS_CNT > 2 then
                        sx_sz_q3 := std_logic_vector(to_unsigned(mod_q2, 2));
                        result_q3 := (((-1)**to_integer(unsigned(sx_sz_q3(0 downto 0))) * 2)
                                    + (to_integer(unsigned(sx_sz_q3(1 downto 1))) + rand_q3)*PI) mod 4;
                        assert mod_q3 = result_q3
                            report "Error: Qubit 3: Actual result is : " & integer'image(mod_q3) 
                                    & " . Expected result is : " & integer'image(result_q3)
                            severity failure;
                    end if;

                    if QUBITS_CNT > 3 then
                        sx_sz_q4 := std_logic_vector(to_unsigned(mod_q3, 2));
                        result_q4 := (((-1)**to_integer(unsigned(sx_sz_q4(0 downto 0))) * 3)
                                    + (to_integer(unsigned(sx_sz_q4(1 downto 1))) + rand_q4)*PI) mod 4;
                        assert mod_q4 = result_q4
                            report "Error: Qubit 4: Actual result is : " & integer'image(mod_q4) 
                                    & " . Expected result is : " & integer'image(result_q4)
                            severity failure;
                    end if;
                end if;

                -- Parse the data vector
                if readout_data_32b(3 downto 0) = x"5" then
                    rand_q5 := to_integer(unsigned(readout_data_32b(15 downto 15)));
                    rand_q6 := to_integer(unsigned(readout_data_32b(14 downto 14)));
                    rand_q7 := to_integer(unsigned(readout_data_32b(13 downto 13)));
                    rand_q8 := to_integer(unsigned(readout_data_32b(12 downto 12)));

                    mod_q5 := to_integer(unsigned(readout_data_32b(11 downto 10)));
                    mod_q6 := to_integer(unsigned(readout_data_32b(9 downto 8)));
                    mod_q7 := to_integer(unsigned(readout_data_32b(7 downto 6)));
                    mod_q8 := to_integer(unsigned(readout_data_32b(5 downto 4)));

                    if QUBITS_CNT > 4 then
                        sx_sz_q5 := std_logic_vector(to_unsigned(mod_q4, 2));
                        result_q5 := (((-1)**to_integer(unsigned(sx_sz_q5(0 downto 0))) * 0)
                                    + (to_integer(unsigned(sx_sz_q5(1 downto 1))) + rand_q5)*PI) mod 4;
                        assert mod_q5 = result_q5
                            report "Error: Qubit 5: Actual result is : " & integer'image(mod_q5) 
                                    & " . Expected result is : " & integer'image(result_q5)
                            severity failure;
                    end if;

                    if QUBITS_CNT > 5 then
                        sx_sz_q6 := std_logic_vector(to_unsigned(mod_q5, 2));
                        result_q6 := (((-1)**to_integer(unsigned(sx_sz_q6(0 downto 0))) * 1)
                                    + (to_integer(unsigned(sx_sz_q6(1 downto 1))) + rand_q6)*PI) mod 4;
                        assert mod_q6 = result_q6
                            report "Error: Qubit 6: Actual result is : " & integer'image(mod_q6)
                                    & " . Expected result is : " & integer'image(result_q6)
                            severity failure;
                    end if;

                    if QUBITS_CNT > 6 then
                        sx_sz_q7 := std_logic_vector(to_unsigned(mod_q6, 2));
                        result_q7 := (((-1)**to_integer(unsigned(sx_sz_q7(0 downto 0))) * 2)
                                    + (to_integer(unsigned(sx_sz_q7(1 downto 1))) + rand_q7)*PI) mod 4;
                        assert mod_q7 = result_q7
                            report "Error: Qubit 7: Actual result is : " & integer'image(mod_q7)
                                    & " . Expected result is : " & integer'image(result_q7)
                            severity failure;
                    end if;

                    if QUBITS_CNT > 7 then
                        sx_sz_q8 := std_logic_vector(to_unsigned(mod_q7, 2));
                        result_q8 := (((-1)**to_integer(unsigned(sx_sz_q8(0 downto 0))) * 3)
                                    + (to_integer(unsigned(sx_sz_q8(1 downto 1))) + rand_q8)*PI) mod 4;
                        assert mod_q8 = result_q8
                            report "Error: Qubit 8: Actual result is : " & integer'image(mod_q8) 
                                    & " . Expected result is : " & integer'image(result_q8)
                            severity failure;
                    end if;
                end if;

                -- Parse the next transaction
                wait until rising_edge(readout_clk);
            end loop;
        end process;

    end architecture;