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
    use lib_sim.clk_pack_tb.all;

    library OSVVM;
    use OSVVM.RandomPkg.all;

    entity top_gflow_tb is
    end top_gflow_tb;

    architecture sim of top_gflow_tb is

        constant PROJ_DIR : string := PROJ_DIR;

        -- File I/O
        file sim_result : text;

        -- Simulation control signals
        type t_input_emulation_mode is (
            SEND_PHOTON_EVERY_LASER_CLK,
            SEND_CLUSTER_THEN_WAIT
        );
        constant TIME_BETWEEN_CLUSTERS_NS : time := 1000.0 ns;
        signal ctrl_input_emulation_mode : t_input_emulation_mode := SEND_PHOTON_EVERY_LASER_CLK;
        signal ctrl_sim_start : std_logic := '0';

        -- FPGA On-Board Oscillator Frequency (Input to MMCM/Clock Wizard)
        constant CLK_HZ : real := 200.0e6;
        constant CLK_PERIOD : time := 1.0 sec / CLK_HZ;

        -- New qubit each 80 MHz (# TODO implement emission probability)
        constant CLK_NEW_QUBIT_78MHz_HZ : real := 80.0e6;
        constant LASER_CLK_PERIOD : time := 1 sec / CLK_NEW_QUBIT_78MHz_HZ;
        signal laser_clk : std_logic := '1';

        -- External Detector: Excelitas SPCM (Single Photon Counting Module) SPCM-AQRH-1X
        constant NOMINAL_DETECTOR_HIGH_TIME_NS : time := 10 ns;
        constant NOMINAL_DETECTOR_DEAD_TIME_NS : time := 22 ns;
        constant REALISTIC_DETECTOR_HIGH_TIME_NS : time := 5 ns;

        -- Gflow generics
        constant RST_VAL                      : std_logic := '1';
        constant CLK_SYS_HZ                   : real := 104.16667e6;
        constant CLK_SAMPL_HZ                 : real := 250.0e6;
        constant INT_QUBITS_CNT               : positive := INT_QUBITS_CNT;
        constant INT_EMULATE_INPUTS           : integer := INT_EMULATE_INPUTS;
        constant INT_WHOLE_PHOTON_1H_DELAY_NS : integer := INT_WHOLE_PHOTON_1H_DELAY_NS;
        constant INT_DECIM_PHOTON_1H_DELAY_NS : integer := INT_DECIM_PHOTON_1H_DELAY_NS;
        constant INT_WHOLE_PHOTON_1V_DELAY_NS : integer := INT_WHOLE_PHOTON_1V_DELAY_NS;
        constant INT_DECIM_PHOTON_1V_DELAY_NS : integer := INT_DECIM_PHOTON_1V_DELAY_NS;
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

        -- PCD Control Pulse Design & Delay
        constant INT_CTRL_PULSE_HIGH_DURATION_NS : integer := INT_CTRL_PULSE_HIGH_DURATION_NS;
        constant INT_CTRL_PULSE_DEAD_DURATION_NS : integer := INT_CTRL_PULSE_DEAD_DURATION_NS;
        constant INT_CTRL_PULSE_EXTRA_DELAY_NS   : integer := INT_CTRL_PULSE_EXTRA_DELAY_NS;

        constant WRITE_ON_VALID     : boolean := true;

        -- I/O Channels
        constant INPUT_PADS_CNT     : positive := 2*INT_QUBITS_CNT;
        constant OUTPUT_PADS_CNT    : positive := 1;

        -- Top I/O signals
        signal sys_clk_p     : std_logic := '1';
        signal sys_clk_n     : std_logic := '0';

        signal led : std_logic_vector(4-1 downto 0);

        signal input_pads : std_logic_vector(INPUT_PADS_CNT-1 downto 0) := (others => '0');
        signal output_pads : std_logic_vector(OUTPUT_PADS_CNT-1 downto 0);

        signal readout_clk        : std_logic := '0';
        signal readout_data_ready : std_logic := '0';
        signal readout_data_valid : std_logic := '0';
        signal readout_enable     : std_logic := '0';
        signal readout_data_32b   : std_logic_vector(31 downto 0);

        signal s_qubits : std_logic_vector(2*INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal s_faster_photon_event : std_logic_vector(2*INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal s_photon_value_latched : std_logic_vector(2*INT_QUBITS_CNT-1 downto 0) := (others => '0');

        -- Delta time of the arrival of a single photon
        constant DELTA_ARRIVAL_MIN_NS : real := -0.5;
        constant DELTA_ARRIVAL_MAX_NS : real := 0.5;

        -- Convert Integer generic values to real numbers
        -- Prevent dividing by zero
        impure function get_divisor (
            constant DIVISOR : integer
        ) return integer is
        begin
            if DIVISOR = 0 then
                return 1;
            else
                return integer(10.0**(floor(log10(real(DIVISOR))) + 1.0));
            end if;
        end function;
        constant PHOTON_1H_DELAY_ABS_NS : real := abs(real(INT_WHOLE_PHOTON_1H_DELAY_NS) + real(INT_DECIM_PHOTON_1H_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_1H_DELAY_NS)));
        constant PHOTON_1V_DELAY_ABS_NS : real := abs(real(INT_WHOLE_PHOTON_1V_DELAY_NS) + real(INT_DECIM_PHOTON_1V_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_1V_DELAY_NS)));
        constant PHOTON_2H_DELAY_ABS_NS : real := abs(real(INT_WHOLE_PHOTON_2H_DELAY_NS) + real(INT_DECIM_PHOTON_2H_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_2H_DELAY_NS)));
        constant PHOTON_2V_DELAY_ABS_NS : real := abs(real(INT_WHOLE_PHOTON_2V_DELAY_NS) + real(INT_DECIM_PHOTON_2V_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_2V_DELAY_NS)));
        constant PHOTON_3H_DELAY_ABS_NS : real := abs(real(INT_WHOLE_PHOTON_3H_DELAY_NS) + real(INT_DECIM_PHOTON_3H_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_3H_DELAY_NS)));
        constant PHOTON_3V_DELAY_ABS_NS : real := abs(real(INT_WHOLE_PHOTON_3V_DELAY_NS) + real(INT_DECIM_PHOTON_3V_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_3V_DELAY_NS)));
        constant PHOTON_4H_DELAY_ABS_NS : real := abs(real(INT_WHOLE_PHOTON_4H_DELAY_NS) + real(INT_DECIM_PHOTON_4H_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_4H_DELAY_NS)));
        constant PHOTON_4V_DELAY_ABS_NS : real := abs(real(INT_WHOLE_PHOTON_4V_DELAY_NS) + real(INT_DECIM_PHOTON_4V_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_4V_DELAY_NS)));
        constant PHOTON_5H_DELAY_ABS_NS : real := abs(real(INT_WHOLE_PHOTON_5H_DELAY_NS) + real(INT_DECIM_PHOTON_5H_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_5H_DELAY_NS)));
        constant PHOTON_5V_DELAY_ABS_NS : real := abs(real(INT_WHOLE_PHOTON_5V_DELAY_NS) + real(INT_DECIM_PHOTON_5V_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_5V_DELAY_NS)));
        constant PHOTON_6H_DELAY_ABS_NS : real := abs(real(INT_WHOLE_PHOTON_6H_DELAY_NS) + real(INT_DECIM_PHOTON_6H_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_6H_DELAY_NS)));
        constant PHOTON_6V_DELAY_ABS_NS : real := abs(real(INT_WHOLE_PHOTON_6V_DELAY_NS) + real(INT_DECIM_PHOTON_6V_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_6V_DELAY_NS)));

        type t_real_arr_2d is array(6-1 downto 0) of real;
        constant PHOTON_V_DELAY_ABS_NS : t_real_arr_2d := (
            PHOTON_6V_DELAY_ABS_NS, -- index 5
            PHOTON_5V_DELAY_ABS_NS, -- index 4
            PHOTON_4V_DELAY_ABS_NS, -- index 3
            PHOTON_3V_DELAY_ABS_NS, -- index 2
            PHOTON_2V_DELAY_ABS_NS, -- index 1
            PHOTON_1V_DELAY_ABS_NS  -- index 0 (never used)
        );
        constant PHOTON_H_DELAY_ABS_NS : t_real_arr_2d := (
            PHOTON_6H_DELAY_ABS_NS, -- index 5
            PHOTON_5H_DELAY_ABS_NS, -- index 4
            PHOTON_4H_DELAY_ABS_NS, -- index 3
            PHOTON_3H_DELAY_ABS_NS, -- index 2
            PHOTON_2H_DELAY_ABS_NS, -- index 1
            PHOTON_1H_DELAY_ABS_NS  -- index 0 (never used)
        );

        impure function get_faster_photon_real (
            constant REAL_DELAY_HORIZ_ABS : real;
            constant REAL_DELAY_VERTI_ABS : real
        ) return real is
        begin
            -- Consistent logic with 'get_faster_photon_index'
            -- Faster = higher number (abs)
            if REAL_DELAY_HORIZ_ABS < REAL_DELAY_VERTI_ABS then
                return REAL_DELAY_VERTI_ABS;
            else
                return REAL_DELAY_HORIZ_ABS;
            end if;
        end function;

        impure function get_slower_photon_real (
            constant REAL_DELAY_HORIZ_ABS : real;
            constant REAL_DELAY_VERTI_ABS : real
        ) return real is
        begin
            -- Consistent logic with 'get_slower_photon_index'
            -- Faster = higher number (abs)
            if REAL_DELAY_HORIZ_ABS < REAL_DELAY_VERTI_ABS then
                return REAL_DELAY_HORIZ_ABS;
            else
                return REAL_DELAY_VERTI_ABS;
            end if;
        end function;

        constant PHOTON_1HV_DIFFERENCE_ABS_NS : real := abs(get_slower_photon_real(PHOTON_1H_DELAY_ABS_NS,PHOTON_1V_DELAY_ABS_NS) 
                                                          - get_faster_photon_real(PHOTON_1H_DELAY_ABS_NS,PHOTON_1V_DELAY_ABS_NS));
        constant PHOTON_2HV_DIFFERENCE_ABS_NS : real := abs(get_slower_photon_real(PHOTON_2H_DELAY_ABS_NS,PHOTON_2V_DELAY_ABS_NS) 
                                                          - get_faster_photon_real(PHOTON_2H_DELAY_ABS_NS,PHOTON_2V_DELAY_ABS_NS));
        constant PHOTON_3HV_DIFFERENCE_ABS_NS : real := abs(get_slower_photon_real(PHOTON_3H_DELAY_ABS_NS,PHOTON_3V_DELAY_ABS_NS) 
                                                          - get_faster_photon_real(PHOTON_3H_DELAY_ABS_NS,PHOTON_3V_DELAY_ABS_NS));
        constant PHOTON_4HV_DIFFERENCE_ABS_NS : real := abs(get_slower_photon_real(PHOTON_4H_DELAY_ABS_NS,PHOTON_4V_DELAY_ABS_NS) 
                                                          - get_faster_photon_real(PHOTON_4H_DELAY_ABS_NS,PHOTON_4V_DELAY_ABS_NS));
        constant PHOTON_5HV_DIFFERENCE_ABS_NS : real := abs(get_slower_photon_real(PHOTON_5H_DELAY_ABS_NS,PHOTON_5V_DELAY_ABS_NS) 
                                                          - get_faster_photon_real(PHOTON_5H_DELAY_ABS_NS,PHOTON_5V_DELAY_ABS_NS));
        constant PHOTON_6HV_DIFFERENCE_ABS_NS : real := abs(get_slower_photon_real(PHOTON_6H_DELAY_ABS_NS,PHOTON_6V_DELAY_ABS_NS) 
                                                          - get_faster_photon_real(PHOTON_6H_DELAY_ABS_NS,PHOTON_6V_DELAY_ABS_NS));
        constant PHOTON_HV_DIFFERENCE_ABS_NS : t_real_arr_2d := (
            PHOTON_6HV_DIFFERENCE_ABS_NS,
            PHOTON_5HV_DIFFERENCE_ABS_NS,
            PHOTON_4HV_DIFFERENCE_ABS_NS,
            PHOTON_3HV_DIFFERENCE_ABS_NS,
            PHOTON_2HV_DIFFERENCE_ABS_NS,
            PHOTON_1HV_DIFFERENCE_ABS_NS
        );

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
            INT_QUBITS_CNT               => INT_QUBITS_CNT,
            INT_EMULATE_INPUTS           => INT_EMULATE_INPUTS,
            INT_WHOLE_PHOTON_1H_DELAY_NS => INT_WHOLE_PHOTON_1H_DELAY_NS,
            INT_DECIM_PHOTON_1H_DELAY_NS => INT_DECIM_PHOTON_1H_DELAY_NS,
            INT_WHOLE_PHOTON_1V_DELAY_NS => INT_WHOLE_PHOTON_1V_DELAY_NS,
            INT_DECIM_PHOTON_1V_DELAY_NS => INT_DECIM_PHOTON_1V_DELAY_NS,
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

            -- PCD Control Pulse Design & Delay
            INT_CTRL_PULSE_HIGH_DURATION_NS => INT_CTRL_PULSE_HIGH_DURATION_NS,
            INT_CTRL_PULSE_DEAD_DURATION_NS => INT_CTRL_PULSE_DEAD_DURATION_NS,
            INT_CTRL_PULSE_EXTRA_DELAY_NS   => INT_CTRL_PULSE_EXTRA_DELAY_NS,

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
        laser_clk <= not laser_clk after LASER_CLK_PERIOD / 2.0;
        readout_clk <= not readout_clk after 5 ns;

        -----------------------------------------------------------
        -- GENERATE RANDOM QUBITS AT A LASER FREQUENCY OF 80 MHz --
        -----------------------------------------------------------
        proc_model_photon_1v : process
            -- Random SLV type generator
            variable rand_slv : RandomPType;
        begin

            -- Triggers this block
            wait until rising_edge(ctrl_sim_start);

            -- Test if this photon is faster as logic will differ for both cases
            if PHOTON_1V_DELAY_ABS_NS <= PHOTON_1H_DELAY_ABS_NS then
                wait_deltas(1);
                -- Create a unique seed (if the same seed is used in all qubits, detected qubits will be the same)
                rand_slv.InitSeed(RANDOM_SEED_1);
                wait_deltas(1);

                loop
                    if ctrl_input_emulation_mode = SEND_PHOTON_EVERY_LASER_CLK then
                        wait until rising_edge(laser_clk);
                    end if;

                    -- Create the randomized values (Normal Distribution)
                    s_qubits(0 downto 0) <= rand_slv.Randslv((0, 1), 1);
                    wait_deltas(1);
                    s_photon_value_latched(0) <= s_qubits(0);
                    wait_deltas(1);
                    s_faster_photon_event(0) <= not s_faster_photon_event(0);
                    wait_deltas(1);

                    input_pads(0) <= s_qubits(0);
                    wait_deltas(1);
                    wait for REALISTIC_DETECTOR_HIGH_TIME_NS;

                    -- Model Detector Dead Time (until next laser clk tick)
                    input_pads(0) <= '0';
                    wait_deltas(1);

                    if ctrl_input_emulation_mode = SEND_CLUSTER_THEN_WAIT then
                        if PHOTON_V_DELAY_ABS_NS(INT_QUBITS_CNT-1) <= PHOTON_H_DELAY_ABS_NS(INT_QUBITS_CNT-1) then
                            wait for PHOTON_H_DELAY_ABS_NS(INT_QUBITS_CNT-1) * 1.0 ns;
                        else
                            wait for PHOTON_V_DELAY_ABS_NS(INT_QUBITS_CNT-1) * 1.0 ns;
                        end if;
                        wait for TIME_BETWEEN_CLUSTERS_NS;
                    end if;
                    
                end loop;
            else
                -- If photon V is slower (has smaller delay) ensure 01/10 configuration
                loop
                    wait until s_faster_photon_event(1)'event;
                    wait for PHOTON_1HV_DIFFERENCE_ABS_NS * 1.0 ns;
                    s_qubits(0) <= not(s_photon_value_latched(1));
                    wait_deltas(1);
                    input_pads(0) <= s_qubits(0);
                    wait_deltas(1);
                    wait for REALISTIC_DETECTOR_HIGH_TIME_NS;

                    -- Model Detector Dead Time
                    input_pads(0) <= '0';
                    wait_deltas(1);
                end loop;

            end if;
        end process;

        proc_model_photon_1h : process
            -- Random SLV type generator
            variable rand_slv : RandomPType;
        begin

            -- Triggers this block
            wait until rising_edge(ctrl_sim_start);

            -- Test if this photon is faster as logic will differ for both cases
            if PHOTON_1V_DELAY_ABS_NS > PHOTON_1H_DELAY_ABS_NS then
                wait_deltas(1);
                -- Create a unique seed (if the same seed is used in all qubits, detected qubits will be the same)
                rand_slv.InitSeed(99+RANDOM_SEED_1);
                wait_deltas(1);

                loop

                    if ctrl_input_emulation_mode = SEND_PHOTON_EVERY_LASER_CLK then
                        wait until rising_edge(laser_clk);
                    end if;

                    -- Create the randomized values (Normal Distribution)
                    s_qubits(1 downto 1) <= rand_slv.Randslv((0, 1), 1);
                    wait_deltas(1);
                    s_photon_value_latched(1) <= s_qubits(1);
                    wait_deltas(1);
                    s_faster_photon_event(1) <= not s_faster_photon_event(1);
                    wait_deltas(1);

                    input_pads(1) <= s_qubits(1);
                    wait_deltas(1);
                    wait for REALISTIC_DETECTOR_HIGH_TIME_NS;

                    -- Model Detector Dead Time (until next laser clk tick)
                    input_pads(1) <= '0';
                    wait_deltas(1);

                    if ctrl_input_emulation_mode = SEND_CLUSTER_THEN_WAIT then
                        if PHOTON_V_DELAY_ABS_NS(INT_QUBITS_CNT-1) <= PHOTON_H_DELAY_ABS_NS(INT_QUBITS_CNT-1) then
                            wait for PHOTON_H_DELAY_ABS_NS(INT_QUBITS_CNT-1) * 1.0 ns;
                        else
                            wait for PHOTON_V_DELAY_ABS_NS(INT_QUBITS_CNT-1) * 1.0 ns;
                        end if;
                        wait for TIME_BETWEEN_CLUSTERS_NS;
                    end if;

                end loop;
            else
                -- If photon H is slower (has smaller delay) ensure 01/10 configuration
                loop
                    wait until s_faster_photon_event(0)'event;
                    wait for PHOTON_1HV_DIFFERENCE_ABS_NS * 1.0 ns;
                    s_qubits(1) <= not(s_photon_value_latched(0));
                    wait_deltas(1);
                    input_pads(1) <= s_qubits(1);
                    wait_deltas(1);
                    wait for REALISTIC_DETECTOR_HIGH_TIME_NS;

                    -- Model Detector Dead Time
                    input_pads(1) <= '0';
                    wait_deltas(1);
                end loop;

            end if;
        end process;


        -- Send Qubits 2 to MAX 6
        gen_photon_detectors : for p in 1 to INT_QUBITS_CNT-1 generate
            proc_model_photon_v : process
                -- Random SLV type generator
                variable rand_slv : RandomPType;
            begin

                -- Triggers this block
                wait until rising_edge(ctrl_sim_start);

                -- Wait for time reference event (faster photon 1)
                if PHOTON_1V_DELAY_ABS_NS <= PHOTON_1H_DELAY_ABS_NS then
                    wait until s_faster_photon_event(0)'event;
                else
                    wait until s_faster_photon_event(1)'event;
                end if;

                -- Test if this photon is faster as logic will differ for both cases
                if PHOTON_V_DELAY_ABS_NS(p) <= PHOTON_H_DELAY_ABS_NS(p) then
                    wait_deltas(1);
                    -- Create a unique seed (if the same seed is used in all qubits, detected qubits will be the same)
                    rand_slv.InitSeed(RANDOM_SEED_1+(p**2+p**2));
                    wait_deltas(1);

                    wait for PHOTON_V_DELAY_ABS_NS(p) * 1.0 ns;

                    loop

                        -- Create the randomized values (Normal Distribution)
                        s_qubits(p*2 downto p*2) <= rand_slv.Randslv((0, 1), 1);
                        wait_deltas(1);
                        s_photon_value_latched(p*2) <= s_qubits(p*2);
                        wait_deltas(1);
                        s_faster_photon_event(p*2) <= not s_faster_photon_event(p*2);
                        wait_deltas(1);

                        input_pads(p*2) <= s_qubits(p*2);
                        wait_deltas(1);
                        wait for REALISTIC_DETECTOR_HIGH_TIME_NS;

                        -- Model Detector Dead Time
                        input_pads(p*2) <= '0';
                        wait_deltas(1);

                        -- Wait for next laser clk minus the time spent on transmitting a pulse
                        if ctrl_input_emulation_mode = SEND_PHOTON_EVERY_LASER_CLK then
                            wait for LASER_CLK_PERIOD-REALISTIC_DETECTOR_HIGH_TIME_NS;

                        -- Wait for an event on the first qubit
                        elsif ctrl_input_emulation_mode = SEND_CLUSTER_THEN_WAIT then
                            if PHOTON_1V_DELAY_ABS_NS <= PHOTON_1H_DELAY_ABS_NS then
                                wait until s_faster_photon_event(0)'event;
                            else
                                wait until s_faster_photon_event(1)'event;
                            end if;
                            wait for PHOTON_V_DELAY_ABS_NS(p) * 1.0 ns;

                        end if;
                    end loop;
                else
                    -- If photon V is slower (has smaller delay) ensure 01/10 configuration
                    loop
                        wait until s_faster_photon_event((p+1)*2-1)'event;
                        wait for PHOTON_HV_DIFFERENCE_ABS_NS(p) * 1.0 ns;
                        s_qubits(p*2) <= not(s_photon_value_latched((p+1)*2-1));
                        wait_deltas(1);
                        input_pads(p*2) <= s_qubits(p*2);
                        wait_deltas(1);
                        wait for REALISTIC_DETECTOR_HIGH_TIME_NS;

                        -- Model Detector Dead Time
                        input_pads(p*2) <= '0';
                        wait_deltas(1);
                    end loop;

                end if;
            end process;

            proc_model_photon_h : process
                -- Random SLV type generator
                variable rand_slv : RandomPType;
            begin

                -- Triggers this block
                wait until rising_edge(ctrl_sim_start);

                -- Wait for time reference event (faster photon 1)
                if PHOTON_1V_DELAY_ABS_NS <= PHOTON_1H_DELAY_ABS_NS then
                    wait until s_faster_photon_event(0)'event;
                else
                    wait until s_faster_photon_event(1)'event;
                end if;

                -- Test if this photon is faster as logic will differ for both cases
                if PHOTON_V_DELAY_ABS_NS(p) > PHOTON_H_DELAY_ABS_NS(p) then
                    wait_deltas(1);
                    -- Create a unique seed (if the same seed is used in all qubits, detected qubits will be the same)
                    rand_slv.InitSeed(RANDOM_SEED_1+(99+p**2+p**2));
                    wait_deltas(1);

                    wait for PHOTON_H_DELAY_ABS_NS(p) * 1.0 ns;

                    loop
                        -- Create the randomized values (Normal Distribution)
                        s_qubits((p+1)*2-1 downto (p+1)*2-1) <= rand_slv.Randslv((0, 1), 1);
                        wait_deltas(1);
                        s_photon_value_latched((p+1)*2-1) <= s_qubits((p+1)*2-1);
                        wait_deltas(1);
                        s_faster_photon_event((p+1)*2-1) <= not s_faster_photon_event((p+1)*2-1);
                        wait_deltas(1);

                        input_pads((p+1)*2-1) <= s_qubits((p+1)*2-1);
                        wait_deltas(1);
                        wait for REALISTIC_DETECTOR_HIGH_TIME_NS;

                        -- Model Detector Dead Time (until next (1/80MHz) sec)
                        input_pads((p+1)*2-1) <= '0';
                        wait_deltas(1);
                        
                        -- Wait for next laser clk minus the time spent on transmitting a pulse
                        if ctrl_input_emulation_mode = SEND_PHOTON_EVERY_LASER_CLK then
                            wait for LASER_CLK_PERIOD-REALISTIC_DETECTOR_HIGH_TIME_NS;

                        -- Wait for an event on the first qubit
                        elsif ctrl_input_emulation_mode = SEND_CLUSTER_THEN_WAIT then
                            if PHOTON_1V_DELAY_ABS_NS <= PHOTON_1H_DELAY_ABS_NS then
                                wait until s_faster_photon_event(0)'event;
                            else
                                wait until s_faster_photon_event(1)'event;
                            end if;
                            wait for PHOTON_H_DELAY_ABS_NS(p) * 1.0 ns;

                        end if;

                    end loop;
                else
                    -- If photon H is slower (has smaller delay) ensure 01/10 configuration
                    loop
                        wait until s_faster_photon_event(p*2)'event;
                        wait for PHOTON_HV_DIFFERENCE_ABS_NS(p) * 1.0 ns;
                        s_qubits((p+1)*2-1) <= not(s_photon_value_latched(p*2));
                        wait_deltas(1);
                        input_pads((p+1)*2-1) <= s_qubits((p+1)*2-1);
                        wait_deltas(1);
                        wait for REALISTIC_DETECTOR_HIGH_TIME_NS;

                        -- Model Detector Dead Time
                        input_pads((p+1)*2-1) <= '0';
                        wait_deltas(1);
                    end loop;

                end if;
            end process;
        end generate;



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
            write(v_file_line_buffer, string'("q1_time,q2_time,q3_time,q4_time,q5_time,q6_time,q7_time,q8_time,,"));
            writeline(sim_result, v_file_line_buffer);

            
            -- Wait until MMCM is locked, then trigger input emulation
            wait until rising_edge(<< signal.top_gflow_tb.dut_top_gflow.locked : std_logic >>);
            
            ctrl_input_emulation_mode <= SEND_CLUSTER_THEN_WAIT;
            ctrl_sim_start <= '1';

            
            -- Run timulation for ...
            wait for 50 us; -- make timer: Duration: 00:00:37
            -- wait for 500 us; -- make timer: Duration: 00:05:00
            -- wait for 5000 us; -- make timer: Duration: 00:48:59
            -- wait for 50000 us; -- make timer: Duration: 07:45:01

            -- ctrl_input_emulation_mode <= SEND_PHOTON_EVERY_LASER_CLK;

            -- Run timulation for ...
            -- wait for 50 us; -- make timer: Duration: 00:00:37
            -- wait for 500 us; -- make timer: Duration: 00:05:00
            -- wait for 5000 us; -- make timer: Duration: 00:48:59
            -- wait for 50000 us; -- make timer: Duration: 07:45:01

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

                    if INT_QUBITS_CNT > 1 then
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

                    if INT_QUBITS_CNT > 2 then
                        sx_sz_q3 := std_logic_vector(to_unsigned(mod_q2, 2));
                        result_q3 := (((-1)**to_integer(unsigned(sx_sz_q3(0 downto 0))) * 2)
                                    + (to_integer(unsigned(sx_sz_q3(1 downto 1))) + rand_q3)*PI) mod 4;
                        assert mod_q3 = result_q3
                            report "Error: Qubit 3: Actual result is : " & integer'image(mod_q3) 
                                    & " . Expected result is : " & integer'image(result_q3)
                            severity failure;
                    end if;

                    if INT_QUBITS_CNT > 3 then
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

                    if INT_QUBITS_CNT > 4 then
                        sx_sz_q5 := std_logic_vector(to_unsigned(mod_q4, 2));
                        result_q5 := (((-1)**to_integer(unsigned(sx_sz_q5(0 downto 0))) * 0)
                                    + (to_integer(unsigned(sx_sz_q5(1 downto 1))) + rand_q5)*PI) mod 4;
                        assert mod_q5 = result_q5
                            report "Error: Qubit 5: Actual result is : " & integer'image(mod_q5) 
                                    & " . Expected result is : " & integer'image(result_q5)
                            severity failure;
                    end if;

                    if INT_QUBITS_CNT > 5 then
                        sx_sz_q6 := std_logic_vector(to_unsigned(mod_q5, 2));
                        result_q6 := (((-1)**to_integer(unsigned(sx_sz_q6(0 downto 0))) * 1)
                                    + (to_integer(unsigned(sx_sz_q6(1 downto 1))) + rand_q6)*PI) mod 4;
                        assert mod_q6 = result_q6
                            report "Error: Qubit 6: Actual result is : " & integer'image(mod_q6)
                                    & " . Expected result is : " & integer'image(result_q6)
                            severity failure;
                    end if;

                    if INT_QUBITS_CNT > 6 then
                        sx_sz_q7 := std_logic_vector(to_unsigned(mod_q6, 2));
                        result_q7 := (((-1)**to_integer(unsigned(sx_sz_q7(0 downto 0))) * 2)
                                    + (to_integer(unsigned(sx_sz_q7(1 downto 1))) + rand_q7)*PI) mod 4;
                        assert mod_q7 = result_q7
                            report "Error: Qubit 7: Actual result is : " & integer'image(mod_q7)
                                    & " . Expected result is : " & integer'image(result_q7)
                            severity failure;
                    end if;

                    if INT_QUBITS_CNT > 7 then
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