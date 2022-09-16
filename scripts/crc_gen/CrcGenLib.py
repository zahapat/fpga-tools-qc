# ----- Libraries -----
import math as lib_math
import random as lib_rand
import csv as lib_csv
import pathlib as lib_path
import FiniteFieldsLib as lib_ff


# ---------- Tuple-parallel CRC over GF(2) (type 1) ----------
def crc_tuple_parallel_gf2_lfsm1(_symbol_width, _prim_poly, _msg_symbolwidth, _in_msg):

    # Add new constant zero bits if the number of input bits message is not divisible by the symbol width without remainder
    _list_new_in_msg = _in_msg
    _cnt_new_bits_added = 0
    # if (_msg_symbolwidth > len(_list_new_in_msg)/_symbol_width):
    if (_msg_symbolwidth > len(_list_new_in_msg)/_symbol_width):
        while ((_msg_symbolwidth != len(_list_new_in_msg)/_symbol_width) | (len(_list_new_in_msg) % _symbol_width != 0)):
            _cnt_new_bits_added += 1
            _list_new_in_msg.insert(0, 0)
    
    print('Added ', _cnt_new_bits_added, ' bits to the message.')
    print('_list_new_in_msg: ', _list_new_in_msg)
    print('The message now consists of ', int(len(_list_new_in_msg)/_symbol_width), ' symbols.')


    # Slice input into separate symbols
    # TO DO: Add zeros where necessary
    _msg_bucketlist = lib_ff.msg_slice_in_symbols(_symbol_width, _msg_symbolwidth, _list_new_in_msg)
    print('_msg_bucketlist =', _msg_bucketlist)

    # Characteristic Matrix A
    _charact_mat_a = lib_ff.char_matrix_a_lfsm1(_symbol_width, lib_ff.mirror_list(_prim_poly))
    print('_charact_mat_a =', _charact_mat_a)

    # Bitwise multiplication of two matrices
    _charact_mat_a_pow = lib_ff.matrix_power(_symbol_width, _charact_mat_a)
    print('_charact_mat_a_pow =', _charact_mat_a_pow)

    # Initial Bitwise multiplication of a matrix and a vector
    _s = [[0] * _symbol_width for _u in range(_msg_symbolwidth+1)]

    # Forming intermediate states
    for _i in range(0, _msg_symbolwidth):
        _s[_i+1] = lib_ff.function_list_xor(lib_ff.matrix_multiply_array(_charact_mat_a_pow, _s[_i]), _msg_bucketlist[_i])
    print('_s =', _s)

    # CRC calculation
    _crc_result = lib_ff.matrix_multiply_array(_charact_mat_a_pow, _s[_msg_symbolwidth])
    print('CRC =', _crc_result)

    return _crc_result


# LFSM type 1: Characteristic matrix A (Symbol-based)
def char_matrix_a_lfsm1_symbols(symbol_width, _list_symbol_seed, _list_prim_poly, _list_gen_pol):

    _list_gen_pol_mirrored = lib_ff.mirror_list(_list_gen_pol)
    _list_prim_poly_mirrored = lib_ff.mirror_list(_list_prim_poly)
    _list_gf = lib_ff.function_gf_generator(symbol_width, _list_prim_poly, _list_symbol_seed)


    _matrix_a = [[0] * (len(_list_gen_pol_mirrored)-1) for i in range(len(_list_gen_pol_mirrored)-1)]
    _matrix_a_mirrored = [[0] * (len(_list_gen_pol_mirrored)-1) for i in range(len(_list_gen_pol_mirrored)-1)]

    # non-mirrored matrix
    # fixed?? POSSIBLE MISTAKE/ERROR
    for _i in range(0, len(_list_gen_pol_mirrored)-1):
        for _j in range(0, len(_list_gen_pol_mirrored)-1):
            if (_j == len(_list_gen_pol_mirrored)-2):
                _matrix_a[_i][_j] = lib_ff.flatten_list(_list_gen_pol_mirrored[_i])
            else:
                _matrix_a[_i][_j] = ([0] * (len(_list_gen_pol_mirrored)-1))

    # for _i in range(0, len(_list_gen_pol_mirrored)-1):
    #     for _j in range(0, len(_list_gen_pol_mirrored)-1):
    #         if (_j == len(_list_gen_pol_mirrored)-2):
    #             _matrix_a[_i][_j] = lib_ff.flatten_list(_list_gen_pol_mirrored[_i])
    #         else:
    #             _matrix_a[_i][_j] = ([0] * (len(_list_gen_pol_mirrored)-2))

    # add alpha_0 under the diagonal
    for _i in range(1, len(_list_gen_pol_mirrored)-1):
        _matrix_a[_i][_i-1] = _list_gf[1]

    # mirrored matrix_a
    for _i in range(0, len(_list_gen_pol_mirrored)-1):
        for _j in range(0, len(_list_gen_pol_mirrored)-1):
            _matrix_a_mirrored[(len(_list_gen_pol_mirrored)-2)-_i][(len(_list_gen_pol_mirrored)-2)-_j] = _matrix_a[_i][_j]


    return _matrix_a_mirrored


