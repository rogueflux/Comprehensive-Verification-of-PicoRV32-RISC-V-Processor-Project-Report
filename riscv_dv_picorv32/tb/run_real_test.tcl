# Real PicoRV32 test with HEX loading

puts "========================================"
puts "PicoRV32 Real Verification Test"
puts "========================================"

# Clean up
file delete -force ./real_sim
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

# Check PicoRV32 RTL
set rtl_file "../../picorv32/picorv32.v"
if {![file exists $rtl_file]} {
    puts "❌ ERROR: PicoRV32 RTL not found: $rtl_file"
    exit 1
}

# Create project
create_project -force real_proj ./real_sim -part xc7a100tcsg324-1
set_property target_language Verilog [current_project]

# Add files
add_files -norecurse $rtl_file

# Check if testbench exists
set tb_file "../tb/picoRV32_real_test.sv"
if {[file exists $tb_file]} {
    add_files -norecurse $tb_file
    puts "✅ Added testbench: [file tail $tb_file]"
} else {
    puts "❌ ERROR: Testbench not found: $tb_file"
    exit 1
}

set_property top picoRV32_real_test [current_fileset]
update_compile_order -fileset sources_1

puts "Design compiled successfully"

# Launch simulation with hexload argument
launch_simulation

# Pass hexload argument to testbench
set_property -name {xsim.simulate.xsim.more_options} -value {-testplusarg hexload} -objects [get_filesets sim_1]

puts "Starting simulation with HEX loading..."
puts "This may take a minute..."

run 50us

puts "========================================"
puts "Simulation completed!"
puts "========================================"

close_sim
exit 0

