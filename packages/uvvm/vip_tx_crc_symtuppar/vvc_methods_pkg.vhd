--==========================================================================================
-- This VVC was generated with Bitvis VVC Generator
--==========================================================================================


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library vip_tx_crc_symtuppar;
  use vip_tx_crc_symtuppar.tx_crc_symtuppar_bfm_pkg.all;
  use vip_tx_crc_symtuppar.vvc_cmd_pkg.all;
  use vip_tx_crc_symtuppar.td_target_support_pkg.all;

--==========================================================================================
--==========================================================================================
package vvc_methods_pkg is

  --==========================================================================================
  -- Types and constants for the TX_CRC_SYMTUPPAR VVC 
  --==========================================================================================
  constant C_VVC_NAME     : string := "TX_CRC_SYMTUPPAR_VVC";

  signal TX_CRC_SYMTUPPAR_VVCT: t_vvc_target_record := set_vvc_target_defaults(C_VVC_NAME);
  alias  THIS_VVCT         : t_vvc_target_record is TX_CRC_SYMTUPPAR_VVCT;
  alias  t_bfm_config is t_tx_crc_symtuppar_bfm_config;

  -- Type found in UVVM-Util types_pkg
  constant C_TX_CRC_SYMTUPPAR_INTER_BFM_DELAY_DEFAULT : t_inter_bfm_delay := (
    delay_type                         => NO_DELAY,
    delay_in_time                      => 0 ns,
    inter_bfm_delay_violation_severity => WARNING
  );

  type t_vvc_config is
  record
    inter_bfm_delay                       : t_inter_bfm_delay; -- Minimum delay between BFM accesses from the VVC. If parameter delay_type is set to NO_DELAY, BFM accesses will be back to back, i.e. no delay.
    cmd_queue_count_max                   : natural;           -- Maximum pending number in command executor before executor is full. Adding additional commands will result in an ERROR.
    cmd_queue_count_threshold             : natural;           -- An alert with severity 'cmd_queue_count_threshold_severity' will be issued if command executor exceeds this count. Used for early warning if command executor is almost full. Will be ignored if set to 0.
    cmd_queue_count_threshold_severity    : t_alert_level;     -- Severity of alert to be initiated if exceeding cmd_queue_count_threshold.
    result_queue_count_max                : natural;
    result_queue_count_threshold          : natural;
    result_queue_count_threshold_severity : t_alert_level;
    bfm_config                            : t_tx_crc_symtuppar_bfm_config; -- Configuration for the BFM. See BFM quick reference.
    msg_id_panel                          : t_msg_id_panel;    -- VVC dedicated message ID panel.
  end record;

  type t_vvc_config_array is array (natural range <>) of t_vvc_config;

  constant C_TX_CRC_SYMTUPPAR_VVC_CONFIG_DEFAULT : t_vvc_config := (
    inter_bfm_delay                       => C_TX_CRC_SYMTUPPAR_INTER_BFM_DELAY_DEFAULT,
    cmd_queue_count_max                   => C_CMD_QUEUE_COUNT_MAX, --  from adaptation package
    cmd_queue_count_threshold             => C_CMD_QUEUE_COUNT_THRESHOLD,
    cmd_queue_count_threshold_severity    => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    result_queue_count_max                => C_RESULT_QUEUE_COUNT_MAX,
    result_queue_count_threshold          => C_RESULT_QUEUE_COUNT_THRESHOLD,
    result_queue_count_threshold_severity => C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY,
    bfm_config                            => C_TX_CRC_SYMTUPPAR_BFM_CONFIG_DEFAULT,
    msg_id_panel                          => C_VVC_MSG_ID_PANEL_DEFAULT
  );

  type t_vvc_status is
  record
    current_cmd_idx  : natural;
    previous_cmd_idx : natural;
    pending_cmd_cnt  : natural;
  end record;

  type t_vvc_status_array is array (natural range <>) of t_vvc_status;

  constant C_VVC_STATUS_DEFAULT : t_vvc_status := (
    current_cmd_idx  => 0,
    previous_cmd_idx => 0,
    pending_cmd_cnt  => 0
  );


  shared variable shared_tx_crc_symtuppar_vvc_config : t_vvc_config_array(0 to C_MAX_VVC_INSTANCE_NUM-1) := (others => C_TX_CRC_SYMTUPPAR_VVC_CONFIG_DEFAULT);
  shared variable shared_tx_crc_symtuppar_vvc_status : t_vvc_status_array(0 to C_MAX_VVC_INSTANCE_NUM-1) := (others => C_VVC_STATUS_DEFAULT);


  --==========================================================================================
  -- Methods dedicated to this VVC 
  -- - These procedures are called from the testbench in order for the VVC to execute
  --   BFM calls towards the given interface. The VVC interpreter will queue these calls
  --   and then the VVC executor will fetch the commands from the queue and handle the
  --   actual BFM execution.
  --==========================================================================================

  --<USER_INPUT> Please insert the VVC procedure declarations here 
  --Example with single VVC channel: 
  procedure tx_crc_symtuppar_write(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    -- constant addr                : in    unsigned;
    constant data                : in    std_logic_vector;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  --Example with multiple VVC channels: 
  procedure tx_crc_symtuppar_read(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant channel             : in    t_channel;
    -- constant addr                : in    unsigned;
    -- constant data                : in    std_logic_vector;
    constant msg                 : in    string;
    constant alert_level         : in    t_alert_level  := ERROR;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  --==============================================================================
  -- VVC Activity
  --==============================================================================
  procedure update_vvc_activity_register( signal global_trigger_vvc_activity_register : inout std_logic;
                                          variable vvc_status                         : inout t_vvc_status;
                                          constant activity                           : in    t_activity;
                                          constant entry_num_in_vvc_activity_register : in    integer;
                                          constant last_cmd_idx_executed              : in    natural;
                                          constant command_queue_is_empty             : in    boolean;
                                          constant scope                              : in string := C_VVC_NAME);

end package vvc_methods_pkg;


package body vvc_methods_pkg is

  --==========================================================================================
  -- Methods dedicated to this VVC
  --==========================================================================================

  --<USER_INPUT> Please insert the VVC procedure implementations here.
  -- These procedures will be used to forward commands to the VVC executor, which will
  -- call the corresponding BFM procedures. 
  -- Example using single channel:
  procedure tx_crc_symtuppar_write( 
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    -- constant addr                : in    unsigned;
    constant data                : in    std_logic_vector;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name : string := "tx_crc_symtuppar_write";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
            --  & ", " & to_string(addr, HEX, AS_IS, INCL_RADIX) & ", " 
            & to_string(data, HEX, AS_IS, INCL_RADIX) 
            & ")";
    -- variable v_normalised_addr    : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH-1 downto 0) := 
    --          normalize_and_check(addr, shared_vvc_cmd.addr, ALLOW_WIDER_NARROWER, "addr", "shared_vvc_cmd.addr", proc_call & " called with to wide addr. " & msg);
    variable v_normalised_data    : std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH-1 downto 0) := 
             normalize_and_check(data, shared_vvc_cmd.data, ALLOW_WIDER_NARROWER, "data", "shared_vvc_cmd.data", proc_call & " called with to wide data. " & msg);
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
  -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
  -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
  -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, WRITE);
    -- shared_vvc_cmd.addr                := v_normalised_addr;
    shared_vvc_cmd.data                := v_normalised_data;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  -- Example using multiple channels:
  procedure tx_crc_symtuppar_read(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant channel             : in    t_channel;
    constant msg                 : in    string;
    constant alert_level         : in    t_alert_level  := ERROR;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name : string := "tx_crc_symtuppar_read";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx, channel) & ")";
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
  -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
  -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
  -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, channel, proc_call, msg, QUEUED, READ);
    shared_vvc_cmd.alert_level         := alert_level;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  --==============================================================================
  -- VVC Activity
  --==============================================================================
  procedure update_vvc_activity_register( signal global_trigger_vvc_activity_register : inout std_logic;
                                          variable vvc_status                         : inout t_vvc_status;
                                          constant activity                           : in    t_activity;
                                          constant entry_num_in_vvc_activity_register : in    integer;
                                          constant last_cmd_idx_executed              : in    natural;
                                          constant command_queue_is_empty             : in    boolean;
                                          constant scope                              : in string := C_VVC_NAME) is
    variable v_activity   : t_activity := activity;
  begin
    -- Update vvc_status after a command has finished (during same delta cycle the activity register is updated)
    if activity = INACTIVE then
      vvc_status.previous_cmd_idx := last_cmd_idx_executed;
      vvc_status.current_cmd_idx  := 0;  
    end if;

    if v_activity = INACTIVE and not(command_queue_is_empty) then
      v_activity := ACTIVE;
    end if;
    shared_vvc_activity_register.priv_report_vvc_activity(vvc_idx               => entry_num_in_vvc_activity_register,
                                                          activity              => v_activity,
                                                          last_cmd_idx_executed => last_cmd_idx_executed);
    if global_trigger_vvc_activity_register /= 'L' then
      wait until global_trigger_vvc_activity_register = 'L';
    end if;
    gen_pulse(global_trigger_vvc_activity_register, 0 ns, "pulsing global trigger for vvc activity", scope, ID_NEVER);
  end procedure;


end package body vvc_methods_pkg;
