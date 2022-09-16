# ----- Libraries -----
import math as lib_math
import random as lib_rand
import csv as lib_csv
import pathlib as lib_path
import sys


# ----- Functions Declaration -----

# Decimal to binary number conversion
def decimal_to_binlist(int_a):
    res = [int(i) for i in list('{0:0b}'.format(int_a))]
    return res

# Flatten a list
def flatten_list(_list):
    if len(_list) == 1:
        if type(_list[0]) == list:
            result = flatten_list(_list[0])
        else:
            result = _list
    elif type(_list[0]) == list:
        result = flatten_list(_list[0]) + flatten_list(_list[1:])
    else:
        result = [_list[0]] + flatten_list(_list[1:])
    return result

# Print a list in rows
def print_list_rows(list_in):
    for _i in range(0, len(list_in)):
        print(list_in[_i])
    return ''


# Mirror a list: an array or array of arrays...
def mirror_list(list_in):
    _list_mirrored = []
    for i in range(0, len(list_in)):
        _list_mirrored.append(list_in[len(list_in)-1-i])
    return _list_mirrored

# Check positive integer
def check_positive_integer(_pos_int_value):
    if int(_pos_int_value) < 1:
        print("ERROR: Inserted number must be a positive integer.")
        sys.exit(2)
    return int(_pos_int_value)

# Get positive integer
def get_positive_integer():
    _pos_int_value = input("Enter positive integer: ")
    while int(_pos_int_value) < 1:
        _pos_int_value = input("Enter positive integer: ")
    return int(_pos_int_value)

# Join list elements of a list to a single integer
def conv_list_to_int(list):
    _string_list = [str(i) for i in list]
    _int_list = int("".join(_string_list))
    return _int_list

# Join list elements of a list to a single bit vector
def merge_intlist_to_string(list):
    _conv_tostring_list = [str(i) for i in list]
    _merged_string_list = "".join(_conv_tostring_list)
    return _merged_string_list

# Convert bitstring to hexnumber
def conv_intlist_to_hexnumber(list):
    _conv_tostring_list = [str(i) for i in list]
    _merged_hexnumber = format(int("".join(_conv_tostring_list)), 'x')
    return _merged_hexnumber

# Define bitwise XOR gate
def function_bit_xor(a, b):
    if(a == b):
        return 0
    else:
        return 1

# Define bitwise AND gate
def function_bit_and(a, b):
    if((a == 1) & (b == 1)):
        return 1
    else:
        return 0

# Define XOR over some bit vector
def function_list_xor(list_a, list_b):
    if (len(list_a) != len(list_b)):
        print('ERROR in "function_list_xor": Length of the lists sent to the function are not equal. Return 3.')
        sys.exit(2)
    
    _list_out = []
    for i in range(0, len(list_a)):
        if(list_a[i] == list_b[i]):
            _list_out.append(0)
        else:
            _list_out.append(1)
    return _list_out

# Function assessing the result after decryption of A1 and A2
def transaction_status(bit_a1, bit_a2):
    if (bit_a1 == bit_a2):
        return 1
    else:
        return 0

# Function which sums all elements of GF in a list
def sum_gf_elements(array_of_gfelements):

    _array_of_gfelements = array_of_gfelements
    _array_added_gfelements = [0]*len(_array_of_gfelements[0])
    # _array_added_gfelements = [[0]*len(_array_of_gfelements[0]) for _u in range(len(_array_of_gfelements)+1)]

    # print(len(_array_of_gfelements))
    # print(_array_of_gfelements)
    # print(_array_added_gfelements)

    _cnt = 0
    if (len(_array_of_gfelements) < 2):
        print('ERROR in "sum_gf_elements": there must be two or more GF elements in the "_array_of_gfelements".')
        sys.exit(2)

    else:
        for _a in range(len(array_of_gfelements)):
            _array_added_gfelements = function_list_xor(_array_of_gfelements[_a], _array_added_gfelements)
            # print(_cnt, _array_added_gfelements)
            _cnt += 1

    # print('_array_of_gfelements: ', _array_of_gfelements)
    # print('_array_added_gfelements: ', _array_added_gfelements)

    return _array_added_gfelements




