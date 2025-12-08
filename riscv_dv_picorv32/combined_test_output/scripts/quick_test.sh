#!/bin/bash

echo "Running PicoRV32 Arithmetic Test..."
echo "Output will be saved to test_output/"

# Clean previous
rm -rf test_output
mkdir -p test_output

# Run simulation
cd sim
echo "Starting Vivado simulation..."
vivado -mode batch -source run_arithmetic_verbose.tcl 2>&1 | tee ../test_output/simulation.log

cd ..

echo ""
echo "========================================"
echo "EXTRACTING KEY RESULTS:"
echo "========================================"

# Get test result
if grep -q "✅ ALL ARITHMETIC TESTS PASSED" test_output/simulation.log; then
    echo "✅ TEST PASSED!"
else
    echo "❌ TEST FAILED!"
fi

echo ""
echo "Key Metrics:"
grep -E "Total Instructions|Final Program Counter|Simulation Time" test_output/simulation.log

echo ""
echo "Memory Results:"
grep -A 5 "DATA MEMORY RESULTS" test_output/simulation.log | tail -5

echo ""
echo "Full log available at: test_output/simulation.log"

