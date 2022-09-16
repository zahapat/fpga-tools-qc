    -- Signals that are accessible to all testbench modules/submodules

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    -- SRC Packages
    library lib_src;
    --     * Global project-specific SRC Packages
    use lib_src.const_pack.all;
    use lib_src.types_pack.all;

    --     * Module-specific SRC Packages
    use lib_src.const_srcname_pack.all;
    use lib_src.types_srcname_pack.all;
    use lib_src.signals_srcname_pack.all;


    package signals_srcname_pack is

        ------------------------------------------------
        -- srcname signals
        ------------------------------------------------
        -- USER INPUT
        signal slv_data_out : std_logic_vector(SRCNAME_OUT_DATA_WIDTH-1 downto 0) := (others => '0');


    end package;

    package body signals_srcname_pack is
    end package body;