# GF(2^m) multiplier
def function_gf_multiply(symbol_width, _list_prim_poly, list_symbol_a, list_symbol_b):

    # GF multiplier
    _list_symbol_a = mirror_list(list_symbol_a)
    _list_symbol_b = mirror_list(list_symbol_b)
    _list_primpoly = mirror_list(_list_prim_poly)
    _mul = [0]*(symbol_width*2-2  +1) # watch out, +1 won't be in SystemVerilog
    _mod = [0]*(symbol_width*2-2  +1) # watch out, +1 won't be in SystemVerilog
    _orders = [*range(0, symbol_width*2-2  +1)] #watch out, +1 won't be in SystemVerilog
    # print('list_symbol_a: ', list_symbol_a)
    # print('list_symbol_b: ', list_symbol_b)
    # print('_mul init: ', _mul)
    for i in range(0, symbol_width):
        # print('_mul: ', _mul)
        if(_list_symbol_b[i] == 1):
            for u in range(0, symbol_width):
                # print(_mul, (symbol_width-1)+i-u, (symbol_width-1)-u)
                # _mul[(symbol_width-1)+i-u] = function_bit_xor(_mul[(symbol_width-1)+i-u], list_symbol_a[(symbol_width-1)-u])
                _mul[(symbol_width-1)+i-u] = function_bit_xor(_mul[(symbol_width-1)+i-u], _list_symbol_a[(symbol_width-1)-u])
    # print('_mul last: ', _mul)

    # GF modulo
    # print('_____ modulo: _____')
    for i in range((symbol_width-1)*2, symbol_width-1, -1):
        # print('_mod: ', _mul)
        if(_mul[i] == 1):
            for u in range(0, symbol_width + 1):
                # print(_mul, i-u, (symbol_width)-u)
                _mul[i-u] = function_bit_xor(_mul[i-u], _list_primpoly[(symbol_width)-u])
    # print('_mod last: ', _mul)

    # Prepare output    
    _list_gfmult_result = [0] * symbol_width
    for i in range(0, symbol_width):
        _list_gfmult_result[i] = _mul[i]

    # return _mirror_result_gfmul
    return mirror_list(_list_gfmult_result)


# Function creating a galois field 2^m
# element alpha_0 = _gf_elements_mirrored_bucketlist[1] in a binary list form
#      000              000
#      001              10
#      010              01
#     (100) xor 111    (00) xor 11
#      011              11
#     (110) xor 111
#      001
#      010
#     (100) xor 111
#      011
def function_gf_generator(symbol_width, _list_prim_poly, list_symbol_seed):

    _list_prim_poly_mirrored = mirror_list(_list_prim_poly)

    # Declarations of matrices
    _gf_elements_bucketlist = [[0] * symbol_width for i in range(pow(2, symbol_width))]
    _gf_elements_mirrored_bucketlist = [[0] * symbol_width for i in range(pow(2, symbol_width))]

    # Always zeros at [0]
    _gf_elements_bucketlist[0] = [0] * symbol_width

    # Based on the previous element calculate the next one
    _gf_elements_bucketlist[1] = mirror_list(list_symbol_seed)

    # Generate the field
    for _i in range(2, pow(2, symbol_width)):
        if (_gf_elements_bucketlist[_i-1][symbol_width-1] == 1):

            # Shift left (in python shift right)
            for u in range(1, symbol_width):
                _gf_elements_bucketlist[_i][u] = _gf_elements_bucketlist[_i-1][u-1]
            _gf_elements_bucketlist[_i][0] = 0

            # XOR
            for u in range(0, symbol_width):
                _gf_elements_bucketlist[_i][u] = function_bit_xor(_gf_elements_bucketlist[_i][u], _list_prim_poly_mirrored[u])
        else:
            # Shift left (in python shift right)
            for u in range(1, symbol_width):
                _gf_elements_bucketlist[_i][u] = _gf_elements_bucketlist[_i-1][u-1]
            _gf_elements_bucketlist[_i][0] = 0

    # Mirror the element elements and store it to the list with previous GF elements
    for _v in range(1, pow(2, symbol_width)):
        _gf_elements_mirrored_bucketlist[_v] = mirror_list(_gf_elements_bucketlist[_v])

    return _gf_elements_mirrored_bucketlist