# ---------- Symbolic-tuple-parallel CRC over GF(2^m) ----------
# _msg_symbolwidth symbols in parallel (have a look at the power of '_charact_mat_a')
# def crc_symbolic_parallel_gf2m_lfsm1(_symbol_width, _prim_poly, _msg_symbolwidth, _tuple_width, _list_symbol_seed, _list_gen_pol, _list_in_msg):
def crc_symbolic_parallel_gf2m_lfsm1(_int_symbol_width, _list_prim_poly, _int_msg_symbols_cnt, _int_msg_tuplewidth, _list_symbol_seed, _list_gen_pol, _list_in_msg):

    # Add new constant zero bits if the number of input bits message is not divisible by the symbol width and tuple width without remainder
    _list_new_in_msg_not_flattnd = []
    _list_new_in_msg_not_flattnd.append(_list_in_msg)
    _list_new_in_msg = lib_ff.flatten_list(_list_new_in_msg_not_flattnd)
    _cnt_new_bits_added = 0
    # if (_msg_symbolwidth > len(_list_new_in_msg)/_symbol_width):
    if ((_int_msg_symbols_cnt > len(_list_new_in_msg)/_int_symbol_width) | ((len(_list_new_in_msg)/_int_symbol_width) % _int_msg_tuplewidth != 0)):
        # while ((_int_msg_symbols_cnt != len(_list_new_in_msg)/_int_symbol_width) | (len(_list_new_in_msg) % _int_symbol_width != 0)):
        while ((len(_list_new_in_msg) % _int_symbol_width != 0) | ((len(_list_new_in_msg)/_int_symbol_width) % _int_msg_tuplewidth != 0)):
            _cnt_new_bits_added += 1
            _list_new_in_msg.insert(0, 0)
    
    print('Added ', _cnt_new_bits_added, ' bits to the message.')
    print('_list_new_in_msg: ', _list_new_in_msg)
    print('The message now consists of ', int(len(_list_new_in_msg)/_int_symbol_width), ' symbols.')



    # Slice input into separate symbols and eventually add some bits to make the _list_in_msg be divisible by _int_symbol_width without remainder
    # TO DO: Add zeros where necessary
    # _msg_bucketlist = lib_ff.msg_slice_in_symbols(_int_symbol_width, _int_msg_symbols_cnt, _list_new_in_msg)
    _msg_bucketlist = lib_ff.msg_slice_in_symbols(_int_symbol_width, int(len(_list_new_in_msg)/_int_symbol_width), _list_new_in_msg)
    print('_msg_bucketlist =', _msg_bucketlist)

    # Check if the actual _msg_bucketlist can be divided into tuples of symbols without remainder
    if ((len(_msg_bucketlist) % _int_msg_tuplewidth) == 0):
        # _int_msg_parts = _int_msg_symbols_cnt / _int_msg_tuplewidth
        _int_msg_parts = len(_msg_bucketlist) / _int_msg_tuplewidth
        print('Divisibility check OK. "_int_msg_parts: "', _int_msg_parts)
    # else:

        # Add new symbols if the _msg_bucketlist is not divisible without remainder
        # _act_length_msg = len(_msg_bucketlist)
        # _list_new_in_msg_bucketlist = _msg_bucketlist
        # _cnt_new_symbols_added = 0
        # if (_int_msg_tuplewidth > len(_msg_bucketlist)/_int_msg_tuplewidth):
        #     # Add zero symbols to the nearest tuple without remainder
        #     while (len(_list_new_in_msg_bucketlist) % _int_msg_tuplewidth != 0):
        #         _cnt_new_symbols_added += 1
        #         _list_new_in_msg_bucketlist.insert(0, [0 for i in range(_int_symbol_width)])

        # _act_length_msg = len(_msg_bucketlist)
        # # _list_new_in_msg_bucketlist = _msg_bucketlist
        # _cnt_new_symbols_added = 0
        # if (_int_msg_tuplewidth > len(_msg_bucketlist)/_int_msg_tuplewidth):
        #     # Add zero symbols to the nearest tuple without remainder
        #     while (len(_msg_bucketlist) % _int_msg_tuplewidth != 0):
        #         _cnt_new_symbols_added += 1
        #         _msg_bucketlist.insert(0, [0 for i in range(_int_symbol_width)])

        # _int_msg_parts = len(_msg_bucketlist) / _int_msg_tuplewidth
        # print('Divisibility check previously NOK. Actual msg parts: "_int_msg_parts: "', _int_msg_parts)
        # print('Added ', _cnt_new_symbols_added, ' symbols to the message = ', _cnt_new_symbols_added * _int_symbol_width, ' bits.')
        # print('_list_new_in_msg_bucketlist: ', _msg_bucketlist)
        # print('The message now consists of ', int(len(_msg_bucketlist)/_int_msg_tuplewidth), ' tuples of symbols.')


    # print('_int_msg_parts: ', int(_int_msg_parts))
    _msg_bucketlist_tuples = lib_ff.msg_slice_in_tuples(_msg_bucketlist, _int_msg_tuplewidth, int(_int_msg_parts))
    # print('_msg_bucketlist_tuples = ', _msg_bucketlist_tuples)


    # Characteristic Matrix A
    # Dimensions of the Characteristic Matrix A are defined by the length of the Generator Polynomial ('_list_gen_pol')
    _charact_mat_a = char_matrix_a_lfsm1_symbols(_int_symbol_width, _list_symbol_seed, _list_prim_poly, _list_gen_pol)
    # print('_charact_mat_a =', _charact_mat_a)


    # Check if one tuple has the same length as the Generator Polynomial
    if (_int_msg_tuplewidth == len(_charact_mat_a[0])):
        print('Tuple width check OK.')
    else:
        print('ERROR: "_int_msg_tuplewidth" must be equal to one dimension of the Characteristic Matrix A "_charact_mat_a". Return 5.')
        return 5


    # Bitwise multiplication of two matrices
    # WATCH OUT! Now, we are going to scramble '_msg_symbolwidth' symbols and so we need to create this degree of '_charact_mat_a'
    _charact_mat_a_pow = lib_ff.matrix_power_symbols(_int_symbol_width, _int_msg_tuplewidth, _list_prim_poly, _charact_mat_a)
    # print('_charact_mat_a_pow =', _charact_mat_a_pow)

    # Initial Bitwise multiplication of a matrix and a vector
    _s = [[] * _int_symbol_width for _u in range(int(_int_msg_parts)+1)]
    for _u in range(0, int(_int_msg_parts)+1):
        _s[_u] = [[0] * _int_symbol_width for _u in range(int(_int_msg_tuplewidth))]

    # _s_tuples = lib_ff.msg_slice_in_tuples(_s[0], int(_int_msg_tuple_symbols), int(_int_msg_parts))
    # print('initial _s[0]: ', _s)

    # # Forming intermediate states
    # Over all msg parts (= tuples), symbols
    _cnt_act_sym = 0
    _cnt_act_tup = 0
    _cnt_pick_in_symbol = 0
    _multiplied_mat_a_intuple = []
    for _u in range(0, int(_int_msg_parts)):        # OPT.1: Multiply the Characteristic Matrix Awith the initial _s[0] vector        # _multiplied_mat_a_intuple.append(lib_ff.matrix_multiply_array_symbols(_int_symbol_width, _list_prim_poly, _charact_mat_a, _s[_u]))
        # Multiply the Characteristic Matrix A multiplied by itself many times with the initial _s[0] vector
        _multiplied_mat_a_intuple.append(lib_ff.matrix_multiply_array_symbols(_int_symbol_width, _list_prim_poly, _charact_mat_a_pow, _s[_u]))

        # print('_s[_u]: ', _s[_u])
        # print('_multiplied_mat_a_intuple: ', _multiplied_mat_a_intuple)

        # Add the result to the input message symbol and create new _s[_+1] vector
        for _i in range (0, int(_int_msg_tuplewidth)):
            # print('_multiplied_mat_a_intuple[', _i, ']: ', lib_ff.flatten_list(_multiplied_mat_a_intuple[_u][_i]))
            _s[_u+1][_i] = lib_ff.function_list_xor(lib_ff.flatten_list(_multiplied_mat_a_intuple[_u][_i]), _msg_bucketlist[_cnt_pick_in_symbol])
            _cnt_pick_in_symbol += 1

    lib_ff.print_list_rows(_multiplied_mat_a_intuple)

    # Check what "_s" contains
    print('entire _s[] (tuples in rows, init row = "0"): ')
    # print(_s)
    lib_ff.print_list_rows(_s)

    # # CRC calculation
    # print('_s[_int_msg_parts]: ', _s[int(_int_msg_parts)])
    _final_multiply = _s[int(_int_msg_parts)]
    # print('_final_multiply: ', _final_multiply)

    # print(lib_ff.matrix_multiply_array_symbols(_int_symbol_width, _list_prim_poly, _charact_mat_a_pow, lib_ff.flatten_list(_s[_int_msg_parts])))

    # print('check: ', _int_symbol_width, _list_prim_poly, _charact_mat_a_pow, _s[int(_int_msg_parts)])
    _crc_result = lib_ff.matrix_multiply_array_symbols(_int_symbol_width, _list_prim_poly, _charact_mat_a_pow, _s[int(_int_msg_parts)])
    _crc_result_flattened = []
    for _i in range(0, _int_msg_tuplewidth):
        _crc_result_flattened.append(lib_ff.flatten_list(_crc_result[_i]))

    print('CRC =', _crc_result_flattened)

    return _crc_result_flattened





