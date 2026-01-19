################################################################################
# Floorplanning Script for 32-bit Counter
# Tool: IC Compiler (Synopsys)
# Design: counter_32bit
# Technology: 45nm CMOS
################################################################################

# Set design name
set DESIGN_NAME "counter_32bit"

# Source common setup
set NETLIST_FILE "/mnt/workspace/users/Shahid/Seminar/syn/netlists/${DESIGN_NAME}_syn.v"
set SDC_FILE "/mnt/workspace/users/Shahid/Seminar/syn/constraints/${DESIGN_NAME}.sdc"

# Technology parameters (45nm CMOS)
set TECH_NODE "45nm"
set METAL_LAYERS 6
set MIN_CHANNEL_WIDTH 0.09  ;# 90nm minimum feature size for 45nm node

################################################################################
# Step 1: Design Import and Setup
################################################################################

puts "=========================================="
puts "STEP 1: Importing Synthesized Netlist"
puts "=========================================="

# Read gate-level netlist
read_verilog $NETLIST_FILE

# Set current design
current_design $DESIGN_NAME

# Link design
link_design

# Read timing constraints
read_sdc $SDC_FILE

puts "INFO: Design imported successfully"
puts "INFO: Cell count: [sizeof_collection [get_cells -hier]]"

################################################################################
# Step 2: Floorplan Dimensions
################################################################################

puts "=========================================="
puts "STEP 2: Defining Floorplan Dimensions"
puts "=========================================="

# Calculate core area based on gate-level netlist area
# Synthesized area: 1772.33 um²
# Target utilization: 70% (allows room for routing)
# Core area = Synthesized area / Utilization

set SYNTH_AREA 1772.33
set UTILIZATION 0.70
set CORE_AREA [expr {$SYNTH_AREA / $UTILIZATION}]
set CORE_SIDE [expr {sqrt($CORE_AREA)}]

# Round up to multiple of 5 for cleaner dimensions
set CORE_WIDTH [expr {ceil($CORE_SIDE / 5.0) * 5}]
set CORE_HEIGHT [expr {ceil($CORE_SIDE / 5.0) * 5}]

# Add I/O ring space
set IO_SPACE 10.0  ;# 10um for I/O ring and pad area
set CHIP_WIDTH [expr {$CORE_WIDTH + 2 * $IO_SPACE}]
set CHIP_HEIGHT [expr {$CORE_HEIGHT + 2 * $IO_SPACE}]

puts "INFO: Core dimensions: ${CORE_WIDTH} x ${CORE_HEIGHT} um"
puts "INFO: Core area: [expr {$CORE_WIDTH * $CORE_HEIGHT}] um²"
puts "INFO: Chip dimensions (with I/O): ${CHIP_WIDTH} x ${CHIP_HEIGHT} um"
puts "INFO: Target utilization: [expr {$UTILIZATION * 100}]%"

# Create floorplan
create_floorplan \
    -core_size $CORE_WIDTH $CORE_HEIGHT \
    -flip_first_row \
    -start_first_row \
    -left_io2core $IO_SPACE \
    -right_io2core $IO_SPACE \
    -top_io2core $IO_SPACE \
    -bottom_io2core $IO_SPACE

puts "INFO: Floorplan created successfully"

################################################################################
# Step 3: I/O Placement
################################################################################

puts "=========================================="
puts "STEP 3: I/O Pin Placement"
puts "=========================================="

# Pin constraints for better placement
# Group related signals together

# Clock pin on left side (top)
set_pin_physical_constraints -layers {metal3} -side 1 [get_ports clk]

# Reset pin on left side (bottom)
set_pin_physical_constraints -layers {metal3} -side 1 [get_ports rst_n]

# Enable pin on bottom side (left)
set_pin_physical_constraints -layers {metal3} -side 3 [get_ports enable]

# Counter outputs distributed on right and top sides
set_pin_physical_constraints -layers {metal3} -side 2 [get_ports count[*]]
set_pin_physical_constraints -layers {metal3} -side 4 [get_ports count[*]]

# Overflow pin on top side (right)
set_pin_physical_constraints -layers {metal3} -side 4 [get_ports overflow]

# Place I/O pins
place_pins -self

puts "INFO: I/O pins placed successfully"

################################################################################
# Step 4: Power Planning
################################################################################

puts "=========================================="
puts "STEP 4: Power Planning"
puts "=========================================="

# Define power nets
set VDD_NET "VDD"
set VSS_NET "VSS"

# Create power rings around the core
create_power_ring \
    -nets "$VDD_NET $VSS_NET" \
    -layers "metal5 metal6" \
    -width 2.0 \
    -spacing 1.0 \
    -offset 1.5

puts "INFO: Power rings created"

# Create power straps (vertical on metal5, horizontal on metal6)
create_power_straps \
    -direction horizontal \
    -layer metal6 \
    -width 1.0 \
    -spacing 20.0 \
    -nets "$VDD_NET $VSS_NET"

create_power_straps \
    -direction vertical \
    -layer metal5 \
    -width 1.0 \
    -spacing 20.0 \
    -nets "$VDD_NET $VSS_NET"

puts "INFO: Power straps created"

# Create standard cell power rails (on metal1)
create_power_rails \
    -direction horizontal \
    -layer metal1 \
    -width 0.18 \
    -nets "$VDD_NET $VSS_NET"

puts "INFO: Standard cell power rails created"

################################################################################
# Step 5: Placement Preparation
################################################################################

puts "=========================================="
puts "STEP 5: Placement Regions and Blockages"
puts "=========================================="

# Create placement blockages if needed
# For this small design, no blockages required

# Set placement constraints
set_placement_constraints -check_legality true

# Optimize floorplan
optimize_floorplan

puts "INFO: Floorplan optimization complete"

################################################################################
# Step 6: Report Generation
################################################################################

puts "=========================================="
puts "STEP 6: Generating Reports"
puts "=========================================="

# Design area report
report_design_area > /mnt/workspace/users/Shahid/Seminar/floorplan/reports/design_area.rpt

# Floorplan summary
report_floorplan > /mnt/workspace/users/Shahid/Seminar/floorplan/reports/floorplan_summary.rpt

# Port placement report
report_ports > /mnt/workspace/users/Shahid/Seminar/floorplan/reports/port_placement.rpt

# Congestion analysis
report_congestion > /mnt/workspace/users/Shahid/Seminar/floorplan/reports/congestion.rpt

puts "INFO: Reports generated in floorplan/reports/"

################################################################################
# Step 7: Save Design
################################################################################

puts "=========================================="
puts "STEP 7: Saving Floorplan"
puts "=========================================="

# Save design database
save_design -hier -f /mnt/workspace/users/Shahid/Seminar/floorplan/${DESIGN_NAME}_floorplan.ddc

# Export DEF (Design Exchange Format)
write_def /mnt/workspace/users/Shahid/Seminar/floorplan/${DESIGN_NAME}_floorplan.def


# Display summary
puts "\n=== FLOORPLAN SUMMARY ==="
puts "Design: $DESIGN_NAME"
puts "Core Area: [expr {$CORE_WIDTH * $CORE_HEIGHT}] um²"
puts "Utilization: [expr {$UTILIZATION * 100}]%"
puts "Chip Size: ${CHIP_WIDTH} x ${CHIP_HEIGHT} um"
puts "I/O Pins: [sizeof_collection [get_ports *]]"
puts "Standard Cells: [sizeof_collection [get_cells -hier -filter {is_hierarchical==false}]]"
puts "=========================="

exit
