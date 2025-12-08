# QuestaSim simulation script

# Load test program into memory
proc load_test_program {} {
    # Read HEX file
    if {[file exists "test.hex"]} {
        echo "Loading test program..."
        
        # Create memory instance and load
        mem load -infile test.hex -format hex /top/imem/memory
        
        echo "Test program loaded"
    } else {
        echo "ERROR: test.hex not found"
        exit 1
    }
}

# Run simulation
proc run_simulation {} {
    # Reset
    force -freeze /top/reset 1 0
    run 100 ns
    force -freeze /top/reset 0 0
    run 10 ns
    
    # Start test
    force -freeze /top/test_start 1 0
    run 20 ns
    force -freeze /top/test_start 0 0
    
    # Run until test done
    while {[examine /top/test_done] == 0} {
        run 1000 ns
    }
    
    # Check result
    set result [examine /top/test_result]
    set pass [examine /top/test_pass]
    
    if {$pass == 1} {
        echo "TEST PASSED: Result = $result"
    } else {
        echo "TEST FAILED: Result = $result"
    }
    
    # Save coverage
    if {[info exists ::env(COVERAGE)] && $::env(COVERAGE) == "1"} {
        coverage save -onexit coverage.ucdb
        echo "Coverage saved to coverage.ucdb"
    }
}

# Main simulation flow
echo "Starting PicoRV32 simulation..."

# Load test
load_test_program

# Run simulation
run_simulation

# Exit
echo "Simulation complete"
quit -sim
exit
