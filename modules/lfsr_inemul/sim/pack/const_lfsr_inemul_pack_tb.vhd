    -- Constants that are accessible to all testbench modules/submodules

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    package const_lfsr_inemul_pack_tb is


        ------------------------------------------------
        -- lfsr_inemul_tb
        ------------------------------------------------
        -- Keep & modify
        constant real_clk1_hz : real := 200.0e6;
        constant real_clk1_period : time := 1 sec / real_clk1_hz;

        -- constant CYCLES_WAIT_FOR_rx_dut1 : natural := 3;

        ------------------------------------------------
        -- lfsr_inemul constants
        ------------------------------------------------
        -- USER INPUT
        constant SYMBOL_WIDTH    : integer := 8;
        

    end package;

    package body const_lfsr_inemul_pack_tb is
    end package body;