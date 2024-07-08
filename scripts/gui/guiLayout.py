# For using the correct python interpreter
# https://code.visualstudio.com/docs/python/python-tutorial

# To Get Zip Codes:
#   go to: https://docs.airnowapi.org/CurrentObservationsByZip/query
#   then set format:
#       application/json
#   click Build and copy Generated URL:
#   https://www.airnowapi.org/aq/observation/zipCode/current/?format=application/json&zipCode=20002&distance=25&API_KEY=564979D7-94C8-48EA-8792-389F060FC2E6

# Then Do this:
#   To be able to get data from APIs
#       pip install requests
#       import requests
#   To decode data in Json formate from APIs
#       import json

from tkinter import *
from tkinter import messagebox
import numpy as np
import matplotlib.pyplot as plt

from matplotlib.lines import Line2D
import matplotlib.animation as animation

import subprocess
import sys
import os

# A subclass of the redis-py Redis client.
from walrus import Database
import redis

import time
from time import sleep

from math import floor, ceil

import multiprocessing
import threading


# from numpy import *
from pyqtgraph.Qt import QtGui, QtCore
import pyqtgraph as pg
from random import randrange, uniform
# from PyQt6.QtWidgets import QMainWindow, QMessageBox, QApplication
from PyQt6.QtWidgets import *


def get_parameters_from_entryboxes():

    # Create Makefile Arguments for Building Design With Generic Parameters
    make_params = ""

    global entry_param_content
    entry_param_content = []
    
    for i in range(len(param_names)):
        entry_param_content.append(entry_box_param[i].get())
        print("entry_box_param[{}].get() = {}".format(i, entry_param_content[i]))
        make_params = make_params + " GEN" + str(i+1) + "_VAL="+str(entry_param_content[i])
        
    print("make_params = ", make_params)


    return make_params



def generate_hardware():

    # Recompile C++ files
    subprocess.Popen('make rescan', cwd="./scripts/gui/csv_readout", creationflags=subprocess.CREATE_NEW_CONSOLE)

    # Regenerate Hardware with or without arguments
    makefile_arguments = get_parameters_from_entryboxes()
    print("makefile_arguments = ", makefile_arguments)

    command_open_cmd = "start /wait cmd /k"
    command_make_1 = "reset" # type make only once!
    command_make_2 = "src"
    command_make_3 = "generics"
    command_make_4 = "all"
    command_make_5 = "timer"

    if makefile_arguments == "":
        os.system(
            # Do not change
            command_open_cmd + " make " +

            command_make_1 + " " +
            command_make_2 + " " +
            command_make_4 + " " +
            command_make_5
        )

    else:
        os.system(
            # Do not change
            command_open_cmd + " make " +

            command_make_1 + " " +
            command_make_2 + " " +
            command_make_3 + " " +
            command_make_4 + " " +
            command_make_5 + str(makefile_arguments)
        )

    # If bitfile has been successfully generated, call make command to copy it to the respective folders
    subprocess.Popen("make distribute_bitfiles", cwd=".")


# Run C++ Script using coommand line to start writing to the stream
def run_stream_write():
    subprocess.Popen("make run_release", cwd="./scripts/gui/csv_readout")
    return True





def start_redis_wait_until_valid_data(sleep_timeout_sec, sleep_timeout_counter_maxval):
    # Return where the stream ended
    # os.system('wsl.exe sudo service redis-server start')
    # os.system('wsl.exe sudo service redis-server stop')
    subprocess.Popen("make redis_start", cwd="./scripts/gui/csv_readout")
    try:
        redis_db = Database(host='localhost', port=6379, db=0)
        # redis_db = Database()
        myStream = redis_db.Stream('myStreamKey')
    
        # Initialize timer
        sleep_timeout_counter = 0

        # If there is not yet any stream, wait for it
        while (myStream.__len__() == 0):
            sleep(sleep_timeout_sec)
            sleep_timeout_counter += 1

            if sleep_timeout_counter == sleep_timeout_counter_maxval:
                response = messagebox.askyesno(
                    "Redis Server: Wait Timeout", 
                    "No data present in Redis server. Do you want to keep waiting?"
                )

                if response == 0:
                    return False

                # Reset timer, ask again
                sleep_timeout_counter = 0
    except redis.exceptions.ConnectionError:
        print("Error Handling: Redis Server has not started. Return False")
        return False
    
    return myStream


