# Simple test with always_load_hex
create_project -force test_proj ./test_sim -part xc7a100tcsg324-1
set_property target_language Verilog [current_project]

add_files -norecurse ../../picorv32/picorv32.v
add_files -norecurse ../tb/always_load_hex.sv

set_property top always_load_hex [current_fileset]

launch_simulation
run 50us
close_sim
exit 0

