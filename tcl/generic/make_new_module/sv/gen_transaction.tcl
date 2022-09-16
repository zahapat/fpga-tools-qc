puts $new_file_sim "    // This file serves for generating the stimulus"
puts $new_file_sim "    // Transaction class can also be used as a placeholder for the activity monitored by the monitor on DUT signals"
puts $new_file_sim ""
puts $new_file_sim "    // Declare transaction class"
puts $new_file_sim "    class transaction;"
puts $new_file_sim "        // Declare the transaction properties (items/variables): a, b are random"
puts $new_file_sim "        rand bit [3:0] a;"
puts $new_file_sim "        rand bit [3:0] b;"
puts $new_file_sim "             bit [3:0] c;"
puts $new_file_sim ""
puts $new_file_sim "        // Methods"
puts $new_file_sim "        function void display ("
puts $new_file_sim "            string name);"
puts $new_file_sim "            \$display(\"-------------------------\");"
puts $new_file_sim "            \$display(\"- %s \", name);"
puts $new_file_sim "            \$display(\"-------------------------\");"
puts $new_file_sim "            \$display(\"- a = %0d, b = %0d\", a, b);"
puts $new_file_sim "            \$display(\"- c = %0d\", c);"
puts $new_file_sim "            \$display(\"-------------------------\");"
puts $new_file_sim "        endfunction"
puts $new_file_sim "    endclass"