def generate_char_matrix_a_symbols(_int_symbol_width, _list_prim_poly, _int_msg_tuplewidth, _list_symbol_seed, _list_gen_pol):


    # Characteristic Matrix A
    # Dimensions of the Characteristic Matrix A are defined by the length of the Generator Polynomial ('_list_gen_pol')
    _charact_mat_a = char_matrix_a_lfsm1_symbols(_int_symbol_width, _list_symbol_seed, _list_prim_poly, _list_gen_pol)
    # print('_charact_mat_a =', _charact_mat_a)


    # Check if one tuple has the same length as the Generator Polynomial
    if (_int_msg_tuplewidth == len(_charact_mat_a[0])):
        print('Tuple width check OK.')
    else:
        print('ERROR: "_int_msg_tuplewidth" must be equal to one dimension of the Characteristic Matrix A "_charact_mat_a". Return 5.')
        return 5


    # Bitwise multiplication of two matrices
    # WATCH OUT! Now, we are going to scramble '_msg_symbolwidth' symbols and so we need to create this degree of '_charact_mat_a'
    _charact_mat_a_pow = lib_ff.matrix_power_symbols(_int_symbol_width, _int_msg_tuplewidth, _list_prim_poly, _charact_mat_a)
    # print('generated _charact_mat_a_pow =', _charact_mat_a_pow)
    # print('dimensions: ', len(_charact_mat_a_pow), ' x ', len(_charact_mat_a_pow[0]), 'columns (SHOULD BE SQUARE MATRIX)')

    return lib_ff.flatten_list(_charact_mat_a_pow)






# ---------- SYNDROMES Calculation in a symbolic-tuple-parallel order over GF(2^m) ----------
def syn_symbolic_parallel_gf2m_lfsm1(_int_symbol_width, _list_prim_poly, _int_msg_symbols_cnt, _int_msg_tuplewidth, _list_symbol_seed, _list_gen_pol, _list_in_msg, _list_crc):

    print('_int_msg_tuplewidth: ', _int_msg_tuplewidth)

    # Add new constant zero bits if the number of input bits message is not divisible by the symbol width and tuple width without remainder
    _list_new_in_msg_not_flattened = []
    _list_new_in_msg_not_flattened.append(_list_in_msg)
    _list_new_in_msg_not_flattened.append(_list_crc)
    _list_new_in_msg = lib_ff.flatten_list(_list_new_in_msg_not_flattened)
    _cnt_new_bits_added = 0
    # if (_msg_symbolwidth > len(_list_new_in_msg)/_symbol_width):
    if ((_int_msg_symbols_cnt > len(_list_new_in_msg)/_int_symbol_width) | ((len(_list_new_in_msg)/_int_symbol_width) % _int_msg_tuplewidth != 0)):
        # while ((_int_msg_symbols_cnt != len(_list_new_in_msg)/_int_symbol_width) | (len(_list_new_in_msg) % _int_symbol_width != 0)):
        while ((len(_list_new_in_msg) % _int_symbol_width != 0) | ((len(_list_new_in_msg)/_int_symbol_width) % _int_msg_tuplewidth != 0)):
            _cnt_new_bits_added += 1
            _list_new_in_msg.insert(0, 0)
    
    print('Added ', _cnt_new_bits_added, ' bits to the message.')
    print('_list_new_in_msg: ', _list_new_in_msg)
    print('The message now consists of ', int(len(_list_new_in_msg)/_int_symbol_width), ' symbols.')



    # Slice input into separate symbols
    # TO DO: Add zeros where necessary
    # _msg_bucketlist = lib_ff.msg_slice_in_symbols(_int_symbol_width, _int_msg_symbols_cnt, _list_new_in_msg)
    _msg_bucketlist = lib_ff.msg_slice_in_symbols(_int_symbol_width, int(len(_list_new_in_msg)/_int_symbol_width), _list_new_in_msg)
    # append the CRC to the message
    # for _i in range(len(_list_crc)):
    #     _msg_bucketlist.append(lib_ff.flatten_list(_list_crc[_i]))
    # print('"_msg_bucketlist" (descram) = ', _msg_bucketlist)
    # print('Symbols to descramble = ', len(_msg_bucketlist))


    # Slice input into separate symbols and eventually add some bits to make the _list_in_msg be divisible by _int_symbol_width without remainder
    # TO DO: Add zeros where necessary
    # _msg_bucketlist = lib_ff.msg_slice_in_symbols(_int_symbol_width, _int_msg_symbols_cnt, _list_in_msg)
    print('_msg_bucketlist =', _msg_bucketlist)

    # Check if the actual _msg_bucketlist can be divided into tuples of symbols without remainder
    if ((len(_msg_bucketlist) % _int_msg_tuplewidth) == 0):
        _int_msg_parts = len(_msg_bucketlist) / _int_msg_tuplewidth
        print('Divisibility check OK. "_int_msg_parts: "', _int_msg_parts)
    # else:
        # Add new symbols if the _msg_bucketlist is not divisible without remainder
        # _act_length_msg = len(_msg_bucketlist)
        # _list_new_in_msg_bucketlist = _msg_bucketlist
        # _cnt_new_symbols_added = 0
        # if (_int_msg_tuplewidth > len(_msg_bucketlist)/_int_msg_tuplewidth):
        #     # Add zero symbols to the nearest tuple without remainder
        #     while (len(_list_new_in_msg_bucketlist) % _int_msg_tuplewidth != 0):
        #         _cnt_new_symbols_added += 1
        #         _list_new_in_msg_bucketlist.insert(0, [0 for i in range(_int_symbol_width)])
        
        # _act_length_msg = len(_msg_bucketlist)
        # # _list_new_in_msg_bucketlist = _msg_bucketlist
        # _cnt_new_symbols_added = 0
        # if (_int_msg_tuplewidth > len(_msg_bucketlist)/_int_msg_tuplewidth):
        #     # Add zero symbols to the nearest tuple without remainder
        #     while (len(_msg_bucketlist) % _int_msg_tuplewidth != 0):
        #         _cnt_new_symbols_added += 1
        #         _msg_bucketlist.insert(0, [0 for i in range(_int_symbol_width)])

        # _int_msg_parts = len(_msg_bucketlist) / _int_msg_tuplewidth
        # print('Divisibility check previously NOK. Actual msg parts: "_int_msg_parts: "', _int_msg_parts)
        # print('Added ', _cnt_new_symbols_added, ' symbols to the message.')
        # print('_list_new_in_msg_bucketlist: ', _msg_bucketlist)
        # print('The message now consists of ', int(len(_msg_bucketlist)/_int_msg_tuplewidth), ' tuples.')


    print('_int_msg_parts: ', int(_int_msg_parts))
    _msg_bucketlist_tuples = lib_ff.msg_slice_in_tuples(_msg_bucketlist, _int_msg_tuplewidth, int(_int_msg_parts))
    print('_msg_bucketlist_tuples = ', _msg_bucketlist_tuples)


    # Characteristic Matrix A
    # Dimensions of the Characteristic Matrix A are defined by the length of the Generator Polynomial ('_list_gen_pol')
    _charact_mat_a = char_matrix_a_lfsm1_symbols(_int_symbol_width, _list_symbol_seed, _list_prim_poly, _list_gen_pol)
    print('_charact_mat_a =', _charact_mat_a)


    # Check if one tuple has the same length as the Generator Polynomial
    if (_int_msg_tuplewidth == len(_charact_mat_a[0])):
        print('Tuple width check OK.')
    else:
        print('ERROR: "_int_msg_tuplewidth" must be equal to one dimension of the Characteristic Matrix A "_charact_mat_a". Return 5.')
        return 5


    # Bitwise multiplication of two matrices
    # WATCH OUT! Now, we are going to scramble '_msg_symbolwidth' symbols and so we need to create this degree of '_charact_mat_a'
    _charact_mat_a_pow = lib_ff.matrix_power_symbols(_int_symbol_width, _int_msg_tuplewidth, _list_prim_poly, _charact_mat_a)
    print('_charact_mat_a_pow =', _charact_mat_a_pow)

    # Initial Bitwise multiplication of a matrix and a vector
    _s = [[] * _int_symbol_width for _u in range(int(_int_msg_parts)+1)]
    for _u in range(0, int(_int_msg_parts)+1):
        _s[_u] = [[0] * _int_symbol_width for _u in range(int(_int_msg_tuplewidth))]

    # _s_tuples = lib_ff.msg_slice_in_tuples(_s[0], int(_int_msg_tuple_symbols), int(_int_msg_parts))
    print('initial _s[0]: ', _s)

    # # Forming intermediate states
    # Over all msg parts (= tuples), symbols
    _cnt_act_sym = 0
    _cnt_act_tup = 0
    _cnt_pick_in_symbol = 0
    _multiplied_mat_a_intuple = []
    for _u in range(0, int(_int_msg_parts)):

        # OPT.1: Multiply the Characteristic Matrix Awith the initial _s[0] vector
        # _multiplied_mat_a_intuple.append(lib_ff.matrix_multiply_array_symbols(_int_symbol_width, _list_prim_poly, _charact_mat_a, _s[_u]))

        # OPT.2: Multiply the Characteristic Matrix A multiplied by itself many times with the initial _s[0] vector
        _multiplied_mat_a_intuple.append(lib_ff.matrix_multiply_array_symbols(_int_symbol_width, _list_prim_poly, _charact_mat_a_pow, _s[_u]))

        # print('_multiplied_mat_a_intuple: ', _multiplied_mat_a_intuple)

        # Add the result to the input message symbol and create new _s[_+1] vector
        for _i in range (0, int(_int_msg_tuplewidth)):
            # print('_multiplied_mat_a_intuple[', _i, ']: ', lib_ff.flatten_list(_multiplied_mat_a_intuple[_u][_i]))
            _s[_u+1][_i] = lib_ff.function_list_xor(lib_ff.flatten_list(_multiplied_mat_a_intuple[_u][_i]), _msg_bucketlist[_cnt_pick_in_symbol])
            _cnt_pick_in_symbol += 1


    # Check what "_s" contains
    print('entire _s[] (tuples in rows, init row = "0"): ')
    # print(_s)
    lib_ff.print_list_rows(_s)

    # # CRC calculation
    print('_s[_int_msg_parts]: ', _s[int(_int_msg_parts)])
    _final_multiply = _s[int(_int_msg_parts)]
    # print('_final_multiply: ', _final_multiply)

    # print(lib_ff.matrix_multiply_array_symbols(_int_symbol_width, _list_prim_poly, _charact_mat_a_pow, lib_ff.flatten_list(_s[_int_msg_parts])))

    print('check: ', _int_symbol_width, _list_prim_poly, _charact_mat_a_pow, _s[int(_int_msg_parts)])
    _crc_result = lib_ff.matrix_multiply_array_symbols(_int_symbol_width, _list_prim_poly, _charact_mat_a_pow, _s[int(_int_msg_parts)])
    _crc_result_flattened = []
    for _i in range(0, _int_msg_tuplewidth):
        _crc_result_flattened.append(lib_ff.flatten_list(_crc_result[_i]))
    print('SYNDROMES =', _crc_result_flattened)

    return _crc_result_flattened



