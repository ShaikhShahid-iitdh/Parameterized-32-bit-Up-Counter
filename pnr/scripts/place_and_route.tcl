################################################################################
# Place and Route Script for 32-bit Counter
# Tool: IC Compiler II (Synopsys)
# Design: counter_32bit
# Technology: 45nm CMOS
################################################################################

set DESIGN_NAME "counter_32bit"

# Source files
set FLOORPLAN_FILE "../floorplan/${DESIGN_NAME}_floorplan.ddc"
set NETLIST_FILE "../syn/netlists/${DESIGN_NAME}_syn.v"
set SDC_FILE "../syn/constraints/${DESIGN_NAME}.sdc"

# Technology parameters
set TECH_NODE "45nm"
set CORNER "typical"
set TEMP "25"
set VOLTAGE "1.0"

puts "================================================================================"
puts "STAGE 6: PLACE AND ROUTE"
puts "IC Compiler II - Synopsys"
puts "================================================================================"
puts "Design: $DESIGN_NAME"
puts "Technology: $TECH_NODE CMOS"
puts "Corner: $CORNER, ${TEMP}C, ${VOLTAGE}V"
puts "================================================================================"

################################################################################
# Step 1: Design Setup and Import
################################################################################

puts "\n=========================================="
puts "STEP 1: IMPORTING FLOORPLAN"
puts "=========================================="

# Read floorplan database
read_ddc $FLOORPLAN_FILE
current_design $DESIGN_NAME

# Read timing constraints
read_sdc $SDC_FILE

# Set operating conditions
set_operating_conditions \
    -max_library typ_lib \
    -max typical \
    -min_library typ_lib \
    -min typical

puts "INFO: Floorplan imported successfully"
puts "INFO: Design: [current_design]"
puts "INFO: Cell count: [sizeof_collection [get_cells -hier]]"

################################################################################
# Step 2: Placement
################################################################################

puts "\n=========================================="
puts "STEP 2: STANDARD CELL PLACEMENT"
puts "=========================================="

# Placement constraints
set_app_var placer_max_cell_density_threshold 0.75
set_app_var placer_enable_enhanced_soft_blockage true

# Coarse placement
puts "INFO: Running coarse placement..."
place_opt -effort medium

# Check placement legality
check_legality -verbose > ../pnr/reports/placement_legality.rpt

# Placement optimization
puts "INFO: Running placement optimization..."
place_opt -effort high -area_recovery -congestion

puts "INFO: Placement complete"

# Report placement statistics
report_placement -physical_hierarchy_violations all > ../pnr/reports/placement.rpt
report_congestion > ../pnr/reports/placement_congestion.rpt

################################################################################
# Step 3: Clock Tree Synthesis (CTS)
################################################################################

puts "\n=========================================="
puts "STEP 3: CLOCK TREE SYNTHESIS"
puts "=========================================="

# Define clock tree constraints
set_app_var cts_target_skew 0.1        ;# 100ps target skew
set_app_var cts_target_latency 0.5     ;# 500ps target latency
set_app_var cts_buffer_max_distance 30  ;# 30um max buffer distance

# Clock tree specification
set_clock_tree_options \
    -target_skew 0.1 \
    -target_latency 0.5 \
    -max_transition 0.3

# Synthesize clock tree
puts "INFO: Synthesizing clock tree..."
clock_opt -only_cts

# Report clock tree
report_clock_tree -summary > ../pnr/reports/clock_tree_summary.rpt
report_clock_timing -type skew > ../pnr/reports/clock_skew.rpt
report_clock_timing -type latency > ../pnr/reports/clock_latency.rpt

puts "INFO: Clock tree synthesis complete"

################################################################################
# Step 4: Routing
################################################################################

puts "\n=========================================="
puts "STEP 4: SIGNAL ROUTING"
puts "=========================================="

# Routing configuration
set_app_var route_opt_verbose true
set_app_var route_detail_use_multi_cut_via_effort high

# Global routing
puts "INFO: Running global routing..."
route_auto -effort medium

# Track assignment
puts "INFO: Running track assignment..."
route_opt -effort high -area_recovery

# Detail routing
puts "INFO: Running detail routing..."
route_detail

# Search and repair (fix DRC violations)
puts "INFO: Running search and repair..."
route_opt -size_only -effort high

puts "INFO: Routing complete"

# Report routing statistics
report_routing > ../pnr/reports/routing.rpt
report_design_physical > ../pnr/reports/design_physical.rpt

################################################################################
# Step 5: Post-Route Optimization
################################################################################

puts "\n=========================================="
puts "STEP 5: POST-ROUTE OPTIMIZATION"
puts "=========================================="

# Timing optimization
puts "INFO: Running timing optimization..."
route_opt -incremental -effort high

