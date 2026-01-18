# ============================================================================
# Synopsys Design Compiler Synthesis Script
# Design: 32-bit Parameterized Counter
# ============================================================================
# Purpose: Complete synthesis flow from RTL to gate-level netlist
# Tool: Synopsys Design Compiler
# ============================================================================

# ============================================================================
# 1. SETUP AND CONFIGURATION
# ============================================================================

echo "=========================================================================="
echo "  SYNTHESIS STARTED: 32-bit Counter Design"
echo "  Tool: Synopsys Design Compiler"
echo "=========================================================================="

# Set design name
set design_name "counter_32bit"

# Define directory paths
set RTL_DIR "../rtl"
set CONSTRAINT_DIR "../syn/constraints"
set REPORT_DIR "../syn/reports"
set NETLIST_DIR "../syn/netlists"

# Create report directory if it doesn't exist
file mkdir $REPORT_DIR
file mkdir $NETLIST_DIR

# ============================================================================
# 2. LIBRARY SETUP
# ============================================================================

echo "\n[INFO] Setting up technology libraries..."

# Technology Library Setup
# NOTE: Replace these with actual library paths in production environment
# For demonstration, we'll use generic library references

# Target Library (standard cell library for synthesis)
# set target_library "typical.db"
# set link_library "* typical.db"

# For demonstration without actual libraries
set target_library [list typical.db]
set link_library [concat "*" $target_library]

# Symbol Library (for schematic viewing)
# set symbol_library "typical.sdb"

# Technology file
# set tech_file "typical.tf"

echo "[INFO] Target Library: $target_library"
echo "[INFO] Link Library: $link_library"

# ============================================================================
# 3. DESIGN SETUP
# ============================================================================

echo "\n[INFO] Setting design parameters..."

# Search path for design files
set search_path [list . $RTL_DIR $CONSTRAINT_DIR]

# Define work library
define_design_lib WORK -path ./work

# Suppress specific warnings (optional)
suppress_message UID-401
suppress_message TIM-164

# ============================================================================
# 4. READ RTL DESIGN
# ============================================================================

echo "\n[INFO] Reading RTL design..."
echo "=========================================================================="

# Analyze RTL files (checks syntax)
analyze -format verilog [list ${RTL_DIR}/${design_name}.v]

# Elaborate design (builds generic logic)
elaborate $design_name

# Set current design
current_design $design_name

# Link design (resolves references)
link

echo "\n[INFO] RTL successfully read and elaborated"
echo "=========================================================================="

# ============================================================================
# 5. CHECK DESIGN
# ============================================================================

echo "\n[INFO] Checking design for errors..."

# Check design for issues
check_design > ${REPORT_DIR}/check_design.rpt

echo "[INFO] Design check complete - see ${REPORT_DIR}/check_design.rpt"

# ============================================================================
# 6. APPLY CONSTRAINTS
# ============================================================================

echo "\n[INFO] Reading constraints..."

# Source SDC constraints file
source ${CONSTRAINT_DIR}/${design_name}.sdc

# Check for constraint conflicts
# check_timing

echo "[INFO] Constraints applied successfully"

# ============================================================================
# 7. PRE-SYNTHESIS REPORTS
# ============================================================================

echo "\n[INFO] Generating pre-synthesis reports..."

# Report design hierarchy
report_hierarchy > ${REPORT_DIR}/hierarchy_pre_syn.rpt

# Report constraints
report_constraint -all_violators > ${REPORT_DIR}/constraints_pre_syn.rpt

echo "[INFO] Pre-synthesis reports generated"

# ============================================================================
# 8. COMPILE/SYNTHESIZE DESIGN
# ============================================================================

echo "\n=========================================================================="
echo "  STARTING SYNTHESIS COMPILATION"
echo "=========================================================================="

# Set compilation options
set compile_ultra_ungroup_dw false

# Compile Design
# Options:
#   -map_effort high: Maximum optimization effort
#   -area_effort high: Focus on area optimization
#   -no_autoungroup: Preserve hierarchy
compile_ultra

echo "\n[INFO] Synthesis compilation complete!"
echo "=========================================================================="

# ============================================================================
# 9. POST-SYNTHESIS OPTIMIZATION
# ============================================================================

echo "\n[INFO] Running post-synthesis optimizations..."

# Optimize the design further
# optimize_netlist -area

# Remove assign statements
# remove_assign

