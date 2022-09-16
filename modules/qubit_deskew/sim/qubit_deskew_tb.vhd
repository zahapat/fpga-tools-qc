    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    library lib_src;

    library lib_sim;
    use lib_sim.clk_pack_tb.all;
    use lib_sim.const_pack_tb.all;
    use lib_sim.export_pack_tb.all;
    use lib_sim.print_pack_tb.all;
    use lib_sim.random_pack_tb.all;
    use lib_sim.print_list_pack_tb.all;

    use lib_sim.list_string_pack_tb.all;

    use std.textio.all;
    use std.env.finish;
    use std.env.stop;

    entity qubit_deskew_tb is
    end qubit_deskew_tb;

    architecture sim of qubit_deskew_tb is


        constant CLK_100_HZ : integer := 100e6;
        -- constant CLK_HZ : integer := 250e6;
        constant CLK_HZ : integer := 450e6;
        constant CLK_PERIOD : time := 1 sec / CLK_HZ;
        constant CLK_NEW_QUBIT_78MHz_HZ : integer := 78e6;
        constant CLK_NEW_QUBIT_78MHz_PERIOD : time := 1 sec / CLK_NEW_QUBIT_78MHz_HZ;
        signal s_clk_100MHz : std_logic := '0';
        signal s_clk_new_qubit_78MHz : std_logic := '1';
        signal s_qubit_78MHz : std_logic_vector(1 downto 0) := (others => '0');
        signal s_qubit_31MHz : std_logic_vector(1 downto 0) := (others => '0');
        signal s_clk_detector_31MHz : std_logic := '1';


        -- Generics
        constant RST_VAL                   : std_logic := '1';
        constant CHANNELS_CNT              : positive := 2;
        constant BUFFER_DEPTH              : positive := 3;
        constant ZERO_BITS_CNT             : positive := 2;
        constant HIGH_BITS_CNT             : positive := 1;

        constant CNT_ONEHOT_WIDTH          : positive := 2;  -- to keep a signal high for a long time 1xclk = 10 ns -> 2 x 10ns = 20 ns (does not exceed 32 ns => OK)

        constant DETECTOR_ACTIVE_PERIOD_NS   : positive := 10;
        constant DETECTOR_DEAD_PERIOD_NS     : positive := 22;

        constant REAL_DETECTOR_ACTIVE_PERIOD_NS   : real := 10.0;
        constant REAL_DETECTOR_DEAD_PERIOD_NS     : real := 22.0;
        constant REAL_TOLERANCE_SPCM_PULSE_MIN_NS : real := -0.01;
        constant REAL_TOLERANCE_SPCM_PULSE_MAX_NS : real := 0.01;

        constant TOLERANCE_KEEP_FASTER_BIT_CYCLES : natural := 1;
        constant IGNORE_CYCLES_AFTER_TIMEUP : natural := 3;

        constant PHOTON_1H_DELAY_NS : real := 75.65;          -- no delay = + 0; check every clk
        constant PHOTON_1V_DELAY_NS : real := 75.01;          -- no delay = + 0; check every clk
        constant PHOTON_2H_DELAY_NS : real := -2117.95;       -- negative number = + delay
        constant PHOTON_2V_DELAY_NS : real := -2125.35;
        constant PHOTON_3H_DELAY_NS : real := -1030.35;
        constant PHOTON_3V_DELAY_NS : real := -1034.45;
        constant PHOTON_4H_DELAY_NS : real := -3177.95;
        constant PHOTON_4V_DELAY_NS : real := -3181.05;
        constant PHOTON_H_DELAY_NS : real := PHOTON_2H_DELAY_NS;          -- no delay = + 0; check every clk
        constant PHOTON_V_DELAY_NS : real := PHOTON_2V_DELAY_NS;          -- no delay = + 0; check every clk

        -- IOs
        signal clk : std_logic := '1';
        signal rst : std_logic := RST_VAL;
        signal noisy_channels_in : std_logic_vector(2-1 downto 0) := (others => '0');
        signal qubit_valid_250MHz : std_logic;          -- Valid acts like write enable to sampler
        signal qubit_250MHz : std_logic_vector(2-1 downto 0);

        -- Desired input data to be send to the unit
        signal slv_input_data : std_logic_vector(1 downto 0) := (others => '1');


        -- Delays as absolute numbers
        constant PHOTON_H_DELAY : time := abs(PHOTON_H_DELAY_NS) * 1 ns;     -- zero delay = reference
        constant PHOTON_V_DELAY : time := abs(PHOTON_V_DELAY_NS) * 1 ns;     -- zero delay = reference

        signal sl_photon_H_onway : std_logic := '0';
        signal sl_photon_V_onway : std_logic := '0';

        -- Delta time of the arrival of a single photon
        constant DELTA_ARRIVAL_MIN_NS : real := -0.5;
        constant DELTA_ARRIVAL_MAX_NS : real := 0.5;


        -- Number of repetitions for various tests
        constant REPETITIONS_TEST1 : natural := 3000;
        constant REPETITIONS_TEST2 : natural := 100;

        -- Update seeds for randomization (range 1 to 2147483647)
        constant RAND_NUMBS_SEEDS : natural := 1;


        -- Assert data buffer
        type t_buff_data is array(CHANNELS_CNT-1 downto 0) of std_logic_vector(BUFFER_DEPTH-1 downto 0);
        signal s_buff_data : t_buff_data := (others => (others => '0'));
        signal s_buff_data_p1 : t_buff_data := (others => (others => '0'));
        signal s_buff_data_p2 : t_buff_data := (others => (others => '0'));

    begin


        -- Check for invalid generics
        assert positive((1.0/real(CLK_HZ) / 1.0e-9))*CNT_ONEHOT_WIDTH 
            <= (DETECTOR_ACTIVE_PERIOD_NS + DETECTOR_DEAD_PERIOD_NS) report
            "The duration of the output pulse must not exceed the duration of period of the input signal from detectors"
            severity failure;


        -- CLK generator
        -- clk <= not clk after CLK_PERIOD / 2;
        -- Clocks
        gen_clk_freq_hz_int(clk, CLK_HZ);
        gen_clk_freq_hz_int(s_clk_100MHz, CLK_100_HZ);

        -- DUT instance
        dut_qubit_deskew : entity lib_src.qubit_deskew(rtl)
        generic map (
            RST_VAL                   => RST_VAL,
            BUFFER_DEPTH              => BUFFER_DEPTH,
            ZERO_BITS_CNT             => ZERO_BITS_CNT,
            HIGH_BITS_CNT             => HIGH_BITS_CNT,
            CLK_HZ                    => CLK_HZ,

            CNT_ONEHOT_WIDTH          => CNT_ONEHOT_WIDTH,
            DETECTOR_ACTIVE_PERIOD_NS => DETECTOR_ACTIVE_PERIOD_NS,
            DETECTOR_DEAD_PERIOD_NS   => DETECTOR_DEAD_PERIOD_NS,

            TOLERANCE_KEEP_FASTER_BIT_CYCLES => TOLERANCE_KEEP_FASTER_BIT_CYCLES,
            IGNORE_CYCLES_AFTER_TIMEUP => IGNORE_CYCLES_AFTER_TIMEUP,

            PHOTON_H_DELAY_NS  => PHOTON_H_DELAY_NS,
            PHOTON_V_DELAY_NS  => PHOTON_V_DELAY_NS
        )
        port map (
            clk => clk,
            rst => rst,
            noisy_channels_in => noisy_channels_in,

            qubit_valid_250MHz => qubit_valid_250MHz,
            qubit_250MHz => qubit_250MHz
        );


        -- Input random number generator, Simulator of the SPCM device
        proc_detectors_emul_qubit1H : process
            variable v_rand_slv   : std_logic_vector(1 downto 1) := (others => '0');
            variable seed1, seed2 : integer := 1;
            variable v_rand_real_tolerance_ns : real;
        begin

            -- Random SLVs test
            -- Send random values and keep them there for several CLK cycles
            loop
                wait until falling_edge(sl_photon_H_onway);
                v_rand_real_tolerance_ns := rand_real(REAL_TOLERANCE_SPCM_PULSE_MIN_NS, REAL_TOLERANCE_SPCM_PULSE_MAX_NS, seed1, seed2);
                -- print_string("Random value added to input SPCM pulse after detecting 'sl_photon_4H_onway': ");
                -- print_real(v_rand_real_tolerance_ns);

                -- v_rand_slv := rand_slv(v_rand_slv'length, seed1, seed2);
                v_rand_slv(1) := slv_input_data(1);
                seed1 := rand_int(1, 2147483647, seed1, seed2);
                seed2 := rand_int(1, 2147483647, seed1, seed2);
                seed1 := seed1 + 1; seed2 := seed2 + 1;

                noisy_channels_in(1) <= v_rand_slv(1);
                wait for (REAL_DETECTOR_ACTIVE_PERIOD_NS + v_rand_real_tolerance_ns)*1 ns;

                -- Send zeros to simulate the dead period (do not add tolerance, the error would be the 2x higher than intended)
                noisy_channels_in(1) <= '0';
                wait for REAL_DETECTOR_DEAD_PERIOD_NS*1 ns;
            end loop;

            wait;
        end process;


        -- Input random number generator, Simulator of the SPCM device
        proc_detectors_emul_qubit1V : process
            variable v_rand_slv   : std_logic_vector(0 downto 0) := (others => '0');
            variable seed1, seed2 : integer := 1;
            variable v_rand_real_tolerance_ns : real;
        begin

            -- Random SLVs test
            -- Send random values and keep them there for several CLK cycles
            loop
                wait until falling_edge(sl_photon_V_onway);
                v_rand_real_tolerance_ns := rand_real(REAL_TOLERANCE_SPCM_PULSE_MIN_NS, REAL_TOLERANCE_SPCM_PULSE_MAX_NS, seed1, seed2);
                -- print_string("Random value added to input SPCM pulse after detecting 'sl_photon_4V_onway': ");
                -- print_real(v_rand_real_tolerance_ns);

                -- v_rand_slv := rand_slv(v_rand_slv'length, seed1, seed2);
                v_rand_slv(0) := slv_input_data(0);
                seed1 := rand_int(1, 2147483647, seed1, seed2);
                seed2 := rand_int(1, 2147483647, seed1, seed2);
                seed1 := seed1 + 1; seed2 := seed2 + 1;

                noisy_channels_in(0) <= v_rand_slv(0);
                wait for (REAL_DETECTOR_ACTIVE_PERIOD_NS + v_rand_real_tolerance_ns)*1 ns;

                -- Send zeros to simulate the dead period (do not add tolerance, the error would be the 2x higher than intended)
                noisy_channels_in(0) <= '0';
                wait for REAL_DETECTOR_DEAD_PERIOD_NS*1 ns;
            end loop;

            wait;
        end process;


        -----------------------
        -- Clock Oscillators --
        -----------------------
        -- 1) SYSTEM 230 MHz, 2) NEW_QUBIT 78 MHz, 3) DETECTOR 31 MHz
        gen_clk_freq_hz_int(clk, CLK_HZ);
        gen_clk_period_time(s_clk_new_qubit_78MHz, CLK_NEW_QUBIT_78MHz_PERIOD);


        ---------------------------------------------
        -- GENERATE RANDOM QUBITS WITH FREQ 78 MHz --
        ---------------------------------------------
        -- Send random data to the dut_qubit_deskew and to the TB
        proc_gen_rand_qbts : process
            variable seed1, seed2 : integer := RAND_NUMBS_SEEDS;
            variable v_rand : std_logic_vector(1 downto 0) := (others => '0');
        begin
            loop
                s_qubit_78MHz <= rand_slv(2, seed1, seed2);
                seed1 := rand_int(1, 2147483647, seed1, seed2);
                seed2 := rand_int(1, 2147483647, seed1, seed2);
                seed1 := seed1 + 1; seed2 := seed2 + 1;
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
            loop
                wait for 0 ns;
                s_qubit_31MHz <= s_qubit_78MHz;
                s_clk_detector_31MHz <= '1';
                wait for REAL_DETECTOR_ACTIVE_PERIOD_NS* 1 ns;

                s_qubit_31MHz <= (others => '0');
                s_clk_detector_31MHz <= '0';
                wait for REAL_DETECTOR_DEAD_PERIOD_NS* 1 ns;

                wait until rising_edge(s_clk_new_qubit_78MHz);
            end loop;
        end process;


        ------------------------------------------
        -- SIMULATE DELAY OF HORIZONTAL PHOTONS --
        ------------------------------------------
        proc_horizontal_photon_arrival : process
            variable v_rand_delta_ns : real := 0.0;
            variable v_delay_pulse_trigger : std_logic := '0';

            -- Seeds for Uniform random real number generator
            variable int_seed1, int_seed2 : integer := RAND_NUMBS_SEEDS;
        begin

            -- Visualize/Emulate Horizontal photons detection
            loop

                v_rand_delta_ns := rand_real(DELTA_ARRIVAL_MIN_NS, DELTA_ARRIVAL_MAX_NS, int_seed1, int_seed1);
                report "TX(H): PHOTON_1H WILL ARRIVE AFTER " & to_string(abs(PHOTON_H_DELAY_NS), "%.3f") & " ns + rand. delta " & to_string(v_rand_delta_ns, "%.3f") & " ns.";
                sl_photon_H_onway <= '1';

                wait for PHOTON_H_DELAY + (v_rand_delta_ns * 1 ns);
                sl_photon_H_onway <= '0';

                -- Update seeds for new values (this will give only positive uniform numbers, otherwise error)
                int_seed1 := int_seed1+1; int_seed2 := int_seed2+1;
                wait until (sl_photon_H_onway = '0' and sl_photon_V_onway = '0');
                wait for 20 ns;
                wait until rising_edge(s_clk_100MHz);
                wait for 0 ns;

                -- Update seeds for new values (this will give only positive uniform numbers, otherwise error)
                int_seed1 := int_seed1+1; int_seed2 := int_seed2+1;
                wait until (sl_photon_H_onway = '0' and sl_photon_V_onway = '0');
                wait for 20 ns;
                wait until rising_edge(s_clk_100MHz);
                wait for 0 ns;

            end loop;

        end process;



        ----------------------------------------
        -- SIMULATE DELAY OF VERTICAL PHOTONS --
        ----------------------------------------
        proc_vertical_photon_arrival : process
            variable v_rand_delta_ns : real := 0.0;
            variable v_delay_pulse_trigger : std_logic := '0';
            variable int_seed1, int_seed2 : integer := RAND_NUMBS_SEEDS;
        begin

            -- Visualize/Emulate Vertical photons detection
            loop

                v_rand_delta_ns := rand_real(DELTA_ARRIVAL_MIN_NS, DELTA_ARRIVAL_MAX_NS, int_seed1, int_seed1);
                report "TX(V): PHOTON_V WILL ARRIVE AFTER " & to_string(abs(PHOTON_V_DELAY_NS), "%.3f") & " ns + rand. delta " & to_string(v_rand_delta_ns, "%.3f") & " ns.";
                sl_photon_V_onway <= '1';

                wait for PHOTON_V_DELAY + (v_rand_delta_ns * 1 ns);
                sl_photon_V_onway <= '0';

                -- Update seeds for new values (this will give only positive uniform numbers, otherwise error)
                int_seed1 := int_seed1+1; int_seed2 := int_seed2+1;
                wait until (sl_photon_H_onway = '0' and sl_photon_V_onway = '0');
                wait for 20 ns;
                wait until rising_edge(s_clk_100MHz);
                wait for 0 ns;

            end loop;

        end process;





        -- Sequencer
        proc_sequencer : process
            variable errors_cnt, tests_cnt : integer := 0;
            variable v_check_event_horiz : integer := 0;
            variable v_check_event_verti : integer := 0;
            variable v_act_value_horiz : std_logic := '0';
            variable v_act_value_verti : std_logic := '0';
        begin

            -- Reset
            wait for 10 * CLK_PERIOD;

            -- Release reset
            rst <= not(RST_VAL);

            -- Random SLVs test
            for u in 0 to REPETITIONS_TEST1-1 loop

                wait for 0 ns;
                s_buff_data_p2 <= << signal dut_qubit_deskew.s_buff_data : t_buff_data >>;
                wait for 0 ns;

                wait until rising_edge(clk);
                wait for 0 ns;
                s_buff_data_p1 <= << signal dut_qubit_deskew.s_buff_data : t_buff_data >>;
                wait for 0 ns;

                wait until rising_edge(clk);
                wait for 0 ns;
                s_buff_data <= << signal dut_qubit_deskew.s_buff_data : t_buff_data >>;
                wait for 0 ns;

                -- Check that Redge was successfully detected and that no unexpected traffic is present
                if u > 0 then

                    -- Check correct function of buffers for rising edge detection
                    for i in 0 to CHANNELS_CNT-1 loop
                        tests_cnt := tests_cnt + 1;
                        if s_buff_data_p2(i) = std_logic_vector(to_unsigned(0, BUFFER_DEPTH)) then
                            if s_buff_data_p1(i) = std_logic_vector(to_unsigned(1, BUFFER_DEPTH)) then
                                if s_buff_data(i) /= std_logic_vector(to_unsigned(3, BUFFER_DEPTH)) then
                                    errors_cnt := errors_cnt + 1;
                                    print_string("ERROR: The expected pattern 0(3'b000) => 1(3'b001) => 3(3'b011) is not present. Instead: 0(3'b000) => 1(3'b001) => " & integer'image(to_integer(unsigned(s_buff_data(i)))));
                                    report "Unexpected transition." severity error;
                                    wait for 0 ns;
                                    stop;
                                end if;
                            end if;
                        end if;
                    end loop;

                end if;

            end loop;


            -- SEND "11": Check activity on outputs for correct operation of stable channels: changes should be from "00" => "11" only
            slv_input_data <= "11";
            for u in 0 to REPETITIONS_TEST2-1 loop

                    wait until qubit_250MHz(1 downto 0) = "11";
                    wait for 0 ns;
                    tests_cnt := tests_cnt + 1;
                    if qubit_250MHz(1) /= '1' and qubit_250MHz(0) /= '1' then
                        errors_cnt := errors_cnt + 1;
                        print_string("ERROR: Expected value of qubit 4 should be '11'. Actual: " & std_logic'image(qubit_250MHz(1)) & std_logic'image(qubit_250MHz(0)));
                        report "Unexpected transition." severity error;
                        wait for 20 ns;
                        stop;
                    end if;
                    wait until rising_edge(clk);

            end loop;


            -- SEND "10":
            slv_input_data <= "10";
            for u in 0 to REPETITIONS_TEST2-1 loop

                    wait until qubit_250MHz(1) = '1';
                    wait for 0 ns;
                    tests_cnt := tests_cnt + 1;
                    if qubit_250MHz(1) /= '1' and qubit_250MHz(0) /= '0' then
                        errors_cnt := errors_cnt + 1;
                        print_string("ERROR: Expected value of qubit 4 should be '10'. Actual: " & std_logic'image(qubit_250MHz(1)) & std_logic'image(qubit_250MHz(0)));
                        report "Unexpected transition." severity error;
                        wait for 20 ns;
                        stop;
                    end if;
                    wait until rising_edge(clk);

            end loop;


            -- SEND "01":
            slv_input_data <= "01";
            for u in 0 to REPETITIONS_TEST2-1 loop

                    wait until qubit_250MHz(0) = '1';
                    wait for 0 ns;
                    tests_cnt := tests_cnt + 1;
                    if qubit_250MHz(1) /= '0' and qubit_250MHz(0) /= '1' then
                        errors_cnt := errors_cnt + 1;
                        print_string("ERROR: Expected value of qubit 4 should be '01'. Actual: " & std_logic'image(qubit_250MHz(1)) & std_logic'image(qubit_250MHz(0)));
                        report "Unexpected transition." severity error;
                        wait for 20 ns;
                        stop;
                    end if;
                    wait until rising_edge(clk);

            end loop;

            print_result("qubit_deskew_tb", errors_cnt, tests_cnt);

            finish;
            wait;
        end process;

    end architecture;