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
            RST_VAL : std_logic := '1';
            CLK_HZ : natural := 100e6;
            WRITE_VALID_SIGNALS_CNT : positive := 4;
            WRITE_ON_VALID : boolean := true
        );
        port (
            -- Reset
            rst : in std_logic;

            -- Write endpoint signals: faster CLK, slower rate
            wr_sys_clk : in std_logic;
            --     Valid Signals / Write Flags
            wr_valid_qubit_flags        : in std_logic_vector(WRITE_VALID_SIGNALS_CNT-1 downto 0);
            wr_valid_gflow_success_done : in std_logic;
            --     Data Signals
            wr_data_qubit_buffer : in t_qubit_buffer_2d;
            wr_data_time_stamp_buffer : in t_time_stamp_buffer_2d;
            wr_data_time_stamp_buffer_overflows : in t_time_stamp_buffer_overflows_2d;
            wr_data_alpha_buffer : in t_alpha_buffer_2d;
            wr_data_modulo_buffer : in t_modulo_buffer_2d;
            wr_data_random_buffer : in t_random_buffer_2d;
            wr_data_stream_32b  : in std_logic_vector(32-1 downto 0);

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
            din : in std_logic_vector(wr_data_stream_32b'range);

            rd_clk : in std_logic;
            rd_en : in std_logic;
            valid : out std_logic;
            dout : out std_logic_vector(readout_data_32b'range);

            full : out std_logic;
            empty : out std_logic;
            prog_empty : out std_logic
        );
        end component;

        signal sl_rst        : std_logic := '0'; -- not bound to any clk

        signal wr_clk        : std_logic;
        signal sl_wr_en      : std_logic;
        signal slv_wr_data    : std_logic_vector(31 downto 0);

        signal rd_clk        : std_logic;
        signal sl_rd_valid   : std_logic := '0';
        signal slv_rd_data_out : std_logic_vector(31 downto 0);

        signal sl_full       : std_logic;
        signal sl_empty      : std_logic;
        signal sl_prog_empty : std_logic;


        -- User logic endpoint write logic
        signal slv_wr_valid_qubit_flags : std_logic_vector(wr_valid_qubit_flags'range) := (others => '0');
        signal sl_wr_en_flag_pulsed : std_logic := '0';
        signal slv_wr_data_stream_32b : std_logic_vector(wr_data_stream_32b'range) := (others => '0');
        signal sl_full_latched : std_logic := '0';

        signal sl_at_least_one_qubit_valid : std_logic := '0';

        -- OK endpoint read logic
        signal sl_readout_endp_ready   : std_logic := '0';
        signal slv_ok_rd_endp_data   : std_logic_vector(31 downto 0) := (others => '0');

        -- Buffer Values Captured
        signal slv_qubit_buffer_2d      : t_qubit_buffer_2d := (others => (others => '0'));
        signal slv_time_stamp_buffer_2d : t_time_stamp_buffer_2d := (others => (others => '0'));
        signal slv_time_stamp_buffer_overflows_2d : t_time_stamp_buffer_overflows_2d := (others => (others => '0'));
        signal slv_alpha_buffer_2d      : t_alpha_buffer_2d := (others => (others => '0'));
        signal slv_modulo_buffer_2d      : t_modulo_buffer_2d := (others => (others => '0'));
        signal slv_random_buffer_2d     : t_random_buffer_2d := (others => '0');


        constant COUNT_UNTIL_SECOND : real := 0.01; -- yes, but too fasts
        -- constant COUNT_UNTIL_SECOND : real := 0.009; -- no data in buffer
        -- constant COUNT_UNTIL_SECOND : real := 0.010; -- no data in buffer
        -- constant COUNT_UNTIL_SECOND : real := 0.100; -- no data in buffer
        -- constant COUNT_UNTIL_SECOND : real := 1.000; -- no data in buffer
        constant CLK_PERIODS_ONE_SECOND : natural := natural(real(COUNT_UNTIL_SECOND) * real(CLK_HZ)*1.0);
        signal int_one_second_counter : integer range 0 to CLK_PERIODS_ONE_SECOND-1 := 0;
        signal uns_counts_in_one_second_counter : unsigned(st_transaction_data_max_width) := (others => '0');
        signal uns_counts_in_one_second_latched : unsigned(st_transaction_data_max_width) := (others => '0');
        signal sl_one_second_flag : std_logic := '0';


        type t_state_write_data_transac is (
            WAIT_AND_SEND_DATA,
            SEND_TIME_QUBIT1,
            SEND_TIME_QUBIT1_OVERFLOWS,
            SEND_TIME_QUBIT2,
            SEND_TIME_QUBIT2_OVERFLOWS,
            SEND_TIME_QUBIT3,
            SEND_TIME_QUBIT3_OVERFLOWS,
            SEND_TIME_QUBIT4,
            SEND_TIME_QUBIT4_OVERFLOWS
        );
        signal state_write_data_transac : t_state_write_data_transac := WAIT_AND_SEND_DATA;

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


        -------------------
        -- WRITE CONTROL --
        -------------------
        -- slv_wr_data_stream_32b <= wr_data_stream_32b;
        -- slv_wr_valid_qubit_flags <= wr_valid_qubit_flags;

        -- For writing signals to fifo if valid asserted
        gen_write_on_valid_true : if WRITE_ON_VALID = true generate


            -- OR-gate with multiple inputs
            asynproc_valid_flags_ored : process(wr_valid_qubit_flags)
                variable v_valid_qubit_flags_ored : std_logic;
            begin
                v_valid_qubit_flags_ored := '0';
                for i in wr_valid_qubit_flags'range loop
                    v_valid_qubit_flags_ored := v_valid_qubit_flags_ored or wr_valid_qubit_flags(i);
                end loop;
                sl_at_least_one_qubit_valid <= v_valid_qubit_flags_ored;
            end process;


            -- Sample the data buffers and make them stable, since they change over time
            -- Then, prepare transactions and send them one by one to the fifo
            proc_transaction_after_success : process(wr_sys_clk)
            begin
                if rising_edge(wr_sys_clk) then
                    if rst = RST_VAL then
                        sl_wr_en_flag_pulsed <= '0';
                        slv_time_stamp_buffer_2d <= (others => (others => '0'));
                        slv_time_stamp_buffer_overflows_2d <= (others => (others => '0'));
                        slv_wr_data_stream_32b <= (others => '0');
                        uns_counts_in_one_second_counter <= (others => '0');
                        int_one_second_counter <= 0;
                        sl_one_second_flag <= '0';
                        uns_counts_in_one_second_latched <= (others => '0');

                    else
                        -- Tie to 0
                        sl_wr_en_flag_pulsed <= '0';


                        -- Sample the time stamp buffer values to read from later
                        if wr_valid_gflow_success_done = '1' then
                            slv_time_stamp_buffer_2d <= wr_data_time_stamp_buffer;
                            slv_time_stamp_buffer_overflows_2d <= wr_data_time_stamp_buffer_overflows;
                        end if;


                        -- Counter to send a value per desired number of seconds
                        if int_one_second_counter = CLK_PERIODS_ONE_SECOND-1 then

                            -- Reset the counter
                            int_one_second_counter <= 0;
                            uns_counts_in_one_second_latched <= uns_counts_in_one_second_counter;

                            -- Is switched back to zero in the FSM below
                            sl_one_second_flag <= '1';

                            -- if wr_valid_gflow_success_done = '1' then
                            if sl_at_least_one_qubit_valid = '1' then
                            -- if sl_at_least_one_qubit_valid = '1' and to_integer(uns_counts_in_one_second_counter) < integer(uns_counts_in_one_second_counter'high**2-1) then
                            -- if sl_at_least_one_qubit_valid = '1' and uns_counts_in_one_second_counter < to_unsigned(uns_counts_in_one_second_counter'high**2-1, uns_counts_in_one_second_counter'length) then
                                uns_counts_in_one_second_counter 
                                    <= to_unsigned(1, uns_counts_in_one_second_counter'length);
                            else
                                uns_counts_in_one_second_counter <= (others => '0');
                            end if;

                        else
                            -- Increment both counters
                            int_one_second_counter <= int_one_second_counter + 1;

                            -- if wr_valid_gflow_success_done = '1' then
                            if sl_at_least_one_qubit_valid = '1' then
                            -- if sl_at_least_one_qubit_valid = '1' and to_integer(uns_counts_in_one_second_counter) < integer(uns_counts_in_one_second_counter'high**2-1) then
                            -- if sl_at_least_one_qubit_valid = '1' and uns_counts_in_one_second_counter < to_unsigned(uns_counts_in_one_second_counter'high**2-1, uns_counts_in_one_second_counter'length) then
                                uns_counts_in_one_second_counter 
                                    <= uns_counts_in_one_second_counter + 1;
                            end if;
                        end if;



                        -- Controller for sending data over USB3
                        case state_write_data_transac is
                            when WAIT_AND_SEND_DATA =>

                                -- Sample the data buffer values on valid, set write en, proceed
                                if wr_valid_gflow_success_done = '1' then
                                    -- Define All bits!
                                    slv_wr_data_stream_32b(31 downto 30) <= wr_data_qubit_buffer(3); -- Qubit 1
                                    slv_wr_data_stream_32b(29 downto 28) <= wr_data_qubit_buffer(2);
                                    slv_wr_data_stream_32b(27 downto 26) <= wr_data_qubit_buffer(1);
                                    slv_wr_data_stream_32b(25 downto 24) <= wr_data_qubit_buffer(0);

                                    slv_wr_data_stream_32b(23 downto 22) <= wr_data_alpha_buffer(3);
                                    slv_wr_data_stream_32b(21 downto 20) <= wr_data_alpha_buffer(2);
                                    slv_wr_data_stream_32b(19 downto 18) <= wr_data_alpha_buffer(1);
                                    slv_wr_data_stream_32b(17 downto 16) <= wr_data_alpha_buffer(0);

                                    slv_wr_data_stream_32b(15) <= wr_data_random_buffer(3);
                                    slv_wr_data_stream_32b(14) <= wr_data_random_buffer(2);
                                    slv_wr_data_stream_32b(13) <= wr_data_random_buffer(1);
                                    slv_wr_data_stream_32b(12) <= wr_data_random_buffer(0);

                                    slv_wr_data_stream_32b(11 downto 10) <= wr_data_modulo_buffer(3);
                                    slv_wr_data_stream_32b(9 downto 8) <= wr_data_modulo_buffer(2);
                                    slv_wr_data_stream_32b(7 downto 6) <= wr_data_modulo_buffer(1);
                                    slv_wr_data_stream_32b(5 downto 4) <= wr_data_modulo_buffer(0);

                                    -- Encoded command for the C++ backend: Get & Parse Data + Append to a file
                                    -- Command x"0" is forbidden
                                    slv_wr_data_stream_32b(3 downto 0) <= x"1";

                                    sl_wr_en_flag_pulsed <= '1';
                                    state_write_data_transac <= SEND_TIME_QUBIT1;

                                elsif sl_one_second_flag = '1' then
                                    -- Define All bits!
                                    slv_wr_data_stream_32b(31 downto 4) <= std_logic_vector(uns_counts_in_one_second_latched);

                                    -- Encoded command for the C++ backend: Print Time to Console Send directly to Redis Server
                                    -- Command x"0" is forbidden
                                    slv_wr_data_stream_32b(3 downto 0) <= x"4";

                                    -- Set the flag back to the default state after successful read
                                    sl_one_second_flag <= '0';

                                    -- Remain in this state
                                    sl_wr_en_flag_pulsed <= '1';
                                    state_write_data_transac <= WAIT_AND_SEND_DATA;
                                else
                                    sl_wr_en_flag_pulsed <= '0';
                                    state_write_data_transac <= WAIT_AND_SEND_DATA;
                                end if;

                            when SEND_TIME_QUBIT1 => 
                                -- Send time stamp of qubit 1 measured, set write en, proceed
                                -- Define All bits!
                                slv_wr_data_stream_32b(31 downto 4) <= slv_time_stamp_buffer_2d(3);

                                -- Encoded command for the C++ backend: Get Time + Append to a file
                                -- Command x"0" is forbidden
                                slv_wr_data_stream_32b(3 downto 0) <= x"2";

                                sl_wr_en_flag_pulsed <= '1';
                                state_write_data_transac <= SEND_TIME_QUBIT1_OVERFLOWS;

                            when SEND_TIME_QUBIT1_OVERFLOWS => 
                                -- Send time stamp of qubit 1 measured, set write en, proceed
                                -- Define All bits!
                                slv_wr_data_stream_32b(31 downto 4) <= slv_time_stamp_buffer_overflows_2d(3);

                                -- Encoded command for the C++ backend: Get Time + Append to a file
                                -- Command x"0" is forbidden
                                slv_wr_data_stream_32b(3 downto 0) <= x"2";

                                sl_wr_en_flag_pulsed <= '1';
                                state_write_data_transac <= SEND_TIME_QUBIT2;

                            when SEND_TIME_QUBIT2 => 
                                -- Send time stamp of qubit 2 measured, set write en, proceed
                                -- Define All bits!
                                slv_wr_data_stream_32b(31 downto 4) <= slv_time_stamp_buffer_2d(2);

                                -- Encoded command for the C++ backend: Get Time + Append to a file
                                -- Command x"0" is forbidden
                                slv_wr_data_stream_32b(3 downto 0) <= x"2";

                                sl_wr_en_flag_pulsed <= '1';
                                state_write_data_transac <= SEND_TIME_QUBIT2_OVERFLOWS;

                            when SEND_TIME_QUBIT2_OVERFLOWS => 
                                -- Send time stamp of qubit 1 measured, set write en, proceed
                                -- Define All bits!
                                slv_wr_data_stream_32b(31 downto 4) <= slv_time_stamp_buffer_overflows_2d(2);

                                -- Encoded command for the C++ backend: Get Time + Append to a file
                                -- Command x"0" is forbidden
                                slv_wr_data_stream_32b(3 downto 0) <= x"2";

                                sl_wr_en_flag_pulsed <= '1';
                                state_write_data_transac <= SEND_TIME_QUBIT3;

                            when SEND_TIME_QUBIT3 => 
                                -- Send time stamp of qubit 3 measured, set write en, proceed
                                -- Define All bits!
                                slv_wr_data_stream_32b(31 downto 4) <= slv_time_stamp_buffer_2d(1);

                                -- Encoded command for the C++ backend: Get Time + Append to a file
                                -- Command x"0" is forbidden
                                slv_wr_data_stream_32b(3 downto 0) <= x"2";

                                sl_wr_en_flag_pulsed <= '1';
                                state_write_data_transac <= SEND_TIME_QUBIT3_OVERFLOWS;

                            when SEND_TIME_QUBIT3_OVERFLOWS => 
                                -- Send time stamp of qubit 1 measured, set write en, proceed
                                -- Define All bits!
                                slv_wr_data_stream_32b(31 downto 4) <= slv_time_stamp_buffer_overflows_2d(1);

                                -- Encoded command for the C++ backend: Get Time + Append to a file
                                -- Command x"0" is forbidden
                                slv_wr_data_stream_32b(3 downto 0) <= x"2";

                                sl_wr_en_flag_pulsed <= '1';
                                state_write_data_transac <= SEND_TIME_QUBIT4;

                            when SEND_TIME_QUBIT4 => 
                                -- Send time stamp of qubit 4 measured, set write en, proceed
                                -- Define All bits!
                                slv_wr_data_stream_32b(31 downto 4) <= slv_time_stamp_buffer_2d(0);

                                -- Encoded command for the C++ backend: Get Time + Append to a file
                                -- Command x"0" is forbidden
                                slv_wr_data_stream_32b(3 downto 0) <= x"2";

                                sl_wr_en_flag_pulsed <= '1';
                                state_write_data_transac <= SEND_TIME_QUBIT4_OVERFLOWS;

                            when SEND_TIME_QUBIT4_OVERFLOWS => 
                                -- Send time stamp of qubit 1 measured, set write en, proceed
                                -- Define All bits!
                                slv_wr_data_stream_32b(31 downto 4) <= slv_time_stamp_buffer_overflows_2d(0);

                                -- Encoded command for the C++ backend: Get Time + Append to a file + New line char
                                -- Command x"0" is forbidden
                                slv_wr_data_stream_32b(3 downto 0) <= x"3";

                                sl_wr_en_flag_pulsed <= '1';
                                state_write_data_transac <= WAIT_AND_SEND_DATA;

                            when others =>
                                sl_wr_en_flag_pulsed <= '0';
                                state_write_data_transac <= WAIT_AND_SEND_DATA;

                        end case;
                    end if;
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
        end generate;

        -- For writing signals to fifo real time
        gen_write_on_valid_false : if WRITE_ON_VALID = false generate
            proc_endp_fifo_write_all : process(wr_sys_clk)
            begin
                if rising_edge(wr_sys_clk) then

                    -- DO NOT TOUCH: Default values
                    sl_wr_en <= '0';
                    sl_full_latched <= sl_full_latched;
                    slv_wr_data <= wr_data_stream_32b;

                    -- DO NOT TOUCH: FIFO Control: Write in the next clk cycle if fifo not full
                    if sl_full = '0' then
                        sl_wr_en <= '1';
                    else
                        sl_full_latched <= '1';
                    end if;

                end if;
            end process;
        end generate;


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