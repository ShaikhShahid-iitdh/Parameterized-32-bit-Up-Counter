#!/bin/bash
# ============================================================================
# RTL Simulation Script using VCS (Synopsys)
# ============================================================================

echo "============================================"
echo "  RTL Simulation - 32-bit Counter"
echo "============================================"

# Create output directory
mkdir -p /mnt/workspace/users/Shahid/Seminar/sim/rtl

# Run VCS compilation and simulation
cd /mnt/workspace/users/Shahid/Seminar/sim/rtl

# Compile the design
echo "Step 1: Compiling RTL design..."
vcs -full64 -sverilog \
    -debug_access+all \
    -timescale=1ns/1ps \
    /mnt/workspace/users/Shahid/Seminar/rtl/counter_32bit.v \
    /mnt/workspace/users/Shahid/Seminar/tb/counter_32bit_tb.v \
    -o counter_sim \
    -l compile.log

if [ $? -ne 0 ]; then
    echo "ERROR: Compilation failed!"
    exit 1
fi

echo "Step 2: Running simulation..."
./counter_sim -l simulation.log

if [ $? -ne 0 ]; then
    echo "ERROR: Simulation failed!"
    exit 1
fi

echo ""
echo "============================================"
echo "  Simulation Complete!"
echo "============================================"
echo "Output files:"
echo "  - compile.log: Compilation messages"
echo "  - simulation.log: Simulation output"
echo "  - counter_32bit_tb.vcd: Waveform file"
echo ""
echo "To view waveforms, use:"
echo "  dve -vpd vcdplus.vpd &"
echo "  or: gtkwave counter_32bit_tb.vcd &"
echo "============================================"
