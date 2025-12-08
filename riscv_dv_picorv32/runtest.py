
#### 2. Main Runner (`run_test.py`)
```python
#!/usr/bin/env python3
"""
run_test.py - Main verification runner for PicoRV32 RISCV-DV integration
"""
import os
import sys
import yaml
import argparse
import subprocess
from pathlib import Path

class PicoRV32Verification:
    def __init__(self):
        self.project_root = Path(__file__).parent
        self.riscv_dv_root = self.project_root.parent / "riscv-dv"
        self.picorv32_root = self.project_root.parent / "picorv32"
        
        # Setup directories
        self.build_dir = self.project_root / "build"
        self.tests_dir = self.project_root / "tests" / "generated"
        self.yaml_dir = self.project_root / "yaml"
        
        self.setup_directories()
        
    def setup_directories(self):
        """Create required directories"""
        self.build_dir.mkdir(exist_ok=True, parents=True)
        self.tests_dir.mkdir(exist_ok=True, parents=True)
        
    def generate_tests(self, isa="rv32im", iterations=100, output="asm"):
        """Generate tests using RISCV-DV"""
        print(f"Generating {iterations} {isa} tests...")
        
        # RISCV-DV command
        cmd = [
            sys.executable, str(self.riscv_dv_root / "run.py"),
            " --steps=1000",
            f"--iterations={iterations}",
            f"--isa={isa}",
            "--num_of_tests=1",
            "--target=picoRV32",
            f"--custom_target={self.yaml_dir / 'riscv_dv_extension.yaml'}",
            "--simulator=yaml",
            f"--simulator_yaml={self.yaml_dir / 'simulator.yaml'}",
            f"--output={self.tests_dir}",
            f"--verbose"
        ]
        
        # Run RISCV-DV
        subprocess.run(cmd, check=True)
        print(f"Tests generated in: {self.tests_dir}")
        
    def compile_tests(self):
        """Compile generated tests"""
        print("Compiling tests...")
        
        # Use provided script
        compile_script = self.project_root / "scripts" / "compile_tests.sh"
        subprocess.run(["bash", str(compile_script)], check=True)
        
    def run_simulation(self):
        """Run simulation using QuestaSim"""
        print("Running simulation...")
        
        sim_dir = self.project_root / "sim"
        
        # Run simulation using Makefile
        subprocess.run(["make", "-C", str(sim_dir), "run"], check=True)
        
    def analyze_results(self):
        """Analyze simulation results"""
        print("Analyzing results...")
        
        results_file = self.build_dir / "results.log"
        
        # Parse results
        with open(results_file, 'r') as f:
            lines = f.readlines()
            
        passed = 0
        failed = 0
        total = 0
        
        for line in lines:
            if "PASSED" in line:
                passed += 1
                total += 1
            elif "FAILED" in line:
                failed += 1
                total += 1
                
        # Generate summary
        summary = {
            "total_tests": total,
            "passed": passed,
            "failed": failed,
            "pass_rate": (passed / total * 100) if total > 0 else 0
        }
        
        # Write summary
        summary_file = self.build_dir / "summary.yaml"
        with open(summary_file, 'w') as f:
            yaml.dump(summary, f, default_flow_style=False)
            
        print(f"Results: {passed}/{total} passed ({summary['pass_rate']:.2f}%)")
        
    def run_full_flow(self, isa="rv32im", iterations=100):
        """Run complete verification flow"""
        print("=" * 50)
        print("PicoRV32 RISCV-DV Verification Flow")
        print("=" * 50)
        
        self.generate_tests(isa, iterations)
        self.compile_tests()
        self.run_simulation()
        self.analyze_results()
        
        print("=" * 50)
        print("Verification complete!")
        print("=" * 50)

def main():
    parser = argparse.ArgumentParser(description="PicoRV32 RISCV-DV Verification")
    parser.add_argument("--test", default="rv32im", help="ISA to test (rv32i, rv32im, etc.)")
    parser.add_argument("--iterations", type=int, default=100, help="Number of test iterations")
    parser.add_argument("--step", choices=["gen", "compile", "sim", "analyze", "all"], 
                       default="all", help="Which step to run")
    
    args = parser.parse_args()
    
    verif = PicoRV32Verification()
    
    if args.step == "gen":
        verif.generate_tests(args.test, args.iterations)
    elif args.step == "compile":
        verif.compile_tests()
    elif args.step == "sim":
        verif.run_simulation()
    elif args.step == "analyze":
        verif.analyze_results()
    else:  # all
        verif.run_full_flow(args.test, args.iterations)

if __name__ == "__main__":
    main()
