# Run with proper testbench
create_project -force proper_proj ./proper_sim -part xc7a100tcsg324-1
set_property target_language Verilog [current_project]

# Add RTL
add_files -norecurse ../../picorv32/picorv32.v

# Add proper testbench
add_files -norecurse ../tb/proper_hex_test.sv

# Set top
set_property top proper_hex_test [get_filesets sources_1]
set_property top proper_hex_test [get_filesets sim_1]

# Update compile order
update_compile_order -fileset sources_1

puts "Starting simulation..."
launch_simulation

run 100us
close_sim
exit 0

