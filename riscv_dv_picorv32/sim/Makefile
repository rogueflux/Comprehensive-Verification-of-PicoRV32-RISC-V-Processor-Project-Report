# Simulation Makefile for PicoRV32 RISCV-DV verification with Vivado

# Configuration
PROJECT_ROOT = ..
RTL_DIR = $(PROJECT_ROOT)/../picorv32
TB_DIR = $(PROJECT_ROOT)/tb
TESTS_DIR = $(PROJECT_ROOT)/tests/generated
BUILD_DIR = $(PROJECT_ROOT)/build

# Tools - Use Vivado tools
VLOG = xvlog
ELAB = xelab
SIM = xsim
PYTHON = python3

# Simulation options
VLOG_OPTS = -sv --incr --relax
ELAB_OPTS = --debug typical --relax -L xil_defaultlib
SIM_OPTS = -tclbatch sim_vivado.tcl

# Test program
TEST_PROGRAM = $(BUILD_DIR)/test.hex

# Default target
all: compile elaborate simulate

# Compile design
compile:
	$(VLOG) $(VLOG_OPTS) $(RTL_DIR)/picorv32.v
	$(VLOG) $(VLOG_OPTS) $(TB_DIR)/picorv32_dv_wrapper.sv
	@echo "Compilation complete"

# Elaborate design
elaborate:
	$(ELAB) $(ELAB_OPTS) work.top

# Run simulation
simulate: $(TEST_PROGRAM)
	cp $(TEST_PROGRAM) ./test.hex
	$(SIM) work.top $(SIM_OPTS)
	cp xsim.log $(BUILD_DIR)/

# Convert test program to HEX
$(BUILD_DIR)/test.hex: $(TESTS_DIR)/test.elf
	riscv64-unknown-elf-objcopy -O ihex $< $@

# Clean
clean:
	rm -rf xsim.dir *.log *.pb test.hex webtalk*.log
	rm -rf $(BUILD_DIR)/*.hex

clean_all: clean
	rm -rf $(TESTS_DIR)/* $(BUILD_DIR)/*

# Help
help:
	@echo "Available targets:"
	@echo "  all       - Compile, elaborate and simulate (default)"
	@echo "  compile   - Compile design only"
	@echo "  elaborate - Elaborate design only"
	@echo "  simulate  - Run simulation only"
	@echo "  clean     - Clean simulation files"
	@echo "  clean_all - Clean everything"

.PHONY: all compile elaborate simulate clean clean_all help