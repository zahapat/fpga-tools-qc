puts $new_file_sim "    -- ${name_file}_tb.${suffix_file}: Testbench for module ${name_file}.${suffix_file}"
puts $new_file_sim "    -- Engineer: $engineer_name"
puts $new_file_sim "    -- Email: $email_addr"
set clock_seconds [clock seconds]
set act_date [clock format $clock_seconds -format %D]
# puts $new_file_sim "    -- Created: $act_date"
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
puts $new_file_sim "        -- Project-specific packages"
puts $new_file_sim "    library $file_library_sim;"
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
puts $new_file_sim "    -- Additional project_specific packages (src)"
puts $new_file_sim "    library $file_library_src;"
puts $new_file_sim "    use $file_library_src.const_pack.all;"
puts $new_file_sim "    use $file_library_src.gtypes_pack.all;"
puts $new_file_sim "    use $file_library_src.signals_pack.all;"
puts $new_file_sim ""
puts $new_file_sim ""
puts $new_file_sim "    entity checkers_${name_file}_tb is"
puts $new_file_sim "    end checkers_${name_file}_tb;"
puts $new_file_sim ""
puts $new_file_sim "    architecture sim of checkers_${name_file}_tb is"
puts $new_file_sim "    begin"
puts $new_file_sim ""
puts $new_file_sim "        -- Checker 2.2.2: Separate process for checking expected data from DUT"
puts $new_file_sim "        proc_checker_from_dut : process"
puts $new_file_sim "        variable test_data : std_logic_vector(7 downto 0);"
puts $new_file_sim "        begin"
puts $new_file_sim "            -- Starts only if valid is active"
puts $new_file_sim "            wait until from_uart_valid;"
puts $new_file_sim "            print_string(\"DUT received:                \" & to_string(from_uart));"
puts $new_file_sim "            assert from_uart = string_bits_to_slv(queue_rx_expected_from_dut.get(0))"
puts $new_file_sim "                report \"from_uart (\" & to_string(from_uart) & "
puts $new_file_sim "                \") not matching test_data: \" & to_string(test_data)"
puts $new_file_sim "                severity failure;"
puts $new_file_sim ""
puts $new_file_sim "            queue_rx_expected_from_dut.delete(0);"
puts $new_file_sim "        end process;"
puts $new_file_sim ""
puts $new_file_sim ""
puts $new_file_sim "        -- Checker 2.3.2: Separate process for checking expected data from UART_RX_BFM"
puts $new_file_sim "        proc_checker_from_rxbfm : process"
puts $new_file_sim "        begin"
puts $new_file_sim "            -- This process is being triggered on rx_bfm_data valid"
puts $new_file_sim "            wait on rx_bfm_data'transaction;"
puts $new_file_sim "            print_string(\"data RX_BFM received:        \" & to_string(rx_bfm_data));"
puts $new_file_sim "            assert rx_bfm_data = string_bits_to_slv(queue_rx_expected_from_rxbfm.get(0))"
puts $new_file_sim "                report \"rx_bfm_data (\" & to_string(from_uart) & "
puts $new_file_sim "                \") not matching test_data:       \" & queue_rx_expected_from_rxbfm.get(0)"
puts $new_file_sim "                severity failure;"
puts $new_file_sim ""
puts $new_file_sim "            queue_rx_expected_from_rxbfm.delete(0);"
puts $new_file_sim "        end process;"
puts $new_file_sim ""
puts $new_file_sim "    end architecture;"
puts -nonewline $new_file_sim "    end architecture;"