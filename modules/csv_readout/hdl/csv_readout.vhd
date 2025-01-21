    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    library UNISIM;
    use UNISIM.VComponents.all;

    library lib_src;
    use lib_src.types_pack.all;

    entity csv_readout is
        generic (
            INT_QUBITS_CNT : positive := 4;
            INT_NUMBER_OF_GFLOWS : natural := 9;
            CLK_HZ : real := 100.0e6;
            REGULAR_SAMPLER_SECONDS : real := 1.0e-6;
            REGULAR_SAMPLER_SECONDS_2 : real := 2.0e-6
        );
        port (
            -- Reset, write clock
            wr_rst : in std_logic;
            rd_rst : in std_logic;

            wr_sys_clk : in std_logic;

            -- Data Signals
            wr_channels_detections : in t_photon_counter_2d;
            wr_photon_losses : in std_logic_vector(INT_QUBITS_CNT-2 downto 0);
            wr_valid_feedfwd_success_done : in std_logic;
            wr_data_qubit_buffer : in t_qubit_buffer_2d;
            wr_data_time_stamp_buffer : in t_time_stamp_buffer_2d;
            wr_data_alpha_buffer : in t_alpha_buffer_2d;
            wr_data_modulo_buffer : in t_modulo_buffer_2d;
            wr_data_random_buffer : in t_random_buffer_2d;
            wr_data_actual_gflow_buffer : in std_logic_vector(
                integer(ceil(log2(real(INT_NUMBER_OF_GFLOWS+1))))-1 downto 0);

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
    end csv_readout;

    architecture rtl of csv_readout is

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
        constant INT_CHANNEL_WIDTH : positive := 32;
        constant INT_COMMAND_WIDTH : positive := 4;
        constant INT_DATA_SPACE_IN_CHANNEL : positive := INT_CHANNEL_WIDTH - INT_COMMAND_WIDTH;

        -- Actual time counter
        constant ACTUAL_TIME_COUNTER_WIDTH : natural := INT_DATA_SPACE_IN_CHANNEL;
        signal slv_time_now : std_logic_vector(2*ACTUAL_TIME_COUNTER_WIDTH-1 downto 0) := (others => '0');
        signal slv_time_feedfwd_sample_request : std_logic_vector(slv_time_now'range) := (others => '0');
        signal slv_time_periodic_sample_request : std_logic_vector(slv_time_now'range) := (others => '0');
        signal slv_time_periodic_sample_request_2 : std_logic_vector(slv_time_now'range) := (others => '0');

        -- FIFO signals
        signal rst_wr_and_rd   : std_logic := '0';
        signal wr_clk          : std_logic := '0';
        signal sl_wr_en        : std_logic := '0';
        signal slv_wr_data     : std_logic_vector(31 downto 0) := (others => '0');
        signal rd_clk          : std_logic := '0';
        signal sl_rd_valid     : std_logic := '0';
        signal slv_rd_data_out : std_logic_vector(31 downto 0) := (others => '0');
        signal sl_full         : std_logic := '0';
        signal sl_empty        : std_logic := '0';
        signal sl_prog_empty   : std_logic := '0';


        -- User logic endpoint write logic
        signal sl_wr_en_flag_pulsed : std_logic := '0';
        signal slv_wr_data_stream_32b : std_logic_vector(32-1 downto 0) := (others => '0');
        signal sl_full_latched : std_logic := '0';


        -- Regular monitoring counter 1
        constant PERIODIC_REPORT_CLK_PERIODS : natural := natural(REGULAR_SAMPLER_SECONDS * CLK_HZ);
        constant PERIODIC_REPORT_CLK_BITS : natural := integer(ceil(log2(real(PERIODIC_REPORT_CLK_PERIODS+1))));
        signal int_periodic_report_counter : integer := 0;
        signal slv_periodic_report_counter : std_logic_vector((2*INT_DATA_SPACE_IN_CHANNEL)-1 downto 0) := (others => '0');
        signal sl_periodic_report_flag : std_logic := '0';
        signal sl_readout_request_periodic : std_logic := '0';
        signal sl_periodic_report_sample_request : std_logic_vector((INT_QUBITS_CNT**2)-1 downto 0) := (others => '0');

        -- Regular monitoring counter 1
        constant PERIODIC_REPORT_CLK_PERIODS_2 : natural := natural(REGULAR_SAMPLER_SECONDS_2 * CLK_HZ);
        constant PERIODIC_REPORT_CLK_BITS_2 : natural := integer(ceil(log2(real(PERIODIC_REPORT_CLK_PERIODS_2+1))));
        signal int_periodic_report_counter_2 : integer := 0;
        signal slv_periodic_report_counter_2 : std_logic_vector((2*INT_DATA_SPACE_IN_CHANNEL)-1 downto 0) := (others => '0');
        signal sl_periodic_report_flag_2 : std_logic := '0';
        signal sl_readout_request_periodic_2 : std_logic := '0';
        signal sl_periodic_report_sample_request_2 : std_logic_vector((INT_QUBITS_CNT*2)-1 downto 0) := (others => '0');

        -- Photon Coincidences Combination Accumulation
        constant COINCIDENCE_PATTERN_ACC_WIDTH : positive := 16; -- 65536 counts max
        type t_all_combinations_2d is array(INT_QUBITS_CNT**2-1 downto 0) of natural;
        type t_all_coincidences_combinations_2d is array(INT_QUBITS_CNT**2-1 downto 0) of std_logic_vector(COINCIDENCE_PATTERN_ACC_WIDTH-1 downto 0);
        impure function get_all_combinations_qubits return t_all_combinations_2d is
            variable v_all_combinations_2d : t_all_combinations_2d := (others => 0);
        begin
            for i in 0 to INT_QUBITS_CNT**2-1 loop
                v_all_combinations_2d(i) := i;
            end loop;
            return v_all_combinations_2d;
        end function;
        constant COMBINATION_ADDR : t_all_combinations_2d := get_all_combinations_qubits;
        signal slv_combinations_counters_2d : t_all_coincidences_combinations_2d := (others => (others => '0'));
        signal slv_higher_bits_qubit_buffer : std_logic_vector(INT_QUBITS_CNT-1 downto 0) := (others => '0');

        -- All channels detections accumulator
        constant ALL_CH_DETECTIONS_ACC_WIDTH : positive := 32-4;
        type t_all_channels_detections_2d is array(INT_QUBITS_CNT*2-1 downto 0) of std_logic_vector(ALL_CH_DETECTIONS_ACC_WIDTH-1 downto 0);
        signal slv_all_channels_detections_2d : t_all_channels_detections_2d := (others => (others => '0'));
        signal sl_overflow_counter : std_logic := '0';
        signal slv_last_bit_p1 : std_logic_vector(INT_QUBITS_CNT*2-1 downto 0) := (others => '0');

        -- Photon Miss / Photon Loss accumulator
        constant ALL_PHOTON_LOSSES_ACC_WIDTH : positive := 32-4; -- 65536 counts max
        type t_all_unsuccessful_coincidences_2d is array(INT_QUBITS_CNT-2 downto 0) of std_logic_vector(ALL_PHOTON_LOSSES_ACC_WIDTH-1 downto 0);
        signal slv_all_unsuccessful_coincidences_2d : t_all_unsuccessful_coincidences_2d := (others => (others => '0'));

        -- Readout counter
        signal int_readout_counter : natural := 0;

        -- Samplers before transmission # TODO?
        signal slv_combinations_counters_sampled : std_logic_vector(COINCIDENCE_PATTERN_ACC_WIDTH*(INT_QUBITS_CNT**2)-1 downto 0) := (others => '0');
        signal slv_ch_detections_sampled : std_logic_vector(ALL_CH_DETECTIONS_ACC_WIDTH*(INT_QUBITS_CNT*2)-1 downto 0) := (others => '0');
        signal slv_photon_losses_sampled : std_logic_vector(ALL_PHOTON_LOSSES_ACC_WIDTH*(INT_QUBITS_CNT-1)-1 downto 0) := (others => '0');
        signal slv_flow_photons_buffer_sampled : std_logic_vector(2*INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_flow_alpha_buffer_sampled : std_logic_vector(2*INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_flow_modulo_buffer_sampled : std_logic_vector(2*INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_flow_random_buffer_sampled : std_logic_vector(1*INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_flow_timestamp_buffer_sampled : std_logic_vector(INT_DATA_SPACE_IN_CHANNEL*(INT_QUBITS_CNT+1)-1 downto 0) := (others => '0');
        -- signal slv_flow_actual_gflow_buffer_sampled : std_logic_vector(2*INT_QUBITS_CNT-1 downto 0) := (others => '0');

        -- Shifters for data outflow
        signal slv_combinations_counters_shreg : std_logic_vector(COINCIDENCE_PATTERN_ACC_WIDTH*(INT_QUBITS_CNT**2)-1 downto 0) := (others => '0');
        signal slv_ch_detections_shreg : std_logic_vector(ALL_CH_DETECTIONS_ACC_WIDTH*(INT_QUBITS_CNT*2)-1 downto 0) := (others => '0');
        signal slv_photon_losses_shreg : std_logic_vector(ALL_PHOTON_LOSSES_ACC_WIDTH*(INT_QUBITS_CNT-1)-1 downto 0) := (others => '0');
        signal slv_flow_photons_buffer_shreg : std_logic_vector(slv_flow_photons_buffer_sampled'range) := (others => '0');
        signal slv_flow_alpha_buffer_shreg : std_logic_vector(slv_flow_alpha_buffer_sampled'range) := (others => '0');
        signal slv_flow_modulo_buffer_shreg : std_logic_vector(slv_flow_modulo_buffer_sampled'range) := (others => '0');
        signal slv_flow_random_buffer_shreg : std_logic_vector(slv_flow_random_buffer_sampled'range) := (others => '0');
        signal slv_flow_timestamp_buffer_shreg : std_logic_vector(slv_flow_timestamp_buffer_sampled'range) := (others => '0');
        signal slv_flow_actual_gflow_buffer_shreg : std_logic_vector(28-1 downto 0) := (others => '0');

        signal sl_readout_request_feedfwd : std_logic := '0'; -- '1' value will be latched

        -- Notify the FSM to transfer data from samplers to shifters and perform the readout
        signal sl_request_read_coincidences_shift_enable : std_logic := '0';
        signal sl_request_read_ch_detections_shift_enable : std_logic := '0';
        signal sl_request_read_photon_losses_shift_enable : std_logic := '0';
        signal sl_request_read_photons_shift_enable : std_logic := '0';
        signal sl_request_read_alpha_shift_enable : std_logic := '0';
        signal sl_request_read_modulo_shift_enable : std_logic := '0';
        signal sl_request_read_random_shift_enable : std_logic := '0';
        signal sl_request_read_timestamp_shift_enable : std_logic := '0';

        type t_state_write_data_transac is (
            SCAN_READOUT_REQUESTS,
            SEND_COINCIDENCES,
            SEND_CH_DETECTIONS,
            SEND_PHOTON_LOSSES,
            SEND_GFLOW_PHOTONS,
            SEND_GFLOW_NUMBER,
            SEND_GFLOW_ALPHA,
            SEND_GFLOW_MODULO,
            SEND_GFLOW_RANDOM,
            SEND_FEEDFWD_TIMESTAMP,
            SEND_FEEDFWD_TIMESTAMP_OVERFLOW,
            SEND_PERIODIC1_TIMESTAMP_OVERFLOW,
            SEND_PERIODIC2_TIMESTAMP_OVERFLOW
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

        -- Legend for bits (3 downto 0) in slv_wr_data_stream_32b
        -- x"0" = Do not use
        -- x"1" = SEND_GFLOW_PHOTONS    (multi-transactional readout start on event)
        -- x"2" = SEND_GFLOW_ALPHA      (continues the x"1")
        -- x"3" = SEND_GFLOW_ALPHA      (continues the x"2")
        -- x"4" = SEND_GFLOW_MODULO     (continues the x"3")
        -- x"5" = SEND_GFLOW_RANDOM     (continues the x"4")
        -- x"6" = SEND_FEEDFWD_TIMESTAMP (continues the x"5")
        -- x"7" = SEND_COINCIDENCES     (periodical readout)
        -- x"8" = SEND_CH_DETECTIONS    (periodical readout)
        -- x"9" = SEND_PHOTON_LOSSES    (periodical readout)
        -- x"A" = FPGA time (match with active output file)
        -- x"B" = available
        -- x"C" = available
        -- x"D" = available
        -- x"E" = EXTRA COMMA DELIMITER
        -- x"F" = ENTER (PRINT LINE), FPGA time overflow


        -----------------
        -- ACTUAL TIME --
        -----------------
        proc_slv_time_now : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then
                if wr_rst = '1' then
                    slv_time_now <= (others => '0');
                    slv_time_feedfwd_sample_request <= (others => '0');
                    slv_time_periodic_sample_request <= (others => '0');
                    slv_time_periodic_sample_request_2 <= (others => '0');
                else
                    slv_time_now <= std_logic_vector(unsigned(slv_time_now) + "1");

                    -- Sample actual time along with sample requests
                    if wr_valid_feedfwd_success_done = '1' then
                        slv_time_feedfwd_sample_request <= slv_time_now;
                    end if;

                    if sl_periodic_report_sample_request(sl_periodic_report_sample_request'high) = '1' then
                        slv_time_periodic_sample_request <= slv_time_now;
                    end if;

                    if sl_periodic_report_sample_request_2(sl_periodic_report_sample_request_2'high) = '1' then
                        slv_time_periodic_sample_request_2 <= slv_time_now;
                    end if;

                end if;
            end if;
        end process;


        -------------------------------------
        -- Dual-port Native FIFO Generator --
        -------------------------------------
        rst_wr_and_rd <= rd_rst or wr_rst;
        fifo_full <= sl_full;
        fifo_empty <= sl_empty;
        fifo_prog_empty <= sl_prog_empty;
        fifo_full_latched <= sl_full_latched;

        inst_native_fifo_generator : fifo_generator_0
        port map (
            -- Reset combining both write and read reset strobes
            rst    => rst_wr_and_rd,

            -- Write: faster CLK, slower rate
            wr_clk => wr_sys_clk,
            wr_en  => sl_wr_en,
            din    => slv_wr_data,

            -- Read: slower CLK, faster rate
            rd_clk => readout_clk,
            rd_en  => readout_enable,
            valid  => sl_rd_valid,
            dout   => slv_rd_data_out,

            -- Flags
            full   => sl_full,
            empty  => sl_empty,
            prog_empty => sl_prog_empty -- Programmable Empty Level indicator set to 5
        );


        -------------------------------------------
        -- COINCIDENCES COMBINATION ACCUMULATION --
        -------------------------------------------
        gen_pick_higher_bits : for i in 0 to INT_QUBITS_CNT-1 generate
            -- slv_higher_bits_qubit_buffer(i) <= wr_data_qubit_buffer(i)(1);

            -- CONVERT TO CONVENTIONAL H/V(=0/1) from H/V(=1/0) NOTATION
            slv_higher_bits_qubit_buffer(i) <= not wr_data_qubit_buffer(i)(1); -- NEW
        end generate;

        proc_qubit_combination_accum : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then
                if wr_valid_feedfwd_success_done = '1' then
                    for i in 0 to INT_QUBITS_CNT**2-1 loop
                        if std_logic_vector(to_unsigned(COMBINATION_ADDR(i), INT_QUBITS_CNT)) = slv_higher_bits_qubit_buffer then
                            slv_combinations_counters_2d(COMBINATION_ADDR(i)) 
                                <= std_logic_vector(unsigned(slv_combinations_counters_2d(COMBINATION_ADDR(i))) + "1");
                        end if;
                    end loop;
                end if;
            end if;
        end process;

        ------------------------------------------
        -- ALL CHANNELS DETECTIONS ACCUMULATION --
        ------------------------------------------
        gen_channels_detections_accumulator : for i in 0 to INT_QUBITS_CNT*2-1 generate
            proc_channels_detections_accumulator : process (wr_sys_clk)
            begin
                if rising_edge(wr_sys_clk) then
                    -- Delay last bit to detect counter overflow (falling edge)
                    slv_last_bit_p1(i) <= wr_channels_detections(i)(0);

                    -- Increment on last bit overflow (falling edge of the MSB), append counter's bits into lower bits to form the wider counter for readout
                    if sl_periodic_report_sample_request_2(i) = '1' then
                        slv_all_channels_detections_2d(i)(ALL_CH_DETECTIONS_ACC_WIDTH-1 downto 1) 
                            <= (others => '0');
                        slv_all_channels_detections_2d(i)(0) <= slv_last_bit_p1(i) and not wr_channels_detections(i)(0);

                    elsif slv_last_bit_p1(i) = '1' and wr_channels_detections(i)(0) = '0' then
                        slv_all_channels_detections_2d(i)(ALL_CH_DETECTIONS_ACC_WIDTH-1 downto 0) 
                            <= std_logic_vector(unsigned(slv_all_channels_detections_2d(i)(ALL_CH_DETECTIONS_ACC_WIDTH-1 downto 0)) + "1");
                    end if;
                end if;
            end process;
        end generate;


        -------------------------------------
        -- PHOTON MISS / LOSS ACCUMULATION --
        -------------------------------------
        gen_photon_loss_accumulator : for i in 0 to INT_QUBITS_CNT-2 generate
            proc_photon_loss_accumulator : process (wr_sys_clk)
            begin
                if rising_edge(wr_sys_clk) then
                    -- Report losses only per certain period of time
                    if sl_periodic_report_sample_request_2(i) = '1' then
                        slv_all_unsuccessful_coincidences_2d(i) <= (others => '0');
                        slv_all_unsuccessful_coincidences_2d(i)(0) <= wr_photon_losses(i);
                    elsif wr_photon_losses(i) = '1' then
                        slv_all_unsuccessful_coincidences_2d(i) <= std_logic_vector(unsigned(slv_all_unsuccessful_coincidences_2d(i)) + "1");
                    end if;
                end if;
            end process;
        end generate;


        ----------------------------------
        -- Samplers Before Transmission --
        ----------------------------------
        proc_sample_photons_buffer : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then

                -- Sample on sample request
                if wr_valid_feedfwd_success_done = '1' then -- Sample request signal
                    for i in 0 to INT_QUBITS_CNT-1 loop
                        slv_flow_photons_buffer_shreg((i+1)*2-1 downto i*2) 
                            <= wr_data_qubit_buffer(i);
                    end loop;
                end if;

                -- Shift right by a certain number of bits on enable
                if sl_request_read_photons_shift_enable = '1' then
                    slv_flow_photons_buffer_shreg <= 
                        slv_shift_right(slv_flow_photons_buffer_shreg, 2);
                end if;
            end if;
        end process;

        proc_sample_actual_gflow_buffer : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then

                -- Sample on sample request
                if wr_valid_feedfwd_success_done = '1' then -- Sample request signal
                    slv_flow_actual_gflow_buffer_shreg(wr_data_actual_gflow_buffer'range)
                        <= wr_data_actual_gflow_buffer;
                end if;

                -- Shift right by a certain number of bits on enable
                -- Nothing to shift here, data is not split into qubit cnt
                
            end if;
        end process;

        proc_sample_alpha_buffer : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then

                -- Sample on sample request
                if wr_valid_feedfwd_success_done = '1' then -- Sample request signal
                    for i in 0 to INT_QUBITS_CNT-1 loop
                        slv_flow_alpha_buffer_shreg((i+1)*2-1 downto i*2) 
                            <= wr_data_alpha_buffer(i);
                    end loop;
                end if;

                -- Shift right by a certain number of bits on enable
                if sl_request_read_alpha_shift_enable = '1' then
                    slv_flow_alpha_buffer_shreg <= 
                        slv_shift_right(slv_flow_alpha_buffer_shreg, 2);
                end if;
            end if;
        end process;

        proc_sample_modulo_buffer_readout : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then

                -- Sample on sample request
                if wr_valid_feedfwd_success_done = '1' then -- Sample request signal
                    for i in 0 to INT_QUBITS_CNT-1 loop
                        slv_flow_modulo_buffer_shreg((i+1)*2-1 downto i*2) 
                            <= wr_data_modulo_buffer(i);
                    end loop;
                end if;

                -- Shift right by a certain number of bits on enable
                if sl_request_read_modulo_shift_enable = '1' then
                    slv_flow_modulo_buffer_shreg <= 
                        slv_shift_right(slv_flow_modulo_buffer_shreg, 2);
                end if;
            end if;
        end process;

        proc_sample_random_buffer : process(wr_sys_clk)
        begin

            if rising_edge(wr_sys_clk) then

                -- Sample on sample request
                if wr_valid_feedfwd_success_done = '1' then -- Sample request signal
                    for i in 0 to INT_QUBITS_CNT-1 loop
                        slv_flow_random_buffer_shreg((i+1)*1-1 downto i*1) 
                            <= wr_data_random_buffer(i);
                    end loop;
                end if;

                -- Shift right by a certain number of bits on enable
                if sl_request_read_random_shift_enable = '1' then
                    slv_flow_random_buffer_shreg <= 
                        slv_shift_right(slv_flow_random_buffer_shreg, 1);
                end if;
            end if;
        end process;

        proc_sample_timestamp_buffer : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then

                -- Sample on sample request
                if wr_valid_feedfwd_success_done = '1' then -- Sample request signal
                    for i in 0 to INT_QUBITS_CNT loop
                        slv_flow_timestamp_buffer_shreg((i+1)*INT_DATA_SPACE_IN_CHANNEL-1 downto i*INT_DATA_SPACE_IN_CHANNEL)
                            <= wr_data_time_stamp_buffer(i);
                    end loop;
                end if;

                -- Shift right by a certain number of bits on enable
                if sl_request_read_timestamp_shift_enable = '1' then
                    slv_flow_timestamp_buffer_shreg <= 
                        slv_shift_right(slv_flow_timestamp_buffer_shreg, INT_DATA_SPACE_IN_CHANNEL);
                end if;
            end if;
        end process;



        proc_sample_coincidences_patterns : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then

                -- Sample on sample request
                for i in 0 to INT_QUBITS_CNT**2-1 loop
                    if sl_periodic_report_sample_request(i) = '1' then -- Sample request signal
                            slv_combinations_counters_shreg((i+1)*COINCIDENCE_PATTERN_ACC_WIDTH-1 downto i*COINCIDENCE_PATTERN_ACC_WIDTH) 
                                <= slv_combinations_counters_2d(i);
                    end if;
                end loop;

                -- Shift right by a certain number of bits on enable
                if sl_request_read_coincidences_shift_enable = '1' then
                    slv_combinations_counters_shreg <= 
                        slv_shift_right(slv_combinations_counters_shreg, COINCIDENCE_PATTERN_ACC_WIDTH);
                end if;
            end if;
        end process;


        proc_sample_all_channels_detections : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then

                -- Sample on sample request
                for i in 0 to INT_QUBITS_CNT*2-1 loop
                    if sl_periodic_report_sample_request_2(i) = '1' then -- Sample request signal
                            slv_ch_detections_shreg((i+1)*ALL_CH_DETECTIONS_ACC_WIDTH-1 downto i*ALL_CH_DETECTIONS_ACC_WIDTH) 
                                <= slv_all_channels_detections_2d(i);
                    end if;
                end loop;

                -- Shift right by a certain number of bits on enable
                if sl_request_read_ch_detections_shift_enable = '1' then
                    slv_ch_detections_shreg <= 
                        slv_shift_right(slv_ch_detections_shreg, ALL_CH_DETECTIONS_ACC_WIDTH);
                end if;
            end if;
        end process;


        proc_sample_photon_losses : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then

                -- Sample on sample request
                for i in 0 to INT_QUBITS_CNT-2 loop
                    if sl_periodic_report_sample_request_2(i) = '1' then -- Sample request signal
                            slv_photon_losses_shreg((i+1)*ALL_PHOTON_LOSSES_ACC_WIDTH-1 downto i*ALL_PHOTON_LOSSES_ACC_WIDTH) 
                                <= slv_all_unsuccessful_coincidences_2d(i);
                    end if;
                end loop;

                -- Shift right by a certain number of bits on enable
                if sl_request_read_photon_losses_shift_enable = '1' then
                    slv_photon_losses_shreg <= 
                        slv_shift_right(slv_photon_losses_shreg, ALL_PHOTON_LOSSES_ACC_WIDTH);
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

                -- Pipes Off by default
                sl_request_read_coincidences_shift_enable <= '0';
                sl_request_read_ch_detections_shift_enable <= '0';
                sl_request_read_photon_losses_shift_enable <= '0';
                sl_request_read_photons_shift_enable <= '0';
                sl_request_read_alpha_shift_enable <= '0';
                sl_request_read_modulo_shift_enable <= '0';
                sl_request_read_random_shift_enable <= '0';
                sl_request_read_timestamp_shift_enable <= '0';


                -- Counter to send a value per desired number of seconds
                if wr_rst = '1' then
                    int_periodic_report_counter <= 0;
                    slv_periodic_report_counter <= (others => '0');
                    sl_periodic_report_flag <= '0';
                    sl_periodic_report_sample_request <= (others => '0');
                else
                    if slv_periodic_report_counter(PERIODIC_REPORT_CLK_BITS-1 downto 0) 
                        = std_logic_vector(to_unsigned(PERIODIC_REPORT_CLK_PERIODS-1, PERIODIC_REPORT_CLK_BITS)) then
                    -- if int_periodic_report_counter = PERIODIC_REPORT_CLK_PERIODS-1 then
                        slv_periodic_report_counter <= (others => '0');
                        int_periodic_report_counter <= 0;
                        sl_periodic_report_flag <= '1';
                        sl_periodic_report_sample_request <= (others => '1');
                    else
                        slv_periodic_report_counter <= std_logic_vector(unsigned(slv_periodic_report_counter) + "1");
                        int_periodic_report_counter <= int_periodic_report_counter + 1;
                        sl_periodic_report_flag <= '0';
                        sl_periodic_report_sample_request <= (others => '0');
                    end if;
                end if;

                -- 2nd counter to send a value per desired number of seconds
                if wr_rst = '1' then
                    slv_periodic_report_counter_2 <= (others => '0');
                    int_periodic_report_counter_2 <= 0;
                    sl_periodic_report_flag_2 <= '0';
                    sl_periodic_report_sample_request_2 <= (others => '0');
                else
                    if slv_periodic_report_counter_2(PERIODIC_REPORT_CLK_BITS_2-1 downto 0) 
                        = std_logic_vector(to_unsigned(PERIODIC_REPORT_CLK_PERIODS_2-1, PERIODIC_REPORT_CLK_BITS_2)) then
                    -- if int_periodic_report_counter_2 = PERIODIC_REPORT_CLK_PERIODS_2-1 then
                        slv_periodic_report_counter_2 <= (others => '0');
                        int_periodic_report_counter_2 <= 0;
                        sl_periodic_report_flag_2 <= '1';
                        sl_periodic_report_sample_request_2 <= (others => '1');
                    else
                        slv_periodic_report_counter_2 <= std_logic_vector(unsigned(slv_periodic_report_counter_2) + "1");
                        int_periodic_report_counter_2 <= int_periodic_report_counter_2 + 1;
                        sl_periodic_report_flag_2 <= '0';
                        sl_periodic_report_sample_request_2 <= (others => '0');
                    end if;
                end if;


                -- Queued Requests
                if wr_valid_feedfwd_success_done = '1' then
                    sl_readout_request_feedfwd <= wr_valid_feedfwd_success_done;
                end if;

                if sl_periodic_report_flag = '1' then
                    sl_readout_request_periodic <= sl_periodic_report_flag;
                end if;

                if sl_periodic_report_flag_2 = '1' then
                    sl_readout_request_periodic_2 <= sl_periodic_report_flag_2;
                end if;



                -- Controller for sending data over USB3
                case state_fifo_readout is
                    when SCAN_READOUT_REQUESTS => 

                        -- Default
                        if sl_readout_request_feedfwd = '1' then -- (Higher Priority)
                            -- Gflow report readout request
                            state_fifo_readout <= SEND_GFLOW_PHOTONS; -- Multi-transactional sequence of readout tx commands
                            sl_request_read_photons_shift_enable <= '1'; -- Pipe On (will be done after 2 clk cycles)

                        elsif sl_readout_request_periodic = '1' then -- (Lower Priority)
                            -- Periodic report readout request
                            state_fifo_readout <= SEND_COINCIDENCES;
                            sl_request_read_coincidences_shift_enable <= '1'; -- Pipe On (will be done after 2 clk cycles)

                        elsif sl_readout_request_periodic_2 = '1' then -- (Lowest Priority)
                            -- Periodic report readout request
                            state_fifo_readout <= SEND_CH_DETECTIONS;
                            sl_request_read_ch_detections_shift_enable <= '1'; -- Pipe On (will be done after 2 clk cycles)
                        end if;



                    when SEND_COINCIDENCES =>

                        -- Send periodic report in a way it has a higher priority over the 'sl_readout_request_feedfwd' but does not interfere with it
                        if int_readout_counter = INT_QUBITS_CNT**2 then
                            int_readout_counter <= 0;

                            -- Send enter
                            sl_wr_en_flag_pulsed <= '1'; -- Writing to FIFO shut down
                            slv_wr_data_stream_32b(31 downto 4) <= slv_time_periodic_sample_request(ACTUAL_TIME_COUNTER_WIDTH-1 downto 0); -- Send TIME information about when data were sampled along with x"9" & x"F" (end of frame)
                            slv_wr_data_stream_32b(3 downto 0) <= x"A";

                            sl_readout_request_periodic <= '0';      -- Job Done

                            state_fifo_readout <= SEND_PERIODIC1_TIMESTAMP_OVERFLOW; -- Coordinate the readout logic
                            -- No shift request to next FSM state
                        else
                            int_readout_counter <= int_readout_counter + 1;
                            sl_wr_en_flag_pulsed <= '1';

                            slv_wr_data_stream_32b(31 downto 4) -- Define All bits!
                                <= std_logic_vector(to_unsigned(0, INT_DATA_SPACE_IN_CHANNEL-COINCIDENCE_PATTERN_ACC_WIDTH)) 
                                    & slv_combinations_counters_shreg(COINCIDENCE_PATTERN_ACC_WIDTH-1 downto 0);

                            slv_wr_data_stream_32b(3 downto 0) <= x"7"; -- Encoded command for the RX counterpart

                            sl_request_read_coincidences_shift_enable <= '1'; -- Keep Pipe On

                        end if;

                    when SEND_CH_DETECTIONS =>

                        -- Send periodic report in a way it has a higher priority over the 'sl_readout_request_feedfwd' but does not interfere with it
                        if int_readout_counter = INT_QUBITS_CNT*2 then
                            int_readout_counter <= 0;

                            -- Send enter
                            sl_wr_en_flag_pulsed <= '1'; -- Writing to FIFO shut down
                            slv_wr_data_stream_32b(31 downto 4) <= (others => '0');
                            slv_wr_data_stream_32b(3 downto 0) <= x"E";

                            -- sl_readout_request_periodic_2 <= '0';      -- Job Not Done Yet

                            state_fifo_readout <= SEND_PHOTON_LOSSES; -- Coordinate the readout logic
                            sl_request_read_photon_losses_shift_enable <= '1';
                        else
                            int_readout_counter <= int_readout_counter + 1;
                            sl_wr_en_flag_pulsed <= '1';

                            slv_wr_data_stream_32b(31 downto 4) -- Define All bits!
                                <= std_logic_vector(to_unsigned(0, INT_DATA_SPACE_IN_CHANNEL-ALL_CH_DETECTIONS_ACC_WIDTH)) 
                                    & slv_ch_detections_shreg(ALL_CH_DETECTIONS_ACC_WIDTH-1 downto 0);

                            slv_wr_data_stream_32b(3 downto 0) <= x"8"; -- Encoded command for the RX counterpart

                            sl_request_read_ch_detections_shift_enable <= '1'; -- Keep Pipe On

                        end if;

                    when SEND_PHOTON_LOSSES =>

                        -- Send periodic report in a way it has a higher priority over the 'sl_readout_request_feedfwd' but does not interfere with it
                        if int_readout_counter = INT_QUBITS_CNT-1 then
                            int_readout_counter <= 0;

                            -- Send enter
                            sl_wr_en_flag_pulsed <= '1'; -- Writing to FIFO shut down
                            slv_wr_data_stream_32b(31 downto 4) <= slv_time_periodic_sample_request_2(ACTUAL_TIME_COUNTER_WIDTH-1 downto 0); -- Send TIME information about when data were sampled along with x"A" & x"F" (end of frame)
                            slv_wr_data_stream_32b(3 downto 0) <= x"A";

                            sl_readout_request_periodic_2 <= '0';      -- Job Done

                            state_fifo_readout <= SEND_PERIODIC2_TIMESTAMP_OVERFLOW; -- Coordinate the readout logic
                            -- No shift request to next FSM state
                        else
                            int_readout_counter <= int_readout_counter + 1;
                            sl_wr_en_flag_pulsed <= '1';

                            slv_wr_data_stream_32b(31 downto 4) -- Define All bits!
                                <= std_logic_vector(to_unsigned(0, INT_DATA_SPACE_IN_CHANNEL-ALL_PHOTON_LOSSES_ACC_WIDTH)) 
                                    & slv_photon_losses_shreg(ALL_PHOTON_LOSSES_ACC_WIDTH-1 downto 0);

                            slv_wr_data_stream_32b(3 downto 0) <= x"9"; -- Encoded command for the RX counterpart

                            sl_request_read_photon_losses_shift_enable <= '1'; -- Keep Pipe On

                        end if;



                    when SEND_GFLOW_PHOTONS => 

                        -- Send periodic report in a way it has a higher priority over the 'sl_readout_request_feedfwd' but does not interfere with it
                        -- Multiple 32b transactions
                        if int_readout_counter = INT_QUBITS_CNT then
                            int_readout_counter <= 0;

                            -- Send extra comma delimiter
                            sl_wr_en_flag_pulsed <= '1';
                            slv_wr_data_stream_32b(31 downto 4) <= (others => '0');
                            slv_wr_data_stream_32b(3 downto 0) <= x"E";

                            state_fifo_readout <= SEND_GFLOW_NUMBER; -- Coordinate the readout logic
                            -- sl_request_read_actual_gflow_shift_enable <= '1'; -- No need to pre-enable Pipe On as the next transaction does not include shifters

                        else
                            -- Multiple 32b transactions
                            int_readout_counter <= int_readout_counter + 1;
                            sl_wr_en_flag_pulsed <= '1';

                            slv_wr_data_stream_32b(31 downto 4) -- Define All bits!
                                <= std_logic_vector(to_unsigned(0, INT_DATA_SPACE_IN_CHANNEL-2))
                                    & slv_flow_photons_buffer_shreg(2-1 downto 0);

                            slv_wr_data_stream_32b(3 downto 0) <= x"1"; -- Encoded command for the RX readout counterpart

                            sl_request_read_photons_shift_enable <= '1'; -- Keep Pipe On

                        end if;

                    
                    when SEND_GFLOW_NUMBER =>

                        -- Send periodic report in a way it has a higher priority over the 'sl_readout_request_feedfwd' but does not interfere with it
                        -- Single 32b transaction
                        if int_readout_counter = 1 then
                            int_readout_counter <= 0;

                            -- Send extra comma delimiter
                            sl_wr_en_flag_pulsed <= '1';
                            slv_wr_data_stream_32b(31 downto 4) <= (others => '0');
                            slv_wr_data_stream_32b(3 downto 0) <= x"E";

                            state_fifo_readout <= SEND_GFLOW_ALPHA; -- Coordinate the readout logic
                            sl_request_read_alpha_shift_enable <= '1'; -- Pipe On (will be done after 2 clk cycles)

                        else
                            -- Single 32b transaction
                            int_readout_counter <= int_readout_counter + 1;
                            sl_wr_en_flag_pulsed <= '1';
                            
                            sl_wr_en_flag_pulsed <= '1';
                            slv_wr_data_stream_32b(31 downto 4) <= slv_flow_actual_gflow_buffer_shreg;
                            slv_wr_data_stream_32b(3 downto 0) <= x"2";

                        end if;


                    when SEND_GFLOW_ALPHA =>

                        -- Send periodic report in a way it has a higher priority over the 'sl_readout_request_feedfwd' but does not interfere with it
                        -- Multiple 32b transactions
                        if int_readout_counter = INT_QUBITS_CNT then
                            int_readout_counter <= 0;

                            -- Send extra comma delimiter
                            sl_wr_en_flag_pulsed <= '1';
                            slv_wr_data_stream_32b(31 downto 4) <= (others => '0');
                            slv_wr_data_stream_32b(3 downto 0) <= x"E";

                            state_fifo_readout <= SEND_GFLOW_MODULO; -- Coordinate the readout logic
                            sl_request_read_modulo_shift_enable <= '1'; -- Pipe On (will be done after 2 clk cycles)
                        else
                            -- Multiple 32b transactions
                            int_readout_counter <= int_readout_counter + 1;
                            sl_wr_en_flag_pulsed <= '1';

                            slv_wr_data_stream_32b(31 downto 4) -- Define All bits!
                                <= std_logic_vector(to_unsigned(0, INT_DATA_SPACE_IN_CHANNEL-2))
                                    & slv_flow_alpha_buffer_shreg(2-1 downto 0);

                            slv_wr_data_stream_32b(3 downto 0) <= x"3"; -- Encoded command for the RX readout counterpart

                            sl_request_read_alpha_shift_enable <= '1'; -- Keep Pipe On

                        end if;

                    when SEND_GFLOW_MODULO =>

                        -- Send periodic report in a way it has a higher priority over the 'sl_readout_request_feedfwd' but does not interfere with it
                        -- Multiple 32b transactions
                        if int_readout_counter = INT_QUBITS_CNT then
                            int_readout_counter <= 0;

                            -- Send extra comma delimiter
                            sl_wr_en_flag_pulsed <= '1';
                            slv_wr_data_stream_32b(31 downto 4) <= (others => '0');
                            slv_wr_data_stream_32b(3 downto 0) <= x"E";

                            state_fifo_readout <= SEND_GFLOW_RANDOM; -- Coordinate the readout logic
                            sl_request_read_random_shift_enable <= '1'; -- Pipe On (will be done after 2 clk cycles)

                        else
                            -- Multiple 32b transactions
                            int_readout_counter <= int_readout_counter + 1;
                            sl_wr_en_flag_pulsed <= '1';

                            slv_wr_data_stream_32b(31 downto 4) -- Define All bits!
                                <= std_logic_vector(to_unsigned(0, INT_DATA_SPACE_IN_CHANNEL-2))
                                    & slv_flow_modulo_buffer_shreg(2-1 downto 0);

                            slv_wr_data_stream_32b(3 downto 0) <= x"4"; -- Encoded command for the RX readout counterpart

                            sl_request_read_modulo_shift_enable <= '1'; -- Pipe On

                        end if;

                    when SEND_GFLOW_RANDOM =>

                        -- Send periodic report in a way it has a higher priority over the 'sl_readout_request_feedfwd' but does not interfere with it
                        -- Multiple 32b transactions
                        if int_readout_counter = INT_QUBITS_CNT then
                            int_readout_counter <= 0;

                            -- Send extra comma delimiter
                            sl_wr_en_flag_pulsed <= '1';
                            slv_wr_data_stream_32b(31 downto 4) <= (others => '0');
                            slv_wr_data_stream_32b(3 downto 0) <= x"E";

                            state_fifo_readout <= SEND_FEEDFWD_TIMESTAMP; -- Coordinate the readout logic
                            sl_request_read_timestamp_shift_enable <= '1'; -- Pipe On (will be done after 2 clk cycles)

                        else
                            -- Multiple 32b transactions
                            int_readout_counter <= int_readout_counter + 1;

                            -- Send data
                            sl_wr_en_flag_pulsed <= '1';
                            slv_wr_data_stream_32b(31 downto 4) -- Define All bits!
                                <= std_logic_vector(to_unsigned(0, INT_DATA_SPACE_IN_CHANNEL-1))
                                    & slv_flow_random_buffer_shreg(1-1 downto 0);

                            slv_wr_data_stream_32b(3 downto 0) <= x"5"; -- Encoded command for the RX readout counterpart

                            sl_request_read_random_shift_enable <= '1'; -- Pipe On

                        end if;

                    when SEND_FEEDFWD_TIMESTAMP =>

                        -- Send periodic report in a way it has a higher priority over the 'sl_readout_request_feedfwd' but does not interfere with it
                        -- Multiple 32b transactions
                        if int_readout_counter = INT_QUBITS_CNT+1 then
                            int_readout_counter <= 0;

                            -- Send enter
                            sl_wr_en_flag_pulsed <= '1';
                            slv_wr_data_stream_32b(31 downto 4) <= slv_time_feedfwd_sample_request(ACTUAL_TIME_COUNTER_WIDTH-1 downto 0); -- Send TIME information about when data were sampled along with x"9" (end of frame)
                            slv_wr_data_stream_32b(3 downto 0) <= x"A";

                            state_fifo_readout <= SEND_FEEDFWD_TIMESTAMP_OVERFLOW; -- Coordinate the readout logic
                            sl_readout_request_feedfwd <= '0'; -- Job done flag

                        else
                            -- Multiple 32b transactions
                            int_readout_counter <= int_readout_counter + 1;

                            -- Send data
                            sl_wr_en_flag_pulsed <= '1';
                            slv_wr_data_stream_32b(31 downto 4) -- Define All bits!
                                <= slv_flow_timestamp_buffer_shreg(INT_DATA_SPACE_IN_CHANNEL-1 downto 0);
                            slv_wr_data_stream_32b(3 downto 0) <= x"6"; -- Encoded command for the RX readout counterpart

                            sl_request_read_timestamp_shift_enable <= '1'; -- Pipe On

                        end if;


                    when SEND_FEEDFWD_TIMESTAMP_OVERFLOW =>

                        -- Send enter
                        sl_wr_en_flag_pulsed <= '1';
                        slv_wr_data_stream_32b(31 downto 4) <= slv_time_feedfwd_sample_request(2*ACTUAL_TIME_COUNTER_WIDTH-1 downto ACTUAL_TIME_COUNTER_WIDTH); -- Send TIME information about when data were sampled along with x"F" (end of frame)
                        slv_wr_data_stream_32b(3 downto 0) <= x"F";

                        state_fifo_readout <= SCAN_READOUT_REQUESTS; -- Coordinate the readout logic
                        sl_readout_request_feedfwd <= '0'; -- Job done flag


                    when SEND_PERIODIC1_TIMESTAMP_OVERFLOW =>

                        -- Send enter
                        sl_wr_en_flag_pulsed <= '1';
                        slv_wr_data_stream_32b(31 downto 4) <= slv_time_periodic_sample_request(2*ACTUAL_TIME_COUNTER_WIDTH-1 downto ACTUAL_TIME_COUNTER_WIDTH); -- Send TIME information about when data were sampled along with x"F" (end of frame)
                        slv_wr_data_stream_32b(3 downto 0) <= x"F";

                        state_fifo_readout <= SCAN_READOUT_REQUESTS; -- Coordinate the readout logic
                        sl_readout_request_feedfwd <= '0'; -- Job done flag


                    when SEND_PERIODIC2_TIMESTAMP_OVERFLOW =>

                        -- Send enter
                        sl_wr_en_flag_pulsed <= '1';
                        slv_wr_data_stream_32b(31 downto 4) <= slv_time_periodic_sample_request_2(2*ACTUAL_TIME_COUNTER_WIDTH-1 downto ACTUAL_TIME_COUNTER_WIDTH); -- Send TIME information about when data were sampled along with x"F" (end of frame)
                        slv_wr_data_stream_32b(3 downto 0) <= x"F";

                        state_fifo_readout <= SCAN_READOUT_REQUESTS; -- Coordinate the readout logic
                        sl_readout_request_feedfwd <= '0'; -- Job done flag


                    when others =>
                        sl_wr_en_flag_pulsed <= '0';
                        state_fifo_readout <= SCAN_READOUT_REQUESTS;

                        -- Set next transaction request to zero, wait to be asserted once next cluster has been measured
                        sl_readout_request_feedfwd <= '0';

                end case;
            end if;
        end process;


        -- Write logic
        proc_endp_fifo_write_valid : process(wr_sys_clk)
        begin
            if rising_edge(wr_sys_clk) then

                -- DO NOT TOUCH: Default values
                if wr_rst = '0' then
                    sl_wr_en <= '0';
                    sl_full_latched <= sl_full_latched;
                end if;

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