class ReadRedisStream():

    def __init__(self, pipe_write):
        
        # Prevent waiting for the stream for too long
        self.sleep_timeout_sec = 0.3
        self.sleep_timeout_counter_maxval = 30

        # Establish connection with Redis and send initial values to the pipe
        self.myStream = start_redis_wait_until_valid_data(self.sleep_timeout_sec, self.sleep_timeout_counter_maxval)
        if self.myStream == False:
            self.stream_items = []
            self.data_ready_before_timeout = False
        else:
            self.stream_items = self.myStream.read(count=1)
            self.data_ready_before_timeout = True

        # Create the input of the pipe
        self.pipe_write = pipe_write

        # Prevent downloading excessive amount of data from the server
        self.default_max_data_width = 1024
        self.default_max_data_length = 1
        self.max_transfer_size = self.default_max_data_width*self.default_max_data_length

        print("ReadRedisStream is all set.")



    def __del__(self):
        print("Called Destructor of ReadRedisStream.")



    def get_stream_items_any_size_notimeout(self):

        # Download/read the stream by transfer sizes into a list
        stream_items = self.myStream.read(count=self.max_transfer_size)

        # If at least some data were downloaded from the stream
        try:
            stream_items[0]
        except IndexError:
            myStream_len = self.myStream.__len__()
            while (myStream_len == 0):
                sleep(self.sleep_timeout_sec)
                myStream_len = self.myStream.__len__()

        stream_items = self.myStream.read(count=self.max_transfer_size)

        return stream_items, True



    def get_stream_items_any_size_timeout(self):

        # Download/read the stream by transfer sizes into a list
        stream_items = self.myStream.read(count=self.max_transfer_size)

        # If at least one item has been downloaded from the stream
        try:
            stream_items[0]
        except IndexError:
            sleep_timeout_counter = 0
            myStream_len = self.myStream.__len__()
            while (myStream_len == 0):
                sleep(self.sleep_timeout_sec)
                myStream_len = self.myStream.__len__()

                sleep_timeout_counter += 1
                if sleep_timeout_counter == self.sleep_timeout_counter_maxval:
                    response = messagebox.askyesno(
                        "Redis Server: Wait Timeout", 
                        "No data present in Redis server. Do you want to keep waiting?"
                    )

                    if response == 0:
                        return 0, False

                    # Reset timer, ask again
                    sleep_timeout_counter = 0

                    # return 0, False

        stream_items = self.myStream.read(count=self.max_transfer_size)

        return stream_items, True


    # def wait_for_data_timeout(self):
    #     sleep_timeout_counter = 0

    #     # Initialize the plot
    #     while not self.pipe_read.poll():
    #         time.sleep(self.sleep_timeout_sec)
    #         sleep_timeout_counter += 1

    #         # If timeout
    #         if sleep_timeout_counter == self.sleep_timeout_counter_maxval:
    #             # Ask Question
    #             response = messagebox.askyesno(
    #                 "Wait Timeout", 
    #                 "No data present in pipe_read or Redis server. Do you want to keep waiting?"
    #             )
                
    #             if response == 0:
    #                 return False

    #             sleep_timeout_counter = 0

    #     return True



    def pipe_write_from_redis_timeout(self):

        # Pass to the while loop, continue if data_ready_before_timeout=True after timeout
        # data_ready_before_timeout = True
        while self.data_ready_before_timeout:

            # Wait for certain amount of time for some data
            stream_items, self.data_ready_before_timeout \
                = self.get_stream_items_any_size_timeout()

            # Yield the content
            for _ in range(self.max_transfer_size):
                try:
                    # Get the oldest stream item
                    stream_item = stream_items.pop(0)

                    # Get the data by known keys
                    time_stream = int(stream_item[1][b'dataKey2'])
                    data_stream = int(stream_item[1][b'dataKey1'])

                    # Write to pipe
                    self.pipe_write.send([time_stream, data_stream, True])

                except IndexError:
                    # print("IndexError: Counting beyond the maximal number of items in the list. Break.")
                    break
                except TypeError:
                    # print("TypeError: Break")
                    break
                except AttributeError:
                    # print("AttributeError: Calling pop method on an empty tuple. Delete the stream content tuple. Break.")
                    del stream_items
                    break

                # self.myStream.trim(count=None, approximate=False, minid=stream_item[0], limit=None)
                self.myStream.__delitem__(stream_item[0])
            # self.myStream.trim(count=None, approximate=False, minid=stream_item[0], limit=None)
            # self.myStream.__delitem__(stream_item[0])

        # If false, return form this method
        self.pipe_write.send([0, 0, False])
        print("Sending false")
        return self.data_ready_before_timeout






