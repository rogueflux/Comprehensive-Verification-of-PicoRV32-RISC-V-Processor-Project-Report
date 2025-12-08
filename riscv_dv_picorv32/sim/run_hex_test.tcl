# Test with HEX file loading

file delete -force ./hex_sim

puts "========================================"
puts "PicoRV32 HEX File Test"
puts "========================================"

# Copy HEX file
if {[file exists "../../build/final_20251207_085807/riscv_arithmetic_basic_test_0.hex"]} {
    file copy -force "../../build/final_20251207_085807/riscv_arithmetic_basic_test_0.hex" "./test.hex"
    puts "✅ Using test: riscv_arithmetic_basic_test_0.hex"
} else {
    puts "❌ No HEX file found"
    exit 1
}

# Create project
create_project -force hex_proj ./hex_sim -part xc7a100tcsg324-1
set_property target_language Verilog [current_project]

# Add files
add_files -norecurse {
    ../../picorv32/picorv32.v
    ../tb/picorv32_hex_test.sv
}

set_property top picorv32_hex_test [current_fileset]
update_compile_order -fileset sources_1

# Launch simulation with hexload argument
launch_simulation -simset sim_1 -mode behavioral

# Pass hexload argument
set_property -name {xsim.simulate.runtime} -value {100us} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.xsim.more_options} -value {-testplusarg hexload} -objects [get_filesets sim_1]

run 100us

puts "========================================"
puts "Simulation completed!"
puts "========================================"

close_sim
exit 0

