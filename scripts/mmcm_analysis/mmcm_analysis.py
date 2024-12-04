# This file serves for the generation of HDL MMCM core with the MMCM2_ADV primitive
# Note: - The file is used to go through all possible output frequencies for the best configuration 
#         and performence of the core
#       - This file was originally developed as a MMCM2_ADV Xilinx core calculator
#       - For more information, read more about how this file works in the following file:
#         https://www.xilinx.com/support/documents/user_guides/ug572-ultrascale-clocking.pdf#page=35&zoom=100,121,266

# For MMCM f_VCO and other MMC properties, see: https://docs.amd.com/v/u/en-US/ds182_Kintex_7_Data_Sheet

# Import libraries
from math import ceil, floor
from numpy import arange

def print_mmcm_parameters (
    f_vco_min_MHz = 600,
    f_vco_max_MHz = 1200,
    f_pfd_min_MHz = 10,
    f_pfd_max_MHz = 550,

    f_clkin1_MHz = 100,

    list_clkoutx_MHz = [
        0.0,
        0.0, 
        0.0,
        0.0, 
        0.0,
        0.0, 
        0.0],
    list_clkoutx_abs_tolerance_MHz = [
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0]):

    # print("PY: DEBUG: list_clkoutx_MHz = ", list_clkoutx_MHz)
    # print("PY: DEBUG: list_clkoutx_abs_tolerance_MHz = ", list_clkoutx_abs_tolerance_MHz)

    # Check if the list of tolerances has the same length
    listlen_clkoutx_MHz = len(list_clkoutx_MHz)
    if (len(list_clkoutx_abs_tolerance_MHz) != listlen_clkoutx_MHz):
        print("PY: ERROR: The numer of required frequencies and tolerances does not match.")
        return

    # Repeat for the desired number of outputs:
    filtered_list_clkoutx_MHz = []
    filtered_list_clkoutx_tolerances_MHz = []
    different_outputs = 0
    related_outputs = 0
    outputs_cnt = 0
    if ((listlen_clkoutx_MHz > 0) and (listlen_clkoutx_MHz < 8)):
        for f in range(listlen_clkoutx_MHz):
            if ((list_clkoutx_MHz[f] != 0.0) or (list_clkoutx_MHz[f] != 0)):
                outputs_cnt = outputs_cnt + 1
                filtered_list_clkoutx_MHz.append(list_clkoutx_MHz[f])
                filtered_list_clkoutx_tolerances_MHz.append(list_clkoutx_abs_tolerance_MHz[f])
            if(f > 0):
                # If frequencies are related, meaning their modulo is zero
                # Before:
                # if (list_clkoutx_MHz[0] != list_clkoutx_MHz[f]):
                #     different_outputs = different_outputs + 1

                # Now:
                # Divide in and out frequency and vice versa and estimate whether integer decrement can be used
                if (list_clkoutx_MHz[f] > 0.0):
                    if ((list_clkoutx_MHz[f] % list_clkoutx_MHz[0]) == 0.0):
                        related_outputs = related_outputs + 1
                    if ((list_clkoutx_MHz[0] % list_clkoutx_MHz[f]) == 0.0):
                        related_outputs = related_outputs + 1

    else:
        print("PY: ERROR: Invalid number of outputs inputted. Make sure you entered 1 to 7 output frequencies.")
        return
    # print("PY: DEBUG outputs_cnt = ", outputs_cnt)

    # print("PY: DEBUG: filtered_list_clkoutx_MHz = ", filtered_list_clkoutx_MHz)
    # print("PY: DEBUG: filtered_list_clkoutx_tolerances_MHz = ", filtered_list_clkoutx_tolerances_MHz)

    # Prepare the output list: 2d array
    list_output_params_and_status = [[False for i in range(9+3)] for j in range(outputs_cnt)]
    # print("PY: DEBUG list_output_params_and_status = ", list_output_params_and_status)

    # Set initial conditions
    set_d = False
    set_m = False
    set_d_to = 1
    set_m_to = 0
    outputs_found = 0
    actual_req_frequency = list_clkoutx_MHz[0]
    max_acceptable_absdifference_for_targetfreq = list_clkoutx_abs_tolerance_MHz[0]

    # Prerequisites for the MMCM2_ADV:
    # [Netlist 29-72] Incorrect value '118.750000' specified for property 'CLKFBOUT_MULT_F'. 
    # Expecting type 'double' with possible values of '2 to 64'. 
    # The system will either use the default value or the property value will be dropped. 
    # Please verify your source files
    range_max_multiply = 64
    range_max_output_divide = 128
    decrement_output_divide = 0.125
    
    # If all output frequencies are equal or their modulo is zero, the decrement output divide will be integer, not float
    # Before: (uncomment lines 61, 62)
    # if (different_outputs != 0):
    #     decrement_output_divide = 1
    # After
    if (related_outputs != 0):
        decrement_output_divide = 1

    # Set the following boolean values
    # Set to True if you want to stop the search after the first acceptable found or exactfreq
    stop_after_first_acceptable = False
    # stop_after_first_exactfeq = True
    stop_after_first_exactfeq = False
    # Set to True only if the best phase offset granularity.precision is required (TODO)

    
    max_acceptable_absdifference_for_targetfreq = list_clkoutx_abs_tolerance_MHz[0]

    # ----- Do not touch: Variables for selecting the best and closest target frequency -----
    decrement_master_multiply = 0.125
    f_clkout_MHz_closest_freq_absdifference = 999999
    f_clkout_MHz_closest_freq = 0
    f_clkout_MHz_closest_freq_vcofreq = 0
    f_clkout_MHz_closest_freq_d = 0
    f_clkout_MHz_closest_freq_m = 0
    f_clkout_MHz_closest_freq_o = 0
    found_best_exactfreq = [False for i in range(outputs_cnt)] # Will be set to True if the first acceptable is found
    found_best_acceptable = [False for i in range(outputs_cnt)] # Will be set to True if the out frequency exactly matches the desired frequency
    found_closest_possible = [False for i in range(outputs_cnt)] # Will be set to True if the max iteration in the 'o' for loop is reached
    f_clkout_MHz_minoffset_deg = 999999
    f_clkout_MHz_minoffset_freq_vcofreq = 0


    # ----- Procedure -----
    # Master division value (1-106)
    master_divide_absmin = ceil(f_clkin1_MHz/f_pfd_max_MHz)
    master_divide_absmax = floor(f_clkin1_MHz/f_pfd_min_MHz)
    print("PY: DIVCLK_DIVIDE_absmin = ", master_divide_absmin)
    print("PY: DIVCLK_DIVIDE_absmax = ", master_divide_absmax)

    # Print out the ideal master multiply value
    # Multiply value for all CLKOUTx (2.000-64.000).
    # master_multiply_absmin = ceil(master_divide_absmin * f_vco_min_MHz/f_clkin1_MHz)
    # master_multiply_absmax = floor(master_divide_absmax * f_vco_max_MHz/f_clkin1_MHz)
    # print("PY: master_multiply_absmin = ", master_multiply_absmin)
    # print("PY: master_multiply_absmax = ", master_multiply_absmax)

    if(outputs_cnt > 0):
        d = master_divide_absmin
        while (d <= master_divide_absmax):
            # for d in range(master_divide_absmin, master_divide_absmax+1):
            # print("PY: LOOP d = ", d)
            master_multiply_currentmin = d * f_vco_min_MHz/f_clkin1_MHz
            master_multiply_currentmin = ceil(master_multiply_currentmin/0.125) * 0.125
            master_multiply_currentmax = d * f_vco_max_MHz/f_clkin1_MHz
            master_multiply_currentmax = floor(master_multiply_currentmax/0.125) * 0.125

            # print("DEBUG = master_multiply_currentmin = ", master_multiply_currentmin)
            # print("DEBUG = master_multiply_currentmax = ", master_multiply_currentmax)
            m = master_multiply_currentmax

            # Correct if the 'master_multiply_currentmax' the allowed range
            if (master_multiply_currentmax > range_max_multiply):
                m = range_max_multiply

            # while (m > master_multiply_currentmin-decrement_master_multiply):
            while (m > master_multiply_currentmin-decrement_master_multiply):
                # print("PY: LOOP m = ", m)

                o = range_max_output_divide
                while (o > 1-decrement_output_divide):
                    # print("PY: LOOP o = ", o)

                    # for m in arange(master_multiply_currentmax, master_multiply_currentmin-decrement_master_multiply, -decrement_master_multiply):
                    f_clkout_MHz_actual_vcofreq = f_clkin1_MHz * (m/d)
                    f_clkout_MHz_actual_vcofreq = float(f'{f_clkout_MHz_actual_vcofreq:.9f}')
                    f_clkout_MHz_static_phase_shift_ps = (1 / (8 * f_clkout_MHz_actual_vcofreq)) * 1000000
                    f_clkout_MHz_static_phase_shift_ns = (1 / (8 * f_clkout_MHz_actual_vcofreq)) * 1000
                    f_clkout_MHz_static_phase_shift_ps = float(f'{f_clkout_MHz_static_phase_shift_ps:.9f}')

                    # Check whether the VCO frequency is within the acceptable range
                    if ((f_clkout_MHz_actual_vcofreq > f_vco_max_MHz) or (f_clkout_MHz_actual_vcofreq < f_vco_min_MHz)):
                        print("PY: ERROR: m,d = ", m, " ", d,)
                        print("PY: ERROR: actual VCO Freq is higher or lower than allowed values; f_clkout_MHz_actual_vcofreq = ", f_clkout_MHz_actual_vcofreq)
                        return

                    # print("PY: DEBUG o = ", o)
                    # for o in arange(range_max_output_divide, 1-decrement_output_divide, -decrement_output_divide):
                    # Calculate VCO freq and the Output freq
                    f_actual_m = float(f'{m:.9f}')
                    f_actual_o = float(f'{o:.9f}')
                    f_clkout_MHz_actual_freq = f_clkout_MHz_actual_vcofreq / o
                    f_clkout_MHz_actual_freq = float(f'{f_clkout_MHz_actual_freq:.9f}')
                    f_clkout_MHz_actual_freq_absdifference_targetfreq = abs(f_clkout_MHz_actual_freq - actual_req_frequency)
                    f_clkout_MHz_actual_freq_absdifference_targetfreq = float(f'{f_clkout_MHz_actual_freq_absdifference_targetfreq:.9f}')
                    f_clkout_MHz_actual_static_phase_offset_deg = (45/f_actual_o)
                    f_clkout_MHz_actual_static_phase_offset_deg = float(f'{f_clkout_MHz_actual_static_phase_offset_deg:.9f}')

                    # Try to find the closest possible frequency throughout the entire search
                    if(f_clkout_MHz_closest_freq_absdifference > f_clkout_MHz_actual_freq_absdifference_targetfreq):
                        f_clkout_MHz_closest_freq_absdifference = float(f'{f_clkout_MHz_actual_freq_absdifference_targetfreq:.9f}')
                        f_clkout_MHz_closest_static_phase_shift_ps = f_clkout_MHz_static_phase_shift_ps
                        f_clkout_MHz_closest_static_phase_shift_ps = float(f'{f_clkout_MHz_closest_static_phase_shift_ps:.9f}')
                        f_clkout_MHz_closest_static_phase_offset_deg = f_clkout_MHz_actual_static_phase_offset_deg
                        f_clkout_MHz_closest_static_phase_offset_deg = float(f'{f_clkout_MHz_closest_static_phase_offset_deg:.9f}')
                        f_clkout_MHz_closest_freq = float(f'{f_clkout_MHz_actual_freq:.9f}')
                        f_clkout_MHz_closest_freq_vcofreq = float(f'{f_clkout_MHz_actual_vcofreq:.9f}')
                        f_clkout_MHz_closest_freq_d = d
                        f_clkout_MHz_closest_freq_m = f_actual_m
                        f_clkout_MHz_closest_freq_o = f_actual_o

                    # If the output freq is not within the range specified, but is within some tolerance:
                    if(f_clkout_MHz_actual_freq_absdifference_targetfreq <= max_acceptable_absdifference_for_targetfreq):
                        # If best M,D,O values found for the exact target frequency
                        if (f_clkout_MHz_actual_freq_absdifference_targetfreq == 0):
                            if (found_best_exactfreq[outputs_found] == True):
                                print("PY: --------------------------------------------------------------------------------------------")
                                print("PY: INFO: M,D,O values for the EXACT target frequency with requirements: ", actual_req_frequency, " MHz")
                                pass
                            else:
                                found_best_exactfreq[outputs_found] = True
                                print("PY: --------------------------------------------------------------------------------------------")
                                print("PY: INFO: BEST M,D,O values for the EXACT target frequency with requirements: ", actual_req_frequency, " MHz")
                        else:
                            # If acceptable M,D,O values found for the desired frequency
                            if (found_best_acceptable[outputs_found] == True):
                                print("PY: --------------------------------------------------------------------------------------------")
                                print("PY: INFO: M,D,O values for the APPROXIMATE target frequency with requirements: ", actual_req_frequency, " ± ", max_acceptable_absdifference_for_targetfreq, " MHz")
                                pass
                            else:
                                found_best_acceptable[outputs_found] = True
                                print("PY: --------------------------------------------------------------------------------------------")
                                print("PY: INFO: BEST M,D,O values for the APPROXIMATE target frequency with requirements: ", actual_req_frequency, " ± ", max_acceptable_absdifference_for_targetfreq, " MHz")

                        # Try to find parameters M,D,O for the finiest possible offset throughout the entire search
                        if(f_clkout_MHz_minoffset_deg > f_clkout_MHz_actual_static_phase_offset_deg):
                        # if(f_clkout_MHz_actual_vcofreq > f_clkout_MHz_minoffset_freq_vcofreq):
                            f_clkout_MHz_minoffset_deg = f_clkout_MHz_actual_static_phase_offset_deg
                            f_clkout_MHz_minoffset_freq_absdifference = float(f'{f_clkout_MHz_actual_freq_absdifference_targetfreq:.9f}')
                            f_clkout_MHz_minoffset_static_phase_shift_ps = f_clkout_MHz_static_phase_shift_ps
                            f_clkout_MHz_minoffset_static_phase_shift_ps = float(f'{f_clkout_MHz_closest_static_phase_shift_ps:.9f}')
                            f_clkout_MHz_minoffset_static_phase_offset_deg = f_clkout_MHz_actual_static_phase_offset_deg
                            f_clkout_MHz_minoffset_static_phase_offset_deg = float(f'{f_clkout_MHz_closest_static_phase_offset_deg:.9f}')
                            f_clkout_MHz_minoffset_freq = float(f'{f_clkout_MHz_actual_freq:.9f}')
                            f_clkout_MHz_minoffset_freq_vcofreq = float(f'{f_clkout_MHz_actual_vcofreq:.9f}')
                            f_clkout_MHz_minoffset_freq_d = d
                            f_clkout_MHz_minoffset_freq_m = f_actual_m
                            f_clkout_MHz_minoffset_freq_o = f_actual_o

                        # Print out the actual values
                        print("PY:       CLKOUTx (MHz)                = ", f_clkout_MHz_actual_freq)
                        print("PY:       CLKFBOUT_MULT_F              = ", f_actual_m)
                        print("PY:       DIVCLK_DIVIDE                = ", d)
                        print("PY:       CLKOUTx_DIVIDE(_F)           = ", f_actual_o)
                        print("PY:         *VCO Frequency             = ", f_clkout_MHz_actual_vcofreq)
                        print("PY:         *MHz to Target Frequency   = ", f_clkout_MHz_actual_freq_absdifference_targetfreq)
                        print("PY:         *Static Phase Shift (ps)   = ", f_clkout_MHz_static_phase_shift_ps)
                        print("PY:         *Static Phase Offset (deg) = integer multiple of ", f_clkout_MHz_actual_static_phase_offset_deg)

                        # Save status and output values
                        list_output_params_and_status[outputs_found][0] = found_best_exactfreq[outputs_found]
                        list_output_params_and_status[outputs_found][1] = found_best_acceptable[outputs_found]
                        list_output_params_and_status[outputs_found][2] = found_closest_possible[outputs_found]

                        list_output_params_and_status[outputs_found][3] = list_clkoutx_MHz[outputs_found]
                        list_output_params_and_status[outputs_found][4] = f_clkout_MHz_actual_freq
                        list_output_params_and_status[outputs_found][5] = f_clkout_MHz_actual_freq_absdifference_targetfreq

                        list_output_params_and_status[outputs_found][6] = d
                        list_output_params_and_status[outputs_found][7] = f_actual_m
                        list_output_params_and_status[outputs_found][8] = f_actual_o

                        list_output_params_and_status[outputs_found][9] = f_clkout_MHz_actual_vcofreq

                        list_output_params_and_status[outputs_found][10] = f_clkout_MHz_static_phase_shift_ps
                        list_output_params_and_status[outputs_found][11] = f_clkout_MHz_actual_static_phase_offset_deg

                    # Break on acceptable or exactfreq requirement
                    if(stop_after_first_acceptable or stop_after_first_exactfeq):
                        if(found_best_acceptable[outputs_found] or found_best_exactfreq[outputs_found]):

                            outputs_found = outputs_found + 1
                            # print("PY: outputs_found 1= ", outputs_found)

                            # Reset the given signals if success
                            if(outputs_found < outputs_cnt):
                                # Start searching for Out+1 frequency, keep the D and M counters
                                # print("PY: DEBUG outputs_found = ", outputs_found)
                                # print("PY: DEBUG outputs_cnt = ", outputs_cnt)

                                actual_req_frequency = filtered_list_clkoutx_MHz[outputs_found]
                                max_acceptable_absdifference_for_targetfreq = filtered_list_clkoutx_tolerances_MHz[outputs_found]

                                #  Only the first output supports fractional output divide, the others not!
                                decrement_output_divide = 1

                                # Reset other values:
                                f_clkout_MHz_minoffset_deg = 999999
                                f_clkout_MHz_closest_freq_absdifference = 999999

                                # Reset the 'o' counter if success
                                o = range_max_output_divide + decrement_output_divide

                                # Lock the other counters to the current val
                                # master_multiply_currentmin = f_actual_m
                                # master_multiply_currentmax = f_actual_m
                                # master_divide_absmin = d
                                # master_divide_absmax = d

                                # Reset the 'found' flags for the current frequency search
                                # found_best_acceptable = False
                                # found_best_exactfreq = False
                            else:
                                break

                    if((o == 1) or (o == 1.0)):
                        if(outputs_found > 0):
                            found_closest_possible[outputs_found] = True
                            # print("PY: outputs_found 2= ", outputs_found)
                            # Print the closest freq if requirements not met
                            print("PY: --------------------------------------------------------------------------------------------")
                            print("PY: INFO: Closest M,D,O values found to synthesize the desired frequency with requirements: ", actual_req_frequency, " ± ", max_acceptable_absdifference_for_targetfreq, " MHz")
                            print("PY:       CLKOUTx (MHz)                = ", f_clkout_MHz_closest_freq)
                            print("PY:       CLKFBOUT_MULT_F              = ", f_clkout_MHz_closest_freq_m)
                            print("PY:       DIVCLK_DIVIDE                = ", f_clkout_MHz_closest_freq_d)
                            print("PY:       CLKOUTx_DIVIDE(_F)           = ", f_clkout_MHz_closest_freq_o)
                            print("PY:         *VCO Frequency             = ", f_clkout_MHz_closest_freq_vcofreq)
                            print("PY:         *MHz to Target Frequency   = ", f_clkout_MHz_closest_freq_absdifference)
                            print("PY:         *Static Phase Shift (ps)   = ", f_clkout_MHz_closest_static_phase_shift_ps)
                            print("PY:         *Static Phase Offset (deg) = integer multiple of ", f_clkout_MHz_closest_static_phase_offset_deg)
                            print("PY: --------------------------------------------------------------------------------------------")

                            # Save status and output values
                            list_output_params_and_status[outputs_found][0] = found_best_exactfreq[outputs_found]
                            list_output_params_and_status[outputs_found][1] = found_best_acceptable[outputs_found]
                            list_output_params_and_status[outputs_found][2] = found_closest_possible[outputs_found]

                            list_output_params_and_status[outputs_found][3] = list_clkoutx_MHz[outputs_found]
                            list_output_params_and_status[outputs_found][4] = f_clkout_MHz_closest_freq
                            list_output_params_and_status[outputs_found][5] = f_clkout_MHz_closest_freq_absdifference

                            list_output_params_and_status[outputs_found][6] = f_clkout_MHz_closest_freq_d
                            list_output_params_and_status[outputs_found][7] = f_clkout_MHz_closest_freq_m
                            list_output_params_and_status[outputs_found][8] = f_clkout_MHz_closest_freq_o

                            list_output_params_and_status[outputs_found][9] = f_clkout_MHz_closest_freq_vcofreq

                            list_output_params_and_status[outputs_found][10] = f_clkout_MHz_closest_static_phase_shift_ps
                            list_output_params_and_status[outputs_found][11] = f_clkout_MHz_closest_static_phase_offset_deg

                            # Proceed with the next output
                            outputs_found = outputs_found + 1

                            # Reset the given signals if success
                            if(outputs_found < outputs_cnt):
                                # Start searching for Out+1 frequency, keep the D and M counters
                                # print("PY: DEBUG outputs_found = ", outputs_found)
                                # print("PY: DEBUG outputs_cnt = ", outputs_cnt)

                                actual_req_frequency = filtered_list_clkoutx_MHz[outputs_found]
                                max_acceptable_absdifference_for_targetfreq = filtered_list_clkoutx_tolerances_MHz[outputs_found]

                                #  Only the first output supports fractional output divide, the others not!
                                decrement_output_divide = 1

                                # Reset other values:
                                f_clkout_MHz_minoffset_deg = 999999
                                f_clkout_MHz_closest_freq_absdifference = 999999

                                # Reset the 'o' counter if success
                                o = range_max_output_divide + decrement_output_divide

                                # Lock the other counters to the current val
                                # master_multiply_currentmin = f_actual_m
                                # master_multiply_currentmax = f_actual_m
                                # master_divide_absmin = d
                                # master_divide_absmax = d

                                # Reset the 'found' flags for the current frequency search
                                # found_best_acceptable = False
                                # found_best_exactfreq = False

                        # If not able to find the M,D,O parameters for the first output with given requirements, print the following:
                        else:
                            # print("PY: mdo = ", m, " ", d)
                            # print("PY: max = ", master_multiply_currentmin, " ", master_divide_absmax)
                            if ((m == master_multiply_currentmin) and (d == master_divide_absmax)):
                                # print("PY: HERE")
                                # return
                                found_closest_possible[outputs_found] = True

                                print("PY: --------------------------------------------------------------------------------------------")
                                print("PY: INFO: FAILED to find M,D,O parameters for the desired frequency with requirements, but the closest are: ", actual_req_frequency, " ± ", max_acceptable_absdifference_for_targetfreq, " MHz")
                                print("PY:       CLKOUTx (MHz)                = ", f_clkout_MHz_closest_freq)
                                print("PY:       CLKFBOUT_MULT_F              = ", f_clkout_MHz_closest_freq_m)
                                print("PY:       DIVCLK_DIVIDE                = ", f_clkout_MHz_closest_freq_d)
                                print("PY:       CLKOUTx_DIVIDE(_F)           = ", f_clkout_MHz_closest_freq_o)
                                print("PY:         *VCO Frequency             = ", f_clkout_MHz_closest_freq_vcofreq)
                                print("PY:         *MHz to Target Frequency   = ", f_clkout_MHz_closest_freq_absdifference)
                                print("PY:         *Static Phase Shift (ps)   = ", f_clkout_MHz_closest_static_phase_shift_ps)
                                print("PY:         *Static Phase Offset (deg) = integer multiple of ", f_clkout_MHz_closest_static_phase_offset_deg)
                                print("PY: --------------------------------------------------------------------------------------------")
                                # Save status and output values
                                list_output_params_and_status[outputs_found][0] = found_best_exactfreq[outputs_found]
                                list_output_params_and_status[outputs_found][1] = found_best_acceptable[outputs_found]
                                list_output_params_and_status[outputs_found][2] = found_closest_possible[outputs_found]

                                list_output_params_and_status[outputs_found][3] = list_clkoutx_MHz[outputs_found]
                                list_output_params_and_status[outputs_found][4] = f_clkout_MHz_closest_freq
                                list_output_params_and_status[outputs_found][5] = f_clkout_MHz_closest_freq_absdifference

                                list_output_params_and_status[outputs_found][6] = f_clkout_MHz_closest_freq_d
                                list_output_params_and_status[outputs_found][7] = f_clkout_MHz_closest_freq_m
                                list_output_params_and_status[outputs_found][8] = f_clkout_MHz_closest_freq_o

                                list_output_params_and_status[outputs_found][9] = f_clkout_MHz_closest_freq_vcofreq

                                list_output_params_and_status[outputs_found][10] = f_clkout_MHz_closest_static_phase_shift_ps
                                list_output_params_and_status[outputs_found][11] = f_clkout_MHz_closest_static_phase_offset_deg

                                # Proceed with the next output
                                outputs_found = outputs_found + 1

                                # print("PY: outputs_found 3= ", outputs_found)

                                # Reset the given signals if success
                                if(outputs_found < outputs_cnt):
                                    # Start searching for Out+1 frequency, keep the D and M counters
                                    # print("PY: DEBUG outputs_found = ", outputs_found)
                                    # print("PY: DEBUG outputs_cnt = ", outputs_cnt)

                                    actual_req_frequency = filtered_list_clkoutx_MHz[outputs_found]
                                    max_acceptable_absdifference_for_targetfreq = filtered_list_clkoutx_tolerances_MHz[outputs_found]

                                    #  Only the first output supports fractional output divide, the others not!
                                    # decrement_output_divide = 1

                                    # Reset other values:
                                    f_clkout_MHz_minoffset_deg = 999999
                                    f_clkout_MHz_closest_freq_absdifference = 999999

                                    # Reset the 'o' counter if success
                                    o = range_max_output_divide + decrement_output_divide

                                    # # Modify the counters to find parameters for the remaining outputs
                                    set_d = True
                                    set_d_to = f_clkout_MHz_closest_freq_d
                                    d = f_clkout_MHz_closest_freq_d

                                    set_m = True
                                    set_m_to = f_clkout_MHz_closest_freq_m
                                    m = f_clkout_MHz_closest_freq_m

                                    # Lock the other counters to the current val
                                    # master_multiply_currentmin = f_actual_m
                                    # master_multiply_currentmax = f_actual_m
                                    # master_divide_absmin = d
                                    # master_divide_absmax = d

                                    # Reset the 'found' flags for the current frequency search
                                    # found_best_acceptable = False
                                    # found_best_exactfreq = False
                                else:
                                    break

                    # update the 'o' while loop variable
                    o = o - decrement_output_divide

                    # MMCM does not support values O within <1.125 and 1.875>
                    # Prevent these invalid values by jumping to the next nearest valid O
                    if (o >= (1+decrement_master_multiply)) and (o <= (2-decrement_master_multiply)):
                        # 'o' counts toward lower numbers, hence set 'o' to the next lower nearest valid O
                        o = 1.0



                # Break on acceptable or exactfreq requirement
                # print("PY: outputs_found 4= ", outputs_found)
                if set_m == True:
                    # print("PY: HERE1")
                    m = set_m_to
                    set_m = False
                else:

                    # Calculate next M
                    m = m - decrement_master_multiply

                # Causes crash if commented
                if(outputs_found >= outputs_cnt):
                    break
                else:
                    if(stop_after_first_acceptable or stop_after_first_exactfeq or found_closest_possible[outputs_found]):
                        if(found_best_acceptable[outputs_found] or found_best_exactfreq[outputs_found] or found_closest_possible[outputs_found]):
                            break


            # Break on acceptable or exactfreq requirement
            if set_d == True:
                # print("PY: HERE2")
                d = set_d_to
                set_d = False
            else:
                d = d + 1


            if(outputs_found >= outputs_cnt):
                break
            else:
                if(stop_after_first_acceptable or stop_after_first_exactfeq or found_closest_possible[outputs_found]):
                    if(found_best_acceptable[outputs_found] or found_best_exactfreq[outputs_found] or found_closest_possible[outputs_found]):
                        break


        # Print the closest freq if requirements not met
        # Break on acceptable or exactfreq requirement
        if((stop_after_first_acceptable == False) or (stop_after_first_exactfeq == False) or (found_closest_possible == False)):
            print("PY: --------------------------------------------------------------------------------------------")
            print("PY: INFO: Closest M,D,O values found to synthesize the desired frequency with requirements: ", actual_req_frequency, " ± ", max_acceptable_absdifference_for_targetfreq, " MHz")
            print("PY:       f_clkout_MHz_closest_freq                  = ", f_clkout_MHz_closest_freq)
            print("PY:       f_clkout_MHz_closest_freq_vcofreq          = ", f_clkout_MHz_closest_freq_vcofreq)
            print("PY:       f_clkout_MHz_closest_freq_d                = ", f_clkout_MHz_closest_freq_d)
            print("PY:       f_clkout_MHz_closest_freq_m                = ", f_clkout_MHz_closest_freq_m)
            print("PY:       f_clkout_MHz_closest_freq_o                = ", f_clkout_MHz_closest_freq_o)
            print("PY:       f_clkout_MHz_closest_freq_absdifference    = ", f_clkout_MHz_closest_freq_absdifference)
            print("PY:       f_clkout_MHz_closest_static_phase_shift_ps = ", f_clkout_MHz_closest_static_phase_shift_ps)
            print("PY:       f_clkout_MHz_closest_static_phase_offset   = ", f_clkout_MHz_closest_static_phase_offset_deg)
            print("PY: --------------------------------------------------------------------------------------------")

        if((found_best_exactfreq == True) or (found_best_acceptable == True)):
            print("PY: --------------------------------------------------------------------------------------------")
            print("PY: INFO: M,D,O values for the finiest phase offset fexibility for: ", actual_req_frequency, " ± ", max_acceptable_absdifference_for_targetfreq, " MHz")
            print("PY:       f_clkout_MHz_minoffset_freq                    = ", f_clkout_MHz_minoffset_freq)
            print("PY:       f_clkout_MHz_minoffset_freq_vcofreq            = ", f_clkout_MHz_minoffset_freq_vcofreq)
            print("PY:       f_clkout_MHz_minoffset_freq_d                  = ", f_clkout_MHz_minoffset_freq_d)
            print("PY:       f_clkout_MHz_minoffset_freq_m                  = ", f_clkout_MHz_minoffset_freq_m)
            print("PY:       f_clkout_MHz_minoffset_freq_o                  = ", f_clkout_MHz_minoffset_freq_o)
            print("PY:       f_clkout_MHz_minoffset_freq_absdifference      = ", f_clkout_MHz_minoffset_freq_absdifference)
            print("PY:       f_clkout_MHz_minoffset_static_phase_shift_ps   = ", f_clkout_MHz_minoffset_static_phase_shift_ps)
            print("PY:       f_clkout_MHz_minoffset_static_phase_offset_deg = ", f_clkout_MHz_minoffset_static_phase_offset_deg)
            print("PY: --------------------------------------------------------------------------------------------")
    else:
        print("PY: ERROR: Invalid number of outputs inputted. Make sure you entered 1 to 7 output frequencies.")
        return

    return list_output_params_and_status



