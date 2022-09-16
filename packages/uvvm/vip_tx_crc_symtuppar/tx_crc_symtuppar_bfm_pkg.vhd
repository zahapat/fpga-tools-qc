--==========================================================================================
-- This VVC was generated with Bitvis VVC Generator
--==========================================================================================


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--==========================================================================================
--==========================================================================================
package tx_crc_symtuppar_bfm_pkg is

  --==========================================================================================
  -- Types and constants for TX_CRC_SYMTUPPAR BFM 
  --==========================================================================================
  constant C_SCOPE : string := "TX_CRC_SYMTUPPAR BFM";

  -- Optional interface record for BFM signals
  type t_tx_crc_symtuppar_if is record
    -- <USER_INPUT> Insert all BFM signals here
    -- Example:
    -- cs      : std_logic;          -- to dut
    -- addr    : unsigned;           -- to dut
    -- rena    : std_logic;          -- to dut
    -- wena    : std_logic;          -- to dut
    wdata   : std_logic_vector;   -- to dut
    -- ready   : std_logic;          -- from dut
    -- rdata   : std_logic_vector;   -- from dut
  end record;

  -- Configuration record to be assigned in the test harness.
  type t_tx_crc_symtuppar_bfm_config is
  record
    id_for_bfm               : t_msg_id;
    id_for_bfm_wait          : t_msg_id;
    id_for_bfm_poll          : t_msg_id;
    --<USER_INPUT> Insert all BFM config parameters here
    -- Example:
    -- max_wait_cycles          : integer;
    -- max_wait_cycles_severity : t_alert_level;
    clock_period             : time;
  end record;

  -- Define the default value for the BFM config
  constant C_TX_CRC_SYMTUPPAR_BFM_CONFIG_DEFAULT : t_tx_crc_symtuppar_bfm_config := (
    id_for_bfm               => ID_BFM,
    id_for_bfm_wait          => ID_BFM_WAIT,
    id_for_bfm_poll          => ID_BFM_POLL,
    --<USER_INPUT> Insert defaults for all BFM config parameters here
    -- Example:
    -- max_wait_cycles          => 10,
    -- max_wait_cycles_severity => failure,
    clock_period             => -1 ns
  );


  --==========================================================================================
  -- BFM procedures 
  --==========================================================================================


  --<USER_INPUT> Insert BFM procedure declarations here, e.g. read and write operations
  -- It is recommended to also have an init function which sets the BFM signals to their default state
  procedure tx_crc_symtuppar_write (
    signal clk : in std_logic;
    signal write_request : in std_logic_vector;
    signal write_data : out std_logic_vector
  );

  procedure tx_crc_symtuppar_read (
    signal clk : in std_logic;
    signal read_request : in std_logic;
    signal read_valid : out std_logic;
    constant delay_clock_cycles : in natural
  );

end package tx_crc_symtuppar_bfm_pkg;


--==========================================================================================
--==========================================================================================

package body tx_crc_symtuppar_bfm_pkg is


  --<USER_INPUT> Insert BFM procedure implementation here.
  procedure tx_crc_symtuppar_write (
    signal clk : in std_logic;
    signal write_request : in std_logic_vector;
    signal write_data : out std_logic_vector
  ) is
  begin
    log(ID_BFM, "Sending data");
    write_data <= write_request;
    wait until rising_edge(clk);
  end procedure;

  procedure tx_crc_symtuppar_read (
    signal clk : in std_logic;
    signal read_request : in std_logic;
    signal read_valid : out std_logic;
    constant delay_clock_cycles : in natural
  ) is
    variable v_shift_left : std_logic_vector(delay_clock_cycles-1 downto 0) := (others => '0');
  begin

    loop
      if rising_edge(clk) then
        v_shift_left(v_shift_left'high downto 0) := 
        v_shift_left(v_shift_left'high-1 downto 0) & read_request;
      end if;

      if v_shift_left(v_shift_left'high) = '1' then
        log(ID_BFM, "Data valid");
        read_valid <= '1';
      else
        read_valid <= '0';
      end if;

      -- exit when v_shift_left = std_logic_vector(to_unsigned(0, v_shift_left'length)) 
      --   and read_request = '0';
      wait until rising_edge(clk);
    end loop;

  end procedure;


end package body tx_crc_symtuppar_bfm_pkg;

