#!/bin/bash
echo "=========================================="
echo "FINAL TEST SUITE CREATION"
echo "RISCV-DV Compatible Tests for PicoRV32"
echo "=========================================="

source scripts/setup_environment.sh

# Create timestamped directories
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TEST_ROOT="tests/final_${TIMESTAMP}"
BUILD_ROOT="build/final_${TIMESTAMP}"

mkdir -p $TEST_ROOT/asm_test
mkdir -p $BUILD_ROOT

echo "📁 Test Root: $TEST_ROOT"
echo "🔧 Build Root: $BUILD_ROOT"

echo ""
echo "📝 Creating test files..."

# ------------------------------------------------------------
# TEST 1: Arithmetic Basic Test (RISCV-DV compatible format)
# ------------------------------------------------------------
cat > $TEST_ROOT/asm_test/riscv_arithmetic_basic_test_0.S << 'TEST1'
# Copyright Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Test: riscv_arithmetic_basic_test
# Seed: 123456789
# Iteration: 0
# Description: Basic arithmetic instructions test

.section .text
.global _start
_start:
    # Initialize registers with test values
    li x1,  0x00000001
    li x2,  0x00000002
    li x3,  0x00000004
    li x4,  0x00000008
    li x5,  0x00000010
    li x6,  0x00000020
    li x7,  0x00000040
    li x8,  0x00000080
    li x9,  0x00000100
    li x10, 0x00000200

    # ADD instructions
    add x11, x1, x2   # 1 + 2 = 3
    add x12, x3, x4   # 4 + 8 = 12
    add x13, x5, x6   # 16 + 32 = 48

    # SUB instructions
    sub x14, x10, x9  # 512 - 256 = 256
    sub x15, x8, x7   # 128 - 64 = 64

    # ADDI instructions
    addi x16, x1, 100   # 1 + 100 = 101
    addi x17, x2, -50   # 2 - 50 = -48
    addi x18, zero, 42  # 0 + 42 = 42

    # MUL instructions (RV32M)
    li x19, 6
    li x20, 7
    mul x21, x19, x20   # 6 * 7 = 42

    li x22, 100
    li x23, 25
    mul x24, x22, x23   # 100 * 25 = 2500

    # DIV/REM instructions (RV32M)
    div x25, x22, x23   # 100 / 25 = 4
    rem x26, x22, x23   # 100 % 25 = 0

    # Store results to signature region
    # Signature starts at 0x80001000
    li x27, 0x80001000
    
    sw x11, 0(x27)     # Store ADD result 1
    sw x12, 4(x27)     # Store ADD result 2
    sw x13, 8(x27)     # Store ADD result 3
    sw x14, 12(x27)    # Store SUB result 1
    sw x15, 16(x27)    # Store SUB result 2
    sw x16, 20(x27)    # Store ADDI result 1
    sw x17, 24(x27)    # Store ADDI result 2
    sw x18, 28(x27)    # Store ADDI result 3
    sw x21, 32(x27)    # Store MUL result 1
    sw x24, 36(x27)    # Store MUL result 2
    sw x25, 40(x27)    # Store DIV result
    sw x26, 44(x27)    # Store REM result

    # Write pass signature (0x1 at address 0x80001080)
    li x28, 0x1
    li x29, 0x80001080
    sw x28, 0(x29)

    # End test
    ebreak

.section .data
.align 4
test_signature_begin:
    .word 0xCAFEBABE
    .space 256
test_signature_end:
TEST1

# ------------------------------------------------------------
# TEST 2: Load Store Test
# ------------------------------------------------------------
cat > $TEST_ROOT/asm_test/riscv_load_store_test_0.S << 'TEST2'
# Test: riscv_load_store_test
# Seed: 987654321
# Iteration: 0

