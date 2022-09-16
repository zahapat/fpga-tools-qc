    -- This package contains all global types accessible to all SRC modules

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    -- SRC Packages
    library lib_src;
    --     * Module-specific SRC Packages
    use lib_src.const_srcname_pack.all;

    --     * Global project-specific SRC Packages
    use lib_src.const_pack.all;
    use lib_src.types_pack.all;
    use lib_src.signals_pack.all;


    package types_srcname_pack is

        ------------------------------------------------
        -- srcname types
        ------------------------------------------------
        -- USER INPUT
        type t_array_2d is array (SRCNAME_OUT_DATA_WIDTH downto 0) of std_logic_vector(SRCNAME_OUT_DATA_WIDTH downto 0);

    end package;

    package body types_srcname_pack is
    end package body;