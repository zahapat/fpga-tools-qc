    -- This package contains all global types accessible to all SRC modules

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    -- SRC Packages
    library lib_src;
    --     * Module-specific SRC Packages (not used)
    -- use lib_src.const_lfsr_inemul_pack.all;
    -- use lib_src.types_lfsr_inemul_pack.all;
    -- use lib_src.signals_lfsr_inemul_pack.all;

    --     * Global project-specific SRC Packages
    use lib_src.const_pack.all;
    use lib_src.types_pack.all;
    use lib_src.signals_pack.all;


    -- TB Packages
    --     * Module-specific TB Packages
    library lib_sim;
    use lib_sim.const_lfsr_inemul_pack_tb.all;
    use lib_sim.types_lfsr_inemul_pack_tb.all;
    use lib_sim.signals_lfsr_inemul_pack_tb.all;

    --     * Global Project-specific TB Packages
    use lib_sim.const_pack_tb.all;
    use lib_sim.types_pack_tb.all;
    use lib_sim.signals_pack_tb.all;

    package triggers_lfsr_inemul_pack_tb is


        -- GENERAL triggers
        -- Enumerated type for all possible commands / values declaration
        type t_cmd_id_general is (
            -- No operation / process not used command
            NOOP,

            DUT1_REMOVE_ALL_QUEUES,

            PRINT_ALL_LOGS,
            REMOVE_ALL_LOGS,

            -- Empty queue command
            WAIT_UNTIL_QUEUES_EMPTY_TX
        );


        -- Record types for commands for triggering executors, data and done flag
        type rec_cmd_general is record
            id   : t_cmd_id_general;
            done : boolean;
        end record;


        -- Prototypes for triggering TX (write) commands
        procedure cmd_general (
            signal cmd : inout rec_cmd_general;
            id : t_cmd_id_general
        );

        -- Declare triggers: Interface for executors
        signal trigger_general : rec_cmd_general;



        -- DUT1 triggers
        -- Enumerated type for all possible commands / values declaration
        type t_cmd_id_dut1_tx is (
            -- No operation / process not used command
            NOOP,

            -- Reset release command
            DUT1_RESET_RELEASE,

            -- Data direction commands: TX to DUT
            TX_DUT1_ZEROES,
            TX_DUT1_ONES,
            TX_DUT1_RANDOM_VALUE,
            TX_DUT1_SPECIFIC_VALUE,

            TX_DUT1_WAIT_UNTIL_SEQUENCE_TRANSMITTED

            -- REMOVE_ALL_LOGS,
            -- PRINT_ALL_LOGS,

            -- Empty queue command
            -- WAIT_UNTIL_QUEUES_EMPTY_TX
        );

        type t_cmd_id_dut1_rx is (
            -- No operation / process not used command
            NOOP,

            -- Not supported yet
            RX_DUT1_WAIT_UNTIL_EVERYTHING_RECEIVED,

            -- Empty queue command
            WAIT_UNTIL_QUEUES_EMPTY_RX
        );

        type t_cmd_id_dut1_check is (
            -- No operation / process not used command
            NOOP,

            -- TX1
            CHECK_DUT1_TX1_IS_SPECIFIC_VALUE,
            CHECK_DUT1_TX1_IS_SPECIFIC_VALUES,
            CHECK_DUT1_TX1_ISNOT_SPECIFIC_VALUE,
            CHECK_DUT1_TX1_ISNOT_SPECIFIC_VALUES,
            CHECK_DUT1_TX1_IS_ZERO,
            CHECK_DUT1_TX1_ISNOT_ZERO,
            CHECK_DUT1_TX1_IS_ONE,
            CHECK_DUT1_TX1_ISNOT_ONE,

            -- RX1
            CHECK_DUT1_RX1_IS_SPECIFIC_VALUE,
            CHECK_DUT1_RX1_IS_SPECIFIC_VALUES,
            CHECK_DUT1_RX1_ISNOT_SPECIFIC_VALUE,
            CHECK_DUT1_RX1_ISNOT_SPECIFIC_VALUES,
            CHECK_DUT1_RX1_IS_ZERO,
            CHECK_DUT1_RX1_ISNOT_ZERO,
            CHECK_DUT1_RX1_IS_ONE,
            CHECK_DUT1_RX1_ISNOT_ONE,

            -- RX2
            CHECK_DUT1_RX2_IS_SPECIFIC_VALUE,
            CHECK_DUT1_RX2_IS_SPECIFIC_VALUES,
            CHECK_DUT1_RX2_ISNOT_SPECIFIC_VALUE,
            CHECK_DUT1_RX2_ISNOT_SPECIFIC_VALUES,
            CHECK_DUT1_RX2_IS_ZERO,
            CHECK_DUT1_RX2_ISNOT_ZERO,
            CHECK_DUT1_RX2_IS_ONE,
            CHECK_DUT1_RX2_ISNOT_ONE


            -- CHECK_DUT1_REMOVE_ALL_QUEUES

            -- CHECK_DUT1_WAIT_UNTIL_CHECKS_DONE,
            -- WAIT_UNTIL_QUEUES_EMPTY
        );

        -- Record types for commands for triggering executors, data and done flag
        type rec_cmd_dut1_tx1 is record
            id   : t_cmd_id_dut1_tx;
            data : std_logic_vector(dut1_tx1'range);
            done : boolean;
        end record;


        type rec_cmd_dut1_rx1 is record
            id   : t_cmd_id_dut1_rx;
            data : std_logic_vector(dut1_rx1'range);
            done : boolean;
        end record;
        type rec_cmd_dut1_rx2 is record
            id   : t_cmd_id_dut1_rx;
            data : std_logic_vector(dut1_rx2'range);
            done : boolean;
        end record;


        type rec_cmd_dut1_tx1_check is record
            id   : t_cmd_id_dut1_check;
            data : std_logic_vector(dut1_tx1'range);
            done : boolean;
        end record;
        type rec_cmd_dut1_rx1_check is record
            id   : t_cmd_id_dut1_check;
            data : std_logic_vector(dut1_rx1'range);
            done : boolean;
        end record;
        type rec_cmd_dut1_rx2_check is record
            id   : t_cmd_id_dut1_check;
            data : std_logic_vector(dut1_rx2'range);
            done : boolean;
        end record;

        -- Prototypes for triggering TX (write) commands
        procedure cmd_dut1_tx1 (
            signal cmd : inout rec_cmd_dut1_tx1;
            id : t_cmd_id_dut1_tx;
            data : std_logic_vector(dut1_tx1'range)
        );


        procedure cmd_dut1_rx1 (
            signal cmd : inout rec_cmd_dut1_rx1;
            id : t_cmd_id_dut1_rx;
            data : std_logic_vector(dut1_rx1'range)
        );
        procedure cmd_dut1_rx2 (
            signal cmd : inout rec_cmd_dut1_rx2;
            id : t_cmd_id_dut1_rx;
            data : std_logic_vector(dut1_rx2'range)
        );


        procedure cmd_dut1_tx1_check (
            signal cmd : inout rec_cmd_dut1_tx1_check;
            id : t_cmd_id_dut1_check;
            data : std_logic_vector(dut1_tx1'range)
        );
        procedure cmd_dut1_rx1_check (
            signal cmd : inout rec_cmd_dut1_rx1_check;
            id : t_cmd_id_dut1_check;
            data : std_logic_vector(dut1_rx1'range)
        );
        procedure cmd_dut1_rx2_check (
            signal cmd : inout rec_cmd_dut1_rx2_check;
            id : t_cmd_id_dut1_check;
            data : std_logic_vector(dut1_rx2'range)
        );

        -- Declare triggers: Interface for executors
        signal trigger_dut1_tx1 : rec_cmd_dut1_tx1;

        signal trigger_dut1_rx1 : rec_cmd_dut1_rx1;
        signal trigger_dut1_rx2 : rec_cmd_dut1_rx2;

        signal trigger_dut1_tx1_check : rec_cmd_dut1_tx1_check;
        signal trigger_dut1_rx1_check : rec_cmd_dut1_rx1_check;
        signal trigger_dut1_rx2_check : rec_cmd_dut1_rx2_check;


    end package;

    package body triggers_lfsr_inemul_pack_tb is


        -- GENERAL
        procedure cmd_general (
            signal cmd : inout rec_cmd_general;
            id : t_cmd_id_general
        ) is begin
            -- Executing the current command
            cmd.done <= false;
            cmd.id <= id;

            -- Wait until the command has been completed
            wait until cmd.done = true;

            -- Set ready for the next command
            cmd.id <= NOOP;
        end procedure;


        -- DUT1
        -- TX (write) command body
        procedure cmd_dut1_tx1 (
            signal cmd : inout rec_cmd_dut1_tx1;
            id : t_cmd_id_dut1_tx;
            data : std_logic_vector(dut1_tx1'range)
        ) is begin
            -- Executing the current command
            cmd.done <= false;
            cmd.id <= id;
            cmd.data <= data;

            -- Wait until the command has been completed
            wait until cmd.done = true;

            -- Set ready for the next command
            cmd.id <= NOOP;
        end procedure;

        -- RX (read) command body
        procedure cmd_dut1_rx1 (
            signal cmd : inout rec_cmd_dut1_rx1;
            id : t_cmd_id_dut1_rx;
            data : std_logic_vector(dut1_rx1'range)
        ) is begin
            -- Executing the current command
            cmd.done <= false;
            cmd.id <= id;
            cmd.data <= data;

            -- Wait until the command has been completed
            wait until cmd.done = true;

            -- Set ready for the next command
            cmd.id <= NOOP;
        end procedure;
        procedure cmd_dut1_rx2 (
            signal cmd : inout rec_cmd_dut1_rx2;
            id : t_cmd_id_dut1_rx;
            data : std_logic_vector(dut1_rx2'range)
        ) is begin
            -- Executing the current command
            cmd.done <= false;
            cmd.id <= id;
            cmd.data <= data;

            -- Wait until the command has been completed
            wait until cmd.done = true;

            -- Set ready for the next command
            cmd.id <= NOOP;
        end procedure;

        -- CHECK command body
        procedure cmd_dut1_tx1_check (
            signal cmd : inout rec_cmd_dut1_tx1_check;
            id : t_cmd_id_dut1_check;
            data : std_logic_vector(dut1_tx1'range)
        ) is begin
            -- Executing the current command
            cmd.done <= false;
            cmd.id <= id;
            cmd.data <= data;

            -- Wait until the command has been completed
            wait until cmd.done = true;

            -- Set ready for the next command
            cmd.id <= NOOP;
        end procedure;
        procedure cmd_dut1_rx1_check (
            signal cmd : inout rec_cmd_dut1_rx1_check;
            id : t_cmd_id_dut1_check;
            data : std_logic_vector(dut1_rx1'range)
        ) is begin
            -- Executing the current command
            cmd.done <= false;
            cmd.id <= id;
            cmd.data <= data;

            -- Wait until the command has been completed
            wait until cmd.done = true;

            -- Set ready for the next command
            cmd.id <= NOOP;
        end procedure;
        procedure cmd_dut1_rx2_check (
            signal cmd : inout rec_cmd_dut1_rx2_check;
            id : t_cmd_id_dut1_check;
            data : std_logic_vector(dut1_rx2'range)
        ) is begin
            -- Executing the current command
            cmd.done <= false;
            cmd.id <= id;
            cmd.data <= data;

            -- Wait until the command has been completed
            wait until cmd.done = true;

            -- Set ready for the next command
            cmd.id <= NOOP;
        end procedure;

    end package body;