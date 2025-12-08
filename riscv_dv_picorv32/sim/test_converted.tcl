create_project -force conv_proj ./conv_sim -part xc7a100tcsg324-1
set_property target_language Verilog [current_project]

add_files -norecurse ../../picorv32/picorv32.v

# Create a simple testbench that loads the converted hex
add_files -norecurse {
    ../tb/simple_test.sv
}

set_property top simple_test [current_fileset]

launch_simulation
run 100us
close_sim
