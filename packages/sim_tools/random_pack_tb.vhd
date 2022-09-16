    -- FOR COMPILING USE VHDL 2008
    --      -> compile before testbenches

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    -- OSVVM Packages
    library osvvm;
    use osvvm.RandomPkg.all;

    use std.textio.all;

    -- library lib_sim;
    -- use lib_sim.const_pack_tb.all;

    -- library lib_src;
    -- use lib_src.types_pck.all;

    -- Prototypes of the subprograms
    package random_pack_tb is

        -- Random real number generator
        -- rand_real(real_max_val, real_min_val, int_seed1, int_seed2)
        -- rand_real(0.1, 10.1, 1, 2)
        impure function rand_real (
            real_min_val, real_max_val : real;
            int_seed1, int_seed2 : integer := 1
        ) return real;

        -- Random 32-bit (64-bit in VHDL 2019) integer number generator
        -- rand_int(int_max_val, int_min_val, int_seed1, int_seed2)
        -- rand_int(0, 10, 1, 2)
        impure function rand_int (
            int_min_val, int_max_val : integer;
            int_seed1, int_seed2 : natural := 1
        ) return integer;


        -- Random SLV generator
        -- rand_slv (int_bits_cnt, int_seed1, int_seed2)
        -- rand_int(slv_my_vector'length, 1, 2)
        -- rand_int(10, 1, 2)
        impure function rand_slv (
            constant int_length : integer;
            int_seed1, int_seed2 : integer := 1
        ) return std_logic_vector;


        -- Random Time value generator (ns, ms, sec, ...)
        -- rand_time_ns (time_max, time_min, ns, 1, 2)
        -- rand_time_ns (1, 50, ns, 1, 2)
        impure function rand_time(
            min_val, max_val : time; 
            unit : time := ns;
            int_seed1, int_seed2 : integer := 1
        ) return time;


        -- Update 1 Seed
        impure function update_seed (int_seed : positive) return positive;


        -- Randomly FLIP X different bits in an slv vector
        impure function flip_random_bits_slv (
            slv_bit_vector : std_logic_vector;
            int_length : natural;
            int_seed : integer := 1;
            int_bits_to_flip_cnt : natural
        ) return std_logic_vector;

    end package;

    -- Bodies of all the prototypes
    package body random_pack_tb is

        -- Random real number generator
        -- rand_real(real_max_val, real_min_val, int_seed1, int_seed2)
        -- rand_real(0.1, 10.1, 1, 2)
        impure function rand_real (
            real_min_val, real_max_val : real;
            int_seed1, int_seed2 : integer := 1
        ) return real is
            variable r : real;
            variable seed1 : integer := int_seed1;
            variable seed2 : integer := int_seed2;
        begin
            uniform(seed1, seed2, r);
            return r * (real_max_val - real_min_val) + real_min_val;
        end function;


        -- Random 32-bit (64-bit in VHDL 2019) integer number generator
        -- rand_int(int_max_val, int_min_val, int_seed1, int_seed2)
        -- rand_int(0, 10, 1, 2)
        impure function rand_int (
            int_min_val, int_max_val : integer;
            int_seed1, int_seed2 : natural := 1
        ) return integer is
            variable r : real;
            variable seed1 : natural := int_seed1;
            variable seed2 : natural := int_seed2;
        begin
            uniform(seed1, seed2, r);
            return integer(round( r * real(int_max_val - int_min_val + 1) + real(int_min_val) - 0.5));
        end function;


        -- Random SLV generator
        -- rand_slv (int_bits_cnt, int_seed1, int_seed2)
        -- rand_int(slv_my_vector'length, 1, 2)
        -- rand_int(10, 1, 2)
        impure function rand_slv (
            constant int_length : integer;
            int_seed1, int_seed2 : integer := 1
        ) return std_logic_vector is
            variable r   : real;
            variable slv : std_logic_vector(int_length-1 downto 0);
            variable seed1 : integer := int_seed1;
            variable seed2 : integer := int_seed2;
        begin
            for i in slv'range loop
                uniform(seed1, seed2, r);
                slv(i) := '1' when r > 0.5 else '0';
            end loop;
            return slv;
        end function;


        -- Random Time value generator (ns, ms, sec, ...)
        -- rand_time_ns (time_max, time_min, ns, 1, 2)
        -- rand_time_ns (1, 50, ns, 1, 2)
        impure function rand_time (
            min_val, max_val : time; 
            unit : time := ns;
            int_seed1, int_seed2 : integer := 1
        ) return time is
            variable r, r_scaled, min_real, max_real : real;
            variable seed1 : integer := int_seed1;
            variable seed2 : integer := int_seed2;
        begin
            uniform(seed1, seed2, r);
            min_real := real(min_val / unit);
            max_real := real(max_val / unit);
            r_scaled := r * (max_real - min_real) + min_real;
            return real(r_scaled) * unit;
        end function;


        -- Update 1 seed
        impure function update_seed (
            int_seed : positive
        ) return positive is
            variable v_rand_int : RandomPType;
        begin
            return abs(v_rand_int.RandInt(1, 2147483647));
        end function;


        -- Randomly FLIP X different bits in an slv vector
        impure function flip_random_bits_slv (
            slv_bit_vector : std_logic_vector;
            int_length : natural;
            int_seed : integer := 1;
            int_bits_to_flip_cnt : natural
        ) return std_logic_vector is
            variable v_update_int_seed : integer := 1;
            variable v_seed1 : integer := 1;
            variable v_seed2 : integer := 1;
            variable v_slv_seed1 : std_logic_vector(30 downto 0) := (others => '0');
            variable v_slv_seed2 : std_logic_vector(30 downto 0) := (others => '0');
            variable v_rand_int : RandomPType;
            variable v_rand_slv : RandomPType;
            variable v_prev_rand_int : integer := 0;
            variable v_act_rand_int : integer := 0;
            variable v_bitflip_slv : std_logic_vector(int_length-1 downto 0) := (others => '0');
            variable v_int_total_number_of_flips : natural := 0;
            variable v_out_slv : std_logic_vector(int_length-1 downto 0) := (others => '0');
            variable v_correct_bits_to_flip : natural := int_length;
        begin

            -- Correct invalid int_bits_to_flip_cnt
            if int_bits_to_flip_cnt /= 0 then
                if int_bits_to_flip_cnt > v_bitflip_slv'length then
                    report "flip_random_bits_slv: Function input (int_bits_to_flip_cnt) overloaded.";
                else
                    v_correct_bits_to_flip := int_bits_to_flip_cnt;
                end if;


                -- Until the required number of flips
                v_update_int_seed := abs(int_seed);
                while v_int_total_number_of_flips /= v_correct_bits_to_flip loop

                        -- Prepare a random position, different than the previous one
                        v_seed1 := abs(v_rand_int.RandInt(1, 2147483647));
                        v_seed2 := rand_int(1, 2147483647, v_seed1, abs(v_update_int_seed));
                        v_act_rand_int := rand_int(v_bitflip_slv'low, v_bitflip_slv'high, v_seed1, v_seed2);

                        while v_act_rand_int = v_prev_rand_int loop
                            v_seed1 := abs(v_rand_int.RandInt(1, 2147483647));
                            v_seed2 := rand_int(1, 2147483647, v_seed1, abs(v_update_int_seed));
                            v_act_rand_int := rand_int(v_bitflip_slv'low, v_bitflip_slv'high, v_seed1, v_seed2);
                        end loop;

                        -- Modify the bitflip id vector
                        v_bitflip_slv(v_act_rand_int) := '1';

                        -- Update rand int
                        v_prev_rand_int := v_act_rand_int;

                        -- Check for the number of flips in total
                        v_int_total_number_of_flips := 0;
                        for i in v_bitflip_slv'range loop
                            if v_bitflip_slv(i) = '1' then
                                v_int_total_number_of_flips := v_int_total_number_of_flips + 1;
                            end if;
                        end loop;

                end loop;

                -- Flip bits
                v_out_slv := slv_bit_vector;
                for i in v_bitflip_slv'range loop
                    if v_bitflip_slv(i) = '1' then
                        v_out_slv(i) := not(v_out_slv(i));
                    end if;
                end loop;
            end if;

            return v_out_slv;
        end function;

        ----------------------
        -- Randomize arrays --
        ----------------------
        -- subtype arr_elem_type is std_logic_vector(3 downto 0);
        -- type arr_type is array (0 to 4) of arr_elem_type;
        -- variable v_arr : arr_type := (x"0", x"1", x"2", x"3", x"4");


        -- Shuffle 2D SLV array items
        -- TO DO
        -- procedure shuffle_items (variable a : arr_type) is
        --     variable j : integer;
        --     variable tmp : arr_elem_type;
        --   begin
        --     -- Fisher-Yates shuffle
        --     for i in a'high downto a'low loop
        --         j := rand_int(0, i);
        --         tmp := v_arr(i);
        --         v_arr(i) := v_arr(j);
        --         v_arr(j) := tmp;
        --     end loop;
        -- end procedure;

        -- Pick random array item (uniform probability)
        -- TO DO
        -- impure function rand_item(a : arr_type) return arr_elem_type is
        -- begin
        --     return a(rand_int(a'low, a'high));
        -- end function;

        -- Pick random array item (weighted probability)
        -- TO DO
        -- type arr_weights_type is array (0 to 4) of real;
        -- variable arr_weights : arr_weights_type := (10.0, 5.0, 30.0, 15.0, 40.0);
        -- impure function rand_item (
        --     a : arr_type;
        --     weights : arr_weights_type;
        --     int_seed1, int_seed2 : integer := 0
        -- ) return arr_elem_type is
        --         variable weights_sum : real := 0.0;
        --         variable weights_acc : real := 0.0;
        --         variable r : real;
        --     begin
        --         for i in weights'range loop
        --             weights_sum := weights_sum + weights(i);
        --         end loop;
        
        --         uniform(int_seed1, int_seed2, r);
        
        --         for i in weights'range loop
        --             weights_acc := weights_acc + weights(i)/weights_sum;
        --             if weights_acc >= r then
        --                 return a(i);
        --             end if;
        --         end loop;
        --   end function;


    end package body;