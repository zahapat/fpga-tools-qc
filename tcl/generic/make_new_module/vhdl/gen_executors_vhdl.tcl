puts $new_file_sim "    -- This file procedures (here executor processes) that come from iniside of the sequencer process from the main tb file"
puts $new_file_sim "    -- All of the executor processes are "
puts $new_file_sim "    --      triggered from exec_cmd.id = command"
puts $new_file_sim "    --      After the end of the processes, a short boolean true pulse is sent"
puts $new_file_sim ""
puts $new_file_sim "    library ieee;"
puts $new_file_sim "    use ieee.std_logic_1164.all;"
puts $new_file_sim "    use ieee.numeric_std.all;"
puts $new_file_sim "    -- use ieee.math_real.all;"
puts $new_file_sim "    -- use ieee.math_complex.all;"
puts $new_file_sim ""
puts $new_file_sim "    use std.textio.all;"
puts $new_file_sim "    use std.env.finish;"
puts $new_file_sim ""
puts $new_file_sim "    -- Additional packages (sim)"
puts $new_file_sim "    library $file_library_sim;"
puts $new_file_sim "        -- Project-specific packages"
puts $new_file_sim "    use $file_library_sim.const_pack_tb.all;"
puts $new_file_sim "    use $file_library_sim.gtypes_pack_tb.all;"
puts $new_file_sim "    use $file_library_sim.signals_pack_tb.all;"
puts $new_file_sim "    "
puts $new_file_sim "        -- Generic packages"
puts $new_file_sim "    use $file_library_sim.print_pack_tb.all;"
puts $new_file_sim "    use $file_library_sim.clk_pack_tb.all;"
puts $new_file_sim "    use $file_library_sim.list_string_pack_tb.all;"
puts $new_file_sim "    use $file_library_sim.print_list_pack_tb.all;"
puts $new_file_sim ""
puts $new_file_sim "    -- Additional project-specific packages (src)"
puts $new_file_sim "    library $file_library_src;"
puts $new_file_sim "    use $file_library_src.const_pack.all;"
puts $new_file_sim "    use $file_library_src.gtypes_pack.all;"
puts $new_file_sim "    use $file_library_src.signals_pack.all;"
puts $new_file_sim ""
puts $new_file_sim ""
puts $new_file_sim "    entity executors_${name_file}_tb is"
puts $new_file_sim "    end executors_${name_file}_tb;"
puts $new_file_sim ""
puts $new_file_sim "    architecture sim of executors_${name_file}_tb is"
puts $new_file_sim "    begin"
puts $new_file_sim "    "
puts $new_file_sim "            -- Procedures from iniside of the sequencer process from the main tb file"
puts $new_file_sim "    "
puts $new_file_sim "            -- 1. Reset DUT"
puts $new_file_sim "            proc_release_reset : process"
puts $new_file_sim "            begin"
puts $new_file_sim "                -- Trigger executor process"
puts $new_file_sim "                wait until exec_cmd.id = RESET_RELEASE;"
puts $new_file_sim "                "
puts $new_file_sim "                wait for clk_period * 10;"
puts $new_file_sim "                print_string(\"Releasing the reset\");"
puts $new_file_sim "                rst <= '0';"
puts $new_file_sim "                wait for clk_period * 10;"
puts $new_file_sim "    "
puts $new_file_sim "                -- Executor done flag"
puts $new_file_sim "                -- overrides previous value; we also want to share the value among all processes"
puts $new_file_sim "                exec_cmd.done <= force true;"
puts $new_file_sim "                wait for 0 ns;"
puts $new_file_sim "                -- all other processes can take control over this .done signal"
puts $new_file_sim "                exec_cmd.done <= release;"
puts $new_file_sim "            end process;"
puts $new_file_sim "    "
puts $new_file_sim "    "
puts $new_file_sim "    "
puts $new_file_sim "            -- 2.2.1 UART_TX_BFM: if tx_bfm ready, send a byte over UART TX BFM (tx rate: 1/baud) to the DUT"
puts $new_file_sim "            proc_tx_to_dut : process"
puts $new_file_sim "            begin"
puts $new_file_sim "                -- Trigger executor process"
puts $new_file_sim "                wait until exec_cmd.id = TX_TXBFM_TO_DUT;"
puts $new_file_sim "    "
puts $new_file_sim "                print_string(\"data TX_BFM -> DUT:          \" & to_string(exec_cmd.data));"
puts $new_file_sim "                tx_bfm_data <= exec_cmd.data;"
puts $new_file_sim "    "
puts $new_file_sim "                -- Executor done flag"
puts $new_file_sim "                exec_cmd.done <= force true;"
puts $new_file_sim "                wait for 0 ns;"
puts $new_file_sim "                exec_cmd.done <= release;"
puts $new_file_sim "            end process;"
puts $new_file_sim "    "
puts $new_file_sim "    "
puts $new_file_sim "    "
puts $new_file_sim "            -- 2.2.2 Wait until the DUT outputs the entire decoded byte from UART_TX_BFM and asssert the value"
puts $new_file_sim "            proc_expecting_from_dut : process"
puts $new_file_sim "            begin"
puts $new_file_sim "                -- Trigger executor process"
puts $new_file_sim "                wait until exec_cmd.id = EXPECT_FROM_DUT;"
puts $new_file_sim "    "
puts $new_file_sim "                print_string(\"Expected RX from DUT:          \" & to_string(exec_cmd.data));"
puts $new_file_sim "                queue_rx_expected_from_dut.append(to_string(exec_cmd.data));"
puts $new_file_sim "    "
puts $new_file_sim "                -- Executor done flag"
puts $new_file_sim "                exec_cmd.done <= force true;"
puts $new_file_sim "                wait for 0 ns;"
puts $new_file_sim "                exec_cmd.done <= release;"
puts $new_file_sim "            end process;"
puts $new_file_sim "    "
puts $new_file_sim "    "
puts $new_file_sim "    "
puts $new_file_sim "            -- 2.3.1 Since DUT is now in idle state, ask the DUT to transmit a new byte FROM DUT to UART_RX_BFM"
puts $new_file_sim "            proc_tx_from_dut : process"
puts $new_file_sim "            begin"
puts $new_file_sim "                -- Trigger executor process"
puts $new_file_sim "                wait until exec_cmd.id = TX_DUT_TO_RXBFM;"
puts $new_file_sim "    "
puts $new_file_sim "                to_uart <= exec_cmd.data;"
puts $new_file_sim "                to_uart_valid <= '1';"
puts $new_file_sim "                wait until rising_edge(to_uart_ack);"
puts $new_file_sim "                print_string(\"TX data DUT -> RX_BFM:          \" & to_string(exec_cmd.data));"
puts $new_file_sim "                to_uart_valid <= '0';"
puts $new_file_sim "    "
puts $new_file_sim "                -- Executor done flag"
puts $new_file_sim "                exec_cmd.done <= force true;"
puts $new_file_sim "                wait for 0 ns;"
puts $new_file_sim "                exec_cmd.done <= release;"
puts $new_file_sim "            end process;"
puts $new_file_sim "    "
puts $new_file_sim "    "
puts $new_file_sim "    "
puts $new_file_sim "            -- 2.3.2 Wait until the UART_RX_BFM outputs the decoded byte and assert the value"
puts $new_file_sim "            proc_expecting_from_rxbfm : process"
puts $new_file_sim "            begin"
puts $new_file_sim "                -- Trigger executor process"
puts $new_file_sim "                wait until exec_cmd.id = EXPECT_FROM_RXBFM;"
puts $new_file_sim "    "
puts $new_file_sim "                print_string(\"Expected RX from RX_BFM:       \" & to_string(exec_cmd.data));"
puts $new_file_sim "                queue_rx_expected_from_rxbfm.append(to_string(exec_cmd.data));"
puts $new_file_sim "    "
puts $new_file_sim "                -- Executor done flag"
puts $new_file_sim "                exec_cmd.done <= force true;"
puts $new_file_sim "                wait for 0 ns;"
puts $new_file_sim "                exec_cmd.done <= release;"
puts $new_file_sim "            end process;"
puts $new_file_sim "    "
puts $new_file_sim "    "
puts $new_file_sim "    "
puts $new_file_sim "            -- Wait until at least 1 of the queues is empty before printing success"
puts $new_file_sim "            proc_wait_until_all_queues_empty : process"
puts $new_file_sim "            begin"
puts $new_file_sim "                -- Trigger executor process"
puts $new_file_sim "                wait until exec_cmd.id = WAIT_UNTIL_QUEUES_EMPTY;"
puts $new_file_sim "    "
puts $new_file_sim "                while queue_rx_expected_from_dut.length > 0 or queue_rx_expected_from_rxbfm.length > 0 loop"
puts $new_file_sim "                    wait until rising_edge(clk);"
puts $new_file_sim "                end loop;"
puts $new_file_sim "    "
puts $new_file_sim "                -- Executor done flag"
puts $new_file_sim "                exec_cmd.done <= force true;"
puts $new_file_sim "                wait for 0 ns;"
puts $new_file_sim "                exec_cmd.done <= release;"
puts $new_file_sim "            end process;"
puts $new_file_sim "    "
puts $new_file_sim "    "
puts -nonewline $new_file_sim "    end architecture;"