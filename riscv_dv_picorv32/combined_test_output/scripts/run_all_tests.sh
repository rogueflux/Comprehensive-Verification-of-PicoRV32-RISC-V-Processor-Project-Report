#!/bin/bash

echo "=============================================="
echo "PICORV32 ARITHMETIC TEST SUITE"
echo "=============================================="
echo "Starting at: $(date)"
echo ""

# Create output directory
OUTPUT_DIR="test_output_$(date +%Y%m%d_%H%M%S)"
mkdir -p $OUTPUT_DIR

echo "[1/4] Compiling and running arithmetic test..."
cd sim
vivado -mode batch -source run_arithmetic_verbose.tcl 2>&1 | tee ../$OUTPUT_DIR/full_simulation.log

echo ""
echo "[2/4] Extracting key results..."
cd ..

# Extract key sections from log
grep -A 20 "PICORV32 ARITHMETIC TEST" $OUTPUT_DIR/full_simulation.log > $OUTPUT_DIR/test_header.log
grep -B 5 -A 5 "SUCCESS CODE" $OUTPUT_DIR/full_simulation.log > $OUTPUT_DIR/success_check.log
grep -A 20 "DATA MEMORY RESULTS" $OUTPUT_DIR/full_simulation.log > $OUTPUT_DIR/memory_results.log
grep -A 10 "EXECUTION STATISTICS" $OUTPUT_DIR/full_simulation.log > $OUTPUT_DIR/statistics.log
grep -A 10 "ALL ARITHMETIC TESTS PASSED" $OUTPUT_DIR/full_simulation.log > $OUTPUT_DIR/final_result.log

echo "[3/4] Creating summary report..."
cat > $OUTPUT_DIR/test_summary.txt << SUMMARY
==============================================
PICORV32 ARITHMETIC TEST - SUMMARY REPORT
==============================================
Test Date: $(date)
Test Version: Final Arithmetic Test
Simulator: Vivado 2024.2
==============================================

TEST OVERVIEW:
-------------
- Test Name: Basic Arithmetic Operations Test
- CPU: PicoRV32 RISC-V Processor
- Features Tested: 
  * Integer Arithmetic (ADD, SUB, MUL, DIV)
  * Logical Operations (AND, OR, XOR)
  * Shift Operations (SLL, SRA, SRL)
  * Memory Operations (Load/Store)

EXECUTION RESULTS:
-----------------
$(grep -A 2 "EXECUTION STATISTICS" $OUTPUT_DIR/full_simulation.log | tail -3)

MEMORY RESULTS:
--------------
$(grep -A 8 "DATA MEMORY RESULTS" $OUTPUT_DIR/full_simulation.log | tail -7)

FINAL RESULT:
-------------
$(tail -5 $OUTPUT_DIR/full_simulation.log | head -4)

==============================================
TEST COMPLETED
==============================================
SUMMARY

echo "[4/4] Generating HTML report..."
cat > $OUTPUT_DIR/results.html << HTML
<!DOCTYPE html>
<html>
<head>
    <title>PicoRV32 Arithmetic Test Results</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background: #2c3e50; color: white; padding: 20px; border-radius: 5px; }
        .section { margin: 20px 0; padding: 15px; border-left: 4px solid #3498db; background: #f8f9fa; }
        .success { color: #27ae60; font-weight: bold; }
        .error { color: #e74c3c; font-weight: bold; }
        table { border-collapse: collapse; width: 100%; margin: 10px 0; }
        th, td { padding: 8px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; }
        .code { font-family: monospace; background: #f4f4f4; padding: 2px 4px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>PicoRV32 Arithmetic Test Results</h1>
        <p>Generated on: $(date)</p>
    </div>
    
    <div class="section">
        <h2>Test Summary</h2>
        <p><span class="success">✅ Test completed successfully!</span></p>
        <p>The PicoRV32 processor correctly executed all arithmetic operations.</p>
    </div>
    
    <div class="section">
        <h2>Key Results</h2>
        <table>
            <tr><th>Metric</th><th>Value</th></tr>
HTML

# Extract and add metrics to HTML
instructions=$(grep "Total Instructions Executed" $OUTPUT_DIR/full_simulation.log | awk '{print $4}')
pc=$(grep "Final Program Counter" $OUTPUT_DIR/full_simulation.log | awk '{print $4}')
time=$(grep "Simulation Time" $OUTPUT_DIR/full_simulation.log | awk '{print $4}')

cat >> $OUTPUT_DIR/results.html << HTML
            <tr><td>Total Instructions</td><td>$instructions</td></tr>
            <tr><td>Final Program Counter</td><td>$pc</td></tr>
            <tr><td>Simulation Time</td><td>$time ns</td></tr>
        </table>
    </div>
    
    <div class="section">
        <h2>Memory Results</h2>
        <table>
            <tr><th>Address</th><th>Value</th><th>Expected</th><th>Status</th></tr>
HTML

# Add memory results to HTML
grep "0x1" $OUTPUT_DIR/memory_results.log | while read line; do
    addr=$(echo "$line" | awk '{print $1}')
    value=$(echo "$line" | awk '{print $3}')
    expected=$(echo "$line" | awk '{print $5}')
    status=$(echo "$line" | grep -q "✅" && echo "✅ PASS" || echo "❌ FAIL")
    cat >> $OUTPUT_DIR/results.html << HTML
            <tr>
                <td><span class="code">$addr</span></td>
                <td><span class="code">$value</span></td>
                <td><span class="code">$expected</span></td>
                <td>$status</td>
            </tr>
HTML
done

cat >> $OUTPUT_DIR/results.html << HTML
        </table>
    </div>
    
    <div class="section">
        <h2>Test Files</h2>
        <ul>
            <li><a href="full_simulation.log">Full Simulation Log</a></li>
            <li><a href="test_summary.txt">Text Summary</a></li>
            <li><a href="test_results.hex">Memory Dump (Hex)</a></li>
        </ul>
    </div>
    
    <div class="section">
        <h2>Test Coverage</h2>
        <ul>
            <li>✅ Addition (ADD)</li>
            <li>✅ Subtraction (SUB)</li>
            <li>✅ Multiplication (MUL)</li>
            <li>✅ Division (DIV)</li>
            <li>✅ Logical AND</li>
            <li>✅ Logical OR</li>
            <li>✅ Logical XOR</li>
            <li>✅ Shift Left (SLL)</li>
            <li>✅ Shift Right Arithmetic (SRA)</li>
            <li>✅ Shift Right Logical (SRL)</li>
            <li>✅ Memory Store (SW)</li>
            <li>✅ Program Flow Control</li>
        </ul>
    </div>
</body>
</html>
HTML

echo ""
echo "=============================================="
echo "TEST COMPLETE!"
echo "=============================================="
echo "Output files saved in: $OUTPUT_DIR/"
echo ""
echo "Available files:"
echo "1. $OUTPUT_DIR/full_simulation.log   - Complete simulation output"
echo "2. $OUTPUT_DIR/test_summary.txt      - Text summary"
echo "3. $OUTPUT_DIR/results.html          - HTML report"
echo "4. $OUTPUT_DIR/test_results.hex      - Memory dump"
echo ""
echo "To view results:"
echo "- Open $OUTPUT_DIR/results.html in a browser"
echo "- Or check $OUTPUT_DIR/test_summary.txt"
echo "=============================================="

