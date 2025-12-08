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
