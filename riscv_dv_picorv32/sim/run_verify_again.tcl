# Run the verification test that works
create_project -force verify2_proj ./verify2_sim -part xc7a100tcsg324-1
set_property target_language Verilog [current_project]

add_files -norecurse ../../picorv32/picorv32.v
add_files -norecurse ../tb/verify_core.sv

set_property top verify_core [get_filesets sources_1]
set_property top verify_core [get_filesets sim_1]

update_compile_order -fileset sources_1

launch_simulation
run 15000ns
close_sim
exit 0

