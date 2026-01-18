# ============================================================================
# Synopsys VCS Simulation Script (TCL)
# ============================================================================

# Set design name
set DESIGN counter_32bit
set TB counter_32bit_tb

# Create output directory
file mkdir /mnt/workspace/users/Shahid/Seminar/sim/rtl

# Compile options
set VCS_OPTS "-full64 -sverilog +v2k -timescale=1ns/1ps -debug_access+all"

# Compile the design
puts "Compiling RTL design..."
exec vcs {*}$VCS_OPTS \
    /mnt/workspace/users/Shahid/Seminar/rtl/${DESIGN}.v \
    /mnt/workspace/users/Shahid/Seminar/tb/${TB}.v \
    -o /mnt/workspace/users/Shahid/Seminar/sim/rtl/counter_sim \
    -l /mnt/workspace/users/Shahid/Seminar/sim/rtl/compile.log

# Run simulation
puts "Running simulation..."
cd /mnt/workspace/users/Shahid/Seminar/sim/rtl
exec ./counter_sim -l simulation.log

puts "Simulation complete!"
