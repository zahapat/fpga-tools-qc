# This py sctipt generates .vhd and .csv files for hardware design
# of the CRC component.
# This file has been tested for these parameters (symbol_width, msg_symbols, prim_polynomial(dec), tuple_width):
#     1) 4, 12, 19, 4
#     2) 4, 11, 19, 4


# ----- Libraries -----
import math as lib_math
import random as lib_rand
import csv as lib_csv
import pathlib as lib_path
import FiniteFieldsLib as lib_ff
import CrcGenLib as lib_crc
import CrcGenConstGFMult as lib_gfmult
import CrcTxFilesGenLib as lib_crc_txfiles
import CrcRxFilesGenLib as lib_crc_rxfiles
import sys


# ----- Functions Declaration -----
def get_dir_delimiter():
    _delimiter_windows = "\\"
    _delimiter_linux = "/"
    _delimiter = _delimiter_windows

    # Save Current File Directory
    _dir_current_file = str(lib_path.Path(__file__).parent.resolve())
    print("PY: dir_current_file = ", _dir_current_file)
    
    # Compare occurrences of backslashes and forward slashes
    _occurrences_backslash = _dir_current_file.count(_delimiter_windows)
    _occurrences_slash = _dir_current_file.count(_delimiter_linux)
    
    # If invoked from Makefile or not, use different separators
    if _occurrences_slash > _occurrences_backslash:
        return "/"
    else:
        return "\\"