# ---------- TWO-PARALLEL Symbolic-tuple-parallel GF(2^m) CRC Encoder ----------
def crc_symbolic_parallel_gf2m_lfsm1_TEST(_int_symbol_width, _list_prim_poly, _int_msg_symbols_cnt, _int_msg_tuplewidth, _list_symbol_seed, _list_gen_pol, _list_in_msg):

    # Add new constant zero bits if the number of input bits message is not divisible by the symbol width and tuple width without remainder
    _list_new_in_msg_not_flattnd = []
    _list_new_in_msg_not_flattnd.append(_list_in_msg)
    _list_new_in_msg = lib_ff.flatten_list(_list_new_in_msg_not_flattnd)
    _cnt_new_bits_added = 0
    # if (_msg_symbolwidth > len(_list_new_in_msg)/_symbol_width):
    if ((_int_msg_symbols_cnt > len(_list_new_in_msg)/_int_symbol_width) | ((len(_list_new_in_msg)/_int_symbol_width) % _int_msg_tuplewidth != 0)):
        # while ((_int_msg_symbols_cnt != len(_list_new_in_msg)/_int_symbol_width) | (len(_list_new_in_msg) % _int_symbol_width != 0)):
        while ((len(_list_new_in_msg) % _int_symbol_width != 0) | ((len(_list_new_in_msg)/_int_symbol_width) % _int_msg_tuplewidth != 0)):
            _cnt_new_bits_added += 1
            _list_new_in_msg.insert(0, 0)
    
    print('Added ', _cnt_new_bits_added, ' bits to the message.')
    print('_list_new_in_msg: ', _list_new_in_msg)
    print('The message now consists of ', int(len(_list_new_in_msg)/_int_symbol_width), ' symbols.')



    # Slice input into separate symbols and eventually add some bits to make the _list_in_msg be divisible by _int_symbol_width without remainder
    # TO DO: Add zeros where necessary
    # _msg_bucketlist = lib_ff.msg_slice_in_symbols(_int_symbol_width, _int_msg_symbols_cnt, _list_new_in_msg)
    _msg_bucketlist = lib_ff.msg_slice_in_symbols(_int_symbol_width, int(len(_list_new_in_msg)/_int_symbol_width), _list_new_in_msg)
    print('_msg_bucketlist =', _msg_bucketlist)

    # Check if the actual _msg_bucketlist can be divided into tuples of symbols without remainder
    if ((len(_msg_bucketlist) % _int_msg_tuplewidth) == 0):
        # _int_msg_parts = _int_msg_symbols_cnt / _int_msg_tuplewidth
        _int_msg_parts = len(_msg_bucketlist) / _int_msg_tuplewidth
        print('Divisibility check OK. "_int_msg_parts: "', _int_msg_parts)
    # else:

        # Add new symbols if the _msg_bucketlist is not divisible without remainder
        # _act_length_msg = len(_msg_bucketlist)
        # _list_new_in_msg_bucketlist = _msg_bucketlist
        # _cnt_new_symbols_added = 0
        # if (_int_msg_tuplewidth > len(_msg_bucketlist)/_int_msg_tuplewidth):
        #     # Add zero symbols to the nearest tuple without remainder
        #     while (len(_list_new_in_msg_bucketlist) % _int_msg_tuplewidth != 0):
        #         _cnt_new_symbols_added += 1
        #         _list_new_in_msg_bucketlist.insert(0, [0 for i in range(_int_symbol_width)])

        # _act_length_msg = len(_msg_bucketlist)
        # # _list_new_in_msg_bucketlist = _msg_bucketlist
        # _cnt_new_symbols_added = 0
        # if (_int_msg_tuplewidth > len(_msg_bucketlist)/_int_msg_tuplewidth):
        #     # Add zero symbols to the nearest tuple without remainder
        #     while (len(_msg_bucketlist) % _int_msg_tuplewidth != 0):
        #         _cnt_new_symbols_added += 1
        #         _msg_bucketlist.insert(0, [0 for i in range(_int_symbol_width)])

        # _int_msg_parts = len(_msg_bucketlist) / _int_msg_tuplewidth
        # print('Divisibility check previously NOK. Actual msg parts: "_int_msg_parts: "', _int_msg_parts)
        # print('Added ', _cnt_new_symbols_added, ' symbols to the message = ', _cnt_new_symbols_added * _int_symbol_width, ' bits.')
        # print('_list_new_in_msg_bucketlist: ', _msg_bucketlist)
        # print('The message now consists of ', int(len(_msg_bucketlist)/_int_msg_tuplewidth), ' tuples of symbols.')


    # print('_int_msg_parts: ', int(_int_msg_parts))
    _msg_bucketlist_tuples = lib_ff.msg_slice_in_tuples(_msg_bucketlist, _int_msg_tuplewidth, int(_int_msg_parts))
    # print('_msg_bucketlist_tuples = ', _msg_bucketlist_tuples)


    # Characteristic Matrix A
    # Dimensions of the Characteristic Matrix A are defined by the length of the Generator Polynomial ('_list_gen_pol')
    _charact_mat_a = char_matrix_a_lfsm1_symbols(_int_symbol_width, _list_symbol_seed, _list_prim_poly, _list_gen_pol)
    # print('_charact_mat_a =', _charact_mat_a)


    # Check if one tuple has the same length as the Generator Polynomial
    if (_int_msg_tuplewidth == len(_charact_mat_a[0])):
        print('Tuple width check OK.')
    else:
        print('ERROR: "_int_msg_tuplewidth" must be equal to one dimension of the Characteristic Matrix A "_charact_mat_a". Return 5.')
        return 5


    # Bitwise multiplication of two matrices
    # WATCH OUT! Now, we are going to scramble '_msg_symbolwidth' symbols and so we need to create this degree of '_charact_mat_a'
    _charact_mat_a_pow = lib_ff.matrix_power_symbols(_int_symbol_width, _int_msg_tuplewidth, _list_prim_poly, _charact_mat_a)
    # print('_charact_mat_a_pow =', _charact_mat_a_pow)

    # Initial Bitwise multiplication of a matrix and a vector
    _s = [[] * _int_symbol_width for _u in range(int(_int_msg_parts)+1)]
    for _u in range(0, int(_int_msg_parts)+1):
        _s[_u] = [[0] * _int_symbol_width for _u in range(int(_int_msg_tuplewidth))]

    # _s_tuples = lib_ff.msg_slice_in_tuples(_s[0], int(_int_msg_tuple_symbols), int(_int_msg_parts))
    # print('initial _s[0]: ', _s)

    # # Forming intermediate states
    # Over all msg parts (= tuples), symbols
    _cnt_act_sym = 0
    _cnt_act_tup = 0
    _cnt_pick_in_symbol = 0
    _multiplied_mat_a_intuple = []
    for _u in range(0, int(_int_msg_parts)):        # OPT.1: Multiply the Characteristic Matrix Awith the initial _s[0] vector        # _multiplied_mat_a_intuple.append(lib_ff.matrix_multiply_array_symbols(_int_symbol_width, _list_prim_poly, _charact_mat_a, _s[_u]))
        # Multiply the Characteristic Matrix A multiplied by itself many times with the initial _s[0] vector
        _multiplied_mat_a_intuple.append(lib_ff.matrix_multiply_array_symbols(_int_symbol_width, _list_prim_poly, _charact_mat_a_pow, _s[_u]))

        # print('_s[_u]: ', _s[_u])
        # print('_multiplied_mat_a_intuple: ', _multiplied_mat_a_intuple)

        # Add the result to the input message symbol and create new _s[_+1] vector
        for _i in range (0, int(_int_msg_tuplewidth)):
            # print('_multiplied_mat_a_intuple[', _i, ']: ', lib_ff.flatten_list(_multiplied_mat_a_intuple[_u][_i]))
            _s[_u+1][_i] = lib_ff.function_list_xor(lib_ff.flatten_list(_multiplied_mat_a_intuple[_u][_i]), _msg_bucketlist[_cnt_pick_in_symbol])
            _cnt_pick_in_symbol += 1

    lib_ff.print_list_rows(_multiplied_mat_a_intuple)

    # Check what "_s" contains
    # print('entire _s[] (tuples in rows, init row = "0"): ')
    # print(_s)
    # lib_ff.print_list_rows(_s)

    # # CRC calculation
    # print('_s[_int_msg_parts]: ', _s[int(_int_msg_parts)])
    _final_multiply = _s[int(_int_msg_parts)]
    # print('_final_multiply: ', _final_multiply)

    # print(lib_ff.matrix_multiply_array_symbols(_int_symbol_width, _list_prim_poly, _charact_mat_a_pow, lib_ff.flatten_list(_s[_int_msg_parts])))

    # print('check: ', _int_symbol_width, _list_prim_poly, _charact_mat_a_pow, _s[int(_int_msg_parts)])
    _crc_result = lib_ff.matrix_multiply_array_symbols(_int_symbol_width, _list_prim_poly, _charact_mat_a_pow, _s[int(_int_msg_parts)])
    _crc_result_flattened = []
    for _i in range(0, _int_msg_tuplewidth):
        _crc_result_flattened.append(lib_ff.flatten_list(_crc_result[_i]))

    print('CRC =', _crc_result_flattened)

    return _crc_result_flattened




