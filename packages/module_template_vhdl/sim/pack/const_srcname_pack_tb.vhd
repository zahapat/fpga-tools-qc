    -- Constants that are accessible to all testbench modules/submodules

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    package const_srcname_pack_tb is


        ------------------------------------------------
        -- srcname_tb
        ------------------------------------------------
        -- Keep & modify
        constant int_clk1_hz : integer := 100e6;
        constant real_clk1_hz : real := 100.0e6;
        constant real_clk1_period : time := 1 sec / real_clk1_hz;

        constant CYCLES_WAIT_FOR_rx_dut1 : natural := 3;
        -- constant CYCLES_WAIT_FOR_rx_dut2 : natural := 3;
        -- constant CYCLES_WAIT_TOTAL : natural := CYCLES_WAIT_FOR_rx_dut1 + CYCLES_WAIT_FOR_rx_dut2;

        ------------------------------------------------
        -- srcname constants
        ------------------------------------------------
        -- USER INPUT
        constant SYMBOL_WIDTH    : integer := 4;
        constant MSG_SYMBOLS     : integer := 11;
        constant ZEROS_ADDED     : integer := 16;
        constant TUPLE_WIDTH     : integer := 4;
        constant TUPLES_CNT      : integer := 3;
        constant SUBMESSAGES_CNT : integer := 3;
        constant SYNCH_DESIGN    : boolean := true;
        constant REGS_SUBMSG_CNT : integer := 1; -- this must be 1, other values are not supported yet

    end package;

    package body const_srcname_pack_tb is
    end package body;