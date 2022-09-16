    ---------------------------------
    -- INSTANTIATE GENERIC PACKAGE --
    ---------------------------------
    -- Instantiate a generic package and construct a new list (of strings)
    library lib_sim;
    package list_string_pack_tb is new lib_sim.list_pack_tb generic map(data_type => string);