# ----- Main -----

# ----- Min and Max VCO Values -----
# 1) Set the VCO operating range
# f_vco_min_MHz = 600
# f_vco_min_MHz = 1200
# f_vco_max_MHz = 1200
f_vco_min_MHz = 1200
f_vco_max_MHz = 1200

# 2) Set the Phase Frequecy Detector Operating Range
f_pfd_min_MHz = 10
f_pfd_max_MHz = 550


# ----- User Defined Variables -----
# Input Clock
f_clkin1_MHz = 200.000

# Tolerance for output clocks +/- (MHz)
list_clkoutx_abs_tolerance_MHz = [
    0.000,
    0.100,
    0.100,
    0.100,
    0.100,
    0.100,
    0.100
]

# Output clock (MHz)
# Try 250 MHz
list_clkoutx_MHz = [
    30.000,    # + Shift by 90 Degrees = 0.9 + 500 ps; 50% Duty Cycle = 0.5
    0.000,    # + Shift by 90 Degrees = 0.9; 50% Duty Cycle = 0.5
    0.000,
    0.000,
    0.000,
    0.000,
    0.000
]

list_output = print_mmcm_parameters(
    f_vco_min_MHz,
    f_vco_max_MHz,
    f_pfd_min_MHz,
    f_pfd_max_MHz,
    f_clkin1_MHz,
    list_clkoutx_MHz,
    list_clkoutx_abs_tolerance_MHz
)


