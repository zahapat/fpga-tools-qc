    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    use std.textio.all;
    use std.env.finish;

    library lib_sim;
    use lib_sim.essentials_tb.all;

    library lib_src;
    use lib_src.types_pack.all;

    entity fsm_feedforward_tb is
    end fsm_feedforward_tb;

    architecture sim of fsm_feedforward_tb is

        -- Generics
                                  -- Qubit #:         1 2 3 4
                                  -- Polarization:    HVHVHVHV
        constant INT_FEEDFWD_PROGRAMMING : integer := 01000000;
        -- constant INT_FEEDFWD_PROGRAMMING : integer := 01110101;
        constant RST_VAL                 : std_logic := '1';
        constant CTRL_PULSE_DUR_WITH_DEADTIME_NS : natural := 150; -- Duration of the output PCD control pulse in ns (e.g. 100 ns high, 50 ns deadtime = 150 ns)

        constant SAMPL_CLK_HZ            : real := 250.0e6;

        constant QUBITS_CNT              : natural := 4;
        constant TOTAL_STATIC_DELAY_FPGA_BEFORE  : natural := 0;
        constant TOTAL_DELAY_FPGA_AFTER  : natural := 0;
        constant PHOTON_1H_DELAY_NS      : real := 75.65;
        constant PHOTON_1V_DELAY_NS      : real := 75.01;       -- no delay
        constant PHOTON_2H_DELAY_NS      : real := -2117.95;    -- negative number = delay
        constant PHOTON_2V_DELAY_NS      : real := -2125.35;
        constant PHOTON_3H_DELAY_NS      : real := -1030.35;
        constant PHOTON_3V_DELAY_NS      : real := -1034.45;
        constant PHOTON_4H_DELAY_NS      : real := -3177.95;
        constant PHOTON_4V_DELAY_NS      : real := -3181.05;
        constant PHOTON_5H_DELAY_NS      : real := -3177.95;
        constant PHOTON_5V_DELAY_NS      : real := -3181.05;
        constant PHOTON_6H_DELAY_NS      : real := -3177.95;
        constant PHOTON_6V_DELAY_NS      : real := -3181.05;
        

        -- CLK of the FPGA
        constant CLK_HZ                : real := 100.0e6;
        constant CLK_PERIOD            : time := 1 sec / CLK_HZ;

        -- Emulation of the Qubit refresh rate on input
        constant QUBIT_REFRESH_FREQ_HZ   : natural := 80e6;        -- New qubits refreshed with this frequency
        constant CLK_NEW_QUBIT_PERIOD  : time := 1 sec / QUBIT_REFRESH_FREQ_HZ;
        signal CLK_NEW_QUBIT           : std_logic := '1';

        -- Signals
        signal clk : std_logic := '0';
        signal rst : std_logic := '0';
        signal qubits_sampled_valid : std_logic_vector(QUBITS_CNT-1 downto 0) := (others => '0');
        signal qubits_sampled : std_logic_vector((QUBITS_CNT*2)-1 downto 0) := (others => '0');
        signal o_feedforward_pulse : std_logic_vector(0 downto 0) := (others => '0');
        signal o_feedforward_pulse_trigger : std_logic_vector(0 downto 0) := (others => '0');
        signal o_unsuccessful_qubits : std_logic_vector(QUBITS_CNT-1 downto 1) := (others => '0');
        signal feedfwd_success_flag : std_logic := '0';
        signal feedfwd_start : std_logic := '0';
        signal qubit_buffer : t_qubit_buffer_2d := (others => (others => '0'));
        signal time_stamp_buffer : t_time_stamp_buffer_2d := (others => (others => '0'));
        signal actual_qubit_valid : std_logic := '0';
        signal actual_qubit : std_logic_vector(1 downto 0) := (others => '0');
        signal time_stamp_counter_overflow : std_logic := '0';
        signal state_feedfwd : std_logic_vector(QUBITS_CNT-1 downto 0) := (others => '0');
        signal eom_ctrl_pulse_ready : std_logic := '1';

        -- Number od random inputs INST_B
        constant MAX_RANDOM_NUMBS : natural := 300;

        -- Duration of reset strobe
        constant RST_DURATION : time := 10 * CLK_PERIOD;

        -- Repetitions
        constant REPETITIONS : natural := 20000;
        

        -- Print to console "TEST OK."
        procedure print_test_ok is
            variable str : line;
        begin
            write(str, string'("TEST OK."));
            writeline(output, str);
        end procedure;


        -- Function to compare which bit arrives the second (is expected to be slower)
        impure function get_slowest_photon_delay (
            constant REAL_DELAY_HORIZ_NS : real;
            constant REAL_DELAY_VERTI_NS : real
        ) return real is
        begin
            -- Pick the one with the largest delay
            if abs(REAL_DELAY_HORIZ_NS) < abs(REAL_DELAY_VERTI_NS) then
                return abs(REAL_DELAY_VERTI_NS);
            else
                return abs(REAL_DELAY_HORIZ_NS);
            end if;
        end function;

        -- MAX 6 QUBITS
        type t_periods_q_2d is array (6-1 downto 0) of real; 
        constant MAX_PERIODS_Q : t_periods_q_2d := (
            get_slowest_photon_delay(PHOTON_6H_DELAY_NS, PHOTON_6V_DELAY_NS), -- i5
            get_slowest_photon_delay(PHOTON_5H_DELAY_NS, PHOTON_5V_DELAY_NS), -- i4
            get_slowest_photon_delay(PHOTON_4H_DELAY_NS, PHOTON_4V_DELAY_NS), -- i3
            get_slowest_photon_delay(PHOTON_3H_DELAY_NS, PHOTON_3V_DELAY_NS), -- i2
            get_slowest_photon_delay(PHOTON_2H_DELAY_NS, PHOTON_2V_DELAY_NS), -- i1
            get_slowest_photon_delay(PHOTON_1H_DELAY_NS, PHOTON_1V_DELAY_NS)  -- i0 (never used)
        );

    begin

        -- Clk generator
        clk <= not clk after CLK_PERIOD / 2;
        CLK_NEW_QUBIT <= not CLK_NEW_QUBIT after CLK_NEW_QUBIT_PERIOD / 2;

        -- DUT instance
        dut_fsm_feedforward : entity lib_src.fsm_feedforward(rtl)
        generic map (
            INT_FEEDFWD_PROGRAMMING => INT_FEEDFWD_PROGRAMMING,
            RST_VAL                 => RST_VAL,
            CLK_HZ                  => CLK_HZ,
            -- SAMPL_CLK_HZ            => SAMPL_CLK_HZ,
            CTRL_PULSE_DUR_WITH_DEADTIME_NS => CTRL_PULSE_DUR_WITH_DEADTIME_NS,
            QUBITS_CNT              => QUBITS_CNT,
            PHOTON_1H_DELAY_NS      => PHOTON_1H_DELAY_NS,
            PHOTON_1V_DELAY_NS      => PHOTON_1V_DELAY_NS,
            PHOTON_2H_DELAY_NS      => PHOTON_2H_DELAY_NS,
            PHOTON_2V_DELAY_NS      => PHOTON_2V_DELAY_NS,
            PHOTON_3H_DELAY_NS      => PHOTON_3H_DELAY_NS,
            PHOTON_3V_DELAY_NS      => PHOTON_3V_DELAY_NS,
            PHOTON_4H_DELAY_NS      => PHOTON_4H_DELAY_NS,
            PHOTON_4V_DELAY_NS      => PHOTON_4V_DELAY_NS,
            PHOTON_5H_DELAY_NS      => PHOTON_5H_DELAY_NS,
            PHOTON_5V_DELAY_NS      => PHOTON_5V_DELAY_NS,
            PHOTON_6H_DELAY_NS      => PHOTON_6H_DELAY_NS,
            PHOTON_6V_DELAY_NS      => PHOTON_6V_DELAY_NS
        )
        port map (
            clk => clk,
            rst => rst,

            qubits_sampled_valid => qubits_sampled_valid,
            qubits_sampled => qubits_sampled,

            o_feedforward_pulse => o_feedforward_pulse,
            o_feedforward_pulse_trigger => o_feedforward_pulse_trigger,

            o_unsuccessful_qubits => o_unsuccessful_qubits,

            feedfwd_success_flag => feedfwd_success_flag,
            feedfwd_start => feedfwd_start,
            qubit_buffer => qubit_buffer,
            time_stamp_buffer => time_stamp_buffer,

            actual_qubit_valid => actual_qubit_valid,
            actual_qubit => actual_qubit,
            state_feedfwd => state_feedfwd,

            time_stamp_counter_overflow => time_stamp_counter_overflow,
            eom_ctrl_pulse_ready => eom_ctrl_pulse_ready
        );


        -- Proc Cluster State Transmitter


        -- Sequencer
        proc_sequencer : process

            -- Required for uniform randomization procedure
            variable seed_1, seed_2 : integer := MAX_RANDOM_NUMBS;

            -- Random SLV generator
            variable v_random_number : std_logic_vector(qubits_sampled_valid'range);
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

            -- Wait for given number of clock cycles
            procedure wait_cycles (
                constant cycles_cnt : integer
            ) is begin
                for i in 0 to cycles_cnt-1 loop
                    wait until rising_edge(CLK);
                end loop;
            end procedure;

            procedure transmit (
                constant data_1 : std_logic_vector(qubits_sampled'range)
            ) is begin
                -- Send data to the DUT
                qubits_sampled <= data_1;
                -- Print what has been sent, in ModelSim (unsigned data)
                -- report "Transmitted: " & integer'image(to_integer(unsigned(data_1)));
            end procedure;

        begin

            -- Reset strobe (Watch out! To is subtracted in procedure check_req_period_after_reset!)
            wait for RST_DURATION;

            -- Releasing reset
            RST <= not(RST_VAL);


            -- TEST #1
            report "TEST #1: Stay at State 1";
            -- Keep the FSM in state 1
            qubits_sampled <= (others => '0');
            qubits_sampled_valid <= (others => '0');
            wait until rising_edge(clk);
            wait_cycles(300);


            -- TEST #2
            report "TEST #2: States 1 -> 2 -> 3 -> 4 -> 1";
            -- FSM in state 1 -> 2
            qubits_sampled(7 downto 6) <= (others => '1');
            qubits_sampled_valid(3) <= '1';
            wait until rising_edge(clk);
            qubits_sampled <= (others => '0');
            qubits_sampled_valid <= (others => '0');
            wait for 0 ns;

            -- FSM in state 2 -> 3
            wait for (MAX_PERIODS_Q(1))*1 ns;
            if (TOTAL_DELAY_FPGA_AFTER+TOTAL_STATIC_DELAY_FPGA_BEFORE /= 0) then
                for i in 0 to TOTAL_DELAY_FPGA_AFTER+TOTAL_STATIC_DELAY_FPGA_BEFORE loop
                    wait until rising_edge(clk);
                end loop;
            end if;
            qubits_sampled(5 downto 4) <= (others => '1');
            qubits_sampled_valid(2) <= '1';
            wait until rising_edge(clk);
            qubits_sampled <= (others => '0');
            qubits_sampled_valid <= (others => '0');
            wait for 0 ns;

            -- FSM in state 3 -> 4
            wait for (MAX_PERIODS_Q(2))*1 ns;
            for i in 0 to TOTAL_DELAY_FPGA_AFTER+TOTAL_STATIC_DELAY_FPGA_BEFORE loop
                wait until rising_edge(clk);
            end loop;
            qubits_sampled(3 downto 2) <= (others => '1');
            qubits_sampled_valid(1) <= '1';
            wait until rising_edge(clk);
            qubits_sampled <= (others => '0');
            qubits_sampled_valid <= (others => '0');
            wait for 0 ns;

            -- FSM in state 4 -> 1
            wait for (MAX_PERIODS_Q(3))*1 ns;
            if (TOTAL_DELAY_FPGA_AFTER+TOTAL_STATIC_DELAY_FPGA_BEFORE /= 0) then
                for i in 0 to TOTAL_DELAY_FPGA_AFTER+TOTAL_STATIC_DELAY_FPGA_BEFORE loop
                    wait until rising_edge(clk);
                end loop;
            end if;
            qubits_sampled(1 downto 0) <= (others => '1');
            qubits_sampled_valid(0) <= '1';
            wait until rising_edge(clk);
            qubits_sampled <= (others => '0');
            qubits_sampled_valid <= (others => '0');
            wait for 0 ns;


            -- TEST #3
            wait_cycles(90);
            report "TEST #3: States 1 -> 2 -> 3 -> 1";
            -- FSM in state 1 -> 2
            qubits_sampled(7 downto 6) <= (others => '1');
            qubits_sampled_valid(3) <= '1';
            wait until rising_edge(clk);
            qubits_sampled <= (others => '0');
            qubits_sampled_valid <= (others => '0');
            wait for 0 ns;

            -- FSM in state 2 -> 3
            wait for (MAX_PERIODS_Q(1))*1 ns;
            if (TOTAL_DELAY_FPGA_AFTER+TOTAL_STATIC_DELAY_FPGA_BEFORE /= 0) then
                for i in 0 to TOTAL_DELAY_FPGA_AFTER+TOTAL_STATIC_DELAY_FPGA_BEFORE loop
                    wait until rising_edge(clk);
                end loop;
            end if;
            qubits_sampled(5 downto 4) <= (others => '1');
            qubits_sampled_valid(2) <= '1';
            wait until rising_edge(clk);
            qubits_sampled <= (others => '0');
            qubits_sampled_valid <= (others => '0');
            wait for 0 ns;

            -- FSM in state 3 -> 1
            wait for (MAX_PERIODS_Q(2))*1 ns;
            if (TOTAL_DELAY_FPGA_AFTER+TOTAL_STATIC_DELAY_FPGA_BEFORE /= 0) then
                for i in 0 to TOTAL_DELAY_FPGA_AFTER+TOTAL_STATIC_DELAY_FPGA_BEFORE loop
                    wait until rising_edge(clk);
                end loop;
            end if;
            qubits_sampled <= (others => '0');
            qubits_sampled_valid <= (others => '0');
            wait for 0 ns;


            -- TEST #4
            wait_cycles(90);
            report "TEST #4: States 1 -> 2 -> 1";
            -- FSM in state 1 -> 2
            qubits_sampled(7 downto 6) <= (others => '1');
            qubits_sampled_valid(3) <= '1';
            wait until rising_edge(clk);
            qubits_sampled <= (others => '0');
            qubits_sampled_valid <= (others => '0');
            wait for 0 ns;

            -- FSM in state 2 -> 1
            wait for (MAX_PERIODS_Q(1))*1 ns;
            qubits_sampled <= (others => '0');
            qubits_sampled_valid <= (others => '0');
            wait for 0 ns;


            -- Random input test
            wait_cycles(90);
            report "Test with random input bits";
            for i in 0 to REPETITIONS-1 loop
                v_random_number := rand_slv(v_random_number'length);
                qubits_sampled <= (others => '1');
                qubits_sampled_valid <= v_random_number;
                wait until rising_edge(clk);
                qubits_sampled <= (others => '0');
                qubits_sampled_valid <= (others => '0');
                wait until rising_edge(clk);
                wait for 0 ns;
            end loop;

            -- Wait in state 1
            wait_cycles(90);

            print_test_ok;
            finish;
            wait;
        end process;

    end architecture;