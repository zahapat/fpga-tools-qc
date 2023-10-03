    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    use std.textio.all;
    use std.env.finish;

    library lib_src;
    use lib_src.types_pack.all;
    use lib_src.const_pack.all;

    library lib_sim;
    use lib_sim.types_pack_tb.all;
    use lib_sim.const_pack_tb.all;

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

        constant REPETITIONS : positive := 10000;

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
        constant EMULATE_INPUTS     : boolean := true;
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
        signal readout_data_ready : std_logic;
        signal readout_enable     : std_logic;
        signal readout_data_32b   : std_logic_vector(31 downto 0);

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
        -- 1) SYSTEM 230 MHz, 2) NEW_QUBIT 78 MHz, 3) DETECTOR 31 MHz
        sys_clk_p <= not sys_clk_p after CLK_PERIOD / 2;
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
                    wait until rising_edge(sys_clk_p);
                end loop;
            end procedure;

            procedure update_seeds(constant index : integer) is
                begin
                    seed_1 := seed_1 + index;
                    seed_2 := seed_2 + (index+1);
            end procedure;

        begin

            wait for 1 us;

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