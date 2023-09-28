# CDL FPGA Environment for Quantum Computing

Welcome to the FPGA Environment for Quantum Computing template repository.

This repository is primarily designed for use with the [Xilinx Vivado Design Suite (HLx Edition build 2020.2)](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive.html) on Windows platforms.

This repository contains VLSI hardware components, PCB layouts for Opal Kelly boards, and Vivado board files for high-speed data acquisition, clock synthesis, and other purposes within a quantum laboratory.



## Prerequisites

1. [Vivado Design Suite (HLx Edition build 2020.2)](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive.html)
2. [ModelSim-Intel® FPGA Standard Edition, Version 20.1std](https://www.intel.com/content/www/us/en/software-kit/750637/modelsim-intel-fpgas-standard-edition-software-version-20-1.html?)
3. [Cygwin](https://www.cygwin.com/install.html) (GNU and Open Source tools for Linux-like functionality on Windows)
4. [App Installer (Winget)](https://apps.microsoft.com/store/detail/app-installer/9NBLGGH4NNS1) available on Microsoft Store.
5. Run all scripts in the directory `'./scripts/installers/win11/'` in the order 1 to 6 (plus the optional batch script afterwise) as an administrator to configure environment variables, install chocolate, Microsoft PowerShell, GitHub CLI (gh), and Make.
6. If you do not wish to install Python, comment the nineth line in the `'RunAsAdmin2-InstallEssentialAppsWin11.bat'`
7. After installing all the required software, go to the directory of this environment. Open this directory in your favourite terminal and run:
    ```shell
    make sim_init
    ```
    This will create a modelsim.ini file in the environment's root directory, necessary to launch simulations.


## Desctiption

The tools provided with this repository serve to offer tools and VLSI source files for facilitating the development of FPGA-based projects to build optimal and resource-efficient hardware.

One can find the following subdirectories:

1. Tcl

    `./tcl` contains Tcl scripts that interact with software supporting a Tcl (Tickle) console. They are designed for automating project building and running simulations using CLI (command-line interface).

2. Scripts

    The `'./scripts'` directory consists of the following tools:

   - Python-Notebook-Based FQEnv wrapper and control tool
   - The search for optimal MMCM (Mixed Mode Clock Manager) primitives analyzer for optimal clock synthesis
   - FIR Coefficients Generator
   - Generic parameters generator
   - Data Visualizer after successful readout

3. Modules

    The `./modules` directory serves as a repository of HDL modules created throughout the development. These modules consist of hardware description and Tcl scripts for adding files to Vivado Design Suite and Modelsim in correct compile order.

4. Boards

    This directory serves as a repository of Tcl-based generators of Vivado board `'*.bd'` files necessary to integrate the project cores with various AXI-based components. It is possible to inspect such bd file in Vivado IDE.

5. PCB

    The `'./pcb'` directory contains PCB design source files and gerber files to view, review, modify, or adapt PCB designs to new designs using KiCad. Gerber files can be directly sent to a PCB manufacturer.

6. Do

    The `'./do'` directory contains do scripts that enable launching and compiling source files within ModelSim.

7. Simulator

    The `'./simulator'` directory accompanies scripts in the `./do` directory. This is the output directory of the ModelSim simualtor. Also, it contains other basic do scripts to control simulation via the ModelSim Tcl command-line. Do scripts can be programmed using Tcl language.

8. Vivado

    This folder contains the Vivado project. While building the project, report files are being generated to inspect the properties of the hardware being generated, its resource utilization, timing, and more. These properties can also be inspected after launching the `*.xpr` Vivado project file located in this directory.


## Basic Functionality

The core unit of the FPGA Environment is the central Makefile located in the root direcotry of this repository. When opened in a text editor, it consists variables in upprecase and make targets which are named based on what one intends to do. For example, the `'make src'` target will add sources to Vivado; and `'make board'` will create and add the bd file to vivado. 

The following example reflects the main implementation flow. Run the following commands in your terminal after navigating to the root directory.

- Reset the environment:
    ```shell
    make reset
    ```

- Add all HDL sources under the given the relative Top file located in modules directory. In this case, the TOP variable defined in the Makefile will be explicitly updated by the desired source:
    ```shell
    make src TOP=fsm_gflow_tb.vhd
    ```

- To launch the simulation, type the following to the command line while being in the project root directory. This will launch ModelSim and start the simulation:
    ```shell
    make sim_gui
    ```

- To run hardware synthesis in out-of-context mode, run the following command:
    ```shell
    make ooc TOP=TOP=fsm_gflow.vhd
    ```

- To view the results in Vivado GUI mode, type the following to the CLI and wait until the project is open in Vivado:
    ```shell
    make gui
    ```

- Run all stages of implementation: synthesis, implementation, bitstream generation, hw platform generation (if applicable)
    ```shell
    make all
    ```



## Git: Create a New Repository

Update the `GIT_EMAIL` variable in `git.mk`. Use your email address to link Git with your Git account.
Run the following command to create a new private repo:

```shell
$ make git_new_private_repo
```

Run the following command to create a new public repository:

```shell
$ make git_new_public_repo
```

Run the following command to make the repository as a template:

```shell
$ make git_make_this_repo_template
```