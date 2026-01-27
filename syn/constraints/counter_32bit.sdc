# ============================================================================
# Synopsys Design Constraints (SDC) File
# Design: 32-bit Parameterized Counter
# ============================================================================
# Purpose: Define timing, area, and design constraints for synthesis
# ============================================================================

# Design Configuration
set design_name "counter_32bit"

# ============================================================================
# 1. CLOCK DEFINITION
# ============================================================================
# Define clock signal with period, uncertainty, and transition times

# Clock Period: 10ns (100 MHz target frequency)
set clk_period 10.0
set clk_name "clk"

# Create clock
create_clock -name $clk_name -period $clk_period [get_ports clk]

# Clock Uncertainty (jitter + skew)
set_clock_uncertainty 0.5 [get_clocks $clk_name]

# Clock Transition Time
set_clock_transition 0.1 [get_clocks $clk_name]

# Clock Latency
set_clock_latency -source 1.0 [get_clocks $clk_name]
set_clock_latency -network 0.5 [get_clocks $clk_name]

# ============================================================================
# 2. INPUT CONSTRAINTS
# ============================================================================
# Define input delay and drive strength

# Input ports (excluding clock)
set input_ports [remove_from_collection [all_inputs] [get_ports clk]]

# Input Delay: 30% of clock period
set input_delay [expr $clk_period * 0.3]
set_input_delay -clock $clk_name -max $input_delay $input_ports
set_input_delay -clock $clk_name -min [expr $input_delay * 0.5] $input_ports

# Input Transition Time
set_input_transition 0.2 $input_ports

# Drive Strength (assuming driven by standard buffer)
set_driving_cell -lib_cell BUFX2 -library typical $input_ports

# ============================================================================
# 3. OUTPUT CONSTRAINTS
# ============================================================================
# Define output delay and load

# Output Delay: 30% of clock period
set output_delay [expr $clk_period * 0.3]
set_output_delay -clock $clk_name -max $output_delay [all_outputs]
set_output_delay -clock $clk_name -min [expr $output_delay * 0.5] [all_outputs]

# Output Load (assuming driving 2 standard loads)
set_load 0.05 [all_outputs]

# ============================================================================
# 4. TIMING CONSTRAINTS
# ============================================================================

# Maximum Transition Time
set_max_transition 0.5 $design_name

# Maximum Fanout
set_max_fanout 16 $design_name

# Maximum Capacitance
set_max_capacitance 0.5 [all_outputs]

# ============================================================================
# 5. AREA CONSTRAINTS
# ============================================================================

# Area Optimization (0 = high effort)
set_max_area 0

# ============================================================================
# 6. DESIGN RULES
# ============================================================================

# Fix hold violations
set_fix_hold [get_clocks $clk_name]

# Don't use cells (if any cells should be avoided)
# set_dont_use [get_lib_cells */LATCH*]

# ============================================================================
# 7. OPERATING CONDITIONS
# ============================================================================

# Set operating conditions (worst case for setup, best case for hold)
# These will be overridden by actual library settings

# Temperature and voltage derating
# set_operating_conditions -max worst_case -min best_case

# ============================================================================
# 8. MULTI-CYCLE AND FALSE PATHS
# ============================================================================

# Reset is asynchronous - no timing check needed on reset path
set_false_path -from [get_ports rst_n] -to [all register]

# ============================================================================
# 9. DESIGN ATTRIBUTES
# ============================================================================

# Preserve hierarchy for better debugging (optional)
# set_dont_touch_network [get_clocks $clk_name]

# ============================================================================
# CONSTRAINT SUMMARY
# ============================================================================
# Clock Period:        10.0 ns (100 MHz)
# Clock Uncertainty:   0.5 ns
# Input Delay:         3.0 ns (30% of period)
# Output Delay:        3.0 ns (30% of period)
# Max Transition:      0.5 ns
# Max Fanout:          16
# ============================================================================
