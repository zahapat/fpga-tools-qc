    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    use std.textio.all;
    use std.env.finish;

    library lib_src;
    use lib_src.types_pack.all;

    entity fsm_gflow_tb is
    end fsm_gflow_tb;

    architecture sim of fsm_gflow_tb is

        -- Generics
        constant RST_VAL                 : std_logic := '1';
        constant PCD_DELAY_US            : natural := 1;           -- Duration of the pulse from PC in usec
        constant QUBITS_CNT              : natural := 4;
        constant TOTAL_DELAY_FPGA_BEFORE : natural := 5;           -- delay before this module + delay after this module
        constant TOTAL_DELAY_FPGA_AFTER  : natural := 5;           -- delay before + delay after
        constant PHOTON_1H_DELAY_NS      : real := 75.65;
        constant PHOTON_1V_DELAY_NS      : real := 75.01;       -- no delay
        constant PHOTON_2H_DELAY_NS      : real := -2117.95;    -- negative number = delay
        constant PHOTON_2V_DELAY_NS      : real := -2125.35;
        constant PHOTON_3H_DELAY_NS      : real := -1030.35;
        constant PHOTON_3V_DELAY_NS      : real := -1034.45;
        constant PHOTON_4H_DELAY_NS      : real := -3177.95;
        constant PHOTON_4V_DELAY_NS      : real := -3181.05;

        -- CLK of the FPGA
        constant CLK_HZ                : natural := 80e6;
        constant CLK_PERIOD            : time := 1 sec / CLK_HZ;

        -- Emulation of the Qubit refresh rate on input
        constant QUBIT_REFRESH_FREQ_HZ   : natural := 78e6;        -- New qubits refreshed with this frequency
        constant CLK_NEW_QUBIT_PERIOD  : time := 1 sec / QUBIT_REFRESH_FREQ_HZ;
        signal CLK_NEW_QUBIT           : std_logic := '1';

        -- Signals

        -- signal Q1_SAMPLER_EMPTY   : std_logic := '0';
        -- signal Q1_SAMPLER_RD_EN   : std_logic;
        signal Q1_SAMPLER_RD_VALID : std_logic := '0';
        -- signal Q2_SAMPLER_EMPTY   : std_logic := '0';
        -- signal Q2_SAMPLER_RD_EN   : std_logic;
        signal Q2_SAMPLER_RD_VALID : std_logic := '0';
        -- signal Q3_SAMPLER_EMPTY   : std_logic := '0';
        -- signal Q3_SAMPLER_RD_EN   : std_logic;
        signal Q3_SAMPLER_RD_VALID : std_logic := '0';
        -- signal Q4_SAMPLER_EMPTY   : std_logic := '0';
        -- signal Q4_SAMPLER_RD_EN   : std_logic;
        signal Q4_SAMPLER_RD_VALID : std_logic := '0';
        signal FEEDBACK_MOD_VALID : std_logic := '0';
        signal FEEDBACK_MOD       : std_logic_vector(1 downto 0) := (others => '0');
        signal QUBIT_DETECTED     : std_logic_vector(1 downto 0) := (others => '0');

        signal CLK                : std_logic := '1';
        signal RST                : std_logic := RST_VAL;
        signal QUBITS_SAMPLED          : std_logic_vector((QUBITS_CNT*2)-1 downto 0) := (others => '0');
        signal GFLOW_SUCCESS_FLAG : std_logic;
        signal EN_SAMPL_FLAG      : std_logic;
        signal TO_MATH_ALPHA      : std_logic_vector(1 downto 0);
        signal TO_MATH_DATA       : std_logic_vector(1 downto 0);

        -- Number od random inputs INST_B
        constant MAX_RANDOM_NUMBS : natural := 300;

        -- Duration of reset strobe
        constant RST_DURATION : time := 10 * CLK_PERIOD;

        -- Repetitions
        constant REPETITIONS : natural := 2000;
        

        -- Print to console "TEST OK."
        procedure print_test_ok is
            variable str : line;
        begin
            write(str, string'("TEST OK."));
            writeline(output, str);
        end procedure;

    begin

        -- 1 delta delay


        -- Clk generator
        CLK <= not CLK after CLK_PERIOD / 2;
        CLK_NEW_QUBIT <= not CLK_NEW_QUBIT after CLK_NEW_QUBIT_PERIOD / 2;

        -- DUT instance
        dut_fsm_gflow : entity lib_src.fsm_gflow(rtl)
        generic map (
            RST_VAL                 => RST_VAL,
            CLK_HZ                  => CLK_HZ,
            PCD_DELAY_US            => PCD_DELAY_US,
            QUBITS_CNT              => QUBITS_CNT,
            TOTAL_DELAY_FPGA_BEFORE => TOTAL_DELAY_FPGA_BEFORE,
            TOTAL_DELAY_FPGA_AFTER  => TOTAL_DELAY_FPGA_AFTER,
            PHOTON_1H_DELAY_NS      => PHOTON_1H_DELAY_NS,
            PHOTON_1V_DELAY_NS      => PHOTON_1V_DELAY_NS,
            PHOTON_2H_DELAY_NS      => PHOTON_2H_DELAY_NS,
            PHOTON_2V_DELAY_NS      => PHOTON_2V_DELAY_NS,
            PHOTON_3H_DELAY_NS      => PHOTON_3H_DELAY_NS,
            PHOTON_3V_DELAY_NS      => PHOTON_3V_DELAY_NS,
            PHOTON_4H_DELAY_NS      => PHOTON_4H_DELAY_NS,
            PHOTON_4V_DELAY_NS      => PHOTON_4V_DELAY_NS
        )
        port map (
            CLK                => CLK,
            RST                => RST,

            -- Q1_SAMPLER_EMPTY => Q1_SAMPLER_EMPTY,
            -- Q1_SAMPLER_RD_EN => Q1_SAMPLER_RD_EN,
            Q1_SAMPLER_RD_VALID => Q1_SAMPLER_RD_VALID,
            -- Q2_SAMPLER_EMPTY => Q2_SAMPLER_EMPTY,
            -- Q2_SAMPLER_RD_EN => Q2_SAMPLER_RD_EN,
            Q2_SAMPLER_RD_VALID => Q2_SAMPLER_RD_VALID,
            -- Q3_SAMPLER_EMPTY => Q3_SAMPLER_EMPTY,
            -- Q3_SAMPLER_RD_EN => Q3_SAMPLER_RD_EN,
            Q3_SAMPLER_RD_VALID => Q3_SAMPLER_RD_VALID,
            -- Q4_SAMPLER_EMPTY => Q4_SAMPLER_EMPTY,
            -- Q4_SAMPLER_RD_EN => Q4_SAMPLER_RD_EN,
            Q4_SAMPLER_RD_VALID => Q4_SAMPLER_RD_VALID,
            QUBITS_SAMPLED     => QUBITS_SAMPLED,

            FEEDBACK_MOD_VALID => FEEDBACK_MOD_VALID,
            FEEDBACK_MOD       => FEEDBACK_MOD,

            EN_SAMPL_FLAG      => EN_SAMPL_FLAG,
            GFLOW_SUCCESS_FLAG => GFLOW_SUCCESS_FLAG,
            TO_MATH_ALPHA      => TO_MATH_ALPHA,
            TO_MATH_DATA       => TO_MATH_DATA,
            QUBIT_DETECTED     => QUBIT_DETECTED

            CLK                       : in  std_logic;
            RST                       : in  std_logic;

            QUBITS_SAMPLED_VALID      : in  std_logic_vector(QUBITS_CNT-1 downto 0);
            QUBITS_SAMPLED            : in  std_logic_vector((QUBITS_CNT*2)-1 downto 0);

            FEEDBACK_MOD_VALID        : in  std_logic;
            FEEDBACK_MOD              : in  std_logic_vector(1 downto 0);

            GFLOW_SUCCESS_FLAG          : out std_logic;
            GFLOW_SUCCESS_DONE          : out std_logic;
            QUBIT_BUFFER                : out t_qubit_buffer_2d;
            TIME_STAMP_BUFFER           : out t_time_stamp_buffer_2d;
            TIME_STAMP_BUFFER_OVERFLOWS : out t_time_stamp_buffer_overflows_2d;
            ALPHA_BUFFER                : out t_alpha_buffer_2d;

            TO_MATH_ALPHA           : out std_logic_vector(1 downto 0);
            TO_MATH_SX_SZ           : out std_logic_vector(1 downto 0);
            ACTUAL_QUBIT_VALID      : out std_logic;
            ACTUAL_QUBIT            : out std_logic_vector(1 downto 0);
            ACTUAL_QUBIT_TIME_STAMP : out std_logic_vector(st_transaction_data_max_width);

            TIME_STAMP_COUNTER_OVERFLOW : out std_logic
        );


        -- Send random data
        -- proc_rand_input : process

        --     variable v_random_number      : std_logic_vector(QUBITS_SAMPLED'range);
        --     -- variable v_keep_time_pulse_p1 : time;

        --     -- Required for uniform randomization procedure
        --     variable seed_1, seed_2 : integer := MAX_RANDOM_NUMBS;

        --     -- Random SLV generator
        --     impure function rand_slv (
        --         constant length : integer
        --     ) return std_logic_vector is
        --         variable r   : real;
        --         variable slv : std_logic_vector(length-1 downto 0);
        --     begin
        --         for i in slv'range loop
        --             uniform(seed_1, seed_2, r);
        --             slv(i) := '1' when r > 0.5 else '0';
        --         end loop;
        --         return slv;
        --     end function;

        --     procedure transmit (
        --         constant data_1 : std_logic_vector(QUBITS_SAMPLED'range)
        --     ) is begin
        --         -- Send data to the DUT
        --         QUBITS_SAMPLED <= data_1;
        --         -- Print what has been sent, in ModelSim (unsigned data)
        --         -- report "Transmitted: " & integer'image(to_integer(unsigned(data_1)));
        --     end procedure;

        -- begin

        --     for i in 0 to REPETITIONS-1 loop
        --         v_random_number := rand_slv(v_random_number'length);
        --         transmit(v_random_number);
        --         wait until rising_edge(CLK);
        --     end loop;

        -- end process;


        -- Sequencer
        proc_sequencer : process

            -- variable v_keep_time_pulse_p1 : time;

            -- Required for uniform randomization procedure
            variable seed_1, seed_2 : integer := MAX_RANDOM_NUMBS;

            -- Random SLV generator
            variable v_random_number : std_logic_vector(QUBITS_SAMPLED'range);
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
                constant data_1 : std_logic_vector(QUBITS_SAMPLED'range)
            ) is begin
                -- Send data to the DUT
                QUBITS_SAMPLED <= data_1;
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
            wait_cycles(90);


            -- TEST #2
            report "TEST #2: States 1 -> 2 -> 3 -> 4 -> 1";
            QUBITS_SAMPLED <= "11111111";
            -- FSM in state 1 -> 2
            wait until rising_edge(CLK);

            -- FSM in state 2 -> 3
            wait for (2.125)*1 us;

            -- FSM in state 3 -> 4
            wait for (1.034)*1 us;

            -- FSM in state 4 -> 1
            wait for (3.181)*1 us;
            QUBITS_SAMPLED <= "00000000";


            -- TEST #3
            report "TEST #3: States 1 -> 2 -> 3 -> 1";
            QUBITS_SAMPLED <= "11110000";
            -- FSM in state 1 -> 2
            wait until rising_edge(CLK);

            -- FSM in state 2 -> 3
            wait for (2.125)*1 us;

            -- FSM in state 3 -> 1
            wait for (1.034)*1 us;
            QUBITS_SAMPLED <= "00000000";


            -- TEST #4
            report "TEST #4: States 1 -> 2 -> 1";
            -- FSM in state 1 -> 2
            QUBITS_SAMPLED <= "11110000";
            -- FSM in state 1 -> 2
            wait until rising_edge(CLK);

            -- FSM in state 2 -> 1
            wait for (2.125)*1 us;
            QUBITS_SAMPLED <= "00000000";


            -- Random input test
            report "Test with random input bits";
            for i in 0 to REPETITIONS-1 loop
                v_random_number := rand_slv(v_random_number'length);
                transmit(v_random_number);
                wait until rising_edge(CLK);
            end loop;

            -- Wait in state 1
            wait_cycles(90);

            print_test_ok;
            finish;
            wait;
        end process;

    end architecture;