# Function creating an inversed galois field 2^m
# element alpha_0^(-1) = _gf_elements_inversed_bucketlist[1] in a binary list form
def function_gf_inversed_generator(symbol_width, _list_prim_poly, list_symbol_seed):

    _list_prim_poly_mirrored = mirror_list(_list_prim_poly)

    # Declarations of matrices
    _gf_elements_bucketlist = [[0] * symbol_width for i in range(pow(2, symbol_width))]
    _gf_elements_mirrored_bucketlist = [[0] * symbol_width for i in range(pow(2, symbol_width))]
    _gf_elements_inversed_bucketlist = [[0] * symbol_width for i in range(pow(2, symbol_width))]

    # Always zeros at [0]
    _gf_elements_bucketlist[0] = [0] * symbol_width

    # Based on the previous element calculate the next one
    _gf_elements_bucketlist[1] = mirror_list(list_symbol_seed)

    # Generate the field
    for _i in range(2, pow(2, symbol_width)):
        if (_gf_elements_bucketlist[_i-1][symbol_width-1] == 1):

            # Shift left (in python shift right)
            for u in range(1, symbol_width):
                _gf_elements_bucketlist[_i][u] = _gf_elements_bucketlist[_i-1][u-1]

            # XOR
            for u in range(0, symbol_width):
                _gf_elements_bucketlist[_i][u] = function_bit_xor(_gf_elements_bucketlist[_i][u], _list_prim_poly_mirrored[u])
        else:
            # Shift left (in python shift right)
            for u in range(1, symbol_width):
                _gf_elements_bucketlist[_i][u] = _gf_elements_bucketlist[_i-1][u-1]

    # Mirror the element elements and store it to the list with previous GF elements
    for _v in range(1, pow(2, symbol_width)):
        _gf_elements_mirrored_bucketlist[_v] = mirror_list(_gf_elements_bucketlist[_v])

    # Create Inversed Galois Field with Multiplicative Inverses to each respective GF element
    for _w in range(1, pow(2, symbol_width)):
        _gf_elements_inversed_bucketlist[(pow(2, symbol_width))-_w] = mirror_list(_gf_elements_mirrored_bucketlist[_w])

    return _gf_elements_inversed_bucketlist


# LFSM type 1: Characteristic matrix A 
# (WARRNING! DO NOT FORGET THAT THE INITIAL VALUES FOR _matrix_a MIGHT BE DIFFERENT FOR DIFFERENT FOR DIFFERENT
# PRIMITIVE POLYNOMIALS - NOT SURE)
def char_matrix_a_lfsm1(symbol_width, _list_prim_poly):

    _matrix_a = []
    _matrix_a_mirrored_lines = []
    _matrix_a_mirrored = []
    _line = []
    _line_mirrored = []
    # print(list_prim_poly)

    # first line
    for _i in range(0, symbol_width-1):
        _line.append(0)
    _line.append(_list_prim_poly[0])
    _line_mirrored = mirror_list(_line)
    # print(_line)
    # print(_line_mirrored)

    # add the first line to the resultant characteristic matrix A
    _matrix_a_mirrored_lines.append(_line_mirrored)

    # generate remaining lines
    for _i in range (0, symbol_width-1):

        # renew
        _line[_i] = 1
        _line[symbol_width-1] = _list_prim_poly[_i+1]
        _line_mirrored = mirror_list(_line)
        _matrix_a_mirrored_lines.append(_line_mirrored)

        # clean
        _line[_i] = 0

    # print('----- Characteristic Matrix A (LFSM Type 1) -----')
    # print(mirror_list(_matrix_a_mirrored_lines))

    return mirror_list(_matrix_a_mirrored_lines)

# LFSM type 1: Characteristic matrix B
def char_matrix_b_lfsm1(symbol_width):

    _matrix_b = []
    _matrix_b.append(1)

    for _i in range(0, symbol_width-1):
        _matrix_b.append(0)

    return mirror_list(_matrix_b)



# Matrix Multiplication in GF(2)
def bitwise_matrix_multiply(matrix_a, matrix_b):

    _matrices_multiplied = []
    for _i in range(len(matrix_a)):

        _row = []
        for _j in range(len(matrix_b[0])):

            _product_row_bin = 0
            for _k in range(len(matrix_a[_i])):
                # Bitwise Calculation
                _and_two_elements = function_bit_and(matrix_a[_i][_k], matrix_b[_k][_j])
                # print(_and_two_elements)
                _product_row_bin = function_bit_xor(_product_row_bin, _and_two_elements)
                # print(_product_row_bin)

            # New Element Calculated
            _row.append(_product_row_bin)

        # New Row Calculated
        _matrices_multiplied.append(_row)
        # print(_matrices_multiplied)

    # print(_matrices_multiplied)

    return _matrices_multiplied




