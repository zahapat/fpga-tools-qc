    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    library UNISIM;
    use UNISIM.VComponents.all;

    library lib_src;
    use lib_src.types_pack.all;

    entity ok_usb_32b_fifo_ctrl is
        generic (
            INT_QUBITS_CNT : positive := 4;
            RST_VAL : std_logic := '1';
            CLK_HZ : real := 100.0e6;
            WRITE_VALID_SIGNALS_CNT : positive := 4;
            WRITE_ON_VALID : boolean := true
        );
        port (
            -- Reset, write clock
            rst : in std_logic;
            wr_sys_clk : in std_logic;

            -- Data Signals
            wr_unsuccessful_cnt : in t_unsuccessful_cntr_2d;
            wr_valid_gflow_success_done : in std_logic;
            wr_data_qubit_buffer : in t_qubit_buffer_2d;
            wr_data_time_stamp_buffer : in t_time_stamp_buffer_2d;
            wr_data_alpha_buffer : in t_alpha_buffer_2d;
            wr_data_modulo_buffer : in t_modulo_buffer_2d;
            wr_data_random_buffer : in t_random_buffer_2d;

            -- Read endpoint signals: slower CLK, faster rate
            readout_clk : in std_logic;
            readout_data_ready : out std_logic;
            readout_data_valid : out std_logic;
            readout_enable : in std_logic;
            readout_data_32b : out std_logic_vector(32-1 downto 0);

            -- Flags
            fifo_full : out std_logic;
            fifo_empty : out std_logic;
            fifo_prog_empty : out std_logic;

            -- LED
            fifo_full_latched : out std_logic
        );
    end ok_usb_32b_fifo_ctrl;

    architecture rtl of ok_usb_32b_fifo_ctrl is

        -- Xilinx FIFO Generator
        component fifo_generator_0
        port (
            rst : in std_logic;

            wr_clk : in std_logic;
            wr_en : in std_logic;
            din : in std_logic_vector(32-1 downto 0);

            rd_clk : in std_logic;
            rd_en : in std_logic;
            valid : out std_logic;
            dout : out std_logic_vector(readout_data_32b'range);

            full : out std_logic;
            empty : out std_logic;
            prog_empty : out std_logic
        );
        end component;

        signal wr_valid_gflow_success_done_p1 : std_logic := '0';
        signal wr_valid_gflow_success_done_p2 : std_logic := '0';
        signal wr_valid_gflow_success_done_p3 : std_logic := '0';
        signal wr_transfer_valid_gflow_request : std_logic := '0';

        signal sl_rst        : std_logic := '0'; -- not bound to any clk

        signal wr_clk      : std_logic := '0';
        signal sl_wr_en    : std_logic := '0';
        signal slv_wr_data : std_logic_vector(31 downto 0) := (others => '0');

        signal rd_clk          : std_logic := '0';
        signal sl_rd_valid     : std_logic := '0';
        signal slv_rd_data_out : std_logic_vector(31 downto 0) := (others => '0');

        signal sl_full       : std_logic := '0';
        signal sl_empty      : std_logic := '0';
        signal sl_prog_empty : std_logic := '0';


        -- User logic endpoint write logic
        signal sl_wr_en_flag_pulsed : std_logic := '0';
        signal slv_wr_data_stream_32b : std_logic_vector(32-1 downto 0) := (others => '0');
        signal slv_wr_data_stream_32b_1 : std_logic_vector(32-1 downto 0) := (others => '0');
        signal slv_wr_data_stream_32b_2 : std_logic_vector(32-1 downto 0) := (others => '0');
        signal sl_full_latched : std_logic := '0';

        signal sl_at_least_one_qubit_valid : std_logic := '0';
        signal sl_at_least_one_qubit_valid_p1 : std_logic := '0';

        -- OK endpoint read logic
        signal sl_readout_endp_ready : std_logic := '0';
        signal slv_ok_rd_endp_data : std_logic_vector(31 downto 0) := (others => '0');

        -- Buffer Values Captured
        signal wr_data_time_stamp_buffer_p1 : t_time_stamp_buffer_2d := (others => (others => '0'));
        signal slv_qubit_buffer_2d          : t_qubit_buffer_2d := (others => (others => '0'));
        signal slv_time_stamp_buffer_2d     : t_time_stamp_buffer_2d := (others => (others => '0'));
        signal slv_alpha_buffer_2d          : t_alpha_buffer_2d := (others => (others => '0'));
        signal slv_modulo_buffer_2d         : t_modulo_buffer_2d := (others => (others => '0'));
        signal slv_random_buffer_2d         : t_random_buffer_2d := (others => (others => '0'));


        constant COUNT_UNTIL_SECOND : real := 1.0e-6; -- yes, but too fasts
        -- constant COUNT_UNTIL_SECOND : real := 0.01; -- yes, but too fasts
        -- constant COUNT_UNTIL_SECOND : real := 0.009; -- no data in buffer
        -- constant COUNT_UNTIL_SECOND : real := 0.010; -- no data in buffer
        -- constant COUNT_UNTIL_SECOND : real := 0.100; -- no data in buffer
        -- constant COUNT_UNTIL_SECOND : real := 1.000; -- no data in buffer
        constant PERIODIC_REPORT_CLK_PERIODS : natural := natural(COUNT_UNTIL_SECOND * CLK_HZ);
        signal int_periodic_report_counter : integer range 0 to PERIODIC_REPORT_CLK_PERIODS-1 := 0;
        signal uns_counts_in_one_second_counter : unsigned(st_transaction_data_max_width) := (others => '0');
        signal uns_counts_in_one_second_latched : unsigned(st_transaction_data_max_width) := (others => '0');
        signal sl_periodic_report_flag : std_logic := '0';
        signal sl_periodic_report_request : std_logic := '0';
        signal sl_periodic_report_sample_valid : std_logic_vector((INT_QUBITS_CNT**2)-1 downto 0) := (others => '0');

        -- Photon Combination Accumulation
        constant ACCUMULATOR_COUNTER_WIDTH : positive := 16; -- 65536 max
        constant REDUNDANT_ZEROS_TRANSAC : std_logic_vector(28-ACCUMULATOR_COUNTER_WIDTH-1 downto 0) := (others => '0');
        constant REDUNDANT_ZEROS_SHIFTREG : std_logic_vector(ACCUMULATOR_COUNTER_WIDTH-1 downto 0) := (others => '0');
        type t_all_combinations_2d is array(INT_QUBITS_CNT**2-1 downto 0) of natural;
        type t_all_combinations_counters_2d is array(INT_QUBITS_CNT**2-1 downto 0) of std_logic_vector(ACCUMULATOR_COUNTER_WIDTH-1 downto 0);
        impure function get_all_combinations_qubits return t_all_combinations_2d is
            variable v_all_combinations_2d : t_all_combinations_2d := (others => 0);
        begin
            for i in 0 to INT_QUBITS_CNT**2-1 loop
                v_all_combinations_2d(i) := i;
            end loop;
            return v_all_combinations_2d;
        end function;
        constant COMBINATION_ADDR : t_all_combinations_2d := get_all_combinations_qubits;
        signal slv_combinations_counters_2d : t_all_combinations_counters_2d := (others => (others => '0'));
        signal slv_higher_bits_qubit_buffer : std_logic_vector(INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_combinations_counters_sampled : std_logic_vector(ACCUMULATOR_COUNTER_WIDTH*(INT_QUBITS_CNT**2)-1 downto 0) := (others => '1');
        signal int_periodic_readout_tx_counter : natural range 0 to INT_QUBITS_CNT**2 := 0;


        type t_state_write_data_transac is (
            SEND_PERIODIC_REPORT_DATA,
            WAIT_AND_SEND_DATA_QUBIT1_TO_QUBIT4,
            WAIT_AND_SEND_DATA_QUBIT5_TO_QUBIT8,
            SEND_TIME_QUBIT1,
            SEND_TIME_QUBIT2,
            SEND_TIME_QUBIT3,
            SEND_TIME_QUBIT4,
            SEND_TIME_QUBIT5,
            SEND_TIME_QUBIT6,
            SEND_TIME_QUBIT7,
            SEND_TIME_QUBIT8
        );
        signal state_write_data_transac : t_state_write_data_transac := SEND_PERIODIC_REPORT_DATA;

    begin


        -------------------------------------
        -- Dual-port Native FIFO Generator --
        -------------------------------------
        fifo_full <= sl_full;
        fifo_empty <= sl_empty;
        fifo_prog_empty <= sl_prog_empty;
        fifo_full_latched <= sl_full_latched;

        inst_native_fifo_generator : fifo_generator_0
        port map (
            rst    => sl_rst,

            -- Write: faster CLK, slower rate
            wr_clk => wr_sys_clk,
            wr_en  => sl_wr_en,
            din    => slv_wr_data,

            -- Read: slower CLK, faster rate
            rd_clk => readout_clk, -- [Timing 38-316] Clock period '1000.000' specified during out-of-context synthesis of instance 'inst_okHost_fifo_ctrl/inst_native_fifo_generator' at clock pin 'rd_clk' is different from the actual clock period '9.920', this can lead to different synthesis results.
            rd_en  => readout_enable,
            valid  => sl_rd_valid,
            dout   => slv_rd_data_out,

            -- Flags
            full   => sl_full,
            empty  => sl_empty,
            prog_empty => sl_prog_empty -- Programmable Empty Level indicator set to 1024
        );


        -------------------------------------
        -- PHOTON COMBINATION ACCUMULATION --
        -------------------------------------
        gen_pick_higher_bits : for i in 0 to INT_QUBITS_CNT-1 generate
            slv_higher_bits_qubit_buffer(i) <= wr_data_qubit_buffer(i)(1);
        end generate;
        proc_qubit_combination_accum : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then
                if wr_valid_gflow_success_done = '1' then
                    for i in 0 to INT_QUBITS_CNT**2-1 loop
                        if std_logic_vector(to_unsigned(COMBINATION_ADDR(i), INT_QUBITS_CNT)) = slv_higher_bits_qubit_buffer then
                            slv_combinations_counters_2d(COMBINATION_ADDR(i)) 
                                <= std_logic_vector(unsigned(slv_combinations_counters_2d(COMBINATION_ADDR(i))) + "1");
                        end if;
                    end loop;
                end if;
            end if;
        end process;



        -------------------
        -- WRITE CONTROL --
        -------------------
        proc_success_flag_delay : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then
                wr_valid_gflow_success_done_p1 <= wr_valid_gflow_success_done;
                wr_valid_gflow_success_done_p2 <= wr_valid_gflow_success_done_p1;
                wr_valid_gflow_success_done_p3 <= wr_valid_gflow_success_done_p2;

                wr_data_time_stamp_buffer_p1 <= wr_data_time_stamp_buffer;
            end if;
        end process;

        proc_create_32b_transaction_1 : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then                
                if wr_valid_gflow_success_done_p1 = '1' then
                    slv_wr_data_stream_32b_1(31 downto 30) <= wr_data_qubit_buffer(0); -- Qubit 1
                    slv_wr_data_stream_32b_1(29 downto 28) <= wr_data_qubit_buffer(1);
                    slv_wr_data_stream_32b_1(27 downto 26) <= wr_data_qubit_buffer(2);
                    slv_wr_data_stream_32b_1(25 downto 24) <= wr_data_qubit_buffer(3);

                    slv_wr_data_stream_32b_1(23 downto 22) <= wr_data_alpha_buffer(0);
                    slv_wr_data_stream_32b_1(21 downto 20) <= wr_data_alpha_buffer(1);
                    slv_wr_data_stream_32b_1(19 downto 18) <= wr_data_alpha_buffer(2);
                    slv_wr_data_stream_32b_1(17 downto 16) <= wr_data_alpha_buffer(3);

                    slv_wr_data_stream_32b_1(15 downto 15) <= wr_data_random_buffer(0);
                    slv_wr_data_stream_32b_1(14 downto 14) <= wr_data_random_buffer(1);
                    slv_wr_data_stream_32b_1(13 downto 13) <= wr_data_random_buffer(2);
                    slv_wr_data_stream_32b_1(12 downto 12) <= wr_data_random_buffer(3);

                    slv_wr_data_stream_32b_1(11 downto 10) <= wr_data_modulo_buffer(0);
                    slv_wr_data_stream_32b_1(9 downto 8) <= wr_data_modulo_buffer(1);
                    slv_wr_data_stream_32b_1(7 downto 6) <= wr_data_modulo_buffer(2);
                    slv_wr_data_stream_32b_1(5 downto 4) <= wr_data_modulo_buffer(3);
                end if;
            end if;
        end process;

        proc_create_32b_transaction_2 : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then                
                if wr_valid_gflow_success_done_p2 = '1' then
                    slv_wr_data_stream_32b_2(31 downto 30) <= wr_data_qubit_buffer(4); -- Qubit 5
                    slv_wr_data_stream_32b_2(29 downto 28) <= wr_data_qubit_buffer(5);

                    slv_wr_data_stream_32b_2(23 downto 22) <= wr_data_alpha_buffer(4);
                    slv_wr_data_stream_32b_2(21 downto 20) <= wr_data_alpha_buffer(5);

                    slv_wr_data_stream_32b_2(15 downto 15) <= wr_data_random_buffer(4);
                    slv_wr_data_stream_32b_2(14 downto 14) <= wr_data_random_buffer(5);

                    slv_wr_data_stream_32b_2(11 downto 10) <= wr_data_modulo_buffer(4);
                    slv_wr_data_stream_32b_2(9 downto 8) <= wr_data_modulo_buffer(5);
                end if;
            end if;
        end process;

        proc_sample_accumulated_values : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then
                -- Shift right by default
                slv_combinations_counters_sampled(slv_combinations_counters_sampled'high downto 0) 
                        <= REDUNDANT_ZEROS_SHIFTREG & slv_combinations_counters_sampled(
                            slv_combinations_counters_sampled'high downto ACCUMULATOR_COUNTER_WIDTH);

                -- Set on valid
                for i in 0 to INT_QUBITS_CNT**2-1 loop
                    if sl_periodic_report_sample_valid(i) = '1' then
                            slv_combinations_counters_sampled((i+1)*ACCUMULATOR_COUNTER_WIDTH-1 downto i*ACCUMULATOR_COUNTER_WIDTH) 
                                <= slv_combinations_counters_2d(i);
                    end if;
                end loop;
            end if;
        end process;

        -- Sample the data buffers and make them stable, since they change over time
        -- Then, prepare transactions and send them one by one to the fifo
        proc_transaction_after_success : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then
                -- Tie to 0
                sl_wr_en_flag_pulsed <= '0';
                sl_at_least_one_qubit_valid_p1 <= sl_at_least_one_qubit_valid;

                -- Queued Requests
                if wr_valid_gflow_success_done_p2 = '1' then
                    wr_transfer_valid_gflow_request <= wr_valid_gflow_success_done_p2;
                end if;

                if sl_periodic_report_flag = '1' then
                    sl_periodic_report_request <= sl_periodic_report_flag;
                end if;


                -- Sample the time stamp buffer values to read from later
                if wr_valid_gflow_success_done_p1 = '1' then
                    slv_time_stamp_buffer_2d <= wr_data_time_stamp_buffer_p1;
                end if;


                -- Counter to send a value per desired number of seconds
                if int_periodic_report_counter = PERIODIC_REPORT_CLK_PERIODS-1 then
                    int_periodic_report_counter <= 0;
                    sl_periodic_report_flag <= '1';
                    sl_periodic_report_sample_valid <= (others => '1');
                else
                    int_periodic_report_counter <= int_periodic_report_counter + 1;
                    sl_periodic_report_flag <= '0';
                    sl_periodic_report_sample_valid <= (others => '0');
                end if;



                -- Controller for sending data over USB3
                case state_write_data_transac is
                    when SEND_PERIODIC_REPORT_DATA => 

                        -- Do not transmit by default
                        sl_wr_en_flag_pulsed <= '0';

                        -- Wait until periodic report has been transmitted
                        if wr_transfer_valid_gflow_request = '1' then
                            state_write_data_transac <= WAIT_AND_SEND_DATA_QUBIT1_TO_QUBIT4;
                        end if;

                        -- Send periodic report in a way it has a higher priority over the 'wr_transfer_valid_gflow_request' but does not interfere with it
                        if sl_periodic_report_request = '1' then
                            state_write_data_transac <= SEND_PERIODIC_REPORT_DATA;
                            if int_periodic_readout_tx_counter = INT_QUBITS_CNT**2 then
                                -- Reset and stop transmitting
                                sl_periodic_report_request <= '0';
                                int_periodic_readout_tx_counter <= 0;
                                sl_wr_en_flag_pulsed <= '0';
                            else
                                -- Allow Transmitting
                                sl_wr_en_flag_pulsed <= '1';
                                int_periodic_readout_tx_counter <= int_periodic_readout_tx_counter + 1;

                                -- Define All bits!
                                slv_wr_data_stream_32b(31 downto 4) 
                                    <= REDUNDANT_ZEROS_TRANSAC & slv_combinations_counters_sampled(
                                        ACCUMULATOR_COUNTER_WIDTH-1 downto 0);

                                -- Encoded command for the C++ backend: Print Time to Console Send directly to Redis Server
                                -- Command x"0" is forbidden
                                slv_wr_data_stream_32b(3 downto 0) <= x"4";

                            end if;
                        end if;


                    when WAIT_AND_SEND_DATA_QUBIT1_TO_QUBIT4 =>

                        -- Sample the data buffer values on valid, set write en, proceed
                        -- Define All bits!
                        slv_wr_data_stream_32b(31 downto 4) <= slv_wr_data_stream_32b_1(31 downto 4);

                        -- Encoded command for the C++ backend: Get & Parse Data + Append to a file
                        -- Command x"0" is forbidden
                        slv_wr_data_stream_32b(3 downto 0) <= x"1";

                        sl_wr_en_flag_pulsed <= '1';
                        state_write_data_transac <= WAIT_AND_SEND_DATA_QUBIT5_TO_QUBIT8;


                    when WAIT_AND_SEND_DATA_QUBIT5_TO_QUBIT8 =>

                            -- Define All bits!
                            slv_wr_data_stream_32b(31 downto 4) <= slv_wr_data_stream_32b_2(31 downto 4);

                            -- Encoded command for the C++ backend: Get & Parse Data + Append to a file
                            -- Command x"0" is forbidden
                            slv_wr_data_stream_32b(3 downto 0) <= x"5";

                            sl_wr_en_flag_pulsed <= '1';
                            state_write_data_transac <= SEND_TIME_QUBIT1;


                    when SEND_TIME_QUBIT1 => 
                        -- Send time stamp of qubit 1 measured, set write en, proceed
                        -- Define All bits!
                        slv_wr_data_stream_32b(31 downto 4) <= slv_time_stamp_buffer_2d(0);

                        -- Encoded command for the C++ backend: Get Time + Append to a file
                        -- Command x"0" is forbidden
                        slv_wr_data_stream_32b(3 downto 0) <= x"2";

                        sl_wr_en_flag_pulsed <= '1';
                        state_write_data_transac <= SEND_TIME_QUBIT2;


                    when SEND_TIME_QUBIT2 => 
                        -- Send time stamp of qubit 2 measured, set write en, proceed
                        -- Define All bits!
                        slv_wr_data_stream_32b(31 downto 4) <= slv_time_stamp_buffer_2d(1);

                        -- Encoded command for the C++ backend: Get Time + Append to a file
                        -- Command x"0" is forbidden
                        slv_wr_data_stream_32b(3 downto 0) <= x"2";

                        sl_wr_en_flag_pulsed <= '1';
                        state_write_data_transac <= SEND_TIME_QUBIT3;


                    when SEND_TIME_QUBIT3 => 
                        -- Send time stamp of qubit 3 measured, set write en, proceed
                        -- Define All bits!
                        slv_wr_data_stream_32b(31 downto 4) <= slv_time_stamp_buffer_2d(2);

                        -- Encoded command for the C++ backend: Get Time + Append to a file
                        -- Command x"0" is forbidden
                        slv_wr_data_stream_32b(3 downto 0) <= x"2";

                        sl_wr_en_flag_pulsed <= '1';
                        state_write_data_transac <= SEND_TIME_QUBIT4;


                    when SEND_TIME_QUBIT4 => 
                        -- Send time stamp of qubit 4 measured, set write en, proceed
                        -- Define All bits!
                        slv_wr_data_stream_32b(31 downto 4) <= slv_time_stamp_buffer_2d(3);

                        -- Encoded command for the C++ backend: Get Time + Append to a file
                        -- Command x"0" is forbidden
                        slv_wr_data_stream_32b(3 downto 0) <= x"2";

                        sl_wr_en_flag_pulsed <= '1';
                        state_write_data_transac <= SEND_TIME_QUBIT5;


                    when SEND_TIME_QUBIT5 => 
                        -- Send time stamp of qubit 4 measured, set write en, proceed
                        -- Define All bits!
                        slv_wr_data_stream_32b(31 downto 4) <= slv_time_stamp_buffer_2d(4);

                        -- Encoded command for the C++ backend: Get Time + Append to a file
                        -- Command x"0" is forbidden
                        slv_wr_data_stream_32b(3 downto 0) <= x"2";

                        sl_wr_en_flag_pulsed <= '1';
                        state_write_data_transac <= SEND_TIME_QUBIT6;


                    when SEND_TIME_QUBIT6 => 
                        -- Send time stamp of qubit 4 measured, set write en, proceed
                        -- Define All bits!
                        slv_wr_data_stream_32b(31 downto 4) <= slv_time_stamp_buffer_2d(5);

                        -- Encoded command for the C++ backend: Get Time + Append to a file
                        -- Command x"0" is forbidden
                        slv_wr_data_stream_32b(3 downto 0) <= x"2";

                        sl_wr_en_flag_pulsed <= '1';
                        state_write_data_transac <= SEND_PERIODIC_REPORT_DATA;
                        
                        -- Set next transaction request to zero, wait to be asserted once next cluster has been measured
                        wr_transfer_valid_gflow_request <= '0';

                    when others =>
                        sl_wr_en_flag_pulsed <= '0';
                        state_write_data_transac <= SEND_PERIODIC_REPORT_DATA;
                        
                        -- Set next transaction request to zero, wait to be asserted once next cluster has been measured
                        wr_transfer_valid_gflow_request <= '0';

                end case;
            end if;
        end process;


        -- Write logic
        proc_endp_fifo_write_valid : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then

                -- DO NOT TOUCH: Default values
                sl_wr_en <= '0';
                sl_full_latched <= sl_full_latched;

                -- USER INPUT: Condition for writing to FIFO
                if sl_wr_en_flag_pulsed = '1' then

                    -- 1 clk wait for 'sl_wr_en' to be asserted
                    slv_wr_data <= slv_wr_data_stream_32b;

                    -- DO NOT TOUCH: FIFO Control: Write in the next clk cycle if fifo not full
                    if sl_full = '0' then   -- Do not touch
                        sl_wr_en <= '1';
                    else
                        sl_full_latched <= '1';
                    end if;

                end if;
            end if;
        end process;


        ------------------
        -- READ CONTROL --
        ------------------
        -- DO NOT TOUCH
        -- 3) Sending Ready Flag to okHost for future reading of a block of data
        --    FIFO Level indicator is tied to okBTPipeOut's 'ep_ready'
        --    When 'ep_ready' is asserted, the host is free to read a full block of data from FIFO
        readout_data_ready <= not sl_prog_empty;
        readout_data_valid <= sl_rd_valid;

        -- DO NOT TOUCH
        -- 4) Reacting to Read requests from okHost
        --    okHost already knows there is a block of data ready to transmit inside the FIFO
        readout_data_32b <= slv_rd_data_out;

    end architecture;