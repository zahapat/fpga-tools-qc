    -- fsm_gflow.vhd: Feed-forward controller

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    use std.textio.all;
    use ieee.std_logic_textio.all;
    
    library lib_src;
    use lib_src.types_pack.all;

    entity fsm_gflow is
        generic (             -- Qubit #:         1 2 3 4
                              -- Polarization:    HVHVHVHV
            INT_FEEDFWD_PROGRAMMING  : integer := 01110101; -- Change the behaviour of the feedforward operation
            RST_VAL                  : std_logic := '1';
            -- SAMPL_CLK_HZ             : real := 250.0e6;       -- You must keep this for acquisition compensation delay between H/V photons
            CLK_HZ                   : real := 250.0e6;       -- Frequency of the FPGA in HZ
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
            INT_NUMBER_OF_GFLOWS     : natural := 9;
            GFLOW_NUMBER             : natural := 0           -- 0 = real-time selection, 1 = Gflow number 1, 2 = Gflow number 2 ...
        );
        port (
            clk : in  std_logic;
            rst : in  std_logic;
            enable : in std_logic;

            i_random_string : in std_logic_vector(QUBITS_CNT-1 downto 0);

            qubits_sampled_valid : in std_logic_vector(QUBITS_CNT-1 downto 0);
            qubits_sampled : in  std_logic_vector((QUBITS_CNT*2)-1 downto 0);

            o_feedforward_pulse : out std_logic_vector(0 downto 0);
            o_feedforward_pulse_trigger : out std_logic_vector(0 downto 0);

            o_unsuccessful_qubits : out std_logic_vector(QUBITS_CNT-1 downto 1);

            feedfwd_success_flag : out std_logic;
            feedfwd_start : out std_logic;
            qubit_buffer : out t_qubit_buffer_2d;
            time_stamp_buffer : out t_time_stamp_buffer_2d;
            random_buffer : out t_random_buffer_2d;
            sx_buffer : out std_logic_vector(QUBITS_CNT-1 downto 0);
            sz_buffer : out std_logic_vector(QUBITS_CNT-1 downto 0);
            actual_gflow_buffer : out std_logic_vector(
                integer(ceil(log2(real(INT_NUMBER_OF_GFLOWS+1))))-1 downto 0);

            state_feedfwd : out std_logic_vector(QUBITS_CNT-1 downto 0);
            actual_qubit_valid : out std_logic;
            actual_qubit : out std_logic_vector(1 downto 0);
            o_sx_next : out std_logic_vector(1 downto 0); -- 2 bits

            time_stamp_counter_overflow : out std_logic;

            eom_ctrl_pulse_ready : in std_logic
        );
    end fsm_gflow;

    architecture rtl of fsm_gflow is

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
        constant SLV_FEEDFWD_PROGRAMMING : std_logic_vector(QUBITS_CNT*2-1 downto 0) := int_to_slv_bitpreserve(INT_FEEDFWD_PROGRAMMING);

        -- Error correction dependence set {Sx, Sz}
        signal slv_o_sx_next : std_logic_vector(o_sx_next'range) := (others => '0');
        signal slv_sx_all_qubits : std_logic_vector(QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_sx_all_qubits_ored : std_logic := '0';

        -- signal slv_o_sz_next : std_logic_vector(o_sz_next'range) := (others => '0');
        signal slv_sx_buffer : std_logic_vector(QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_sz_buffer : std_logic_vector(QUBITS_CNT-1 downto 0) := (others => '0');

        -- The main signal that holds the actual qubit state within the cluster
        signal slv_state_feedforward : std_logic_vector(QUBITS_CNT-1 downto 0) := std_logic_vector(to_unsigned(1, QUBITS_CNT));
        signal slv_state_feedforward_two_qubits : std_logic_vector(QUBITS_CNT-1 downto 0) := std_logic_vector(to_unsigned(1, QUBITS_CNT));

        signal int_state_feedfwd : natural range 0 to QUBITS_CNT-1 := 0;
        signal int_state_feedfwd_two_qubits : natural range 0 to QUBITS_CNT-1 := 0;
        signal actual_state_feedfwd : natural range 0 to QUBITS_CNT-1 := 0;
        signal actual_state_feedfwd_two_qubits : natural range 0 to QUBITS_CNT-1 := 0;

        constant CLK_PERIOD_NS : real := 
            (1.0/real(CLK_HZ) * 1.0e9);
        signal eom_ctrl_pulse_ready_p1 : std_logic := '0';
        signal eom_ctrl_pulse_fedge_latched : std_logic := '0';

        -- Feedforward output EOM signal
        signal slv_o_feedforward_pulse : std_logic_vector(0 downto 0) := (others => '0');
        signal slv_o_feedforward_pulse_trigger : std_logic_vector(0 downto 0) := (others => '0');

        -- Success flag
        signal sl_feedfwd_success_flag : std_logic := '0';

        -- Start flag
        signal sl_feedfwd_start : std_logic := '0';

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

        -- Ensure the random bit string does not update in the middle of the feedforward execution
        signal slv_random_string : std_logic_vector(i_random_string'range) := (others => '0');

        -- Data buffers for verification in PC
        signal slv_qubit_buffer_2d      : t_qubit_buffer_2d := (others => (others => '0'));
        signal slv_time_stamp_buffer_2d : t_time_stamp_buffer_2d := (others => (others => '0'));
        signal slv_random_buffer_2d     : t_random_buffer_2d := (others => (others => '0'));
        

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
            if INT_TARGET_VALUE < 0 then
                for i in 1 to 2**INT_SYMBOL_WIDTH - abs(INT_TARGET_VALUE) loop
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
                        & " = " & integer'image(abs(INT_MAX_PERIODS(i) - INT_MAX_PERIODS(i-1)));
                    v_max_periods_diff_2d(i)
                        := abs(INT_MAX_PERIODS(i) - INT_MAX_PERIODS(i-1));
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


        -- Correct periods to counter rounding error
        impure function correct_periods (
            constant CLK_PERIODS : natural;
            constant CLK_PERIOD_NS : real;
            constant REAL_TARGET_VALUE : real
        ) return integer is
            variable v_periods_plus_one : real := CLK_PERIOD_NS * real(CLK_PERIODS+1);
            variable v_periods_plus_one_abserror : real;

            variable v_periods_actual : real := CLK_PERIOD_NS * real(CLK_PERIODS);
            variable v_periods_actual_abserror : real;

            variable v_periods_minus_one : real := CLK_PERIOD_NS * real(CLK_PERIODS-1);
            variable v_periods_minus_one_abserror : real;
        begin

            -- Compare differences from each case and select the minimum error
            v_periods_plus_one_abserror := abs(v_periods_plus_one - REAL_TARGET_VALUE);
            v_periods_actual_abserror := abs(v_periods_actual - REAL_TARGET_VALUE);
            v_periods_minus_one_abserror := abs(v_periods_minus_one - REAL_TARGET_VALUE);

            -- If CLK_PERIODS+1 gives less error
            if v_periods_plus_one_abserror < v_periods_actual_abserror then
                if v_periods_plus_one_abserror < v_periods_minus_one_abserror then
                    -- return CLK_PERIODS + 1;
                    return +1;
                end if;
            end if;

            -- If CLK_PERIODS-1 gives less error
            if v_periods_minus_one_abserror < v_periods_actual_abserror then
                if v_periods_minus_one_abserror < v_periods_plus_one_abserror then
                    -- return CLK_PERIODS - 1;
                    return -1;
                end if;
            end if;

            -- Otherwise keep ceil value
            -- return CLK_PERIODS;
            return 0;
        end function;

        -- MAX 6 QUBITS
        -- Manually shift the coincidence window to correct rounding errors
        type t_periods_q_corr_2d is array(6-1 downto 0) of integer;
        constant MAX_PERIODS_DIFF_CORR : t_periods_q_corr_2d := (
            0,  -- qubit 6
            0,  -- qubit 5
            0,  -- qubit 4
            +1, -- qubit 3
            -1, -- qubit 2
            0   -- qubit 1 (index 0, never used) => Always 0
        );
        -- constant MAX_PERIODS_DIFF_CORR : t_periods_q_corr_2d := (
        constant MAX_PERIODS_CORR : t_periods_q_corr_2d := (
            correct_periods(MAX_PERIODS_DIFF(5), CLK_PERIOD_NS, abs(PHOTON_6H_DELAY_NS - PHOTON_6V_DELAY_NS)),
            correct_periods(MAX_PERIODS_DIFF(4), CLK_PERIOD_NS, abs(PHOTON_5H_DELAY_NS - PHOTON_5V_DELAY_NS)),
            correct_periods(MAX_PERIODS_DIFF(3), CLK_PERIOD_NS, abs(PHOTON_4H_DELAY_NS - PHOTON_4V_DELAY_NS)),
            correct_periods(MAX_PERIODS_DIFF(2), CLK_PERIOD_NS, abs(PHOTON_3H_DELAY_NS - PHOTON_3V_DELAY_NS)),
            correct_periods(MAX_PERIODS_DIFF(1), CLK_PERIOD_NS, abs(PHOTON_2H_DELAY_NS - PHOTON_2V_DELAY_NS)),
            correct_periods(MAX_PERIODS_DIFF(0), CLK_PERIOD_NS, abs(PHOTON_1H_DELAY_NS - PHOTON_1V_DELAY_NS))
        );


        -- Photon Measurements Notations:
        -- Input Notation   Output Notation
        --     alpha              a=index0
        --     beta               b=index1
        --     gamma              c=index2
        --     delta              d=index3

        -- Sx Mask: [0 A A CB] where:
        --      - A={1,0}: 
        --          if  A == 1  then a else 0;
        --      - CB={00,01,10,11}: 
        --          if CB == 01 then b elif 10 then c else 0;

        -- Sx correction dependence sets for 9 possible Gflows:
        -- Photon        1st  2nd  3rd  4th  Mask[0  A  A  CB]
        -- Gflow(1) Sx    0    a    0    c    ->  0  1  0  10
        -- Gflow(2) Sx    0    0    a    c    ->  0  0  1  10
        -- Gflow(3) Sx    0    0    0    c    ->  0  0  0  10
        -- Gflow(4) Sx    0    0    a    b    ->  0  0  1  01
        -- Gflow(5) Sx    0    a    0    b    ->  0  1  0  01
        -- Gflow(6) Sx    0    0    0    b    ->  0  0  0  01
        -- Gflow(7) Sx    0    a    0    0    ->  0  1  0  00
        -- Gflow(8) Sx    0    0    a    0    ->  0  0  1  00
        -- Gflow(9) Sx    0    0    0    0    ->  0  0  0  00

        -- Sz Mask: [0 C B A] where:
        --      -  C={1,0}: 
        --          if  C == 1 then c else 0;
        --      -  B={1,0}: 
        --          if  B == 1 then b else 0;
        --      -  A={1,0}: 
        --          if  A == 1 then a else 0;

        -- Sz correction dependence sets for 9 possible Gflows:
        -- Photon        1st  2nd  3rd  4th  Mask[0  C  B  A]
        -- Gflow(1) Sz    0    c    0    a    ->  0  1  0  1
        -- Gflow(2) Sz    0    c    0    a    ->  0  1  0  1
        -- Gflow(3) Sz    0    c    0    0    ->  0  1  0  0
        -- Gflow(4) Sz    0    0    b    a    ->  0  0  1  1
        -- Gflow(5) Sz    0    0    b    a    ->  0  0  1  1
        -- Gflow(6) Sz    0    0    b    0    ->  0  0  1  0
        -- Gflow(7) Sz    0    0    0    a    ->  0  0  0  1
        -- Gflow(8) Sz    0    0    0    a    ->  0  0  0  1
        -- Gflow(9) Sz    0    0    0    0    ->  0  0  0  0
        subtype st_sx_mask is std_logic_vector(QUBITS_CNT+1-1 downto 0);
        subtype st_sz_mask is std_logic_vector(QUBITS_CNT-1 downto 0);
        type t_rom_sx_mask is array (INT_NUMBER_OF_GFLOWS-1 downto 0) of st_sx_mask;
        type t_rom_sz_mask is array (INT_NUMBER_OF_GFLOWS-1 downto 0) of st_sz_mask;
        constant ROM_SX_MASK_2D : t_rom_sx_mask := (
            -- 5-bit mask, 9 gflows, bits in each row reversed with respect to the plan above to match indexing
            -- Index:  43210
            --         BCAA0             Mask[0  A  A  CB]
                      "00000", -- Gflow(9) Sx(0  0  0  00)
                      "00100", -- Gflow(8) Sx(0  0  1  00)
                      "00010", -- Gflow(7) Sx(0  1  0  00)
                      "10000", -- Gflow(6) Sx(0  0  0  01)
                      "10010", -- Gflow(5) Sx(0  1  0  01)
                      "10100", -- Gflow(4) Sx(0  0  1  01)
                      "01000", -- Gflow(3) Sx(0  0  0  10)
                      "01100", -- Gflow(2) Sx(0  0  1  10)
                      "01010"  -- Gflow(1) Sx(0  1  0  10), Index 0
        );
        constant ROM_SZ_MASK_2D : t_rom_sz_mask := (
            -- 4-bit mask, 9 gflows, bits in each row reversed with respect to the plan above to match indexing
            -- Index:  3210
            --         ABC0             Mask[0  C  B  A]
                      "0000", -- Gflow(9) Sz(0  0  0  0)
                      "1000", -- Gflow(8) Sz(0  0  0  1)
                      "1000", -- Gflow(7) Sz(0  0  0  1)
                      "0100", -- Gflow(6) Sz(0  0  1  0)
                      "1100", -- Gflow(5) Sz(0  0  1  1)
                      "1100", -- Gflow(4) Sz(0  0  1  1)
                      "0010", -- Gflow(3) Sz(0  1  0  0)
                      "1010", -- Gflow(2) Sz(0  1  0  1)
                      "1010"  -- Gflow(1) Sz(0  1  0  1), Index 0
        );
        signal slv_gen_sx_mask : st_sx_mask := (others => '0');
        signal slv_gen_sz_mask : st_sz_mask := (others => '0');
        signal slv_actual_sx_mask : st_sx_mask := (others => '0');
        signal slv_actual_sz_mask : st_sz_mask := (others => '0');

        -- Gflow Mask generator
        signal slv_cntr_mask : std_logic_vector(actual_gflow_buffer'range) := (others => '0');
        signal slv_actual_gflow_buffer : std_logic_vector(actual_gflow_buffer'range);



        -- Sx correction logic
        impure function sx_correction_logic (
            constant ACTUAL_QUBIT : natural;    -- Qubit number
            actual_qubits : std_logic_vector(QUBITS_CNT*2-1 downto 0);
            previous_qubits : t_qubit_buffer_2d;
            sx : std_logic_vector(QUBITS_CNT-1 downto 0);
            sz : std_logic_vector(QUBITS_CNT-1 downto 0);
            rand : std_logic_vector(QUBITS_CNT-1 downto 0);
            sx_mask : st_sx_mask
        ) return std_logic is
            variable v_masked_actual_qubits : std_logic_vector(actual_qubits'range) := (others => '0');
            variable v_masked_previous_qubits : t_qubit_buffer_2d := (others => (others => '0'));
        begin

            -- Mask qubits
            -- The desired behaviour of the mask is: 
            --      - If mask == '1', copy the value of the measured
            --        qubit to the output 'v_masked_actual_qubits'
            --      - If mask == '0', force the output to be 0.
            --      -> This is AND gate.

            -- Notation:
            --      a => index 0
            --      b => index 1
            --      c => index 2
            --      d => index 3

            -- Sx correction dependence sets for 9 possible Gflows:
            -- Photon        1st  2nd  3rd  4th
            -- Gflow(1) Sx    0    a    0    c
            -- Gflow(2) Sx    0    0    a    c
            -- Gflow(3) Sx    0    0    0    c
            -- Gflow(4) Sx    0    0    a    b
            -- Gflow(5) Sx    0    a    0    b
            -- Gflow(6) Sx    0    0    0    b
            -- Gflow(7) Sx    0    a    0    0
            -- Gflow(8) Sx    0    0    a    0
            -- Gflow(9) Sx    0    0    0    0

            -- The function being performed in each qubit stage:
            -- b_i = b_i' xor r_i
            -- Sx_i = b_i xor Sz_i

            -- 1st qubit: 0 
            -- -> control 2nd qubit 0 or a
            if ACTUAL_QUBIT = 0 then -- @a
                return '0'
                    -- original
                    -- -- xor (actual_qubits(ACTUAL_QUBIT*2)   -- b': Only current qubit outcome; if '1' then it is V, else H
                    -- -- xor (previous_qubits(N/A)(0)         -- b': Only previous qubit outcomes (N/A -> '0')
                        --  and sx_mask(ACTUAL_QUBIT))      -- Mask/Unmask the measurement outcome based on the Gflow being performed
                    -- xor rand(ACTUAL_QUBIT);                 -- r: Random bit for Decryption

                    -- -- xor sz(ACTUAL_QUBIT-1);              -- Sz: Target Sz (N/A -> '0')

                    -- new
                    xor (actual_qubits(ACTUAL_QUBIT*2)   -- b': Only current qubit outcome; if '1' then it is V, else H
                    -- xor (previous_qubits(0)(0)           -- b': Only previous qubit outcomes, Valid indices: 0 to 0; if '1' then it is V, else H
                        and sx_mask(ACTUAL_QUBIT+1))       -- Mask/Unmask the measurement outcome based on the Gflow being performed
                    xor rand(ACTUAL_QUBIT);               -- r: Random bit for Decryption

                    -- xor sz(ACTUAL_QUBIT-1);              -- Sz: Target Sz
            end if;

            -- 2nd qubit: 0 or a 
            -- -> control 3rd qubit 0 or a
            if ACTUAL_QUBIT = 1 then -- @b
                return '0'
                    -- original
                    -- -- xor (actual_qubits(ACTUAL_QUBIT*2)   -- b': Only current qubit outcome; if '1' then it is V, else H
                    -- xor (previous_qubits(0)(0)           -- b': Only previous qubit outcomes, Valid indices: 0 to 0; if '1' then it is V, else H
                    --      and sx_mask(ACTUAL_QUBIT))      -- Mask/Unmask the measurement outcome based on the Gflow being performed
                    -- xor rand(ACTUAL_QUBIT)               -- r: Random bit for Decryption

                    -- xor sz(ACTUAL_QUBIT-1);              -- Sz: Target Sz

                    -- new
                    -- xor (actual_qubits(ACTUAL_QUBIT*2)   -- b': Only current qubit outcome; if '1' then it is V, else H
                    xor (previous_qubits(0)(0)           -- b': Only previous qubit outcomes, Valid indices: 0 to 0; if '1' then it is V, else H
                        and sx_mask(ACTUAL_QUBIT+1))      -- Mask/Unmask the measurement outcome based on the Gflow being performed
                    xor rand(ACTUAL_QUBIT)               -- r: Random bit for Decryption

                    xor sz(ACTUAL_QUBIT-1);              -- Sz: Target Sz
            end if;

            -- 3rd qubit: 0 or a 
            -- -> control 4th qubit c or b or 0
            if ACTUAL_QUBIT = 2 then -- @c
                return '0'
                    -- original
                    -- -- xor (actual_qubits(ACTUAL_QUBIT*2)   -- b': Only current qubit outcome; if '1' then it is V, else H
                    -- xor (previous_qubits(0)(0)           -- b': Only previous qubit outcomes, Valid indices: 0 to 1; if '1' then it is V, else H
                    --      and sx_mask(ACTUAL_QUBIT))      -- Mask/Unmask the measurement outcome based on the Gflow being performed
                    -- xor rand(ACTUAL_QUBIT)               -- r: Random bit for Decryption

                    -- xor sz(ACTUAL_QUBIT-1);              -- Sz: Target Sz

                    -- new
                    -- SPECIAL CASE
                    -- xor (actual_qubits(ACTUAL_QUBIT*2)   -- b': Only current qubit outcome; if '1' then it is V, else H
                    xor (
                        -- measurement c mask
                        (actual_qubits(ACTUAL_QUBIT*2)   -- b': Only previous qubit outcomes, Valid indices: 0 to 2; if '1' then it is V, else H 
                            and sx_mask(ACTUAL_QUBIT+1))   -- Mask/Unmask the measurement outcome based on the Gflow being performed
                        or 
                        -- measurement b mask
                        (previous_qubits(1)(0)           -- b': Only previous qubit outcomes, Valid indices: 0 to 2; if '1' then it is V, else H
                            and sx_mask(ACTUAL_QUBIT+2)) -- Mask/Unmask the measurement outcome based on the Gflow being performed
                    )
                    xor rand(ACTUAL_QUBIT)               -- r: Random bit for Decryption
                    xor sz(ACTUAL_QUBIT-1);              -- Sz: Target Sz
            end if;

            -- SPECIAL CASE
            -- 4th qubit: c or b or 0
            -- -> no feedforward
            if ACTUAL_QUBIT = 3 then -- @d
                return '0'
                    -- original
                    -- -- xor (actual_qubits(ACTUAL_QUBIT*2)   -- b': Only current qubit outcome; if '1' then it is V, else H
                    -- xor (
                    --     -- measurement c mask
                    --     (previous_qubits(2)(0)           -- b': Only previous qubit outcomes, Valid indices: 0 to 2; if '1' then it is V, else H 
                    --         and sx_mask(ACTUAL_QUBIT))   -- Mask/Unmask the measurement outcome based on the Gflow being performed
                    --     or 
                    --     -- measurement b mask
                    --     (previous_qubits(1)(0)           -- b': Only previous qubit outcomes, Valid indices: 0 to 2; if '1' then it is V, else H
                    --         and sx_mask(ACTUAL_QUBIT+1)) -- Mask/Unmask the measurement outcome based on the Gflow being performed
                    -- )
                    -- xor rand(ACTUAL_QUBIT)               -- r: Random bit for Decryption
                    -- xor sz(ACTUAL_QUBIT-1);              -- Sz: Target Sz

                    -- new (nothing)
                    ;
            end if;

            -- 5th qubit
            if ACTUAL_QUBIT = 4 then
                return '0'
                    -- xor (actual_qubits(ACTUAL_QUBIT*2)    -- b': Only current qubit outcome; if '1' then it is V, else H
                    xor (previous_qubits(ACTUAL_QUBIT)(0) -- b': Only previous qubit outcomes, Valid indices: 0 to 3; if '1' then it is V, else H
                         and sx_mask(ACTUAL_QUBIT+1))       -- Mask/Unmask the measurement outcome based on the Gflow being performed
                    xor rand(ACTUAL_QUBIT)                -- r: Random bit for Decryption
                    xor sz(ACTUAL_QUBIT-1);               -- Sz: Target Sz
            end if;

            return '0';
        end function;


        -- Sz correction logic
        impure function sz_correction_logic (
            constant ACTUAL_QUBIT : natural;    -- Qubit number
            actual_qubits : std_logic_vector(QUBITS_CNT*2-1 downto 0);
            previous_qubits : t_qubit_buffer_2d;
            sx : std_logic_vector(QUBITS_CNT-1 downto 0);
            sz : std_logic_vector(QUBITS_CNT-1 downto 0);
            rand : std_logic_vector(QUBITS_CNT-1 downto 0);
            sz_mask : st_sz_mask
        ) return std_logic is
            variable v_masked_actual_qubits : std_logic_vector(actual_qubits'range) := (others => '0');
            variable v_masked_previous_qubits : t_qubit_buffer_2d := (others => (others => '0'));
        begin

            -- Mask qubits
            -- The desired behaviour of the mask is: 
            --      - If mask == '1', copy the value of the measured
            --        qubit to the output 'v_masked_actual_qubits'
            --      - If mask == '0', force the output to be 0.
            --      -> This is AND gate.

            -- Notation:
            --      a => index 0
            --      b => index 1
            --      c => index 2
            --      d => index 3

            -- Sx correction dependence sets for 9 possible Gflows:
            -- Photon        1st  2nd  3rd  4th
            -- Gflow(1) Sz    0    c*   0    a  * ... not yet measured
            -- Gflow(2) Sz    0    c*   0    a  * ... not yet measured
            -- Gflow(3) Sz    0    c*   0    0  * ... not yet measured
            -- Gflow(4) Sz    0    0    b    a
            -- Gflow(5) Sz    0    0    b    a
            -- Gflow(6) Sz    0    0    b    0
            -- Gflow(7) Sz    0    0    0    a
            -- Gflow(8) Sz    0    0    0    a
            -- Gflow(9) Sz    0    0    0    0

            -- The function being performed in each qubit stage:
            -- b_i = b_i' xor r_i
            -- Sz_i = b_i

            -- 1st qubit: 0
            -- -> 0 or c(not yet measured -> set to 0, postprocess after readout)
            if ACTUAL_QUBIT = 0 then -- @a
            return '0'
                -- original
                -- -- xor (actual_qubits(ACTUAL_QUBIT*2)   -- Only current qubit outcome; if '1' then it is V, else H
                -- -- xor (previous_qubits(N/A)(0)         -- Only previous qubit outcomes (N/A -> '0')
                --     --  and sz_mask(ACTUAL_QUBIT))      -- Mask/Unmask the measurement outcome based on the Gflow being performed
                -- -- xor sz(ACTUAL_QUBIT-1)               -- Sz: Target Sz (N/A -> '0')
                -- xor rand(ACTUAL_QUBIT);              -- Random bit for Decryption

                -- new
                -- xor (actual_qubits(ACTUAL_QUBIT*2)   -- Only current qubit outcome; if '1' then it is V, else H
                -- xor (previous_qubits(N/A)(0)         -- Only previous qubit outcomes (N/A -> '0')
                    --  and sz_mask(ACTUAL_QUBIT))      -- Mask/Unmask the measurement outcome based on the Gflow being performed
                -- xor sz(ACTUAL_QUBIT-1)               -- Sz: Target Sz (N/A -> '0')
                xor rand(ACTUAL_QUBIT);              -- Random bit for Decryption
            end if;

            -- 2nd qubit: 0 or c(not yet measured -> set to 0, postprocess after readout)
            -- -> 0 or b
            if ACTUAL_QUBIT = 1 then -- @b
                return '0'
                    -- original
                    -- -- xor *actual_qubits(ACTUAL_QUBIT*2)    -- Only current qubit outcome; if '1' then it is V, else H
                    -- -- xor (previous_qubits(not measured)(0) -- Only previous qubit outcomes, Valid indices: 0 to 0; if '1' then it is V, else H
                    --      -- and sz_mask(ACTUAL_QUBIT))       -- Mask/Unmask the measurement outcome based on the Gflow being performed
                    -- xor sz(ACTUAL_QUBIT-1)                -- Sz: Target Sz
                    -- xor rand(ACTUAL_QUBIT);               -- Random bit for Decryption

                    -- new
                    xor (actual_qubits(ACTUAL_QUBIT*2)    -- Only current qubit outcome; if '1' then it is V, else H
                    -- xor (previous_qubits(1)(0)            -- Only previous qubit outcomes, Valid indices: 0 to 1; if '1' then it is V, else H
                        and sz_mask(ACTUAL_QUBIT+1))       -- Mask/Unmask the measurement outcome based on the Gflow being performed
                    xor sz(ACTUAL_QUBIT-1)                -- Sz: Target Sz
                    xor rand(ACTUAL_QUBIT);               -- Random bit for Decryption
            end if;

            -- 3rd qubit: 0 or b
            -- -> 0 or a
            if ACTUAL_QUBIT = 2 then -- @c
                return '0'
                    -- original
                    -- -- xor (actual_qubits(ACTUAL_QUBIT*2)    -- Only current qubit outcome; if '1' then it is V, else H
                    -- xor (previous_qubits(1)(0)            -- Only previous qubit outcomes, Valid indices: 0 to 1; if '1' then it is V, else H
                    --      and sz_mask(ACTUAL_QUBIT))       -- Mask/Unmask the measurement outcome based on the Gflow being performed
                    -- xor sz(ACTUAL_QUBIT-1)                -- Sz: Target Sz
                    -- xor rand(ACTUAL_QUBIT);               -- Random bit for Decryption
                    -- xor (actual_qubits(ACTUAL_QUBIT*2)    -- Only current qubit outcome; if '1' then it is V, else H

                    -- new
                    xor (previous_qubits(0)(0)            -- Only previous qubit outcomes, Valid indices: 0 to 2; if '1' then it is V, else H
                        and sz_mask(ACTUAL_QUBIT+1))       -- Mask/Unmask the measurement outcome based on the Gflow being performed
                    xor sz(ACTUAL_QUBIT-1)                -- Sz: Target Sz
                    xor rand(ACTUAL_QUBIT);               -- Random bit for Decryption
            end if;

            -- 4th qubit: 0 or a
            if ACTUAL_QUBIT = 3 then -- @d
                return '0'
                    -- original
                    -- -- xor (actual_qubits(ACTUAL_QUBIT*2)    -- Only current qubit outcome; if '1' then it is V, else H
                    -- xor (previous_qubits(0)(0)            -- Only previous qubit outcomes, Valid indices: 0 to 2; if '1' then it is V, else H
                    --      and sz_mask(ACTUAL_QUBIT))       -- Mask/Unmask the measurement outcome based on the Gflow being performed
                    -- xor sz(ACTUAL_QUBIT-1)                -- Sz: Target Sz
                    -- xor rand(ACTUAL_QUBIT);               -- Random bit for Decryption

                    -- new (nothing)
                    ;
            end if;

            -- 5th qubit
            -- -> no feedforward
            if ACTUAL_QUBIT = 4 then
                return '0'
                    -- xor (actual_qubits(ACTUAL_QUBIT*2)    -- Only current qubit outcome; if '1' then it is V, else H
                    xor (previous_qubits(ACTUAL_QUBIT)(0) -- Only previous qubit outcomes, Valid indices: 0 to 3; if '1' then it is V, else H
                         and sz_mask(ACTUAL_QUBIT))       -- Mask/Unmask the measurement outcome based on the Gflow being performed
                    xor sz(ACTUAL_QUBIT-1)                -- Sz: Target Sz
                    xor rand(ACTUAL_QUBIT);               -- Random bit for Decryption
            end if;

            return '0';
        end function;



    begin

        ---------------------------------
        -- Sx & Sz ROM Mask generator  --
        ---------------------------------
        gen_all_gflows : if GFLOW_NUMBER = 0 generate
            proc_gen_sx_sz_mask : process(clk)
            begin
                if rising_edge(clk) then
                    -- Do not count beyond the max range of the ROM memory
                    slv_cntr_mask <= std_logic_vector(unsigned(slv_cntr_mask) + "1");
                    if slv_cntr_mask = std_logic_vector(to_unsigned(INT_NUMBER_OF_GFLOWS-1, slv_cntr_mask'length)) then
                        slv_cntr_mask <= (others => '0');
                    end if;

                    -- slv_gen_sx_mask <= ROM_SX_MASK_2D(to_integer(unsigned(slv_cntr_mask)));
                    -- slv_gen_sz_mask <= ROM_SZ_MASK_2D(to_integer(unsigned(slv_cntr_mask)));

                    -- Sample the content of the current slv_cntr_mask address pointer
                    for i in 0 to INT_NUMBER_OF_GFLOWS-1 loop
                        if std_logic_vector(to_unsigned(i, slv_cntr_mask'length)) = slv_cntr_mask then
                            -- slv_gen_sx_mask <= ROM_SX_MASK_2D(to_integer(unsigned(slv_cntr_mask)));
                            -- slv_gen_sz_mask <= ROM_SZ_MASK_2D(to_integer(unsigned(slv_cntr_mask)));
                            slv_gen_sx_mask <= ROM_SX_MASK_2D(i);
                            slv_gen_sz_mask <= ROM_SZ_MASK_2D(i);
                        end if;
                    end loop;

                end if;
            end process;
        end generate;

        -- Output constant Sx and Sz masks, and Gflow number
        gen_specific_gflow : if GFLOW_NUMBER > 0 generate
            slv_cntr_mask <= std_logic_vector(to_unsigned(GFLOW_NUMBER-1, slv_cntr_mask'length));
            slv_gen_sx_mask <= ROM_SX_MASK_2D(GFLOW_NUMBER-1);
            slv_gen_sz_mask <= ROM_SZ_MASK_2D(GFLOW_NUMBER-1);
        end generate;




        ----------------------------
        -- Feedforward Controller --
        ----------------------------
        actual_qubit <= slv_actual_qubit;
        slv_qubits_sampled <= qubits_sampled;
        o_feedforward_pulse <= slv_o_feedforward_pulse;
        o_feedforward_pulse_trigger <= slv_o_feedforward_pulse_trigger;
        o_unsuccessful_qubits <= slv_unsuccessful_qubits xor slv_unsuccessful_qubits_two_qubits; -- Xor will not be implemented but this is to prevent warnings in compilation
        feedfwd_success_flag <= sl_feedfwd_success_flag;
        feedfwd_start <= sl_feedfwd_start;
        qubit_buffer <= slv_qubit_buffer_2d;
        time_stamp_buffer <= slv_time_stamp_buffer_2d;
        random_buffer <= slv_random_buffer_2d;
        sx_buffer <= slv_sx_buffer;
        sz_buffer <= slv_sz_buffer;
        actual_gflow_buffer <= slv_actual_gflow_buffer;

        -- Update Sx asynchronously before Pulse Generator
        --                           data                     enable
        -- slv_sx_all_qubits(0) <= slv_sx_buffer(0) when slv_state_feedforward(1) = '1';
        -- slv_sx_all_qubits(1) <= slv_sx_buffer(1) when slv_state_feedforward(2) = '1';
        -- slv_sx_all_qubits(2) <= slv_sx_buffer(2) when slv_state_feedforward(3) = '1';
        -- slv_sx_all_qubits(3) <= slv_sx_buffer(3) when slv_state_feedforward(0) = '1';

        -- slv_sx_all_qubits_ored <= slv_sx_all_qubits(0) 
        --                        or slv_sx_all_qubits(1) 
        --                        or slv_sx_all_qubits(2) 
        --                        or slv_sx_all_qubits(3);

        -- o_sx_next(0) <= slv_sx_all_qubits_ored;
        o_sx_next(0) <= slv_o_sx_next(0);

        -- Scalable hardware description of a FSM-like logic: more than 2 qubits
        gen_feedfwd_more_qubits : if (QUBITS_CNT > 2) generate

            state_feedfwd <= slv_state_feedforward; -- NEW
            int_main_counter_gray <= to_integer(unsigned(slv_main_counter_gray)); -- NEW
            slv_main_counter_bin <= intgray_to_slvbin(int_main_counter_gray, MAX_DELAY_NS_CNTR_BITWIDTH);  -- NEW
            int_main_counter_bin <= to_integer(unsigned(slv_main_counter_bin));  -- NEW
            slv_main_counter_bin_incr <= std_logic_vector(unsigned(slv_main_counter_bin) + "1");  -- NEW
            int_main_counter_bin_incr <= to_integer(unsigned(slv_main_counter_bin_incr));  -- NEW

            proc_fsm_flowambiguity : process(clk)
                variable v_int_precalculate_delay_qx_1 : t_periods_q_2d := (others => 0);
                variable v_int_precalculate_delay_qx_2 : t_periods_q_2d := (others => 0);
                variable v_int_precalculate_delay_qx_3 : t_periods_q_2d := (others => 0);
            begin
                if rising_edge(clk) then
                    -- Default values
                    actual_qubit_valid <= '0';
                    -- actual_state_feedfwd <= int_state_feedfwd; -- NEW (commented)
                    sl_feedfwd_success_flag <= '0';
                    time_stamp_counter_overflow <= '0';
                    sl_feedfwd_start <= '0';
                    slv_unsuccessful_qubits <= (others => '0');
                    eom_ctrl_pulse_ready_p1 <= eom_ctrl_pulse_ready;

                    slv_new_main_cntr <= slv_new_main_cntr + 1; -- NEW

                    -- Galois Counter
                    for i in 1 to QUBITS_CNT-1 loop
                        slv_new_main_galois_cntr_2d(i) <= incr_galois_cntr(to_integer(unsigned(slv_new_main_galois_cntr_2d(i))), MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF); -- NEW
                    end loop;

                    -- Time Stamp counter always inscrements each clock cycle and overflows
                    -- If 1 cycle = 5 ns: 5*10^(-9) sec * 2^(28*2) cycles = overflow after every 42.949673 sec
                    if rst = '0' then
                        uns_actual_time_stamp_counter <= uns_actual_time_stamp_counter + 1;
                    else
                        uns_actual_time_stamp_counter <= (others => '0');
                    end if;


                    --------------------------
                    -- FIRST qubit detected --
                    --------------------------
                    if slv_state_feedforward(0) = '1' and enable = '1' then -- NEW
                        slv_new_main_cntr <= 0; -- NEW
                        slv_new_main_galois_cntr_2d(1) <= int_to_slvgalois(0, MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF); -- NEW

                        -- Make sure that the random string does not update while feedforward is being executed
                        slv_random_string <= i_random_string;
                        slv_sx_buffer <= (others => '0');
                        slv_sz_buffer <= (others => '0');

                        -- AFTER
                        -- Forward the given pulse defined in INT_FEEDFWD_PROGRAMMING
                        -- If 'Horizontal' Coincidence on first qubit
                        if SLV_FEEDFWD_PROGRAMMING(QUBITS_CNT*2-2) = '1' and SLV_FEEDFWD_PROGRAMMING(QUBITS_CNT*2-1) = '0' then
                            slv_o_feedforward_pulse(0) <= slv_qubits_sampled(1);
                            slv_o_feedforward_pulse_trigger(0) <= slv_qubits_sampled(1);
                            -- sl_feedfwd_start <= slv_qubits_sampled(1); -- On Horizontal
                            sl_feedfwd_start <= qubits_sampled_valid(0); -- On Both
                        -- If 'Vertical' Coincidence on first qubit
                        elsif SLV_FEEDFWD_PROGRAMMING(QUBITS_CNT*2-2) = '0' and SLV_FEEDFWD_PROGRAMMING(QUBITS_CNT*2-1) = '1' then
                            slv_o_feedforward_pulse(0) <= slv_qubits_sampled(0);
                            slv_o_feedforward_pulse_trigger(0) <= slv_qubits_sampled(0);
                            -- sl_feedfwd_start <= slv_qubits_sampled(0); -- On Vertical
                            sl_feedfwd_start <= qubits_sampled_valid(0); -- On Both
                        -- If 'Any channel' Coincidence on first qubit
                        elsif SLV_FEEDFWD_PROGRAMMING(QUBITS_CNT*2-2) = '1' and SLV_FEEDFWD_PROGRAMMING(QUBITS_CNT*2-1) = '1' then
                            slv_o_feedforward_pulse(0) <= qubits_sampled_valid(0);
                            slv_o_feedforward_pulse_trigger(0) <= qubits_sampled_valid(0);
                            sl_feedfwd_start <= qubits_sampled_valid(0); -- On Both
                        end if;

                        -- Sample the actual qubit measurement for readout and analysis
                        slv_actual_qubit <= slv_qubits_sampled(1 downto 0);
                        slv_qubit_buffer_2d(0) <= slv_qubits_sampled(1 downto 0);


                        -- Sample time overflow
                        slv_time_stamp_buffer_2d(0) -- Higher bits of the counter (to count beyond ~0.8s)
                        <= std_logic_vector(uns_actual_time_stamp_counter(uns_actual_time_stamp_counter'high downto 28));

                        -- Sample time
                        slv_time_stamp_buffer_2d(1)
                        <= std_logic_vector(uns_actual_time_stamp_counter(st_transaction_data_max_width));

                        -- Sample the first bit from the pre-determimned random bit string
                        slv_random_buffer_2d(0)(0) <= i_random_string(0);

                        -- Sample which Gflow will be implemented in the next feedforward run
                        -- Sample also Sx and Sz masks to enable/disable qubit measurements
                        -- in the Sx and Sz correction table
                        slv_actual_gflow_buffer <= slv_cntr_mask;
                        slv_actual_sx_mask <= slv_gen_sx_mask;
                        slv_actual_sz_mask <= slv_gen_sz_mask;

                        -- For EOM control & encryption
                        slv_o_sx_next(0) <= sx_correction_logic(0, slv_qubits_sampled, slv_qubit_buffer_2d, slv_sx_buffer, slv_sz_buffer, slv_random_string, slv_actual_sx_mask);
                        slv_sx_buffer(0+1) <= sx_correction_logic(0, slv_qubits_sampled, slv_qubit_buffer_2d, slv_sx_buffer, slv_sz_buffer, slv_random_string, slv_actual_sx_mask);
                        slv_sz_buffer(0+1) <= sz_correction_logic(0, slv_qubits_sampled, slv_qubit_buffer_2d, slv_sx_buffer, slv_sz_buffer, slv_random_string, slv_actual_sz_mask);

                        -- Next state
                        actual_qubit_valid <= qubits_sampled_valid(0);
                        slv_state_feedforward(0) <= not qubits_sampled_valid(0); -- NEW
                        slv_state_feedforward(1) <= qubits_sampled_valid(0); -- NEW

                        -- For EOM control & encryption
                        -- b' + Sz(default; for now  Sz=0)
                        -- if qubits_sampled_valid(0) = '1' then
                            -- slv_sx_buffer(0) <= sx_correction_logic(0, slv_qubits_sampled, slv_sx_buffer, slv_sz_buffer, slv_random_string, slv_actual_sx_mask);
                            -- slv_sz_buffer(0) <= sz_correction_logic(0, slv_qubits_sampled, slv_sx_buffer, slv_sz_buffer, slv_random_string, slv_actual_sz_mask);
                            -- slv_o_sx_next(0) <= slv_qubits_sampled(0) xor i_random_string(0); -- slv_qubits_sampled(0) = V; slv_qubits_sampled(1) = H
                            -- slv_o_sx_next(1) <= slv_qubits_sampled(0) and i_random_string(0); -- slv_qubits_sampled(0) = V; slv_qubits_sampled(1) = H
                        -- end if;


                    end if;

                    -----------------------------------
                    -- INTERMEDIATE qubit/s detected --
                    -----------------------------------
                    -- Create parallel threads, activate one based on the actual state
                    for i in 1 to QUBITS_CNT-2 loop
                        if slv_state_feedforward(QUBIT_ID(i)) = '1' then

                            slv_actual_qubit <= slv_qubits_sampled(QUBIT_ID(i)*2+1 downto QUBIT_ID(i)*2);
                            slv_qubit_buffer_2d(QUBIT_ID(i)) <= slv_qubits_sampled(QUBIT_ID(i)*2+1 downto QUBIT_ID(i)*2);

                            -- Sample time
                            slv_time_stamp_buffer_2d(QUBIT_ID(i)+1) 
                            <= std_logic_vector(uns_actual_time_stamp_counter(st_transaction_data_max_width));
                        
                            -- Sample the respective intermediate bit from the pre-determimned random bit string
                            slv_random_buffer_2d(QUBIT_ID(i))(0) <= slv_random_string(QUBIT_ID(i));

                            -- For EOM control & encryption
                            slv_o_sx_next(0) <= sx_correction_logic(QUBIT_ID(i), slv_qubits_sampled, slv_qubit_buffer_2d, slv_sx_buffer, slv_sz_buffer, slv_random_string, slv_actual_sx_mask);
                            slv_sx_buffer(QUBIT_ID(i+1)) <= sx_correction_logic(QUBIT_ID(i), slv_qubits_sampled, slv_qubit_buffer_2d, slv_sx_buffer, slv_sz_buffer, slv_random_string, slv_actual_sx_mask);
                            slv_sz_buffer(QUBIT_ID(i+1)) <= sz_correction_logic(QUBIT_ID(i), slv_qubits_sampled, slv_qubit_buffer_2d, slv_sx_buffer, slv_sz_buffer, slv_random_string, slv_actual_sz_mask);

                            -- If the counter has reached the max delay, don't ask and reset it and assess the next state
                            v_int_precalculate_delay_qx_1(QUBIT_ID(i)) := MAX_PERIODS_DIFF(QUBIT_ID(i)) + MAX_PERIODS_DIFF_CORR(QUBIT_ID(i)); -- NEW CORR
                            if slv_new_main_galois_cntr_2d(QUBIT_ID(i)) = int_to_slvgalois(v_int_precalculate_delay_qx_1(QUBIT_ID(i)), MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF) then -- NEW CORR

                                if qubits_sampled_valid(QUBIT_ID(i)) = '1' then
                                    report "Qubit " & integer'image(QUBIT_ID(i)) & ": " 
                                        & "XX | XX | " & integer'image(slv_new_main_cntr);
                                else 
                                    report "Qubit " & integer'image(QUBIT_ID(i)) & ": " 
                                        & "lost at " & integer'image(slv_new_main_cntr);
                                end if;

                                -- Forward the given pulse defined in INT_FEEDFWD_PROGRAMMING
                                -- If 'Horizontal' Coincidence
                                if SLV_FEEDFWD_PROGRAMMING((QUBITS_CNT-i)*2-2) = '1' and SLV_FEEDFWD_PROGRAMMING((QUBITS_CNT-i)*2-1) = '0' then
                                    slv_o_feedforward_pulse(0) <= slv_qubits_sampled(QUBIT_ID(i)*2+1);
                                -- If 'Vertical' Coincidence
                                elsif SLV_FEEDFWD_PROGRAMMING((QUBITS_CNT-i)*2-2) = '0' and SLV_FEEDFWD_PROGRAMMING((QUBITS_CNT-i)*2-1) = '1' then
                                    slv_o_feedforward_pulse(0) <= slv_qubits_sampled(QUBIT_ID(i)*2);
                                -- If 'Any channel' Coincidence
                                elsif SLV_FEEDFWD_PROGRAMMING((QUBITS_CNT-i)*2-2) = '1' and SLV_FEEDFWD_PROGRAMMING((QUBITS_CNT-i)*2-1) = '1' then
                                    slv_o_feedforward_pulse(0) <= qubits_sampled_valid(QUBIT_ID(i));
                                end if;

                                -- Detect Qubit 3 and proceed to Qubit 4, sample time stamp, reset counters
                                -- Always reset in the last coincidence window time slot
                                slv_new_main_cntr <= 0; -- NEW
                                slv_new_main_galois_cntr_2d(QUBIT_ID(i+1)) <= int_to_slvgalois(0, MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF); -- NEW

                                actual_qubit_valid <= qubits_sampled_valid(QUBIT_ID(i));

                                -- -- Sample time
                                -- slv_time_stamp_buffer_2d(QUBIT_ID(i)+1) 
                                --     <= std_logic_vector(uns_actual_time_stamp_counter(st_transaction_data_max_width));

                                -- -- Sample the respective intermediate bit from the pre-determimned random bit string
                                -- slv_random_buffer_2d(QUBIT_ID(i))(0) <= slv_random_string(QUBIT_ID(i));

                                -- Next state logic
                                -- slv_state_feedforward(i) <= not qubits_sampled_valid(QUBIT_ID(i)); -- NEW
                                slv_state_feedforward(i) <= '0'; -- Always leave this state
                                slv_state_feedforward(i+1) <= qubits_sampled_valid(QUBIT_ID(i)); -- Depending on coincidence, enable next state

                                -- For EOM control & encryption
                                -- b' + Sz(default; for now  Sz=0)
                                -- if qubits_sampled_valid(QUBIT_ID(i)) = '1' then
                                    -- slv_sx_buffer(QUBIT_ID(i)) <= sx_correction_logic(QUBIT_ID(i), slv_qubits_sampled, slv_qubit_buffer_2d, slv_sx_buffer, slv_sz_buffer, slv_random_string, slv_actual_sx_mask);
                                    -- slv_sz_buffer(QUBIT_ID(i)) <= sz_correction_logic(QUBIT_ID(i), slv_qubits_sampled, slv_qubit_buffer_2d, slv_sx_buffer, slv_sz_buffer, slv_random_string, slv_actual_sz_mask);
                                    -- slv_o_sx_next(0) <= slv_qubits_sampled(QUBIT_ID(i)*2) xor i_random_string(QUBIT_ID(i)); -- slv_qubits_sampled(0) = V; slv_qubits_sampled(1) = H
                                    -- slv_o_sx_next(1) <= slv_qubits_sampled(QUBIT_ID(i)*2) and i_random_string(QUBIT_ID(i)); -- slv_qubits_sampled(0) = V; slv_qubits_sampled(1) = H
                                -- end if;

                                -- Enable Qubit 1 state if not coincidence
                                if qubits_sampled_valid(QUBIT_ID(i)) = '0' then
                                    slv_state_feedforward(0) <= not qubits_sampled_valid(QUBIT_ID(i)); -- NEW
                                end if;

                                slv_unsuccessful_qubits(QUBIT_ID(i)) <= not qubits_sampled_valid(QUBIT_ID(i));
                            end if;

                            -- Look for detection before the last counter iteration (counter the data skew)
                            for u in 0 to 0 loop
                                v_int_precalculate_delay_qx_2(QUBIT_ID(i)) := MAX_PERIODS_DIFF(QUBIT_ID(i)) -1 -u + MAX_PERIODS_DIFF_CORR(QUBIT_ID(i)); -- NEW CORR
                                if slv_new_main_galois_cntr_2d(QUBIT_ID(i)) = int_to_slvgalois(v_int_precalculate_delay_qx_2(QUBIT_ID(i)), MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF) then -- NEW CORR

                                    if qubits_sampled_valid(QUBIT_ID(i)) = '1' then
                                        report "Qubit " & integer'image(QUBIT_ID(i)) & ": " 
                                            & "XX | " & integer'image(slv_new_main_cntr) & " | XX ";
                                    end if;

                                    -- Forward the given pulse defined in INT_FEEDFWD_PROGRAMMING
                                    -- If 'Horizontal' Coincidence
                                    if SLV_FEEDFWD_PROGRAMMING((QUBITS_CNT-i)*2-2) = '1' and SLV_FEEDFWD_PROGRAMMING((QUBITS_CNT-i)*2-1) = '0' then
                                        slv_o_feedforward_pulse(0) <= slv_qubits_sampled(QUBIT_ID(i)*2+1);
                                    -- If 'Vertical' Coincidence
                                    elsif SLV_FEEDFWD_PROGRAMMING((QUBITS_CNT-i)*2-2) = '0' and SLV_FEEDFWD_PROGRAMMING((QUBITS_CNT-i)*2-1) = '1' then
                                        slv_o_feedforward_pulse(0) <= slv_qubits_sampled(QUBIT_ID(i)*2);
                                    -- If 'Any channel' Coincidence
                                    elsif SLV_FEEDFWD_PROGRAMMING((QUBITS_CNT-i)*2-2) = '1' and SLV_FEEDFWD_PROGRAMMING((QUBITS_CNT-i)*2-1) = '1' then
                                        slv_o_feedforward_pulse(0) <= qubits_sampled_valid(QUBIT_ID(i));
                                    end if;

                                    -- Leave the state early, reset counter, sample time stamp
                                    actual_qubit_valid <= qubits_sampled_valid(QUBIT_ID(i));

                                    -- -- Sample time
                                    -- slv_time_stamp_buffer_2d(QUBIT_ID(i)+1) 
                                    --     <= std_logic_vector(uns_actual_time_stamp_counter(st_transaction_data_max_width));
                                    
                                    -- -- Sample the respective intermediate bit from the pre-determimned random bit string
                                    -- slv_random_buffer_2d(QUBIT_ID(i))(0) <= slv_random_string(QUBIT_ID(i));

                                    -- Next state logic
                                    slv_state_feedforward(i) <= not qubits_sampled_valid(QUBIT_ID(i)); -- Stay in this state if not coincidence, leave on coincidence
                                    slv_state_feedforward(i+1) <= qubits_sampled_valid(QUBIT_ID(i)); -- Enable next state on coincidence, keep disabled otherwise

                                    -- For EOM control & encryption
                                    -- b' + Sz(default; for now  Sz=0)
                                    -- if qubits_sampled_valid(QUBIT_ID(i)) = '1' then
                                        -- slv_sx_buffer(QUBIT_ID(i)) <= sx_correction_logic(0, slv_qubits_sampled, slv_qubit_buffer_2d, slv_sx_buffer, slv_sz_buffer, slv_random_string, slv_actual_sx_mask);
                                        -- slv_sz_buffer(QUBIT_ID(i)) <= sz_correction_logic(0, slv_qubits_sampled, slv_qubit_buffer_2d, slv_sx_buffer, slv_sz_buffer, slv_random_string, slv_actual_sz_mask);
                                        -- slv_o_sx_next(0) <= slv_qubits_sampled(QUBIT_ID(i)*2) xor i_random_string(QUBIT_ID(i)); -- slv_qubits_sampled(0) = V; slv_qubits_sampled(1) = H
                                        -- slv_o_sx_next(1) <= slv_qubits_sampled(QUBIT_ID(i)*2) and i_random_string(QUBIT_ID(i)); -- slv_qubits_sampled(0) = V; slv_qubits_sampled(1) = H
                                    -- end if;

                                    -- Reset counters only if valid
                                    if qubits_sampled_valid(QUBIT_ID(i)) = '1' then
                                        slv_new_main_cntr <= 0;
                                        slv_new_main_galois_cntr_2d(QUBIT_ID(i+1)) <= int_to_slvgalois(0, MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF);
                                    end if;

                                end if;
                            end loop;


                        end if;
                    end loop;


                    -------------------------
                    -- LAST qubit detected --
                    -------------------------
                    if slv_state_feedforward(QUBITS_CNT-1) = '1' then

                        slv_actual_qubit <= slv_qubits_sampled((QUBITS_CNT-1)*2+1 downto (QUBITS_CNT-1)*2);
                        slv_qubit_buffer_2d(QUBITS_CNT-1) <= slv_qubits_sampled((QUBITS_CNT-1)*2+1 downto (QUBITS_CNT-1)*2);

                        -- Sample time
                        slv_time_stamp_buffer_2d(QUBITS_CNT)
                        <= std_logic_vector(uns_actual_time_stamp_counter(st_transaction_data_max_width));
                    
                        -- Sample the last bit from the pre-determimned random bit string
                        slv_random_buffer_2d(QUBITS_CNT-1)(0) <= slv_random_string(QUBITS_CNT-1);

                        -- For EOM control & encryption (NO CONTROL ON LAST QUBIT STAGE!!)
                        -- slv_o_sx_next(0) <= sx_correction_logic(QUBITS_CNT-1, slv_qubits_sampled, slv_qubit_buffer_2d, slv_sx_buffer, slv_sz_buffer, slv_random_string, slv_actual_sx_mask);
                        -- slv_sx_buffer(QUBITS_CNT-1) <= sx_correction_logic(QUBITS_CNT-1, slv_qubits_sampled, slv_qubit_buffer_2d, slv_sx_buffer, slv_sz_buffer, slv_random_string, slv_actual_sx_mask);
                        -- slv_sz_buffer(QUBITS_CNT-1) <= sz_correction_logic(QUBITS_CNT-1, slv_qubits_sampled, slv_qubit_buffer_2d, slv_sx_buffer, slv_sz_buffer, slv_random_string, slv_actual_sz_mask);

                        v_int_precalculate_delay_qx_1(QUBITS_CNT-1) := MAX_PERIODS_DIFF(QUBITS_CNT-1) + MAX_PERIODS_DIFF_CORR(QUBITS_CNT-1); -- NEW CORR
                        if slv_new_main_galois_cntr_2d(QUBITS_CNT-1) = int_to_slvgalois(v_int_precalculate_delay_qx_1(QUBITS_CNT-1), MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF) then -- NEW CORR

                            if qubits_sampled_valid(QUBITS_CNT-1) = '1' then
                                report "Qubit " & integer'image(QUBITS_CNT-1) & ":            " 
                                    & "XX | XX | " & integer'image(slv_new_main_cntr);
                            else 
                                report "Qubit " & integer'image(QUBITS_CNT-1) & ":            " 
                                    & "lost at " & integer'image(slv_new_main_cntr);
                            end if;

                            -- Detect Qubit 4 and proceed to Qubit 1 state, save time stamp, no need to reset counters (will reset on Qubit 1 detection)
                            actual_qubit_valid <= qubits_sampled_valid(QUBITS_CNT-1);

                            -- -- Sample time
                            -- slv_time_stamp_buffer_2d(QUBITS_CNT) 
                            --     <= std_logic_vector(uns_actual_time_stamp_counter(st_transaction_data_max_width));
                            
                            -- -- Sample the last bit from the pre-determimned random bit string
                            -- slv_random_buffer_2d(QUBITS_CNT-1)(0) <= slv_random_string(QUBITS_CNT-1);

                            slv_state_feedforward(QUBITS_CNT-1) <= '0'; -- Always leave this state here
                            slv_state_feedforward(0) <= '1'; -- Always go back to state 1 from here

                            -- For EOM control & encryption
                            -- b' + Sz(default; for now  Sz=0)
                            -- if qubits_sampled_valid(QUBITS_CNT-1) = '1' then
                                -- slv_sx_buffer(QUBITS_CNT-1) <= sx_correction_logic(QUBITS_CNT-1, slv_qubits_sampled, slv_qubit_buffer_2d, slv_sx_buffer, slv_sz_buffer, slv_random_string, slv_actual_sx_mask);
                                -- slv_sz_buffer(QUBITS_CNT-1) <= sz_correction_logic(QUBITS_CNT-1, slv_qubits_sampled, slv_qubit_buffer_2d, slv_sx_buffer, slv_sz_buffer, slv_random_string, slv_actual_sz_mask);
                                -- slv_o_sx_next(0) <= slv_qubits_sampled((QUBITS_CNT-1)*2) xor slv_random_string(QUBITS_CNT-1); -- slv_qubits_sampled(0) = V; slv_qubits_sampled(1) = H
                                -- slv_o_sx_next(1) <= slv_qubits_sampled((QUBITS_CNT-1)*2) and slv_random_string(QUBITS_CNT-1); -- slv_qubits_sampled(0) = V; slv_qubits_sampled(1) = H
                            -- end if;

                            -- If 'Horizontal' Coincidence is success on last qubit
                            if SLV_FEEDFWD_PROGRAMMING(0) = '1' and SLV_FEEDFWD_PROGRAMMING(1) = '0' then
                                sl_feedfwd_success_flag <= slv_qubits_sampled((QUBITS_CNT-1)*2+1);
                            -- If 'Vertical' Coincidence is success on last qubit
                            elsif SLV_FEEDFWD_PROGRAMMING(0) = '0' and SLV_FEEDFWD_PROGRAMMING(1) = '1' then
                                sl_feedfwd_success_flag <= slv_qubits_sampled((QUBITS_CNT-1)*2);
                            -- If 'Any channel' Coincidence is success on last qubit
                            elsif SLV_FEEDFWD_PROGRAMMING(0) = '1' and SLV_FEEDFWD_PROGRAMMING(1) = '1' then
                                sl_feedfwd_success_flag <= qubits_sampled_valid(QUBITS_CNT-1);
                            end if;

                            slv_unsuccessful_qubits(QUBITS_CNT-1) <= not qubits_sampled_valid(QUBITS_CNT-1);
                        end if;

                        
                        -- Look for detection before the last counter iteration (counter the data skew)
                        for u in 0 to 0 loop
                            v_int_precalculate_delay_qx_2(QUBITS_CNT-1) := MAX_PERIODS_DIFF(QUBITS_CNT-1) -1 -u + MAX_PERIODS_DIFF_CORR(QUBITS_CNT-1); -- NEW CORR
                            if slv_new_main_galois_cntr_2d(QUBITS_CNT-1) = int_to_slvgalois(v_int_precalculate_delay_qx_2(QUBITS_CNT-1), MAX_PERIODS_DIFF_MAXDELAY_BITWIDTH, INT_PRIM_POL_DIFF) then -- NEW CORR

                                if qubits_sampled_valid(QUBITS_CNT-1) = '1' then
                                    report "Qubit " & integer'image(QUBITS_CNT-1) & ":            " 
                                        & "XX | " & integer'image(slv_new_main_cntr) & " | XX ";
                                end if;

                                -- Detect Qubit 4 earlier and proceed to Qubit 1 state
                                -- Leave the state early, reset counter, sample time stamp
                                actual_qubit_valid <= qubits_sampled_valid(QUBITS_CNT-1);

                                -- -- Sample time
                                -- slv_time_stamp_buffer_2d(QUBITS_CNT)
                                --     <= std_logic_vector(uns_actual_time_stamp_counter(st_transaction_data_max_width));
                                
                                -- -- Sample the last bit from the pre-determimned random bit string
                                -- slv_random_buffer_2d(QUBITS_CNT-1)(0) <= slv_random_string(QUBITS_CNT-1);

                                slv_state_feedforward(QUBITS_CNT-1) <= not qubits_sampled_valid(QUBITS_CNT-1); -- NEW
                                slv_state_feedforward(0) <= qubits_sampled_valid(QUBITS_CNT-1); -- NEW

                                -- For EOM control & encryption
                                -- b' + Sz(default; for now  Sz=0)
                                -- if qubits_sampled_valid(QUBITS_CNT-1) = '1' then
                                    -- slv_sx_buffer(QUBITS_CNT-1) <= sx_correction_logic(QUBITS_CNT-1, slv_qubits_sampled, slv_qubit_buffer_2d, slv_sx_buffer, slv_sz_buffer, slv_random_string, slv_actual_sx_mask);
                                    -- slv_sz_buffer(QUBITS_CNT-1) <= sz_correction_logic(QUBITS_CNT-1, slv_qubits_sampled, slv_qubit_buffer_2d, slv_sx_buffer, slv_sz_buffer, slv_random_string, slv_actual_sz_mask);
                                    -- slv_o_sx_next(0) <= slv_qubits_sampled((QUBITS_CNT-1)*2) xor slv_random_string(QUBITS_CNT-1); -- slv_qubits_sampled(0) = V; slv_qubits_sampled(1) = H
                                    -- slv_o_sx_next(1) <= slv_qubits_sampled((QUBITS_CNT-1)*2) and slv_random_string(QUBITS_CNT-1); -- slv_qubits_sampled(0) = V; slv_qubits_sampled(1) = H
                                -- end if;

                                -- If 'Horizontal' Coincidence is success on last qubit
                                if SLV_FEEDFWD_PROGRAMMING(0) = '1' and SLV_FEEDFWD_PROGRAMMING(1) = '0' then
                                    sl_feedfwd_success_flag <= slv_qubits_sampled((QUBITS_CNT-1)*2+1);
                                -- If 'Vertical' Coincidence is success on last qubit
                                elsif SLV_FEEDFWD_PROGRAMMING(0) = '0' and SLV_FEEDFWD_PROGRAMMING(1) = '1' then
                                    sl_feedfwd_success_flag <= slv_qubits_sampled((QUBITS_CNT-1)*2);
                                -- If 'Any channel' Coincidence is success on last qubit
                                elsif SLV_FEEDFWD_PROGRAMMING(0) = '1' and SLV_FEEDFWD_PROGRAMMING(1) = '1' then
                                    sl_feedfwd_success_flag <= qubits_sampled_valid(QUBITS_CNT-1);
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
                    sl_feedfwd_start <= '0';
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

                                sl_feedfwd_start <= '1'; -- #TODO REMOVE
                                
                                actual_qubit_valid <= '1';
                                slv_time_stamp_buffer_2d(0) -- Timing -- Higher bits of the counter (to count beyond ~0.8s)
                                    <= std_logic_vector(uns_actual_time_stamp_counter(uns_actual_time_stamp_counter'high downto 28));
                                slv_time_stamp_buffer_2d(1) 
                                    <= std_logic_vector(uns_actual_time_stamp_counter(st_transaction_data_max_width));
                                
                                -- Sample the first bit from the pre-determimned random bit string
                                slv_random_buffer_2d(0)(0) <= i_random_string(0);

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

                                -- Sample the last bit from the pre-determimned random bit string
                                slv_random_buffer_2d(QUBITS_CNT-1)(0) <= slv_random_string(QUBITS_CNT-1);

                                int_state_feedfwd_two_qubits <= 0;
                                sl_feedfwd_success_flag <= '1';
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

                                    -- Sample the last bit from the pre-determimned random bit string
                                    slv_random_buffer_2d(QUBITS_CNT-1)(0) <= slv_random_string(QUBITS_CNT-1);

                                    int_state_feedfwd_two_qubits <= 0;
                                    sl_feedfwd_success_flag <= '1';
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