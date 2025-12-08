#!/bin/bash

# Find the latest test output directory
latest_dir=$(ls -td test_output_* | head -1)

if [ -z "$latest_dir" ]; then
    echo "No test output directories found!"
    echo "Run ./run_all_tests.sh first"
    exit 1
fi

echo "=============================================="
echo "VIEWING TEST RESULTS FROM: $latest_dir"
echo "=============================================="
echo ""

echo "1. TEST SUMMARY:"
echo "----------------"
cat "$latest_dir/test_summary.txt"
echo ""

echo "2. KEY METRICS:"
echo "---------------"
grep -E "Total Instructions|Final Program Counter|Simulation Time|Errors detected" "$latest_dir/full_simulation.log" | tail -4
echo ""

echo "3. MEMORY RESULTS:"
echo "------------------"
if [ -f "$latest_dir/memory_results.log" ]; then
    cat "$latest_dir/memory_results.log"
else
    grep -A 8 "DATA MEMORY RESULTS" "$latest_dir/full_simulation.log" 2>/dev/null || echo "Memory results not found in log"
fi
echo ""

echo "4. FINAL VERDICT:"
echo "-----------------"
if grep -q "✅ ALL TESTS PASSED" "$latest_dir/full_simulation.log"; then
    echo "✅ ALL TESTS PASSED SUCCESSFULLY!"
else
    echo "❌ SOME TESTS FAILED!"
fi
echo ""

echo "5. AVAILABLE FILES:"
echo "-------------------"
ls -la "$latest_dir/" | awk '{print $9, "("$5" bytes)"}'
echo ""

echo "=============================================="
echo "To open HTML report in browser:"
echo "file:///d/SoC_1/riscv_dv_picorv32/$latest_dir/results.html"
echo "=============================================="

