# Batch test with proper hex loading
puts "========================================"
puts "Running batch test with HEX loading"
puts "========================================"

# Clean up
file delete -force ./batch_sim
file delete -force test.hex

# Copy HEX file
set hex_file "../build/final_20251207_085807/riscv_arithmetic_basic_test_0.hex"
if {[file exists $hex_file]} {
    file copy -force $hex_file "./test.hex"
    set hex_size [file size $hex_file]
    puts "✅ Using test: [file tail $hex_file] ($hex_size bytes)"
} else {
    puts "❌ ERROR: HEX file not found"
    exit 1
}

# Create project
create_project -force batch_proj ./batch_sim -part xc7a100tcsg324-1
set_property target_language Verilog [current_project]

# Add files
add_files -norecurse ../../picorv32/picorv32.v
add_files -norecurse ../tb/picorv32_hex_test.sv

# Set top
set_property top picorv32_hex_test [current_fileset]
set_property top picorv32_hex_test [get_filesets sim_1]

# Set hexload argument BEFORE launching
set_property -name {xsim.simulate.xsim.more_options} -value {-testplusarg hexload} -objects [get_filesets sim_1]

puts "Starting simulation with hexload argument..."
launch_simulation

# Run for enough time
run 100us

puts "========================================"
puts "Simulation completed"
puts "========================================"

close_sim
exit 0

