    -- This file procedures (here executor processes) that come from iniside of the sequencer process from the main tb file
    -- All of the executor processes are 
    --      triggered from exec_cmd.id = command
    --      After the end of the processes, a short boolean true pulse is sent

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;
    -- use ieee.math_complex.all;

    library std;
    use std.textio.all;
    use std.env.all;

    -- TB Packages
    --     * Module-specific TB Packages
    library lib_sim;
    use lib_sim.const_srcname_pack_tb.all;
    use lib_sim.types_srcname_pack_tb.all;
    use lib_sim.signals_srcname_pack_tb.all;
    use lib_sim.triggers_srcname_pack_tb.all;

    --     * Global Project-specific TB Packages
    use lib_sim.const_pack_tb.all;
    use lib_sim.types_pack_tb.all;
    use lib_sim.signals_pack_tb.all;

    --     * Generic TB Packages
    use lib_sim.print_pack_tb.all;
    use lib_sim.clk_pack_tb.all;
    use lib_sim.list_string_pack_tb.all;
    use lib_sim.print_list_pack_tb.all;

    -- SRC Packages
    library lib_src;
    --     * Module-specific SRC Packages
    use lib_src.const_srcname_pack.all;
    use lib_src.types_srcname_pack.all;
    use lib_src.signals_srcname_pack.all;

    --     * Global project-specific SRC Packages
    use lib_src.const_pack.all;
    use lib_src.types_pack.all;
    use lib_src.signals_pack.all;

    -- OSVVM Packages
    library osvvm;
    use osvvm.RandomPkg.all;


    entity executors_srcname_tb is
    end executors_srcname_tb;

    architecture sim of executors_srcname_tb is
    begin

        -- Procedures from iniside of the sequencer process from the main tb file

        -- GENERAL

        -- GENERAL: Executor of the command "DUT1_REMOVE_ALL_QUEUES"
        proc_exec_check_dut1_remove_all_queues : process
            variable v_items_cnt : natural := 0;
            variable v_sent_cnt : natural := 0;
            variable pass : boolean := true;
        begin
            -- 1. Trigger executor process
            wait until trigger_general.id = DUT1_REMOVE_ALL_QUEUES;

            -- 2. The process
            print_string("DUT1_REMOVE_ALL_QUEUES:                 ");

            -- Before cleaning the queues, assure that all TX sequece items have propagated
            if queue_sequence_dut1_tx1.length /= 0 then
                pass := false;
                Stop;
            end if;

            -- Before cleaning the queues, assure that items TX = RX
            if queue_received_dut1_rx1.length /= queue_sent_dut1_tx1.length  then
                print_string("queue_received_dut1_rx1.length: " & to_string(queue_received_dut1_rx1.length));
                print_string("queue_sent_dut1_tx1.length: " & to_string(queue_sent_dut1_tx1.length));
                pass := false;
                Stop;
            end if;
                
            if pass = true then
                    -- dut1_tx1
                queue_sent_dut1_tx1.clear;
                queue_expected_dut1_tx1.clear;
                queue_forbidden_dut1_tx1.clear;
                queue_expected_values_dut1_tx1.clear;
                queue_forbidden_values_dut1_tx1.clear;

                    -- dut1_rx1
                queue_received_dut1_rx1.clear;
                queue_expected_dut1_rx1.clear;
                queue_forbidden_dut1_rx1.clear;
                queue_expected_values_dut1_rx1.clear;
                queue_forbidden_values_dut1_rx1.clear;

                    -- dut1_rx2
                queue_received_dut1_rx2.clear;
                queue_expected_dut1_rx2.clear;
                queue_forbidden_dut1_rx2.clear;
                queue_expected_values_dut1_rx2.clear;
                queue_forbidden_values_dut1_rx2.clear;

                print_string("DUT1_REMOVE_ALL_QUEUES:                 Cleaning all queues done.");
            else
                print_string("DUT1_REMOVE_ALL_QUEUES:                 ERROR: Sequence queue 'queue_sequence_dut1_tx1' is not empty yet! Stop.");
                print_string("DUT1_REMOVE_ALL_QUEUES:                     -> Check 'WAIT_UNTIL_SEQUENCE_PROPAGATED' for possible mistakes/errors.");
                print_string("DUT1_REMOVE_ALL_QUEUES:                     -> Check 'queue_sequence_dut1_tx1' for possible mistakes/errors.");
                Stop;
            end if;


            -- 3. Executor done flag
            trigger_general.done <= force true;
            wait for 0 ns;
            trigger_general.done <= release;
        end process;



        -- GENERAL: Executor of the command "PRINT_ALL_LOGS"
        proc_exec_print_all_logs : process
            variable v_items_cnt_log1 : natural;
            variable v_items_cnt_log2 : natural;
            variable v_items_cnt_log3 : natural;
            variable v_items_cnt_log4 : natural;
            variable v_items_cnt_log5 : natural;
            variable v_items_cnt_log6 : natural;
            variable v_items_cnt_log7 : natural;
            variable v_items_cnt_log8 : natural;
            variable v_items_cnt_log9 : natural;
            variable v_items_cnt_log10 : natural;
            variable v_items_cnt_log11 : natural;
            variable v_items_cnt_log12 : natural;
            variable v_items_cnt_log13 : natural;
            variable v_items_cnt_log14 : natural;
            variable v_items_cnt_log15 : natural;
        begin
            -- 1. Trigger executor process
            wait until trigger_general.id = PRINT_ALL_LOGS;

            -- 2. The process
            -- DUT1
            v_items_cnt_log1 := log_sent_dut1_tx1.length; -- queue_sent_dut1_tx1

            -- v_items_cnt_log2 := log_expected_dut1_rx1.length; -- queue_expected_dut1_rx1
            -- v_items_cnt_log3 := log_forbidden_dut1_rx1.length; -- queue_forbidden_dut1_rx1
            v_items_cnt_log4 := log_received_dut1_rx1.length; -- queue_received_dut1_rx1
            -- v_items_cnt_log2 := log_expected_values_dut1_rx1.length; -- queue_expected_values_dut1_rx1
            -- v_items_cnt_log3 := log_forbidden_values_dut1_rx1.length; -- queue_forbidden_values_dut1_rx1

            -- v_items_cnt_log5 := log_expected_dut1_rx2.length; -- queue_expected_dut1_rx2
            -- v_items_cnt_log6 := log_forbidden_dut1_rx2.length; -- queue_forbidden_dut1_rx2
            v_items_cnt_log7 := log_received_dut1_rx2.length; -- queue_received_dut1_rx2
            -- v_items_cnt_log5 := log_expected_values_dut1_rx2.length; -- queue_expected_values_dut1_rx2
            -- v_items_cnt_log6 := log_forbidden_values_dut1_rx2.length; -- queue_forbidden_values_dut1_rx2

            -- DUT2
            v_items_cnt_log8 := log_sent_dut2_tx1.length; -- queue_sent_dut2_tx1
            v_items_cnt_log9 := log_sent_dut2_tx1_aux1.length; -- queue_sent_dut2_tx1_aux1

            -- v_items_cnt_log10 := log_expected_dut2_rx1.length; -- queue_expected_dut2_rx1
            -- v_items_cnt_log11 := log_forbidden_dut2_rx1.length; -- queue_forbidden_dut2_rx1
            v_items_cnt_log12 := log_received_dut2_rx1.length; -- queue_received_dut2_rx1
            -- v_items_cnt_log11 := log_forbidden_values_dut2_rx1.length; -- queue_forbidden_values_dut2_rx1
            -- v_items_cnt_log12 := log_received_values_dut2_rx1.length; -- queue_received_values_dut2_rx1

            -- v_items_cnt_log13 := log_expected_dut2_rx2.length; -- queue_expected_dut2_rx2
            -- v_items_cnt_log14 := log_forbidden_dut2_rx2.length; -- queue_forbidden_dut2_rx2
            v_items_cnt_log15 := log_received_dut2_rx2.length; -- queue_received_dut2_rx2
            -- v_items_cnt_log14 := log_forbidden_values_dut2_rx2.length; -- queue_forbidden_values_dut2_rx2
            -- v_items_cnt_log15 := log_received_values_dut2_rx2.length; -- queue_received_values_dut2_rx2


            print_string("PRINT_ALL_LOGS:");
            if v_items_cnt_log1 /= 0 then
                for i in 0 to v_items_cnt_log1-1 loop
                    if i = 0 then
                        print_string("====================");
                    end if;
                    print_string("transaction no. " & integer'image(i));

                    -- DUT1
                    print_string(    "log_sent_dut1_tx1:                      " & log_sent_dut1_tx1.get(i));

                    -- if i < v_items_cnt_log2 then
                    --     print_string("log_expected_dut1_rx1:                  " & log_expected_dut1_rx1.get(i));
                    -- end if;
                    -- if i < v_items_cnt_log3 then
                    --     print_string("log_forbidden_dut1_rx1:                 " & log_forbidden_dut1_rx1.get(i));
                    -- end if;
                    if i < v_items_cnt_log4 then
                        print_string("log_received_dut1_rx1:                  " & log_received_dut1_rx1.get(i));
                    end if;

                    -- if i < v_items_cnt_log5 then
                    --     print_string("log_expected_dut1_rx2:                  " & log_expected_dut1_rx2.get(i));
                    -- end if;
                    -- if i < v_items_cnt_log6 then
                    --     print_string("log_forbidden_dut1_rx2:                 " & log_forbidden_dut1_rx2.get(i));
                    -- end if;
                    if i < v_items_cnt_log7 then
                        print_string("log_received_dut1_rx2:                  " & log_received_dut1_rx2.get(i));
                    end if;

                    -- DUT2
                    if i < v_items_cnt_log8 then
                        print_string("log_sent_dut2_tx1:                      " & log_sent_dut2_tx1.get(i));
                    end if;
                    if i < v_items_cnt_log9 then
                        print_string("log_sent_dut2_tx1_aux1:                 " & log_sent_dut2_tx1_aux1.get(i));
                    end if;

                    -- if i < v_items_cnt_log10 then
                    --     print_string("log_expected_dut2_rx1:                  " & log_expected_dut2_rx1.get(i));
                    -- end if;
                    -- if i < v_items_cnt_log11 then
                    --     print_string("log_forbidden_dut2_rx1:                 " & log_forbidden_dut2_rx1.get(i));
                    -- end if;
                    if i < v_items_cnt_log12 then
                        print_string("log_received_dut2_rx1:                  " & log_received_dut2_rx1.get(i));
                    end if;

                    -- if i < v_items_cnt_log13 then
                    --     print_string("log_expected_dut2_rx2:                  " & log_expected_dut2_rx2.get(i));
                    -- end if;
                    -- if i < v_items_cnt_log14 then
                    --     print_string("log_forbidden_dut2_rx2:                 " & log_forbidden_dut2_rx2.get(i));
                    -- end if;
                    if i < v_items_cnt_log15 then
                        print_string("log_received_dut2_rx2:                  " & log_received_dut2_rx2.get(i));
                    end if;

                    print_string("====================");
                end loop;
            else
                print_string("PRINT_ALL_LOGS:                         Nothing to print. Logs are empty.");
            end if;

            -- 3. Executor done flag
            trigger_general.done <= force true;
            wait for 0 ns;
            trigger_general.done <= release;
        end process;



        -- GENERAL: Executor of the command "REMOVE_ALL_LOGS"
        proc_exec_remove_all_logs : process
            variable v_items_cnt : natural;
        begin
            -- 1. Trigger executor process
            wait until trigger_general.id = REMOVE_ALL_LOGS;

            -- 2. The process
            print_string("REMOVE_ALL_LOGS:");

            -- DUT1
                -- dut1_tx1
            log_sent_dut1_tx1.clear;
            log_expected_dut1_tx1.clear;
            log_forbidden_dut1_tx1.clear;
            log_expected_values_dut1_tx1.clear;
            log_forbidden_values_dut1_tx1.clear;

                -- dut1_rx1
            log_received_dut1_rx1.clear;
            log_expected_dut1_rx1.clear;
            log_forbidden_dut1_rx1.clear;
            log_expected_values_dut1_rx1.clear;
            log_forbidden_values_dut1_rx1.clear;

                -- dut1_rx2
            log_received_dut1_rx2.clear;
            log_expected_dut1_rx2.clear;
            log_forbidden_dut1_rx2.clear;
            log_expected_values_dut1_rx2.clear;
            log_forbidden_values_dut1_rx2.clear;

            -- DUT2
            log_sent_dut2_tx1.clear;
            log_sent_dut2_tx1_aux1.clear;

            log_expected_dut2_rx1.clear;
            log_forbidden_dut2_rx1.clear;
            log_expected_values_dut2_rx1.clear;
            log_forbidden_values_dut2_rx1.clear;
            log_received_dut2_rx1.clear;

            log_expected_dut2_rx2.clear;
            log_forbidden_dut2_rx2.clear;
            log_expected_values_dut2_rx2.clear;
            log_forbidden_values_dut2_rx2.clear;
            log_received_dut2_rx2.clear;

            print_string("REMOVE_ALL_LOGS:                        Removing logs done.");

            -- 3. Executor done flag
            trigger_general.done <= force true;
            wait for 0 ns;
            trigger_general.done <= release;
        end process;



        -- DUT1
        -- TX: Executor of the command "DUT1_RESET_RELEASE"
            proc_exec_tx_dut1_reset_release : process
            begin
                -- 1. Trigger executor process
                wait until trigger_dut1_tx1.id = DUT1_RESET_RELEASE;

                -- 2. The process
                wait for real_clk1_period * 10;
                print_string("DUT1_RESET_RELEASE:                     Releasing signal rst1");
                rst1 <= '0';
                wait for real_clk1_period * 10;

                -- 3. Executor done flag
                trigger_dut1_tx1.done <= force true;
                wait for 0 ns;
                trigger_dut1_tx1.done <= release;
        end process;



        -- TX: Executor of the command "TX_DUT1_ZEROS"
        proc_exec_tx_dut1_zeros : process
            variable v_dut1_tx1 : std_logic_vector(dut1_tx1'range);
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1.id = TX_DUT1_ZEROS;

            -- 2. The process
            v_dut1_tx1 := (others => '0');
            print_string("TX_DUT1_ZEROS:                          " & to_string(v_dut1_tx1));

            -- Original
            -- queue_sent_dut1_tx1.append(to_string(v_dut1_tx1));
            -- log_sent_dut1_tx1.append(to_string(v_dut1_tx1));

            -- Enables the data flow
            queue_sequence_dut1_tx1.append(to_string(v_dut1_tx1));
            log_sequence_dut1_tx1.append(to_string(v_dut1_tx1));

            -- 3. Executor done flag
            trigger_dut1_tx1.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1.done <= release;
        end process;


        -- TX: Executor of the command "TX_DUT1_ONES"
        proc_exec_tx_dut1_ones : process
            variable v_dut1_tx1 : std_logic_vector(dut1_tx1'range);
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1.id = TX_DUT1_ONES;

            -- 2. The process
            v_dut1_tx1 := (others => '1');
            print_string("TX_DUT1_ONES:                           " & to_string(v_dut1_tx1));

            -- Original
            -- queue_sent_dut1_tx1.append(to_string(v_dut1_tx1));
            -- log_sent_dut1_tx1.append(to_string(v_dut1_tx1));

            -- Enables the data flow
            queue_sequence_dut1_tx1.append(to_string(v_dut1_tx1));
            log_sequence_dut1_tx1.append(to_string(v_dut1_tx1));

            -- 3. Executor done flag
            trigger_dut1_tx1.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1.done <= release;
        end process;


        -- TX: Executor of the command "TX_DUT1_RANDOM_VALUE"
        proc_exec_tx_dut1_random_value : process
            variable v_dut1_tx1 : std_logic_vector(dut1_tx1'range);
            variable random_slv : RandomPType;
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1.id = TX_DUT1_RANDOM_VALUE;

            -- 2. The process
            v_dut1_tx1 := random_slv.RandSlv(dut1_tx1'length);
            print_string("TX_DUT1_RANDOM_VALUE:                   " & to_string(v_dut1_tx1));

            -- Original
            -- queue_sent_dut1_tx1.append(to_string(v_dut1_tx1));
            -- log_sent_dut1_tx1.append(to_string(v_dut1_tx1));

            -- Enables the data flow
            queue_sequence_dut1_tx1.append(to_string(v_dut1_tx1));
            log_sequence_dut1_tx1.append(to_string(v_dut1_tx1));



            -- if queue_sequence_dut1_tx1.length /= 0 then
            --     print_string("ERROR");
            --     for i in 0 to queue_sequence_dut1_tx1.length-1 loop
            --         print_string("    queue_sequence_dut1_tx1 = " & queue_sequence_dut1_tx1.get(i));
            --     end loop;
            -- end if;

            -- 3. Executor done flag
            trigger_dut1_tx1.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1.done <= release;
        end process;


        -- TX: Executor of the command "TX_DUT1_SPECIFIC_VALUE"
        proc_exec_tx_dut1_specific_value : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1.id = TX_DUT1_SPECIFIC_VALUE;

            -- 2. The process
            print_string("TX_DUT1_SPECIFIC_VALUE:                 " & to_string(trigger_dut1_tx1.data));

            -- Original
            -- queue_sent_dut1_tx1.append(to_string(trigger_dut1_tx1.data));
            -- log_sent_dut1_tx1.append(to_string(trigger_dut1_tx1.data));

            -- Enables the data flow
            queue_sequence_dut1_tx1.append(to_string(trigger_dut1_tx1.data));
            log_sequence_dut1_tx1.append(to_string(trigger_dut1_tx1.data));

            -- 3. Executor done flag
            trigger_dut1_tx1.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1.done <= release;
        end process;


        -- TX: Executor of the command "TX_DUT1_WAIT_UNTIL_SEQUENCE_TRANSMITTED"
        proc_exec_tx_dut1_wait_until_sequence_transmitted : process
            variable v_sent_cnt : natural := 0;
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1.id = TX_DUT1_WAIT_UNTIL_SEQUENCE_TRANSMITTED;

            -- 2. The process
            print_string("TX_DUT1_WAIT_UNTIL_SEQUENCE_TRANSMITTED:");

            -- Propagate TX transactions from TX sequence
            while queue_sequence_dut1_tx1.length /= 0 loop
                wait_deltas(2);
                print_string("TX_DUT1_WAIT_UNTIL_SEQUENCE_TRANSMITTED TX to go:  queue_sequence_dut1_tx1.length: " & integer'image(queue_sequence_dut1_tx1.length));
                wait_cycles(1, clk1);
            end loop;
            wait_deltas(20);


            -- 3. Executor done flag
            trigger_dut1_tx1.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1.done <= release;
        end process;


        -- RX
        -- RX: Executor of the command "RX_DUT1_WAIT_UNTIL_EVERYTHING_RECEIVED"
        proc_exec_rx_dut1_wait_until_everything_received : process
            variable v_items_cnt : natural := 0;
            variable v_sent_cnt : natural := 0;
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx1.id = RX_DUT1_WAIT_UNTIL_EVERYTHING_RECEIVED;

            -- 2. The process
            print_string("RX_DUT1_WAIT_UNTIL_EVERYTHING_RECEIVED: ");

            -- Make sure all RX signals have propagated successfully
            print_string("RX_DUT1_WAIT_UNTIL_EVERYTHING_RECEIVED: TX done: queue_sent_dut1_tx1.length: " & integer'image(queue_sent_dut1_tx1.length));
            while queue_received_dut1_rx1.length < queue_sent_dut1_tx1.length loop
                wait_deltas(20);
                print_string("RX_DUT1_WAIT_UNTIL_EVERYTHING_RECEIVED: RX done: queue_received_dut1_rx1.length: " & integer'image(queue_received_dut1_rx1.length));
                wait_cycles(1, clk1);
            end loop;
            wait_deltas(20);


            -- 3. Executor done flag
            trigger_dut1_rx1.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx1.done <= release;
        end process;


        -- CHECKER
        -- TX1
        -- CHECKER TX1: Cmd executor of the command "CHECK_DUT1_TX1_IS_SPECIFIC_VALUE"
        proc_exec_check_dut1_tx1_is_specific_value : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1_check.id = CHECK_DUT1_TX1_IS_SPECIFIC_VALUE;

            -- 2. The process
            print_string("CHECK_DUT1_TX1_IS_SPECIFIC_VALUE:       " & to_string(trigger_dut1_tx1_check.data));
            queue_expected_dut1_tx1.append(to_string(trigger_dut1_tx1_check.data));
            log_expected_dut1_tx1.append(to_string(trigger_dut1_tx1_check.data));

            -- while queue_expected_dut1_tx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_tx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1_check.done <= release;
        end process;

        -- CHECKER TX1: Cmd executor of the command "CHECK_DUT1_TX1_IS_SPECIFIC_VALUES"
        proc_exec_check_dut1_tx1_is_specific_values : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1_check.id = CHECK_DUT1_TX1_IS_SPECIFIC_VALUES;

            -- 2. The process
            print_string("CHECK_DUT1_TX1_IS_SPECIFIC_VALUES:      " & to_string(trigger_dut1_tx1_check.data));
            queue_expected_values_dut1_tx1.append(to_string(trigger_dut1_tx1_check.data));
            log_expected_values_dut1_tx1.append(to_string(trigger_dut1_tx1_check.data));

            -- while queue_expected_dut1_tx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_tx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1_check.done <= release;
        end process;

        -- CHECKER TX1: Cmd executor of the command "CHECK_DUT1_TX1_IS_ZERO"
        proc_exec_check_dut1_tx1_is_zero : process
            variable v_data : std_logic_vector(dut1_tx1'range) := (others => '0');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1_check.id = CHECK_DUT1_TX1_IS_ZERO;

            -- 2. The process
            print_string("CHECK_DUT1_TX1_IS_ZERO:                 " & to_string(v_data));
            queue_expected_dut1_tx1.append(to_string(v_data));
            log_expected_dut1_tx1.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_tx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1_check.done <= release;
        end process;

        -- CHECKER TX1: Executor of the command "CHECK_DUT1_TX1_IS_ONE"
        proc_exec_check_dut1_tx1_is_one : process
            variable v_data : std_logic_vector(dut1_tx1'range) := (others => '1');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1_check.id = CHECK_DUT1_TX1_IS_ONE;

            -- 2. The process
            print_string("CHECK_DUT1_TX1_IS_ONE:                  " & to_string(v_data));
            queue_expected_dut1_tx1.append(to_string(v_data));
            log_expected_dut1_tx1.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_tx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1_check.done <= release;
        end process;


        -- CHECKER TX1: Executor of the command "CHECK_DUT1_TX1_ISNOT_SPECIFIC_VALUE"
        proc_exec_check_dut1_tx1_isnot_specific_value : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1_check.id = CHECK_DUT1_TX1_ISNOT_SPECIFIC_VALUE;

            -- 2. The process
            print_string("CHECK_DUT1_TX1_ISNOT_SPECIFIC_VALUE:    " & to_string(trigger_dut1_tx1_check.data));
            queue_forbidden_dut1_tx1.append(to_string(trigger_dut1_tx1_check.data));
            log_forbidden_dut1_tx1.append(to_string(trigger_dut1_tx1_check.data));

            -- while queue_expected_dut1_tx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_tx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1_check.done <= release;
        end process;

        -- CHECKER TX1: Executor of the command "CHECK_DUT1_TX1_ISNOT_SPECIFIC_VALUES"
        proc_exec_check_dut1_tx1_isnot_specific_values : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1_check.id = CHECK_DUT1_TX1_ISNOT_SPECIFIC_VALUES;

            -- 2. The process
            print_string("CHECK_DUT1_TX1_ISNOT_SPECIFIC_VALUES:    " & to_string(trigger_dut1_tx1_check.data));
            queue_forbidden_values_dut1_tx1.append(to_string(trigger_dut1_tx1_check.data));
            log_forbidden_values_dut1_tx1.append(to_string(trigger_dut1_tx1_check.data));

            -- while queue_expected_dut1_tx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_tx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1_check.done <= release;
        end process;

        -- CHECKER TX1: Executor of the command "CHECK_DUT1_TX1_ISNOT_ZERO"
        proc_exec_check_dut1_tx1_isnot_zero : process
            variable v_data : std_logic_vector(dut1_tx1'range) := (others => '0');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1_check.id = CHECK_DUT1_TX1_ISNOT_ZERO;

            -- 2. The process
            print_string("CHECK_DUT1_TX1_ISNOT_ZERO:              " & to_string(v_data));
            queue_forbidden_dut1_tx1.append(to_string(v_data));
            log_forbidden_dut1_tx1.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_tx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1_check.done <= release;
        end process;

        -- CHECKER TX1: Executor of the command "CHECK_DUT1_TX1_ISNOT_ONE"
        proc_exec_check_dut1_tx1_isnot_one : process
            variable v_data : std_logic_vector(dut1_tx1'range) := (others => '1');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1_check.id = CHECK_DUT1_TX1_ISNOT_ONE;

            -- 2. The process
            print_string("CHECK_DUT1_TX1_ISNOT_ONE:               " & to_string(v_data));
            queue_forbidden_dut1_tx1.append(to_string(v_data));
            log_forbidden_dut1_tx1.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_tx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1_check.done <= release;
        end process;


        
        -- RX1
        -- CHECKER RX1: Cmd executor of the command "CHECK_DUT1_RX1_IS_SPECIFIC_VALUE"
        proc_exec_check_dut1_rx1_is_specific_value : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx1_check.id = CHECK_DUT1_RX1_IS_SPECIFIC_VALUE;

            -- 2. The process
            print_string("CHECK_DUT1_RX1_IS_SPECIFIC_VALUE:       " & to_string(trigger_dut1_rx1_check.data));
            queue_expected_dut1_rx1.append(to_string(trigger_dut1_rx1_check.data));
            log_expected_dut1_rx1.append(to_string(trigger_dut1_rx1_check.data));

            -- while queue_expected_dut1_rx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;
            -- while queue_expected_dut1_rx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_rx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx1_check.done <= release;
        end process;

        -- CHECKER RX1: Cmd executor of the command "CHECK_DUT1_RX1_IS_SPECIFIC_VALUES"
        proc_exec_check_dut1_rx1_is_specific_values : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx1_check.id = CHECK_DUT1_RX1_IS_SPECIFIC_VALUES;

            -- 2. The process
            print_string("CHECK_DUT1_RX1_IS_SPECIFIC_VALUES:      " & to_string(trigger_dut1_rx1_check.data));
            queue_expected_values_dut1_rx1.append(to_string(trigger_dut1_rx1_check.data));
            log_expected_values_dut1_rx1.append(to_string(trigger_dut1_rx1_check.data));

            -- while queue_expected_dut1_rx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;
            -- while queue_expected_dut1_rx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_rx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx1_check.done <= release;
        end process;

        -- CHECKER RX1: Cmd executor of the command "CHECK_DUT1_RX1_IS_ZERO"
        proc_exec_check_dut1_rx1_is_zero : process
            variable v_data : std_logic_vector(dut1_rx1'range) := (others => '0');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx1_check.id = CHECK_DUT1_RX1_IS_ZERO;

            -- 2. The process
            print_string("CHECK_DUT1_RX1_IS_ZERO:                 " & to_string(v_data));
            queue_expected_dut1_rx1.append(to_string(v_data));
            log_expected_dut1_rx1.append(to_string(v_data));

            queue_expected_dut1_rx1.append(to_string(v_data));
            log_expected_dut1_rx1.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_rx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx1_check.done <= release;
        end process;

        -- CHECKER RX1: Executor of the command "CHECK_DUT1_RX1_IS_ONE"
        proc_exec_check_dut1_rx1_is_one : process
            variable v_data : std_logic_vector(dut1_rx1'range) := (others => '1');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx1_check.id = CHECK_DUT1_RX1_IS_ONE;

            -- 2. The process
            print_string("CHECK_DUT1_RX1_IS_ONE:                  " & to_string(v_data));
            queue_expected_dut1_rx1.append(to_string(v_data));
            log_expected_dut1_rx1.append(to_string(v_data));

            queue_expected_dut1_rx1.append(to_string(v_data));
            log_expected_dut1_rx1.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_rx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx1_check.done <= release;
        end process;


        -- CHECKER RX1: Executor of the command "CHECK_DUT1_RX1_ISNOT_SPECIFIC_VALUE"
        proc_exec_check_dut1_rx1_isnot_specific_value : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx1_check.id = CHECK_DUT1_RX1_ISNOT_SPECIFIC_VALUE;

            -- 2. The process
            print_string("CHECK_DUT1_RX1_ISNOT_SPECIFIC_VALUE:    " & to_string(trigger_dut1_rx1_check.data));
            queue_forbidden_dut1_rx1.append(to_string(trigger_dut1_rx1_check.data));
            log_forbidden_dut1_rx1.append(to_string(trigger_dut1_rx1_check.data));

            -- while queue_expected_dut1_rx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;
            -- while queue_expected_dut1_rx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_rx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx1_check.done <= release;
        end process;

        -- CHECKER RX1: Executor of the command "CHECK_DUT1_RX1_ISNOT_SPECIFIC_VALUES"
        proc_exec_check_dut1_rx1_isnot_specific_values : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx1_check.id = CHECK_DUT1_RX1_ISNOT_SPECIFIC_VALUES;

            -- 2. The process
            print_string("CHECK_DUT1_RX1_ISNOT_SPECIFIC_VALUES:   " & to_string(trigger_dut1_rx1_check.data));
            queue_forbidden_values_dut1_rx1.append(to_string(trigger_dut1_rx1_check.data));
            log_forbidden_values_dut1_rx1.append(to_string(trigger_dut1_rx1_check.data));

            -- while queue_expected_dut1_rx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;
            -- while queue_expected_dut1_rx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_rx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx1_check.done <= release;
        end process;

        -- CHECKER RX1: Executor of the command "CHECK_DUT1_RX1_ISNOT_ZERO"
        proc_exec_check_dut1_rx1_isnot_zero : process
            variable v_data : std_logic_vector(dut1_rx1'range) := (others => '0');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx1_check.id = CHECK_DUT1_RX1_ISNOT_ZERO;

            -- 2. The process
            print_string("CHECK_DUT1_RX1_ISNOT_ZERO:              " & to_string(v_data));
            queue_forbidden_dut1_rx1.append(to_string(v_data));
            log_forbidden_dut1_rx1.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_rx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx1_check.done <= release;
        end process;

        -- CHECKER RX1: Executor of the command "CHECK_DUT1_RX1_ISNOT_ONE"
        proc_exec_check_dut1_rx1_isnot_one : process
            variable v_data : std_logic_vector(dut1_rx1'range) := (others => '1');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx1_check.id = CHECK_DUT1_RX1_ISNOT_ONE;

            -- 2. The process
            print_string("CHECK_DUT1_RX1_ISNOT_ONE:               " & to_string(v_data));
            queue_forbidden_dut1_rx1.append(to_string(v_data));
            log_forbidden_dut1_rx1.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_rx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx1_check.done <= release;
        end process;


        


        -- RX2
        -- CHECKER RX2: Cmd executor of the command "CHECK_DUT1_RX2_IS_SPECIFIC_VALUE"
        proc_exec_check_dut1_rx2_is_specific_value : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx2_check.id = CHECK_DUT1_RX2_IS_SPECIFIC_VALUE;

            -- 2. The process
            print_string("CHECK_DUT1_RX2_IS_SPECIFIC_VALUE:       " & to_string(trigger_dut1_rx2_check.data));
            queue_expected_dut1_rx2.append(to_string(trigger_dut1_rx2_check.data));
            log_expected_dut1_rx2.append(to_string(trigger_dut1_rx2_check.data));

            -- while queue_expected_dut1_rx2.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_rx2_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx2_check.done <= release;
        end process;

        -- CHECKER RX2: Cmd executor of the command "CHECK_DUT1_RX2_IS_SPECIFIC_VALUES"
        proc_exec_check_dut1_rx2_is_specific_values : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx2_check.id = CHECK_DUT1_RX2_IS_SPECIFIC_VALUES;

            -- 2. The process
            print_string("CHECK_DUT1_RX2_IS_SPECIFIC_VALUES:      " & to_string(trigger_dut1_rx2_check.data));
            queue_expected_values_dut1_rx2.append(to_string(trigger_dut1_rx2_check.data));
            log_expected_values_dut1_rx2.append(to_string(trigger_dut1_rx2_check.data));

            -- while queue_expected_dut1_rx2.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_rx2_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx2_check.done <= release;
        end process;

        -- CHECKER RX2: Cmd executor of the command "CHECK_DUT1_RX2_IS_ZERO"
        proc_exec_check_dut1_rx2_is_zero : process
            variable v_data : std_logic_vector(dut1_rx2'range) := (others => '0');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx2_check.id = CHECK_DUT1_RX2_IS_ZERO;

            -- 2. The process
            print_string("CHECK_DUT1_RX2_IS_ZERO:                 " & to_string(v_data));
            queue_expected_dut1_rx2.append(to_string(v_data));
            log_expected_dut1_rx2.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_rx2_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx2_check.done <= release;
        end process;

        -- CHECKER RX2: Executor of the command "CHECK_DUT1_RX2_IS_ONE"
        proc_exec_check_dut1_rx2_is_one : process
            variable v_data : std_logic_vector(dut1_rx2'range) := (others => '1');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx2_check.id = CHECK_DUT1_RX2_IS_ONE;

            -- 2. The process
            print_string("CHECK_DUT1_RX2_IS_ONE:                  " & to_string(v_data));
            queue_expected_dut1_rx2.append(to_string(v_data));
            log_expected_dut1_rx2.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_rx2_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx2_check.done <= release;
        end process;


        -- CHECKER RX2: Executor of the command "CHECK_DUT1_RX2_ISNOT_SPECIFIC_VALUE"
        proc_exec_check_dut1_rx2_isnot_specific_value : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx2_check.id = CHECK_DUT1_RX2_ISNOT_SPECIFIC_VALUE;

            -- 2. The process
            print_string("CHECK_DUT1_RX2_ISNOT_SPECIFIC_VALUE:    " & to_string(trigger_dut1_rx2_check.data));
            queue_forbidden_dut1_rx2.append(to_string(trigger_dut1_rx2_check.data));
            log_forbidden_dut1_rx2.append(to_string(trigger_dut1_rx2_check.data));

            -- while queue_expected_dut1_rx2.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_rx2_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx2_check.done <= release;
        end process;

        -- CHECKER RX2: Executor of the command "CHECK_DUT1_RX2_ISNOT_SPECIFIC_VALUES"
        proc_exec_check_dut1_rx2_isnot_specific_values : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx2_check.id = CHECK_DUT1_RX2_ISNOT_SPECIFIC_VALUES;

            -- 2. The process
            print_string("CHECK_DUT1_RX2_ISNOT_SPECIFIC_VALUES:   " & to_string(trigger_dut1_rx2_check.data));
            queue_forbidden_values_dut1_rx2.append(to_string(trigger_dut1_rx2_check.data));
            log_forbidden_values_dut1_rx2.append(to_string(trigger_dut1_rx2_check.data));

            -- while queue_expected_dut1_rx2.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_rx2_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx2_check.done <= release;
        end process;

        -- CHECKER RX2: Executor of the command "CHECK_DUT1_RX2_ISNOT_ZERO"
        proc_exec_check_dut1_rx2_isnot_zero : process
            variable v_data : std_logic_vector(dut1_rx2'range) := (others => '0');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx2_check.id = CHECK_DUT1_RX2_ISNOT_ZERO;

            -- 2. The process
            print_string("CHECK_DUT1_RX2_ISNOT_ZERO:              " & to_string(v_data));
            queue_forbidden_dut1_rx2.append(to_string(v_data));
            log_forbidden_dut1_rx2.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_rx2_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx2_check.done <= release;
        end process;

        -- CHECKER RX2: Executor of the command "CHECK_DUT1_RX2_ISNOT_ONE"
        proc_exec_check_dut1_rx2_isnot_one : process
            variable v_data : std_logic_vector(dut1_rx2'range) := (others => '1');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx2_check.id = CHECK_DUT1_RX2_ISNOT_ONE;

            -- 2. The process
            print_string("CHECK_DUT1_RX2_ISNOT_ONE:               " & to_string(v_data));
            queue_forbidden_dut1_rx2.append(to_string(v_data));
            log_forbidden_dut1_rx2.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_rx2_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx2_check.done <= release;
        end process;





        -- DUT2
        -- TX: Executor of the command "TX_DUT2_ERROR_PATTERN_ZEROS"
        proc_exec_tx_dut2_error_pattern_zeros : process
            variable v_dut2_tx1_aux1 : std_logic_vector(dut2_tx1_aux1'range) := (others => '0');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut2_tx.id = TX_DUT2_ERROR_PATTERN_ZEROS;

            -- 2. The process
            print_string("TX_DUT2_ERROR_PATTERN_ZEROS:            " & to_string(v_dut2_tx1_aux1));
            -- dut2_tx1_aux1 <= v_dut2_tx1_aux1;
            queue_sent_dut2_tx1_aux1.append(to_string(v_dut2_tx1_aux1));
            log_sent_dut2_tx1_aux1.append(to_string(v_dut2_tx1_aux1));
            -- print_string("log_sent_dut2_tx1_aux1.get(0):          " & log_sent_dut2_tx1_aux1.get(0));

            -- 3. Executor done flag
            trigger_dut2_tx.done <= force true;
            wait for 0 ns;
            trigger_dut2_tx.done <= release;
        end process;


        -- TX: Executor of the command "TX_DUT2_ERROR_PATTERN_RANDOM_VALUE"
        proc_exec_tx_dut2_error_pattern_random_value : process
            variable random_slv : RandomPType;
            variable v_dut2_tx1_aux1 : std_logic_vector(dut2_tx1_aux1'range) := (others => '0');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut2_tx.id = TX_DUT2_ERROR_PATTERN_RANDOM_VALUE;

            -- 2. The process
            v_dut2_tx1_aux1 := random_slv.RandSlv(dut2_tx1'length);
            print_string("TX_DUT2_ERROR_PATTERN_RANDOM_VALUE:     " & to_string(v_dut2_tx1_aux1));
            -- dut2_tx1_aux1 <= v_dut2_tx1_aux1;
            queue_sent_dut2_tx1_aux1.append(to_string(v_dut2_tx1_aux1));
            log_sent_dut2_tx1_aux1.append(to_string(v_dut2_tx1_aux1));

            -- 3. Executor done flag
            trigger_dut2_tx.done <= force true;
            wait for 0 ns;
            trigger_dut2_tx.done <= release;
        end process;


        -- TX: Executor of the command "TX_DUT2_ERROR_PATTERN_SPECIFIC_VALUE"
        proc_exec_tx_dut2_error_pattern_specific_value : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut2_tx.id = TX_DUT2_ERROR_PATTERN_SPECIFIC_VALUE;

            -- 2. The process
            print_string("TX_DUT2_ERROR_PATTERN_SPECIFIC_VALUE:   " & to_string(trigger_dut2_tx.data));
            queue_sent_dut2_tx1_aux1.append(to_string(trigger_dut2_tx.data));
            log_sent_dut2_tx1_aux1.append(to_string(trigger_dut2_tx.data));

            -- 3. Executor done flag
            trigger_dut2_tx.done <= force true;
            wait for 0 ns;
            trigger_dut2_tx.done <= release;
        end process;


        





        -- Send raw data to the DUT
        -- proc_exec_tx_data_to_dut_noaxi : process
        -- begin
        --     -- 1. Trigger executor process
        --     wait until exec_cmd.id = TX_DATA_TO_DUT;

        --     -- 2. The process
        --     print_string("data TB -> DUT:          " & to_string(exec_cmd.data));
        --     to_dut <= exec_cmd.data;

        --     -- 3. Executor done flag
        --     exec_cmd.done <= force true;
        --     wait for 0 ns;
        --     exec_cmd.done <= release;
        -- end process;

        -- enable_if_axi : if axi_ports_present = true generate
        --     proc_tx_data_to_dut_valid : process
        --     begin
        --         -- 1. Trigger executor process
        --         wait until exec_cmd.id = TX_DATA_TO_DUT_AXI;

        --         -- 2. The process
        --         print_string("data TB -> DUT:          " & to_string(exec_cmd.data));
        --         to_dut <= exec_cmd.data;

        --         -- 3. Executor done flag
        --         exec_cmd.done <= force true;
        --         wait for 0 ns;
        --         exec_cmd.done <= release;
        --     end process;
        -- end generate;


        -- TEST 2: Create an error pattern, if test2 is enabled
        -- proc_exec_gen_rand_error_pattern : process
        --     variable v_zero_vector : std_logic_vector(slv_rx_in_cw'range) := (others => '0');
        --     variable v_cw_before_error : std_logic_vector(slv_rx_in_cw'range) := (others => '0');
        --     variable v_cw_after_error : std_logic_vector(slv_rx_in_cw'range) := (others => '0');
        --     variable v_error_polynomial : std_logic_vector(slv_rx_in_cw'range) := (others => '0');
        -- begin

        --     -- 1. Trigger process with each 'flag_aux_valid2' transaction and proceed if test2 is enabled
        --     wait until exec_cmd.id = GEN_RAND_ERROR_PATTERN;
            
        --     -- 2. The process
        --     -- Wait until CRC is calculated
        --     -- wait on flag_aux_valid2'transaction;
        --     if en_test2 then

        --         -- Prepare the Error polynomial and send it
        --         -- wait_deltas(5);

        --         v_error_polynomial := flip_random_bits_slv(v_zero_vector, v_zero_vector'length, glob_seed1, int_bits_in_error);
        --         dut2_tx1_aux1 <= v_error_polynomial;
        --         print_string("TX CW before error (exe):" & to_string(slv_tx_out_msg & slv_tx_out_crc));
        --         v_cw_after_error := (slv_tx_out_msg & slv_tx_out_crc) xor v_error_polynomial;
        --         slv_rx_in_cw <= force v_cw_after_error;

        --         -- dut2_tx1_aux1 <= force v_error_polynomial;
        --         -- dut2_tx1_aux1 <= release;
        --         -- glob_seed1 <= update_seed(glob_seed1);
        --         wait_deltas(1);
        --         -- print_string("Error TB -> DUT:         " & to_string(dut2_tx1_aux1));

        --         -- 3. Executor done flag
        --         flag_error_polynomial_done <= force true;
        --         wait for 0 ns;
        --         flag_error_polynomial_done <= release;

        --     end if;
        -- end process;


        -- TEST 3: Create an error pattern, if test3 is enabled
        -- proc_exec_gen_specific_error_pattern : process
        --     variable v_zero_vector : std_logic_vector(slv_rx_in_cw'range) := (others => '0');
        --     variable v_cw_before_error : std_logic_vector(slv_rx_in_cw'range) := (others => '0');
        --     variable v_cw_after_error : std_logic_vector(slv_rx_in_cw'range) := (others => '0');
        --     variable v_error_polynomial : std_logic_vector(slv_rx_in_cw'range) := (others => '0');
        -- begin

        --     -- 1. Trigger process with each 'flag_aux_valid1' transaction and proceed if test3 is enabled
        --     -- Wait until CRC is calculated
        --     wait on flag_aux_valid2'transaction;

        --     -- 2. The process
        --     if en_test3 then

        --         -- Prepare the Error polynomial and send it
        --         -- The error polynomial is static (the seed is not changing, is constant)
        --         v_error_polynomial := flip_random_bits_slv(v_zero_vector, v_zero_vector'length, 11, int_bits_in_error);
        --         dut2_tx1_aux1 <= v_error_polynomial;
        --         print_string("TX CW before error (exe):" & to_string(slv_tx_out_msg & slv_tx_out_crc));
        --         v_cw_after_error := (slv_tx_out_msg & slv_tx_out_crc) xor v_error_polynomial;
        --         slv_rx_in_cw <= force v_cw_after_error;

        --         print_string("Error TB -> DUT:         " & to_string(dut2_tx1_aux1));

        --         -- 3. Executor done flag
        --         -- Not needed

        --     end if;
        -- end process;


        -- -- TEST 3: Sample the actual syndrome
        -- proc_exec_add_valid_syndrome_to_queue : process
            
        -- begin

        --     -- 1. Trigger process with each 'flag_aux_valid1' transaction and proceed if test3 is enabled
        --     -- Wait until Syndrome is calculated
        --     wait on flag_aux_valid1'transaction;

        --     -- 2. The process
        --     if en_test3 then

        --         -- Append the Syndrome to the list
        --         wait_deltas(1);
        --         print_string("Added Syndrome to queue3:" & to_string(from_dut));
        --         queue_assert_test3.append(to_string(from_dut));

        --         -- 3. Executor done flag
        --         if queue_assert_test3.length = repetitions then
        --             flag_syndromes_loaded_done <= force true;
        --         end if;
        --     end if;
        -- end process;


        -- 2.2.1 UART_TX_BFM: if tx_bfm ready, send a byte over UART TX BFM (tx rate: 1/baud) to the DUT
        -- proc_tx_to_dut : process
        -- begin
        --     -- 1. Trigger executor process
        --     wait until exec_cmd.id = TX_TXBFM_TO_DUT;

        --     -- 2. The process
        --     print_string("data TX_BFM -> DUT:          " & to_string(exec_cmd.data));
        --     tx_bfm_data <= exec_cmd.data;

        --     -- 3. Executor done flag
        --     exec_cmd.done <= force true;
        --     wait for 0 ns;
        --     exec_cmd.done <= release;
        -- end process;



        -- proc_exec_check_correct_rx_from_dut : process
        -- begin
        --     -- 1. Trigger executor process
        --     wait until exec_cmd.id = CHECK_DATA_FROM_DUT;

        --     -- 2. The process
        --     print_string("Assert output with:       " & to_string(exec_cmd.assert_data));
        --     queue_assert_test1.append(to_string(exec_cmd.assert_data));

        --     -- Executor done flag
        --     exec_cmd.done <= force true;
        --     wait for 0 ns;
        --     exec_cmd.done <= release;
        -- end process;

        -- proc_check_zero_rx_from_dut : process
        -- begin
        --     -- 1. Trigger executor process
        --     wait until exec_cmd.id = CHECK_ZERO_DATA_FROM_DUT;

        --     -- 2. The process
        --     print_string("Assert output with:      " & to_string(to_unsigned(0, from_dut'length)));
        --     queue_assert_test2.append(to_string(exec_cmd.assert_data));

        --     -- 3. Executor done flag
        --     exec_cmd.done <= force true;
        --     wait for 0 ns;
        --     exec_cmd.done <= release;
        -- end process;


        -- proc_check_nonzero_rx_from_dut : process
        -- begin
        --     -- 1. Trigger executor process
        --     wait until exec_cmd.id = CHECK_NONZERO_DATA_FROM_DUT;

        --     -- 2. The process
        --     print_string("Assert output with:      " & to_string(to_unsigned(0, from_dut'length)));
        --     queue_assert_test2.append(to_string(exec_cmd.assert_data));

        --     -- Executor done flag
        --     exec_cmd.done <= force true;
        --     wait for 0 ns;
        --     exec_cmd.done <= release;
        -- end process;


        -- 2.2.2 Wait until the DUT outputs the entire decoded byte from UART_TX_BFM and asssert the value
        -- proc_expecting_from_dut : process
        -- begin
        --     -- 1. Trigger executor process
        --     wait until exec_cmd.id = EXPECT_FROM_DUT;

        --     -- 2. The process
        --     print_string("Expected RX from DUT:          " & to_string(exec_cmd.data));
        --     queue_assert_test1.append(to_string(exec_cmd.data));

        --     -- 3. Executor done flag
        --     exec_cmd.done <= force true;
        --     wait for 0 ns;
        --     exec_cmd.done <= release;
        -- end process;



        -- 2.3.1 Since DUT is now in idle state, ask the DUT to transmit a new byte FROM DUT to UART_RX_BFM
        -- proc_tx_from_dut : process
        -- begin
        --     -- 1. Trigger executor process
        --     wait until exec_cmd.id = TX_DUT_TO_RXBFM;

        --     -- 2. The process
        --     to_uart <= exec_cmd.data;
        --     to_uart_valid <= '1';
        --     wait until rising_edge(to_uart_ack);
        --     print_string("TX data DUT -> RX_BFM:          " & to_string(exec_cmd.data));
        --     to_uart_valid <= '0';

        --     -- 3. Executor done flag
        --     exec_cmd.done <= force true;
        --     wait for 0 ns;
        --     exec_cmd.done <= release;
        -- end process;



        -- 2.3.2 Wait until the UART_RX_BFM outputs the decoded byte and assert the value
        -- proc_expecting_from_rxbfm : process
        -- begin
        --     -- 1. Trigger executor process
        --     wait until exec_cmd.id = EXPECT_FROM_RXBFM;

        --     -- 2. The process
        --     print_string("Expected RX from RX_BFM:       " & to_string(exec_cmd.data));
        --     queue_rx_expected_from_rxbfm.append(to_string(exec_cmd.data));

        --     -- 3. Executor done flag
        --     exec_cmd.done <= force true;
        --     wait for 0 ns;
        --     exec_cmd.done <= release;
        -- end process;



        -- Wait until at least 1 of the queues is empty before printing success
        -- proc_wait_until_queues_empty : process
        -- begin
        --     -- 1. Trigger executor process
        --     wait until trigger_dut1_tx1.id = WAIT_UNTIL_QUEUES_EMPTY_TX;

            -- 2. The process
            -- while queue_assert_test1.length > 0 or queue_rx_expected_from_rxbfm.length > 0 loop
            -- -- while queue_assert_test1.length > 0 loop
            --     wait until rising_edge(clk);
            -- end loop;
            -- while queue_assert_test2.length > 0 loop
            --     wait until rising_edge(clk);
            -- end loop;

        --     -- 3. Executor done flag
        --     exec_cmd.done <= force true;
        --     wait for 0 ns;
        --     exec_cmd.done <= release;
        -- end process;
    
    
    end architecture;