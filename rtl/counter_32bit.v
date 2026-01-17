// ============================================================================
// Parameterized 32-bit Up Counter with Enable and Reset
// ============================================================================
// Description: Synchronous up counter with enable and reset functionality
// Author: Design Team
// Date: December 3, 2025
// ============================================================================

module counter_32bit #(
    parameter WIDTH = 32  // Counter width (parameterized)
) (
    input  wire             clk,        // Clock input
    input  wire             rst_n,      // Active-low asynchronous reset
    input  wire             enable,     // Counter enable
    output reg [WIDTH-1:0]  count,      // Counter output
    output wire             overflow    // Overflow flag
);

    // Overflow detection
    assign overflow = (count == {WIDTH{1'b1}}) && enable;

    // Counter logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= {WIDTH{1'b0}};
        end else if (enable) begin
            count <= count + 1'b1;
        end
    end

endmodule