# Matrix Multiplication in GF(2^m)
# POSSIBLE ERROR/MISTAKE
def symbol_matrix_multiply(_symbol_width, _list_prim_poly, matrix_a, matrix_b):

    # print('_symbol_width_smm: ', _symbol_width)
    # print('matrix_a_smm', matrix_a)
    # print('matrix_b_smm', matrix_b)
    _matrices_multiplied = []
    _cnt = 0
    _cnt_row_sym = 0
    _gfmult_two_elements = []
    _product_row_symbol = []
    for _i in range(len(matrix_a)):

        # _row_symbols = [[]*_symbol_width]
        _row_symbols = []
        for _j in range(len(matrix_b[0])):

            _product_row_symbol.append([0 for i in range(_symbol_width)])
            # print('_product_row_symbol: ', _product_row_symbol)
            for _k in range(len(matrix_a[_i])):
                # Symbol-based Calculation                
                _gfmult_two_elements.append(function_gf_multiply(_symbol_width, _list_prim_poly, matrix_a[_i][_k], matrix_b[_k][_j]))
                # print(matrix_a[_i][_k], 'x', matrix_b[_k][_j], '=', _gfmult_two_elements[_cnt])
                _product_row_symbol[_cnt_row_sym] = function_list_xor(_product_row_symbol[_cnt_row_sym], _gfmult_two_elements[_cnt])
                # print('_product_row_symbol[_cnt_row_sym]: ', _product_row_symbol[_cnt_row_sym])
                # print('_gfmult_two_elements: ', _gfmult_two_elements, '    _product_row_bin_symbol: ', _product_row_bin_symbol)

                _cnt += 1
            # New Element Calculated
            _row_symbols.append(_product_row_symbol[_cnt_row_sym])
            _cnt_row_sym += 1
            # print('----- _row_symbols: ' ,_row_symbols)

        # New Row Calculated
        _matrices_multiplied.append(_row_symbols)
        # print(_matrices_multiplied)

    # print('_matrices_multiplied: ', _matrices_multiplied)

    return _matrices_multiplied




# Multiply two matrices with integers as values
def matrix_multiply(matrix_a, matrix_b):

    _matrices_multiplied = []
    for _i in range(len(matrix_a)):

        _row = []
        for _j in range(len(matrix_b[0])):

            _product_row = 0
            for _k in range(len(matrix_a[_i])):
                # Classical Arithmetics
                _product_row = _product_row + (matrix_a[_i][_k] * matrix_b[_k][_j])

            # New Element Calculated
            _row.append(_product_row)

        # New Row Calculated
        _matrices_multiplied.append(_row)

    # print(_matrices_multiplied)

    return _matrices_multiplied


# Calculate multiplication of Matrix[][] x Array[]
# TO DO:
def matrix_multiply_array(matrix, vector):

    _vector_multiplied = []
    for _i in range(len(matrix)):

        _row = []
        # for _j in range(len(vector)):
        for _j in range(1):

            _product_row_bin = 0
            for _k in range(len(matrix[_i])):
                # Bitwise Calculation
                _and_two_elements = function_bit_and(matrix[_i][_k], vector[_k])
                # print(_and_two_elements)
                _product_row_bin = function_bit_xor(_product_row_bin, _and_two_elements)
                # print(_product_row_bin)

            # New Element Calculated
            # _row.append(_product_row_bin) previously uncommented

        # New Row Calculated
        # _vector_multiplied.append(_row) previously uncommented
        _vector_multiplied.append(_product_row_bin) # previously commented
        # print(_vector_multiplied)

    # print(_vector_multiplied)

    return _vector_multiplied