class RealtimeMonitor():

    def __init__(self, pipe):
        # Create the Qtgui App and make exit function functional
        # self.app = QtGui.QApplication(sys.argv)            # you MUST do this once (initialize things)
        self.app = QApplication([])            # you MUST do this once (initialize things)

        # self.app.aboutToQuit.connect(self.closeEvent)

        # self.window = pg.GraphicsWindow(title="Streaming Data From the Redis Server") # creates a window
        self.window = pg.GraphicsLayoutWidget() # creates a window

        # setting vertical range
        # self.window.setYRange(0, 30)

        self.window_left = 100
        self.window_top = 100
        # self.window_width = 500 # width of the window displaying the curvecurve
        # self.window_width = 60 # width of the window displaying the curvecurve
        self.window_width = 180 # width of the window displaying the curvecurve
        self.window_height = 400
        self.window.setGeometry(
            self.window_left, 
            self.window_top, 
            self.window_width, 
            self.window_height
        )

        # Creates empty space for the plot in the window, set labels, units
        # label_style_args_bottom = {"color": "#EEE", "font-size": "14pt"}
        label_style_args_bottom = {}
        label_style_args_left = {}
        self.plot = self.window.addPlot(title="Real-time Data Monitoring")

        self.plot.setLimits(
            xMin=None,
            xMax=None,
            yMin=None,
            yMax=None
        )

        self.plot.setLabel(
            axis="bottom",
            text="<i>Time (sec)</i>",
            units=None,
            unitPrefix=None,
            **label_style_args_bottom
        )

        self.plot.setLabel(
            axis="left",
            text="<i>Count</i>", 
            units=None,
            unitPrefix=None,
            **label_style_args_left
        )

        # Create an empty plot curve
        self.curve = self.plot.plot()
        print("DEBUG: self.curve = ", self.curve)


        # Create the output of the pipe
        self.pipe_read, self.pipe_write = pipe
        self.pipe_write.close()
        self.plot_data = np.linspace(0, 0,self.window_width)

        # Functional variables
        self.sleep_timeout_sec = 0.1
        self.sleep_timeout_counter_maxval = 50


        self.window.show()
        print("RealtimeMonitor is all set.")



    def __del__(self):
        print("Called Destructor of RealtimeMonitor.")
 
 

    def wait_for_data_timeout(self):
        sleep_timeout_counter = 0

        # Initialize the plot
        while not self.pipe_read.poll():
            time.sleep(self.sleep_timeout_sec)
            sleep_timeout_counter += 1

            # If timeout
            if sleep_timeout_counter == self.sleep_timeout_counter_maxval:
                # Ask Question
                response = messagebox.askyesno(
                    "Real-time Monitor: Wait Timeout", 
                    "No data present in pipe_read. Do you want to keep waiting?"
                )
                
                if response == 0:
                    return False

                sleep_timeout_counter = 0

        return True



    # Realtime data plot. Each time this function is called, the data display is updated
    # 150 Frames / Second
    def visualize_stream(self):

        # stream_data_valid = self.wait_for_data_timeout()
        start_time = time.time()

        self.pipe_item = self.pipe_read.recv()
        self.plot_time = self.pipe_item[0]

        # If the first time value is non-zero, shift the entire data series
        # init_shift = 0
        
        init_plot_time = self.plot_time


        y_min_last = self.pipe_item[1]
        y_max_last = self.pipe_item[1]
        y_margin = 0.05 * (y_max_last-y_min_last)
        if self.plot_time != 0:
            self.plot.setLimits(
                xMin=init_plot_time,
                xMax=None,
                yMin=y_min_last-y_margin,
                yMax=y_max_last+y_margin
            )


        while self.pipe_item[2] == True:
            if self.pipe_item[0] < self.window_width:

                # Get new min-max values in the initial part of the stream 
                # to prevent plotting element at (time=0, data=0), if the stream starts later
                if self.pipe_item[1] <= y_min_last: y_min_last = self.pipe_item[1]
                elif self.pipe_item[1] > y_max_last: y_max_last = self.pipe_item[1]
                y_margin = 0.05 * (y_max_last-y_min_last)

                # Set the Y axis range
                self.plot.setLimits(
                    xMin=init_plot_time,
                    xMax=self.plot_time-0.0005,
                    yMin=y_min_last-y_margin,
                    yMax=y_max_last+y_margin
                )

                # Plot y_margin time data if time of stream is greater than plot time
                if self.plot_time <= self.pipe_item[0]:
                    # Add stream value to the vector containing the instantaneous values
                    np.put(self.plot_data, self.plot_time, self.pipe_item[1])
                else:
                    # Reset and try to reconstruct the data anyway:
                    print("Attempt to reset the window and reconstruct the data in the plot")
                    print("self.plot_time = ", self.plot_time)
                    print("self.pipe_item = ", self.pipe_item)
                    self.plot_data = np.linspace(0,0,self.window_width)
                    self.plot_time = self.pipe_item[0]
                    np.put(self.plot_data, self.plot_time, self.pipe_item[1])

                    # Set new max x position in the plot if time is more than actual max time displayed
                    # if :
                        # self.curve.setPos(self.plot_time,0)

                self.plot_time = self.pipe_item[0] + 1

            else:

                self.plot.setLimits(
                    xMin=None,
                    xMax=None,
                    yMin=None,
                    yMax=None
                )

                # Plot y_margin time data if time of stream is greater than plot time
                if self.plot_time <= self.pipe_item[0]:
                    shift_by = self.pipe_item[0] + 1 - self.plot_time
                    self.plot_data[:-shift_by] = self.plot_data[shift_by:]

                    # Filling non-stream data to be pulled to a certain value
                    # Note: For zero values as data fillers, the next line can be left commented.
                    #       However, Pygtgraph apparently has its own mechanisms to keep the plot alive, 
                    #       which cost some time. In a nutshell, it is faster to leave it uncommented
                    self.plot_data[-shift_by:] = 0

                    self.plot_data[-1] = self.pipe_item[1]
                    self.plot_time = self.pipe_item[0] + 1

                # This can be useful
                # # Plot stream time data if time of stream is equal to the plot time, shift left data
                # elif self.plot_time == self.pipe_item[0]:
                #     self.plot_data[:-1] = self.plot_data[1:]
                #     self.plot_data[-1] = self.pipe_item[1]
                #     self.plot_time += 1                           # update x position for displaying the curve

                else:
                    # Reset and try to reconstruct the data anyway:
                    print("Attempt to reset the window and reconstruct the data in the plot")
                    print("self.pipe_item = ", self.pipe_item)
                    self.plot_data = np.linspace(0,0,self.window_width)
                    self.plot_time = self.pipe_item[0]
                    self.plot_data[:-1] = self.plot_data[1:]
                    self.plot_data[-1] = self.pipe_item[1]
                    self.plot_time += 1

                # Set new x position in the plot
                self.curve.setPos(self.plot_time,0)

            # Update the plot values, draw changes
            self.curve.setData(self.plot_data)
            # QtGui.QApplication.processEvents()
            QApplication.processEvents()

            # Wait and get a new item
            self.pipe_item = self.pipe_read.recv()
            # stream_data_valid = self.wait_for_data_timeout()
            
            # if stream_data_valid == True:
                # self.pipe_item = self.pipe_read.recv()

        print("Exit in any case. Received End of Stream = ", self.pipe_item[2])
        print("Streaming took {0} seconds.".format((time.time() - start_time)))
        return True