# Slice a Message into Sub-messages
def slice_into_submessages(_int_symbol_width, _int_msg_symbols_cnt, _int_msg_tuplewidth, _submessages_cnt, _list_in_msg):

    # Add new constant zero bits if the number of input bits message is not divisible by the symbol width and tuple width without remainder
    _list_new_in_msg_not_flattnd = []
    _list_new_in_msg_not_flattnd.append(_list_in_msg)
    _list_new_in_msg = lib_ff.flatten_list(_list_new_in_msg_not_flattnd)
    _cnt_new_bits_added = 0
    # if (_msg_symbolwidth > len(_list_new_in_msg)/_symbol_width):
    if ((_int_msg_symbols_cnt > len(_list_new_in_msg)/_int_symbol_width) | ((len(_list_new_in_msg)/_int_symbol_width) % _int_msg_tuplewidth != 0)):
        # while ((_int_msg_symbols_cnt != len(_list_new_in_msg)/_int_symbol_width) | (len(_list_new_in_msg) % _int_symbol_width != 0)):
        while ((len(_list_new_in_msg) % _int_symbol_width != 0) | ((len(_list_new_in_msg)/_int_symbol_width) % _int_msg_tuplewidth != 0)):
            _cnt_new_bits_added += 1
            _list_new_in_msg.insert(0, 0)
    
    print('Added ', _cnt_new_bits_added, ' bits to the message.')
    print('_list_new_in_msg: ', _list_new_in_msg)
    print('The message now consists of ', int(len(_list_new_in_msg)/_int_symbol_width), ' symbols.')

    # _bucketlist_input = [[0] * _int_symbol_width for i in range(int(len(_list_new_in_msg)/_int_symbol_width))]
    # _cnt_bit = 0
    # _cnt_element = 0
    # for _i in range(0, len(_list_new_in_msg)):
    #     if (_cnt_bit < _int_symbol_width-1):
    #         _bucketlist_input[_cnt_element][_cnt_bit] = _list_new_in_msg[_i]
    #         _cnt_bit += 1
    #     elif (_cnt_bit == _int_symbol_width-1):
    #         if(_cnt_element <= (int(len(_list_new_in_msg)/_int_symbol_width)-1)):
    #             _bucketlist_input[_cnt_element][_cnt_bit] = _list_new_in_msg[_i]
    #         _cnt_bit = 0
    #         _cnt_element += 1

    # print(_submessages_cnt)
    _bucketlist_submsgs = [[] for i in range(_submessages_cnt)]
    _bits_start = [0 for i in range(_submessages_cnt)]
    _bits_end = [0 for i in range(_submessages_cnt)]
    _cnt_bit = 0
    _cnt_submsg_id = 0
    for _i in range(len(_list_new_in_msg)):
        if (_cnt_submsg_id < _submessages_cnt-1):
            _bucketlist_submsgs[_cnt_submsg_id].append(_list_new_in_msg[_i])
            _cnt_bit += 1
            _cnt_submsg_id += 1
        elif (_cnt_submsg_id == _submessages_cnt-1):
            _bucketlist_submsgs[_cnt_submsg_id].append(_list_new_in_msg[_i])
            _cnt_bit += 1
            _cnt_submsg_id = 0
            
    
    _bits_parts_start = [0 for i in range(_submessages_cnt)]
    _bits_parts_end = [0 for i in range(_submessages_cnt)]
    for _i in range(_submessages_cnt):
        if _i == 0:
            _bits_parts_start[_i] = 0
            _bits_parts_end[_i] = len(_bucketlist_submsgs[_i])-1
        elif _i > 0:
            _bits_parts_start[_i] = _bits_parts_end[_i-1] + 1
            _bits_parts_end[_i] = _bits_parts_start[_i] + (len(_bucketlist_submsgs[_i])-1)
            
    print('_bits_parts_start: ', _bits_parts_start)
    print('_bits_parts_end: ', _bits_parts_end)

    _bucketlist_inputs_submsgs = [[0] * len(_list_new_in_msg) for i in range(_submessages_cnt)]
    _act_msg = 0
    # for _i in range(_submessages_cnt):
    for _u in range(len(_list_new_in_msg)):
        _bucketlist_inputs_submsgs[_act_msg][_u] = _list_new_in_msg[_u]
        if _u == _bits_parts_end[_act_msg]:
            _act_msg += 1

    print('_bucketlist_inputs_submsgs: ')
    lib_ff.print_list_rows(_bucketlist_inputs_submsgs)

    # _cnt_bit = 0
    # _cnt_submsg_id = 0
    # for _i in range(0, len(_list_new_in_msg)):
    #     if (_cnt_bit < len(_list_new_in_msg)-1):
    #         _bucketlist_submsgs[_cnt_submsg][_cnt_bit] = _list_new_in_msg[_i]
    #         _cnt_bit += 1
    #     elif (_cnt_bit == len(_list_new_in_msg)-1):
    #         if(_cnt_submsg <= (_submessages_cnt-1)):
    #             _bucketlist_submsgs[_cnt_submsg][_cnt_bit] = _list_new_in_msg[_i]
    #         _cnt_bit = 0
    #         _cnt_submsg += 1



    # print('bucketlist in function: ', _bucketlist_input)

    return _bucketlist_inputs_submsgs


