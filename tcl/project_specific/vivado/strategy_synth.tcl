set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]
# set_property STEPS.SYNTH_DESIGN.ARGS.NO_SRLEXTRACT true [get_runs synth_1]

# set_property strategy Flow_AlternateRoutability [get_runs synth_1]
set_property strategy Flow_PerfOptimized_high [get_runs synth_1]