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
            CLK_HZ                   : natural := 100e6;       -- Frequency of the FPGA in HZ
            PCD_DELAY_US             : natural := 1;           -- Duration of the pulse from PCD in usec
            QUBITS_CNT               : natural := 4;
            TOTAL_DELAY_FPGA_BEFORE  : natural := 5;           -- Delay before this module
            TOTAL_DELAY_FPGA_AFTER   : natural := 5;           -- Delay after this module
            -- TOTAL_DELAY_PCD_REDGE_US : natural := 20;
            PHOTON_1H_DELAY_NS       : real := 75.65;          -- no delay = + 0; check every clk
            PHOTON_1V_DELAY_NS       : real := 75.01;          -- no delay = + 0; check every clk
            PHOTON_2H_DELAY_NS       : real := -2117.95;       -- negative number = + delay
            PHOTON_2V_DELAY_NS       : real := -2125.35;
            PHOTON_3H_DELAY_NS       : real := -1030.35;
            PHOTON_3V_DELAY_NS       : real := -1034.45;
            PHOTON_4H_DELAY_NS       : real := -3177.95;
            PHOTON_4V_DELAY_NS       : real := -3181.05
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
            time_stamp_buffer_overflows : out t_time_stamp_buffer_overflows_2d;
            alpha_buffer : out t_alpha_buffer_2d;

            to_math_alpha : out std_logic_vector(1 downto 0);
            to_math_sx_xz : out std_logic_vector(1 downto 0);
            actual_qubit_valid : out std_logic;
            actual_qubit : out std_logic_vector(1 downto 0);
            actual_qubit_time_stamp : out std_logic_vector(st_transaction_data_max_width);

            time_stamp_counter_overflow : out std_logic
        );
    end fsm_gflow;

    architecture rtl of fsm_gflow is

        type t_state_gflow is (
            QUBIT_1,
            QUBIT_2,
            QUBIT_3,
            QUBIT_4
        );
        -- attribute ENUM_ENCODING : string;
        -- attribute ENUM_ENCODING of t_state_gflow : type is "GRAY";
        -- attribute ENUM_ENCODING of t_state_gflow : type is "00 01 11 10";

        signal state_gflow : t_state_gflow := QUBIT_1;
        -- Encoding: BINARY, GRAY, ONE_HOT, ONE_COLD or AUTO
        attribute FSM_STATE : string;
        attribute FSM_STATE of state_gflow : signal is "GRAY";

        signal int_state_gflow : natural range 0 to QUBITS_CNT-1 := 0;

        constant CLK_PERIODS_PC_DELAY : natural := natural(real(CLK_HZ)/1.0e6) * PCD_DELAY_US;
        subtype st_periods_pcd_delay is natural range 0 to CLK_PERIODS_PC_DELAY-1;
        signal s_cnt_pcd_delay : st_periods_pcd_delay := 0;

        -- Angles alpha (binary represenatation):
        type t_qx_angle_alpha is array(QUBITS_CNT-1 downto 0) of std_logic_vector(1 downto 0);
        -- ORIGINAL
        -- constant QX_BASIS_ALPHA : t_qx_angle_alpha := ("11", "10", "01", "00");

        -- TEST
        constant QX_BASIS_ALPHA : t_qx_angle_alpha := ("00", "01", "10", "11");
        --                                              i3    i2    i1    i0

        -- Success flag
        signal s_gflow_success_flag : std_logic := '0';
        signal s_gflow_success_done : std_logic := '0';

        -- Wait for the PCD to transmit the Trigger pulse
        -- constant CLK_PERIODS_DELAY_Q1H : natural := natural(real(CLK_HZ)/1.0e6) * (PCD_DELAY_US);

        -- After triggering the pulse, a new qubit is expected to arrive within around 12 ns (+- PHOTON_XY_DELAY_NS)
        -- The time which the measurement programm has to subtract or add to get the coincidence clicks (CCS)
        -- constant PHOTON_1H_DELAY_US : real := -(PHOTON_1H_DELAY_NS)/1000.0;  -- conversion ns to us
        -- constant PHOTON_1V_DELAY_US : real := -(PHOTON_1V_DELAY_NS)/1000.0;  -- conversion ns to us
        constant PHOTON_2H_DELAY_US : real := abs(PHOTON_2H_DELAY_NS)/1000.0;  -- conversion ns to us
        constant PHOTON_2V_DELAY_US : real := abs(PHOTON_2V_DELAY_NS)/1000.0;  -- conversion ns to us
        constant PHOTON_3H_DELAY_US : real := abs(PHOTON_3H_DELAY_NS)/1000.0;  -- conversion ns to us
        constant PHOTON_3V_DELAY_US : real := abs(PHOTON_3V_DELAY_NS)/1000.0;  -- conversion ns to us
        constant PHOTON_4H_DELAY_US : real := abs(PHOTON_4H_DELAY_NS)/1000.0;  -- conversion ns to us
        constant PHOTON_4V_DELAY_US : real := abs(PHOTON_4V_DELAY_NS)/1000.0;  -- conversion ns to us

        -- constant CLK_PERIODS_DELAY_Q1H : natural := natural(real(CLK_HZ)/1.0e6) * (natural(PHOTON_1H_DELAY_US));  -- PCD delay is included in the photon XY delays
        -- constant CLK_PERIODS_DELAY_Q1V : natural := natural(real(CLK_HZ)/1.0e6) * (natural(PHOTON_1V_DELAY_US));  -- PCD delay is included in the photon XY delays
        -- 1 MHz = 1 us
        constant CLK_PERIODS_DELAY_Q2H : natural := natural(real(CLK_HZ)/1.0e6) * (natural(PHOTON_2H_DELAY_US));  -- PCD delay is included in the photon XY delays
        constant CLK_PERIODS_DELAY_Q2V : natural := natural(real(CLK_HZ)/1.0e6) * (natural(PHOTON_2V_DELAY_US));  -- PCD delay is included in the photon XY delays
        constant CLK_PERIODS_DELAY_Q3H : natural := natural(real(CLK_HZ)/1.0e6) * (natural(PHOTON_3H_DELAY_US));  -- PCD delay is included in the photon XY delays
        constant CLK_PERIODS_DELAY_Q3V : natural := natural(real(CLK_HZ)/1.0e6) * (natural(PHOTON_3V_DELAY_US));  -- PCD delay is included in the photon XY delays
        constant CLK_PERIODS_DELAY_Q4H : natural := natural(real(CLK_HZ)/1.0e6) * (natural(PHOTON_4H_DELAY_US));  -- PCD delay is included in the photon XY delays
        constant CLK_PERIODS_DELAY_Q4V : natural := natural(real(CLK_HZ)/1.0e6) * (natural(PHOTON_4V_DELAY_US));  -- PCD delay is included in the photon XY delays

        -- 1 MHz delay + CCS delay + FPGA Delay: corrected counting for waiting for the next qubit

        -- GFLOW module timing perspective:
        -- Qubit 1 on pins (delay 0 ns)    -> 5x clk input logic -> GFLOW wait for 0x   clk -> 5x clk until output pulse -> Trigger waiting 408x clk (= delay 2117 ns = 1MHz output pulse + delay on cables)
        -- Qubit 2 in pins (delay 2117 ns) -> 5x clk input logic -> GFLOW wait for 408x clk ->

        -- subtype st_periods_q1h is natural range 0 to CLK_PERIODS_DELAY_Q1H-1 + TOTAL_DELAY_FPGA_BEFORE + TOTAL_DELAY_FPGA_AFTER;
        -- subtype st_periods_q1v is natural range 0 to CLK_PERIODS_DELAY_Q1V-1 + TOTAL_DELAY_FPGA_BEFORE + TOTAL_DELAY_FPGA_AFTER;  -- not used
        subtype st_periods_q2h is natural range 0 to CLK_PERIODS_DELAY_Q2H-1 + TOTAL_DELAY_FPGA_BEFORE + TOTAL_DELAY_FPGA_AFTER;
        subtype st_periods_q2v is natural range 0 to CLK_PERIODS_DELAY_Q2V-1 + TOTAL_DELAY_FPGA_BEFORE + TOTAL_DELAY_FPGA_AFTER;  -- not used
        subtype st_periods_q3h is natural range 0 to CLK_PERIODS_DELAY_Q3H-1 + TOTAL_DELAY_FPGA_BEFORE + TOTAL_DELAY_FPGA_AFTER;
        subtype st_periods_q3v is natural range 0 to CLK_PERIODS_DELAY_Q3V-1 + TOTAL_DELAY_FPGA_BEFORE + TOTAL_DELAY_FPGA_AFTER;  -- not used
        subtype st_periods_q4h is natural range 0 to CLK_PERIODS_DELAY_Q4H-1 + TOTAL_DELAY_FPGA_BEFORE + TOTAL_DELAY_FPGA_AFTER;
        subtype st_periods_q4v is natural range 0 to CLK_PERIODS_DELAY_Q4V-1 + TOTAL_DELAY_FPGA_BEFORE + TOTAL_DELAY_FPGA_AFTER;  -- not used

        -- signal s_periods_q1h : st_periods_q1h := 0;
        -- signal s_periods_q1v : st_periods_q1v := 0;
        -- Function to compare which bit arrives second
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
                return natural(real(CLK_HZ)/1.0e6) * (natural(v_ph_verti_us));
            else
                return natural(real(CLK_HZ)/1.0e6) * (natural(v_ph_horiz_us));
            end if;
        end function;

        type t_periods_q_2d is array (QUBITS_CNT-1 downto 0) of natural; 
        -- indexes: 3, 2, 1, 0
        constant MAX_PERIODS_Q : t_periods_q_2d := (
            get_slowest_photon_delay_us(PHOTON_1H_DELAY_NS, PHOTON_1V_DELAY_NS), -- 3 (never used)
            get_slowest_photon_delay_us(PHOTON_2H_DELAY_NS, PHOTON_2V_DELAY_NS), -- 2
            get_slowest_photon_delay_us(PHOTON_3H_DELAY_NS, PHOTON_3V_DELAY_NS), -- 1
            get_slowest_photon_delay_us(PHOTON_4H_DELAY_NS, PHOTON_4V_DELAY_NS)  -- 0
        );

        signal s_periods_q : t_periods_q_2d := (others => 0);

        signal s_periods_q2h : st_periods_q2h := 0;
        signal s_periods_q2v : st_periods_q2v := 0;
        signal s_periods_q3h : st_periods_q3h := 0;
        signal s_periods_q3v : st_periods_q3v := 0;
        signal s_periods_q4h : st_periods_q4h := 0;
        signal s_periods_q4v : st_periods_q4v := 0;

        signal slv_to_math_sx_sz : std_logic_vector(1 downto 0) := (others => '0');
        signal slv_sampled_qubits : std_logic_vector(qubits_sampled'range) := (others => '0');

        -- Time Stamp
        signal uns_actual_time_stamp_counter : unsigned(st_transaction_data_max_width) := (others => '0');
        signal uns_actual_time_overflow_counter : unsigned(st_transaction_data_max_width) := (others => '0');
        signal slv_last_time_stamp : std_logic_vector(st_transaction_data_max_width) := (others => '0');

        -- Data buffers for verification
        signal slv_qubit_buffer_2d      : t_qubit_buffer_2d := (others => (others => '0'));
        signal slv_time_stamp_buffer_2d : t_time_stamp_buffer_2d := (others => (others => '0'));
        signal slv_time_stamp_buffer_overflows_2d : t_time_stamp_buffer_overflows_2d := (others => (others => '0'));
        signal slv_alpha_buffer_2d      : t_alpha_buffer_2d := (others => (others => '0'));


    begin


        ---------------------
        -- G-Flow Protocol --
        ---------------------
        gflow_success_flag <= s_gflow_success_flag;
        gflow_success_done <= s_gflow_success_done;
        to_math_sx_xz <= slv_to_math_sx_sz;
        actual_qubit_time_stamp <= std_logic_vector(uns_actual_time_stamp_counter(st_transaction_data_max_width));
        qubit_buffer <= slv_qubit_buffer_2d;
        time_stamp_buffer <= slv_time_stamp_buffer_2d;
        time_stamp_buffer_overflows <= slv_time_stamp_buffer_overflows_2d;
        alpha_buffer <= slv_alpha_buffer_2d;

        proc_fsm_gflow : process(clk)
            variable v_valid_qubit_signals_ored : std_logic;

        begin
            if rising_edge(clk) then
                if rst = RST_VAL then
                    state_gflow <= QUBIT_1;
                    actual_qubit_valid <= '0';
                    time_stamp_counter_overflow <= '0';
                    s_gflow_success_flag <= '0';
                    s_gflow_success_done <= '0';
                    s_periods_q2h <= 0;
                    s_periods_q3h <= 0;
                    s_periods_q4h <= 0;
                    to_math_alpha <= (others => '0');
                    slv_to_math_sx_sz <= (others => '0');
                    actual_qubit <= (others => '0');
                    uns_actual_time_stamp_counter <= (others => '0');
                    uns_actual_time_overflow_counter <= (others => '0');

                    slv_qubit_buffer_2d <= (others => (others => '0'));
                    slv_time_stamp_buffer_2d <= (others => (others => '0'));
                    slv_time_stamp_buffer_overflows_2d <= (others => (others => '0'));
                    slv_alpha_buffer_2d <= (others => (others => '0'));

                    -- TEST
                    int_state_gflow <= 0;


                else
                    -- Default values
                    actual_qubit_valid <= '0';
                    time_stamp_counter_overflow <= '0';
                    s_gflow_success_done <= '0';

                    -- Time Stamp counter always inscrements each clock cycle and overflows
                    -- If 1 cycle = 10 ns: 10*10^(-9) sec * 2^32 cycles = overflow after every 42.949673 sec
                    uns_actual_time_stamp_counter <= uns_actual_time_stamp_counter + 1;

                    -- Wait until first qubit detected, otherwise trigger overflow flag
                    if to_integer(uns_actual_time_stamp_counter) = 2**uns_actual_time_stamp_counter'length-1 then
                        uns_actual_time_overflow_counter <= uns_actual_time_overflow_counter + 1;
                    end if;

                    -- Sample and latch feedback from MODULO, Override if feedback_mod_valid
                    slv_to_math_sx_sz <= slv_to_math_sx_sz;

                    -- ORIGINAL
                    -- case state_gflow is
                    --     when QUBIT_1 =>

                    --         s_gflow_success_done <= '0';

                    --         actual_qubit <= qubits_sampled(7 downto 6);
                    --         slv_qubit_buffer_2d(3) <= qubits_sampled(7 downto 6);

                    --         to_math_alpha <= QX_BASIS_ALPHA(3);
                    --         slv_alpha_buffer_2d(3) <= QX_BASIS_ALPHA(3);

                    --         slv_to_math_sx_sz <= "00";

                    --         -- If success from photon 4, then let this state transmit the pulse, otherwise wait for new clicks
                    --         if s_gflow_success_flag = '1' then

                    --             -- Let the photon 4 transmit the PCD pulse
                    --             if s_cnt_pcd_delay = st_periods_pcd_delay'high then
                    --                 s_cnt_pcd_delay <= 0;
                    --                 s_gflow_success_flag <= '0';
                    --                 s_gflow_success_done <= '1';
                    --             else
                    --                 s_cnt_pcd_delay <= s_cnt_pcd_delay + 1;
                    --                 s_gflow_success_flag <= s_gflow_success_flag;
                    --             end if;

                    --         else
                    --             -- Detect Qubit 1 and proceed to Qubit 2
                    --             if qubits_sampled_valid(3) = '0' then
                    --                 state_gflow <= QUBIT_1;
                    --             else
                    --                 actual_qubit_valid <= '1';
                    --                 slv_time_stamp_buffer_2d(3) <= std_logic_vector(uns_actual_time_stamp_counter);
                    --                 slv_time_stamp_buffer_overflows_2d(3) <= std_logic_vector(uns_actual_time_overflow_counter);
                    --                 -- state_gflow <= QUBIT_2;
                    --                 state_gflow <= state_gflow + 1;
                    --             end if;

                    --         end if;


                    --     -- Wait for qubit 2
                    --     when QUBIT_2 =>

                    --         actual_qubit <= qubits_sampled(5 downto 4);
                    --         slv_qubit_buffer_2d(2) <= qubits_sampled(5 downto 4);

                    --         to_math_alpha <= QX_BASIS_ALPHA(2);
                    --         slv_alpha_buffer_2d(2) <= QX_BASIS_ALPHA(2);

                    --         if feedback_mod_valid = '1' then
                    --             slv_to_math_sx_sz <= feedback_mod;
                    --         end if;

                    --         -- If the counter has reached the max delay, don't ask and reset it and assess the next state
                    --         if s_periods_q2h = st_periods_q2h'high then

                    --             -- Detect Qubit 2 and proceed to Qubit 3, save times tamp
                    --             if qubits_sampled_valid(2) = '0' then
                    --                 state_gflow <= QUBIT_1;
                    --             else
                    --                 actual_qubit_valid <= '1';
                    --                 slv_time_stamp_buffer_2d(2) <= std_logic_vector(uns_actual_time_stamp_counter);
                    --                 slv_time_stamp_buffer_overflows_2d(2) <= std_logic_vector(uns_actual_time_overflow_counter);
                    --                 -- state_gflow <= QUBIT_3;
                    --                 state_gflow <= state_gflow + 1;
                    --             end if;

                    --             -- Reset counter
                    --             s_periods_q2h <= 0;

                    --         elsif s_periods_q2h = st_periods_q2h'high-1 then

                    --             -- Detect Qubit 2 earlier and proceed to Qubit 3
                    --             if qubits_sampled_valid(2) = '1' then
                    --                 -- Leave the state early, reset counter, save time stamp
                    --                 actual_qubit_valid <= '1';
                    --                 slv_time_stamp_buffer_2d(2) <= std_logic_vector(uns_actual_time_stamp_counter);
                    --                 slv_time_stamp_buffer_overflows_2d(2) <= std_logic_vector(uns_actual_time_overflow_counter);
                    --                 s_periods_q2h <= 0;
                    --                 -- state_gflow <= QUBIT_3;
                    --                 state_gflow <= state_gflow + 1;
                    --             else
                    --                 s_periods_q2h <= s_periods_q2h + 1;
                    --             end if;

                    --         else
                    --             s_periods_q2h <= s_periods_q2h + 1;
                    --         end if;


                    --     -- Wait for qubit 3
                    --     when QUBIT_3 =>

                    --         actual_qubit <= qubits_sampled(3 downto 2);
                    --         slv_qubit_buffer_2d(1) <= qubits_sampled(3 downto 2);

                    --         to_math_alpha <= QX_BASIS_ALPHA(1);
                    --         slv_alpha_buffer_2d(1) <= QX_BASIS_ALPHA(1);

                    --         if feedback_mod_valid = '1' then
                    --             slv_to_math_sx_sz <= feedback_mod;
                    --         end if;

                    --         -- If the counter has reached the max delay, don't ask and reset it and assess the next state
                    --         if s_periods_q3h = st_periods_q3h'high then

                    --             -- Detect Qubit 3 and proceed to Qubit 4, save time stamp
                    --             if qubits_sampled_valid(1) = '0' then
                    --                 state_gflow <= QUBIT_1;
                    --             else
                    --                 actual_qubit_valid <= '1';
                    --                 slv_time_stamp_buffer_2d(1) <= std_logic_vector(uns_actual_time_stamp_counter);
                    --                 slv_time_stamp_buffer_overflows_2d(1) <= std_logic_vector(uns_actual_time_overflow_counter);
                    --                 -- state_gflow <= QUBIT_4;
                    --                 state_gflow <= state_gflow + 1;
                    --             end if;

                    --             -- Reset counter
                    --             s_periods_q3h <= 0;

                    --         elsif s_periods_q3h = st_periods_q3h'high-1 then

                    --             -- Detect Qubit 3 earlier and proceed to Qubit 4
                    --             if qubits_sampled_valid(1) = '1' then
                    --                 -- Leave the state early, reset counter, save time stamp
                    --                 actual_qubit_valid <= '1';
                    --                 slv_time_stamp_buffer_2d(1) <= std_logic_vector(uns_actual_time_stamp_counter);
                    --                 slv_time_stamp_buffer_overflows_2d(1) <= std_logic_vector(uns_actual_time_overflow_counter);
                    --                 s_periods_q3h <= 0;
                    --                 -- state_gflow <= QUBIT_4;
                    --                 state_gflow <= state_gflow + 1;
                    --             else
                    --                 s_periods_q3h <= s_periods_q3h + 1;
                    --             end if;

                    --         else
                    --             s_periods_q3h <= s_periods_q3h + 1;
                    --         end if;


                    --     -- Wait for qubit 4
                    --     when QUBIT_4 =>

                    --         actual_qubit <= qubits_sampled(1 downto 0);
                    --         slv_qubit_buffer_2d(0) <= qubits_sampled(1 downto 0);

                    --         to_math_alpha <= QX_BASIS_ALPHA(0);
                    --         slv_alpha_buffer_2d(0) <= QX_BASIS_ALPHA(0);

                    --         if feedback_mod_valid = '1' then
                    --             slv_to_math_sx_sz <= feedback_mod;
                    --         end if;

                    --         if s_periods_q4h = st_periods_q4h'high then

                    --             -- Detect Qubit 4 and proceed to Qubit 1, save times tamp
                    --             if qubits_sampled_valid(0) = '0' then
                    --                 state_gflow <= QUBIT_1;
                    --             else
                    --                 actual_qubit_valid <= '1';
                    --                 slv_time_stamp_buffer_2d(0) <= std_logic_vector(uns_actual_time_stamp_counter);
                    --                 slv_time_stamp_buffer_overflows_2d(0) <= std_logic_vector(uns_actual_time_overflow_counter);
                    --                 state_gflow <= QUBIT_1;
                    --                 s_gflow_success_flag <= '1';
                    --             end if;

                    --             -- Reset counter
                    --             s_periods_q(0) <= 0;

                    --         elsif s_periods_q(0) = st_periods_q4h'high-1 then

                    --             -- Detect Qubit 4 earlier and proceed to Qubit 1
                    --             if qubits_sampled_valid(0) = '1' then
                    --                 -- Leave the state early, reset counter, save time stamp
                    --                 actual_qubit_valid <= '1';
                    --                 slv_time_stamp_buffer_2d(0) <= std_logic_vector(uns_actual_time_stamp_counter);
                    --                 slv_time_stamp_buffer_overflows_2d(0) <= std_logic_vector(uns_actual_time_overflow_counter);
                    --                 s_periods_q(0) <= 0;
                    --                 state_gflow <= QUBIT_1;
                    --                 s_gflow_success_flag <= '1';
                    --             else
                    --                 s_periods_q(0) <= s_periods_q(0) + 1;
                    --             end if;

                    --         else
                    --             s_periods_q(0) <= s_periods_q(0) + 1;
                    --         end if;

                    -- end case;








                    
                    -- TEST: Scalable description of a FSM-like logic
                    -- FIRST qubit detected
                    if int_state_gflow = 0 then
                        s_gflow_success_done <= '0';

                        actual_qubit <= qubits_sampled(QUBITS_CNT*2-1 - 0*2 downto QUBITS_CNT*2-1 - 0*2-1);
                        slv_qubit_buffer_2d(QUBITS_CNT-1) <= qubits_sampled(QUBITS_CNT*2-1 - 0*2 downto QUBITS_CNT*2-1 - 0*2-1);

                        to_math_alpha <= QX_BASIS_ALPHA(QUBITS_CNT-1);
                        slv_alpha_buffer_2d(QUBITS_CNT-1) <= QX_BASIS_ALPHA(QUBITS_CNT-1);

                        slv_to_math_sx_sz <= "00";

                        -- If success from photon 4, then let this state transmit the pulse, otherwise wait for new clicks
                        if s_gflow_success_flag = '1' then

                            -- Let the photon 4 transmit the PCD pulse
                            if s_cnt_pcd_delay = st_periods_pcd_delay'high then
                                s_cnt_pcd_delay <= 0;
                                s_gflow_success_flag <= '0';
                                s_gflow_success_done <= '1';
                            else
                                s_cnt_pcd_delay <= s_cnt_pcd_delay + 1;
                                s_gflow_success_flag <= s_gflow_success_flag;
                            end if;

                        else
                            -- Detect Qubit 1 and proceed to Qubit 2
                            if qubits_sampled_valid(QUBITS_CNT-1) = '0' then
                                int_state_gflow <= int_state_gflow;
                            else
                                actual_qubit_valid <= '1';
                                slv_time_stamp_buffer_2d(QUBITS_CNT-1) <= std_logic_vector(uns_actual_time_stamp_counter);
                                slv_time_stamp_buffer_overflows_2d(QUBITS_CNT-1) <= std_logic_vector(uns_actual_time_overflow_counter);
                                -- Next state
                                int_state_gflow <= int_state_gflow + 1;
                            end if;

                        end if;

                    -- INTERMEDIATE qubit/s detected
                    -- when (int_state_gflow /= 0 and int_state_gflow < QUBITS_CNT-1) =>
                    elsif (int_state_gflow /= 0 and int_state_gflow < QUBITS_CNT-1) then
                        -- Create parallel threads, activate one based on the actual state
                        for i in 1 to QUBITS_CNT-2 loop
                            if i = int_state_gflow then
                                -- actual_qubit <= qubits_sampled(3 downto 2);
                                actual_qubit <= qubits_sampled(QUBITS_CNT*2-1 - i*2 downto QUBITS_CNT*2-1 - i*2-1);
                                -- slv_qubit_buffer_2d(QUBITS_CNT-1-i) <= qubits_sampled(3 downto 2);
                                slv_qubit_buffer_2d(QUBITS_CNT-1-i) <= qubits_sampled(QUBITS_CNT*2-1 - i*2 downto QUBITS_CNT*2-1 - i*2-1);

                                to_math_alpha <= QX_BASIS_ALPHA(QUBITS_CNT-1-i);
                                slv_alpha_buffer_2d(QUBITS_CNT-1-i) <= QX_BASIS_ALPHA(QUBITS_CNT-1-i);

                                if feedback_mod_valid = '1' then
                                    slv_to_math_sx_sz <= feedback_mod;
                                end if;

                                -- If the counter has reached the max delay, don't ask and reset it and assess the next state
                                if s_periods_q(QUBITS_CNT-1-i) = MAX_PERIODS_Q(QUBITS_CNT-1-i)-1 then

                                    -- Detect Qubit 3 and proceed to Qubit 4, save time stamp
                                    if qubits_sampled_valid(QUBITS_CNT-1-i) = '0' then
                                        int_state_gflow <= 0;
                                    else
                                        actual_qubit_valid <= '1';
                                        slv_time_stamp_buffer_2d(QUBITS_CNT-1-i) <= std_logic_vector(uns_actual_time_stamp_counter);
                                        slv_time_stamp_buffer_overflows_2d(QUBITS_CNT-1-i) <= std_logic_vector(uns_actual_time_overflow_counter);
                                        -- state_gflow <= QUBIT_4;
                                        int_state_gflow <= int_state_gflow + 1;
                                    end if;

                                    -- Reset counter
                                    s_periods_q(QUBITS_CNT-1-i) <= 0;

                                elsif s_periods_q(QUBITS_CNT-1-i) = MAX_PERIODS_Q(QUBITS_CNT-1-i)-1 then

                                    -- Detect Qubit 3 earlier and proceed to Qubit 4
                                    if qubits_sampled_valid(QUBITS_CNT-1-i) = '1' then
                                        -- Leave the state early, reset counter, save time stamp
                                        actual_qubit_valid <= '1';
                                        slv_time_stamp_buffer_2d(QUBITS_CNT-1-i) <= std_logic_vector(uns_actual_time_stamp_counter);
                                        slv_time_stamp_buffer_overflows_2d(QUBITS_CNT-1-i) <= std_logic_vector(uns_actual_time_overflow_counter);
                                        s_periods_q(QUBITS_CNT-1-i) <= 0;
                                        -- state_gflow <= QUBIT_4;
                                        int_state_gflow <= int_state_gflow + 1;
                                    else
                                        s_periods_q(QUBITS_CNT-1-i) <= s_periods_q(QUBITS_CNT-1-i) + 1;
                                    end if;

                                else
                                    s_periods_q(QUBITS_CNT-1-i) <= s_periods_q(QUBITS_CNT-1-i) + 1;
                                end if;
                            else
                                -- Detect invalid state, reset
                                int_state_gflow <= 0;
                            end if;
                        end loop;


                    -- LAST photon detected
                    -- when QUBITS_CNT-1 =>
                    elsif int_state_gflow = QUBITS_CNT-1 then
                        actual_qubit <= qubits_sampled(1 downto 0);
                        slv_qubit_buffer_2d(0) <= qubits_sampled(1 downto 0);

                        to_math_alpha <= QX_BASIS_ALPHA(0);
                        slv_alpha_buffer_2d(0) <= QX_BASIS_ALPHA(0);

                        if feedback_mod_valid = '1' then
                            slv_to_math_sx_sz <= feedback_mod;
                        end if;

                        if s_periods_q(0) = MAX_PERIODS_Q(0)-1 then

                            -- Detect Qubit 4 and proceed to Qubit 1, save times tamp
                            if qubits_sampled_valid(0) = '0' then
                                int_state_gflow <= 0;
                            else
                                actual_qubit_valid <= '1';
                                slv_time_stamp_buffer_2d(0) <= std_logic_vector(uns_actual_time_stamp_counter);
                                slv_time_stamp_buffer_overflows_2d(0) <= std_logic_vector(uns_actual_time_overflow_counter);
                                int_state_gflow <= 0;
                                s_gflow_success_flag <= '1';
                            end if;

                            -- Reset counter
                            s_periods_q(0) <= 0;

                        elsif s_periods_q(0) = MAX_PERIODS_Q(0)-1 then

                            -- Detect Qubit 4 earlier and proceed to Qubit 1
                            if qubits_sampled_valid(0) = '1' then
                                -- Leave the state early, reset counter, save time stamp
                                actual_qubit_valid <= '1';
                                slv_time_stamp_buffer_2d(0) <= std_logic_vector(uns_actual_time_stamp_counter);
                                slv_time_stamp_buffer_overflows_2d(0) <= std_logic_vector(uns_actual_time_overflow_counter);
                                s_periods_q(0) <= 0;
                                int_state_gflow <= 0;
                                s_gflow_success_flag <= '1';
                            else
                                s_periods_q(0) <= s_periods_q(0) + 1;
                            end if;

                        else
                            s_periods_q(0) <= s_periods_q(0) + 1;
                        end if;

                    -- Define invalid states
                    elsif int_state_gflow > QUBITS_CNT-1 then
                        int_state_gflow <= 0;
                    end if;


                end if;
            end if;
        end process;

    end architecture;