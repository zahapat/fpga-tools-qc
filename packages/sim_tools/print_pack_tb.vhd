-- FOR COMPILING USE VHDL 2008
--      -> compile before testbenches

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

-- Prototypes of the subprograms
package print_pack_tb is

    -- Print String to the console
    procedure print_string(constant str : string);

    -- Print success to console
    procedure print_success;

    -- Print test start, set trigger to true
    procedure start_test(
        signal test_trigger : inout boolean;
        constant str : string  := ""
    );

    -- Print test done, set trigger to false
    procedure end_test(
        signal test_trigger : inout boolean;
        constant str : string  := ""
    );

    -- Print to console "TEST NOT OK."
    procedure print_fail;

    -- Print Integer as an ASCII Char to the console
    procedure print_int_char(constant int_char : integer);

    -- Print Integer to the console
    procedure print_int(constant int : integer);

    -- Print Real to the console
    procedure print_real(constant r : real);

    -- Print Unsigned representation of SLV to the console
    procedure print_slv_unsigned(constant slv : std_logic_vector);

    -- Print Signed representation of SLV to the console
    procedure print_slv_signed(constant slv : std_logic_vector);

    -- Print results of a test
    procedure print_result(
        tb_name : string;
        constant int_errors_cnt, int_tests_cnt : integer
    );


end package;


-- Bodies of all the prototypes
package body print_pack_tb is


    -- Print String to the console
    procedure print_string(constant str : string) is
        variable str_print : line;
    begin
        write(str_print, string'(str));
        writeline(output, str_print);
    end procedure;


    -- Print to console "TEST OK."
    procedure print_success is
        variable str : line;
    begin
        write(str, string'("*********************************"));
        writeline(output, str);
        write(str, string'("SIMULATION COMPLETED SUCCESSFULLY"));
        writeline(output, str);
        write(str, string'("*********************************"));
        writeline(output, str);
    end procedure;


    -- Print test start, set trigger to true
    procedure start_test(
        signal test_trigger : inout boolean;
        constant str : string := ""
    ) is begin
        print_string("*********************************");
        print_string(" Test: '" & str & "' started.");
        test_trigger <= true;
        wait for 0 ns;
    end procedure;


    -- Print test done, set trigger to false
    procedure end_test(
        signal test_trigger : inout boolean;
        constant str : string  := ""
    ) is begin
        test_trigger <= false;
        wait for 0 ns;
        print_string(" Test: '" & str & "' finished.");
        print_string("*********************************");
    end procedure;


    -- Print to console "TEST NOT OK."
    procedure print_fail is
        variable str : line;
    begin
        write(str, string'("*********************************"));
        writeline(output, str);
        write(str, string'(" SIMULATION FINISHED WITH ERRORS "));
        writeline(output, str);
        write(str, string'("*********************************"));
        writeline(output, str);
    end procedure;


    -- Print Integer as an ASCII Char to the console
    procedure print_int_char(constant int_char : integer) is
        variable str_print : line;
    begin
        -- int -> ASCII char
        write(str_print, character'image(character'val(int_char)) );
        writeline(output, str_print);
    end procedure;
    

    -- Print Integer to the console
    procedure print_int(constant int : integer) is
        variable str_print : line;
    begin
        -- int -> string
        write(str_print, integer'image(int));
        writeline(output, str_print);
    end procedure;


    -- Print Real to the console
    procedure print_real(constant r : real) is
    begin
        -- int -> string
        -- str_print := to_string(r);
        print_string(to_string(r));
    end procedure;


    -- Print Unsigned representation of SLV to the console
    procedure print_slv_unsigned(constant slv : std_logic_vector) is
        variable str_print : line;
    begin
        -- SLV -> unsigned -> int -> string
        write(str_print, integer'image(to_integer(unsigned(slv))));
        writeline(output, str_print);
    end procedure;


    -- Print Signed representation of SLV to the console
    procedure print_slv_signed(constant slv : std_logic_vector) is
        variable str_print : line;
    begin
        -- SLV -> signed -> int -> string
        write(str_print, integer'image(to_integer(signed(slv))));
        writeline(output, str_print);
    end procedure;


    -- Print results of a test
    procedure print_result(
        tb_name : string;
        constant int_errors_cnt, int_tests_cnt : integer
    ) is begin
        if int_errors_cnt = 0 then
            
            print_success;

            print_string("Stats:");
            print_string("    Module: " & tb_name);
            print_string("     Tests: " & integer'image(int_tests_cnt));
            print_string("    Errors: " & integer'image(int_errors_cnt));
        else

            print_fail;

            print_string("Stats:");
            print_string("    Module: " & tb_name);
            print_string("     Tests: " & integer'image(int_tests_cnt));
            print_string("    Errors: " & integer'image(int_errors_cnt));
        end if;
    end procedure;


end package body;