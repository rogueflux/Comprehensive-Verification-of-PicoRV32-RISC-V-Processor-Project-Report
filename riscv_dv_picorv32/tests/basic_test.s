# Basic test
.section .text
.global _start

_start:
    li x1, 10
    li x2, 20
    add x3, x1, x2    # 30
    li x4, 1          # Pass
    ebreak
