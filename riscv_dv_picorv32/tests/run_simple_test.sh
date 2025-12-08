#!/bin/bash
# Simple test runner

echo "Running simple PicoRV32 test..."

# Setup environment
source scripts/setup_environment.sh

# Create test directory
mkdir -p tests/generated

# Compile simple test
echo "Compiling test..."
riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -static \
    -nostdlib -nostartfiles -T linker.ld \
    -o build/test.elf tests/basic_test.s

# Convert to hex
riscv64-unknown-elf-objcopy -O ihex build/test.elf build/test.hex

# Run simulation
echo "Running simulation..."
cd sim
make clean
make all

# Check results
if grep -q "TEST PASSED" ../build/xsim.log; then
    echo "✅ SUCCESS: Test passed!"
    exit 0
else
    echo "❌ FAILURE: Test failed!"
    echo "Check build/xsim.log for details"
    exit 1
fi