# Calculate multiplication of Matrix[][] of symbols x Array[] of symbols
def matrix_multiply_array_symbols(_symbol_width, _list_prim_poly, matrix, vector):

    # _vector_multiplied = []
    # for _i in range(len(matrix)):

    #     _row = []
    #     # for _j in range(len(vector)):
    #     for _j in range(1):

    #         _product_row_bin = 0
    #         for _k in range(len(matrix[_i])):
    #             # Bitwise Calculation
    #             _and_two_elements = function_bit_and(matrix[_i][_k], vector[_k])
    #             # print(_and_two_elements)
    #             _product_row_bin = function_bit_xor(_product_row_bin, _and_two_elements)
    #             # print(_product_row_bin)

    #         # New Element Calculated
    #         # _row.append(_product_row_bin) previously uncommented

    #     # New Row Calculated
    #     # _vector_multiplied.append(_row) previously uncommented
    #     _vector_multiplied.append(_product_row_bin) # previously commented
    #     # print(_vector_multiplied)

    # # print(_vector_multiplied)


    _matrices_multiplied = []
    _cnt_add = 0
    _cnt_mul = 0
    _cnt_row_sym = 0
    _gfmult_two_elements = []
    _product_row_symbol = []
    for _i in range(len(matrix)):

        _row_symbols = []
        _product_row_symbol.append([0 for i in range(_symbol_width)])
        _cnt_add += 1
        for _j in range(0, 1):

            for _k in range(len(matrix[_i])):
                # Symbol-based Calculation
                _gfmult_two_elements.append(function_gf_multiply(_symbol_width, _list_prim_poly, matrix[_i][_k], vector[_k]))

                # _product_row_symbol[_cnt_row_sym] = function_list_xor(_product_row_symbol[_cnt_row_sym], _gfmult_two_elements[_cnt])
                _product_row_symbol.append(function_list_xor(_product_row_symbol[_cnt_add-1], _gfmult_two_elements[_cnt_mul]))
            
                # print('multiplying ', matrix[_i][_k], 'with ', vector[_k], ' = ', function_gf_multiply(_symbol_width, _list_prim_poly, matrix[_i][_k], vector[_k]), ' => add immediately to prev added value: ', function_list_xor(_product_row_symbol[_cnt_add-1], _gfmult_two_elements[_cnt_mul]))
                
                _cnt_mul += 1
                _cnt_add += 1
            # New Element Calculated
            # _row_symbols.append(_product_row_symbol[_cnt_row_sym])
            _row_symbols.append(_product_row_symbol[_cnt_add-1])
            _cnt_row_sym += 1

        # New Row Calculated
        _matrices_multiplied.append(_row_symbols)
        # print('_product_row_symbol:', _product_row_symbol)
        # print("_matrices_multiplied", _matrices_multiplied)

    # print('_gfmult_two_elements:', _gfmult_two_elements)
    # print('_product_row_symbol:', _product_row_symbol)
    # print('_matrices_multiplied_symbols: ', _matrices_multiplied)

    return _matrices_multiplied




# Calculation of powers of a single binary matrix
def matrix_power(power, matrix):

    _matrix_power = []
    _matrix_power.append(bitwise_matrix_multiply(matrix, matrix))

    _cnt = 0
    for _i in range(0, power - 2):
        _cnt = _cnt + 1
        _matrix_power.append(bitwise_matrix_multiply(_matrix_power[_i], matrix))

    if (power == 2):
        return _matrix_power[0]
    else:
        return _matrix_power[_cnt]


# Calculation of powers of a single symbol-based matrix with elements as members of GF(2^m)
def matrix_power_symbols(_symbol_width, _power, _list_prim_poly, _matrix):

    _matrix_power = []
    # print('_symbol_width_mps: ', _symbol_width)
    # print('_power_mps: ', _power)
    # print('_list_prim_poly_mps: ', _matrix)
    # print('matrix_a_mps: ', _matrix)
    
    # _matrix of power 2 (squared):
    # symbol_matrix_multiply(_symbol_width, _list_prim_poly, matrix_a, matrix_b):
    _matrix_power.append(symbol_matrix_multiply(_symbol_width, _list_prim_poly, _matrix, _matrix))
    # print('matrix_a_squared: ' ,_matrix_power)

    # _matrix of power > 2:
    _cnt = 0
    for _i in range(0, _power - 2):
        _cnt = _cnt + 1
        _matrix_power.append(symbol_matrix_multiply(_symbol_width, _list_prim_poly, _matrix_power[_i], _matrix))

    if (_power == 2):
        return _matrix_power[0]
    else:
        return _matrix_power[_cnt]



