# PicoRV32 RISCV-DV Verification Makefile

.PHONY: all setup generate compile simulate clean help

# Configuration
TEST_NAME ?= riscv_arithmetic_basic_test_0
TEST_DIR = tests/final_20251207_085807
BUILD_DIR = build/final_20251207_085807

# Default target
all: setup compile simulate

# Setup environment - use bash directly
setup:
	@echo "=== Setting up environment ==="
	@bash -c "source scripts/setup_environment.sh && echo '✅ Environment setup complete'"

# Generate tests (already done)
generate:
	@echo "=== Tests already generated ==="
	@echo "Tests in: $(TEST_DIR)"
	@ls -la $(TEST_DIR)/asm_test/*.S 2>/dev/null || echo "No test files found"

# Compile tests
compile:
	@echo "=== Compiling tests ==="
	@bash -c "source scripts/setup_environment.sh && ./scripts/compile_riscv_dv_tests.sh"
	@echo "✅ Tests compiled in: $(BUILD_DIR)"

# Run simulation with Vivado
simulate:
	@echo "=== Running Vivado Simulation ==="
	@echo "Using test: $(TEST_NAME)"
	@if [ -f "$(BUILD_DIR)/$(TEST_NAME).hex" ]; then \
		cp "$(BUILD_DIR)/$(TEST_NAME).hex" sim/test.hex; \
		echo "Test program copied: $(TEST_NAME).hex"; \
	else \
		echo "❌ ERROR: Test file not found: $(BUILD_DIR)/$(TEST_NAME).hex"; \
		echo "Available tests:"; \
		ls -la $(BUILD_DIR)/*.hex 2>/dev/null || echo "No HEX files found"; \
		exit 1; \
	fi
	@echo "Starting Vivado simulation..."
	@cd sim && vivado -mode batch -source run_vivado_simulation.tcl 2>&1 | grep -E "PASSED|FAILED|TIMEOUT|ERROR|Test program loaded"
	@echo "✅ Simulation complete"
	@echo "Check sim/vivado_sim/xsim.log for details"

# Run all tests
run_all:
	@echo "=== Running all tests ==="
	@bash -c "source scripts/setup_environment.sh"
	@for hexfile in $(BUILD_DIR)/*.hex; do \
		if [ -f "$$hexfile" ]; then \
			test_name=$$(basename $$hexfile .hex); \
			echo ""; \
			echo "========================================"; \
			echo "Running test: $$test_name"; \
			echo "========================================"; \
			cp "$$hexfile" sim/test.hex; \
			cd sim && vivado -mode batch -source run_vivado_simulation.tcl 2>&1 | grep -E "PASSED|FAILED|TIMEOUT|Test program loaded|SIMULATION"; \
			cd ..; \
			sleep 2; \
		fi \
	done

# Quick test - compile and run one
test: compile simulate

# Clean
clean:
	@echo "=== Cleaning simulation files ==="
	rm -rf sim/test.hex sim/vivado_sim sim/*.log sim/*.wcfg sim/*.jou sim/*.str 2>/dev/null || true
	@echo "✅ Clean complete"

clean_all: clean
	@echo "=== Cleaning all generated files ==="
	rm -rf build/* tests/*_* 2>/dev/null || true
	@echo "✅ All clean"

# List available tests
list:
	@echo "=== Available tests ==="
	@if [ -d "$(BUILD_DIR)" ]; then \
		echo "ELF files:"; \
		ls -la $(BUILD_DIR)/*.elf 2>/dev/null | awk '{print "  " $$9}'; \
		echo ""; \
		echo "HEX files:"; \
		ls -la $(BUILD_DIR)/*.hex 2>/dev/null | awk '{print "  " $$9}'; \
	else \
		echo "Build directory not found: $(BUILD_DIR)"; \
	fi

# Check setup
check:
	@echo "=== Checking environment ==="
	@bash -c "source scripts/setup_environment.sh 2>/dev/null && echo '✅ Environment variables set'"
	@which vivado >/dev/null 2>&1 && echo "✅ Vivado found: $$(which vivado)" || echo "❌ Vivado not found"
	@which riscv64-unknown-elf-gcc >/dev/null 2>&1 && echo "✅ RISC-V GCC found: $$(which riscv64-unknown-elf-gcc)" || echo "❌ RISC-V GCC not found"
	@echo "✅ Setup check complete"

# Help
help:
	@echo "PicoRV32 RISCV-DV Verification Makefile"
	@echo "========================================"
	@echo ""
	@echo "Available targets:"
	@echo "  all       - Run complete flow (setup, compile, simulate)"
	@echo "  setup     - Setup environment"
	@echo "  compile   - Compile tests"
	@echo "  simulate  - Run Vivado simulation (default: riscv_arithmetic_basic_test_0)"
	@echo "  run_all   - Run all generated tests"
	@echo "  test      - Quick test (compile + simulate)"
	@echo "  list      - List available tests"
	@echo "  check     - Check environment setup"
	@echo "  clean     - Clean simulation files"
	@echo "  clean_all - Clean everything"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Usage examples:"
	@echo "  make simulate TEST_NAME=riscv_load_store_test_0"
	@echo "  make run_all"
	@echo "  make list"
	@echo "  make check"
	@echo ""
	@echo "Current test directory: $(TEST_DIR)"
	@echo "Current build directory: $(BUILD_DIR)"

