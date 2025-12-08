# Clean up
file delete -force ./real_sim

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
create_project -force real_proj ./real_sim -part xc7a100tcsg324-1
set_property target_language Verilog [current_project]

# Add files
add_files -norecurse ../../picorv32/picorv32.v
add_files -norecurse ../tb/picorv32_hex_test.sv

# Set top module
set_property top picorv32_hex_test [current_fileset]
update_compile_order -fileset sources_1

puts "Project created successfully"

# Save project
save_project_as -force "D:/SoC_1/riscv_dv_picorv32/sim/real_sim/real_proj.xpr"

# Launch simulation
launch_simulation

# Add hexload argument
set_property -name {xsim.simulate.xsim.more_options} -value {-testplusarg hexload} -objects [get_filesets sim_1]

puts "Starting simulation..."
run 1000ns

puts "Simulation completed"
close_sim

