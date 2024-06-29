    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    library UNISIM;
    use UNISIM.VComponents.all;

    library lib_src;
    use lib_src.types_pack.all;

    entity universal_readout is
        generic (
            INT_CHANNEL_WIDTH : positive := 32;
            INT_QUBITS_CNT : positive := 4;
            RST_VAL : std_logic := '1';
            CLK_HZ : real := 100.0e6;
            REGULAR_SAMPLER_SECONDS : real := 1.0e-6;
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
    end universal_readout;

    architecture rtl of universal_readout is

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

        -- Channel Widths Breakdown
        constant INT_COMMAND_WIDTH : positive := 4;
        constant INT_DATA_SPACE_IN_CHANNEL : positive := INT_CHANNEL_WIDTH - INT_COMMAND_WIDTH;

        -- FIFO signals
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
        signal sl_full_latched : std_logic := '0';


        -- Regular monitoring counter
        constant PERIODIC_REPORT_CLK_PERIODS : natural := natural(REGULAR_SAMPLER_SECONDS * CLK_HZ);
        signal int_periodic_report_counter : integer range 0 to PERIODIC_REPORT_CLK_PERIODS-1 := 0;
        signal sl_periodic_report_flag : std_logic := '0';
        signal sl_readout_request_coincidences : std_logic := '0';
        signal sl_periodic_report_sample_request : std_logic_vector((INT_QUBITS_CNT**2)-1 downto 0) := (others => '0');

        -- Photon Combination Accumulation
        constant ACCUMULATOR_COUNTER_WIDTH : positive := 16; -- 65536 counts max
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

        -- Readout counter
        signal int_readout_counter : natural := 0;

        -- Samplers before transmission
        signal slv_combinations_counters_sampled : std_logic_vector(ACCUMULATOR_COUNTER_WIDTH*(INT_QUBITS_CNT**2)-1 downto 0) := (others => '0');
        signal slv_flow_photons_buffer_sampled : std_logic_vector(2*INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_flow_alpha_buffer_sampled : std_logic_vector(2*INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_flow_modulo_buffer_sampled : std_logic_vector(2*INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_flow_random_buffer_sampled : std_logic_vector(1*INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_flow_timestamp_buffer_sampled : std_logic_vector(28*INT_QUBITS_CNT-1 downto 0) := (others => '0');

        -- Shifters for data outflow
        signal slv_combinations_counters_shreg : std_logic_vector(ACCUMULATOR_COUNTER_WIDTH*(INT_QUBITS_CNT**2)-1 downto 0) := (others => '0');
        signal slv_flow_photons_buffer_shreg : std_logic_vector(slv_flow_photons_buffer_sampled'range) := (others => '0');
        signal slv_flow_alpha_buffer_shreg : std_logic_vector(slv_flow_alpha_buffer_sampled'range) := (others => '0');
        signal slv_flow_modulo_buffer_shreg : std_logic_vector(slv_flow_modulo_buffer_sampled'range) := (others => '0');
        signal slv_flow_random_buffer_shreg : std_logic_vector(slv_flow_random_buffer_sampled'range) := (others => '0');
        signal slv_flow_timestamp_buffer_shreg : std_logic_vector(slv_flow_timestamp_buffer_sampled'range) := (others => '0');

        signal sl_readout_request_gflow : std_logic := '0'; -- '1' value will be latched

        -- Notify the FSM to transfer data from samplers to shifters and perform the readout
        signal sl_request_read_coincidences_to_shreg : std_logic := '0';
        signal sl_request_read_photons_to_shreg : std_logic := '0';
        signal sl_request_read_alpha_to_shreg : std_logic := '0';
        signal sl_request_read_modulo_to_shreg : std_logic := '0';
        signal sl_request_read_random_to_shreg : std_logic := '0';
        signal sl_request_read_timestamp_to_shreg : std_logic := '0';

        type t_state_write_data_transac is (
            SCAN_READOUT_REQUESTS,
            SEND_COINCIDENCES,
            SEND_GFLOW_PHOTONS,
            SEND_GFLOW_ALPHA,
            SEND_GFLOW_MODULO,
            SEND_GFLOW_RANDOM,
            SEND_GFLOW_TIMESTAMP
        );
        signal state_fifo_readout : t_state_write_data_transac := SCAN_READOUT_REQUESTS;


        function slv_shift_right (
            slv_shifter : std_logic_vector;
            SHIFT_BY_X_BITS : positive := 1
        ) return std_logic_vector is 
        begin
            return std_logic_vector(to_unsigned(0, SHIFT_BY_X_BITS))
                & slv_shifter(slv_shifter'high downto SHIFT_BY_X_BITS);
        end function;

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

        ----------------------------------
        -- Samplers Before Transmission --
        ----------------------------------
        proc_sample_photons_buffer : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then
                -- Shift right by default
                slv_flow_photons_buffer_shreg <= 
                    slv_shift_right(slv_flow_photons_buffer_shreg, 2);

                if wr_valid_gflow_success_done = '1' then
                    for i in 0 to INT_QUBITS_CNT-1 loop
                        slv_flow_photons_buffer_sampled((i+1)*2-1 downto i*2) 
                            <= wr_data_qubit_buffer(i);
                    end loop;
                end if;
            end if;

            -- Set Shreg readout pipe on to_shreg request
            if sl_request_read_photons_to_shreg = '1' then -- This must be 1 clk long pulse
                slv_flow_photons_buffer_shreg <= slv_flow_photons_buffer_sampled;
            end if;
        end process;

        proc_sample_alpha_buffer : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then
                -- Shift right by default
                slv_flow_alpha_buffer_shreg <= 
                    slv_shift_right(slv_flow_alpha_buffer_shreg, 2);

                if wr_valid_gflow_success_done = '1' then
                    for i in 0 to INT_QUBITS_CNT-1 loop
                        slv_flow_alpha_buffer_sampled((i+1)*2-1 downto i*2) 
                            <= wr_data_alpha_buffer(i);
                    end loop;
                end if;
            end if;

            -- Set Shreg readout pipe on to_shreg request
            if sl_request_read_alpha_to_shreg = '1' then -- This must be 1 clk long pulse
                slv_flow_alpha_buffer_shreg <= slv_flow_alpha_buffer_sampled;
            end if;
        end process;

        proc_sample_modulo_buffer_readout : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then
                -- Shift right by default
                slv_flow_modulo_buffer_shreg <= 
                    slv_shift_right(slv_flow_modulo_buffer_shreg, 2);

                if wr_valid_gflow_success_done = '1' then
                    for i in 0 to INT_QUBITS_CNT-1 loop
                        slv_flow_modulo_buffer_sampled((i+1)*2-1 downto i*2) 
                            <= wr_data_modulo_buffer(i);
                    end loop;
                end if;
            end if;

            -- Set Shreg readout pipe on to_shreg request
            if sl_request_read_modulo_to_shreg = '1' then -- This must be 1 clk long pulse
                slv_flow_modulo_buffer_shreg <= slv_flow_modulo_buffer_sampled;
            end if;
        end process;

        proc_sample_random_buffer : process(wr_sys_clk)
        begin
            -- Shift right by default
            slv_flow_random_buffer_shreg <= 
                slv_shift_right(slv_flow_random_buffer_shreg, 1);

            if rising_edge(wr_sys_clk) then
                if wr_valid_gflow_success_done = '1' then
                    for i in 0 to INT_QUBITS_CNT-1 loop
                        slv_flow_random_buffer_sampled((i+1)*1-1 downto i*1) 
                            <= wr_data_random_buffer(i);
                    end loop;
                end if;
            end if;

            -- Set Shreg readout pipe on to_shreg request
            if sl_request_read_random_to_shreg = '1' then -- This must be 1 clk long pulse
                slv_flow_random_buffer_shreg <= slv_flow_random_buffer_sampled;
            end if;
        end process;

        proc_sample_timestamp_buffer : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then
                -- Shift right by default
                slv_flow_timestamp_buffer_shreg <= 
                    slv_shift_right(slv_flow_timestamp_buffer_shreg, 2);

                -- Sample on sample request
                if wr_valid_gflow_success_done = '1' then
                    for i in 0 to INT_QUBITS_CNT-1 loop
                        slv_flow_timestamp_buffer_sampled((i+1)*28-1 downto i*28)
                            <= wr_data_time_stamp_buffer(i);
                    end loop;
                end if;

                -- Set Shreg readout pipe on to_shreg request
                if sl_request_read_timestamp_to_shreg = '1' then -- This must be 1 clk long pulse
                    slv_flow_timestamp_buffer_shreg <= slv_flow_timestamp_buffer_sampled;
                end if;
            end if;
        end process;

        proc_sample_accumulated_values : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then
                -- Shift right by default
                slv_combinations_counters_shreg <= 
                    slv_shift_right(slv_combinations_counters_shreg, ACCUMULATOR_COUNTER_WIDTH);

                -- Sample on sample request
                for i in 0 to INT_QUBITS_CNT**2-1 loop
                    if sl_periodic_report_sample_request(i) = '1' then
                            slv_combinations_counters_sampled((i+1)*ACCUMULATOR_COUNTER_WIDTH-1 downto i*ACCUMULATOR_COUNTER_WIDTH) 
                                <= slv_combinations_counters_2d(i);
                    end if;
                end loop;

                -- Set Shreg readout pipe on to_shreg request
                if sl_request_read_coincidences_to_shreg = '1' then -- This must be 1 clk long pulse
                    slv_combinations_counters_shreg <= slv_combinations_counters_sampled;
                end if;
            end if;
        end process;

        -- Sample the data buffers and make them stable, since they change over time
        -- Then, prepare transactions and send them one by one to the fifo
        proc_transaction : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then
                -- Tie to 0
                sl_wr_en_flag_pulsed <= '0';

                -- Queued Requests
                if wr_valid_gflow_success_done = '1' then
                    sl_readout_request_gflow <= wr_valid_gflow_success_done;
                end if;

                if sl_periodic_report_flag = '1' then
                    sl_readout_request_coincidences <= sl_periodic_report_flag;
                end if;


                -- -- Sample the time stamp buffer values to read from later
                -- if wr_valid_gflow_success_done = '1' then
                --     slv_time_stamp_buffer_2d <= wr_data_time_stamp_buffer;
                -- end if;


                -- Counter to send a value per desired number of seconds
                if int_periodic_report_counter = PERIODIC_REPORT_CLK_PERIODS-1 then
                    int_periodic_report_counter <= 0;
                    sl_periodic_report_flag <= '1';
                    sl_periodic_report_sample_request <= (others => '1');
                else
                    int_periodic_report_counter <= int_periodic_report_counter + 1;
                    sl_periodic_report_flag <= '0';
                    sl_periodic_report_sample_request <= (others => '0');
                end if;



                -- Controller for sending data over USB3
                case state_fifo_readout is
                    when SCAN_READOUT_REQUESTS => 

                        -- (Lower Priority) Wait for periodic report readout request
                        if sl_readout_request_coincidences = '1' then
                            state_fifo_readout <= SEND_COINCIDENCES;
                            sl_request_read_coincidences_to_shreg <= '1'; -- Must be 1 clk long pulse
                        end if;

                        -- (Higher Priority) Wait for gflow report readout request
                        if sl_readout_request_gflow = '1' then
                            state_fifo_readout <= SEND_GFLOW_PHOTONS;
                            sl_request_read_photons_to_shreg <= '1'; -- Must be 1 clk long pulse
                        end if;


                    when SEND_COINCIDENCES =>

                        sl_request_read_coincidences_to_shreg <= '0'; -- Must be 1 clk pulse

                        -- Send periodic report in a way it has a higher priority over the 'sl_readout_request_gflow' but does not interfere with it
                        if int_readout_counter = INT_QUBITS_CNT**2 then
                            int_readout_counter <= 0;
                            sl_wr_en_flag_pulsed <= '0'; -- Writing to FIFO shut down

                            -- Send comma or something like that
                            -- # TODO

                            state_fifo_readout <= SCAN_READOUT_REQUESTS; -- Coordinate the readout logic
                            sl_readout_request_coincidences <= '0'; -- Job done indication
                        else
                            int_readout_counter <= int_readout_counter + 1;
                            sl_wr_en_flag_pulsed <= '1';

                            slv_wr_data_stream_32b(31 downto 4) -- Define All bits!
                                <= std_logic_vector(to_unsigned(0, INT_DATA_SPACE_IN_CHANNEL-ACCUMULATOR_COUNTER_WIDTH)) 
                                    & slv_combinations_counters_shreg(ACCUMULATOR_COUNTER_WIDTH-1 downto 0);

                            slv_wr_data_stream_32b(3 downto 0) <= x"6"; -- Encoded command for the RX counterpart

                        end if;


                    when SEND_GFLOW_PHOTONS => 
                        sl_request_read_photons_to_shreg <= '0'; -- Must be 1 clk pulse

                        -- Send periodic report in a way it has a higher priority over the 'sl_readout_request_gflow' but does not interfere with it
                        if int_readout_counter = INT_QUBITS_CNT then
                            int_readout_counter <= 0;
                            sl_wr_en_flag_pulsed <= '0'; -- Writing to FIFO shut down

                            -- Send comma or something like that
                            -- # TODO

                            state_fifo_readout <= SEND_GFLOW_ALPHA; -- Coordinate the readout logic
                            sl_request_read_alpha_to_shreg <= '1'; -- 1 clk long pulse
                            -- sl_readout_request_gflow <= '0'; -- Job done indication
                        else
                            int_readout_counter <= int_readout_counter + 1;
                            sl_wr_en_flag_pulsed <= '1';

                            slv_wr_data_stream_32b(31 downto 4) -- Define All bits!
                                <= std_logic_vector(to_unsigned(0, INT_DATA_SPACE_IN_CHANNEL-2))
                                    & slv_flow_photons_buffer_shreg(2-1 downto 0);

                            slv_wr_data_stream_32b(3 downto 0) <= x"1"; -- Encoded command for the RX counterpart

                        end if;


                    when SEND_GFLOW_ALPHA =>
                        sl_request_read_alpha_to_shreg <= '0'; -- Must be 1 clk pulse

                        -- Send periodic report in a way it has a higher priority over the 'sl_readout_request_gflow' but does not interfere with it
                        if int_readout_counter = INT_QUBITS_CNT then
                            int_readout_counter <= 0;
                            sl_wr_en_flag_pulsed <= '0'; -- Writing to FIFO shut down
                            
                            -- Send comma or something like that
                            -- # TODO

                            state_fifo_readout <= SEND_GFLOW_MODULO; -- Coordinate the readout logic
                            sl_request_read_modulo_to_shreg <= '1';
                            -- sl_readout_request_gflow <= '0'; -- Job done indication
                        else
                            int_readout_counter <= int_readout_counter + 1;
                            sl_wr_en_flag_pulsed <= '1';

                            slv_wr_data_stream_32b(31 downto 4) -- Define All bits!
                                <= std_logic_vector(to_unsigned(0, INT_DATA_SPACE_IN_CHANNEL-2))
                                    & slv_flow_alpha_buffer_shreg(2-1 downto 0);

                            slv_wr_data_stream_32b(3 downto 0) <= x"2"; -- Encoded command for the RX counterpart

                        end if;

                    when SEND_GFLOW_MODULO =>
                        sl_request_read_modulo_to_shreg <= '0'; -- Must be 1 clk pulse

                        -- Send periodic report in a way it has a higher priority over the 'sl_readout_request_gflow' but does not interfere with it
                        if int_readout_counter = INT_QUBITS_CNT then
                            int_readout_counter <= 0;
                            sl_wr_en_flag_pulsed <= '0'; -- Writing to FIFO shut down
                            
                            -- Send comma or something like that
                            -- # TODO

                            state_fifo_readout <= SEND_GFLOW_RANDOM; -- Coordinate the readout logic
                            sl_request_read_random_to_shreg <= '1';
                            -- sl_readout_request_gflow <= '0'; -- Job done indication
                        else
                            int_readout_counter <= int_readout_counter + 1;
                            sl_wr_en_flag_pulsed <= '1';

                            slv_wr_data_stream_32b(31 downto 4) -- Define All bits!
                                <= std_logic_vector(to_unsigned(0, INT_DATA_SPACE_IN_CHANNEL-2))
                                    & slv_flow_modulo_buffer_shreg(2-1 downto 0);

                            slv_wr_data_stream_32b(3 downto 0) <= x"3"; -- Encoded command for the RX counterpart

                        end if;

                    when SEND_GFLOW_RANDOM =>
                        sl_request_read_random_to_shreg <= '0'; -- Must be 1 clk pulse

                        -- Send periodic report in a way it has a higher priority over the 'sl_readout_request_gflow' but does not interfere with it
                        if int_readout_counter = INT_QUBITS_CNT then
                            int_readout_counter <= 0;
                            sl_wr_en_flag_pulsed <= '0'; -- Writing to FIFO shut down
                            
                            -- Send comma or something like that
                            -- # TODO

                            state_fifo_readout <= SEND_GFLOW_TIMESTAMP; -- Coordinate the readout logic
                            sl_request_read_timestamp_to_shreg <= '1';
                            -- sl_readout_request_gflow <= '0'; -- Job done indication
                        else
                            int_readout_counter <= int_readout_counter + 1;
                            sl_wr_en_flag_pulsed <= '1';

                            slv_wr_data_stream_32b(31 downto 4) -- Define All bits!
                                <= std_logic_vector(to_unsigned(0, INT_DATA_SPACE_IN_CHANNEL-1))
                                    & slv_flow_random_buffer_shreg(1-1 downto 0);

                            slv_wr_data_stream_32b(3 downto 0) <= x"4"; -- Encoded command for the RX counterpart

                        end if;

                    when SEND_GFLOW_TIMESTAMP =>
                        sl_request_read_timestamp_to_shreg <= '0'; -- Must be 1 clk pulse

                        -- Send periodic report in a way it has a higher priority over the 'sl_readout_request_gflow' but does not interfere with it
                        if int_readout_counter = INT_QUBITS_CNT then
                            int_readout_counter <= 0;
                            sl_wr_en_flag_pulsed <= '0'; -- Writing to FIFO shut down
                            
                            -- Send comma or something like that
                            -- # TODO

                            state_fifo_readout <= SCAN_READOUT_REQUESTS; -- Coordinate the readout logic
                            -- sl_request_read_timestamp_to_shreg <= '1';
                            sl_readout_request_gflow <= '0'; -- Job done indication
                        else
                            int_readout_counter <= int_readout_counter + 1;
                            sl_wr_en_flag_pulsed <= '1';

                            -- slv_wr_data_stream_32b(31 downto 4) -- Define All bits!
                            --     <= std_logic_vector(to_unsigned(0, INT_DATA_SPACE_IN_CHANNEL-28))
                            --         & slv_flow_timestamp_buffer_shreg(28-1 downto 0);
                            slv_wr_data_stream_32b(31 downto 4) -- Define All bits!
                                <= slv_flow_timestamp_buffer_shreg(28-1 downto 0);

                            slv_wr_data_stream_32b(3 downto 0) <= x"5"; -- Encoded command for the RX counterpart

                        end if;

                    when others =>
                        sl_wr_en_flag_pulsed <= '0';
                        state_fifo_readout <= SCAN_READOUT_REQUESTS;
                        
                        -- Set next transaction request to zero, wait to be asserted once next cluster has been measured
                        sl_readout_request_gflow <= '0';

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