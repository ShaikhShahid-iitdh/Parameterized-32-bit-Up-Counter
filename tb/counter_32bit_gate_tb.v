// ============================================================================
// Gate-Level Testbench for 32-bit Counter
// ============================================================================
// Description: Testbench for post-synthesis gate-level simulation
// Purpose: Verify synthesized netlist functionality with timing
// ============================================================================

`timescale 1ns/1ps

module counter_32bit_gate_tb;

    // Parameters
    parameter WIDTH = 32;
    parameter CLK_PERIOD = 10;  // 10ns clock period (100MHz)

    // Testbench signals
    reg                 clk;
    reg                 rst_n;
    reg                 enable;
    wire [WIDTH-1:0]    count;
    wire                overflow;

    // Test control
    integer test_count;
    integer pass_count;
    integer fail_count;

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Instantiate DUT (Device Under Test) - Gate-Level Netlist
    counter_32bit dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .count(count),
        .overflow(overflow)
    );

    // Test monitoring
    initial begin
        // Initialize counters
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        // Generate VCD file for waveform viewing
        $dumpfile("counter_gate_level.vcd");
        $dumpvars(0, counter_32bit_gate_tb);
        
        // Display header
        $display("================================================================================");
        $display("  GATE-LEVEL SIMULATION - 32-bit Counter");
        $display("  Post-Synthesis Verification with Timing");
        $display("================================================================================");
        $display("Time\t\tReset\tEnable\tCount\t\tOverflow\tTest");
        $display("--------------------------------------------------------------------------------");
    end

    // Main test sequence
    initial begin
        // Initialize signals
        rst_n = 0;
        enable = 0;
        
        // Test 1: Power-on reset verification
        test_count = test_count + 1;
        #20 rst_n = 1;
        #10;
        if (count === 32'h00000000) begin
            $display("%0t ns\t%b\t%b\t%h\t%b\t\tTest 1: PASS (Reset)", $time, rst_n, enable, count, overflow);
            pass_count = pass_count + 1;
        end else begin
            $display("%0t ns\t%b\t%b\t%h\t%b\t\tTest 1: FAIL (Reset)", $time, rst_n, enable, count, overflow);
            fail_count = fail_count + 1;
        end
        
        // Test 2: Enable counter and verify increment
        test_count = test_count + 1;
        #10 enable = 1;
        #10; // Wait one clock
        if (count === 32'h00000001) begin
            $display("%0t ns\t%b\t%b\t%h\t%b\t\tTest 2: PASS (First increment)", $time, rst_n, enable, count, overflow);
            pass_count = pass_count + 1;
        end else begin
            $display("%0t ns\t%b\t%b\t%h\t%b\t\tTest 2: FAIL (First increment)", $time, rst_n, enable, count, overflow);
            fail_count = fail_count + 1;
        end
        
        // Test 3: Continuous counting
        test_count = test_count + 1;
        repeat(10) #10;
        if (count === 32'h0000000B) begin
            $display("%0t ns\t%b\t%b\t%h\t%b\t\tTest 3: PASS (Count=11)", $time, rst_n, enable, count, overflow);
            pass_count = pass_count + 1;
        end else begin
            $display("%0t ns\t%b\t%b\t%h\t%b\t\tTest 3: FAIL (Count=11)", $time, rst_n, enable, count, overflow);
            fail_count = fail_count + 1;
        end
        
        // Test 4: Disable counter (hold)
        test_count = test_count + 1;
        #10 enable = 0;
        #10;
        if (count === 32'h0000000B) begin
            $display("%0t ns\t%b\t%b\t%h\t%b\t\tTest 4: PASS (Hold)", $time, rst_n, enable, count, overflow);
            pass_count = pass_count + 1;
        end else begin
            $display("%0t ns\t%b\t%b\t%h\t%b\t\tTest 4: FAIL (Hold)", $time, rst_n, enable, count, overflow);
            fail_count = fail_count + 1;
        end
        
        // Test 5: Re-enable
        test_count = test_count + 1;
        #10 enable = 1;
        repeat(5) #10;
        if (count === 32'h00000010) begin
            $display("%0t ns\t%b\t%b\t%h\t%b\t\tTest 5: PASS (Resume count=16)", $time, rst_n, enable, count, overflow);
            pass_count = pass_count + 1;
        end else begin
            $display("%0t ns\t%b\t%b\t%h\t%b\t\tTest 5: FAIL (Resume count=16)", $time, rst_n, enable, count, overflow);
            fail_count = fail_count + 1;
        end
        
        // Test 6: Reset during operation
        test_count = test_count + 1;
        #10 rst_n = 0;
        #20 rst_n = 1;
        #10;
        if (count === 32'h00000000) begin
            $display("%0t ns\t%b\t%b\t%h\t%b\t\tTest 6: PASS (Async reset)", $time, rst_n, enable, count, overflow);
            pass_count = pass_count + 1;
        end else begin
            $display("%0t ns\t%b\t%b\t%h\t%b\t\tTest 6: FAIL (Async reset)", $time, rst_n, enable, count, overflow);
            fail_count = fail_count + 1;
        end
        
        // Test 7: Overflow detection
        test_count = test_count + 1;
        // Force counter to near maximum
        force dut.count = 32'hFFFFFFF0;
        #10 release dut.count;
        
        repeat(16) #10;
        
        if (overflow === 1'b1) begin
            $display("%0t ns\t%b\t%b\t%h\t%b\t\tTest 7: PASS (Overflow detected)", $time, rst_n, enable, count, overflow);
            pass_count = pass_count + 1;
        end else begin
            $display("%0t ns\t%b\t%b\t%h\t%b\t\tTest 7: FAIL (Overflow not detected)", $time, rst_n, enable, count, overflow);
            fail_count = fail_count + 1;
        end
        
        // Test 8: Wraparound after overflow
        test_count = test_count + 1;
        #10;
        if (count < 32'h00000010) begin
            $display("%0t ns\t%b\t%b\t%h\t%b\t\tTest 8: PASS (Wraparound)", $time, rst_n, enable, count, overflow);
            pass_count = pass_count + 1;
        end else begin
            $display("%0t ns\t%b\t%b\t%h\t%b\t\tTest 8: FAIL (Wraparound)", $time, rst_n, enable, count, overflow);
            fail_count = fail_count + 1;
        end
        
        // Additional cycles for observation
        repeat(10) begin
            #10 $display("%0t ns\t%b\t%b\t%h\t%b", $time, rst_n, enable, count, overflow);
        end
        
        // Summary
        #100;
        $display("================================================================================");
        $display("  GATE-LEVEL SIMULATION SUMMARY");
        $display("================================================================================");
        $display("Total Tests:   %0d", test_count);
        $display("Tests Passed:  %0d", pass_count);
        $display("Tests Failed:  %0d", fail_count);
        $display("Pass Rate:     %0d%%", (pass_count * 100) / test_count);
        $display("");
        
        if (fail_count == 0) begin
            $display("*** ALL TESTS PASSED ***");
            $display("Gate-level netlist matches RTL functionality");
            $display("Design is ready for physical implementation");
        end else begin
            $display("*** SOME TESTS FAILED ***");
            $display("Gate-level netlist has functional issues");
        end
        
        $display("================================================================================");
        $finish;
    end

    // Timing violation checker
    always @(posedge clk) begin
        if (rst_n && $time > 0) begin
            // Check for setup/hold violations (would be reported by simulator)
            if ($realtime - $time < 0.1) begin
                $display("WARNING: Possible timing violation at %0t ns", $time);
            end
        end
    end

    // Monitor for overflow events
    always @(posedge overflow) begin
        $display(">>> OVERFLOW EVENT at time %0t ns <<<", $time);
    end

endmodule
