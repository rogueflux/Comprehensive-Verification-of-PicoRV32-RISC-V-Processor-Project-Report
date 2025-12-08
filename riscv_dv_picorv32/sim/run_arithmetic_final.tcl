# Run arithmetic test
create_project -force arithmetic_proj ./arithmetic_sim -part xc7a100tcsg324-1
set_property target_language Verilog [current_project]

add_files -norecurse ../../picorv32/picorv32.v
add_files -norecurse ../tb/run_arithmetic_test.sv

set_property top run_arithmetic_test [get_filesets sources_1]
set_property top run_arithmetic_test [get_filesets sim_1]

update_compile_order -fileset sources_1

puts "Running arithmetic basic test..."
launch_simulation

run 200us
close_sim
exit 0

