    -- lfsr_bitgen.vhd: This code contains the hardware architecture of the Galois Linear Feedback Shift Register
    -- for pseudo-random number generation
    -- More irreducible primitive polynomials: 
    -- https://link.springer.com/content/pdf/bbm%3A978-1-4615-1509-8%2F1.pdf
    

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    
    entity lfsr_bitgen is
        generic (
            RST_VAL          : std_logic := '1';
            PRIM_POL_INT_VAL : positive := 19;
            SYMBOL_WIDTH     : positive := 4;
            GF_SEED          : positive := 1
        );
        port (
            CLK      : in  std_logic;
            RST      : in  std_logic;
            RAND_BIT : out std_logic
        );
    end entity;

    architecture rtl of lfsr_bitgen is
    
        -- Galois field can be created only if its generator polynomial is prime ofer the field GF(2^SYMBOL_WIDTH)
        -- and has a degree of SYMBOL_WIDTH (one more than each symbol SYMBOL_WIDTH)
        constant PRIM_POL_BIT_VAL : std_logic_vector := std_logic_vector(to_unsigned(PRIM_POL_INT_VAL, SYMBOL_WIDTH+1));
    
        -- Signals for the components
        -- Galois counter must start from any nonzero element (= GF_SEED) and thus will never generate zero vector
        signal s_prev_rand_feedback  : std_logic_vector(SYMBOL_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(GF_SEED, SYMBOL_WIDTH));
        signal s_reg_act_rand_number : std_logic_vector(SYMBOL_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(GF_SEED, SYMBOL_WIDTH));
    
        signal s_cnt_wait_symbol : integer range 0 to SYMBOL_WIDTH-1 := 0;

        signal s_shift_symbol : std_logic_vector(SYMBOL_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(GF_SEED, SYMBOL_WIDTH));
        signal sample_symbol_flag : std_logic := '0';

        signal sample_symbol_flag_p1 : std_logic := '0';

    begin

        -- Galois Field LSFR generates a n-bit random number after SYMBOL_WIDTH-1 clock cycles
        proc_gf_counter : process (CLK)
        begin
            if rising_edge(CLK) then
                -- Default value
                sample_symbol_flag <= '0';

                -- For rising_edge detection
                sample_symbol_flag_p1 <= '0';

                -- Generate new pseudorandom number in the middle of the counting to minimise metastability
                if s_cnt_wait_symbol = SYMBOL_WIDTH/2 then
                    -- Galois Counter
                    if s_prev_rand_feedback(SYMBOL_WIDTH-1) = '1' then
                        s_reg_act_rand_number(SYMBOL_WIDTH-1 downto 0) <= s_prev_rand_feedback(SYMBOL_WIDTH-2 downto 0) & '0' xor PRIM_POL_BIT_VAL(SYMBOL_WIDTH-1 downto 0);
                    else
                        s_reg_act_rand_number(SYMBOL_WIDTH-1 downto 0) <= s_prev_rand_feedback(SYMBOL_WIDTH-2 downto 0) & '0';
                    end if;
                end if;

                if s_cnt_wait_symbol = SYMBOL_WIDTH-1 then

                    -- Reset cnt
                    s_cnt_wait_symbol <= 0;

                    -- Refresh new data
                    s_prev_rand_feedback <= s_reg_act_rand_number;

                    -- Command to sample the new symbol
                    sample_symbol_flag <= '1';
                else
                    s_cnt_wait_symbol <= s_cnt_wait_symbol + 1;
                end if;
            end if;
        end process;

        -- Registered output; new output with each rising edge
        shift_only_bits_out : process(CLK)
        begin
            if rising_edge(CLK) then
                if (sample_symbol_flag = '1') and (sample_symbol_flag_p1 = '0') then
                    -- Sample new symbol
                    s_shift_symbol <= s_reg_act_rand_number;
                else
                    -- Fill out the symbol data every cycle
                    s_shift_symbol(s_shift_symbol'high downto 0) <= s_shift_symbol(s_shift_symbol'high-1 downto 0) & '0';
                end if;
            end if;
        end process;

        -- Connect the output pins
        RAND_BIT <= s_shift_symbol(SYMBOL_WIDTH-1);

    end architecture;