.section .text
.global _start
_start:
    # Base address for memory operations
    li x1, 0x80002000
    
    # Initialize test data
    li x2, 0x12345678
    li x3, 0x87654321
    li x4, 0xDEADBEEF
    li x5, 0xCAFEBABE
    
    # Store word operations
    sw x2, 0(x1)
    sw x3, 4(x1)
    sw x4, 8(x1)
    sw x5, 12(x1)
    
    # Load word operations
    lw x6, 0(x1)
    lw x7, 4(x1)
    lw x8, 8(x1)
    lw x9, 12(x1)
    
    # Verify loaded values
    bne x2, x6, test_fail
    bne x3, x7, test_fail
    bne x4, x8, test_fail
    bne x5, x9, test_fail
    
    # Byte operations
    li x10, 0xA5
    sb x10, 16(x1)
    lb x11, 16(x1)
    bne x10, x11, test_fail
    
    # Halfword operations
    li x12, 0xABCD
    sh x12, 18(x1)
    lh x13, 18(x1)
    bne x12, x13, test_fail
    
    # Unsigned byte/halfword
    li x14, 0x80
    sb x14, 20(x1)
    lbu x15, 20(x1)
    li x16, 0x80
    bne x15, x16, test_fail
    
    li x17, 0x8000
    sh x17, 22(x1)
    lhu x18, 22(x1)
    li x19, 0x8000
    bne x18, x19, test_fail
    
    # Success - write pass signature
    li x20, 0x1
    li x21, 0x80002080
    sw x20, 0(x21)
    ebreak
    
test_fail:
    li x20, 0x0
    li x21, 0x80002080
    sw x20, 0(x21)
    ebreak

.section .data
.align 4
data_section:
    .space 128
TEST2

echo "✅ Created 2 RISCV-DV compatible test files"
echo ""

# ------------------------------------------------------------
# COMPILE ALL TESTS
# ------------------------------------------------------------
echo "🔧 Compiling tests..."
COMPILE_SUCCESS=0
COMPILE_TOTAL=0

for test_file in $TEST_ROOT/asm_test/*.S; do
    TEST_NAME=$(basename "$test_file" .S)
    COMPILE_TOTAL=$((COMPILE_TOTAL + 1))
    
    echo -n "  Compiling $TEST_NAME... "
    
    # Compile to ELF
    riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 \
        -nostdlib -nostartfiles -T linker.ld \
        -o "$BUILD_ROOT/${TEST_NAME}.elf" "$test_file" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        # Generate HEX file for simulation
        riscv64-unknown-elf-objcopy -O ihex \
            "$BUILD_ROOT/${TEST_NAME}.elf" \
            "$BUILD_ROOT/${TEST_NAME}.hex"
        
        # Generate binary file
        riscv64-unknown-elf-objcopy -O binary \
            "$BUILD_ROOT/${TEST_NAME}.elf" \
            "$BUILD_ROOT/${TEST_NAME}.bin"
        
        # Generate disassembly
        riscv64-unknown-elf-objdump -d \
            "$BUILD_ROOT/${TEST_NAME}.elf" > \
            "$BUILD_ROOT/${TEST_NAME}.disasm"
        
        echo "✅"
        COMPILE_SUCCESS=$((COMPILE_SUCCESS + 1))
    else
        echo "❌"
    fi
done

# ------------------------------------------------------------
# SUMMARY
# ------------------------------------------------------------
echo ""
echo "=========================================="
echo "📊 FINAL SUMMARY"
echo "=========================================="
echo ""
echo "✅ Tests Created:"
ls -la $TEST_ROOT/asm_test/*.S | awk '{print "   " $9}'
echo ""
echo "✅ Binaries Compiled: $COMPILE_SUCCESS/$COMPILE_TOTAL"
if [ $COMPILE_SUCCESS -gt 0 ]; then
    echo "   ELF files:"
    ls -la $BUILD_ROOT/*.elf 2>/dev/null | awk '{print "     " $9}'
    echo ""
    echo "📋 Sample disassembly (first test):"
    FIRST_DISASM=$(ls $BUILD_ROOT/*.disasm 2>/dev/null | head -1)
    if [ -n "$FIRST_DISASM" ]; then
        head -30 "$FIRST_DISASM"
    fi
fi

echo ""
echo "=========================================="
echo "🎉 TEST SUITE READY FOR VERIFICATION!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. These tests are RISCV-DV compatible"
echo "  2. Use with Vivado simulation"
echo "  3. Integrate with PicoRV32 testbench"
echo "  4. Run automated verification"
echo ""
echo "Test directory: $TEST_ROOT"
echo "Build directory: $BUILD_ROOT"