# Multiply an array of GF elements by an array of GF elements (using a GF multiplier)
def gf_multiply_polys(symbol_width, _list_prim_poly, vector_a, vector_b):

    _orders_mult = []
    _result_mult = []
    _solve_multiplied = []
    _vector_a = mirror_list(vector_a)
    _vector_b = mirror_list(vector_b)


    for _i in range(0, len(_vector_a)):
        for _j in range(0, len(_vector_b)):
            _orders_mult.append((len(_vector_a)-1-_i) + (len(_vector_b)-1-_j))
            _result_mult.append(function_gf_multiply(symbol_width, _list_prim_poly, _vector_a[_i], _vector_b[_j]))

    # print(_orders_mult)
    # print('_result_mult: ' ,_result_mult)
    # find largest

    #TO DO: PUT THE SAME DEGREES ONE UNDER ANOTHER AND ADD THEM TOGETHER
    # _multiple_items_same_order = [[0] * (((len(_vector_a))-1) * (len(_vector_b)-1)-2)]
    # _final_result = []
    # _act_order = _orders_mult[0]
    # _element_cnt = 0
    # _cnt_elements = _orders_mult[0]*2
    # # print(_multiple_items_same_order)

    # 1. Determine which different nonzero orders are present in the vector _orders_mult and how many times
    # start from the highest order
    _highest_order = (len(_vector_a)-1) + (len(_vector_b)-1)
    _array_occurrances_orders = [[] for i in range((_highest_order + 1))]
    for _u in range(0, len(_orders_mult)):
        for _i in range(0, len(_orders_mult)):
            if (_u == _orders_mult[_i]):
                _array_occurrances_orders[_orders_mult[0]-_u].append(_i)
    # print('_array_occurrances_orders: ' ,_array_occurrances_orders)

    # 2. Add these elements together where needed
    # print(len(_array_occurrances_orders))

    _array_same_degrees_added = [[] for i in range(_highest_order + 1)]
    _list_merged_orders = [[]*1 for i in range(1)]
    _merged_cnt = 0
    for _i in range(0, len(_array_same_degrees_added)):
        if (len(_array_occurrances_orders[_i]) == []):
            _array_same_degrees_added[_i] = ([[0]*(symbol_width)])
        elif (len(_array_occurrances_orders[_i]) == 1):
            _array_same_degrees_added[_i] = flatten_list(_result_mult[_array_occurrances_orders[_i][0]])
        elif (len(_array_occurrances_orders[_i]) > 1):
            # _array_same_degrees_added[_i] = function_list_xor(_result_mult[_array_occurrances_orders[_i][0]], _result_mult[_array_occurrances_orders[_i][1]])
            for _k in range(len(_array_occurrances_orders[_i])):
                _list_merged_orders[_merged_cnt].append(_result_mult[_array_occurrances_orders[_i][_k]])
            _array_same_degrees_added[_i] = sum_gf_elements(_list_merged_orders[_merged_cnt])
            _list_merged_orders.append([])
            _merged_cnt += 1

        else:
            print('ERROR: Undefined state in function gf_multiply_polys. Break.')
            sys.exit(2)

            _array_same_degrees_added[_i] = function_list_xor(_result_mult[_array_occurrances_orders[_i][0]], _result_mult[_array_occurrances_orders[_i][1]])
        # TO DO: EXTEND IT FOR: (len(_array_occurrances_orders[_i]) > 2)

    # print('_orders_mult: ', _orders_mult)
    # print('_array_same_degrees_added: ' ,_array_same_degrees_added)


    return mirror_list(_array_same_degrees_added)


# Slice the input msg list_message_J of the CRC to create separated symbols
def msg_slice_in_symbols(symbol_width, msg_symbolwidth, list_in_msg):

    # Add new symbols if not divisible without remainder
    # _act_length_msg = len(list_in_msg)
    # _list_new_in_msg = list_in_msg
    # _cnt_new_bits_added = 0
    # if (msg_symbolwidth > len(_list_new_in_msg)/symbol_width):
    #     while ((msg_symbolwidth != len(_list_new_in_msg)/symbol_width) | (len(_list_new_in_msg) % symbol_width != 0)):
    #         _cnt_new_bits_added += 1
    #         _list_new_in_msg.insert(0, 0)
    
    # print('Added ', _cnt_new_bits_added, ' bits to the message.')
    # print('_list_new_in_msg: ', _list_new_in_msg)
    # print('The message now consists of ', int(len(_list_new_in_msg)/symbol_width), ' symbols.')

    # Create bucketlist
    _bucketlist_input = [[0] * symbol_width for i in range(msg_symbolwidth)]
    _cnt_bit = 0
    _cnt_element = 0
    for _i in range(0, len(list_in_msg)):
        if (_cnt_bit < symbol_width-1):
            _bucketlist_input[_cnt_element][_cnt_bit] = list_in_msg[_i]
            _cnt_bit += 1
        elif (_cnt_bit == symbol_width-1):
            if(_cnt_element <= (msg_symbolwidth-1)):
                _bucketlist_input[_cnt_element][_cnt_bit] = list_in_msg[_i]
            _cnt_bit = 0
            _cnt_element += 1

    # print('bucketlist in function: ', _bucketlist_input)

    return _bucketlist_input



