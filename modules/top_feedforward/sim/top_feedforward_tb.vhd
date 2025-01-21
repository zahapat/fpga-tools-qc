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

    entity top_feedforward_tb is
    end top_feedforward_tb;

    architecture sim of top_feedforward_tb is

        constant PROJ_DIR : string := PROJ_DIR;

        -- File I/O: Write to ONE file at a time
        constant CSV1_PATH : string := PROJ_DIR & "modules/top_feedforward/sim/sim_reports/all_flows_details.csv";
        constant CSV2_PATH : string := PROJ_DIR & "modules/top_feedforward/sim/sim_reports/all_coincidences.csv";
        constant CSV3_PATH : string := PROJ_DIR & "modules/top_feedforward/sim/sim_reports/all_counters.csv";
        file actual_csv : text;
        signal files_recreated : bit := '0';

        -- Simulation control signals
        type t_input_emulation_mode is (
            SEND_PHOTON_EVERY_LASER_CLK,
            SEND_CLUSTER_THEN_WAIT
        );
        constant WAIT_BEFORE_FIRST_PHOTON_NS : time := 500.0 ns;
        constant OUTPUT_BOTH_CHANNELS : boolean := false;
        -- constant TIME_BETWEEN_CLUSTERS_NS : time := 1000.0 ns;
        constant TIME_BETWEEN_CLUSTERS_NS : time := 100.0 ns;
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
        -- constant NOMINAL_DETECTOR_HIGH_TIME_NS : time := 10 ns;
        constant NOMINAL_DETECTOR_HIGH_TIME_NS : time := 6.68 ns; -- MEASURED Value (Detector's output pulse width at above 1V)
        constant NOMINAL_DETECTOR_DEAD_TIME_NS : time := 22 ns;
        constant REALISTIC_DETECTOR_HIGH_TIME_NS : time := 5 ns;

        -- Gflow generics
        constant RST_VAL                      : std_logic := '1';
        constant INT_QUBITS_CNT               : positive := INT_QUBITS_CNT;
        constant INT_EMULATE_INPUTS           : integer := INT_EMULATE_INPUTS;
        constant INT_ALL_DIGITS_PHOTON_1H_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_1H_DELAY_NS;
        constant INT_ALL_DIGITS_PHOTON_1V_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_1V_DELAY_NS;
        constant INT_WHOLE_DIGITS_CNT_PHOTON_1H_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_1H_DELAY;
        constant INT_WHOLE_DIGITS_CNT_PHOTON_1V_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_1V_DELAY;
        constant INT_ALL_DIGITS_PHOTON_2H_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_2H_DELAY_NS;
        constant INT_ALL_DIGITS_PHOTON_2V_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_2V_DELAY_NS;
        constant INT_WHOLE_DIGITS_CNT_PHOTON_2H_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_2H_DELAY;
        constant INT_WHOLE_DIGITS_CNT_PHOTON_2V_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_2V_DELAY;
        constant INT_ALL_DIGITS_PHOTON_3H_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_3H_DELAY_NS;
        constant INT_ALL_DIGITS_PHOTON_3V_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_3V_DELAY_NS;
        constant INT_WHOLE_DIGITS_CNT_PHOTON_3H_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_3H_DELAY;
        constant INT_WHOLE_DIGITS_CNT_PHOTON_3V_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_3V_DELAY;
        constant INT_ALL_DIGITS_PHOTON_4H_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_4H_DELAY_NS;
        constant INT_ALL_DIGITS_PHOTON_4V_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_4V_DELAY_NS;
        constant INT_WHOLE_DIGITS_CNT_PHOTON_4H_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_4H_DELAY;
        constant INT_WHOLE_DIGITS_CNT_PHOTON_4V_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_4V_DELAY;
        constant INT_ALL_DIGITS_PHOTON_5H_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_5H_DELAY_NS;
        constant INT_ALL_DIGITS_PHOTON_5V_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_5V_DELAY_NS;
        constant INT_WHOLE_DIGITS_CNT_PHOTON_5H_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_5H_DELAY;
        constant INT_WHOLE_DIGITS_CNT_PHOTON_5V_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_5V_DELAY;
        constant INT_ALL_DIGITS_PHOTON_6H_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_6H_DELAY_NS;
        constant INT_ALL_DIGITS_PHOTON_6V_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_6V_DELAY_NS;
        constant INT_WHOLE_DIGITS_CNT_PHOTON_6H_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_6H_DELAY;
        constant INT_WHOLE_DIGITS_CNT_PHOTON_6V_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_6V_DELAY;

        -- PCD Control Pulse Design & Delay
        constant INT_CTRL_PULSE_HIGH_DURATION_NS : integer := INT_CTRL_PULSE_HIGH_DURATION_NS;
        constant INT_CTRL_PULSE_DEAD_DURATION_NS : integer := INT_CTRL_PULSE_DEAD_DURATION_NS;
        constant INT_CTRL_PULSE_EXTRA_DELAY_Q2_NS   : integer := INT_CTRL_PULSE_EXTRA_DELAY_Q2_NS;
        constant INT_CTRL_PULSE_EXTRA_DELAY_Q3_NS   : integer := INT_CTRL_PULSE_EXTRA_DELAY_Q3_NS;
        constant INT_CTRL_PULSE_EXTRA_DELAY_Q4_NS   : integer := INT_CTRL_PULSE_EXTRA_DELAY_Q4_NS;
        constant INT_CTRL_PULSE_EXTRA_DELAY_Q5_NS   : integer := INT_CTRL_PULSE_EXTRA_DELAY_Q5_NS;
        constant INT_CTRL_PULSE_EXTRA_DELAY_Q6_NS   : integer := INT_CTRL_PULSE_EXTRA_DELAY_Q6_NS;

        constant WRITE_ON_VALID     : boolean := true;

        -- I/O Channels
        constant INPUT_PADS_CNT     : positive := 2*INT_QUBITS_CNT;

        -- Top I/O signals
        signal sys_clk_p     : std_logic := '1';
        signal sys_clk_n     : std_logic := '0';

        signal led : std_logic_vector(4-1 downto 0);

        signal input_pads : std_logic_vector(INPUT_PADS_CNT-1 downto 0) := (others => '0');
        signal output_pads : std_logic_vector(1 downto 0);
        signal o_eom_ctrl_pulse : std_logic;
        signal o_eom_ctrl_pulsegen_busy : std_logic;
        signal o_debug_port_1 : std_logic;      -- Debug port 1
        signal o_debug_port_2 : std_logic;         -- Debug port 2
        signal o_debug_port_3 : std_logic;         -- Debug port 3

        signal readout_clk        : std_logic := '0';
        signal readout_data_ready : std_logic := '0';
        signal readout_data_valid : std_logic := '0';
        signal readout_enable     : std_logic := '0';
        signal readout_data_32b   : std_logic_vector(31 downto 0);

        signal s_qubits : std_logic_vector(2*INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal s_photon_trans_event : std_logic_vector(2*INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal s_photon_value_latched : std_logic_vector(2*INT_QUBITS_CNT-1 downto 0) := (others => '0');

        -- Signal spy
        signal slv_cdcc_rd_qubits_to_fsm : std_logic_vector(2*INT_QUBITS_CNT-1 downto 0);

        -- Analysis Sygnals
        type t_natural_arr_allphotons_2d is array(2*INT_QUBITS_CNT-1 downto 0) of natural;
        type t_time_arr_allphotons_2d is array(2*INT_QUBITS_CNT-1 downto 0) of time;
        type t_natural_arr_qubits_2d is array(INT_QUBITS_CNT-1 downto 0) of natural;
        type t_natural_arr_qubits_allcombinations_2d is array(2**INT_QUBITS_CNT-1 downto 0) of natural;
        signal s_photons_allcombinations_acc : t_natural_arr_qubits_allcombinations_2d := (others => 0);
        signal s_allphotons_transmitted_cnt : t_natural_arr_allphotons_2d := (others => 0);
        signal s_qubits_transmitted_cnt : t_natural_arr_qubits_2d := (others => 0);
        signal s_photons_sampled_in_flow : t_natural_arr_qubits_2d := (others => 0);
        signal s_io_delay_upper_bound_ns : t_time_arr_allphotons_2d;
        signal s_io_delay_lower_bound_ns : t_time_arr_allphotons_2d;
        signal s_io_delay_avg_ns : t_time_arr_allphotons_2d;
        signal s_i_to_fsm_feedfwd_delay_lower_bound_ns : t_time_arr_allphotons_2d;
        signal s_i_to_fsm_feedfwd_delay_upper_bound_ns : t_time_arr_allphotons_2d;
        signal s_i_to_fsm_feedfwd_delay_avg_ns : t_time_arr_allphotons_2d;
        signal int_successful_flows_counter : integer := 0;
        signal int_failed_flows_counter : integer := 0;

        -- Delta time of the arrival of a single photon
        constant DELTA_ARRIVAL_MIN_NS : real := -0.5;
        constant DELTA_ARRIVAL_MAX_NS : real := 0.5;

        -- Convert Integer generic values to real numbers
        impure function int_to_real (
            constant INT_ALL_DIGITS : integer;        -- Contains whole and decimal digits (e.g. 4541710)
            constant INT_WHOLE_DIGITS_COUNT : integer -- Positive int specifies the number of whole digits in 'INT_ALL_DIGITS' (e.g. 2 to be converted to 45.41710)
                                                      -- Negative int adds leading zeros to 'INT_ALL_DIGITS' (e.g. -2 to be converted to 0.004541710)
                                                      -- Zero will create a decimal number: 0.'INT_ALL_DIGITS' (to be converted to 0.4541710)
        ) return real is
        begin
            if INT_ALL_DIGITS /= 0 then
                return (real(INT_ALL_DIGITS) / (10.0**(floor(log10(abs(real(INT_ALL_DIGITS))))+1.0))) * (0.1**(-1.0*real(INT_WHOLE_DIGITS_COUNT)));
            else
                return 0.0;
            end if;
        end function;

        constant PHOTON_1H_DELAY_ABS_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_1H_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_1H_DELAY));
        constant PHOTON_1V_DELAY_ABS_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_1V_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_1V_DELAY));
        constant PHOTON_2H_DELAY_ABS_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_2H_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_2H_DELAY));
        constant PHOTON_2V_DELAY_ABS_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_2V_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_2V_DELAY));
        constant PHOTON_3H_DELAY_ABS_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_3H_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_3H_DELAY));
        constant PHOTON_3V_DELAY_ABS_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_3V_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_3V_DELAY));
        constant PHOTON_4H_DELAY_ABS_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_4H_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_4H_DELAY));
        constant PHOTON_4V_DELAY_ABS_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_4V_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_4V_DELAY));
        constant PHOTON_5H_DELAY_ABS_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_5H_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_5H_DELAY));
        constant PHOTON_5V_DELAY_ABS_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_5V_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_5V_DELAY));
        constant PHOTON_6H_DELAY_ABS_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_6H_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_6H_DELAY));
        constant PHOTON_6V_DELAY_ABS_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_6V_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_6V_DELAY));

        type t_real_arr_2d is array(6-1 downto 0) of real;
        constant PHOTON_V_DELAY_ABS_NS : t_real_arr_2d := (
            PHOTON_6V_DELAY_ABS_NS, -- index 5
            PHOTON_5V_DELAY_ABS_NS, -- index 4
            PHOTON_4V_DELAY_ABS_NS, -- index 3
            PHOTON_3V_DELAY_ABS_NS, -- index 2
            PHOTON_2V_DELAY_ABS_NS, -- index 1
            PHOTON_1V_DELAY_ABS_NS  -- index 0
        );
        constant PHOTON_H_DELAY_ABS_NS : t_real_arr_2d := (
            PHOTON_6H_DELAY_ABS_NS, -- index 5
            PHOTON_5H_DELAY_ABS_NS, -- index 4
            PHOTON_4H_DELAY_ABS_NS, -- index 3
            PHOTON_3H_DELAY_ABS_NS, -- index 2
            PHOTON_2H_DELAY_ABS_NS, -- index 1
            PHOTON_1H_DELAY_ABS_NS  -- index 0
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

        -- Print to console "TEST DONE."
        procedure print_test_done is
            variable str : line;
        begin
            write(str, string'("TEST DONE."));
            writeline(output, str);
        end procedure;

        procedure print_analysis is
            variable str : line;
            variable v_time_lower_bound : time;
            variable v_time_upper_bound : time;
            variable v_time_average : time;
        begin
            write(str, string'("------------------------------------------------------"));
            writeline(output, str);
            write(str, string'("              Simulation Analysis Output              "));
            writeline(output, str);
            write(str, string'("------------------------------------------------------"));
            writeline(output, str);

            -- Total flows, successful and failed flows counter
            write(str, string'("Initiated Flows: " & integer'image(s_qubits_transmitted_cnt(0))));
            writeline(output, str);

            write(str, string'("Completed Flows: " & integer'image(int_successful_flows_counter)));
            writeline(output, str);

            write(str, string'("Failed Flows: " & integer'image(int_failed_flows_counter)));
            writeline(output, str);

            write(str, string'(""));
            writeline(output, str);

            -- Delays In -> Out PCD Pulse
            for i in 0 to 2*INT_QUBITS_CNT-1 loop
                -- Print Upper Bound IO Delay
                write(str, string'("IO Delay (Upper Bound)(channel " & to_string(i) & "): " & time'image(s_io_delay_upper_bound_ns(i))));
                writeline(output, str);
                if i = 0 then
                    v_time_upper_bound := s_io_delay_upper_bound_ns(i);
                else
                    if v_time_upper_bound < s_io_delay_upper_bound_ns(i) then
                        v_time_upper_bound := s_io_delay_upper_bound_ns(i);
                    end if;
                end if;
            end loop;

            write(str, string'(""));
            writeline(output, str);
            for i in 0 to 2*INT_QUBITS_CNT-1 loop
                -- Print Lower Bound IO Delay
                write(str, string'("IO Delay (Lower Bound)(channel " & to_string(i) & "): " & time'image(s_io_delay_lower_bound_ns(i))));
                writeline(output, str);
                if i = 0 then
                    v_time_lower_bound := s_io_delay_lower_bound_ns(i);
                else
                    if v_time_lower_bound > s_io_delay_lower_bound_ns(i) then
                        v_time_lower_bound := s_io_delay_lower_bound_ns(i);
                    end if;
                end if;
            end loop;

            write(str, string'(""));
            writeline(output, str);
            for i in 0 to 2*INT_QUBITS_CNT-1 loop
                -- Print Lower Bound IO Delay
                write(str, string'("IO Delay (Average)(channel " & to_string(i) & "): " & time'image(s_io_delay_avg_ns(i))));
                writeline(output, str);
                if i = 0 then
                    v_time_average := s_io_delay_avg_ns(i);
                else
                    v_time_average := v_time_average + s_io_delay_avg_ns(i);
                end if;
            end loop;

            write(str, string'("IO Delay (Upper Bound)(all channels): " & time'image(v_time_upper_bound)));
            writeline(output, str);
            write(str, string'("IO Delay (Lower Bound)(all channels): " & time'image(v_time_lower_bound)));
            writeline(output, str);
            write(str, string'("IO Delay (Average)(all channels): " & time'image(v_time_average/(2*INT_QUBITS_CNT))));
            writeline(output, str);
            write(str, string'(""));
            writeline(output, str);


            -- Delays In -> FSM GFLOW
            write(str, string'(""));
            writeline(output, str);
            for i in 0 to 2*INT_QUBITS_CNT-1 loop
                -- Print Upper Bound IO Delay
                write(str, string'("I-to-FSM Delay (Upper Bound)(channel " & to_string(i) & "): " & time'image(s_i_to_fsm_feedfwd_delay_upper_bound_ns(i))));
                writeline(output, str);
                if i = 0 then
                    v_time_upper_bound := s_i_to_fsm_feedfwd_delay_upper_bound_ns(i);
                else
                    if v_time_upper_bound < s_i_to_fsm_feedfwd_delay_upper_bound_ns(i) then
                        v_time_upper_bound := s_i_to_fsm_feedfwd_delay_upper_bound_ns(i);
                    end if;
                end if;
            end loop;

            write(str, string'(""));
            writeline(output, str);
            for i in 0 to 2*INT_QUBITS_CNT-1 loop
                -- Print Lower Bound IO Delay
                write(str, string'("I-to-FSM Delay (Lower Bound)(channel " & to_string(i) & "): " & time'image(s_i_to_fsm_feedfwd_delay_lower_bound_ns(i))));
                writeline(output, str);
                if i = 0 then
                    v_time_lower_bound := s_i_to_fsm_feedfwd_delay_lower_bound_ns(i);
                else
                    if v_time_lower_bound > s_i_to_fsm_feedfwd_delay_lower_bound_ns(i) then
                        v_time_lower_bound := s_i_to_fsm_feedfwd_delay_lower_bound_ns(i);
                    end if;
                end if;
            end loop;

            write(str, string'(""));
            writeline(output, str);
            for i in 0 to 2*INT_QUBITS_CNT-1 loop
                -- Print Lower Bound IO Delay
                write(str, string'("I-to-FSM Delay (Average)(channel " & to_string(i) & "): " & time'image(s_i_to_fsm_feedfwd_delay_avg_ns(i))));
                writeline(output, str);
                if i = 0 then
                    v_time_average := s_i_to_fsm_feedfwd_delay_avg_ns(i);
                else
                    v_time_average := v_time_average + s_i_to_fsm_feedfwd_delay_avg_ns(i);
                end if;
            end loop;

            write(str, string'("I-to-FSM Delay (Upper Bound)(all channels): " & time'image(v_time_upper_bound)));
            writeline(output, str);
            write(str, string'("I-to-FSM Delay (Lower Bound)(all channels): " & time'image(v_time_lower_bound)));
            writeline(output, str);
            write(str, string'("I-to-FSM Delay (Average)(all channels): " & time'image(v_time_average/(2*INT_QUBITS_CNT))));
            writeline(output, str);


            -- Delay Compensation (after CDC)
            write(str, string'(""));
            writeline(output, str);
            for i in 0 to INT_QUBITS_CNT-1 loop
                -- Print Upper Bound IO Delay
                write(str, string'("I-to-FSM Delay Compensation (Upper Bound)(qubit " & to_string(i) 
                    & "): " & time'image(abs(s_i_to_fsm_feedfwd_delay_upper_bound_ns(i*2) - s_i_to_fsm_feedfwd_delay_upper_bound_ns((i+1)*2-1)))));
                writeline(output, str);
            end loop;

            write(str, string'(""));
            writeline(output, str);
            for i in 0 to INT_QUBITS_CNT-1 loop
                -- Print Upper Bound IO Delay
                write(str, string'("I-to-FSM Delay Compensation (Lower Bound)(qubit " & to_string(i) 
                    & "): " & time'image(abs(s_i_to_fsm_feedfwd_delay_lower_bound_ns(i*2) - s_i_to_fsm_feedfwd_delay_lower_bound_ns((i+1)*2-1)))));
                writeline(output, str);
            end loop;

            write(str, string'(""));
            writeline(output, str);
            for i in 0 to INT_QUBITS_CNT-1 loop
                -- Print Upper Bound IO Delay
                write(str, string'("I-to-FSM Delay Compensation (Average)(qubit " & to_string(i) 
                    & "): " & time'image(abs(s_i_to_fsm_feedfwd_delay_avg_ns(i*2) - s_i_to_fsm_feedfwd_delay_avg_ns((i+1)*2-1)))));
                writeline(output, str);
            end loop;

            write(str, string'(""));
            writeline(output, str);
            for i in 0 to 2**INT_QUBITS_CNT-1 loop
                -- Print accumulated photon combinations after successful flows (1 = Horizontal, 0 = Vertical Photon)
                write(str, string'("Combination " & to_string(to_unsigned(i, INT_QUBITS_CNT)) 
                    & ": " & integer'image(s_photons_allcombinations_acc(i))));
                writeline(output, str);
            end loop;
        end procedure;

        -- Readout output signals
        type t_INT_QUBITS_CNT_x_1b_2d is array(INT_QUBITS_CNT-1 downto 0) of std_logic_vector(0 downto 0);   -- random
        type t_INT_QUBITS_CNT_x_2b_2d is array(INT_QUBITS_CNT-1 downto 0) of std_logic_vector(2-1 downto 0); -- photons, alpha, modulo
        type t_INT_QUBITS_CNT_x_8b_2d is array(INT_QUBITS_CNT-1 downto 1) of std_logic_vector(8-1 downto 0); -- unsuccessful counter
        type t_INT_QUBITS_CNTp1_x_28b_2d is array(INT_QUBITS_CNT downto 0) of std_logic_vector(32-4-1 downto 0); -- time stamps
        type t_INT_QUBITS_CNTpw2_x_16_2d is array(INT_QUBITS_CNT**2-1 downto 0) of std_logic_vector(16-1 downto 0); -- coincidence patterns
        type t_INT_QUBITS_CNT2_x_16_2d is array (INT_QUBITS_CNT*2-1 downto 0) of std_logic_vector(16-1 downto 0); -- photon detections counting
        type t_INT_QUBITS_CNT_x_16_2d is array (INT_QUBITS_CNT-1 downto 0) of std_logic_vector(16-1 downto 0); -- lost photons

        -- CSV file 1
        signal readout_photons : t_INT_QUBITS_CNT_x_2b_2d := (others => (others => '0'));
        signal readout_alpha : t_INT_QUBITS_CNT_x_2b_2d := (others => (others => '0'));
        signal readout_random : t_INT_QUBITS_CNT_x_1b_2d := (others => (others => '0'));
        signal readout_modulo : t_INT_QUBITS_CNT_x_2b_2d := (others => (others => '0'));
        signal readout_timestamps : t_INT_QUBITS_CNTp1_x_28b_2d := (others => (others => '0'));
        signal readout_csv1_line_done_event : bit := '0';

        -- CSV file 2
        signal readout_coincidences : t_INT_QUBITS_CNTpw2_x_16_2d := (others => (others => '0'));
        signal readout_csv2_line_done_event : bit := '0';

        -- CSV file 3
        signal readout_photon_counter : t_INT_QUBITS_CNT2_x_16_2d := (others => (others => '0'));
        signal readout_photon_losses : t_INT_QUBITS_CNT_x_16_2d := (others => (others => '0'));
        signal readout_csv3_line_done_event : bit := '0';

        -- Checkers
        type t_INT_QUBITS_CNT_x_int_2d is array(INT_QUBITS_CNT-1 downto 0) of integer;

    begin

        ------------------
        -- DUT instance --
        ------------------
        dut_top_feedforward : entity lib_src.top_feedforward(str)
        generic map (
            RST_VAL            => RST_VAL,
            INT_QUBITS_CNT     => INT_QUBITS_CNT,
            INT_EMULATE_INPUTS => INT_EMULATE_INPUTS,

            INT_ALL_DIGITS_PHOTON_1H_DELAY_NS    => INT_ALL_DIGITS_PHOTON_1H_DELAY_NS,
            INT_ALL_DIGITS_PHOTON_1V_DELAY_NS    => INT_ALL_DIGITS_PHOTON_1V_DELAY_NS,
            INT_WHOLE_DIGITS_CNT_PHOTON_1H_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_1H_DELAY,
            INT_WHOLE_DIGITS_CNT_PHOTON_1V_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_1V_DELAY,
            INT_ALL_DIGITS_PHOTON_2H_DELAY_NS    => INT_ALL_DIGITS_PHOTON_2H_DELAY_NS,
            INT_ALL_DIGITS_PHOTON_2V_DELAY_NS    => INT_ALL_DIGITS_PHOTON_2V_DELAY_NS,
            INT_WHOLE_DIGITS_CNT_PHOTON_2H_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_2H_DELAY,
            INT_WHOLE_DIGITS_CNT_PHOTON_2V_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_2V_DELAY,
            INT_ALL_DIGITS_PHOTON_3H_DELAY_NS    => INT_ALL_DIGITS_PHOTON_3H_DELAY_NS,
            INT_ALL_DIGITS_PHOTON_3V_DELAY_NS    => INT_ALL_DIGITS_PHOTON_3V_DELAY_NS,
            INT_WHOLE_DIGITS_CNT_PHOTON_3H_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_3H_DELAY,
            INT_WHOLE_DIGITS_CNT_PHOTON_3V_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_3V_DELAY,
            INT_ALL_DIGITS_PHOTON_4H_DELAY_NS    => INT_ALL_DIGITS_PHOTON_4H_DELAY_NS,
            INT_ALL_DIGITS_PHOTON_4V_DELAY_NS    => INT_ALL_DIGITS_PHOTON_4V_DELAY_NS,
            INT_WHOLE_DIGITS_CNT_PHOTON_4H_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_4H_DELAY,
            INT_WHOLE_DIGITS_CNT_PHOTON_4V_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_4V_DELAY,
            INT_ALL_DIGITS_PHOTON_5H_DELAY_NS    => INT_ALL_DIGITS_PHOTON_5H_DELAY_NS,
            INT_ALL_DIGITS_PHOTON_5V_DELAY_NS    => INT_ALL_DIGITS_PHOTON_5V_DELAY_NS,
            INT_WHOLE_DIGITS_CNT_PHOTON_5H_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_5H_DELAY,
            INT_WHOLE_DIGITS_CNT_PHOTON_5V_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_5V_DELAY,
            INT_ALL_DIGITS_PHOTON_6H_DELAY_NS    => INT_ALL_DIGITS_PHOTON_6H_DELAY_NS,
            INT_ALL_DIGITS_PHOTON_6V_DELAY_NS    => INT_ALL_DIGITS_PHOTON_6V_DELAY_NS,
            INT_WHOLE_DIGITS_CNT_PHOTON_6H_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_6H_DELAY,
            INT_WHOLE_DIGITS_CNT_PHOTON_6V_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_6V_DELAY,

            -- PCD Control Pulse Design & Delay
            INT_CTRL_PULSE_HIGH_DURATION_NS => INT_CTRL_PULSE_HIGH_DURATION_NS,
            INT_CTRL_PULSE_DEAD_DURATION_NS => INT_CTRL_PULSE_DEAD_DURATION_NS,
            INT_CTRL_PULSE_EXTRA_DELAY_Q2_NS => INT_CTRL_PULSE_EXTRA_DELAY_Q2_NS,
            INT_CTRL_PULSE_EXTRA_DELAY_Q3_NS => INT_CTRL_PULSE_EXTRA_DELAY_Q3_NS,
            INT_CTRL_PULSE_EXTRA_DELAY_Q4_NS => INT_CTRL_PULSE_EXTRA_DELAY_Q4_NS,
            INT_CTRL_PULSE_EXTRA_DELAY_Q5_NS => INT_CTRL_PULSE_EXTRA_DELAY_Q5_NS,
            INT_CTRL_PULSE_EXTRA_DELAY_Q6_NS => INT_CTRL_PULSE_EXTRA_DELAY_Q6_NS,

            WRITE_ON_VALID => WRITE_ON_VALID
        )
        port map (
            sys_clk_p => sys_clk_p,                   -- External 200MHz oscillator
            sys_clk_n => sys_clk_n,

            readout_clk => readout_clk,               -- Readout Endpoint Signals
            readout_data_ready => readout_data_ready,
            readout_data_valid => readout_data_valid,
            readout_enable => readout_enable,
            readout_data_32b => readout_data_32b,

            led => led,                               -- Debug LEDs
            input_pads => input_pads,                 -- Inputs from SPCM
            o_eom_ctrl_pulse => o_eom_ctrl_pulse,     -- PCD Trigger
            o_eom_ctrl_pulsegen_busy => o_eom_ctrl_pulsegen_busy,
            o_debug_port_1 => o_debug_port_1,                 -- Debug port 1
            o_debug_port_2 => o_debug_port_2,                 -- Debug port 2
            o_debug_port_3 => o_debug_port_3                  -- Debug port 3
        );

        -----------------------
        -- Clock Oscillators --
        -----------------------
        -- 1) BOARD OSCILLATOR 200 MHz Differential, 2) LASER 80 MHz, 3) Readout 100 MHz
        sys_clk_p <= not sys_clk_p after CLK_PERIOD / 2;
        sys_clk_n <= not sys_clk_p;
        laser_clk <= not laser_clk after LASER_CLK_PERIOD / 2.0;
        readout_clk <= not readout_clk after 5 ns;

        --------------
        -- Monitors --
        --------------
        slv_cdcc_rd_qubits_to_fsm <= << signal.top_feedforward_tb.dut_top_feedforward.slv_cdcc_rd_qubits_to_fsm : std_logic_vector >>;
        gen_monitors_all_qubits : for q in 0 to INT_QUBITS_CNT-1 generate
            monitor_qubits_transmitted_counter : process
            begin
                loop
                    if PHOTON_V_DELAY_ABS_NS(q) <= PHOTON_H_DELAY_ABS_NS(q) then
                        wait until s_photon_trans_event(q*2)'event;
                    else
                        wait until s_photon_trans_event((q+1)*2-1)'event;
                    end if;
                    s_qubits_transmitted_cnt(q) <= s_qubits_transmitted_cnt(q) + 1;
                end loop;
            end process;

        end generate;

        gen_monitors_all_channels : for c in 0 to 2*INT_QUBITS_CNT-1 generate
            monitors_all_channels_events_counter : process
            begin
                loop
                    wait until s_photon_trans_event(c)'event;
                    if s_qubits(c) = '1' then
                        s_allphotons_transmitted_cnt(c) <= s_allphotons_transmitted_cnt(c) + 1;
                    end if;
                end loop;
            end process;

            -- Measure the delay between producing an input pulse and receiving output pulse
            proc_measure_io_delay : process
                variable v_time_start_real : real := 0.0;
                variable v_time_delta_real : real := 0.0;
                variable v_time_delta_acc_real : real := 0.0;
                variable v_time_avg_real : real := 0.0;
                variable v_cntr_real : real := 0.0;

                variable v_time_start : time := 0.0 ns;
                variable v_time_delta : time := 0.0 ns;
                variable v_time_delta_acc : time := 0.0 ns;
                variable v_time_avg : time := 0.0 ns;
                variable v_time_lower_bound : time := 0.0 ns;
                variable v_time_upper_bound : time := 0.0 ns;
            begin
                loop
                    -- Capture the time in each
                    wait until rising_edge(input_pads(c));
                    if ctrl_input_emulation_mode = SEND_CLUSTER_THEN_WAIT then
                        v_time_start_real := real(now / 1 ps) / 1000.0; -- 'now' base time unit is in ps -> convert to ns
                    end if;

                    -- Wait until valid pulse being transmitted along with the pcd ctrl pulse
                    wait until rising_edge(o_eom_ctrl_pulsegen_busy);

                    if ctrl_input_emulation_mode = SEND_CLUSTER_THEN_WAIT then
                        v_time_delta_real := (real(now / 1 ps) / 1000.0) - v_time_start_real; -- 'now' base time unit is in ps -> convert to ns
                        v_cntr_real := v_cntr_real + 1.0;
                        v_time_delta_acc_real := v_time_delta_acc_real + v_time_delta_real;
                        v_time_avg_real := v_time_delta_acc_real / v_cntr_real;

                        v_time_start := v_time_start_real * 1 ns;
                        v_time_delta := v_time_delta_real * 1 ns;
                        v_time_avg := v_time_avg_real * 1 ns;

                        -- Measure upper bound delay
                        if v_time_delta > v_time_upper_bound then
                            v_time_upper_bound := v_time_delta;
                        end if;

                        -- Measure lower bound delay
                        if v_cntr_real = 1.0 then
                            v_time_lower_bound := v_time_delta;
                        else
                            if v_time_delta < v_time_lower_bound then
                                v_time_lower_bound := v_time_delta;
                            end if;
                        end if;

                        s_io_delay_upper_bound_ns(c) <= v_time_upper_bound;
                        s_io_delay_lower_bound_ns(c) <= v_time_lower_bound;
                        s_io_delay_avg_ns(c) <= v_time_avg;

                    end if;
                end loop;
            end process;

            -- Check if the fsm_feedforward module captured the transmitted photons
            monitors_delay_in_to_fsm_feedforward : process
                variable v_time_start_real : real := 0.0;
                variable v_time_delta_real : real := 0.0;
                variable v_time_delta_acc_real : real := 0.0;
                variable v_time_avg_real : real := 0.0;
                variable v_cntr_real : real := 0.0;

                variable v_time_start : time := 0.0 ns;
                variable v_time_delta : time := 0.0 ns;
                variable v_time_delta_acc : time := 0.0 ns;
                variable v_time_avg : time := 0.0 ns;
                variable v_time_lower_bound : time := 0.0 ns;
                variable v_time_upper_bound : time := 0.0 ns;
            begin
                loop
                    wait until rising_edge(input_pads(c));
                    if ctrl_input_emulation_mode = SEND_CLUSTER_THEN_WAIT then
                        v_time_start_real := real(now / 1 ps) / 1000.0; -- 'now' base time unit is in ps -> convert to ns
                    end if;

                    wait until rising_edge(slv_cdcc_rd_qubits_to_fsm(c));
                    if ctrl_input_emulation_mode = SEND_CLUSTER_THEN_WAIT then
                        v_time_delta_real := (real(now / 1 ps) / 1000.0) - v_time_start_real; -- 'now' base time unit is in ps -> convert to ns
                        v_cntr_real := v_cntr_real + 1.0;
                        v_time_delta_acc_real := v_time_delta_acc_real + v_time_delta_real;
                        v_time_avg_real := v_time_delta_acc_real / v_cntr_real;

                        v_time_start := v_time_start_real * 1 ns;
                        v_time_delta := v_time_delta_real * 1 ns;
                        v_time_avg := v_time_avg_real * 1 ns;

                        -- Measure upper bound delay
                        if v_time_delta > v_time_upper_bound then
                            v_time_upper_bound := v_time_delta;
                        end if;

                        -- Measure lower bound delay
                        if v_cntr_real = 1.0 then
                            v_time_lower_bound := v_time_delta;
                        else
                            if v_time_delta < v_time_lower_bound then
                                v_time_lower_bound := v_time_delta;
                            end if;
                        end if;

                        s_i_to_fsm_feedfwd_delay_upper_bound_ns(c) <= v_time_upper_bound;
                        s_i_to_fsm_feedfwd_delay_lower_bound_ns(c) <= v_time_lower_bound;
                        s_i_to_fsm_feedfwd_delay_avg_ns(c) <= v_time_avg;
                    end if;
                 end loop;
            end process;

        end generate;

        monitor_successful_and_failed_flows_counter : process
            variable v_prev_state : natural range 0 to 2**INT_QUBITS_CNT-1 := 0;
            variable v_curr_state : natural range 0 to 2**INT_QUBITS_CNT-1 := 0;
            variable v_success_flag : std_logic := '0';

            variable v_slv_prev_state : std_logic_vector(INT_QUBITS_CNT-1 downto 0) := std_logic_vector(to_unsigned(1, INT_QUBITS_CNT));
            variable v_slv_curr_state : std_logic_vector(INT_QUBITS_CNT-1 downto 0) := std_logic_vector(to_unsigned(1, INT_QUBITS_CNT));
            variable v_xs : std_logic_vector(INT_QUBITS_CNT-1 downto 0) := (others => 'X');
            variable v_us : std_logic_vector(INT_QUBITS_CNT-1 downto 0) := (others => 'U');
        begin
            loop
                -- OLD
                -- v_prev_state := << signal.top_feedforward_tb.dut_top_feedforward.state_feedfwd : natural range 0 to INT_QUBITS_CNT-1 >>;

                -- wait until rising_edge(o_eom_ctrl_pulsegen_busy);
                -- v_curr_state := << signal.top_feedforward_tb.dut_top_feedforward.state_feedfwd : natural range 0 to INT_QUBITS_CNT-1 >>;
                -- v_success_flag := << signal.top_feedforward_tb.dut_top_feedforward.sl_feedfwd_success_flag : std_logic >>;

                -- if v_prev_state > 0 and v_curr_state = 0 and v_success_flag = '0' then
                --     int_failed_flows_counter <= int_failed_flows_counter + 1;
                -- end if;

                -- if v_prev_state = INT_QUBITS_CNT-1 and v_curr_state = 0 and v_success_flag = '1' then
                --     int_successful_flows_counter <= int_successful_flows_counter + 1;
                -- end if;

                -- NEW
                v_slv_prev_state := << signal.top_feedforward_tb.dut_top_feedforward.state_feedfwd : std_logic_vector(INT_QUBITS_CNT-1 downto 0) >>;
                -- Prevent reading metavalues
                if v_slv_prev_state = v_xs or v_slv_prev_state = v_us then
                    for i in 0 to 100 loop
                        v_slv_prev_state := << signal.top_feedforward_tb.dut_top_feedforward.state_feedfwd : std_logic_vector(INT_QUBITS_CNT-1 downto 0) >>;
                        wait for 0 ns;
                    end loop;
                end if;
                v_prev_state := to_integer(unsigned(v_slv_prev_state));
                if (v_prev_state > 0) then
                    v_prev_state := integer(ceil(log2(real(v_prev_state))));
                end if;


                -- !!!!!!
                -- At this time, the fsm feedforward state should be updated
                -- wait until rising_edge(o_eom_ctrl_pulsegen_busy);
                wait until falling_edge(<< signal.top_feedforward_tb.dut_top_feedforward.inst_fsm_feedforward.actual_qubit_valid : std_logic >>); -- NEW
                -- !!!!!!

                v_slv_curr_state := << signal.top_feedforward_tb.dut_top_feedforward.state_feedfwd : std_logic_vector(INT_QUBITS_CNT-1 downto 0) >>;
                -- Prevent reading metavalues
                if v_slv_curr_state = v_xs or v_slv_curr_state = v_us then
                    for i in 0 to 100 loop
                        wait for 0 ns;
                        v_slv_prev_state := << signal.top_feedforward_tb.dut_top_feedforward.state_feedfwd : std_logic_vector(INT_QUBITS_CNT-1 downto 0) >>;
                    end loop;
                end if;
                v_curr_state := to_integer(unsigned(v_slv_curr_state));
                if (v_curr_state > 0) then
                    v_curr_state := integer(ceil(log2(real(v_curr_state))));
                end if;

                v_success_flag := << signal.top_feedforward_tb.dut_top_feedforward.sl_feedfwd_success_flag : std_logic >>;

                if v_prev_state > 0 and v_curr_state = 0 and v_success_flag = '0' then
                    int_failed_flows_counter <= int_failed_flows_counter + 1;
                end if;

                if v_prev_state = INT_QUBITS_CNT-1 and v_curr_state = 0 and v_success_flag = '1' then
                    int_successful_flows_counter <= int_successful_flows_counter + 1;
                end if;
            end loop;
        end process;


        -- Accumulate the sampled qubits using readout
        monitor_photons_flow_accumulation : process
            variable v_binary_to_integer : unsigned(INT_QUBITS_CNT-1 downto 0) := (others => '0');
        begin
            -- Wait until the readout line is complete for a completed flow
            wait until readout_csv1_line_done_event'event;

            wait_deltas(10);

            for i in 0 to INT_QUBITS_CNT-1 loop
                v_binary_to_integer(i) := readout_photons(i)(1); -- H photon bit; if H=0, the V=1
            end loop;

            s_photons_allcombinations_acc(to_integer(v_binary_to_integer(INT_QUBITS_CNT-1 downto 0))) 
                <= s_photons_allcombinations_acc(to_integer(v_binary_to_integer(INT_QUBITS_CNT-1 downto 0))) + 1;

        end process;

        ------------------------------------
        -- Transactors (Input Generators) --
        ------------------------------------
        proc_model_photon_1v : process
            variable rand_slv : RandomPType; -- Random SLV type generator
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
                    s_photon_trans_event(0) <= not s_photon_trans_event(0);
                    wait_deltas(1);
                    if OUTPUT_BOTH_CHANNELS = true then
                        input_pads(0) <= '1';
                    else
                        input_pads(0) <= s_qubits(0);
                    end if;
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
                    wait until s_photon_trans_event(1)'event;
                    wait for PHOTON_1HV_DIFFERENCE_ABS_NS * 1.0 ns;
                    s_photon_trans_event(0) <= not s_photon_trans_event(0);
                    wait_deltas(1);
                    s_qubits(0) <= not(s_photon_value_latched(1));
                    wait_deltas(1);
                    if OUTPUT_BOTH_CHANNELS = true then
                        input_pads(0) <= '1';
                    else
                        input_pads(0) <= s_qubits(0);
                    end if;
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

            -- Test if this photon arrives earlier since logic will differ for both cases
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
                    s_photon_trans_event(1) <= not s_photon_trans_event(1);
                    wait_deltas(1);
                    if OUTPUT_BOTH_CHANNELS = true then
                        input_pads(1) <= '1';
                    else
                        input_pads(1) <= s_qubits(1);
                    end if;
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
                -- If photon H arrives later ensure "01" or "10" data transmission (invert the faster detection)
                loop
                    wait until s_photon_trans_event(0)'event;
                    wait for PHOTON_1HV_DIFFERENCE_ABS_NS * 1.0 ns;
                    s_photon_trans_event(1) <= not s_photon_trans_event(1);
                    wait_deltas(1);
                    s_qubits(1) <= not(s_photon_value_latched(0));
                    wait_deltas(1);
                    if OUTPUT_BOTH_CHANNELS = true then
                        input_pads(1) <= '1';
                    else
                        input_pads(1) <= s_qubits(1);
                    end if;
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
                    wait until s_photon_trans_event(0)'event;
                else
                    wait until s_photon_trans_event(1)'event;
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
                        s_photon_trans_event(p*2) <= not s_photon_trans_event(p*2);
                        wait_deltas(1);
                        if OUTPUT_BOTH_CHANNELS = true then
                            input_pads(p*2) <= '1';
                        else
                            input_pads(p*2) <= s_qubits(p*2);
                        end if;
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
                                wait until s_photon_trans_event(0)'event;
                            else
                                wait until s_photon_trans_event(1)'event;
                            end if;
                            wait for PHOTON_V_DELAY_ABS_NS(p) * 1.0 ns;

                        end if;
                    end loop;
                else
                    -- If photon V arrives later ensure "01" or "10" data transmission (invert the faster detection)
                    loop
                        wait until s_photon_trans_event((p+1)*2-1)'event;
                        wait for PHOTON_HV_DIFFERENCE_ABS_NS(p) * 1.0 ns;
                        s_photon_trans_event(p*2) <= not s_photon_trans_event(p*2);
                        wait_deltas(1);
                        s_qubits(p*2) <= not(s_photon_value_latched((p+1)*2-1));
                        wait_deltas(1);
                        if OUTPUT_BOTH_CHANNELS = true then
                            input_pads(p*2) <= '1';
                        else
                            input_pads(p*2) <= s_qubits(p*2);
                        end if;
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
                    wait until s_photon_trans_event(0)'event;
                else
                    wait until s_photon_trans_event(1)'event;
                end if;

                -- Test if this photon arrives earlier since logic will differ for both cases
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
                        s_photon_trans_event((p+1)*2-1) <= not s_photon_trans_event((p+1)*2-1);
                        wait_deltas(1);
                        if OUTPUT_BOTH_CHANNELS = true then
                            input_pads((p+1)*2-1) <= '1';
                        else
                            input_pads((p+1)*2-1) <= s_qubits((p+1)*2-1);
                        end if;
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
                                wait until s_photon_trans_event(0)'event;
                            else
                                wait until s_photon_trans_event(1)'event;
                            end if;
                            wait for PHOTON_H_DELAY_ABS_NS(p) * 1.0 ns;

                        end if;

                    end loop;
                else
                    -- If photon H arrives later ensure "01" or "10" data transmission (invert the faster detection)
                    loop
                        wait until s_photon_trans_event(p*2)'event;
                        wait for PHOTON_HV_DIFFERENCE_ABS_NS(p) * 1.0 ns;
                        s_photon_trans_event((p+1)*2-1) <= not s_photon_trans_event((p+1)*2-1);
                        wait_deltas(1);
                        s_qubits((p+1)*2-1) <= not(s_photon_value_latched(p*2));
                        wait_deltas(1);
                        if OUTPUT_BOTH_CHANNELS = true then
                            input_pads((p+1)*2-1) <= '1';
                        else
                            input_pads((p+1)*2-1) <= s_qubits((p+1)*2-1);
                        end if;
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
            variable v_line_buffer : line;    -- Line buffer
        begin

            -- Print the converted real numbers of inputted generic variables of photon's delays
            write(v_line_buffer, string'("PHOTON_1H_DELAY_ABS_NS=" & real'image(PHOTON_1H_DELAY_ABS_NS))); writeline(output, v_line_buffer);
            write(v_line_buffer, string'("PHOTON_1V_DELAY_ABS_NS=" & real'image(PHOTON_1V_DELAY_ABS_NS))); writeline(output, v_line_buffer);
            write(v_line_buffer, string'("PHOTON_2H_DELAY_ABS_NS=" & real'image(PHOTON_2H_DELAY_ABS_NS))); writeline(output, v_line_buffer);
            write(v_line_buffer, string'("PHOTON_2V_DELAY_ABS_NS=" & real'image(PHOTON_2V_DELAY_ABS_NS))); writeline(output, v_line_buffer);
            write(v_line_buffer, string'("PHOTON_3H_DELAY_ABS_NS=" & real'image(PHOTON_3H_DELAY_ABS_NS))); writeline(output, v_line_buffer);
            write(v_line_buffer, string'("PHOTON_3V_DELAY_ABS_NS=" & real'image(PHOTON_3V_DELAY_ABS_NS))); writeline(output, v_line_buffer);
            write(v_line_buffer, string'("PHOTON_4H_DELAY_ABS_NS=" & real'image(PHOTON_4H_DELAY_ABS_NS))); writeline(output, v_line_buffer);
            write(v_line_buffer, string'("PHOTON_4V_DELAY_ABS_NS=" & real'image(PHOTON_4V_DELAY_ABS_NS))); writeline(output, v_line_buffer);
            write(v_line_buffer, string'("PHOTON_5H_DELAY_ABS_NS=" & real'image(PHOTON_5H_DELAY_ABS_NS))); writeline(output, v_line_buffer);
            write(v_line_buffer, string'("PHOTON_5V_DELAY_ABS_NS=" & real'image(PHOTON_5V_DELAY_ABS_NS))); writeline(output, v_line_buffer);
            write(v_line_buffer, string'("PHOTON_6H_DELAY_ABS_NS=" & real'image(PHOTON_6H_DELAY_ABS_NS))); writeline(output, v_line_buffer);
            write(v_line_buffer, string'("PHOTON_6V_DELAY_ABS_NS=" & real'image(PHOTON_6V_DELAY_ABS_NS))); writeline(output, v_line_buffer);

            -- Wait until MMCM0 is locked, then trigger input emulation
            wait until rising_edge(<< signal.top_feedforward_tb.dut_top_feedforward.mmcm_locked : std_logic >>);
            wait for 500 ns;

            
            wait for WAIT_BEFORE_FIRST_PHOTON_NS; -- NEW
            ctrl_input_emulation_mode <= SEND_CLUSTER_THEN_WAIT;
            ctrl_sim_start <= '1';


            -- Run timulation for ...
            wait for 50 us; -- make timer: Duration: 00:00:37
            -- wait for 500 us; -- make timer: Duration: 00:05:00
            -- wait for 5000 us; -- make timer: Elapsed time: 1:04:16
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

            print_test_done;
            print_analysis;
            finish;
            wait;
        end process;


                -------------
        -- READOUT --
        -------------
        -- Readout
        proc_fifo_readout : process
        begin
            wait until rising_edge(readout_clk);
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
        proc_readout_and_csv_printer : process
            variable v_line_buffer : line;    -- Line buffer
            variable v_line_being_created : bit := '0';

            variable v_cntr_csv1_column : natural := 0;
            variable v_cntr_csv2_column : natural := 0;
            variable v_cntr_csv3_column : natural := 0;
        begin

            -- Recreate output csv files
            -- CSV1: Open and Initialize Headers in output report files (all flows details)
            file_open(actual_csv, CSV1_PATH, write_mode);
            for i in 1 to INT_QUBITS_CNT loop
                write(v_line_buffer, string'("photon_q" & integer'image(i) & ","));
            end loop;
            write(v_line_buffer, string'(","));

            for i in 1 to INT_QUBITS_CNT loop
                write(v_line_buffer, string'("alpha_q" & integer'image(i) & ","));
            end loop;
            write(v_line_buffer, string'(","));

            for i in 1 to INT_QUBITS_CNT loop
                write(v_line_buffer, string'("mod_q" & integer'image(i) & ","));
            end loop;
            write(v_line_buffer, string'(","));

            for i in 1 to INT_QUBITS_CNT loop
                write(v_line_buffer, string'("random_q" & integer'image(i) & ","));
            end loop;
            write(v_line_buffer, string'(","));

            write(v_line_buffer, string'("timestamp_q1_ovflw" & ","));
            for i in 1 to INT_QUBITS_CNT loop
                write(v_line_buffer, string'("timestamp_q" & integer'image(i) & ","));
            end loop;

            write(v_line_buffer, string'(","));
            write(v_line_buffer, string'("@time"));
            write(v_line_buffer, string'(","));
            write(v_line_buffer, string'("time_ovflw"));
            writeline(actual_csv, v_line_buffer);
            file_close(actual_csv);


            -- CSV2: Open and Initialize Headers in output report files (accumulated coincidences)
            file_open(actual_csv, CSV2_PATH, write_mode);
            for i in 0 to INT_QUBITS_CNT**2-1 loop
                write(v_line_buffer, string'(to_string(to_unsigned(i, INT_QUBITS_CNT)) & ","));
            end loop;

            write(v_line_buffer, string'(","));
            write(v_line_buffer, string'("@time"));

            write(v_line_buffer, string'(","));
            write(v_line_buffer, string'("time_ovflw"));
            writeline(actual_csv, v_line_buffer);
            file_close(actual_csv);


            -- CSV3: Open and Initialize Headers in output report files (all counters)
            file_open(actual_csv, CSV3_PATH, write_mode);
            for i in 1 to INT_QUBITS_CNT*2 loop
                write(v_line_buffer, string'("chann_q" & integer'image(i) & ","));
            end loop;
            write(v_line_buffer, string'(","));

            for i in 2 to INT_QUBITS_CNT loop
                write(v_line_buffer, string'("loss_q" & integer'image(i) & ","));
            end loop;

            write(v_line_buffer, string'(","));
            write(v_line_buffer, string'("@time"));
            write(v_line_buffer, string'(","));
            write(v_line_buffer, string'("time_ovflw"));
            writeline(actual_csv, v_line_buffer);
            file_close(actual_csv);

            report "CSV files have been re-created successfully.";
            files_recreated <= '1';


            -- Acquire data and print to console
            loop
                wait until rising_edge(readout_clk);
                if readout_data_valid = '1' then

                    -- Translate the following code to the target language performing the RX readout
                    -- 1) Open target output CSV file where new data will be appended
                    if v_line_being_created = '0' then
                        if readout_data_32b(4-1 downto 0) = x"1" then
                            file_open(actual_csv, CSV1_PATH, append_mode);
                            v_line_being_created := '1'; -- Job Started
                        elsif readout_data_32b(4-1 downto 0) = x"6" then
                            file_open(actual_csv, CSV2_PATH, append_mode);
                            v_line_being_created := '1'; -- Job Started
                        elsif readout_data_32b(4-1 downto 0) = x"7" then
                            file_open(actual_csv, CSV3_PATH, append_mode);
                            v_line_being_created := '1'; -- Job Started
                        end if;
                    end if;

                    -- 2) CSV file line creation
                    if readout_data_32b(4-1 downto 0) = x"F" then -- Print out the line buffer
                        write(v_line_buffer, string'(","));
                        write(v_line_buffer, string'(
                            to_string(to_integer(unsigned(readout_data_32b(32-1 downto 4))) ) ));
                        -- writeline(output, v_line_buffer);     -- To the console (but this deletes the v_line_buffer content)
                        writeline(actual_csv, v_line_buffer); -- To the CSV file
                        file_close(actual_csv);
                        v_line_being_created := '0';          -- Job Done (for all readout groups)

                        if v_cntr_csv1_column /= 0 then
                            readout_csv1_line_done_event <= not readout_csv1_line_done_event;
                        elsif v_cntr_csv2_column /= 0 then
                            readout_csv2_line_done_event <= not readout_csv2_line_done_event;
                        elsif v_cntr_csv3_column /= 0 then
                            readout_csv3_line_done_event <= not readout_csv3_line_done_event;
                        end if;
                        v_cntr_csv1_column := 0;
                        v_cntr_csv2_column := 0;
                        v_cntr_csv3_column := 0;


                    elsif readout_data_32b(4-1 downto 0) = x"E" then -- Extra Comma Delimiter
                        write(v_line_buffer, string'(",") );
                        v_cntr_csv1_column := 0;
                        v_cntr_csv2_column := 0;
                        v_cntr_csv3_column := 0;

                    elsif readout_data_32b(4-1 downto 0) = x"1" then -- Event-based data group 1
                        write(v_line_buffer, string'(
                            to_string(to_integer(unsigned(readout_data_32b(32-1 downto 4))) ) ));
                        write(v_line_buffer, string'(",") );

                        -- Get Data (4 is offset, bits occupied by the csv commands)
                        readout_photons(v_cntr_csv1_column) <= readout_data_32b(2-1+4 downto 4); -- Record Data (4 is offset, bits occupied by the csv commands)
                        v_cntr_csv1_column := v_cntr_csv1_column + 1;

                    elsif readout_data_32b(4-1 downto 0) = x"2" then -- Event-based data group 2
                        write(v_line_buffer, string'(
                            to_string(to_integer(unsigned(readout_data_32b(32-1 downto 4))) ) ));
                        write(v_line_buffer, string'(",") );

                        -- Get Data (4 is offset, bits occupied by the csv commands)
                        readout_alpha(v_cntr_csv1_column) <= readout_data_32b(2-1+4 downto 4); -- Record Data (4 is offset, bits occupied by the csv commands)
                        v_cntr_csv1_column := v_cntr_csv1_column + 1;

                    elsif readout_data_32b(4-1 downto 0) = x"3" then -- Event-based data group 3
                        write(v_line_buffer, string'(
                            to_string(to_integer(unsigned(readout_data_32b(32-1 downto 4))) ) ));
                        write(v_line_buffer, string'(",") );

                        -- Get Data (4 is offset, bits occupied by the csv commands)
                        readout_modulo(v_cntr_csv1_column) <= readout_data_32b(2-1+4 downto 4); -- Record Data (4 is offset, bits occupied by the csv commands)
                        v_cntr_csv1_column := v_cntr_csv1_column + 1;

                    elsif readout_data_32b(4-1 downto 0) = x"4" then -- Event-based data group 4
                        write(v_line_buffer, string'(
                            to_string(to_integer(unsigned(readout_data_32b(32-1 downto 4))) ) ));
                        write(v_line_buffer, string'(",") );

                        -- Get Data (4 is offset, bits occupied by the csv commands)
                        readout_random(v_cntr_csv1_column) <= readout_data_32b(1-1+4 downto 4);
                        v_cntr_csv1_column := v_cntr_csv1_column + 1;

                    elsif readout_data_32b(4-1 downto 0) = x"5" then -- Event-based data group 5
                        write(v_line_buffer, string'(
                            to_string(to_integer(unsigned(readout_data_32b(32-1 downto 4))) ) ));
                        write(v_line_buffer, string'(",") );

                        -- Get Data (4 is offset, bits occupied by the csv commands)
                        readout_timestamps(v_cntr_csv1_column) <= readout_data_32b(28-1+4 downto 4); -- Record Data (4 is offset, bits occupied by the csv commands)
                        v_cntr_csv1_column := v_cntr_csv1_column + 1;

                    elsif readout_data_32b(4-1 downto 0) = x"6" then -- Regular reporting group 1
                        write(v_line_buffer, string'(
                            to_string(to_integer(unsigned(readout_data_32b(32-1 downto 4))) ) ));
                        write(v_line_buffer, string'(",") );

                        -- Get Data (4 is offset, bits occupied by the csv commands)
                        readout_coincidences(v_cntr_csv2_column) <= readout_data_32b(16-1+4 downto 4); -- Record Data (4 is offset, bits occupied by the csv commands)
                        v_cntr_csv2_column := v_cntr_csv2_column + 1;

                    elsif readout_data_32b(4-1 downto 0) = x"7" then -- Regular multi-transactional reporting 1
                        write(v_line_buffer, string'(
                            to_string(to_integer(unsigned(readout_data_32b(32-1 downto 4))) ) ));
                        write(v_line_buffer, string'(",") );

                        readout_photon_counter(v_cntr_csv3_column) <= readout_data_32b(16-1+4 downto 4);
                        v_cntr_csv3_column := v_cntr_csv3_column + 1;

                    elsif readout_data_32b(4-1 downto 0) = x"8" then -- Regular multi-transactional reporting 2
                        write(v_line_buffer, string'(
                            to_string(to_integer(unsigned(readout_data_32b(32-1 downto 4))) ) ));
                        write(v_line_buffer, string'(",") );

                        readout_photon_losses(v_cntr_csv3_column) <= readout_data_32b(16-1+4 downto 4);
                        v_cntr_csv3_column := v_cntr_csv3_column + 1;

                    elsif readout_data_32b(4-1 downto 0) = x"9" then -- FPGA Time
                        write(v_line_buffer, string'(",") );
                        write(v_line_buffer, string'(
                            to_string(to_integer(unsigned(readout_data_32b(32-1 downto 4))) ) ));
                    elsif readout_data_32b(4-1 downto 0) = x"A" then -- Regular reporting
                        null;
                    elsif readout_data_32b(4-1 downto 0) = x"B" then -- Regular reporting
                        null;
                    elsif readout_data_32b(4-1 downto 0) = x"C" then -- Regular reporting
                        null;
                    elsif readout_data_32b(4-1 downto 0) = x"D" then -- Regular reporting
                        null;

                    else
                        -- "0000" Is forbidden!!!
                        report "Last four bits being '0000' is forbidden! It can mean data loss or unwanted behaviour.";
                        assert false severity failure;
                    end if;

                end if;
            end loop;
        end process;


        --------------
        -- CHECKERS --
        --------------
        -- #TODO

    end architecture;