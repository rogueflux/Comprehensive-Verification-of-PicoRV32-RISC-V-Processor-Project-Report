# Vivado XSim simulation script for PicoRV32

# Set up simulation
set SIM_TIME "100us"

# Create project
create_project -force sim_proj ./vivado_project -part xc7a100tcsg324-1
set_property target_language Verilog [current_project]

# Add source files
add_files -norecurse {
    ../../picorv32/picorv32.v
    ../tb/picorv32_dv_wrapper.sv
}

# Set top module
set_property top picorv32_dv_wrapper [current_fileset]

# Compile design
update_compile_order -fileset sources_1

# Load test program
if {[file exists "test.hex"]} {
    puts "Loading test program from test.hex..."
    # Note: Loading memory depends on your memory model implementation
    # For now, we'll assume the testbench handles loading
} else {
    puts "ERROR: test.hex not found"
    puts "Make sure test compilation completed successfully"
    exit 1
}

# Launch simulation
launch_simulation

# Initialize
run 100ns

# Apply reset
add_force reset 1
run 100ns
add_force reset 0
run 100ns

# Start test
add_force test_start 1
run 20ns
add_force test_start 0

# Run for specified time
run $SIM_TIME

# Check results
set test_done [get_value -radix unsigned /test_done]
set test_pass [get_value -radix unsigned /test_pass]
set test_result [get_value -radix unsigned /test_result]

if {$test_done == 1} {
    if {$test_pass == 1} {
        puts "========================================"
        puts "TEST PASSED! Result: $test_result"
        puts "========================================"
    } else {
        puts "========================================"
        puts "TEST FAILED! Result: $test_result"
        puts "========================================"
    }
} else {
    puts "========================================"
    puts "TEST TIMEOUT - Simulation ran for $SIM_TIME"
    puts "========================================"
}

# Save waveform if needed
if {[info exists ::env(SAVE_WAVEFORM)] && $::env(SAVE_WAVEFORM) == 1} {
    save_wave_config waveform.wcfg
    puts "Waveform saved to waveform.wcfg"
}

# Close simulation
close_sim
exit