def process_ReadRedisStream(pipe_write):
    redis_stream_client = ReadRedisStream(pipe_write)
    data_ready_before_timeout = redis_stream_client.pipe_write_from_redis_timeout()

    print("process_ReadRedisStream: data_ready_before_timeout = ", data_ready_before_timeout)
    return data_ready_before_timeout

def process_RealtimeMonitor(pipe):
    monitor = RealtimeMonitor(pipe)
    data_ready_before_timeout = monitor.visualize_stream()

    return data_ready_before_timeout
def graph_realtime_multiprocess():

    # if button_canbe_pressed == True:
        # Prevent clicking that button again while running
        # global button_func_2_canbe_pressed
        # button_func_2_canbe_pressed = False

        # # Define a pool of jobs to be done in parallel
        # jobs_number = 2
        # pool = multiprocessing.Pool(processes=jobs_number)
        # pool.apply_async(run_stream_write)
        # pool.apply_async(process_RealtimeMonitor)

        # pool.close()

        # # Wait until both jobs have been executed
        # pool.join()

    pipe_read, pipe_write = multiprocessing.Pipe()

    process_run_cpp_script = multiprocessing.Process(target=run_stream_write)
    process_write_to_pipe = multiprocessing.Process(target=process_ReadRedisStream, args=(pipe_write,))
    process_read_from_pipe = multiprocessing.Process(target=process_RealtimeMonitor, args=((pipe_read, pipe_write),))

    process_run_cpp_script.daemon = True
    process_write_to_pipe.daemon = True
    process_read_from_pipe.daemon = True

    process_run_cpp_script.start()
    process_write_to_pipe.start()
    process_read_from_pipe.start()

    process_write_to_pipe.join()
    process_read_from_pipe.join()
    process_run_cpp_script.terminate()