# Create desired number of sub-messages out of the original message
def slice_into_submessages_origmsg(_int_symbol_width, _int_msg_symbols_cnt, _int_msg_tuplewidth, _submessages_cnt, _list_in_msg):

    # print(_submessages_cnt)
    _bucketlist_submsgs = [[] for i in range(_submessages_cnt)]
    _bits_start = [0 for i in range(_submessages_cnt)]
    _bits_end = [0 for i in range(_submessages_cnt)]
    _cnt_bit = 0
    _cnt_submsg_id = 0
    for _i in range(len(_list_in_msg)):
        if (_cnt_submsg_id < _submessages_cnt-1):
            _bucketlist_submsgs[_cnt_submsg_id].append(_list_in_msg[_i])
            _cnt_bit += 1
            _cnt_submsg_id += 1
        elif (_cnt_submsg_id == _submessages_cnt-1):
            _bucketlist_submsgs[_cnt_submsg_id].append(_list_in_msg[_i])
            _cnt_bit += 1
            _cnt_submsg_id = 0
            
    
    _bits_parts_start = [0 for i in range(_submessages_cnt)]
    _bits_parts_end = [0 for i in range(_submessages_cnt)]
    for _i in range(_submessages_cnt):
        if _i == 0:
            _bits_parts_start[_i] = 0
            _bits_parts_end[_i] = len(_bucketlist_submsgs[_i])-1
        elif _i > 0:
            _bits_parts_start[_i] = _bits_parts_end[_i-1] + 1
            _bits_parts_end[_i] = _bits_parts_start[_i] + (len(_bucketlist_submsgs[_i])-1)

    print('_bits_parts_start: ', _bits_parts_start)
    print('_bits_parts_end: ', _bits_parts_end)

    _bucketlist_inputs_submsgs = [[0] * len(_list_in_msg) for i in range(_submessages_cnt)]
    _act_msg = 0
    # for _i in range(_submessages_cnt):
    for _u in range(len(_list_in_msg)):
        _bucketlist_inputs_submsgs[_act_msg][_u] = _list_in_msg[_u]
        if _u == _bits_parts_end[_act_msg]:
            _act_msg += 1

    print('_bucketlist_inputs_submsgs: ')
    lib_ff.print_list_rows(_bucketlist_inputs_submsgs)

    # print('bucketlist in function: ', _bucketlist_input)

    return _bucketlist_inputs_submsgs


# This function returns bitwidths of the number sub-messages out of the original message as equally as possible
def get_submessages_bits_start_end(_int_symbol_width, _int_msg_symbols_cnt, _int_msg_tuplewidth, _submessages_cnt, _list_in_msg):

    # print(_submessages_cnt)
    _bucketlist_submsgs = [[] for i in range(_submessages_cnt)]
    _bits_start = [0 for i in range(_submessages_cnt)]
    _bits_end = [0 for i in range(_submessages_cnt)]
    _cnt_bit = 0
    _cnt_submsg_id = 0
    for _i in range(len(_list_in_msg)):
        if (_cnt_submsg_id < _submessages_cnt-1):
            _bucketlist_submsgs[_cnt_submsg_id].append(_list_in_msg[_i])
            _cnt_bit += 1
            _cnt_submsg_id += 1
        elif (_cnt_submsg_id == _submessages_cnt-1):
            _bucketlist_submsgs[_cnt_submsg_id].append(_list_in_msg[_i])
            _cnt_bit += 1
            _cnt_submsg_id = 0
            
    
    _bits_parts_start = [0 for i in range(_submessages_cnt)]
    _bits_parts_end = [0 for i in range(_submessages_cnt)]
    for _i in range(_submessages_cnt):
        if _i == 0:
            _bits_parts_start[_i] = 0
            _bits_parts_end[_i] = len(_bucketlist_submsgs[_i])-1
        elif _i > 0:
            _bits_parts_start[_i] = _bits_parts_end[_i-1] + 1
            _bits_parts_end[_i] = _bits_parts_start[_i] + (len(_bucketlist_submsgs[_i])-1)

    print('_bits_parts_start: ', _bits_parts_start)
    print('_bits_parts_end: ', _bits_parts_end)

    # _bucketlist_inputs_submsgs = [[0] * len(_list_in_msg) for i in range(_submessages_cnt)]
    # _act_msg = 0
    # # for _i in range(_submessages_cnt):
    # for _u in range(len(_list_in_msg)):
    #     _bucketlist_inputs_submsgs[_act_msg][_u] = _list_in_msg[_u]
    #     if _u == _bits_parts_end[_act_msg]:
    #         _act_msg += 1

    # print('_bucketlist_inputs_submsgs: ')
    # lib_ff.print_list_rows(_bucketlist_inputs_submsgs)

    # print('bucketlist in function: ', _bucketlist_input)

    _list_start_end = []
    _list_start_end.append(_bits_parts_start)
    _list_start_end.append(_bits_parts_end)

    return _list_start_end



