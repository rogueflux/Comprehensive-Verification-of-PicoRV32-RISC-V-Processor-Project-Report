# Run arithmetic test with error checking
create_project -force arith_verbose ./arith_verbose_sim -part xc7a100tcsg324-1
set_property target_language Verilog [current_project]

add_files -norecurse ../../picorv32/picorv32.v

# Check if testbench exists
set tb_file "../tb/run_arithmetic_test.sv"
if {[file exists $tb_file]} {
    add_files -norecurse $tb_file
    puts "✅ Testbench added: $tb_file"
} else {
    puts "❌ ERROR: Testbench not found: $tb_file"
    exit 1
}

set_property top run_arithmetic_test [get_filesets sources_1]
set_property top run_arithmetic_test [get_filesets sim_1]

update_compile_order -fileset sources_1

puts "Starting arithmetic test simulation..."
launch_simulation

# Run for enough time
run 300us

close_sim
exit 0