def root_window(
    error,
    verbose,
    geometry,
    proj_name, proj_dir, output_dir,
    generic_names, generic_vals):

    # Launch gui if no error occurred
    if error != 0:
        if error == 1:
            messagebox.showerror(
                "Error #"+str(error), 
                "Number of names and values of inputted generic parameters do not match. Check your command-line arguments or Makefile."
            )
    else:

        root = Tk()
        root.title("Generic Python GUI")
        # root.geometry(str(geometry))
        # root.configure(background='green')
    
        # Set initial values for objects, which must not be called again while already running
        global button_func_2_canbe_pressed
        button_func_2_canbe_pressed = True

        # ----- SET GENERICS SECTION -----
        # Frame
        frame1 = LabelFrame(root, text="Parameters for Hardware Generation", padx=20, pady=20) #  padx/y Inside of the frame
        frame1.grid(row=0, column=0, padx=(15,10), pady=(10,15), ipadx=0, ipady=0)                #  padx/y Outside of the frame


        global param_names
        global param_vals
        param_names = generic_names
        param_vals = generic_vals

        global entry_box_param
        entry_box_param_label = [Label(frame1, text=str(param_names[i]) + ": ") for i in range(len(param_names))]
        entry_box_param = [Entry(frame1, width=20, bg="white", fg="blue", borderwidth=1) for i in range(len(param_names))]

        for i in range(len(param_names)):
            if param_names[i] != "":
                entry_box_param_label[i].grid(row=i, column=0)
                entry_box_param[i].insert(0, str(param_vals[i]))
                entry_box_param[i].grid(row=i, column=1, padx=10, pady=0)



        # ----- FUNCTION SECTION -----
        # Frame
        frame2 = LabelFrame(root, text="Functions", padx=20, pady=20)              #  padx/y Inside of the frame
        frame2.grid(row=0, column=1, padx=(10,15), pady=(15,10), ipadx=0, ipady=0) #  padx/y Outside of the frame

        # Function Button
        global makefile_dir
        makefile_dir = proj_dir

        button_func_1 = Button(frame2, text="Generate Hardware", command=generate_hardware)
        button_func_1.grid(row=0, column=0, pady=5, padx=10, ipadx=20)

        # button_func_2 = Button(frame2, text="Real-time Monitoring", command=graph_realtime_thread)
        button_func_2 = Button(frame2, text="Data Monitoring", command=graph_realtime_multiprocess)
        # button_func_2 = Button(frame2, text="Real-time Monitoring", command=process_RealtimeMonitor)
        button_func_2.grid(row=1, column=0, pady=5, padx=10, ipadx=27)

        # Event loop (constant loop to run the program until exit)
        root.mainloop()

    return error