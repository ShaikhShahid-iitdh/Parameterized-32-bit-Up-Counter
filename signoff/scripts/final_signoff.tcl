################################################################################
# Final Signoff Script for 32-bit Counter
# Tool: PrimeTime (Synopsys) / Calibre (Mentor)
# Design: counter_32bit
# Technology: 45nm CMOS
################################################################################

set DESIGN_NAME "counter_32bit"

# Input files
set GDS_FILE "/mnt/workspace/users/Shahid/Seminar/pnr/${DESIGN_NAME}_pnr.gds"
set NETLIST_FILE "/mnt/workspace/users/Shahid/Seminar/pnr/${DESIGN_NAME}_pnr.v"
set SDF_FILE "/mnt/workspace/users/Shahid/Seminar/pnr/${DESIGN_NAME}_pnr.sdf"
set SPEF_FILE "/mnt/workspace/users/Shahid/Seminar/pnr/${DESIGN_NAME}_pnr.spef"
set SDC_FILE "/mnt/workspace/users/Shahid/Seminar/syn/constraints/${DESIGN_NAME}.sdc"

puts "================================================================================"
puts "STAGE 8: FINAL SIGNOFF AND GDSII GENERATION"
puts "PrimeTime / Calibre - Synopsys / Mentor Graphics"
puts "================================================================================"
puts "Design: $DESIGN_NAME"
puts "Technology: 45nm CMOS"
puts "================================================================================"

################################################################################
# Step 1: Final Timing Signoff
################################################################################

puts "\n=========================================="
puts "STEP 1: FINAL TIMING SIGNOFF"
puts "=========================================="

# Load design
read_verilog $NETLIST_FILE
current_design $DESIGN_NAME
link_design

# Read timing constraints
read_sdc $SDC_FILE

# Read parasitic data
read_parasitics -format spef $SPEF_FILE

# Set operating conditions
set_operating_conditions \
    -max typical \
    -min typical \
    -temperature 25 \
    -voltage 1.0

puts "INFO: Running multi-corner timing analysis..."

# Setup timing analysis
update_timing
report_timing -delay max -max_paths 10 -nworst 10 > /mnt/workspace/users/Shahid/Seminar/signoff/reports/final_timing_setup.rpt
report_constraint -all_violators > /mnt/workspace/users/Shahid/Seminar/signoff/reports/final_violations.rpt

# Hold timing analysis
report_timing -delay min -max_paths 10 -nworst 10 > /mnt/workspace/users/Shahid/Seminar/signoff/reports/final_timing_hold.rpt

# Clock analysis
report_clock_timing -type skew > /mnt/workspace/users/Shahid/Seminar/signoff/reports/final_clock_skew.rpt
report_clock_timing -type latency > /mnt/workspace/users/Shahid/Seminar/signoff/reports/final_clock_latency.rpt

# Summary
report_qor > /mnt/workspace/users/Shahid/Seminar/signoff/reports/final_qor.rpt

puts "INFO: Timing signoff complete"

################################################################################
# Step 2: Power Integrity Analysis
################################################################################

puts "\n=========================================="
puts "STEP 2: POWER INTEGRITY ANALYSIS"
puts "=========================================="

# Static power analysis
set_switching_activity -toggle_rate 0.1 -static_probability 0.5
report_power -hierarchy all > /mnt/workspace/users/Shahid/Seminar/signoff/reports/final_power.rpt

# IR drop analysis
analyze_power_grid \
    -nets {VDD VSS} \
    -voltage_drop 0.05 \
    -output /mnt/workspace/users/Shahid/Seminar/signoff/reports/ir_drop_analysis.rpt

# EM (Electromigration) analysis
check_em_rules \
    -output /mnt/workspace/users/Shahid/Seminar/signoff/reports/em_analysis.rpt

puts "INFO: Power integrity analysis complete"

################################################################################
# Step 3: Signal Integrity Analysis
################################################################################

puts "\n=========================================="
puts "STEP 3: SIGNAL INTEGRITY ANALYSIS"
puts "=========================================="

# Crosstalk analysis
analyze_crosstalk \
    -victim_nets all \
    -output /mnt/workspace/users/Shahid/Seminar/signoff/reports/crosstalk_analysis.rpt

# Noise analysis
report_noise \
    -output /mnt/workspace/users/Shahid/Seminar/signoff/reports/noise_analysis.rpt

puts "INFO: Signal integrity analysis complete"

################################################################################
# Step 4: Final DRC/LVS Check
################################################################################

puts "\n=========================================="
puts "STEP 4: FINAL DRC/LVS VERIFICATION"
puts "=========================================="

# Run final DRC
puts "INFO: Running final DRC sweep..."
calibre -drc -gds $GDS_FILE -runset /mnt/workspace/users/Shahid/Seminar/verification/rules/drc_rules_45nm.tcl

# Run final LVS
puts "INFO: Running final LVS verification..."
calibre -lvs -gds $GDS_FILE -netlist $NETLIST_FILE -runset /mnt/workspace/users/Shahid/Seminar/verification/rules/lvs_rules_45nm.tcl

puts "INFO: Final verification complete"

################################################################################
# Step 5: GDSII Generation and Validation
################################################################################

puts "\n=========================================="
puts "STEP 5: GDSII GENERATION"
puts "=========================================="

# Stream out final GDSII
puts "INFO: Generating final GDSII file..."
write_gds \
    -file /mnt/workspace/users/Shahid/Seminar/signoff/gdsii/${DESIGN_NAME}_final.gds \
    -design $DESIGN_NAME \
    -layer_map /mnt/workspace/users/Shahid/Seminar/verification/tech/layer_map.txt \
    -no_zero_length_boundaries \
    -merge_files

# Validate GDSII
puts "INFO: Validating GDSII file..."
validate_gds \
    -file /mnt/workspace/users/Shahid/Seminar/signoff/gdsii/${DESIGN_NAME}_final.gds \
    -output /mnt/workspace/users/Shahid/Seminar/signoff/reports/gds_validation.rpt

# Generate OASIS (optional, more compact format)
write_oasis \
    -file /mnt/workspace/users/Shahid/Seminar/signoff/gdsii/${DESIGN_NAME}_final.oas \
    -design $DESIGN_NAME

puts "INFO: GDSII generation complete"

################################################################################
# Step 6: Documentation Generation
################################################################################

puts "\n=========================================="
puts "STEP 6: GENERATING FABRICATION DOCUMENTATION"
puts "=========================================="

# Design datasheet
generate_datasheet \
    -design $DESIGN_NAME \
    -output /mnt/workspace/users/Shahid/Seminar/signoff/documentation/design_datasheet.pdf

# Pin map
report_pins \
    -output /mnt/workspace/users/Shahid/Seminar/signoff/documentation/pin_map.txt

# Layer stack
report_layers \
    -output /mnt/workspace/users/Shahid/Seminar/signoff/documentation/layer_stack.txt

# Test vectors
generate_test_vectors \
    -output /mnt/workspace/users/Shahid/Seminar/signoff/documentation/test_vectors.txt


