# Simple direct test - FIXED
create_project -force direct_proj ./direct_sim -part xc7a100tcsg324-1
set_property target_language Verilog [current_project]

# Add files
add_files -norecurse ../../picorv32/picorv32.v
add_files -norecurse simple_direct_test.sv

# Set top for BOTH filesets
set_property top simple_direct_test [current_fileset]
set_property top simple_direct_test [get_filesets sim_1]

# Launch simulation
launch_simulation

# Run
run 50us

close_sim
exit 0

