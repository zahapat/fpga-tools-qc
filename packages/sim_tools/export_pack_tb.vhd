    -- FOR COMPILING USE VHDL 2008
    --      -> compile before testbenches

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use std.textio.all;
    use ieee.std_logic_textio.all;

    -- Prototypes of subprograms
    package export_pack_tb is

        procedure write_file_line (
            string_delimiter : string;
            int_elements_cnt : positive;
            file text_type_variable : text;
            string_outfile_path : string;
            s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10 : string;
            s11, s12, s13, s14, s15, s16, s17, s18, s19, s20 : string;
            s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, s31 : string
        );

    end package;


    -- Bodies of all prototypes
    package body export_pack_tb is

        -- Create a single line for the output csv file (string_delimiter = ',') (max elements/strings per line = 32)
        procedure write_file_line (
            string_delimiter : string;
            int_elements_cnt : positive;
            file text_type_variable : text;
            string_outfile_path : string;
            s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10 : string;
            s11, s12, s13, s14, s15, s16, s17, s18, s19, s20 : string;
            s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, s31 : string
        ) is
            variable line_out : line;
        begin

            if int_elements_cnt >= 1 then write(line_out, string'(s0)); end if;
            if int_elements_cnt >= 1 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 2 then write(line_out, string'(s1)); end if;
            if int_elements_cnt >= 2 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 3 then write(line_out, string'(s2)); end if;
            if int_elements_cnt >= 3 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 4 then write(line_out, string'(s3)); end if;
            if int_elements_cnt >= 4 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 5 then write(line_out, string'(s4)); end if;
            if int_elements_cnt >= 5 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 6 then write(line_out, string'(s5)); end if;
            if int_elements_cnt >= 6 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 7 then write(line_out, string'(s6)); end if;
            if int_elements_cnt >= 7 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 8 then write(line_out, string'(s7)); end if;
            if int_elements_cnt >= 8 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 9 then write(line_out, string'(s8)); end if;
            if int_elements_cnt >= 9 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 10 then write(line_out, string'(s9)); end if;
            if int_elements_cnt >= 10 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 11 then write(line_out, string'(s10)); end if;
            if int_elements_cnt >= 11 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 12 then write(line_out, string'(s11)); end if;
            if int_elements_cnt >= 12 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 13 then write(line_out, string'(s12)); end if;
            if int_elements_cnt >= 13 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 14 then write(line_out, string'(s13)); end if;
            if int_elements_cnt >= 14 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 15 then write(line_out, string'(s14)); end if;
            if int_elements_cnt >= 15 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 16 then write(line_out, string'(s15)); end if;
            if int_elements_cnt >= 16 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 17 then write(line_out, string'(s16)); end if;
            if int_elements_cnt >= 17 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 18 then write(line_out, string'(s17)); end if;
            if int_elements_cnt >= 18 then write(line_out, string'(string_delimiter)); end if;
            
            if int_elements_cnt >= 19 then write(line_out, string'(s18)); end if;
            if int_elements_cnt >= 19 then write(line_out, string'(string_delimiter)); end if;
            
            if int_elements_cnt >= 20 then write(line_out, string'(s19)); end if;
            if int_elements_cnt >= 20 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 21 then write(line_out, string'(s20)); end if;
            if int_elements_cnt >= 21 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 22 then write(line_out, string'(s21)); end if;
            if int_elements_cnt >= 22 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 23 then write(line_out, string'(s22)); end if;
            if int_elements_cnt >= 23 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 24 then write(line_out, string'(s23)); end if;
            if int_elements_cnt >= 24 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 25 then write(line_out, string'(s24)); end if;
            if int_elements_cnt >= 25 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 26 then write(line_out, string'(s25)); end if;
            if int_elements_cnt >= 26 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 27 then write(line_out, string'(s26)); end if;
            if int_elements_cnt >= 27 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 28 then write(line_out, string'(s27)); end if;
            if int_elements_cnt >= 28 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 29 then write(line_out, string'(s28)); end if;
            if int_elements_cnt >= 29 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 30 then write(line_out, string'(s29)); end if;
            if int_elements_cnt >= 30 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 31 then write(line_out, string'(s30)); end if;
            if int_elements_cnt >= 31 then write(line_out, string'(string_delimiter)); end if;

            if int_elements_cnt >= 32 then write(line_out, string'(s31)); end if;
            if int_elements_cnt >= 32 then write(line_out, string'(string_delimiter)); end if;

            writeline(text_type_variable, line_out);

        end procedure;


    end package body;