-- This package contains all global types of the TB env accessible to all SIM modules
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_src;
use lib_src.const_pack.all;
use lib_src.generics.all;

package types_pack is

    -- Photon Counter
    -- type t_photon_counter_2d is array(MAX_QUBITS_CNT*2-1 downto 0) of std_logic_vector(8-1 downto 0);
    type t_photon_counter_2d is array(MAX_QUBITS_CNT*2-1 downto 0) of std_logic_vector(1-1 downto 0);

    -- Buffers From G-Flow Module
    type t_qubit_buffer_2d is array(MAX_QUBITS_CNT-1 downto 0) of std_logic_vector(2-1 downto 0);
    type t_alpha_buffer_2d is array(MAX_QUBITS_CNT-1 downto 0) of std_logic_vector(2-1 downto 0);

    subtype st_transaction_data_max_width is natural range 32-4-1 downto 0;
    type t_time_stamp_buffer_2d is array(MAX_QUBITS_CNT downto 0) of std_logic_vector(st_transaction_data_max_width);

    -- Buffers From Math Module
    type t_random_buffer_2d is array(MAX_QUBITS_CNT-1 downto 0) of std_logic_vector(0 downto 0);
    type t_modulo_buffer_2d is array(MAX_QUBITS_CNT-1 downto 0) of std_logic_vector(2-1 downto 0);

    type t_sx_buffer_2d is array(MAX_QUBITS_CNT-1 downto 0) of std_logic_vector(0 downto 0);
    type t_sz_buffer_2d is array(MAX_QUBITS_CNT-1 downto 0) of std_logic_vector(0 downto 0);

end package;

package body types_pack is
end package body;