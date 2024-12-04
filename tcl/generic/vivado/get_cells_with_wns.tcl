proc print_failed_paths {} {
    set all_cells_with_negative_slack {}
    set report_paths_negslack [get_timing_paths -max_paths 1000 -slack_lesser_than 0]
    puts "TCL: ----- Timing Report (can be modified in XDC file) -----"
    foreach path $report_paths_negslack {
        set startpoint [get_property STARTPOINT_PIN $path]
        set startclock [get_property STARTPOINT_CLOCK $path]
        set endpoint [get_property ENDPOINT_PIN $path]
        set endclock [get_property ENDPOINT_CLOCK $path]
        set slack [get_property SLACK $path]
        lappend all_cells_with_negative_slack $startpoint
        lappend all_cells_with_negative_slack $endpoint
        puts " "
        puts "# Slack ${slack} on clocks ${startclock} -> ${endclock}"
        puts "set_max_delay 1.500 -datapath_only \\ "
        puts "-from \[get_cells [string range $startpoint 0 [expr {[string last "/" $startpoint]-1}]]\]\\ "
        puts "  -to \[get_cells [string range $endpoint 0 [expr {[string last "/" $endpoint]-1}]]\]"
    }
    puts " "
    puts "TCL: ----- End of Timing Report -----"
    return $all_cells_with_negative_slack
}

set cells_with_negative_slack [print_failed_paths]

if {[llength $cells_with_negative_slack] == 0} {
    puts "TCL: Timing constraints are MET. Proceed to bitstream generation."
} else {
    puts "TCL: The above cells cause timimng violations."
}