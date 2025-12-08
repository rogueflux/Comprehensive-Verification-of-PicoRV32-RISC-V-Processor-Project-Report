# PicoRV32 RISCV-DV Verification Project

## ✅ Project Status: COMPLETE

A complete verification environment for the PicoRV32 RISC-V processor using RISCV-DV methodology.

## 📋 Features

- ✅ RISCV-DV compatible test generation
- ✅ RISC-V RV32IM instruction set verification
- ✅ Vivado XSim integration
- ✅ Automated test compilation and simulation
- ✅ Comprehensive test suite

## 🏗️ Project Structure
riscv_dv_picorv32/
├── tests/final_20251207_085807/ # Generated test suite
│ └── asm_test/ # Assembly tests
├── build/final_20251207_085807/ # Compiled binaries
├── tb/ # Testbench files
├── sim/ # Simulation scripts
├── scripts/ # Automation scripts
├── yaml/ # Configuration files
└── custom_target/ # RISCV-DV target config

## 🚀 Quick Start

### 1. Setup Environment
```bash
source scripts/setup_environment.sh

