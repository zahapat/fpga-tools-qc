    -- crc_tb.vhd: Testbench for module lfsr_inemul.vhd
    -- Engineer: Patrik Zahalka 
    -- Email: patrik.zahalka@univie.ac.at

    -- General packages
    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;
    -- use ieee.math_complex.all;

    library std;
    use std.textio.all;
    use std.env.all;

    -- SRC Packages
    library lib_src;
    --     * Module-specific SRC Packages (not used)
    -- use lib_src.const_lfsr_inemul_pack.all;
    -- use lib_src.types_lfsr_inemul_pack.all;
    -- use lib_src.signals_lfsr_inemul_pack.all;

    --     * Global project-specific SRC Packages
    use lib_src.const_pack.all;
    use lib_src.types_pack.all;
    use lib_src.signals_pack.all;

    -- TB Packages
    --     * Module-specific TB Packages
    library lib_sim;
    use lib_sim.const_lfsr_inemul_pack_tb.all;
    use lib_sim.types_lfsr_inemul_pack_tb.all;
    use lib_sim.signals_lfsr_inemul_pack_tb.all;
    use lib_sim.triggers_lfsr_inemul_pack_tb.all;

    --     * Global Project-specific TB Packages
    use lib_sim.const_pack_tb.all;
    use lib_sim.types_pack_tb.all;
    use lib_sim.signals_pack_tb.all;

    --     * Generic TB Packages
    use lib_sim.print_pack_tb.all;
    use lib_sim.clk_pack_tb.all;
    use lib_sim.list_string_pack_tb.all;
    use lib_sim.print_list_pack_tb.all;

    -- OSVVM Packages
    library osvvm;
    use osvvm.RandomPkg.all;


    entity lfsr_inemul_tb is
    end lfsr_inemul_tb;

    architecture sim of lfsr_inemul_tb is
    begin

        -- TB submodules
        inst_executors_lfsr_inemul_tb : entity lib_sim.executors_lfsr_inemul_tb(sim);

        inst_monitor_lfsr_inemul_tb : entity lib_sim.monitors_lfsr_inemul_tb(sim);
        inst_checkers_lfsr_inemul_tb : entity lib_sim.checkers_lfsr_inemul_tb(sim);

        inst_harness_lfsr_inemul_tb : entity lib_sim.harness_lfsr_inemul_tb(sim);

        -- DUT
        -- inst_lfsr_inemul : entity lib_src.lfsr_inemul(rtl)
        -- port map (
        --     CLK => clk1,
        --     IN_DATA => dut1_tx1,
        --     OUT_CRC => dut1_rx1,
        --     OUT_MSG => dut1_rx2
        -- );



        -- Main Sequencer
        proc_sequencer : process

            -- Overloaded Procedures: Subprograms calling itself, linked to their record types
            -- GENERAL
            procedure cmd_general (
                id : t_cmd_id_general
            ) is begin
                cmd_general(trigger_general, id);
            end procedure;


            -- DUT1
            --     * tx commands
            procedure cmd_dut1_tx1 (
                id : t_cmd_id_dut1_tx;
                data : std_logic_vector(dut1_tx1'range) := (others => '0')
            ) is begin
                cmd_dut1_tx1(trigger_dut1_tx1, id, data);
            end procedure;


            --     * rx commands
            procedure cmd_dut1_rx1 (
                id : t_cmd_id_dut1_rx;
                data : std_logic_vector(dut1_rx1'range) := (others => '0')
            ) is begin
                cmd_dut1_rx1(trigger_dut1_rx1, id, data);
            end procedure;
            procedure cmd_dut1_rx2 (
                id : t_cmd_id_dut1_rx;
                data : std_logic_vector(dut1_rx2'range) := (others => '0')
            ) is begin
                cmd_dut1_rx2(trigger_dut1_rx2, id, data);
            end procedure;

            --     * check commands
            procedure cmd_dut1_tx1_check (
                id : t_cmd_id_dut1_check;
                data : std_logic_vector(dut1_tx1'range) := (others => '0')
            ) is begin
                cmd_dut1_tx1_check(trigger_dut1_tx1_check, id, data);
            end procedure;
            procedure cmd_dut1_rx1_check (
                id : t_cmd_id_dut1_check;
                data : std_logic_vector(dut1_rx1'range) := (others => '0')
            ) is begin
                cmd_dut1_rx1_check(trigger_dut1_rx1_check, id, data);
            end procedure;
            procedure cmd_dut1_rx2_check (
                id : t_cmd_id_dut1_check;
                data : std_logic_vector(dut1_rx2'range) := (others => '0')
            ) is begin
                cmd_dut1_rx2_check(trigger_dut1_rx2_check, id, data);
            end procedure;



            -- Variables
            variable v_tx_dut1_1 : std_logic_vector(dut1_tx1'range);
            -- variable assert_with_data_from_dut : std_logic_vector(from_dut'range);
            variable random_slv : RandomPType;

            -- Model Transaction
            -- variable v_model_transaction : std_logic_vector(dut1_tx1'range) := "00010010001101000101011001111000100110101011";
            variable v_dut1_tx1 : std_logic_vector(dut1_tx1'range);

        begin

            -- Test #0: Visual assessment: Send arbitrary data, run arbitrary sequence, no checking
            -- Send one message, then zeros
            print_string("TB: Simulation Started");
            wait_cycles(50, clk1);


            --------------------------
            -- * DUT1 Test 1
            --------------------------
            print_string("TB: ===== Test 1 =====");

            -- 1) Schedule transactions & expected/forbidden values
            print_string("TB: Scheduling ...");
            -- for i in 1 to dut1_tx1'length loop
            for i in 0 to 10 loop
                -- 1.1) Schedule TX transactions
                cmd_dut1_tx1(TX_DUT1_ZEROES);
                -- v_dut1_tx1 := std_logic_vector(to_unsigned(i, dut1_tx1'length));
                -- cmd_dut1_tx1(TX_DUT1_SPECIFIC_VALUE, v_dut1_tx1);

                -- 1.2) Schedule expected/forbidden/ RX values: (for all transactions above)
                wait_deltas(1);
                cmd_dut1_rx1_check(CHECK_DUT1_RX1_ISNOT_ZERO);
                -- wait_deltas(1);
                -- cmd_dut1_rx2_check(CHECK_DUT1_RX2_IS_SPECIFIC_VALUE, v_dut1_tx1);
                -- wait_deltas(1);
            end loop;
            print_string("TB: Scheduling done.");


            -- 2) Run, wait until test done
            print_string("TB: Running test ...");
            cmd_dut1_tx1(TX_DUT1_WAIT_UNTIL_SEQUENCE_TRANSMITTED);
            cmd_dut1_rx1(RX_DUT1_WAIT_UNTIL_EVERYTHING_RECEIVED);
            print_string("TB: Running test done.");


            -- 3) Clear all queues & logs
            print_string("TB: ... Cleaning queues & logs.");
            cmd_general(DUT1_REMOVE_ALL_QUEUES);
            cmd_general(PRINT_ALL_LOGS);
            cmd_general(REMOVE_ALL_LOGS);
            print_string("TB: ... Cleaning queues & logs done.");


            -- Wait until at least 1 of the queues is empty, then print success
            -- cmd_dut1_tx(WAIT_UNTIL_QUEUES_EMPTY);

            print_success;

            finish;
            wait;
        end process;


    end architecture;