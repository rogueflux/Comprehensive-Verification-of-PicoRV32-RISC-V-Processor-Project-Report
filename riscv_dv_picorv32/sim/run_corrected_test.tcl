# Corrected test with proper paths
create_project -force corrected_proj ./corrected_sim -part xc7a100tcsg324-1
set_property target_language Verilog [current_project]

# Add RTL
add_files -norecurse ../../picorv32/picorv32.v

# Add testbench from tb/ directory
add_files -norecurse ../tb/simple_hex_test.sv

# Set top module
set_property top simple_hex_test [get_filesets sources_1]
set_property top simple_hex_test [get_filesets sim_1]

# Update compile order
update_compile_order -fileset sources_1

puts "Starting simulation..."
launch_simulation

# Run simulation
run 50us

close_sim
exit 0

