// RISC-V core setting for PicoRV32
// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Configuration for PicoRV32 processor
// PicoRV32 supports RV32IM instruction set

// XLEN
parameter int XLEN = 32;

// Parameter for test generator
parameter string UNKNOWN_INSTR = "";  // Treat unknown instruction as illegal

// ISA configuration
parameter bit RV32E = 0;
parameter bit RV32M = 1;  // PicoRV32 has multiply/divide
parameter bit RV32A = 0;
parameter bit RV32F = 0;
parameter bit RV32D = 0;
parameter bit RV32C = 0;  // PicoRV32 doesn't support compressed
parameter bit RV32B = 0;

// Address configuration
parameter int MAX_INSTR_CNT = 10000;
parameter int MAX_CYCLE_CNT  = 100000;

// Interrupt configuration  
parameter bit SUPPORT_SUPER = 0;
parameter bit SUPPORT_USER  = 0;

// Enable functional coverage
parameter bit ENABLE_FC = 1;

// Trace log format
parameter string TRACE_FORMAT = "basic";

// PMP configuration
parameter int PMP_NUM_REGIONS = 0;
parameter int PMP_GRANULARITY = 0;

// Vector configuration
parameter bit VECTOR_EXT = 0;

// Debug configuration
parameter bit DEBUG_EXT = 0;

