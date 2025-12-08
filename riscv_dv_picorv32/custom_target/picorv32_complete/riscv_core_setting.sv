// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// RISC-V register width
parameter int XLEN = 32;

// Supported ISA extensions
parameter bit RV32E = 0;
parameter bit RV32M = 1;  // PicoRV32 has multiply/divide
parameter bit RV32C = 0;  // PicoRV32 doesn't support compressed
parameter bit RV32F = 0;
parameter bit RV32D = 0;
parameter bit RV32A = 0;
parameter bit RV32B = 0;

// Unsupported extensions for PicoRV32
parameter bit VECTOR_EXT = 0;
parameter bit BITMANIP_EXT = 0;

// Privilege modes
parameter bit SUPPORT_SUPER = 0;
parameter bit SUPPORT_USER = 0;

// Test generation parameters
parameter int MAX_INSTR_CNT = 10000;
parameter int MAX_CYCLE_CNT  = 100000;

// PMP (Physical Memory Protection) not supported in PicoRV32
parameter int PMP_NUM_REGIONS = 0;
parameter int PMP_GRANULARITY = 0;

// Debug extension not supported
parameter bit DEBUG_EXT = 0;

// Functional coverage
parameter bit ENABLE_FC = 1;

// Trace log format
parameter string TRACE_FORMAT = "basic";

// Unknown instruction handling
parameter string UNKNOWN_INSTR = "";