# Print the output:
# Note: Items in the return list represent these values:
#    [x]     = Output no. 1, 2, ... configuration
#       [0]  = if True: Best Exact frequency found (Max VCO frequency preferred)
#       [1]  = if True: Best Approximate frequency found (within tolerance)(max VCO frequency preferred)
#       [2]  = if True: Closest frequency found (outside tolerance)(closest target frequency preferred)
#       [3]  = Desired frequency
#       [4]  = Found frequency
#       [5]  = MHz to target frequency (Absolute value)
#       [6]  = VCO freq divide (D)
#       [7]  = VCO freq multiply (M)
#       [8]  = Output divide (O)
#       [9]  = VCO Frequency based on the D and M value
#       [10] = Static Phase Shift (SPS) in ps
#       [11] = Static Phase Offset (deg): 1x value = SPS; Use integer multiples of this number

# print("PY: INFO: FAILED to find M,D,O parameters for the desired frequency with requirements, but the closest are: ", actual_req_frequency, " ± ", max_acceptable_absdifference_for_targetfreq, " MHz")
# print("PY:       CLKOUTx (MHz)                = ", f_clkout_MHz_closest_freq)
# print("PY:       CLKFBOUT_MULT_F              = ", f_clkout_MHz_closest_freq_m)
# print("PY:       DIVCLK_DIVIDE                = ", f_clkout_MHz_closest_freq_d)
# print("PY:       CLKOUTx_DIVIDE(_F)           = ", f_clkout_MHz_closest_freq_o)
# print("PY:         *VCO Frequency             = ", f_clkout_MHz_closest_freq_vcofreq)
# print("PY:         *MHz to Target Frequency   = ", f_clkout_MHz_closest_freq_absdifference)
# print("PY:         *Static Phase Shift (ps)   = ", f_clkout_MHz_closest_static_phase_shift_ps)
# print("PY:         *Static Phase Offset (deg) = integer multiple of ", f_clkout_MHz_closest_static_phase_offset_deg)

lrange = len(list_output)
print("PY: Output x : [Exact, Approx, Closest, Ftarget, Ffound, Adiff, D, M, O, F_VCO, SPS(ps), SPS(deg)]")
for i in range(lrange):
    print("PY: Output", i + 1, ":", list_output[i])


# Print script completed
print("PY: DONE.")