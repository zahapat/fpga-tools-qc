    -- Signals that are accessible to all testbench modules/submodules

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    -- SRC Packages
    library lib_src;
    --     * Module-specific SRC Packages (if used, uncomment)
    -- use lib_src.const_srcname_pack.all;
    -- use lib_src.types_srcname_pack.all;
    -- use lib_src.signals_srcname_pack.all;

    --     * Global project-specific SRC Packages
    use lib_src.const_pack.all;
    use lib_src.types_pack.all;
    use lib_src.signals_pack.all;

    -- TB Packages
    --     * Module-specific TB Packages
    library lib_sim;
    use lib_sim.const_srcname_pack_tb.all;
    use lib_sim.types_srcname_pack_tb.all;

    --     * Global Project-specific TB Packages
    use lib_sim.const_pack_tb.all;
    use lib_sim.types_pack_tb.all;
    use lib_sim.signals_pack_tb.all;

    use lib_sim.list_string_pack_tb.all;
    use lib_sim.print_list_pack_tb.all;


    package signals_srcname_pack_tb is

        ----------------------------------------------
        -- Interfaces = data queues (triggers) between executors -> checkers (tests)) / monitors
        ----------------------------------------------
        -- AUXILLIARY
        -- Interface Executor => Checker
        
        -- TO DO: SEQUENCE QUEUE
        shared variable queue_sequence_dut1_tx1 : list;
        shared variable log_sequence_dut1_tx1 : list;

        -- DUT1
        -- 1.1) Ports:
        signal dut1_tx1 : std_logic_vector(MSG_SYMBOLS*SYMBOL_WIDTH-1 downto 0) := (others => '0');

        signal dut1_rx1 : std_logic_vector(TUPLE_WIDTH*SYMBOL_WIDTH-1 downto 0) := (others => '0');
        signal dut1_rx2 : std_logic_vector(MSG_SYMBOLS*SYMBOL_WIDTH-1 downto 0) := (others => '0');
    
        -- 2.1) TX input data schedulers
        --     * dut1_tx1
        shared variable queue_sent_dut1_tx1 : list;
        shared variable queue_expected_dut1_tx1 : list;         -- Check with one value
        shared variable queue_forbidden_dut1_tx1 : list;
        shared variable queue_expected_values_dut1_tx1 : list;  -- Check with multiple values
        shared variable queue_forbidden_values_dut1_tx1 : list;
        shared variable log_sent_dut1_tx1 : list;
        shared variable log_expected_dut1_tx1 : list;
        shared variable log_forbidden_dut1_tx1 : list;
        shared variable log_expected_values_dut1_tx1 : list;
        shared variable log_forbidden_values_dut1_tx1 : list;

        -- 2.2) RX expected / forbidden output value schedulers (for checkers)
        --     * dut1_rx1
        shared variable queue_received_dut1_rx1 : list;         -- For monitors
        shared variable queue_expected_dut1_rx1 : list;         -- Check with one value
        shared variable queue_forbidden_dut1_rx1 : list;
        shared variable queue_expected_values_dut1_rx1 : list;  -- Check with multiple values
        shared variable queue_forbidden_values_dut1_rx1 : list;
        shared variable log_received_dut1_rx1 : list;
        shared variable log_expected_dut1_rx1 : list;
        shared variable log_forbidden_dut1_rx1 : list;
        shared variable log_expected_values_dut1_rx1 : list;
        shared variable log_forbidden_values_dut1_rx1 : list;

        --     * dut1_rx2
        shared variable queue_received_dut1_rx2 : list;         -- For monitors
        shared variable queue_expected_dut1_rx2 : list;         -- Check with one value
        shared variable queue_forbidden_dut1_rx2 : list;
        shared variable queue_expected_values_dut1_rx2 : list;  -- Check with multiple values
        shared variable queue_forbidden_values_dut1_rx2 : list;
        shared variable log_received_dut1_rx2 : list;
        shared variable log_expected_dut1_rx2 : list;
        shared variable log_forbidden_dut1_rx2 : list;
        shared variable log_expected_values_dut1_rx2 : list;
        shared variable log_forbidden_values_dut1_rx2 : list;

    
        -- 2.3) CHECKER command queue + results log (NOT employed)
        shared variable queue_check_cmds_dut1 : list;

        --     * dut1_tx1
        shared variable queue_result_dut1_tx1 : list;
        shared variable log_result_dut1_tx1 : list;

        --     * dut1_rx1
        shared variable queue_result_dut1_rx1 : list;
        shared variable log_result_dut1_rx1 : list;

        --     * dut1_rx2
        shared variable queue_result_dut1_rx2 : list;
        shared variable log_result_dut1_rx2 : list;


        ------------------------------------------------
        -- Keep names & modify: srcname_tb
        ------------------------------------------------
        -- Clock generator
        signal clk1 : std_logic := '1';
        signal rst1 : std_logic := '0';

        -- Global seeds
        signal glob_seed1 : positive := 1;

        -- Auxiliary valid signal (which is not in the RTL)
        signal slv_aux_valid1 : std_logic_vector(CYCLES_WAIT_FOR_rx_dut1-1 downto 0) := (others => '0');
        signal to_aux_valid1 : std_logic := '0';
        signal aux_rx_dut1_valid_monitor : std_logic := '0';
        signal aux_rx_dut1_valid_pulsed : std_logic := '0';

        -- Auxiliary signals
        -- signal tx_aux_dut1_valid : std_logic := '0';
        -- signal dut2_tx1_aux1 : std_logic_vector(dut2_tx1'range) := (others => '0');


        -- Do not touch
        --     * If no axi valid port is present
        signal flag_wait_for_output : std_logic := '0';
        --     * If axi valid port is present
        signal tx_dut1_valid : std_logic := '0';
        signal rx_dut1_valid : std_logic := '0';

        signal int_bits_in_error : integer := 0;

        

    end package;

    package body signals_srcname_pack_tb is
    end package body;