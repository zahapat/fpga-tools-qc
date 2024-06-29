    -- alu_gflow.vhd: This block performs the calculation of the equation below where inputs are max 2 bits:
    --                            and Pi is represented as 2 since (mod 2Pi) has been substituted by (mod 4) for feasibility
    --                            in FPGAs:
    --                              ((-1)**s_x * alpha) + ((s_z + r)*Pi)

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    library lib_src;
    use lib_src.types_pack.all;

    entity alu_gflow is
        generic (
            QUBITS_CNT : integer := 4;
            RST_VAL : std_logic := '1';
            SYNCH_FACTORS_CALCULATION : boolean := true
        );
        port (
            CLK             : in  std_logic;
            RST             : in  std_logic;
            QUBIT_VALID     : in  std_logic;
            STATE_QUBIT     : in  natural;
            S_X             : in  std_logic;     -- From TO_MATH_SX_SZ(0) in FSM
            S_Z             : in  std_logic;     -- From TO_MATH_SX_SZ(1) in FSM
            ALPHA_POSITIVE  : in  std_logic_vector(1 downto 0);  -- is unsigned 00, 01, 10, 11
            RAND_BIT        : in  std_logic;
            RANDOM_BUFFER   : out t_random_buffer_2d;
            MODULO_BUFFER   : out t_modulo_buffer_2d;
            DATA_MODULO_OUT : out std_logic_vector(1 downto 0);
            DATA_VALID      : out std_logic
        );
    end alu_gflow;

    architecture rtl of alu_gflow is


        -- Propagate valid signal
        signal sl_valid_factors : std_logic := '0';
        signal sl_data_valid : std_logic := '0';

        -- Gflow state indicating the actual qubit state being processed
        signal natural_state_gflow : natural range 0 to QUBITS_CNT-1 := 0;
        signal natural_state_gflow_async : natural range 0 to QUBITS_CNT-1 := 0;
        signal natural_state_gflow_p1 : natural range 0 to QUBITS_CNT-1 := 0;

        -- Delay alpha_positive
        signal sl_alpha_positive_p1 : std_logic_vector(ALPHA_POSITIVE'high downto 0) := (others => '0');
        signal sl_alpha_positive_p2 : std_logic_vector(ALPHA_POSITIVE'high downto 0) := (others => '0');

        -- Number Pi is represented as number 2 in mod 4
        constant PI : std_logic_vector(2 downto 0) := std_logic_vector(to_signed(2, 3));

        -- Signals for math block pipeline  -- 4-1 downto 0 1111, 4-1 downto 0 1111, = 3 + 3 + 1
        signal minus_one_power_simplified          : std_logic := '0';
        signal s_alpha_multiplied_signed           : std_logic_vector(2 downto 0) := (others => '0');
        signal s_added_random_unsigned             : std_logic_vector(1 downto 0) := (others => '0');
        signal s_added_random_multiplied_unsigned  : std_logic_vector(2 downto 0) := (others => '0');
        signal s_modulo                            : std_logic_vector(3 downto 0) := (others => '0');

        type t_qx_angle_alpha is array(3 downto 0) of std_logic_vector(1 downto 0);
        --                                              0     -1    -2    -3
        constant ALPHA_NEGATIVE : t_qx_angle_alpha := ("01", "10", "11", "00");

        constant AUX_BITS_CORRECTION : signed(s_modulo'range) := (others => '0');

        -- Data Buffer
        signal slv_random_buffer_2d : t_random_buffer_2d := (others => (others => '0'));
        signal slv_modulo_buffer_2d : t_modulo_buffer_2d := (others => (others => '0'));

        -- Change type from sl to slv
        signal slv_random : std_logic_vector(0 downto 0) := (others => '0');

    begin


        -- Sample the random bit on signal valid and stor it to the respective buffer
        RANDOM_BUFFER <= slv_random_buffer_2d;
        slv_random(0) <= RAND_BIT;
        proc_sample_random : process(CLK)
        begin
            if rising_edge(CLK) then

                -- Latch the value
                slv_random_buffer_2d <= slv_random_buffer_2d;

                if QUBIT_VALID = '1' then
                    -- Using comparators, assign the value to the respective data slot
                    for i in 0 to QUBITS_CNT-1 loop
                        if i = STATE_QUBIT then
                            slv_random_buffer_2d(i) <= slv_random;
                        end if;
                    end loop;
                end if;
            end if;
        end process;



        -- Synchronous pipeline math block 1: Parallel synchronous calculation of factors in the functional dependence
        gen_synch_factors_calc_true : if SYNCH_FACTORS_CALCULATION = true generate
            proc_math_block_1 : process(CLK)
            begin
                if rising_edge(CLK) then
                    -- Pass valid signal synchronously
                    sl_valid_factors <= QUBIT_VALID;
                    natural_state_gflow <= STATE_QUBIT;

                    -- Delay signal ALPHA_POSITIVE
                    sl_alpha_positive_p1 <= ALPHA_POSITIVE;

                    -- Power -1^S_X (MSB is 1 for any negative signed number)
                    if ALPHA_POSITIVE = "00" then
                        -- zero is only one for signed numbers: 000
                        s_alpha_multiplied_signed <= '0' & ALPHA_POSITIVE;
                    else
                        if S_X = '0' then
                            -- signed value of positive number alpha
                            s_alpha_multiplied_signed <= S_X & ALPHA_POSITIVE;
                        else
                            -- find negative representation of number alpha
                            s_alpha_multiplied_signed <= S_X & ALPHA_NEGATIVE(to_integer(unsigned(ALPHA_POSITIVE)));     -- simplified
                        end if;
                    end if;

                    -- Add S_Z + RAND_BIT (The result is always positive)
                    if RAND_BIT = '1' then
                        if S_Z = '1' then                       -- 01 or 10
                            s_added_random_multiplied_unsigned <= "10" & '0';   -- Simplified
                        else 
                            s_added_random_multiplied_unsigned <= "01" & '0';   -- Simplified
                        end if;
                    else
                        s_added_random_multiplied_unsigned <= '0' & S_Z & '0';  -- Simplified
                    end if;
                end if;
            end process;
        end generate;



        -- If asynch version
        gen_synch_factors_calc_false : if SYNCH_FACTORS_CALCULATION = false generate

            -- Pass valid signal
            sl_valid_factors <= QUBIT_VALID;
            natural_state_gflow_async <= STATE_QUBIT;

            -- Delay signal ALPHA_POSITIVE
            sl_alpha_positive_p1 <= ALPHA_POSITIVE;

            proc_math_block_1 : process(ALPHA_POSITIVE, RAND_BIT, S_X, S_Z)
            begin
                -- Power -1^S_X (MSB is 1 for any negative signed number)
                if ALPHA_POSITIVE = "00" then
                    -- zero is only one for signed numbers: 000
                    s_alpha_multiplied_signed <= '0' & ALPHA_POSITIVE;
                else
                    if S_X = '0' then
                        -- signed value of positive number alpha
                        s_alpha_multiplied_signed <= S_X & ALPHA_POSITIVE;
                    else
                        -- find negative representation of number alpha
                        s_alpha_multiplied_signed <= S_X & ALPHA_NEGATIVE(to_integer(unsigned(ALPHA_POSITIVE)));     -- simplified
                    end if;
                end if;

                -- Add S_Z + RAND_BIT (The result is always positive)
                if RAND_BIT = '1' then
                    if S_Z = '1' then                       -- 01 or 10
                        s_added_random_multiplied_unsigned <= "10" & '0';   -- Simplified
                    else 
                        s_added_random_multiplied_unsigned <= "01" & '0';   -- Simplified
                    end if;
                else
                    s_added_random_multiplied_unsigned <= '0' & S_Z & '0';  -- Simplified
                end if;
            end process;
        end generate;



        -- Synchronous pipeline math block 3: addition
        DATA_VALID <= sl_data_valid;
        proc_math_block_2 : process(CLK)
        begin
            if rising_edge(CLK) then
                -- Send data valid after signal successfully propagated the module
                sl_data_valid <= sl_valid_factors;
                natural_state_gflow_p1 <= to_integer(unsigned(std_logic_vector(to_unsigned(natural_state_gflow, QUBITS_CNT)) xor std_logic_vector(to_unsigned(natural_state_gflow_async, QUBITS_CNT)))); -- One of them is constantly zero

                -- Delay signal ALPHA_POSITIVE
                sl_alpha_positive_p2 <= sl_alpha_positive_p1;

                -- Calculate the Modulo                                     3 bits signed (2 magnitude bits)          4 bits signed positive (3 magnitude bits)
                s_modulo <= std_logic_vector(signed(AUX_BITS_CORRECTION + signed(s_alpha_multiplied_signed)) + signed('0' & s_added_random_multiplied_unsigned));
            end if;
        end process;

        -- Modulo 2Pi
        DATA_MODULO_OUT <= s_modulo(1 downto 0);



        -- Sample the modulo bit on signal valid and stor it to the respective buffer
        MODULO_BUFFER <= slv_modulo_buffer_2d;
        proc_sample_modulo : process(CLK)
        begin
            if rising_edge(CLK) then
                if sl_data_valid = '1' then
                    -- Using comparators, assign the value to the respective data slot
                    for i in 0 to QUBITS_CNT-1 loop
                        if i = natural_state_gflow_p1 then
                            slv_modulo_buffer_2d(i) <= s_modulo(1 downto 0);
                        end if;
                    end loop;
                end if;
            end if;
        end process;


    end architecture;