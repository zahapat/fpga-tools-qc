# FPGA Tools for Quantum Computing

Welcome to the FPGA Tools for Quantum Computing template repository.

This repository is primarily designed for use with the Xilinx Vivado Design Suite (HLx Edition build 2020.2) on Windows platforms.


# Documentation

## Desctiption

Tools provided with this repository serve for facilitating and speeding up the development of arbitrary FPGA-based projects.

The main content and functions of the repository are as follows:

1. Makefile Project Environment

The project environment enables to run make commands to interact with Xilinx software, HDL simulators (Modelsim), Git, run generic python GUIs, and much more.

2. Tcl scripts

Tcl scripts interact with software supporting a Tcl console. They are designed for automized re/building projects as well as running simulations using CLI (command-line interface).

3. modules

The environment consists of a subdirectory named modules, which serves as a collection of HDL modules created throughout the development of various projects in the past.
These modules consist of hardware description files and Tcl scripts for adding files to Vivado Design Suite and Modelsim in correct compile order.

4. packages

Subdirectory "packages" contains header package files for HDL development and simulations.



## Installing and Upgrading Required Packages

Xilinx Vivado and Vitis need to be downloaded and installed externally. After cloning this repository, run the following make command to install all required packages:

```
$ make install_all_pkg
```

Run the following make command to upgrade all packages:

```
$ make upgrade_all_pkg
```

## Git: Create A New Repository

Update the `GIT_EMAIL` variable in `git.mk`. Use your email address to link Git with your Git account.
Run the following command to create a new private repo:

```
$ make git_new_private_repo
```

Run the following command to create a new public repository:

```
$ make git_new_public_repo
```


## Git: Make The Current Repository Available As A Template

Run the following command to change the status accordingly:

```
$ make git_make_this_repo_template
```