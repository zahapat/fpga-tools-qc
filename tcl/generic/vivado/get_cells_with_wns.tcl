set cells_with_negative_slack {}
set timing_report [report_timing -no_header -path_type full -return_string]
set timing_report_items [split ${timing_report}]
if {("[lindex $timing_report_items 1]" eq "(VIOLATED)")} {
    puts "TCL: --------------------------------"
    puts "TCL: Cells causing timimng violation:"
    foreach cell $timing_report_items {
        if {([regexp {.*?\/.*\/D} $cell]) || 
            ([regexp {.*?\/.*\/C} $cell]) || 
            ([regexp {.*?\/.*\/Q} $cell]) || 
            ([regexp {.*?\/.*\/CLR} $cell])} {
            puts "TCL: $cell"
            lappend cells_with_negative_slack [get_cells -filter {IS_PRIMITIVE==1} -of_objects [get_pins $cell]]
        }
    }
    puts "TCL: --------------------------------"
} else {
    puts "TCL: Timing constraints have been MET. Proceed to bitstream generation."
}