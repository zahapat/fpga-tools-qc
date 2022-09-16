    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    use std.textio.all;
    use std.env.finish;

    library lib_src;

    entity top_gflow_tb is
    end top_gflow_tb;

    architecture sim of top_gflow_tb is

        -- FPGA System Clock
        constant CLK_HZ : integer := 200e6;
        constant CLK_PERIOD : time := 1 sec / CLK_HZ;

        -- New qubit each 78 MHz
        constant CLK_NEW_QUBIT_78MHz_HZ : integer := 78e6;
        constant CLK_NEW_QUBIT_78MHz_PERIOD : time := 1 sec / CLK_NEW_QUBIT_78MHz_HZ;
        signal s_clk_new_qubit_78MHz : std_logic := '1';

        -- External Detector: Excelitas SPCM (Single Photon Counting Module) SPCM-AQRH-1X
        -- 31.249999999999996 MHz
        constant SPCM_OUTPUT_PULSE_DUR : time := 10 ns;
        constant SPCM_DEAD_TIME_DUR : time := 22 ns;
        signal s_clk_detector_31MHz : std_logic := '1';

        -- Reset
        constant RST_VAL : std_logic := '1';

        -- Top I/O signals
        signal SYS_CLK     : std_logic := '1';
        signal RST         : std_logic := RST_VAL; -- Pullup
        signal PHOTON_1H   : std_logic_vector(0 downto 0) := "0";
        signal PHOTON_1V   : std_logic_vector(0 downto 0) := "0";
        signal PHOTON_2H   : std_logic_vector(0 downto 0) := "0";
        signal PHOTON_2V   : std_logic_vector(0 downto 0) := "0";
        signal PHOTON_3H   : std_logic_vector(0 downto 0) := "0";
        signal PHOTON_3V   : std_logic_vector(0 downto 0) := "0";
        signal PHOTON_4H   : std_logic_vector(0 downto 0) := "0";
        signal PHOTON_4V   : std_logic_vector(0 downto 0) := "0";
        signal PULSE1_1MHZ : std_logic;
        signal PULSE2_1MHZ : std_logic;

        -- Duration of reset strobe
        constant RST_DURATION : time := 10 * CLK_PERIOD;

        -- REPETITIONS = duration of the test
        constant REPETITIONS : positive := 10000;

        -- Number od random inputs INST_B
        -- THE SEEDS MUST BE MODIFIED!
        constant RAND_NUMBS_SEEDS : natural := 1;

        -- Time the measurement programm has to subtract or add to get the coincidence clicks (CCS)
        constant PHOTON_1H_DELAY_NS : real := 75.65;     -- zero delay = reference
        constant PHOTON_1V_DELAY_NS : real := 75.01;     -- zero delay = reference
        constant PHOTON_2H_DELAY_NS : real := -2117.95;  -- fibre delay of qubit 2
        constant PHOTON_2V_DELAY_NS : real := -2125.35;  -- fibre delay of qubit 2
        constant PHOTON_3H_DELAY_NS : real := -1030.35;  -- fibre delay of qubit 3
        constant PHOTON_3V_DELAY_NS : real := -1034.45;  -- fibre delay of qubit 3
        constant PHOTON_4H_DELAY_NS : real := -3177.95;  -- fibre delay of qubit 4
        constant PHOTON_4V_DELAY_NS : real := -3181.05;  -- fibre delay of qubit 4
            -- constant PHOTON_1H_DELAY_NS : real := 0.0;     -- zero delay = reference
            -- constant PHOTON_1V_DELAY_NS : real := 0.0;     -- zero delay = reference
            -- constant PHOTON_2H_DELAY_NS : real := 0.0;  -- fibre delay of qubit 2
            -- constant PHOTON_2V_DELAY_NS : real := 0.0;  -- fibre delay of qubit 2
            -- constant PHOTON_3H_DELAY_NS : real := 0.0;  -- fibre delay of qubit 3
            -- constant PHOTON_3V_DELAY_NS : real := 0.0;  -- fibre delay of qubit 3
            -- constant PHOTON_4H_DELAY_NS : real := 0.0;  -- fibre delay of qubit 4
            -- constant PHOTON_4V_DELAY_NS : real := 0.0;  -- fibre delay of qubit 4

        signal s_qubits_78MHz : std_logic_vector(7 downto 0) := (others => '0');
        signal s_qubits_31MHz : std_logic_vector(7 downto 0) := (others => '0');

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

        type t_state_gflow is (
            QUBIT_1,
            QUBIT_2,
            QUBIT_3,
            QUBIT_4
        );
        signal state_gflow : t_state_gflow := QUBIT_1;

    begin

        ------------------
        -- DUT instance --
        ------------------
        dut_top_gflow : entity lib_src.top_gflow(str)
        generic map (
            CLK_HZ             => CLK_HZ,
            RST_VAL            => RST_VAL,
            PHOTON_1H_DELAY_NS => PHOTON_1H_DELAY_NS,
            PHOTON_1V_DELAY_NS => PHOTON_1V_DELAY_NS,
            PHOTON_2H_DELAY_NS => PHOTON_2H_DELAY_NS,
            PHOTON_2V_DELAY_NS => PHOTON_2V_DELAY_NS,
            PHOTON_3H_DELAY_NS => PHOTON_3H_DELAY_NS,
            PHOTON_3V_DELAY_NS => PHOTON_3V_DELAY_NS,
            PHOTON_4H_DELAY_NS => PHOTON_4H_DELAY_NS,
            PHOTON_4V_DELAY_NS => PHOTON_4V_DELAY_NS
        )
        port map (
            SYS_CLK => SYS_CLK,
            RST_SECTOR_1 => RST,
            PHOTON_1H_PMODA => s_qubits_31MHz(7),
            PHOTON_1V_PMODA => s_qubits_31MHz(6),
            PHOTON_2H_PMODA => s_qubits_31MHz(5),
            PHOTON_2V_PMODA => s_qubits_31MHz(4),
            PHOTON_3H_PMODA => s_qubits_31MHz(3),
            PHOTON_3V_PMODA => s_qubits_31MHz(2),
            PHOTON_4H_PMODA => s_qubits_31MHz(1),
            PHOTON_4V_PMODA => s_qubits_31MHz(0),
            -- PULSE1_1MHZ => PULSE1_1MHZ,
            PULSE2_1MHZ_PMODB => PULSE2_1MHZ
        );

        -----------------------
        -- Clock Oscillators --
        -----------------------
        -- 1) SYSTEM 230 MHz, 2) NEW_QUBIT 78 MHz, 3) DETECTOR 31 MHz
        SYS_CLK <= not SYS_CLK after CLK_PERIOD / 2;
        s_clk_new_qubit_78MHz <= not s_clk_new_qubit_78MHz after CLK_NEW_QUBIT_78MHz_PERIOD / 2;
        proc_spcm_detector_osc : process
        begin
            for i in 0 to REPETITIONS-1 loop
                s_clk_detector_31MHz <= '1' ;
                wait for SPCM_OUTPUT_PULSE_DUR;
                s_clk_detector_31MHz <= '0';
                wait for SPCM_DEAD_TIME_DUR;
            end loop;
        end process;


        ---------------------------------------------
        -- GENERATE RANDOM QUBITS WITH FREQ 78 MHz --
        ---------------------------------------------
        proc_gen_rand_qbts : process
            -- Random SLV generator
            variable v_rand : std_logic_vector(7 downto 0) := (others => '0');
            variable seed_1, seed_2 : integer := RAND_NUMBS_SEEDS;
            impure function rand_slv (
                constant length : integer
            ) return std_logic_vector is
                variable r   : real;
                variable slv : std_logic_vector(length-1 downto 0);
            begin
                for i in slv'range loop
                    uniform(seed_1, seed_2, r);
                    slv(i) := '1' when r > 0.5 else '0';
                end loop;
                return slv;
            end function;

            procedure update_seeds(constant index : integer) is
                begin
                    seed_1 := seed_1 + index;
                    seed_2 := seed_2 + (index+1);
            end procedure;

        begin

            -- Send some random data to the system and to the TB
            for i in 0 to REPETITIONS-1 loop
                s_qubits_78MHz <= rand_slv(8);
                update_seeds(i);
                wait until rising_edge(s_clk_new_qubit_78MHz);
            end loop;
        end process;


        -------------------------------------------
        -- DETECT RANDOM QUBITS WITH FREQ 31 MHz --
        -------------------------------------------
        -- 31.249999999999996 MHz
        -- proc_detect_rand_qbts : process(all)
        proc_detect_rand_qbts : process
        begin

            for i in 0 to REPETITIONS-1 loop
                s_qubits_31MHz <= s_qubits_78MHz;
                wait for SPCM_OUTPUT_PULSE_DUR;
                s_qubits_31MHz <= (others => '0');
                wait for SPCM_DEAD_TIME_DUR;
            end loop;

            -- Send new data to the DUT each 32 ns
            -- if s_clk_detector_31MHz = '1' then
            --     -- Keep them during SPCM Active period
            --     s_qubits_31MHz <= s_qubits_78MHz;
            -- else
            --     -- Respect SPCM Dead Period
            --     s_qubits_31MHz <= (others => '0');
            -- end if;
        end process;


        -----------------------------------------
        -- SIMULATE DELAYED HORIZONTAL PHOTONS --
        -----------------------------------------
        -- proc_horizontal_photons_arrival : process
        --     variable v_rand_delta_ns : real := 0.0;
        --     variable v_str_state : t_state_gflow := QUBIT_1;
        --     -- Random real number generator
        --     variable seed_1, seed_2 : integer := RAND_NUMBS_SEEDS;
        --     impure function rand_real(min_val, max_val : real)
        --     return real is
        --         variable r : real;
        --     begin
        --         uniform(seed_1, seed_2, r);
        --         return r * (max_val - min_val) + min_val;
        --     end function;
        -- begin

        --     -- 78 MHz = 12.820512820513 ns
        --     -- Horizontal photons
        --     for i in 0 to REPETITIONS-1 loop
        --         v_str_state := << signal DUT.inst_gflow_fsm.state_gflow : t_state_gflow >>;
        --         case v_str_state is
        --             when QUBIT_1 =>
        --                 -- Wait for the rising edge of the input signal (about 31 MHz)
        --                 wait until rising_edge(s_clk_detector_31MHz);
        --                 v_rand_delta_ns := rand_real(DELTA_ARRIVAL_MIN_NS, DELTA_ARRIVAL_MAX_NS);
        --                 -- wait for (abs(PHOTON_1H_DELAY_NS) + v_rand_delta_ns)*1 ns; -- WRONG
        --                 report "TX(H): QUBIT_1 AFTER " & to_string(PHOTON_1H_DELAY_NS, "%.3f") & " ns + rand. delta " & to_string(v_rand_delta_ns, "%.3f") & " ns.";
        --                 -- FORCE
        --                 -- ...
        --                 wait for SPCM_OUTPUT_PULSE_DUR;
        --                 -- RELEASE

        --             when QUBIT_2 =>
        --                 -- Flow
        --                 v_rand_delta_ns := rand_real(DELTA_ARRIVAL_MIN_NS, DELTA_ARRIVAL_MAX_NS);
        --                 -- wait for (abs(PHOTON_2H_DELAY_NS) + v_rand_delta_ns)*1 ns; -- WRONG
        --                 report "TX(H): QUBIT_2 AFTER " & to_string(PHOTON_2H_DELAY_NS, "%.3f") & " ns + rand. delta " & to_string(v_rand_delta_ns, "%.3f") & " ns.";
        --                 -- FORCE
        --                 -- ...
        --                 wait for SPCM_OUTPUT_PULSE_DUR;
        --                 -- RELEASE

        --             when QUBIT_3 =>
        --                 -- Flow
        --                 v_rand_delta_ns := rand_real(DELTA_ARRIVAL_MIN_NS, DELTA_ARRIVAL_MAX_NS);
        --                 -- wait for (abs(PHOTON_3H_DELAY_NS) + v_rand_delta_ns)*1 ns; -- WRONG
        --                 report "TX(H): QUBIT_3 AFTER " & to_string(PHOTON_3H_DELAY_NS, "%.3f") & " ns + rand. delta " & to_string(v_rand_delta_ns, "%.3f") & " ns.";
        --                 -- FORCE
        --                 -- ...
        --                 wait for SPCM_OUTPUT_PULSE_DUR;
        --                 -- RELEASE

        --             when QUBIT_4 =>
        --                 -- Flow
        --                 v_rand_delta_ns := rand_real(DELTA_ARRIVAL_MIN_NS, DELTA_ARRIVAL_MAX_NS);
        --                 -- wait for (abs(PHOTON_4H_DELAY_NS) + v_rand_delta_ns)*1 ns;
        --                 report "TX(H): QUBIT_4 AFTER " & to_string(PHOTON_4H_DELAY_NS, "%.3f") & " ns + rand. delta " & to_string(v_rand_delta_ns, "%.3f") & " ns.";
        --                 -- FORCE
        --                 -- ...
        --                 wait for SPCM_OUTPUT_PULSE_DUR;
        --                 -- RELEASE
        --         end case;

        --         -- Update seeds for new values
        --         seed_1 := seed_1 + i;
        --         seed_2 := seed_2 + (i+1);
        --     end loop;

        -- end process;


        -- ---------------------------------------
        -- -- SIMULATE DELAYED VERTICAL PHOTONS --
        -- ---------------------------------------
        -- proc_vertical_photons_arrival : process
        --     variable v_rand_delta_ns : real := 0.0;
        --     variable v_str_state : t_state_gflow := QUBIT_1;
        --     -- Random real number generator
        --     variable seed_1, seed_2 : integer := RAND_NUMBS_SEEDS;
        --     impure function rand_real(min_val, max_val : real)
        --     return real is
        --         variable r : real;
        --     begin
        --         uniform(seed_1, seed_2, r);
        --         return r * (max_val - min_val) + min_val;
        --     end function;

        -- begin

        --     -- 78 MHz = 12.820512820513 ns
        --     -- Vertical photons
        --     for i in 0 to REPETITIONS-1 loop
        --         v_str_state := << signal DUT.inst_gflow_fsm.state_gflow : t_state_gflow >>;
        --         case v_str_state is
        --             when QUBIT_1 =>
        --                 -- Wait for the rising edge of the input signal from the detector (about 31 MHz)
        --                 wait until rising_edge(s_clk_detector_31MHz);
        --                 v_rand_delta_ns := rand_real(DELTA_ARRIVAL_MIN_NS, DELTA_ARRIVAL_MAX_NS);
        --                 -- wait for (abs(PHOTON_1V_DELAY_NS) + v_rand_delta_ns)*1 ns; -- WRONG
        --                 report "TX(V): QUBIT_1 AFTER " & to_string(PHOTON_1V_DELAY_NS, "%.3f") & " ns + rand. delta " & to_string(v_rand_delta_ns, "%.3f") & " ns.";
        --                 -- FORCE
        --                 -- ...
        --                 wait for SPCM_OUTPUT_PULSE_DUR;
        --                 -- RELEASE

        --             when QUBIT_2 =>
        --                 -- Flow
        --                 v_rand_delta_ns := rand_real(DELTA_ARRIVAL_MIN_NS, DELTA_ARRIVAL_MAX_NS);
        --                 -- wait for (abs(PHOTON_2V_DELAY_NS) + v_rand_delta_ns)*1 ns; -- WRONG
        --                 report "TX(V): QUBIT_2 AFTER " & to_string(PHOTON_2V_DELAY_NS, "%.3f") & " ns + rand. delta " & to_string(v_rand_delta_ns, "%.3f") & " ns.";
        --                 -- FORCE
        --                 -- ...
        --                 wait for SPCM_OUTPUT_PULSE_DUR;
        --                 -- RELEASE

        --             when QUBIT_3 =>
        --                 -- Flow
        --                 v_rand_delta_ns := rand_real(DELTA_ARRIVAL_MIN_NS, DELTA_ARRIVAL_MAX_NS);
        --                 -- wait for (abs(PHOTON_3V_DELAY_NS) + v_rand_delta_ns)*1 ns; -- WRONG
        --                 report "TX(V): QUBIT_3 AFTER " & to_string(PHOTON_3V_DELAY_NS, "%.3f") & " ns + rand. delta " & to_string(v_rand_delta_ns, "%.3f") & " ns.";
        --                 -- FORCE
        --                 -- ...
        --                 wait for SPCM_OUTPUT_PULSE_DUR;
        --                 -- RELEASE

        --             when QUBIT_4 =>
        --                 -- Flow
        --                 v_rand_delta_ns := rand_real(DELTA_ARRIVAL_MIN_NS, DELTA_ARRIVAL_MAX_NS);
        --                 -- wait for (abs(PHOTON_4V_DELAY_NS) + v_rand_delta_ns)*1 ns; -- WRONG
        --                 report "TX(V): QUBIT_4 AFTER " & to_string(PHOTON_4V_DELAY_NS, "%.3f") & " ns + rand. delta " & to_string(v_rand_delta_ns, "%.3f") & " ns.";
        --                 -- FORCE
        --                 -- ...
        --                 wait for SPCM_OUTPUT_PULSE_DUR;
        --                 -- RELEASE
        --         end case;

        --         -- Update seeds for new values
        --         seed_1 := seed_1 + i;
        --         seed_2 := seed_2 + (i+1);
        --     end loop;

        -- end process;
 

        ---------------
        -- SEQUENCER --
        ---------------
        proc_sequencer : process

        variable v_keep_time_pulse_p1 : time;

            -- Random SLV generator
            variable v_rand_slv : std_logic_vector(0 downto 0) := "0";
            variable seed_1, seed_2 : integer := 0;
            impure function rand_slv (
                constant length : integer
            ) return std_logic_vector is
                variable r   : real;
                variable slv : std_logic_vector(length-1 downto 0);
            begin
                for i in slv'range loop
                    uniform(seed_1, seed_2, r);
                    slv(i) := '1' when r > 0.5 else '0';
                end loop;
                return slv;
            end function;

            -- Wait for certain number of SYSTEM clk cycles
            procedure wait_cycles (
                constant cycles_cnt : integer
            ) is begin
                for i in 0 to cycles_cnt-1 loop
                    wait until rising_edge(SYS_CLK);
                end loop;
            end procedure;

            procedure update_seeds(constant index : integer) is
                begin
                    seed_1 := seed_1 + index;
                    seed_2 := seed_2 + (index+1);
            end procedure;

        begin

            -- Reset strobe
            wait for RST_DURATION;

            -- Release reset
            RST <= RST_VAL;

            -- Run for certain number of cycles: send random data
            for i in 0 to REPETITIONS-1 loop
                -- transmit;
                wait_cycles(1);
            end loop;

            print_test_ok;
            finish;
            wait;
        end process;

    end architecture;