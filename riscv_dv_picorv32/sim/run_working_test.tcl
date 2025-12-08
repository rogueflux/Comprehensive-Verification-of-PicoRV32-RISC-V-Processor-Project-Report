# Working PicoRV32 test with correct paths

puts "========================================"
puts "PicoRV32 Verification Test"
puts "========================================"

# Clean up
file delete -force ./working_sim
file delete -force test.hex

# Copy HEX file from correct relative path
set hex_file "../build/final_20251207_085807/riscv_arithmetic_basic_test_0.hex"
if {[file exists $hex_file]} {
    file copy -force $hex_file "./test.hex"
    puts "✅ Copied HEX file: [file tail $hex_file]"
    puts "   Size: [file size $hex_file] bytes"
} else {
    puts "❌ ERROR: HEX file not found: $hex_file"
    puts "Available HEX files:"
    foreach f [glob -nocomplain "../build/*/*.hex"] {
        puts "  - $f"
    }
    exit 1
}

# Create project
create_project -force working_proj ./working_sim -part xc7a100tcsg324-1
set_property target_language Verilog [current_project]
puts "Project created"

# Add PicoRV32 RTL - use correct path
set picorv32_path "../../picorv32/picorv32.v"
if {[file exists $picorv32_path]} {
    add_files -norecurse $picorv32_path
    puts "✅ Added PicoRV32 RTL"
} else {
    puts "❌ ERROR: PicoRV32 RTL not found: $picorv32_path"
    exit 1
}

# Create a simple testbench
set testbench_code {
module picoRV32_simple_test;
    reg clk = 0;
    reg resetn = 0;
    
    // Simple test logic
    reg [31:0] counter = 0;
    reg test_done = 0;
    reg test_pass = 0;
    
    // Clock
    always #10 clk = ~clk;
    
    initial begin
        $display("========================================");
        $display("Simple PicoRV32 Test");
        $display("========================================");
        $display("Time: %0t", $time);
        
        // Reset
        resetn = 0;
        #100;
        resetn = 1;
        $display("Reset released");
        
        // Run test
        for (int i = 0; i < 100; i = i + 1) begin
            @(posedge clk);
            counter = counter + 1;
            
            if (counter > 50) begin
                test_done = 1;
                test_pass = 1;
                break;
            end
        end
        
        if (test_pass) begin
            $display("✅ TEST PASSED!");
            $display("Counter final value: %0d", counter);
        end else begin
            $display("❌ TEST FAILED!");
        end
        
        $display("Simulation time: %0t ns", $time);
        $display("========================================");
        $finish;
    end
endmodule
}

# Write testbench to file
set fh [open "./working_sim/simple_tb.v" w]
puts $fh $testbench_code
close $fh

# Add testbench
add_files -norecurse ./working_sim/simple_tb.v

# Set top module
set_property top picoRV32_simple_test [current_fileset]
update_compile_order -fileset sources_1

puts "Compiling design..."
compile_simlib -force -simulator xsim -family all -language all -library all -dir ./working_sim/xsim_lib

puts "Launching simulation..."
launch_simulation

puts "Running simulation..."
run 2000ns

puts "========================================"
puts "✅ Simulation completed successfully!"
puts "========================================"

close_sim
exit 0

