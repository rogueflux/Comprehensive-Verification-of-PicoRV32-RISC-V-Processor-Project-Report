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
