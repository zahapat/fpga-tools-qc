    -- fsm_feedforward.vhd: Feed-forward controller

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    use std.textio.all;
    use ieee.std_logic_textio.all;
    
    library lib_src;
    use lib_src.types_pack.all;

    entity fsm_feedforward is
        generic (             -- Qubit #:         1 2 3 4
                              -- Polarization:    HVHVHVHV
            INT_FEEDFWD_PROGRAMMING  : integer := 01110101; -- Change the behaviour of the feedforward operation
            RST_VAL                  : std_logic := '1';
            -- SAMPL_CLK_HZ             : real := 250.0e6;       -- You must keep this for acquisition compensation delay between H/V photons
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

            qubits_sampled_valid : in std_logic_vector(QUBITS_CNT-1 downto 0);
            qubits_sampled : in  std_logic_vector((QUBITS_CNT*2)-1 downto 0);

            o_feedforward_pulse : out std_logic_vector(0 downto 0);
            o_feedforward_pulse_trigger : out std_logic_vector(0 downto 0);

            o_unsuccessful_qubits : out std_logic_vector(QUBITS_CNT-1 downto 1);

            feedfwd_success_flag : out std_logic;
            feedfwd_success_done : out std_logic;
            qubit_buffer : out t_qubit_buffer_2d;
            time_stamp_buffer : out t_time_stamp_buffer_2d;

            -- state_feedfwd : out natural range 0 to QUBITS_CNT-1;
            state_feedfwd : out std_logic_vector(QUBITS_CNT-1 downto 0); -- NEW
            actual_qubit_valid : out std_logic;
            actual_qubit : out std_logic_vector(1 downto 0);

            time_stamp_counter_overflow : out std_logic;

            eom_ctrl_pulse_ready : in std_logic
        );
    end fsm_feedforward;

    architecture rtl of fsm_feedforward is

        -- Binary integer to std_logic_vector preserving bitstring
        impure function int_to_slv_bitpreserve (
            constant INT_BITSTRING : integer
        ) return std_logic_vector is
            variable v_degree_val : real := 0.0;
            variable v_degree_cnt : integer := 0;
            variable v_int_tobe_divided_by_ten : integer;
            variable v_int_divided_by_ten : integer;
            variable v_remainder : integer;
            variable v_slv_result : std_logic_vector(QUBITS_CNT*2-1 downto 0) := (others => '0');
            variable v_slv_result_reversed : std_logic_vector(QUBITS_CNT*2-1 downto 0) := (others => '0');
        begin

            -- Estimate the degree of the integer variable (raw value)
            -- Set the upper bound variable high enough to estimate the degree
            v_degree_val := real(INT_BITSTRING);
            if v_degree_val > 0.0 then
                v_degree_cnt := 1;
            end if;
            for i in 0 to 31 loop
                v_degree_val := v_degree_val/10.0;
                if v_degree_val >= 1.0 then
                    v_degree_cnt := v_degree_cnt + 1;
                end if;
            end loop;
            report "v_degree_cnt=" & integer'image(v_degree_cnt);

            -- Initial assignment and conversion to real
            v_int_tobe_divided_by_ten := integer(INT_BITSTRING);
            report "v_int_tobe_divided_by_ten=" & integer'image(v_int_tobe_divided_by_ten);

            -- Iterative addition of 0 or 1 bits
            -- for i in QUBITS_CNT*2-1 downto 0 loop
            for i in v_degree_cnt-1 downto 0 loop
                -- Calculate remainder
                v_int_divided_by_ten := v_int_tobe_divided_by_ten / 10;

                -- Add 0 or 1 to the output vector
                report "v_int_divided_by_ten * 10 = " & integer'image(v_int_divided_by_ten * 10);
                report "v_int_tobe_divided_by_ten = " & integer'image(v_int_tobe_divided_by_ten);
                if v_int_divided_by_ten * 10 /= v_int_tobe_divided_by_ten then
                    v_slv_result(i) := '1';
                end if;

                report "v_slv_result(loop)=" & integer'image(to_integer(unsigned(v_slv_result(i downto i))));

                -- Reset variables for new iteration
                v_int_tobe_divided_by_ten := v_int_divided_by_ten;
            end loop;
            report "v_slv_result(after loop)=" & integer'image(to_integer(unsigned(v_slv_result)));

            -- Mirror values with the effect of adding leading zeros
            for i in 0 to QUBITS_CNT*2-1 loop
                if i < v_degree_cnt then
                    v_slv_result_reversed(i) := v_slv_result(v_degree_cnt-1-i);
                end if;
                report "v_slv_result_reversed=" & integer'image(to_integer(unsigned(v_slv_result_reversed(i downto i))));
            end loop;

            return v_slv_result_reversed;
        end function;
        constant SLV_FEEDFWD_PROGRAMMING : std_logic_vector := int_to_slv_bitpreserve(INT_FEEDFWD_PROGRAMMING);


        -- The main signal that holds the actual qubit state within the cluster
        signal slv_state_feedforward : std_logic_vector(QUBITS_CNT-1 downto 0) := std_logic_vector(to_unsigned(1, QUBITS_CNT));
        signal slv_state_feedforward_two_qubits : std_logic_vector(QUBITS_CNT-1 downto 0) := std_logic_vector(to_unsigned(1, QUBITS_CNT));

        signal int_state_feedfwd : natural range 0 to QUBITS_CNT-1 := 0;
        signal int_state_feedfwd_two_qubits : natural range 0 to QUBITS_CNT-1 := 0;
        signal actual_state_feedfwd : natural range 0 to QUBITS_CNT-1 := 0;
        signal actual_state_feedfwd_two_qubits : natural range 0 to QUBITS_CNT-1 := 0;

        constant CLK_PERIOD_NS : real := 
            (1.0/real(CLK_HZ) * 1.0e9);
        constant CLK_PERIODS_CTRL_PULSE : natural :=
                natural( ceil(real(CTRL_PULSE_DUR_WITH_DEADTIME_NS) / CLK_PERIOD_NS) );
        signal eom_ctrl_pulse_ready_p1 : std_logic := '0';
        signal eom_ctrl_pulse_fedge_latched : std_logic := '0';

        -- Feedforward output EOM signal
        signal slv_o_feedforward_pulse : std_logic_vector(0 downto 0) := (others => '0');
        signal slv_o_feedforward_pulse_trigger : std_logic_vector(0 downto 0) := (others => '0');

        -- Success flag
        signal s_feedfwd_success_flag : std_logic := '0';
        signal sl_feedfwd_success_flag : std_logic := '0';
        signal sl_feedfwd_success_done : std_logic := '0';

        -- Unsuccessful flags
        signal slv_unsuccessful_qubits : std_logic_vector(QUBITS_CNT-1 downto 1) := (others => '0');
        signal slv_unsuccessful_qubits_two_qubits : std_logic_vector(QUBITS_CNT-1 downto 1) := (others => '0');

        -- Qubits sampled - initialize values, prevent X in simulation
        signal slv_qubits_sampled : std_logic_vector(qubits_sampled'range) := (others => '0');
        signal slv_actual_qubit : std_logic_vector(actual_qubit'range) := (others => '0');

        -- GFLOW module timing perspective
        -- Function that compares which photon (H/V) arrives the second (is expected to be slower) and get its delay in clock periods
        impure function get_largest_photon_delay_periods (
            constant REAL_PHOTON_A_DELAY_NS : real;
            constant REAL_PHOTON_B_DELAY_NS : real
        ) return natural is
            variable v_ph_a_us : real := 0.0;
            variable v_ph_b_us : real := 0.0;
        begin
            -- 1 MHz = 1 us
            v_ph_a_us := abs(REAL_PHOTON_A_DELAY_NS)/1000.0;
            v_ph_b_us := abs(REAL_PHOTON_B_DELAY_NS)/1000.0;

            -- Pick the one with the largest delay
            if v_ph_a_us < v_ph_b_us then
                return natural(ceil(real(CLK_HZ)/1.0e6 * v_ph_b_us));
            else
                return natural(ceil(real(CLK_HZ)/1.0e6 * v_ph_a_us));
            end if;
        end function;

        type t_periods_q_2d is array (6-1 downto 0) of natural; 
        constant MAX_PERIODS : t_periods_q_2d := (
            get_largest_photon_delay_periods(PHOTON_6H_DELAY_NS, PHOTON_6V_DELAY_NS), -- index 5
            get_largest_photon_delay_periods(PHOTON_5H_DELAY_NS, PHOTON_5V_DELAY_NS), -- index 4
            get_largest_photon_delay_periods(PHOTON_4H_DELAY_NS, PHOTON_4V_DELAY_NS), -- index 3
            get_largest_photon_delay_periods(PHOTON_3H_DELAY_NS, PHOTON_3V_DELAY_NS), -- index 2
            get_largest_photon_delay_periods(PHOTON_2H_DELAY_NS, PHOTON_2V_DELAY_NS), -- index 1
            get_largest_photon_delay_periods(PHOTON_1H_DELAY_NS, PHOTON_1V_DELAY_NS)  -- index 0 (never used)
        );

        -- Sort MAX_PERIODS and get sorted indices (default) or periods
        impure function get_sorted_qubits_indices_or_periods (
            constant INDICES_OR_PERIODS : string -- Input "INDICES" or "PERIODS"
        ) return t_periods_q_2d is 
            variable v_max_periods_q_sorted : t_periods_q_2d := MAX_PERIODS;
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
        signal int_main_counter_two_qubits : natural := 0;

        -- attribute use_dsp : string;
        -- attribute use_dsp of int_main_counter : signal is "yes";

        -- Time Stamp
        signal uns_actual_time_stamp_counter : unsigned(28*2-1 downto 0) := (others => '0');
        signal sl_time_stamp_counter_counter_en : std_logic := '0';

        -- Data buffers for verification in PC
        signal slv_qubit_buffer_2d      : t_qubit_buffer_2d := (others => (others => '0'));
        signal slv_time_stamp_buffer_2d : t_time_stamp_buffer_2d := (others => (others => '0'));

        -- This part is necessary to create scalable binary encoding for this controller to determine qubit IDs
        type t_qubits_binary_encoding_2d is array (QUBITS_CNT-1 downto 1) of integer;
        impure function feedfwd_controller_binary_encoding (
            constant QUBITS_CNT : natural
        ) return t_qubits_binary_encoding_2d is
            variable v_qubits_binary_encoding_2d : t_qubits_binary_encoding_2d;
        begin
            v_qubits_binary_encoding_2d := (others => 1);
            for i in 1 to QUBITS_CNT-1 loop
                v_qubits_binary_encoding_2d(i) := i;
            end loop;
            return v_qubits_binary_encoding_2d;
        end function;
        constant QUBIT_ID : t_qubits_binary_encoding_2d := feedfwd_controller_binary_encoding(QUBITS_CNT);
        signal flag_invalid_qubit_id : std_logic := '0';

        -- Calculate total delay before this module
        impure function get_photon_hv_synch_delay (
            constant DELAY_PHOTON_1 : real;
            constant DELAY_PHOTON_2 : real
        ) return natural is
            constant CLK_PERIOD_SAMPLCLK_NS : real := 
                (1.0/real(CLK_HZ) * 1.0e9);
            constant TIME_DIFFERENCE_PHOTONS_NS_ABS : real := 
                abs(DELAY_PHOTON_1 - DELAY_PHOTON_2);
        begin
            return natural( ceil(TIME_DIFFERENCE_PHOTONS_NS_ABS / CLK_PERIOD_SAMPLCLK_NS) );
        end function;
        constant PHOTON_HV_SYNCHRONIZATION_DELAY : t_periods_q_2d := (
            get_photon_hv_synch_delay(PHOTON_6H_DELAY_NS, PHOTON_6V_DELAY_NS), -- index 5
            get_photon_hv_synch_delay(PHOTON_5H_DELAY_NS, PHOTON_5V_DELAY_NS), -- index 4
            get_photon_hv_synch_delay(PHOTON_4H_DELAY_NS, PHOTON_4V_DELAY_NS), -- index 3
            get_photon_hv_synch_delay(PHOTON_3H_DELAY_NS, PHOTON_3V_DELAY_NS), -- index 2
            get_photon_hv_synch_delay(PHOTON_2H_DELAY_NS, PHOTON_2V_DELAY_NS), -- index 1
            get_photon_hv_synch_delay(PHOTON_1H_DELAY_NS, PHOTON_1V_DELAY_NS)  -- index 0 (never used)
        );


        -- Qubit skipping part: Use Floor this time
        constant CLK_PERIODS_SKIP : natural :=
                natural( ceil(real(DISCARD_QUBITS_TIME_NS) / CLK_PERIOD_NS) );
        signal slv_counter_skip_qubits : std_logic_vector(integer(ceil(log2(real(CLK_PERIODS_SKIP+1)))) downto 0) := (others => '0');


        -- Ceil function may increase the difference from the target and generated delay
        impure function correct_periods (
            constant CLK_PERIODS : natural;
            constant CLK_PERIOD_NS : real;
            constant REAL_TARGET_VALUE : real
        ) return natural is
            variable v_periods_plus_one : real := CLK_PERIOD_NS * real(CLK_PERIODS+1);
            variable v_periods_plus_one_abserror : real;

            variable v_periods_actual : real := CLK_PERIOD_NS * real(CLK_PERIODS);
            variable v_periods_actual_abserror : real;

            variable v_periods_minus_one : real := CLK_PERIOD_NS * real(CLK_PERIODS-1);
            variable v_periods_minus_one_abserror : real;
        begin
            -- Compare differences from each case and select the minimum error
            if REAL_TARGET_VALUE < v_periods_plus_one then
                v_periods_plus_one_abserror := v_periods_plus_one - REAL_TARGET_VALUE;
            else
                v_periods_plus_one_abserror := REAL_TARGET_VALUE - v_periods_plus_one;
            end if;

            if REAL_TARGET_VALUE < v_periods_actual then
                v_periods_actual_abserror := v_periods_actual - REAL_TARGET_VALUE;
            else
                v_periods_actual_abserror := REAL_TARGET_VALUE - v_periods_actual;
            end if;

            if REAL_TARGET_VALUE < v_periods_minus_one then
                v_periods_minus_one_abserror := v_periods_minus_one - REAL_TARGET_VALUE;
            else
                v_periods_minus_one_abserror := REAL_TARGET_VALUE - v_periods_minus_one;
            end if;

            -- If CLK_PERIODS+1 gives less error
            if v_periods_plus_one_abserror < v_periods_actual_abserror then
                if v_periods_plus_one_abserror < v_periods_minus_one_abserror then
                    return CLK_PERIODS + 1;
                end if;
            end if;

            -- If CLK_PERIODS-1 gives less error
            if v_periods_minus_one_abserror < v_periods_actual_abserror then
                if v_periods_minus_one_abserror < v_periods_plus_one_abserror then
                    return CLK_PERIODS - 1;
                end if;
            end if;

            -- Otherwise keep ceil value
            return CLK_PERIODS;

        end function;

        -- Compare which photon arrives the second
        impure function get_largest_delay (
            constant REAL_DELAY_A_ABS : real;
            constant REAL_DELAY_B_ABS : real
        ) return real is
        begin
            -- Faster = higher number (abs)
            if abs(REAL_DELAY_A_ABS) < abs(REAL_DELAY_B_ABS) then
                return abs(REAL_DELAY_B_ABS);
            else
                return abs(REAL_DELAY_A_ABS);
            end if;
        end function;

        -- MAX 6 QUBITS
        constant MAX_PERIODS_CORR : t_periods_q_2d := (
            correct_periods(MAX_PERIODS(5), CLK_PERIOD_NS, get_largest_delay(PHOTON_6H_DELAY_NS, PHOTON_6V_DELAY_NS)),
            correct_periods(MAX_PERIODS(4), CLK_PERIOD_NS, get_largest_delay(PHOTON_5H_DELAY_NS, PHOTON_5V_DELAY_NS)),
            correct_periods(MAX_PERIODS(3), CLK_PERIOD_NS, get_largest_delay(PHOTON_4H_DELAY_NS, PHOTON_4V_DELAY_NS)),
            correct_periods(MAX_PERIODS(2), CLK_PERIOD_NS, get_largest_delay(PHOTON_3H_DELAY_NS, PHOTON_3V_DELAY_NS)),
            correct_periods(MAX_PERIODS(1), CLK_PERIOD_NS, get_largest_delay(PHOTON_2H_DELAY_NS, PHOTON_2V_DELAY_NS)),
            correct_periods(MAX_PERIODS(0), CLK_PERIOD_NS, get_largest_delay(PHOTON_1H_DELAY_NS, PHOTON_1V_DELAY_NS))
        );


        -- NEW
        -- Gray Counter
        -- Pick the largest delay value to calculate the width of slv
        function get_max_delay_max_periods (
            INT_MAX_PERIODS : t_periods_q_2d
        ) return natural is
            variable v_max_delay : natural := 0;
        begin
            for i in 0 to 6-1 loop
                if INT_MAX_PERIODS(i) > v_max_delay then
                    v_max_delay := INT_MAX_PERIODS(i);
                end if;
            end loop;

            return v_max_delay;
        end function;
        constant MAX_DELAY_NS : natural := get_max_delay_max_periods(MAX_PERIODS); -- NEW
        constant MAX_DELAY_NS_CNTR_BITWIDTH : natural := integer(ceil(log2(real(MAX_DELAY_NS+1)))); -- NEW

        -- NEW
        function intbin_to_slvgray (
            int_bin_number : integer;
            INT_WIDTH : positive
        ) return std_logic_vector is
            variable v_slv_bin_number : std_logic_vector(INT_WIDTH-1 downto 0) := (others => '0');
            variable v_shifted_right_by_one : std_logic_vector(INT_WIDTH-1 downto 0) := (others => '0');
            variable v_bin_xored_with_shifted_bin : std_logic_vector(INT_WIDTH-1 downto 0) := (others => '0');
        begin
            v_slv_bin_number := std_logic_vector(to_unsigned(int_bin_number, INT_WIDTH));
            v_shifted_right_by_one := '0' & v_slv_bin_number(INT_WIDTH-1 downto 1);

            for i in 0 to INT_WIDTH-1 loop
                v_bin_xored_with_shifted_bin(i) := v_slv_bin_number(i) xor v_shifted_right_by_one(i);
            end loop;

            return v_bin_xored_with_shifted_bin;
        end function;
        signal slv_main_counter_bin      : std_logic_vector(MAX_DELAY_NS_CNTR_BITWIDTH-1 downto 0) := (others => '0'); -- NEW
        signal int_main_counter_bin      : integer := 0; -- NEW
        signal slv_main_counter_bin_incr : std_logic_vector(MAX_DELAY_NS_CNTR_BITWIDTH-1 downto 0) := (others => '0'); -- NEW
        signal int_main_counter_bin_incr : integer := 0; -- NEW
        signal slv_main_counter_gray     : std_logic_vector(MAX_DELAY_NS_CNTR_BITWIDTH-1 downto 0) := (others => '0'); -- NEW
        signal int_main_counter_gray     : integer := 0; -- NEW

        -- NEW
        function intgray_to_slvbin (
            int_gray_number : integer;
            INT_WIDTH : natural
        ) return std_logic_vector is
            variable v_slv_gray_number : std_logic_vector(INT_WIDTH-1 downto 0) := (others => '0');
            variable v_xored_accumulated : std_logic_vector(INT_WIDTH-1 downto 0) := (others => '0');
        begin
            v_slv_gray_number := std_logic_vector(to_unsigned(int_gray_number, INT_WIDTH));
            for i in 0 to INT_WIDTH-1 loop
                for j in i to INT_WIDTH-1 loop
                    v_xored_accumulated(i) := v_xored_accumulated(i) xor v_slv_gray_number(j);
                end loop;
            end loop;

            return v_xored_accumulated;
        end function;


        -- NEW
        type t_slv_periods_q_2d is array (6-1 downto 0) of std_logic_vector(MAX_DELAY_NS_CNTR_BITWIDTH-1 downto 0);
        function conv_max_periods_intbin_to_slvgray (
            MAX_PERIODS_2D : t_periods_q_2d;
            INT_WIDTH : integer
        ) return t_slv_periods_q_2d is
            variable v_gray_periods_q_2d : t_slv_periods_q_2d := (others => (others => '0'));
        begin
            for i in 0 to QUBITS_CNT-1 loop
                v_gray_periods_q_2d(i) := intbin_to_slvgray(MAX_PERIODS_2D(i), INT_WIDTH);
            end loop;

            return v_gray_periods_q_2d;
        end function;
        constant INT_MAX_PERIODS_GRAY_2D : t_slv_periods_q_2d := conv_max_periods_intbin_to_slvgray(MAX_PERIODS, MAX_DELAY_NS_CNTR_BITWIDTH); -- NEW


        -- NEW
        -- Galois Counter
        -- More irreducible primitive polynomials: 
        -- https://link.springer.com/content/pdf/bbm%3A978-1-4615-1509-8%2F1.pdf
        function incr_galois_cntr (
            int_galois_cntr_feedback : natural;
            SYMBOL_WIDTH : positive;
            INT_PRIMPOL : positive
        ) return std_logic_vector is
            variable v_slv_galois_cntr_feedback : std_logic_vector(SYMBOL_WIDTH-1 downto 0) := (others => '0');
            variable v_slv_galois_cntr : std_logic_vector(SYMBOL_WIDTH-1 downto 0) := (others => '0');
            variable v_slv_primpol : std_logic_vector(SYMBOL_WIDTH downto 0) := std_logic_vector(to_unsigned(INT_PRIMPOL, SYMBOL_WIDTH+1));
        begin
            -- Convert int to slv
            v_slv_galois_cntr_feedback := std_logic_vector(to_unsigned(int_galois_cntr_feedback, SYMBOL_WIDTH));
            
            -- Calculate a new iteration
            v_slv_galois_cntr(SYMBOL_WIDTH-1 downto 0) 
                := v_slv_galois_cntr_feedback(SYMBOL_WIDTH-2 downto 0) & '0';
            if v_slv_galois_cntr_feedback(SYMBOL_WIDTH-1) = '1' then
                v_slv_galois_cntr(SYMBOL_WIDTH-1 downto 0) 
                    := v_slv_galois_cntr_feedback(SYMBOL_WIDTH-2 downto 0) 
                        & '0' xor v_slv_primpol(SYMBOL_WIDTH-1 downto 0);
            end if;

            return v_slv_galois_cntr;
        end function;
        constant GF_SEED : positive := 1; -- NEW
        signal slv_main_counter_galois : std_logic_vector(MAX_DELAY_NS_CNTR_BITWIDTH-1 downto 0) := std_logic_vector(to_unsigned(GF_SEED, MAX_DELAY_NS_CNTR_BITWIDTH)); -- NEW
        signal slv_main_counter_galois_feedback : std_logic_vector(MAX_DELAY_NS_CNTR_BITWIDTH-1 downto 0) := std_logic_vector(to_unsigned(GF_SEED, MAX_DELAY_NS_CNTR_BITWIDTH)); -- NEW

        -- Assign a primitive polynomial based on counter width
        function get_int_primpol (
            SYMBOL_WIDTH : positive
        ) return positive is
            variable v_int_primpol : positive := 7;
        begin
            -- Set primitive polynomials for these bit widths
            if SYMBOL_WIDTH = 2 then v_int_primpol := 7; end if;  -- 0b111 OK
            if SYMBOL_WIDTH = 3 then v_int_primpol := 13; end if; -- 0b1101 OK
            if SYMBOL_WIDTH = 4 then v_int_primpol := 25; end if; -- 0b11001 OK
            if SYMBOL_WIDTH = 5 then v_int_primpol := 41; end if; -- 0b101001 perfect
            if SYMBOL_WIDTH = 6 then v_int_primpol := 97; end if; -- 0b1100001 OK
            if SYMBOL_WIDTH = 7 then v_int_primpol := 137; end if;-- 0b10001001 perfect
            if SYMBOL_WIDTH = 8 then v_int_primpol := 425; end if;-- 0b110101001 suboptimal
            if SYMBOL_WIDTH = 9 then v_int_primpol := 529; end if;-- 0b1000010001 perfect
            if SYMBOL_WIDTH = 10 then v_int_primpol := 1033; end if; -- 0b10000001001 perfect
            if SYMBOL_WIDTH = 11 then v_int_primpol := 2053; end if; -- 0b100000000101 perfect
            if SYMBOL_WIDTH = 12 then v_int_primpol := 6289; end if; -- 0b1100010010001 suboptimal
            if SYMBOL_WIDTH = 13 then v_int_primpol := 8357; end if; -- 0b10000010100101 suboptimal
            if SYMBOL_WIDTH = 14 then v_int_primpol := 16553; end if;-- 0b100000010101001 suboptimal
            if SYMBOL_WIDTH = 15 then v_int_primpol := 32785; end if;-- 0b1000000000010001 perfect
            if SYMBOL_WIDTH = 16 then v_int_primpol := 66193; end if;-- 0b10000001010010001 suboptimal
            if SYMBOL_WIDTH = 17 then v_int_primpol := 131137; end if;  -- 0b100000000001000001 perfect
            if SYMBOL_WIDTH = 18 then v_int_primpol := 262273; end if;  -- 0b1000000000010000001 perfect
            if SYMBOL_WIDTH = 19 then v_int_primpol := 524377; end if;  -- 0b10000000000001011001 bad
            if SYMBOL_WIDTH = 20 then v_int_primpol := 1048585; end if; -- 0b100000000000000001001 perfect
            if SYMBOL_WIDTH = 21 then v_int_primpol := 2097157; end if; -- 0b1000000000000000000101 perfect

            -- Else, let the HW generation fail
            if SYMBOL_WIDTH < 2 then v_int_primpol := 1; end if;
            if SYMBOL_WIDTH > 21 then v_int_primpol := 1; end if;
            return v_int_primpol;
        end function;

        constant INT_PRIM_POL : positive := get_int_primpol(MAX_DELAY_NS_CNTR_BITWIDTH); -- NEW

        -- NEW
        function int_to_slvgalois (
            INT_TARGET_VALUE : natural;
            INT_SYMBOL_WIDTH : positive;
            INT_PRIMPOL : positive
        ) return std_logic_vector is
            variable v_slv_act_galois_cntr : std_logic_vector(INT_SYMBOL_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(1, INT_SYMBOL_WIDTH)); -- NEW
        begin
            -- if INT_TARGET_VALUE = 0 then return the first valid GF element (=v_slv_act_galois_cntr, which is 1)
            if INT_TARGET_VALUE > 0 then
                -- else if, for example, INT_TARGET_VALUE = 1, then increment v_slv_act_galois_cntr(=1) once (then then output will be 2)
                for i in 1 to INT_TARGET_VALUE-1 loop
                    v_slv_act_galois_cntr := incr_galois_cntr(to_integer(unsigned(v_slv_act_galois_cntr)), INT_SYMBOL_WIDTH, INT_PRIMPOL); -- NEW
                end loop;
            end if;
            return v_slv_act_galois_cntr;
        end function;


        -- NEW
        -- Counter MAX periods for each qubit (REVISE!)
        function get_max_periods_diff (
            INT_MAX_PERIODS : t_periods_q_2d
        ) return t_periods_q_2d is
            variable v_max_periods_diff_2d : t_periods_q_2d := (others => 0);
        begin
            -- Get the time difference between two qubits
            for i in 0 to 6-1 loop
                if i = 1 then
                    report "INT_MAX_PERIODS(i) = " 
                        & integer'image(INT_MAX_PERIODS(i));
                    v_max_periods_diff_2d(i)
                        := INT_MAX_PERIODS(i);
                elsif i > 1 then
                    report "INT_MAX_PERIODS(i) - INT_MAX_PERIODS(i-1) = " 
                        & integer'image(INT_MAX_PERIODS(i)) & " - " & integer'image(INT_MAX_PERIODS(i-1))
                        & " = " & integer'image(INT_MAX_PERIODS(i) - INT_MAX_PERIODS(i-1));
                    v_max_periods_diff_2d(i)
                        := INT_MAX_PERIODS(i) - INT_MAX_PERIODS(i-1);
                end if;
            end loop;
            -- * Fatal: (vsim-3421) Value -109 is out of range 0 to 2147483647.
            return v_max_periods_diff_2d;
        end function;
         -- NEW
        -- function get_max_periods_diff_galois (
        --     INT_MAX_PERIODS : t_periods_q_2d
        -- ) return t_periods_q_2d is
        --     variable v_max_periods_galois_diff_2d : t_periods_q_2d := (others => 0);
        --     variable v_max_periods_galois_2d : t_periods_q_2d := (others => 0); -- Otherwise Error "Value 0 is out of range 1 to 2147483647"
        -- begin
        --     -- Get the time difference between two qubits
        --     v_max_periods_galois_diff_2d := get_max_periods_diff(INT_MAX_PERIODS);

        --     for i in 0 to QUBITS_CNT-1 loop
        --         if i > 0 then
        --             v_max_periods_galois_2d(i) := to_integer(unsigned(int_to_slvgalois(v_max_periods_galois_diff_2d(i), INT_PRIM_POL)));
        --         end if;
        --     end loop;
        --     return v_max_periods_galois_2d;
        -- end function;

        constant MAX_PERIODS_DIFF : t_periods_q_2d := get_max_periods_diff(MAX_PERIODS); -- NEW
        constant MAX_PERIODS_DIFF_MAXDELAY : natural := get_max_delay_max_periods(MAX_PERIODS_DIFF); -- NEW
        constant MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH : positive := integer(ceil(log2(real(MAX_PERIODS_DIFF_MAXDELAY+1)))); -- NEW

        -- constant MAX_PERIODS_DIFF_GALOIS : t_periods_q_2d := get_max_periods_diff_galois(MAX_PERIODS); -- NEW
        constant INT_PRIM_POL_DIFF : positive := get_int_primpol(MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH); -- NEW

        signal slv_new_main_cntr : integer := 0; -- NEW
        signal slv_new_main_galois_cntr_two_qubits : std_logic_vector(MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH-1 downto 0) := (others => '0'); -- NEW
        type t_galois_cntr_2d is array (QUBITS_CNT-1 downto 1) of std_logic_vector(MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH-1 downto 0); -- NEW
        signal slv_new_main_galois_cntr_2d : t_galois_cntr_2d := (others => (others => '0'));
    begin


        ----------------------------
        -- Feedforward Controller --
        ----------------------------
        actual_qubit <= slv_actual_qubit;
        slv_qubits_sampled <= qubits_sampled;
        o_feedforward_pulse <= slv_o_feedforward_pulse;
        o_feedforward_pulse_trigger <= slv_o_feedforward_pulse_trigger;
        o_unsuccessful_qubits <= slv_unsuccessful_qubits xor slv_unsuccessful_qubits_two_qubits; -- Xor will not be implemented but this is to prevent warnings in compilation
        feedfwd_success_flag <= sl_feedfwd_success_flag;
        feedfwd_success_done <= sl_feedfwd_success_done;
        qubit_buffer <= slv_qubit_buffer_2d;
        time_stamp_buffer <= slv_time_stamp_buffer_2d;
        -- state_feedfwd <= to_integer(unsigned(std_logic_vector(to_unsigned(actual_state_feedfwd, QUBITS_CNT)) xor std_logic_vector(to_unsigned(actual_state_feedfwd_two_qubits, QUBITS_CNT)))); -- One of them is constantly zero

        -- Scalable hardware description of a FSM-like logic: more than 2 qubits
        gen_feedfwd_more_qubits : if (QUBITS_CNT > 2) generate

            state_feedfwd <= slv_state_feedforward; -- NEW

            int_main_counter_gray <= to_integer(unsigned(slv_main_counter_gray)); -- NEW
            slv_main_counter_bin <= intgray_to_slvbin(int_main_counter_gray, MAX_DELAY_NS_CNTR_BITWIDTH);  -- NEW
            int_main_counter_bin <= to_integer(unsigned(slv_main_counter_bin));  -- NEW
            slv_main_counter_bin_incr <= std_logic_vector(unsigned(slv_main_counter_bin) + "1");  -- NEW
            int_main_counter_bin_incr <= to_integer(unsigned(slv_main_counter_bin_incr));  -- NEW
            proc_fsm_feedforward : process(clk)
                variable v_int_precalculate_delay_qx_1 : t_periods_q_2d := (others => 0);
                variable v_int_precalculate_delay_qx_2 : t_periods_q_2d := (others => 0);
                variable v_int_precalculate_delay_qx_3 : t_periods_q_2d := (others => 0);
            begin
                if rising_edge(clk) then
                    -- Default values
                    actual_qubit_valid <= '0';
                    -- actual_state_feedfwd <= int_state_feedfwd; -- NEW (commented)
                    time_stamp_counter_overflow <= '0';
                    sl_feedfwd_success_done <= '0';
                    slv_unsuccessful_qubits <= (others => '0');
                    eom_ctrl_pulse_ready_p1 <= eom_ctrl_pulse_ready;

                    -- int_main_counter <= int_main_counter + 1;
                    -- slv_main_counter_gray <= intbin_to_slvgray(int_main_counter_bin_incr, MAX_DELAY_NS_CNTR_BITWIDTH);  -- NEW
                    -- slv_new_main_cntr <= slv_new_main_cntr + 1; -- NEW

                    -- Galois Counter
                    -- slv_main_counter_galois <= incr_galois_cntr(to_integer(unsigned(slv_main_counter_galois)), MAX_DELAY_NS_CNTR_BITWIDTH, INT_PRIM_POL); -- NEW
                    -- slv_new_main_galois_cntr_two_qubits <= incr_galois_cntr(to_integer(unsigned(slv_new_main_galois_cntr_two_qubits)), MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF); -- NEW
                    for i in 1 to QUBITS_CNT-1 loop
                        slv_new_main_galois_cntr_2d(i) <= incr_galois_cntr(to_integer(unsigned(slv_new_main_galois_cntr_2d(i))), MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF); -- NEW
                    end loop;

                    -- Time Stamp counter always inscrements each clock cycle and overflows
                    -- If 1 cycle = 5 ns: 5*10^(-9) sec * 2^(28*2) cycles = overflow after every 42.949673 sec
                    uns_actual_time_stamp_counter <= uns_actual_time_stamp_counter + 1;

                    -- NEW
                    if qubits_sampled_valid(0) = '1' and rst = '0' then
                        sl_time_stamp_counter_counter_en <= '1';
                    end if;

                    -- NEW
                    -- Time Stamp counter always inscrements each clock cycle and overflows
                    -- If 1 cycle = 10 ns: 10*10^(-9) sec * 2^32 cycles = overflow after every 42.949673 sec
                    if (sl_time_stamp_counter_counter_en = '1' or qubits_sampled_valid(0) = '1') and rst = '0' then
                        uns_actual_time_stamp_counter <= uns_actual_time_stamp_counter + 1;
                    end if;

                    -- Qubit skipping
                    if to_integer(unsigned(slv_counter_skip_qubits)) /= CLK_PERIODS_SKIP then
                        if sl_feedfwd_success_flag = '1' then
                            slv_counter_skip_qubits <= std_logic_vector(unsigned(slv_counter_skip_qubits) + "1");
                        end if;
                    end if;

                    -- If success from photon 4, then let this state transmit the pulse, otherwise wait for new clicks
                    if sl_feedfwd_success_flag = '1' then

                        -- Send 1 clock cycle long pulse as soon as the output PCD control pulse generation starts
                        if eom_ctrl_pulse_ready = '0' and eom_ctrl_pulse_ready_p1 = '1' then
                            sl_feedfwd_success_done <= '1';
                        end if;

                        -- Latch PCD output pulse falling edge event
                        if eom_ctrl_pulse_ready = '1' and eom_ctrl_pulse_ready_p1 = '0' then
                            eom_ctrl_pulse_fedge_latched <= '1';
                        end if;

                        -- Wait until PCD pulse has been transmitted and all qubits from previous clusters states have been skipped
                        if eom_ctrl_pulse_fedge_latched = '1' and to_integer(unsigned(slv_counter_skip_qubits)) = CLK_PERIODS_SKIP then
                            sl_feedfwd_success_flag <= '0';
                            eom_ctrl_pulse_fedge_latched <= '0';
                            slv_counter_skip_qubits <= std_logic_vector(to_unsigned(0, slv_counter_skip_qubits'length));
                        end if;
                    end if;


                    --------------------------
                    -- FIRST qubit detected --
                    --------------------------
                    -- if int_state_feedfwd = 0 then
                    if slv_state_feedforward(0) = '1' then -- NEW
                        -- int_main_counter <= 0;
                        -- slv_new_main_cntr <= 0; -- NEW
                        -- slv_main_counter_gray <= (others => '0'); -- NEW
                        -- slv_main_counter_galois <= std_logic_vector(to_unsigned(GF_SEED, MAX_DELAY_NS_CNTR_BITWIDTH)); -- NEW
                        -- slv_new_main_galois_cntr_two_qubits <= int_to_slvgalois(0, MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF); -- NEW
                        slv_new_main_galois_cntr_2d(1) <= int_to_slvgalois(0, MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF); -- NEW

                        if sl_feedfwd_success_flag = '0' then

                            -- Forward the given pulse defined in INT_FEEDFWD_PROGRAMMING
                            if slv_qubits_sampled(0) = '1' then
                                -- Horizontal
                                slv_o_feedforward_pulse(0) <= SLV_FEEDFWD_PROGRAMMING(QUBITS_CNT*2-1);
                            elsif slv_qubits_sampled(1) = '1' then
                                -- Vertical
                                slv_o_feedforward_pulse(0) <= SLV_FEEDFWD_PROGRAMMING(QUBITS_CNT*2-2);
                            end if;

                            -- After waiting, only then continue the control operation, otherwise qubit 1 will interfere with yet uprocessed data from qubit 4
                            -- slv_actual_qubit <= slv_qubits_sampled(QUBITS_CNT*2-1 - 0*2 downto QUBITS_CNT*2-1 - 0*2-1);
                            -- slv_qubit_buffer_2d(0) <= slv_qubits_sampled(QUBITS_CNT*2-1 - 0*2 downto QUBITS_CNT*2-1 - 0*2-1);
                            slv_actual_qubit <= slv_qubits_sampled(1 downto 0);
                            slv_qubit_buffer_2d(0) <= slv_qubits_sampled(1 downto 0);

                            -- Detect Qubit 1 and proceed to Qubit 2
                            -- Reset: Instead of resetting every signal in the FSM, the approach is
                            -- to prevent the FSM from proceeding from state 1 to next states
                            -- The reset capabilities:
                            --      - Prevents FSM to react to input when on state 1
                            -- Detect Qubit 1 and proceed to Qubit 2
                            -- if qubits_sampled_valid(0) = '1' and rst = '0' then
                            if qubits_sampled_valid(0) = '1' then
                                actual_qubit_valid <= '1';
                                slv_time_stamp_buffer_2d(0) -- Higher bits of the counter (to count beyond ~0.8s)
                                    <= std_logic_vector(uns_actual_time_stamp_counter(uns_actual_time_stamp_counter'high downto 28));
                                slv_time_stamp_buffer_2d(1)
                                    <= std_logic_vector(uns_actual_time_stamp_counter(st_transaction_data_max_width));
                                -- Next state
                                -- int_state_feedfwd <= int_state_feedfwd + 1;
                                -- int_state_feedfwd <= 1; -- NEW
                                slv_state_feedforward(0) <= '0'; -- NEW
                                slv_state_feedforward(1) <= '1'; -- NEW

                                -- slv_new_main_galois_cntr_two_qubits <= int_to_slvgalois(0, MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF); -- NEW
                                -- slv_new_main_cntr <= 0; -- NEW
                            end if;

                        end if;
                    end if;

                    -----------------------------------
                    -- INTERMEDIATE qubit/s detected --
                    -----------------------------------
                    -- Create parallel threads, activate one based on the actual state
                    for i in 1 to QUBITS_CNT-2 loop
                        -- if QUBIT_ID(i) = int_state_feedfwd then
                        if slv_state_feedforward(QUBIT_ID(i)) = '1' then

                            -- Forward the given pulse defined in INT_FEEDFWD_PROGRAMMING
                            if slv_qubits_sampled(QUBIT_ID(i)*2+1) = '1' then
                                -- Horizontal
                                slv_o_feedforward_pulse(0) <= SLV_FEEDFWD_PROGRAMMING((QUBITS_CNT-i)*2-1);
                            elsif slv_qubits_sampled(QUBIT_ID(i)*2) = '1' then
                                -- Vertical
                                slv_o_feedforward_pulse(0) <= SLV_FEEDFWD_PROGRAMMING((QUBITS_CNT-i)*2-2);
                            end if;

                            slv_actual_qubit <= slv_qubits_sampled(QUBIT_ID(i)*2+1 downto QUBIT_ID(i)*2);
                            slv_qubit_buffer_2d(QUBIT_ID(i)) <= slv_qubits_sampled(QUBIT_ID(i)*2+1 downto QUBIT_ID(i)*2);

                            -- If the counter has reached the max delay, don't ask and reset it and assess the next state
                            -- if int_main_counter = MAX_PERIODS(QUBIT_ID(i)) -1 then
                            -- if slv_main_counter_gray = intbin_to_slvgray(v_int_precalculate_delay_qx_1(QUBIT_ID(i)), MAX_DELAY_NS_CNTR_BITWIDTH) then -- NEW

                            -- v_int_precalculate_delay_qx_1(QUBIT_ID(i)) := MAX_PERIODS(QUBIT_ID(i)) -1; -- NEW
                            -- if slv_main_counter_galois = int_to_slvgalois(v_int_precalculate_delay_qx_1(QUBIT_ID(i)), MAX_DELAY_NS_CNTR_BITWIDTH, INT_PRIM_POL) then -- NEW

                            v_int_precalculate_delay_qx_1(QUBIT_ID(i)) := MAX_PERIODS_DIFF(QUBIT_ID(i)); -- NEW
                            if slv_new_main_galois_cntr_2d(QUBIT_ID(i)) = int_to_slvgalois(v_int_precalculate_delay_qx_1(QUBIT_ID(i)), MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF) then -- NEW

                                -- Detect Qubit 3 and proceed to Qubit 4, sample time stamp
                                -- if qubits_sampled_valid(QUBITS_CNT-1-QUBIT_ID(i)) = '1' then
                                if qubits_sampled_valid(QUBIT_ID(i)) = '1' then
                                    actual_qubit_valid <= '1';
                                    slv_time_stamp_buffer_2d(QUBIT_ID(i)+1) 
                                        <= std_logic_vector(uns_actual_time_stamp_counter(st_transaction_data_max_width));
                                    -- int_state_feedfwd <= int_state_feedfwd + 1;
                                    -- int_state_feedfwd <= i+1; -- NEW

                                    slv_state_feedforward(i) <= '0'; -- NEW
                                    slv_state_feedforward(i+1) <= '1'; -- NEW

                                    -- slv_new_main_cntr <= 0; -- NEW
                                    -- slv_new_main_galois_cntr_two_qubits <= int_to_slvgalois(0, MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF); -- NEW
                                    slv_new_main_galois_cntr_2d(QUBIT_ID(i+1)) <= int_to_slvgalois(0, MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF); -- NEW
                                else
                                    slv_state_feedforward(i) <= '0'; -- NEW
                                    slv_state_feedforward(0) <= '1'; -- NEW

                                    -- int_state_feedfwd <= 0;
                                    slv_unsuccessful_qubits(QUBIT_ID(i)) <= '1';
                                end if;
                            end if;

                            -- Look for detection before the last counter iteration (counter the data skew)
                            for u in 0 to 0 loop
                                -- if int_main_counter = MAX_PERIODS(QUBIT_ID(i)) -2 -u then
                                -- if slv_main_counter_gray = intbin_to_slvgray(v_int_precalculate_delay_qx_2(QUBIT_ID(i)), MAX_DELAY_NS_CNTR_BITWIDTH) then -- NEW

                                -- v_int_precalculate_delay_qx_2(QUBIT_ID(i)) := MAX_PERIODS(QUBIT_ID(i)) -2 -u; -- NEW
                                -- if slv_main_counter_galois = int_to_slvgalois(v_int_precalculate_delay_qx_2(QUBIT_ID(i)), MAX_DELAY_NS_CNTR_BITWIDTH, INT_PRIM_POL) then -- NEW

                                v_int_precalculate_delay_qx_2(QUBIT_ID(i)) := MAX_PERIODS_DIFF(QUBIT_ID(i)) -1 -u; -- NEW
                                if slv_new_main_galois_cntr_2d(QUBIT_ID(i)) = int_to_slvgalois(v_int_precalculate_delay_qx_2(QUBIT_ID(i)), MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF) then -- NEW

                                    -- Detect Qubit 3 earlier and proceed to Qubit 4
                                    -- if qubits_sampled_valid(QUBITS_CNT-1-QUBIT_ID(i)) = '1' then
                                    if qubits_sampled_valid(QUBIT_ID(i)) = '1' then
                                        -- Leave the state early, reset counter, sample time stamp
                                        actual_qubit_valid <= '1';
                                        slv_time_stamp_buffer_2d(QUBIT_ID(i)+1) 
                                            <= std_logic_vector(uns_actual_time_stamp_counter(st_transaction_data_max_width));
                                        -- int_state_feedfwd <= int_state_feedfwd + 1;
                                        -- int_state_feedfwd <= i+1; -- NEW

                                        slv_state_feedforward(i) <= '0'; -- NEW
                                        slv_state_feedforward(i+1) <= '1'; -- NEW

                                        -- slv_new_main_cntr <= -1-u; -- NEW
                                        -- slv_new_main_galois_cntr_two_qubits <= int_to_slvgalois(2**MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH-1 -u, MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF); -- NEW
                                        slv_new_main_galois_cntr_2d(QUBIT_ID(i+1)) <= int_to_slvgalois(2**MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH-1 -u, MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF); -- NEW
                                    end if;

                                end if;
                            end loop;
                        end if;
                    end loop;


                    -------------------------
                    -- LAST qubit detected --
                    -------------------------
                    -- if int_state_feedfwd = QUBITS_CNT-1 then
                    if slv_state_feedforward(QUBITS_CNT-1) = '1' then

                        -- Forward the given pulse defined in INT_FEEDFWD_PROGRAMMING
                        if slv_qubits_sampled((QUBITS_CNT-1)*2+1) = '1' then
                            -- Horizontal
                            slv_o_feedforward_pulse(0) <= SLV_FEEDFWD_PROGRAMMING(1);
                        elsif slv_qubits_sampled((QUBITS_CNT-1)*2) = '1' then
                            -- Vertical
                            slv_o_feedforward_pulse(0) <= SLV_FEEDFWD_PROGRAMMING(0);
                        end if;

                        slv_actual_qubit <= slv_qubits_sampled((QUBITS_CNT-1)*2+1 downto (QUBITS_CNT-1)*2);
                        slv_qubit_buffer_2d(QUBITS_CNT-1) <= slv_qubits_sampled((QUBITS_CNT-1)*2+1 downto (QUBITS_CNT-1)*2);

                        -- if int_main_counter = MAX_PERIODS_CORR(QUBITS_CNT-1) -1 then

                        -- if int_main_counter = MAX_PERIODS(QUBITS_CNT-1) -1 then
                        -- if slv_main_counter_gray = intbin_to_slvgray(v_int_precalculate_delay_qx_1(QUBITS_CNT-1), MAX_DELAY_NS_CNTR_BITWIDTH) then -- NEW

                        -- v_int_precalculate_delay_qx_1(QUBITS_CNT-1) := MAX_PERIODS(QUBITS_CNT-1) -1; -- NEW
                        -- if slv_main_counter_galois = int_to_slvgalois(v_int_precalculate_delay_qx_1(QUBITS_CNT-1), MAX_DELAY_NS_CNTR_BITWIDTH, INT_PRIM_POL) then -- NEW

                        v_int_precalculate_delay_qx_1(QUBITS_CNT-1) := MAX_PERIODS_DIFF(QUBITS_CNT-1); -- NEW
                        if slv_new_main_galois_cntr_2d(QUBITS_CNT-1) = int_to_slvgalois(v_int_precalculate_delay_qx_1(QUBITS_CNT-1), MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF) then -- NEW

                            -- Detect Qubit 4 and proceed to Qubit 1, save times tamp
                            -- if qubits_sampled_valid(0) = '1' then
                            if qubits_sampled_valid(QUBITS_CNT-1) = '1' then
                                actual_qubit_valid <= '1';
                                slv_time_stamp_buffer_2d(QUBITS_CNT) 
                                    <= std_logic_vector(uns_actual_time_stamp_counter(st_transaction_data_max_width));
                                -- int_state_feedfwd <= 0;

                                slv_state_feedforward(QUBITS_CNT-1) <= '0'; -- NEW
                                slv_state_feedforward(0) <= '1'; -- NEW

                                sl_feedfwd_success_flag <= '1';
                            else
                                slv_state_feedforward(QUBITS_CNT-1) <= '0'; -- NEW
                                slv_state_feedforward(0) <= '1'; -- NEW

                                slv_unsuccessful_qubits(QUBITS_CNT-1) <= '1';
                            end if;
                        end if;

                        -- Look for detection before the last counter iteration (counter the data skew)
                        for u in 0 to 0 loop
                            -- if int_main_counter = MAX_PERIODS_CORR(QUBITS_CNT-1) -2 -u then

                            -- if int_main_counter = MAX_PERIODS(QUBITS_CNT-1) -2 -u then
                            -- if slv_main_counter_gray = intbin_to_slvgray(v_int_precalculate_delay_qx_2(QUBITS_CNT-1), MAX_DELAY_NS_CNTR_BITWIDTH) then -- NEW

                            -- v_int_precalculate_delay_qx_2(QUBITS_CNT-1) := MAX_PERIODS(QUBITS_CNT-1) -2 -u; -- NEW
                            -- if slv_main_counter_galois = int_to_slvgalois(v_int_precalculate_delay_qx_2(QUBITS_CNT-1), MAX_DELAY_NS_CNTR_BITWIDTH, INT_PRIM_POL) then -- NEW

                            v_int_precalculate_delay_qx_2(QUBITS_CNT-1) := MAX_PERIODS_DIFF(QUBITS_CNT-1) -1 -u; -- NEW
                            if slv_new_main_galois_cntr_2d(QUBITS_CNT-1) = int_to_slvgalois(v_int_precalculate_delay_qx_2(QUBITS_CNT-1), MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF) then -- NEW

                                -- Detect Qubit 4 earlier and proceed to Qubit 1
                                -- if qubits_sampled_valid(0) = '1' then
                                if qubits_sampled_valid(QUBITS_CNT-1) = '1' then
                                    -- Leave the state early, reset counter, sample time stamp
                                    actual_qubit_valid <= '1';
                                    slv_time_stamp_buffer_2d(QUBITS_CNT) 
                                        <= std_logic_vector(uns_actual_time_stamp_counter(st_transaction_data_max_width));
                                    -- int_state_feedfwd <= 0;

                                    slv_state_feedforward(QUBITS_CNT-1) <= '0'; -- NEW
                                    slv_state_feedforward(0) <= '1'; -- NEW

                                    sl_feedfwd_success_flag <= '1';
                                end if;

                            end if;
                        end loop;
                    end if;

                    ---------------------------
                    -- Define invalid states --
                    ---------------------------
                    -- if int_state_feedfwd > QUBITS_CNT-1 then
                        -- Reset the int_state_feedfwd
                        -- int_state_feedfwd <= 0;

                        -- Set the error flag high that the int_state_feedfwd went beyond the maximum allowed value
                        -- flag_invalid_qubit_id <= '1';
                    -- end if;

                end if;
            end process;
        end generate;


        gen_feedfwd_two_qubits : if (QUBITS_CNT = 2) generate

            state_feedfwd <= std_logic_vector(to_unsigned(int_state_feedfwd_two_qubits, QUBITS_CNT) + 1); -- NEW

            proc_fsm_feedfwd_two_qubits : process(clk)
                variable v_int_precalculate_delay_qx_1 : integer := 0;
                variable v_int_precalculate_delay_qx_2 : integer := 0;
            begin
                if rising_edge(clk) then
                    -- Default values
                    actual_qubit_valid <= '0';
                    time_stamp_counter_overflow <= '0';
                    sl_feedfwd_success_done <= '0';
                    slv_unsuccessful_qubits_two_qubits <= (others => '0');
                    eom_ctrl_pulse_ready_p1 <= eom_ctrl_pulse_ready;

                    slv_o_feedforward_pulse <= (others => '0'); -- NEW
                    slv_o_feedforward_pulse_trigger <= (others => '0'); -- NEW
                    
                    -- int_main_counter_two_qubits <= int_main_counter_two_qubits + 1; -- Timing
                    slv_new_main_galois_cntr_two_qubits <= incr_galois_cntr(to_integer(unsigned(slv_new_main_galois_cntr_two_qubits)), MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF); -- NEW
                    
                    -- NEW
                    -- if qubits_sampled_valid(0) = '1' and rst = '0' then
                    --     sl_time_stamp_counter_counter_en <= '1';
                    -- end if;

                    -- NEW
                    -- Time Stamp counter always inscrements each clock cycle and overflows
                    -- If 1 cycle = 10 ns: 10*10^(-9) sec * 2^32 cycles = overflow after every 42.949673 sec
                    -- if (sl_time_stamp_counter_counter_en = '1' or qubits_sampled_valid(0) = '1') and rst = '0' then
                    if rst = '0' then
                        uns_actual_time_stamp_counter <= uns_actual_time_stamp_counter + 1;
                    else
                        uns_actual_time_stamp_counter <= (others => '0');
                    end if;

                    -- Qubit skipping
                    -- #TODO UNCOMMENT THIS
                    -- if to_integer(unsigned(slv_counter_skip_qubits)) /= CLK_PERIODS_SKIP then
                    --     if sl_feedfwd_success_flag = '1' then
                    --         slv_counter_skip_qubits <= std_logic_vector(unsigned(slv_counter_skip_qubits) + "1");
                    --     end if;
                    -- end if;

                    -- If success from photon 4, then let this state transmit the pulse, otherwise wait for new clicks
                    -- if sl_feedfwd_success_flag = '1' then

                    --     -- Send 1 clock cycle long pulse as soon as the output PCD control pulse generation starts
                    --     if eom_ctrl_pulse_ready = '0' and eom_ctrl_pulse_ready_p1 = '1' then
                    --         sl_feedfwd_success_done <= '1';
                    --     end if;

                    --     -- Latch PCD output pulse falling edge event
                    --     if eom_ctrl_pulse_ready = '1' and eom_ctrl_pulse_ready_p1 = '0' then
                    --         eom_ctrl_pulse_fedge_latched <= '1';
                    --     end if;

                    --     -- Wait until PCD pulse has been transmitted and all qubits from previous clusters states have been skipped
                    --     if eom_ctrl_pulse_fedge_latched = '1' and to_integer(unsigned(slv_counter_skip_qubits)) = CLK_PERIODS_SKIP then
                    --         sl_feedfwd_success_flag <= '0';
                    --         eom_ctrl_pulse_fedge_latched <= '0';
                    --         slv_counter_skip_qubits <= std_logic_vector(to_unsigned(0, slv_counter_skip_qubits'length));
                    --     end if;
                    -- end if;

                    -- #TODO UNCOMMENT THIS
                    -- if sl_feedfwd_success_flag = '1' then
                    --     -- Wait until PCD pulse has been transmitted and all qubits from previous clusters states have been skipped
                    --     if to_integer(unsigned(slv_counter_skip_qubits)) = CLK_PERIODS_SKIP then
                    --         sl_feedfwd_success_flag <= '0';

                    --         -- Send 1 clock cycle long pulse
                    --         sl_feedfwd_success_done <= '1';
                    --         slv_counter_skip_qubits <= std_logic_vector(to_unsigned(0, slv_counter_skip_qubits'length));
                    --     end if;
                    -- end if;


                    --------------------------
                    -- FIRST qubit detected --
                    --------------------------
                    if int_state_feedfwd_two_qubits = 0 and rst = '0' then
                        -- int_main_counter_two_qubits <= 0;
                        slv_new_main_galois_cntr_two_qubits <= int_to_slvgalois(0, MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF); -- NEW

                        -- if sl_feedfwd_success_flag = '0' then -- #TODO UNCOMMENT

                            -- Forward the given pulse defined in INT_FEEDFWD_PROGRAMMING
                            if slv_qubits_sampled(0) = '1' then
                                -- Horizontal
                                slv_o_feedforward_pulse(0) <= SLV_FEEDFWD_PROGRAMMING(QUBITS_CNT*2-1);
                                slv_o_feedforward_pulse_trigger(0) <= '1';
                            elsif slv_qubits_sampled(1) = '1' then
                                -- Vertical
                                slv_o_feedforward_pulse(0) <= SLV_FEEDFWD_PROGRAMMING(QUBITS_CNT*2-2);
                                slv_o_feedforward_pulse_trigger(0) <= '1';
                            end if;

                            -- After waiting, only then continue the control operation, otherwise qubit 1 will interfere with yet uprocessed data from qubit 4
                            slv_actual_qubit <= slv_qubits_sampled(1 downto 0);
                            slv_qubit_buffer_2d(0) <= slv_qubits_sampled(1 downto 0);
                            
                            -- 1) NEW
                            if qubits_sampled_valid(0) = '1' then

                            -- 2) NEW                           it's reversed
                            -- if slv_qubits_sampled(1 downto 0) = not(SLV_FEEDFWD_PROGRAMMING(QUBITS_CNT*2-1 downto QUBITS_CNT*2-2)) then -- NEW
                                
                                actual_qubit_valid <= '1';
                                slv_time_stamp_buffer_2d(0) -- Timing -- Higher bits of the counter (to count beyond ~0.8s)
                                    <= std_logic_vector(uns_actual_time_stamp_counter(uns_actual_time_stamp_counter'high downto 28));
                                slv_time_stamp_buffer_2d(1) 
                                    <= std_logic_vector(uns_actual_time_stamp_counter(st_transaction_data_max_width));
                                -- Next state
                                -- int_state_feedfwd_two_qubits <= int_state_feedfwd_two_qubits + 1;
                                int_state_feedfwd_two_qubits <= 1; -- NEW
                            end if;

                        -- end if;
                    end if;

                    -------------------------
                    -- LAST qubit detected --
                    -------------------------
                    if int_state_feedfwd_two_qubits = 1 then

                        -- !!! Do not output any feedforward signal in the last qubit state !!!
                        -- Forward the given pulse defined in INT_FEEDFWD_PROGRAMMING
                        -- if slv_qubits_sampled((QUBITS_CNT-1)*2+1) = '1' then
                        --     -- Horizontal
                        --     slv_o_feedforward_pulse(0) <= SLV_FEEDFWD_PROGRAMMING(1);
                        -- elsif slv_qubits_sampled((QUBITS_CNT-1)*2) = '1' then
                        --     -- Vertical
                        --     slv_o_feedforward_pulse(0) <= SLV_FEEDFWD_PROGRAMMING(0);
                        -- end if;

                        slv_actual_qubit <= slv_qubits_sampled((QUBITS_CNT-1)*2+1 downto (QUBITS_CNT-1)*2);
                        slv_qubit_buffer_2d(QUBITS_CNT-1) <= slv_qubits_sampled((QUBITS_CNT-1)*2+1 downto (QUBITS_CNT-1)*2);

                        -- if int_main_counter = MAX_PERIODS_CORR(QUBITS_CNT-1) -1 then
                        -- if int_main_counter_two_qubits = MAX_PERIODS(QUBITS_CNT-1) -1 then
                        v_int_precalculate_delay_qx_1 := MAX_PERIODS_DIFF(QUBITS_CNT-1); -- NEW
                        if slv_new_main_galois_cntr_two_qubits = int_to_slvgalois(v_int_precalculate_delay_qx_1, MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF) then -- NEW
                            -- Detect Qubit 4 and proceed to Qubit 1, sample time stamp
                            -- if qubits_sampled_valid(0) = '1' then
                            if qubits_sampled_valid(QUBITS_CNT-1) = '1' then
                                actual_qubit_valid <= '1';
                                slv_time_stamp_buffer_2d(QUBITS_CNT) 
                                    <= std_logic_vector(uns_actual_time_stamp_counter(st_transaction_data_max_width));
                                int_state_feedfwd_two_qubits <= 0;
                                sl_feedfwd_success_flag <= '1';
                                sl_feedfwd_success_done <= '1'; -- #TODO REMOVE
                            else
                                int_state_feedfwd_two_qubits <= 0;
                                slv_unsuccessful_qubits_two_qubits(QUBITS_CNT-1) <= '1';
                            end if;
                        end if;

                        -- Look for detection before the last counter iteration (counter the data skew)
                        for u in 0 to 0 loop
                        -- if int_main_counter_two_qubits = MAX_PERIODS(QUBITS_CNT-1) -2 then
                            v_int_precalculate_delay_qx_2 := MAX_PERIODS_DIFF(QUBITS_CNT-1) -1 -u; -- NEW
                            if slv_new_main_galois_cntr_two_qubits = int_to_slvgalois(v_int_precalculate_delay_qx_2, MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF) then -- NEW
                                -- Detect Last Qubit earlier and proceed to Qubit 1
                                if qubits_sampled_valid(QUBITS_CNT-1) = '1' then
                                    -- Leave the state early, reset counter, sample time stamp
                                    actual_qubit_valid <= '1';
                                    slv_time_stamp_buffer_2d(QUBITS_CNT) 
                                        <= std_logic_vector(uns_actual_time_stamp_counter(st_transaction_data_max_width));
                                    int_state_feedfwd_two_qubits <= 0;
                                    sl_feedfwd_success_flag <= '1';
                                    sl_feedfwd_success_done <= '1'; -- #TODO REMOVE
                                end if;
                            end if;
                        end loop;
                    end if;

                    ---------------------------
                    -- Define invalid states --
                    ---------------------------
                    -- if int_state_feedfwd_two_qubits > QUBITS_CNT-1 then
                    --     -- Reset the int_state_feedfwd_two_qubits
                    --     int_state_feedfwd_two_qubits <= 0;

                    --     -- Set the error flag high that the int_state_feedfwd_two_qubits went beyond the maximum allowed value
                    --     flag_invalid_qubit_id <= '1';
                    -- end if;

                end if;
            end process;
        end generate;

    end architecture;