# Remove unconnected ports
remove_unconnected_ports -blast_buses [get_cells -hierarchical *]

echo "[INFO] Post-synthesis optimization complete"

# ============================================================================
# 10. GENERATE REPORTS
# ============================================================================

echo "\n[INFO] Generating post-synthesis reports..."
echo "=========================================================================="

# Area Report
report_area -hierarchy > ${REPORT_DIR}/area.rpt
echo "[REPORT] Area report: ${REPORT_DIR}/area.rpt"

# Timing Report
report_timing -max_paths 10 -transition_time -nets -attributes > ${REPORT_DIR}/timing.rpt
echo "[REPORT] Timing report: ${REPORT_DIR}/timing.rpt"

# Constraint Report
report_constraint -all_violators > ${REPORT_DIR}/constraints.rpt
echo "[REPORT] Constraints report: ${REPORT_DIR}/constraints.rpt"

# Power Report
report_power -hierarchy > ${REPORT_DIR}/power.rpt
echo "[REPORT] Power report: ${REPORT_DIR}/power.rpt"

# Clock Report
report_clock -skew > ${REPORT_DIR}/clock.rpt
echo "[REPORT] Clock report: ${REPORT_DIR}/clock.rpt"

# QoR (Quality of Results) Report
report_qor > ${REPORT_DIR}/qor.rpt
echo "[REPORT] QoR report: ${REPORT_DIR}/qor.rpt"

# Resources Report
report_resources > ${REPORT_DIR}/resources.rpt
echo "[REPORT] Resources report: ${REPORT_DIR}/resources.rpt"

# Cell usage report
report_cell > ${REPORT_DIR}/cell_usage.rpt
echo "[REPORT] Cell usage report: ${REPORT_DIR}/cell_usage.rpt"

# Reference report (shows cell instances)
report_reference > ${REPORT_DIR}/reference.rpt
echo "[REPORT] Reference report: ${REPORT_DIR}/reference.rpt"

# Design report
report_design > ${REPORT_DIR}/design.rpt
echo "[REPORT] Design report: ${REPORT_DIR}/design.rpt"

echo "\n[INFO] All reports generated successfully!"
echo "=========================================================================="

# ============================================================================
# 11. WRITE OUTPUT FILES
# ============================================================================

echo "\n[INFO] Writing output netlist files..."

# Write gate-level Verilog netlist
write -format verilog -hierarchy -output ${NETLIST_DIR}/${design_name}_syn.v
echo "[OUTPUT] Gate-level netlist: ${NETLIST_DIR}/${design_name}_syn.v"

# Write DDC format (Design Compiler database)
write -format ddc -hierarchy -output ${NETLIST_DIR}/${design_name}_syn.ddc
echo "[OUTPUT] DDC database: ${NETLIST_DIR}/${design_name}_syn.ddc"

# Write SDC constraints for next stage
write_sdc ${NETLIST_DIR}/${design_name}_syn.sdc
echo "[OUTPUT] SDC constraints: ${NETLIST_DIR}/${design_name}_syn.sdc"

# Write SDF (Standard Delay Format) for timing simulation
write_sdf ${NETLIST_DIR}/${design_name}_syn.sdf
echo "[OUTPUT] SDF timing: ${NETLIST_DIR}/${design_name}_syn.sdf"

echo "\n[INFO] All output files written successfully!"
echo "=========================================================================="

# ============================================================================
# 12. SYNTHESIS SUMMARY
# ============================================================================

echo "\n=========================================================================="
echo "  SYNTHESIS COMPLETE - SUMMARY"
echo "=========================================================================="

# Quick summary
report_qor -summary

echo "\n=========================================================================="
echo "  OUTPUT FILES LOCATION"
echo "=========================================================================="
echo "Reports:   ${REPORT_DIR}/"
echo "Netlists:  ${NETLIST_DIR}/"
echo ""
echo "Key Files:"
echo "  - Gate-level netlist: ${design_name}_syn.v"
echo "  - Timing constraints: ${design_name}_syn.sdc"
echo "  - Timing delays:      ${design_name}_syn.sdf"
echo "  - Area report:        area.rpt"
echo "  - Timing report:      timing.rpt"
echo "  - Power report:       power.rpt"
echo "  - QoR report:         qor.rpt"
echo "=========================================================================="
echo "\n[SUCCESS] Synthesis completed successfully!"
echo "=========================================================================="

# Exit Design Compiler (comment out for interactive mode)
# quit