# Slice the input array of symbols into separate tuples
# def msg_slice_in_tuples(_symbol_width, _msg_symbolwidth, _list_in_msg):
def msg_slice_in_tuples(_list_in_msg_symbols, _int_msg_tuple_symbols, _int_msg_tuples):

    # Create bucketlist
    # _bucketlist_input = [[0] * _symbol_width for i in range(_list_in_msg_symbols)]
    _bucketlist_tuples = [[] for i in range(_int_msg_tuples)]
    _result_vector_tuples = []
    _cnt_act_symbol = 0
    _cnt_act_tuple = 0
    for _ in range(0, len(_list_in_msg_symbols)):

        if (_cnt_act_symbol < (_int_msg_tuple_symbols - 1)):
            _bucketlist_tuples[_cnt_act_tuple].append(_list_in_msg_symbols[_])
            _cnt_act_symbol += 1
        elif (_cnt_act_symbol == (_int_msg_tuple_symbols - 1)):
            _bucketlist_tuples[_cnt_act_tuple].append(_list_in_msg_symbols[_])
            _cnt_act_symbol = 0
            _cnt_act_tuple += 1


    # print('_bucketlist_tuples: ', _bucketlist_tuples)

    return _bucketlist_tuples



# Calculate Generator Polynomial
def calculate_gen_pol(_int_symbol_width, _list_symbol_seed, _list_prim_poly, _int_parity_symbols_cnt):

    if (_int_parity_symbols_cnt < 2):
        print('ERROR: "_int_parity_symbols_cnt" must be larger than one to calculate Generator Polynomial. Break.')
        sys.exit(2)


    _gf = function_gf_generator(_int_symbol_width, _list_prim_poly, _list_symbol_seed)
    _bucketlist_factors_gfelements = [[0] * 2 for i in range(_int_parity_symbols_cnt)]
    _one = [0 for i in range(_int_symbol_width)]
    _one[_int_symbol_width-1] = 1
    # print(_bucketlist_factors_gfelements)

    # Initialize the bucketlist
    for _i in range(_int_parity_symbols_cnt):
        for _u in range(2):
            _bucketlist_factors_gfelements[_i][0] = _one
            _bucketlist_factors_gfelements[_i][1] = _gf[_i+1]
    # print(_bucketlist_factors_gfelements)


    # Multiply the initialized polynomials with each other
    _ = []
    _.append(gf_multiply_polys(_int_symbol_width, _list_prim_poly, _bucketlist_factors_gfelements[0], _bucketlist_factors_gfelements[1]))

    for _i in range(1, _int_parity_symbols_cnt-1):
        _.append(gf_multiply_polys(_int_symbol_width, _list_prim_poly, _[_i-1], _bucketlist_factors_gfelements[_i+1]))

    # print('_3: ', _[_int_parity_symbols_cnt-2])


    return _[_int_parity_symbols_cnt-2]


# Convert cygpath to classical path ()veriable forward/backslash
def conv_cygpath_to_path(_cygpath, _delimiter):
    _str = str(_cygpath)
    _str = _str.replace("/cygdrive/c/", "C:{}".format(_delimiter), 1)
    _str = _str.replace("/cygdrive/d/", "D:{}".format(_delimiter), 1)
    _str = _str.replace("/cygdrive/e/", "E:{}".format(_delimiter), 1)
    _str = _str.replace("/cygdrive/f/", "F:{}".format(_delimiter), 1)
    _str = _str.replace("/cygdrive/g/", "G:{}".format(_delimiter), 1)
    _str = _str.replace("/cygdrive/h/", "H:{}".format(_delimiter), 1)
    _str = _str.replace("/cygdrive/i/", "I:{}".format(_delimiter), 1)
    _str = _str.replace("/cygdrive/j/", "J:{}".format(_delimiter), 1)
    _str = _str.replace("/cygdrive/k/", "K:{}".format(_delimiter), 1)
    # print('PY: DEBUG: _cygpath = ', _cygpath)
    # print('PY: DEBUG: _str = ', _str)
    return _str