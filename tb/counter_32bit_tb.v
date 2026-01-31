// ============================================================================
// Testbench for 32-bit Up Counter
// ============================================================================
// Description: Comprehensive testbench for counter verification
// ============================================================================

`timescale 1ns/1ps

module counter_32bit_tb;

    // Parameters
    parameter WIDTH = 32;
    parameter CLK_PERIOD = 10;  // 10ns clock period (100MHz)

    // Testbench signals
    reg                 clk;
    reg                 rst_n;
    reg                 enable;
    wire [WIDTH-1:0]    count;
    wire                overflow;

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Instantiate DUT
    counter_32bit #(
        .WIDTH(WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .count(count),
        .overflow(overflow)
    );

    // Test stimulus
    initial begin
        // Initialize signals
        rst_n = 0;
        enable = 0;
        
        // Generate VCD file for waveform viewing
        $dumpfile("counter_32bit_tb.vcd");
        $dumpvars(0, counter_32bit_tb);
        
        // Test 1: Reset test
        #20 rst_n = 1;
        #10;
        $display("%0t ns\t%b\t%b\t%h\t%b", $time, rst_n, enable, count, overflow);
        
        // Test 2: Enable counter
        #10 enable = 1;
        repeat(20) begin
            #10 $display("%0t ns\t%b\t%b\t%h\t%b", $time, rst_n, enable, count, overflow);
        end
        
        // Test 3: Disable counter
        #10 enable = 0;
        repeat(5) begin
            #10 $display("%0t ns\t%b\t%b\t%h\t%b", $time, rst_n, enable, count, overflow);
        end
        
        // Test 4: Re-enable counter
        #10 enable = 1;
        repeat(10) begin
            #10 $display("%0t ns\t%b\t%b\t%h\t%b", $time, rst_n, enable, count, overflow);
        end
        
        // Test 5: Reset during counting
        #10 rst_n = 0;
        #20 $display("%0t ns\t%b\t%b\t%h\t%b", $time, rst_n, enable, count, overflow);
        rst_n = 1;
        #10 $display("%0t ns\t%b\t%b\t%h\t%b", $time, rst_n, enable, count, overflow);
        
        // Test 6: Count for more cycles
        repeat(20) begin
            #10 $display("%0t ns\t%b\t%b\t%h\t%b", $time, rst_n, enable, count, overflow);
        end
        
        // Test 7: Overflow test (set counter near max value)
        #10 rst_n = 0;
        #10 rst_n = 1;
        // Force counter to near overflow for testing
        force dut.count = 32'hFFFFFFF0;
        #10 release dut.count;
        $display("\n--- Testing Overflow Condition ---");
        repeat(20) begin
            #10 $display("%0t ns\t%b\t%b\t%h\t%b", $time, rst_n, enable, count, overflow);
        end
        
        // End simulation
        #100;
        $finish;
    end

    // Monitor for critical events
    always @(posedge clk) begin
        if (overflow)
            $display("*** OVERFLOW DETECTED at time %0t ns ***", $time);
    end

endmodule
