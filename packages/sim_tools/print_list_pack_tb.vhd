------------------------------------------------------------
    -- PACKAGE FOR THE USE OF THE PROTECTED TYPE GENERIC_LIST --
    ------------------------------------------------------------
    -- Prototypes of the subprograms
    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use std.textio.all;
    use ieee.std_logic_textio.all;

    library lib_sim;
    use lib_sim.list_string_pack_tb.all;

    package print_list_pack_tb is

        -- Print the content of the list as string
        procedure print_line_string (string_msg : string);
        procedure print_list_of_strings (list_of_strings : inout list);

        -- Buffer data from INfile
        -- file text_type_variable : text;
        procedure import_file_as_list_of_strings (
            constant INT_STRING_MAXLENGTH : integer;
            constant STRING_INFILE_PATH : string;
            file text_type_variable : text;
            list_of_strings : inout list
        );


        -- For writing a line to a file
        procedure write_list_file_line (
            string_delimiter : string;
            int_elements_cnt : positive;
            file text_type_variable : text;
            s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10 : string;
            s11, s12, s13, s14, s15, s16, s17, s18, s19, s20 : string;
            s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, s31 : string
        );


        -- Export all the list data buffer to output file
        procedure export_list_of_strings (
            file text_type_variable : text;
            STRING_OUTFILE_PATH : string;
            list_of_strings : inout list
            -- int_string_length : integer
        );


        -- Convert a string to standard_logic_vector type
        impure function string_bits_to_slv(some_string : string) return std_logic_vector;


        -- Import data from a file (REDUNDANT)
        -- file text_type_variable : text;
        -- impure function get_infile_line_string (
        --     text_type_variable : text;
        --     string_infile_path : string;
        --     int_index : integer;
        --     list_of_strings : list_pack_tb
        -- );

    end package;


    -- Bodies of all the prototypes
    package body print_list_pack_tb is

        -- Print the content of the list as string
        procedure print_line_string (string_msg : string) is
            variable new_line : line;
        begin
            write(new_line, string_msg);
            writeline(output, new_line);
        end procedure;

        -- Print a message to the simulator console
        procedure print_list_of_strings (list_of_strings : inout list) is
        begin
            print_line_string("List list_of_strings:");
            print_line_string("    list_of_strings.length: " & to_string(list_of_strings.length));
            for i in 0 to list_of_strings.length-1 loop
                print_line_string("    list_of_strings.get(" & to_string(i) & "): " & list_of_strings.get(i));
                -- print_line_string("    my_list.get(" & to_string(i) & "): " );
            end loop;
        end procedure;


        -- Buffer data from INfile
        -- file text_type_variable : text;
        procedure import_file_as_list_of_strings (
            constant INT_STRING_MAXLENGTH : integer;
            constant STRING_INFILE_PATH : string;
            file text_type_variable : text;
            list_of_strings : inout list
        ) is
            variable line_text_type_variable : line;
            variable var_actual_line_string : string(INT_STRING_MAXLENGTH downto 1);
            variable act_line : natural := 0;
        begin

            if list_of_strings.length = 0 then

                print_line_string("* Importing data from infile: " & STRING_INFILE_PATH);
                print_line_string("    list_of_strings.length: " & to_string(list_of_strings.length));

                -- Open IO files: read mode
                file_open(text_type_variable, STRING_INFILE_PATH, read_mode);

                -- Loop until the last row of the file 
                over_all_lines_infile: while not endfile(text_type_variable) loop
                    -- Read content of the current line
                    print_line_string("    Reading line: " & integer'image(act_line) );
                    readline(text_type_variable, line_text_type_variable);

                    -- Load the content of the current line to respective variables
                    read(line_text_type_variable, var_actual_line_string);

                    -- Append the line to generic list buffer
                    list_of_strings.append(var_actual_line_string);
                    act_line := act_line + 1;
                end loop;

                -- Close IO files: read mode
                file_close(text_type_variable);
                print_line_string("* Import from infile ended. ");
                print_line_string("    lines imported: " & to_string(list_of_strings.length));

            end if;
        end procedure;


        -- Import data from a file (REDUNDANT)
        -- file text_type_variable : text;
        -- impure function get_infile_line_string (
        --     text_type_variable : text;
        --     string_infile_path : string;
        --     int_index : integer;
        --     list_of_strings : list_pack_tb
        -- ) return string is
        --     variable line_text_type_variable : line;
        --     variable var_actual_line_string : string;
        -- begin

        --     if list_of_strings.length = 0 then
        --         print_line_string("list_of_strings.length: " & to_string(list_of_strings.length));

        --         -- Open IO files: read mode
        --         print_line_string("Loading data infrom file: " & string_infile_path);
        --         file_open(text_type_variable, string_infile_path, read_mode);

        --         -- Loop until the last row of the file 
        --         over_all_lines_infile: while not endfile(text_type_variable) loop
        --             -- Read content of the current line
        --             readline(text_type_variable, line_text_type_variable);

        --             -- Load the content of the current line to respective variables
        --             read(line_text_type_variable, var_actual_line_string);

        --             -- Append the line to generic list buffer
        --             list_of_strings.append(var_actual_line_string);
        --         end loop;

        --         -- Close IO files: read mode
        --         file_close(text_type_variable);
        --         print_line_string("Loading from infile ended.");

        --     end if;

        --     return list_of_strings.get(int_index);

        -- end function;


        -- Create a single line for output csv file (string_delimiter = ',') (max elements/strings per line = 32)
        procedure write_list_file_line (
            string_delimiter : string;
            int_elements_cnt : positive;
            file text_type_variable : text;
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

        
        -- Export all the list data buffer to output file
        procedure export_list_of_strings (
            file text_type_variable : text;
            STRING_OUTFILE_PATH : string;
            list_of_strings : inout list
        ) is 
            variable line_out : line;
        begin

            print_line_string("* Exporting data to outfile: " & STRING_OUTFILE_PATH);
            print_line_string("    list_of_strings.length: " & to_string(list_of_strings.length));

            file_open(text_type_variable, STRING_OUTFILE_PATH, write_mode);

            for i in 0 to list_of_strings.length-1 loop
                write(line_out, string'(list_of_strings.get(i) ));
                writeline(text_type_variable, line_out);
            end loop;

            file_close(text_type_variable);

            print_line_string("* Export to outfile ended.");
            print_line_string("    lines exported: " & to_string(list_of_strings.length));

        end procedure;


        -- Convert a string to standard_logic_vector type
        impure function string_bits_to_slv(some_string : string) return std_logic_vector is
            variable slv_output : std_logic_vector(some_string'length-1 downto 0);
            variable act_character : natural;
            variable v_slv_char : std_logic_vector(8-1 downto 0);
        begin
            -- for i in 1 to slv_output'length-1 loop
            for i in some_string'range loop

                -- For debugging
                -- print_line_string("slv_output'length = " & integer'image(slv_output'length));
                -- print_line_string("i = " & integer'image(i));
                -- print_line_string("some_string(i) = " & some_string(i));

                v_slv_char := std_logic_vector(to_unsigned(character'pos(some_string(i)), 8));

                if v_slv_char(0) = '0' then
                    slv_output(slv_output'left-i+1) := '0';
                elsif v_slv_char(0) = '1' then
                    slv_output(slv_output'left-i+1) := '1';
                else 
                    slv_output(slv_output'left-i+1) := 'X';
                    print_line_string("ERROR: The following character was not recognised as a bit: " & character'image(some_string(i)));
                end if;

            end loop;

            -- For debugging
            -- print_line_string("slv_output = " & integer'image(to_integer(unsigned(slv_output))) );

            return slv_output;
        end function;


    end package body;