def CrcGenerator(symbol_width, symbols_count, primitive_polynomial, gf_seed, genpol_symbols_count, tx_submessages_count, rx_submessages_count, sim_transactions_count, gfmult_dir, tx_dir, rx_dir, lib_src, lib_sim):

    # If invoked from Makefile or not, get correct separators
    delimiter = get_dir_delimiter()

    # ----- Create '.csv' Files -----
    # Current File Directory (Globally accessible)
    dir_current_file = lib_path.Path().absolute()

    # Create File '#1' in the Current Directory "dir_current_file" + headers
    file_tx_name = 'tx_crc_generated_parameters.csv'
    # file_tx_fullpath = ('{0}\\{1}'.format(dir_current_file, file_tx_name))
    
    # Export Parameters for TX CRC
    file_tx_fullpath = ('{0}{1}{2}'.format(tx_dir, delimiter, file_tx_name))
    print('new file', file_tx_name,'created: ', file_tx_fullpath)
    file_tx_line = open(file_tx_fullpath, 'w')


    # ---- Main Program ----
    # 1) ----- User-defined parameters : Symbol Width, Message Symbols Count
    print('1. Random Message Generation')
    print('Set how many bits one symbol shall have:')
    # int_sym_width = lib_ff.get_positive_integer()
    int_sym_width = lib_ff.check_positive_integer(symbol_width)
    file_tx_line.write('{}'.format(int_sym_width))
    file_tx_line.write('\n')
    print("Symbol width: ", int_sym_width)
    print('Set how many symbols the input message shall have:')
    # int_msg_symwidth = lib_ff.get_positive_integer()
    int_msg_symwidth = lib_ff.check_positive_integer(symbols_count)
    file_tx_line.write('{}'.format(int_msg_symwidth))
    file_tx_line.write('\n')
    print('Symbols in a message in total:', int_msg_symwidth)
    int_msg_bitwidth = int_msg_symwidth * int_sym_width

    # Prepare the bit vectors as lists (of integers)
    # list_message = [0]*(int_msg_symwidth * int_sym_width)
    # Generate a random string (Constant) with given number of bits to generate the Secret Key shared with A1 and A2
    # for i in range(0, int_msg_bitwidth):
    #     list_message[i] = lib_rand.randint(0, 1)
    # print('"list_message": ', list_message)
    # TO DO:
    # Write to .csv file
    # for j in range(0, int_msg_bitwidth):
    #     file_tx_line.write('{}'.format(list_message[j]))
    # file_tx_line.write('\n')


    # 2) ----- Set the user-defined FF Primitive Polynomial (Tuple Width) -----
    # e.g: orders:      4  3  2  1  0
    #   list_primpol = [1, 0, 0, 1, 1]
    print('2. Primitive Polynomial')
    print('Enter decimal value of the Primitive Polynomial:')
    # int_primpol = lib_ff.get_positive_integer()
    int_primpol = lib_ff.check_positive_integer(primitive_polynomial)
    list_primpol = []
    list_primpol = lib_ff.decimal_to_binlist(int_primpol)
    print('Binary "list_primpol": ', list_primpol)
    for j in range(len(list_primpol)):
        file_tx_line.write('{}'.format(list_primpol[j]))
    file_tx_line.write('\n')


    # 3) ----- Set the default Seed for the Galois Field -----
    print('3. Seed for the Galois Field')
    # # e.g: orders: 4  3  2  1  0
    # Change it here for different seed for GF creation
    list_gfseed = [0 for i in range(int_sym_width)]
    list_gfseed_input = lib_ff.decimal_to_binlist(lib_ff.check_positive_integer(gf_seed))
    for i in range(len(list_gfseed_input)):
        list_gfseed[int_sym_width-1-i] = list_gfseed_input[i]
    
    # list_gfseed = [0 for i in range(int_sym_width)]
    # list_gfseed[int_sym_width - 1] = 1
    for j in range(len(list_gfseed)):
        file_tx_line.write('{}'.format(list_gfseed[j]))
    file_tx_line.write('\n')
    print('Default "list_symbolseed": ', list_gfseed)


    # 4) ----- Calculate Generator Polynomial
    print('4. Generator Polynomial')
    print('Enter the number of parity symbols (= number of symbols in one tuple to be processed in parallel):')
    # int_paritysymbs_cnt = lib_ff.get_positive_integer()
    int_paritysymbs_cnt = lib_ff.check_positive_integer(genpol_symbols_count)
    file_tx_line.write('{}'.format(int_paritysymbs_cnt))
    file_tx_line.write('\n')
    print('"int_paritysymbs_cnt": ', int_paritysymbs_cnt)
    list_genpol_generated = lib_ff.calculate_gen_pol(int_sym_width, list_gfseed, list_primpol, int_paritysymbs_cnt)
    for j in range(len(list_genpol_generated)):
        file_tx_line.write('{}'.format(lib_ff.merge_intlist_to_string(list_genpol_generated[j])))
    file_tx_line.write('\n')
    print('"list_genpol_generated": ', list_genpol_generated)
    file_tx_line.close()


    # 5) ----- Test symbolic-parallel CRC -----
    print('5. Calculate CRC Checksum (Symbolic-parallel)')
    example_inp_tx = [0,0,0,1, 0,0,1,0, 0,0,1,1, 0,1,0,0, 0,1,0,1, 0,1,1,0, 0,1,1,1, 1,0,0,0, 1,0,0,1, 1,0,1,0, 1,0,1,1]
    print('"example_inp_tx": ', example_inp_tx)
    list_crc = lib_crc.crc_symbolic_parallel_gf2m_lfsm1(    int_sym_width,    list_primpol,    int_msg_symwidth,    int_paritysymbs_cnt,    list_gfseed,    list_genpol_generated, example_inp_tx)

    # 6)  ----- Calculate CRC Syndromes with or without error pattern -----
    print('6. Calculate CRC Syndromes (Symbolic-parallel) + Verify that syndromes are zero')
    # 6.1) without an error pattern
    list_syn = lib_crc.syn_symbolic_parallel_gf2m_lfsm1(    int_sym_width,    list_primpol,    int_msg_symwidth,    int_paritysymbs_cnt,    list_gfseed,    list_genpol_generated, example_inp_tx, list_crc)
    for i in range(len(list_syn)):
        for j in range(len(list_syn[i])):
            if list_syn[i][j] != 0:
                print('PY: ERROR: Syndrome is not zero. Unable to generate HW files.')
                print('PY: ERROR: list_syn[',i,'][',j,'] = ',list_syn[i][j],' is not 0.')
                sys.exit(2)
    print('PY: Symbolic-parallel Syndromes Check OK.')


    # 6.2) with an error pattern
    # example_inp_error = [0,0,0,1, 0,0,1,0, 0,0,1,1, 0,1,0,0, 0,1,0,1, 1,0,1,1, 0,1,1,1, 1,0,0,0, 1,0,0,1, 1,0,1,0, 1,0,1,1]
    # list_crc_error = [[0,0,1,1], [0,0,0,1], [1,1,0,0], [1,1,0,0]]
    # lib_crc.syn_symbolic_parallel_gf2m_lfsm1(    int_sym_width,     list_primpol,     int_msg_symwidth,     int_paritysymbs_cnt, list_gfseed,       list_genpol_generated, example_inp_error, list_crc_error)


    # 7) ----- Create VHDL Files for CRC TX and RX: Design, Wrapper, Testbench -----
    print('7. Generate CSV and VHDL files')
    # TX
    print('Enter the number of sub-messages:')
    # submessages_cnt_tx = lib_ff.get_positive_integer()
    submessages_cnt_tx = lib_ff.check_positive_integer(tx_submessages_count)

    print('Enter the number of transactions for simulations:')
    sim_transactions_count = lib_ff.check_positive_integer(sim_transactions_count)

    print('PY: Generating constant Galois Field Multiplier')
    lib_gfmult.create_gfmult_constb_vhdl(gfmult_dir, delimiter)

    if tx_dir == None:
        print('PY: INFO: Output path for CRC TX output files has not been specified using the \'--tx_dir=\' command-line argument.')
        print('PY: INFO: No CRC TX output files generated.')
    else:
        print('PY: Generating CRC TX output files.')
        lib_crc_txfiles.create_files_crc_tx_vhdl(tx_dir,    delimiter,    int_sym_width,    list_primpol,    int_msg_symwidth,    int_paritysymbs_cnt,    list_gfseed,    list_genpol_generated,    example_inp_tx,    submessages_cnt_tx, sim_transactions_count, lib_src, lib_sim)

    # RX
    # example_inp_rx = [0,0,0,1, 0,0,1,0, 0,0,1,1, 0,1,0,0, 0,1,0,1, 0,1,1,0, 0,1,1,1, 1,0,0,0, 1,0,0,1, 1,0,1,0, 1,0,1,1,    1,1,1,1, 1,0,1,1, 1,0,1,1, 0,0,0,0, 1,1,1,1]
    example_inp_rx = [0,0,0,1, 0,0,1,0, 0,0,1,1, 0,1,0,0, 0,1,0,1, 0,1,1,0, 0,1,1,1, 1,0,0,0, 1,0,0,1, 1,0,1,0, 1,0,1,1,    0,0,1,1, 0,0,1,1, 1,1,0,0, 1,1,0,0]
    print('Enter the number of sub-messages:')
    # submessages_cnt_rx = lib_ff.get_positive_integer()
    submessages_cnt_rx = lib_ff.check_positive_integer(rx_submessages_count)
    if rx_dir == None:
        print('PY: INFO: Output path for CRC RX output files has not been specified using the \'--rx_dir=\' command-line argument.')
        print('PY: INFO: No CRC RX output files generated.')
    else:
        print('PY: Generating CRC RX output files.')
        lib_crc_rxfiles.create_files_crc_rx_vhdl(rx_dir,    delimiter,    int_sym_width,    list_primpol,    int(int_msg_symwidth+int_paritysymbs_cnt),    int_paritysymbs_cnt,    list_gfseed,    list_genpol_generated,    example_inp_rx,    submessages_cnt_rx, sim_transactions_count, lib_src, lib_sim)






    # 8) ----- Parallel form of the Symbol-Tuple-Parallel CRC -----
    # Task: We have 11 symbols and we want to calculate them in parallel using the Symbol-Tuple-Parallel CRC Encoder
    print('8. Parallel form of the Symbol-Tuple-Parallel CRC')
    # print('Enter the number of sub-messages:')
    # submessages_cnt_tx = lib_ff.get_positive_integer()
    # submessages_crc_tx = slice_into_submessages(    int_sym_width,     int_msg_symwidth,     int_paritysymbs_cnt, submessages_cnt_tx, example_inp_tx)
    submessages_crc_tx = lib_crc.slice_into_submessages_origmsg(    int_sym_width,     int_msg_symwidth,     int_paritysymbs_cnt, submessages_cnt_tx, example_inp_tx)
    print('submessages_crc_tx: ')
    lib_ff.print_list_rows(submessages_crc_tx)



    # ORIGINAL INPUT: example_inp_tx = [0,0,0,1, 0,0,1,0, 0,0,1,1, 0,1,0,0, 0,1,0,1, 0,1,1,0, 0,1,1,1, 1,0,0,0, 1,0,0,1, 1,0,1,0, 1,0,1,1]
    #                           SUBMESSAGE 1                                                                                                                 SUBMESSAGE 2
    example_inp_parts = [[0,0,0,1, 0,0,1,0, 0,0,1,1, 0,1,0,0, 0,1,0,1, 0,1,1,0,    0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0], [0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,    0,1,1,1, 1,0,0,0, 1,0,0,1, 1,0,1,0, 1,0,1,1]]
    list_merged_parallel_crcs = []
    print('"example_inp_parts": ', example_inp_parts)
    for i in range(len(submessages_crc_tx)):
        list_merged_parallel_crcs.append(lib_crc.crc_symbolic_parallel_gf2m_lfsm1(    int_sym_width,     list_primpol,     int_msg_symwidth,     int_paritysymbs_cnt, list_gfseed,       list_genpol_generated, submessages_crc_tx[i]))
    print('list_merged_parallel_crcs: ', list_merged_parallel_crcs)


    # IF PARALLEL REALIZATION
    if submessages_cnt_tx > 1:
        xored_parities_crc = [[] for i in range(submessages_cnt_tx-1)]

        for u in range(int_paritysymbs_cnt):
            xored_parities_crc[0].append(lib_ff.function_list_xor(list_merged_parallel_crcs[0][u], list_merged_parallel_crcs[1][u]))

    if submessages_cnt_tx > 2:
        for i in range(2, submessages_cnt_tx):
            for u in range(int_paritysymbs_cnt):
                xored_parities_crc[i-1].append(lib_ff.function_list_xor(xored_parities_crc[i-2][u], list_merged_parallel_crcs[i][u]))

    print('CRC xored_parities_crc: ', xored_parities_crc[submessages_cnt_tx-2])



    # insert_registers_tuples(int_sym_width, int_msg_symwidth, int_paritysymbs_cnt, submessages_cnt_tx, example_inp_tx)
    # synchronize_delayed_input(int_sym_width, int_msg_symwidth, int_paritysymbs_cnt, submessages_cnt_tx, example_inp_tx)


        
        