# Locate where to place registers in each sub-message (GET_TUPLE_ID)
def insert_registers_tuples(_int_symbol_width, _int_msg_symbols_cnt, _int_msg_tuplewidth, _submessages_cnt, _list_in_msg):

    print('------- function insert_registers_tuples -------')
    # print(_submessages_cnt)
    _bucketlist_submsgs = [[] for i in range(_submessages_cnt)]
    _bits_start = [0 for i in range(_submessages_cnt)]
    _bits_end = [0 for i in range(_submessages_cnt)]
    _cnt_bit = 0
    _cnt_submsg_id = 0
    for _i in range(len(_list_in_msg)):
        if (_cnt_submsg_id < _submessages_cnt-1):
            _bucketlist_submsgs[_cnt_submsg_id].append(_list_in_msg[_i])
            _cnt_bit += 1
            _cnt_submsg_id += 1
        elif (_cnt_submsg_id == _submessages_cnt-1):
            _bucketlist_submsgs[_cnt_submsg_id].append(_list_in_msg[_i])
            _cnt_bit += 1
            _cnt_submsg_id = 0
            
    
    _bits_parts_start = [0 for i in range(_submessages_cnt)]
    _bits_parts_end = [0 for i in range(_submessages_cnt)]
    for _i in range(_submessages_cnt):
        if _i == 0:
            _bits_parts_start[_i] = 0
            _bits_parts_end[_i] = len(_bucketlist_submsgs[_i])-1
        elif _i > 0:
            _bits_parts_start[_i] = _bits_parts_end[_i-1] + 1
            _bits_parts_end[_i] = _bits_parts_start[_i] + (len(_bucketlist_submsgs[_i])-1)

    print('_bits_parts_start: ', _bits_parts_start)
    print('_bits_parts_end: ', _bits_parts_end)

    _bucketlist_inputs_submsgs = [[0] * len(_list_in_msg) for i in range(_submessages_cnt)]
    _act_msg = 0
    # for _i in range(_submessages_cnt):
    for _u in range(len(_list_in_msg)):
        _bucketlist_inputs_submsgs[_act_msg][_u] = _list_in_msg[_u]
        if _u == _bits_parts_end[_act_msg]:
            _act_msg += 1

    print('_bucketlist_inputs_submsgs: ')
    lib_ff.print_list_rows(_bucketlist_inputs_submsgs)


    # Add new constant zero bits if the number of input bits message is not divisible by the symbol width and tuple width without remainder
    _list_new_in_msg = []
    for _i in range(len(_bucketlist_inputs_submsgs)):
        _list_new_in_msg.append(_bucketlist_inputs_submsgs[_i])

    _msg_bucketlist = [[] for i in range(len(_bucketlist_inputs_submsgs))]
    for _i in range(len(_bucketlist_inputs_submsgs)):
        _cnt_new_bits_added = 0
        if ((_int_msg_symbols_cnt > len(_list_new_in_msg[_i])/_int_symbol_width) | ((len(_list_new_in_msg[_i])/_int_symbol_width) % _int_msg_tuplewidth != 0)):
            while ((len(_list_new_in_msg[_i]) % _int_symbol_width != 0) | ((len(_list_new_in_msg[_i])/_int_symbol_width) % _int_msg_tuplewidth != 0)):
                _cnt_new_bits_added += 1
                _list_new_in_msg[_i].insert(0, 0)
    
        print('Added ', _cnt_new_bits_added, ' bits to the message.')
        # print('_list_new_in_msg: ', _list_new_in_msg[_i])
        # print('The message now consists of ', int(len(_list_new_in_msg[_i])/_int_symbol_width), ' symbols.')


        # Slice input into separate symbols and eventually add some bits to make the _list_in_msg be divisible by _int_symbol_width without remainder
        _msg_bucketlist[_i] = lib_ff.msg_slice_in_symbols(_int_symbol_width, int(len(_list_new_in_msg[_i])/_int_symbol_width), _list_new_in_msg[_i])
        # print('_msg_bucketlist =', _msg_bucketlist[_i])

        # Check if the actual _msg_bucketlist can be divided into tuples of symbols without remainder
        if ((len(_msg_bucketlist[_i]) % _int_msg_tuplewidth) == 0):
            _int_msg_parts = len(_msg_bucketlist[_i]) / _int_msg_tuplewidth
            print('Divisibility check OK. "_int_msg_parts: "', _int_msg_parts)

    # print('_int_msg_parts: ', int(_int_msg_parts))
    # _msg_bucketlist_tuples = lib_ff.msg_slice_in_tuples(_msg_bucketlist[_i], _int_msg_tuplewidth, int(_int_msg_parts))
    # print('_msg_bucketlist_tuples = ', _msg_bucketlist_tuples)


    # to which symbol and tuple any single bit belongs to?
    # _cnt_act_bit_in_symbol = 0
    _list_reg_symbol = [[] for i in range(len(_msg_bucketlist))]
    _list_reg_tuple = [[] for i in range(len(_msg_bucketlist))]
    for _i in range(len(_msg_bucketlist)):
        _cnt_act_symbol = 0
        _cnt_sym_in_tuple = 0
        _cnt_act_tuple = 0
        for _u in range(len(_msg_bucketlist[0])):
            for _s in range(_int_symbol_width):
                _list_reg_symbol[_i].append(_cnt_act_symbol)
            _cnt_act_symbol += 1
            _cnt_sym_in_tuple += 1
            for _s in range(_int_symbol_width):
                _list_reg_tuple[_i].append(_cnt_act_tuple)
            if (_cnt_sym_in_tuple == _int_msg_tuplewidth):
                _cnt_act_tuple += 1
                _cnt_sym_in_tuple = 0

    print('_msg_bucketlist:')
    lib_ff.print_list_rows(_msg_bucketlist)
    print('_list_reg_symbol:')
    lib_ff.print_list_rows(_list_reg_symbol)
    print('_list_reg_tuple:')
    lib_ff.print_list_rows(_list_reg_tuple)


    # Place registers ONLY to the MIDDLE of each "_bits_parts_start" and "_bits_parts_end" of the parallel sub-message
    # TO IMPROVE/ TO DO NEXT: Divide the calculation into any nuber of computation steps (slice it in various number of pieces)
    _list_reg_sym_tup = [[] for i in range(_submessages_cnt)]
    _list_avg_submsg = [[] for i in range(_submessages_cnt)]
    for _i in range(_submessages_cnt):
        _list_avg_submsg[_i] = lib_math.ceil(_bits_parts_start[_i] + ((_bits_parts_end[_i] - _bits_parts_start[_i]) / 2))
        # _list_reg_sym_tup[_i].append(_list_reg_symbol[_i][_list_avg_submsg[_i]])
        # We need only tuple ID
        _list_reg_sym_tup[_i].append(_list_reg_tuple[_i][_list_avg_submsg[_i]])

    # The below says that "_list_avg_submsg" is a bit in a certain submessage where it is worth to put registers
    print('_list_avg_submsg:', _list_avg_submsg)
    
    # Below we say that based on the "_list_avg_submsg" we can determine to which symbol and tuple the bit "_list_avg_submsg" belongs to
    # So we can now exactly determine where to put registers to speed up computation
    print('_list_reg_sym_tup:')
    lib_ff.print_list_rows(_list_reg_sym_tup)

    return _list_reg_sym_tup



