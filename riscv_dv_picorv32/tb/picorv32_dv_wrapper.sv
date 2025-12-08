
// Minimal PicoRV32 wrapper for initial testing
`timescale 1ns/1ps

module picorv32_dv_wrapper (
    input  wire         clk,
    input  wire         reset,
    input  wire         test_start,
    output wire         test_done,
    output wire         test_pass,
    output wire [31:0]  test_result
);
    
    // Simple test logic for now
    reg [31:0] counter = 0;
    reg done = 0;
    reg pass = 0;
    reg [31:0] result = 0;
    
    always @(posedge clk) begin
        if (reset) begin
            counter <= 0;
            done <= 0;
            pass <= 0;
            result <= 0;
        end else if (test_start && !done) begin
            counter <= counter + 1;
            
            if (counter > 100) begin
                done <= 1;
                pass <= 1;
                result <= 32'h12345678;
            end
        end
    end
    
    assign test_done = done;
    assign test_pass = pass;
    assign test_result = result;
    
endmodule

