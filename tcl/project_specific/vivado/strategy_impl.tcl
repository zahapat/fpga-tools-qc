set_property STEPS.OPT_DESIGN.ARGS.DIRECTIVE AddRemap [get_runs impl_1]


# Uncomment one
set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
# set_property strategy Performance_Explore [get_runs impl_1]
# set_property strategy Performance_ExplorePostRoutePhysOpt [get_runs impl_1]
# set_property strategy Performance_ExploreWithRemap [get_runs impl_1]
# set_property strategy Performance_WLBlockPlacement [get_runs impl_1]
# set_property strategy Performance_WLBlockPlacementFanoutOpt [get_runs impl_1]
# set_property strategy Performance_EarlyBlockPlacement [get_runs impl_1]
# set_property strategy Performance_NetDelay_high [get_runs impl_1]
# set_property strategy Performance_NetDelay_low [get_runs impl_1]
# set_property strategy Performance_Retiming [get_runs impl_1]
# set_property strategy Performance_ExtraTimingOpt [get_runs impl_1]
# set_property strategy Performance_RefinePlacement [get_runs impl_1]
# set_property strategy Performance_SpreadSLLs [get_runs impl_1]
# set_property strategy Performance_BalanceSLRs* (Vivado Implementation 2020) [get_runs impl_1]
# set_property strategy Performance_HighUtilSLRs* (Vivado Implementation 2020) [get_runs impl_1]
# set_property strategy Congestion_SpreadLogic_high* (Vivado Implementation 2020) [get_runs impl_1]
# set_property strategy Congestion_SpreadLogic_medium* (Vivado Implementation 2020) [get_runs impl_1]
# set_property strategy Congestion_SpreadLogic_low* (Vivado Implementation 2020) [get_runs impl_1]
# set_property strategy Congestion_SSI_SpreadLogic_high* (Vivado Implementation 2020) [get_runs impl_1]