# Optimize for setup timing
optimize_timing -effort high -setup

# Optimize for hold timing
optimize_timing -effort high -hold

# Final optimization
route_opt -incremental -only_design_rule

puts "INFO: Post-route optimization complete"

################################################################################
# Step 6: Design Rule Checking
################################################################################

puts "\n=========================================="
puts "STEP 6: DESIGN RULE CHECKING"
puts "=========================================="

# Check design rules
puts "INFO: Running DRC checks..."
check_routes > ../pnr/reports/drc_check.rpt

# Check connectivity
puts "INFO: Checking connectivity..."
verify_connectivity > ../pnr/reports/connectivity.rpt

# Check geometry
puts "INFO: Checking geometry..."
verify_geometry > ../pnr/reports/geometry.rpt

puts "INFO: Design rule checking complete"

################################################################################
# Step 7: Timing Analysis
################################################################################

puts "\n=========================================="
puts "STEP 7: STATIC TIMING ANALYSIS"
puts "=========================================="

# Update timing
update_timing

# Report timing
report_timing -delay max -max_paths 10 > ../pnr/reports/timing_setup.rpt
report_timing -delay min -max_paths 10 > ../pnr/reports/timing_hold.rpt
report_constraint -all_violators > ../pnr/reports/timing_violations.rpt

# Report QoR
report_qor > ../pnr/reports/qor_final.rpt
report_qor -summary > ../pnr/reports/qor_summary.rpt

puts "INFO: Timing analysis complete"

################################################################################
# Step 8: Power Analysis
################################################################################

puts "\n=========================================="
puts "STEP 8: POWER ANALYSIS"
puts "=========================================="

# Set switching activity
set_switching_activity -toggle_rate 0.1 -static_probability 0.5

# Report power
report_power -hierarchy all > ../pnr/reports/power_final.rpt
report_power -net > ../pnr/reports/power_nets.rpt

puts "INFO: Power analysis complete"

################################################################################
# Step 9: Area and Utilization
################################################################################

puts "\n=========================================="
puts "STEP 9: AREA AND UTILIZATION ANALYSIS"
puts "=========================================="

report_area -hierarchy > ../pnr/reports/area_final.rpt
report_design_area > ../pnr/reports/design_area_final.rpt
report_utilization > ../pnr/reports/utilization.rpt

puts "INFO: Area analysis complete"

################################################################################
# Step 10: Save Design
################################################################################

puts "\n=========================================="
puts "STEP 10: SAVING DESIGN"
puts "=========================================="

# Save design database
save_design -hier -f ../pnr/${DESIGN_NAME}_pnr.ddc

# Write GDS (for tapeout preparation)
write_gds ../pnr/${DESIGN_NAME}_pnr.gds

# Write DEF
write_def ../pnr/${DESIGN_NAME}_pnr.def

# Write Verilog netlist
write_verilog ../pnr/${DESIGN_NAME}_pnr.v

# Write SDF (for timing simulation)
write_sdf ../pnr/${DESIGN_NAME}_pnr.sdf

# Write SPEF (parasitic extraction)
write_parasitics -format spef -output ../pnr/${DESIGN_NAME}_pnr.spef

puts "INFO: Design saved successfully"

################################################################################
# Summary Report
################################################################################

puts "\n================================================================================"
puts "PLACE AND ROUTE COMPLETE"
puts "================================================================================"

puts "\nDESIGN STATISTICS:"
puts "  Cells:          [sizeof_collection [get_cells -hier -filter is_hierarchical==false]]"
puts "  Nets:           [sizeof_collection [get_nets -hier]]"
puts "  Ports:          [sizeof_collection [get_ports *]]"

puts "\nFILES GENERATED:"
puts "  Design Database:  pnr/${DESIGN_NAME}_pnr.ddc"
puts "  GDS Layout:       pnr/${DESIGN_NAME}_pnr.gds"
puts "  DEF:              pnr/${DESIGN_NAME}_pnr.def"
puts "  Verilog Netlist:  pnr/${DESIGN_NAME}_pnr.v"
puts "  SDF:              pnr/${DESIGN_NAME}_pnr.sdf"
puts "  SPEF:             pnr/${DESIGN_NAME}_pnr.spef"

puts "\nREPORTS:"
puts "  Placement:        pnr/reports/placement.rpt"
puts "  Clock Tree:       pnr/reports/clock_tree_summary.rpt"
puts "  Routing:          pnr/reports/routing.rpt"
puts "  Timing:           pnr/reports/timing_setup.rpt, timing_hold.rpt"
puts "  Power:            pnr/reports/power_final.rpt"
puts "  Area:             pnr/reports/area_final.rpt"
puts "  QoR:              pnr/reports/qor_final.rpt"

puts "================================================================================"

exit
