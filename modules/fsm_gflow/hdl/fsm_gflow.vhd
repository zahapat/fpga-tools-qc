    -- fsm_gflow.vhd: Feed-forward module: Conducts the protocol for the G-FLOW as FSM (Finite-state-machine)
    --                         The FSM will do two basic things: Advance(=increment cnt) or reach the last Go back
    --                         1) if data valid, increment cnt by 1 and go to DETECT_CLICK_2 else stay at cnt 0
    --                         2) keep incrementing up to CHANNELS-1 only if next data valid
    --                              if CHANNELS-1 reached, reset the counter and go back to DETECT_CLICK_1 state
    --                              if CHANNELS-1 NOT reached due to invalid data, reset the counter and go back to DETECT_CLICK_1 state
    --                         3) as 2
    --                         4) always goes to 1

    -- G-Flow protocol: Finite State Machine (4 states, 0 Unused)
    -- Wait for qubit 1 each clk, then immediately wait for qubit 2
    -- If Qubit 4 succeeded, State Qubit 1 will let the output pulse to be fully transmitted to PCD
    -- and then it will start checking the inputs

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    library lib_src;
    use lib_src.types_pack.all;

    entity fsm_gflow is
        generic (
            RST_VAL                  : std_logic := '1';
            SAMPL_CLK_HZ             : real := 250.0e6;       -- You must keep this for acquisition compensation delay between H/V photons
            CLK_HZ                   : real := 250.0e6;       -- Frequency of the FPGA in HZ
            CTRL_PULSE_DUR_WITH_DEADTIME_NS : natural := 150; -- Duration of the output PCD control pulse in ns (e.g. 100 ns high, 50 ns deadtime = 150 ns)
            QUBITS_CNT               : natural := 4;
            PHOTON_1H_DELAY_NS       : real := 75.65;          -- no delay = + 0; check every clk
            PHOTON_1V_DELAY_NS       : real := 75.01;          -- no delay = + 0; check every clk
            PHOTON_2H_DELAY_NS       : real := -2117.95;       -- negative number = + delay
            PHOTON_2V_DELAY_NS       : real := -2125.35;
            PHOTON_3H_DELAY_NS       : real := -1030.35;
            PHOTON_3V_DELAY_NS       : real := -1034.45;
            PHOTON_4H_DELAY_NS       : real := -3177.95;
            PHOTON_4V_DELAY_NS       : real := -3181.05;
            PHOTON_5H_DELAY_NS       : real := -3177.95;
            PHOTON_5V_DELAY_NS       : real := -3181.05;
            PHOTON_6H_DELAY_NS       : real := -3177.95;
            PHOTON_6V_DELAY_NS       : real := -3181.05;
            DISCARD_QUBITS_TIME_NS   : natural := 0
        );
        port (
            clk : in  std_logic;
            rst : in  std_logic;

            qubits_sampled_valid : in  std_logic_vector(QUBITS_CNT-1 downto 0);
            qubits_sampled : in  std_logic_vector((QUBITS_CNT*2)-1 downto 0);

            feedback_mod_valid : in  std_logic;
            feedback_mod : in  std_logic_vector(1 downto 0);

            gflow_success_flag : out std_logic;
            gflow_success_done : out std_logic;
            qubit_buffer : out t_qubit_buffer_2d;
            time_stamp_buffer : out t_time_stamp_buffer_2d;
            alpha_buffer : out t_alpha_buffer_2d;

            to_math_alpha : out std_logic_vector(1 downto 0);
            to_math_sx_xz : out std_logic_vector(1 downto 0);

            state_gflow : out natural range 0 to QUBITS_CNT-1;
            actual_qubit_valid : out std_logic;
            actual_qubit : out std_logic_vector(1 downto 0);
            actual_qubit_time_stamp : out std_logic_vector(st_transaction_data_max_width);

            time_stamp_counter_overflow : out std_logic;

            pcd_ctrl_pulse_ready : in std_logic
        );
    end fsm_gflow;

    architecture rtl of fsm_gflow is

        -- The main signal that holds the actual qubit state within the cluster
        signal int_state_gflow : natural range 0 to QUBITS_CNT-1 := 0;
        signal int_state_gflow_two_qubits : natural range 0 to QUBITS_CNT-1 := 0;
        signal actual_state_gflow : natural range 0 to QUBITS_CNT-1 := 0;
        signal actual_state_gflow_two_qubits : natural range 0 to QUBITS_CNT-1 := 0;

        constant CLK_PERIOD_NS : real := 
            (1.0/real(CLK_HZ) * 1.0e9);
        constant CLK_PERIODS_CTRL_PULSE : natural :=
                natural( ceil(real(CTRL_PULSE_DUR_WITH_DEADTIME_NS) / CLK_PERIOD_NS) );
        signal pcd_ctrl_pulse_ready_p1 : std_logic := '0';
        signal pcd_ctrl_pulse_fedge_latched : std_logic := '0';

        -- Angles alpha (binary represenatation):
        type t_qx_angle_alpha is array(4-1 downto 0) of std_logic_vector(1 downto 0);
        constant QX_BASIS_ALPHA : t_qx_angle_alpha := ("11", "10", "01", "00");
        --                                              i3    i2    i1    i0

        -- Success flag
        signal s_gflow_success_flag : std_logic := '0';
        signal sl_gflow_success_flag : std_logic := '0';
        signal sl_gflow_success_done : std_logic := '0';

        -- Qubits sampled - initialize values, prevent X in simulation
        signal slv_qubits_sampled : std_logic_vector(qubits_sampled'range) := (others => '0');
        signal slv_actual_qubit : std_logic_vector(actual_qubit'range) := (others => '0');


        -- 1 MHz delay + CCS delay + FPGA Delay: corrected counting for waiting for the next qubit

        -- GFLOW module timing perspective:
        -- Function to compare which bit arrives the second (is expected to be slower)
        impure function get_slowest_photon_delay_us (
            constant REAL_DELAY_HORIZ_NS : real;
            constant REAL_DELAY_VERTI_NS : real
        ) return natural is
            variable v_ph_horiz_us : real := 0.0;
            variable v_ph_verti_us : real := 0.0;
        begin
            -- 1 MHz = 1 us
            v_ph_horiz_us := abs(REAL_DELAY_HORIZ_NS)/1000.0;
            v_ph_verti_us := abs(REAL_DELAY_VERTI_NS)/1000.0;

            -- Pick the one with the largest delay
            if v_ph_horiz_us < v_ph_verti_us then
                return natural(ceil(real(CLK_HZ)/1.0e6 * v_ph_verti_us));
            else
                return natural(ceil(real(CLK_HZ)/1.0e6 * v_ph_horiz_us));
            end if;
        end function;

        -- MAX 6 QUBITS
        type t_periods_q_2d is array (6-1 downto 0) of natural; 
        constant MAX_PERIODS_Q : t_periods_q_2d := (
            get_slowest_photon_delay_us(PHOTON_6H_DELAY_NS, PHOTON_6V_DELAY_NS), -- index 5
            get_slowest_photon_delay_us(PHOTON_5H_DELAY_NS, PHOTON_5V_DELAY_NS), -- index 4
            get_slowest_photon_delay_us(PHOTON_4H_DELAY_NS, PHOTON_4V_DELAY_NS), -- index 3
            get_slowest_photon_delay_us(PHOTON_3H_DELAY_NS, PHOTON_3V_DELAY_NS), -- index 2
            get_slowest_photon_delay_us(PHOTON_2H_DELAY_NS, PHOTON_2V_DELAY_NS), -- index 1
            get_slowest_photon_delay_us(PHOTON_1H_DELAY_NS, PHOTON_1V_DELAY_NS)  -- index 0 (never used)
        );

        -- Sort MAX_PERIODS_Q and get sorted indices (default) or periods
        impure function get_sorted_qubits_indices_or_periods (
            constant INDICES_OR_PERIODS : string -- Input "INDICES" or "PERIODS"
        ) return t_periods_q_2d is 
            variable v_max_periods_q_sorted : t_periods_q_2d := MAX_PERIODS_Q;
            variable v_max_periods_q_indices : t_periods_q_2d;
            variable aux : natural := 0;
        begin
            -- Fill in initial indices
            for u in 0 to QUBITS_CNT-1 loop
                v_max_periods_q_indices(u) := u;
            end loop;

            -- Bubble sort
            for i in 0 to QUBITS_CNT-1 loop
                for j in 0 to QUBITS_CNT-i-2 loop
                    if v_max_periods_q_sorted(j) > v_max_periods_q_sorted(j+1) then
                        -- Swap delays
                        aux := v_max_periods_q_sorted(j);
                        v_max_periods_q_sorted(j) := v_max_periods_q_sorted(j+1);
                        v_max_periods_q_sorted(j+1) := aux;

                        -- Swap indices
                        aux := v_max_periods_q_indices(j);
                        v_max_periods_q_indices(j) := v_max_periods_q_indices(j+1);
                        v_max_periods_q_indices(j+1) := aux;
                    end if;
                end loop;
            end loop;

            -- Choose which sorted list to output
            if INDICES_OR_PERIODS = "INDICES" then
                return v_max_periods_q_indices;
            elsif INDICES_OR_PERIODS = "PERIODS" then
                return v_max_periods_q_sorted;
            else 
                return v_max_periods_q_indices;
            end if;

        end function;

        constant MAX_PERIODS_Q_SORTED : t_periods_q_2d := get_sorted_qubits_indices_or_periods("PERIODS");
        constant MAX_INDICES_Q_SORTED : t_periods_q_2d := get_sorted_qubits_indices_or_periods("INDICES");

        signal int_main_counter : natural := 0;

        signal slv_to_math_sx_sz : std_logic_vector(1 downto 0) := (others => '0');

        -- Time Stamp
        signal uns_actual_time_stamp_counter : unsigned(st_transaction_data_max_width) := (others => '0');

        -- Data buffers for verification in PC
        signal slv_qubit_buffer_2d      : t_qubit_buffer_2d := (others => (others => '0'));
        signal slv_time_stamp_buffer_2d : t_time_stamp_buffer_2d := (others => (others => '0'));
        signal slv_alpha_buffer_2d      : t_alpha_buffer_2d := (others => (others => '0'));

        -- This part is necessary to create scalable binary encoding fot this controller to determine qubit IDs
        type t_qubits_binary_encoding_2d is array (QUBITS_CNT-2 downto 1) of integer;
        impure function gflow_controller_binary_encoding (
            constant QUBITS_CNT : natural
        ) return t_qubits_binary_encoding_2d is
            variable v_qubits_binary_encoding_2d : t_qubits_binary_encoding_2d := (others => 1);
        begin
            for i in 1 to QUBITS_CNT-2 loop
                v_qubits_binary_encoding_2d(i) := i;
            end loop;

            return v_qubits_binary_encoding_2d;
        end function;
        constant QUBIT_ID : t_qubits_binary_encoding_2d := gflow_controller_binary_encoding(QUBITS_CNT);
        signal flag_invalid_qubit_id : std_logic := '0';

        -- Calculate total delay before this module
        impure function get_delay_qubit_deskew (
            constant DELAY_PHOTON_1 : real;
            constant DELAY_PHOTON_2 : real
        ) return natural is
            constant CLK_PERIOD_SAMPLCLK_NS : real := 
                (1.0/real(SAMPL_CLK_HZ) * 1.0e9);
            constant TIME_DIFFERENCE_PHOTONS_NS_ABS : real := 
                abs(DELAY_PHOTON_1 - DELAY_PHOTON_2);
        begin
            return natural( ceil(TIME_DIFFERENCE_PHOTONS_NS_ABS / CLK_PERIOD_SAMPLCLK_NS) );
        end function;
        constant DELAY_BEFORE_FSM_GFLOW : t_periods_q_2d := (
            get_delay_qubit_deskew(PHOTON_6H_DELAY_NS, PHOTON_6V_DELAY_NS), -- index 5
            get_delay_qubit_deskew(PHOTON_5H_DELAY_NS, PHOTON_5V_DELAY_NS), -- index 4
            get_delay_qubit_deskew(PHOTON_4H_DELAY_NS, PHOTON_4V_DELAY_NS), -- index 3
            get_delay_qubit_deskew(PHOTON_3H_DELAY_NS, PHOTON_3V_DELAY_NS), -- index 2
            get_delay_qubit_deskew(PHOTON_2H_DELAY_NS, PHOTON_2V_DELAY_NS), -- index 1
            get_delay_qubit_deskew(PHOTON_1H_DELAY_NS, PHOTON_1V_DELAY_NS)  -- index 0 (never used)
        );


        -- Qubit skipping part: Use Floor this time
        constant CLK_PERIODS_SKIP : natural :=
                natural( ceil(real(DISCARD_QUBITS_TIME_NS) / CLK_PERIOD_NS) );
        signal slv_counter_skip_qubits : std_logic_vector(integer(ceil(log2(real(CLK_PERIODS_SKIP+1)))) downto 0) := (others => '0');
        


    begin


        ---------------------
        -- G-Flow Protocol --
        ---------------------
        actual_qubit <= slv_actual_qubit;
        slv_qubits_sampled <= qubits_sampled;
        gflow_success_flag <= sl_gflow_success_flag;
        gflow_success_done <= sl_gflow_success_done;
        to_math_sx_xz <= slv_to_math_sx_sz;
        actual_qubit_time_stamp <= std_logic_vector(uns_actual_time_stamp_counter(st_transaction_data_max_width));
        qubit_buffer <= slv_qubit_buffer_2d;
        time_stamp_buffer <= slv_time_stamp_buffer_2d;
        alpha_buffer <= slv_alpha_buffer_2d;
        state_gflow <= to_integer(unsigned(std_logic_vector(to_unsigned(actual_state_gflow, QUBITS_CNT)) xor std_logic_vector(to_unsigned(actual_state_gflow_two_qubits, QUBITS_CNT)))); -- One of them is constantly zero

        -- Scalable hardware description of a FSM-like logic: more than 2 qubits
        gen_gflow_more_qubits : if (QUBITS_CNT > 2) generate
            proc_fsm_gflow : process(clk)
            begin
                if rising_edge(clk) then
                    -- Default values
                    actual_qubit_valid <= '0';
                    actual_state_gflow <= int_state_gflow;
                    time_stamp_counter_overflow <= '0';
                    sl_gflow_success_done <= '0';
                    int_main_counter <= int_main_counter + 1;
                    pcd_ctrl_pulse_ready_p1 <= pcd_ctrl_pulse_ready;

                    -- Time Stamp counter always inscrements each clock cycle and overflows
                    -- If 1 cycle = 10 ns: 10*10^(-9) sec * 2^32 cycles = overflow after every 42.949673 sec
                    uns_actual_time_stamp_counter <= uns_actual_time_stamp_counter + 1;

                    -- Sample and latch feedback from MODULO, Override if feedback_mod_valid
                    slv_to_math_sx_sz <= slv_to_math_sx_sz;

                    -- Qubit skipping
                    if to_integer(unsigned(slv_counter_skip_qubits)) /= CLK_PERIODS_SKIP then
                        if sl_gflow_success_flag = '1' then
                            slv_counter_skip_qubits <= std_logic_vector(unsigned(slv_counter_skip_qubits) + "1");
                        end if;
                    end if;

                    -- If success from photon 4, then let this state transmit the pulse, otherwise wait for new clicks
                    if sl_gflow_success_flag = '1' then

                        -- Send 1 clock cycle long pulse as soon as the output PCD control pulse generation starts
                        if pcd_ctrl_pulse_ready = '0' and pcd_ctrl_pulse_ready_p1 = '1' then
                            sl_gflow_success_done <= '1';
                        end if;

                        -- Latch PCD output pulse falling edge event
                        if pcd_ctrl_pulse_ready = '1' and pcd_ctrl_pulse_ready_p1 = '0' then
                            pcd_ctrl_pulse_fedge_latched <= '1';
                        end if;

                        -- Wait until PCD pulse has been transmitted and all qubits from previous clusters states have been skipped
                        if pcd_ctrl_pulse_fedge_latched = '1' and to_integer(unsigned(slv_counter_skip_qubits)) = CLK_PERIODS_SKIP then
                            sl_gflow_success_flag <= '0';
                            pcd_ctrl_pulse_fedge_latched <= '0';
                            slv_counter_skip_qubits <= std_logic_vector(to_unsigned(0, slv_counter_skip_qubits'length));
                        end if;
                    end if;


                    --------------------------
                    -- FIRST qubit detected --
                    --------------------------
                    if int_state_gflow = 0 then
                        int_main_counter <= 0;

                        if sl_gflow_success_flag = '0' then

                            -- After waiting, only then continue the control operation, otherwise qubit 1 will interfere with yet uprocessed data from qubit 4
                            -- slv_actual_qubit <= slv_qubits_sampled(QUBITS_CNT*2-1 - 0*2 downto QUBITS_CNT*2-1 - 0*2-1);
                            -- slv_qubit_buffer_2d(0) <= slv_qubits_sampled(QUBITS_CNT*2-1 - 0*2 downto QUBITS_CNT*2-1 - 0*2-1);
                            slv_actual_qubit <= slv_qubits_sampled(1 downto 0);
                            slv_qubit_buffer_2d(0) <= slv_qubits_sampled(1 downto 0);

                            to_math_alpha <= QX_BASIS_ALPHA((0) mod 4);
                            slv_alpha_buffer_2d(0) <= QX_BASIS_ALPHA((0) mod 4);

                            slv_to_math_sx_sz <= "00";

                            -- Detect Qubit 1 and proceed to Qubit 2
                            -- if qubits_sampled_valid(QUBITS_CNT-1) = '1' then
                            if qubits_sampled_valid(0) = '1' then
                                actual_qubit_valid <= '1';
                                slv_time_stamp_buffer_2d(0) <= std_logic_vector(uns_actual_time_stamp_counter);
                                -- Next state
                                int_state_gflow <= int_state_gflow + 1;
                            end if;

                        end if;
                    end if;

                    -----------------------------------
                    -- INTERMEDIATE qubit/s detected --
                    -----------------------------------
                    if (int_state_gflow /= 0 and int_state_gflow < QUBITS_CNT-1) then
                        -- Create parallel threads, activate one based on the actual state
                        for i in 1 to QUBITS_CNT-2 loop
                            if QUBIT_ID(i) = int_state_gflow then
                                slv_actual_qubit <= slv_qubits_sampled(QUBIT_ID(i)*2+1 downto QUBIT_ID(i)*2);
                                slv_qubit_buffer_2d(QUBIT_ID(i)) <= slv_qubits_sampled(QUBIT_ID(i)*2+1 downto QUBIT_ID(i)*2);

                                to_math_alpha <= QX_BASIS_ALPHA((i) mod 4);
                                slv_alpha_buffer_2d(QUBIT_ID(i)) <= QX_BASIS_ALPHA((QUBIT_ID(i)) mod 4);

                                if feedback_mod_valid = '1' then
                                    slv_to_math_sx_sz <= feedback_mod;
                                end if;

                                -- If the counter has reached the max delay, don't ask and reset it and assess the next state
                                if int_main_counter = MAX_PERIODS_Q(QUBIT_ID(i)) -1 then

                                    -- Detect Qubit 3 and proceed to Qubit 4, sample time stamp
                                    -- if qubits_sampled_valid(QUBITS_CNT-1-QUBIT_ID(i)) = '1' then
                                    if qubits_sampled_valid(QUBIT_ID(i)) = '1' then
                                        actual_qubit_valid <= '1';
                                        slv_time_stamp_buffer_2d(QUBIT_ID(i)) <= std_logic_vector(uns_actual_time_stamp_counter);
                                        int_state_gflow <= int_state_gflow + 1;
                                    else
                                        int_state_gflow <= 0;
                                    end if;
                                end if;

                                -- Look for detection before the last counter iteration (counter the data skew)
                                for u in 0 to 2 loop
                                    if int_main_counter = MAX_PERIODS_Q(QUBIT_ID(i)) -2 -u then

                                        -- Detect Qubit 3 earlier and proceed to Qubit 4
                                        -- if qubits_sampled_valid(QUBITS_CNT-1-QUBIT_ID(i)) = '1' then
                                        if qubits_sampled_valid(QUBIT_ID(i)) = '1' then
                                            -- Leave the state early, reset counter, sample time stamp
                                            actual_qubit_valid <= '1';
                                            slv_time_stamp_buffer_2d(QUBIT_ID(i)) <= std_logic_vector(uns_actual_time_stamp_counter);
                                            int_state_gflow <= int_state_gflow + 1;
                                        end if;

                                    end if;
                                end loop;
                            end if;
                        end loop;
                    end if;


                    -------------------------
                    -- LAST qubit detected --
                    -------------------------
                    if int_state_gflow = QUBITS_CNT-1 then
                        slv_actual_qubit <= slv_qubits_sampled((QUBITS_CNT-1)*2+1 downto (QUBITS_CNT-1)*2);
                        slv_qubit_buffer_2d(QUBITS_CNT-1) <= slv_qubits_sampled((QUBITS_CNT-1)*2+1 downto (QUBITS_CNT-1)*2);

                        to_math_alpha <= QX_BASIS_ALPHA((QUBITS_CNT-1) mod 4);
                        slv_alpha_buffer_2d(QUBITS_CNT-1) <= QX_BASIS_ALPHA((QUBITS_CNT-1) mod 4);

                        if feedback_mod_valid = '1' then
                            slv_to_math_sx_sz <= feedback_mod;
                        end if;

                        if int_main_counter = MAX_PERIODS_Q(QUBITS_CNT-1) -1 then

                            -- Detect Qubit 4 and proceed to Qubit 1, save times tamp
                            -- if qubits_sampled_valid(0) = '1' then
                            if qubits_sampled_valid(QUBITS_CNT-1) = '1' then
                                actual_qubit_valid <= '1';
                                slv_time_stamp_buffer_2d(QUBITS_CNT-1) <= std_logic_vector(uns_actual_time_stamp_counter);
                                int_state_gflow <= 0;
                                sl_gflow_success_flag <= '1';
                            else
                                int_state_gflow <= 0;
                            end if;
                        end if;

                        -- Look for detection before the last counter iteration (counter the data skew)
                        for u in 0 to 2 loop
                            if int_main_counter = MAX_PERIODS_Q(QUBITS_CNT-1) -2 -u then

                                -- Detect Qubit 4 earlier and proceed to Qubit 1
                                -- if qubits_sampled_valid(0) = '1' then
                                if qubits_sampled_valid(QUBITS_CNT-1) = '1' then
                                    -- Leave the state early, reset counter, sample time stamp
                                    actual_qubit_valid <= '1';
                                    slv_time_stamp_buffer_2d(QUBITS_CNT-1) <= std_logic_vector(uns_actual_time_stamp_counter);
                                    int_state_gflow <= 0;
                                    sl_gflow_success_flag <= '1';
                                end if;

                            end if;
                        end loop;
                    end if;

                    ---------------------------
                    -- Define invalid states --
                    ---------------------------
                    if int_state_gflow > QUBITS_CNT-1 then
                        -- Reset the int_state_gflow
                        int_state_gflow <= 0;

                        -- Set the error flag high that the int_state_gflow went beyond the maximum allowed value
                        flag_invalid_qubit_id <= '1';
                    end if;

                end if;
            end process;
        end generate;


        gen_gflow_two_qubits : if (QUBITS_CNT = 2) generate
            proc_fsm_gflow_two_qubits : process(clk)
            begin
                if rising_edge(clk) then
                    -- Default values
                    actual_qubit_valid <= '0';
                    actual_state_gflow <= int_state_gflow_two_qubits;
                    time_stamp_counter_overflow <= '0';
                    sl_gflow_success_done <= '0';
                    int_main_counter <= int_main_counter + 1;
                    pcd_ctrl_pulse_ready_p1 <= pcd_ctrl_pulse_ready;

                    -- Time Stamp counter always inscrements each clock cycle and overflows
                    -- If 1 cycle = 10 ns: 10*10^(-9) sec * 2^32 cycles = overflow after every 42.949673 sec
                    uns_actual_time_stamp_counter <= uns_actual_time_stamp_counter + 1;

                    -- Sample and latch feedback from MODULO, Override if feedback_mod_valid
                    slv_to_math_sx_sz <= slv_to_math_sx_sz;

                    -- Qubit skipping
                    if to_integer(unsigned(slv_counter_skip_qubits)) /= CLK_PERIODS_SKIP then
                        if sl_gflow_success_flag = '1' then
                            slv_counter_skip_qubits <= std_logic_vector(unsigned(slv_counter_skip_qubits) + "1");
                        end if;
                    end if;

                    -- If success from photon 4, then let this state transmit the pulse, otherwise wait for new clicks
                    if sl_gflow_success_flag = '1' then

                        -- Send 1 clock cycle long pulse as soon as the output PCD control pulse generation starts
                        if pcd_ctrl_pulse_ready = '0' and pcd_ctrl_pulse_ready_p1 = '1' then
                            sl_gflow_success_done <= '1';
                        end if;

                        -- Latch PCD output pulse falling edge event
                        if pcd_ctrl_pulse_ready = '1' and pcd_ctrl_pulse_ready_p1 = '0' then
                            pcd_ctrl_pulse_fedge_latched <= '1';
                        end if;

                        -- Wait until PCD pulse has been transmitted and all qubits from previous clusters states have been skipped
                        if pcd_ctrl_pulse_fedge_latched = '1' and to_integer(unsigned(slv_counter_skip_qubits)) = CLK_PERIODS_SKIP then
                            sl_gflow_success_flag <= '0';
                            pcd_ctrl_pulse_fedge_latched <= '0';
                            slv_counter_skip_qubits <= std_logic_vector(to_unsigned(0, slv_counter_skip_qubits'length));
                        end if;
                    end if;


                    --------------------------
                    -- FIRST qubit detected --
                    --------------------------
                    if int_state_gflow_two_qubits = 0 then
                        int_main_counter <= 0;

                        if sl_gflow_success_flag = '0' then

                            -- After waiting, only then continue the control operation, otherwise qubit 1 will interfere with yet uprocessed data from qubit 4
                            -- slv_actual_qubit <= slv_qubits_sampled(QUBITS_CNT*2-1 - 0*2 downto QUBITS_CNT*2-1 - 0*2-1);
                            -- slv_qubit_buffer_2d(0) <= slv_qubits_sampled(QUBITS_CNT*2-1 - 0*2 downto QUBITS_CNT*2-1 - 0*2-1);
                            slv_actual_qubit <= slv_qubits_sampled(1 downto 0);
                            slv_qubit_buffer_2d(0) <= slv_qubits_sampled(1 downto 0);

                            to_math_alpha <= QX_BASIS_ALPHA((0) mod 4);
                            slv_alpha_buffer_2d(0) <= QX_BASIS_ALPHA((0) mod 4);

                            slv_to_math_sx_sz <= "00";

                            -- Detect Qubit 1 and proceed to Qubit 2
                            -- if qubits_sampled_valid(QUBITS_CNT-1) = '1' then
                            if qubits_sampled_valid(0) = '1' then
                                actual_qubit_valid <= '1';
                                slv_time_stamp_buffer_2d(0) <= std_logic_vector(uns_actual_time_stamp_counter);
                                -- Next state
                                int_state_gflow <= int_state_gflow + 1;
                            end if;

                        end if;
                    end if;

                    -------------------------
                    -- LAST qubit detected --
                    -------------------------
                    if int_state_gflow_two_qubits = QUBITS_CNT-1 then
                        slv_actual_qubit <= slv_qubits_sampled((QUBITS_CNT-1)*2+1 downto (QUBITS_CNT-1)*2);
                        slv_qubit_buffer_2d(QUBITS_CNT-1) <= slv_qubits_sampled((QUBITS_CNT-1)*2+1 downto (QUBITS_CNT-1)*2);

                        to_math_alpha <= QX_BASIS_ALPHA((QUBITS_CNT-1) mod 4);
                        slv_alpha_buffer_2d(QUBITS_CNT-1) <= QX_BASIS_ALPHA((QUBITS_CNT-1) mod 4);

                        if feedback_mod_valid = '1' then
                            slv_to_math_sx_sz <= feedback_mod;
                        end if;

                        if int_main_counter = MAX_PERIODS_Q(QUBITS_CNT-1) -1 then

                            -- Detect Qubit 4 and proceed to Qubit 1, sample time stamp
                            -- if qubits_sampled_valid(0) = '1' then
                            if qubits_sampled_valid(QUBITS_CNT-1) = '1' then
                                actual_qubit_valid <= '1';
                                slv_time_stamp_buffer_2d(QUBITS_CNT-1) <= std_logic_vector(uns_actual_time_stamp_counter);
                                int_state_gflow_two_qubits <= 0;
                                sl_gflow_success_flag <= '1';
                            else
                                int_state_gflow_two_qubits <= 0;
                            end if;
                        end if;

                        -- Look for detection before the last counter iteration (counter the data skew)
                        if int_main_counter = MAX_PERIODS_Q(QUBITS_CNT-1) -2 then

                            -- Detect Qubit 4 earlier and proceed to Qubit 1
                            -- if qubits_sampled_valid(0) = '1' then
                            if qubits_sampled_valid(QUBITS_CNT-1) = '1' then
                                -- Leave the state early, reset counter, sample time stamp
                                actual_qubit_valid <= '1';
                                slv_time_stamp_buffer_2d(QUBITS_CNT-1) <= std_logic_vector(uns_actual_time_stamp_counter);
                                int_state_gflow_two_qubits <= 0;
                                sl_gflow_success_flag <= '1';
                            end if;
                        end if;
                    end if;

                    ---------------------------
                    -- Define invalid states --
                    ---------------------------
                    if int_state_gflow_two_qubits > QUBITS_CNT-1 then
                        -- Reset the int_state_gflow_two_qubits
                        int_state_gflow_two_qubits <= 0;

                        -- Set the error flag high that the int_state_gflow_two_qubits went beyond the maximum allowed value
                        flag_invalid_qubit_id <= '1';
                    end if;

                end if;
            end process;
        end generate;

    end architecture;