# Locate where to place registers in each sub-message (GET_TUPLE_ID)
def synchronize_delayed_input(_int_symbol_width, _int_msg_symbols_cnt, _int_msg_tuplewidth, _submessages_cnt, _list_in_msg):

    print('------- function synchronize_delayed_input -------')
    # print(_submessages_cnt)
    _bucketlist_submsgs = [[] for i in range(_submessages_cnt)]
    _bits_start = [0 for i in range(_submessages_cnt)]
    _bits_end = [0 for i in range(_submessages_cnt)]
    _cnt_bit = 0
    _cnt_submsg_id = 0
    for _i in range(len(_list_in_msg)):
        if (_cnt_submsg_id < _submessages_cnt-1):
            _bucketlist_submsgs[_cnt_submsg_id].append(_list_in_msg[_i])
            _cnt_bit += 1
            _cnt_submsg_id += 1
        elif (_cnt_submsg_id == _submessages_cnt-1):
            _bucketlist_submsgs[_cnt_submsg_id].append(_list_in_msg[_i])
            _cnt_bit += 1
            _cnt_submsg_id = 0
            
    
    _bits_parts_start = [0 for i in range(_submessages_cnt)]
    _bits_parts_end = [0 for i in range(_submessages_cnt)]
    for _i in range(_submessages_cnt):
        if _i == 0:
            _bits_parts_start[_i] = 0
            _bits_parts_end[_i] = len(_bucketlist_submsgs[_i])-1
        elif _i > 0:
            _bits_parts_start[_i] = _bits_parts_end[_i-1] + 1
            _bits_parts_end[_i] = _bits_parts_start[_i] + (len(_bucketlist_submsgs[_i])-1)

    print('_bits_parts_start: ', _bits_parts_start)
    print('_bits_parts_end: ', _bits_parts_end)

    _bucketlist_inputs_submsgs = [[0] * len(_list_in_msg) for i in range(_submessages_cnt)]
    _act_msg = 0
    # for _i in range(_submessages_cnt):
    for _u in range(len(_list_in_msg)):
        _bucketlist_inputs_submsgs[_act_msg][_u] = _list_in_msg[_u]
        if _u == _bits_parts_end[_act_msg]:
            _act_msg += 1

    print('_bucketlist_inputs_submsgs: ')
    lib_ff.print_list_rows(_bucketlist_inputs_submsgs)


    # Add new constant zero bits if the number of input bits message is not divisible by the symbol width and tuple width without remainder
    _list_new_in_msg = []
    for _i in range(len(_bucketlist_inputs_submsgs)):
        _list_new_in_msg.append(_bucketlist_inputs_submsgs[_i])

    _msg_bucketlist = [[] for i in range(len(_bucketlist_inputs_submsgs))]
    for _i in range(len(_bucketlist_inputs_submsgs)):
        _cnt_new_bits_added = 0
        if ((_int_msg_symbols_cnt > len(_list_new_in_msg[_i])/_int_symbol_width) | ((len(_list_new_in_msg[_i])/_int_symbol_width) % _int_msg_tuplewidth != 0)):
            while ((len(_list_new_in_msg[_i]) % _int_symbol_width != 0) | ((len(_list_new_in_msg[_i])/_int_symbol_width) % _int_msg_tuplewidth != 0)):
                _cnt_new_bits_added += 1
                _list_new_in_msg[_i].insert(0, 0)
    
        print('Added ', _cnt_new_bits_added, ' bits to the message.')
        # print('_list_new_in_msg: ', _list_new_in_msg[_i])
        # print('The message now consists of ', int(len(_list_new_in_msg[_i])/_int_symbol_width), ' symbols.')


        # Slice input into separate symbols and eventually add some bits to make the _list_in_msg be divisible by _int_symbol_width without remainder
        _msg_bucketlist[_i] = lib_ff.msg_slice_in_symbols(_int_symbol_width, int(len(_list_new_in_msg[_i])/_int_symbol_width), _list_new_in_msg[_i])
        # print('_msg_bucketlist =', _msg_bucketlist[_i])

        # Check if the actual _msg_bucketlist can be divided into tuples of symbols without remainder
        if ((len(_msg_bucketlist[_i]) % _int_msg_tuplewidth) == 0):
            _int_msg_parts = len(_msg_bucketlist[_i]) / _int_msg_tuplewidth
            print('Divisibility check OK. "_int_msg_parts: "', _int_msg_parts)

    # print('_int_msg_parts: ', int(_int_msg_parts))
    # _msg_bucketlist_tuples = lib_ff.msg_slice_in_tuples(_msg_bucketlist[_i], _int_msg_tuplewidth, int(_int_msg_parts))
    # print('_msg_bucketlist_tuples = ', _msg_bucketlist_tuples)


    # to which symbol and tuple any single bit belongs to?
    # _cnt_act_bit_in_symbol = 0
    _list_reg_symbol = [[] for i in range(len(_msg_bucketlist))]
    _list_reg_tuple = [[] for i in range(len(_msg_bucketlist))]
    for _i in range(len(_msg_bucketlist)):
        _cnt_act_symbol = 0
        _cnt_sym_in_tuple = 0
        _cnt_act_tuple = 0
        for _u in range(len(_msg_bucketlist[0])):
            for _s in range(_int_symbol_width):
                _list_reg_symbol[_i].append(_cnt_act_symbol)
            _cnt_act_symbol += 1
            _cnt_sym_in_tuple += 1
            for _s in range(_int_symbol_width):
                _list_reg_tuple[_i].append(_cnt_act_tuple)
            if (_cnt_sym_in_tuple == _int_msg_tuplewidth):
                _cnt_act_tuple += 1
                _cnt_sym_in_tuple = 0

    print('_msg_bucketlist:')
    lib_ff.print_list_rows(_msg_bucketlist)
    print('_list_reg_symbol:')
    lib_ff.print_list_rows(_list_reg_symbol)
    print('_list_reg_tuple:')
    lib_ff.print_list_rows(_list_reg_tuple)


    # Place registers ONLY to the MIDDLE of each "_bits_parts_start" and "_bits_parts_end" of the parallel sub-message
    # TO IMPROVE/ TO DO NEXT: Divide the calculation into any nuber of computation steps (slice it in various number of pieces)
    _list_reg_sym_tup = [[] for i in range(_submessages_cnt)]
    _list_avg_submsg = [[] for i in range(_submessages_cnt)]
    for _i in range(_submessages_cnt):
        _list_avg_submsg[_i] = lib_math.ceil(_bits_parts_start[_i] + ((_bits_parts_end[_i] - _bits_parts_start[_i]) / 2))

        # We need only tuple ID
        _list_reg_sym_tup[_i].append(_list_reg_tuple[_i][_list_avg_submsg[_i]])

    # The below says that "_list_avg_submsg" is a bit in a certain submessage where it is worth to put registers
    print('_list_avg_submsg:', _list_avg_submsg)
    
    # Below we say that based on the "_list_avg_submsg" we can determine to which symbol and tuple the bit "_list_avg_submsg" belongs to
    # So we can now exactly determine where to put registers to speed up computation
    print('_list_reg_sym_tup:')
    lib_ff.print_list_rows(_list_reg_sym_tup)

    # Based on these identified Tuples (_list_reg_sym_tup), identify from which delayed message to read from (= synchronize input and pipelined blocks)
    _bucketlist_synch_input = [[] for i in range(_submessages_cnt)]
    for _i in range(_submessages_cnt):
        for _u in range(int(_int_msg_parts)):
            _bucketlist_synch_input[_i].append(1)

    # Add zeros where you want the calculation to be processed in the first pipeline (before registers)
    # And the second part will be synchronized with given delayed input
    for _i in range(_submessages_cnt):
        if _list_reg_sym_tup[_i][0] == 0:
            _bucketlist_synch_input[_i][0] = 0
        else:
            for _u in range(_list_reg_sym_tup[_i][0]):
                _bucketlist_synch_input[_i][_u] = 0

    print(_bucketlist_synch_input)

    return _bucketlist_synch_input