This folder contains a template for a new VHDL module

To do in /hdl/ folder:
1. Copy the module_template_vhdl folder to ./modules/ and rename it by your desired "srcname"
2. Keep/remove the /pack/ folder
    - Keep it if you don't intend using generic variables in this module
    - Remove it otherwise. The reason is that all packages need to be compiled before 
      generic variables are passed to the module during compile time. Therefore, 
      having signals, constants and types declared in packages, generic variables won't 
      be able to reach these packages and thus modify the module generically.
3. Replace all "srcname" keywords in all files
4. Include the ready/valid handshake in your module. This is useful for both:
    - Verification. No need to know precisely how many cycles there are to receive valid data.
      Just wait for this valid signal. Eventually, you can assert this signal to verify the correct delay.
    - Design synthesis debug. If ready/valid signals are constant, they will be trimmed, if intended.
      If trimming of these signals was be unintended, you can locate the cause more easily.

To do in /sim/ folder:
1. Keep the /pack/ folder
2. Replace all "srcname" keywords in all files
3. Connect the DUT, data, ready, valid


To do in "compile_order.tcl" file
1. Comment/uncomment hdl/pack/ part