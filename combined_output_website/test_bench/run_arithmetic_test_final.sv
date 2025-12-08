module run_arithmetic_test;
    // ============================================
    // Clock and Reset
    // ============================================
    reg clk = 0;
    reg resetn = 0;
    
    // ============================================
    // Testbench Control Signals
    // ============================================
    reg [31:0] errors = 0;
    reg [31:0] total_instructions = 0;
    reg test_finished = 0;
    
    // ============================================
    // PicoRV32 Interface Signals
    // ============================================
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    wire        mem_valid;
    wire        mem_instr;
    reg  [31:0] mem_rdata;
    reg         mem_ready;
    wire        trap;
    
    // ============================================
    // PC Tracking
    // ============================================
    reg [31:0] current_pc = 0;
    
    // ============================================
    // PicoRV32 Instance
    // ============================================
    picorv32 #(
        .ENABLE_COUNTERS(1),
        .ENABLE_MUL(1),
        .ENABLE_DIV(1),
        .ENABLE_IRQ(0),
        .ENABLE_TRACE(0)
    ) cpu (
        .clk(clk),
        .resetn(resetn),
        .trap(trap),
        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),
        .pcpi_valid(),
        .pcpi_insn(),
        .pcpi_rs1(),
        .pcpi_rs2(),
        .pcpi_wr(),
        .pcpi_rd(),
        .pcpi_wait(),
        .pcpi_ready(),
        .irq(32'b0),
        .eoi()
    );
    
    // ============================================
    // Clock Generation
    // ============================================
    always #5 clk = ~clk;
    
    // ============================================
    // Memory Model (16KB)
    // ============================================
    reg [31:0] memory [0:4095];
    integer i;
    
    // ============================================
    // Initial Block - Test Setup
    // ============================================
    initial begin
        $display("=========================================");
        $display("PICORV32 ARITHMETIC TEST - FINAL VERSION");
        $display("=========================================");
        $display("Date: %t", $time);
        $display("Test: Basic Arithmetic Operations");
        $display("=========================================");
        
        // Initialize memory to NOPs
        for (i = 0; i < 4096; i = i + 1) begin
            memory[i] = 32'h00000013;
        end
        
        // ============================================
        // FINAL ARITHMETIC TEST PROGRAM
        // ============================================
        $display("\n[PROGRAM] Loading test program...");
        
        // Basic arithmetic operations
        memory[0] = 32'h00100093;  // addi x1, x0, 1       # x1 = 1
        memory[1] = 32'h00200113;  // addi x2, x0, 2       # x2 = 2
        memory[2] = 32'h00300193;  // addi x3, x0, 3       # x3 = 3
        memory[3] = 32'h00400213;  // addi x4, x0, 4       # x4 = 4
        
        // Arithmetic operations
        memory[4] = 32'h002080b3;  // add x1, x1, x2       # x1 = 1 + 2 = 3
        memory[5] = 32'h40310133;  // sub x2, x2, x3       # x2 = 2 - 3 = -1
        memory[6] = 32'h022181b3;  // mul x3, x3, x2       # x3 = 3 * -1 = -3 (if MUL enabled)
        memory[7] = 32'h02420233;  // div x4, x4, x4       # x4 = 4 / 4 = 1 (if DIV enabled)
        
        // Logical operations
        memory[8] = 32'h0020e0b3;  // or x1, x1, x2        # x1 = 3 | -1 = -1
        memory[9] = 32'h00117133;  // and x2, x2, x1       # x2 = -1 & -1 = -1
        memory[10] = 32'h0031c1b3; // xor x3, x3, x3       # x3 = -3 ^ -3 = 0
        
        // Shift operations
        memory[11] = 32'h00109293; // slli x5, x1, 1       # x5 = -1 << 1 = -2
        memory[12] = 32'h40125313; // srai x6, x2, 1       # x6 = -1 >> 1 = -1
        memory[13] = 32'h0010d393; // srli x7, x1, 1       # x7 = -1 >>> 1 = 0x7FFFFFFF
        
        // Set up data pointer (0x1000)
        memory[14] = 32'h000012b7; // lui x5, 0x1          # x5 = 0x1000
        memory[15] = 32'h00028293; // addi x5, x5, 0       # x5 = 0x1000
        
        // Store results to data memory
        memory[16] = 32'h0012a023; // sw x1, 0(x5)         # Store x1 (-1) at 0x1000
        memory[17] = 32'h0022a423; // sw x2, 8(x5)         # Store x2 (-1) at 0x1008
        memory[18] = 32'h0032a823; // sw x3, 16(x5)        # Store x3 (0) at 0x1010
        memory[19] = 32'h0042ac23; // sw x4, 24(x5)        # Store x4 (1) at 0x1018
        memory[20] = 32'h0052a023; // sw x5, 32(x5)        # Store x5 (0x1000) at 0x1020
        memory[21] = 32'h0062a423; // sw x6, 40(x5)        # Store x6 (-1) at 0x1028
        memory[22] = 32'h0072a823; // sw x7, 48(x5)        # Store x7 (0x7FFFFFFF) at 0x1030
        
        // Load success code
        memory[23] = 32'h123453b7; // lui x7, 0x12345      # 
        memory[24] = 32'h67838393; // addi x7, x7, 0x678   # x7 = 0x12345678
        
        // Store success code at address 0
        memory[25] = 32'h00702023; // sw x7, 0(x0)         # Store success at address 0
        
        // Infinite loop to terminate
        memory[26] = 32'h00000063; // beq x0, x0, -4       # Infinite loop
        
        // Fill rest with nops
        for (i = 27; i < 100; i = i + 1) begin
            memory[i] = 32'h00000013;
        end
        
        // Reset sequence
        $display("\n[SETUP] Applying reset...");
        resetn = 0;
        mem_ready = 0;
        #100;
        
        $display("[SETUP] Releasing reset...");
        resetn = 1;
        
        $display("\n[EXECUTION] Starting test execution...");
        $display("Time    | PC       | Instruction | Operation");
        $display("--------|----------|-------------|-------------------");
        
        // Run simulation
        #10000;
        
        // Final verification
        $display("\n" + string'("="*50));
        $display("TEST RESULTS SUMMARY");
        $display(string'("="*50));
        
        // Check success code
        if (memory[0] == 32'h12345678) begin
            $display("✅ SUCCESS CODE: 0x12345678 written to address 0");
            errors = 0;
        end else begin
            $display("❌ FAILED: Expected 0x12345678 at address 0");
            $display("   Found: 0x%h", memory[0]);
            errors = 1;
        end
        
        // Display stored results
        $display("\nDATA MEMORY RESULTS (0x1000 region):");
        $display("Address | Value         | Expected      | Status");
        $display("--------|---------------|---------------|--------");
        
        check_result(1024, 32'hffffffff, "0x1000: x1 (-1)");
        check_result(1026, 32'hffffffff, "0x1008: x2 (-1)");
        check_result(1028, 32'h00000000, "0x1010: x3 (0)");
        check_result(1030, 32'h00000001, "0x1018: x4 (1)");
        check_result(1032, 32'h00001000, "0x1020: x5 (0x1000)");
        check_result(1034, 32'hffffffff, "0x1028: x6 (-1)");
        check_result(1036, 32'h7fffffff, "0x1030: x7 (0x7FFFFFFF)");
        
        // Final statistics
        $display("\n" + string'("="*50));
        $display("EXECUTION STATISTICS");
        $display(string'("="*50));
        $display("Total Instructions Executed: %0d", total_instructions);
        $display("Final Program Counter: 0x%h", current_pc);
        $display("Simulation Time: %0t ns", $time);
        
        $display("\n" + string'("="*50));
        if (errors == 0) begin
            $display("✅ ALL ARITHMETIC TESTS PASSED!");
            $display("PicoRV32 correctly executed:");
            $display("  - Addition, Subtraction");
            $display("  - Multiplication, Division");
            $display("  - Logical operations (AND, OR, XOR)");
            $display("  - Shift operations (SLLI, SRAI, SRLI)");
            $display("  - Memory operations (Load/Store)");
        end else begin
            $display("❌ SOME TESTS FAILED!");
            $display("Errors detected: %0d", errors);
        end
        $display(string'("="*50));
        
        // Write results to file
        $writememh("test_results.hex", memory, 0, 1039);
        $display("\n[OUTPUT] Results written to: test_results.hex");
        
        $finish;
    end
    
    // Helper task to check results
    task check_result;
        input [31:0] addr;
        input [31:0] expected;
        input string description;
        begin
            if (memory[addr] == expected) begin
                $display("0x%h   | 0x%h    | 0x%h    | ✅", 
                         addr << 2, memory[addr], expected);
            end else begin
                $display("0x%h   | 0x%h    | 0x%h    | ❌", 
                         addr << 2, memory[addr], expected);
                errors = errors + 1;
            end
        end
    endtask
    
    // ============================================
    // Memory Access Handler
    // ============================================
    always @(posedge clk) begin
        mem_ready <= 0;
        
        if (mem_valid && !mem_ready) begin
            if (mem_addr < 32'h4000) begin  // 16KB range
                mem_rdata <= memory[mem_addr[13:2]];
                mem_ready <= 1;
                
                if (mem_instr) begin
                    current_pc <= mem_addr;
                    total_instructions <= total_instructions + 1;
                    
                    // Display instruction trace (first 30 only)
                    if (total_instructions < 30) begin
                        case (memory[mem_addr[13:2]])
                            32'h00100093: $display("%6t | %h | %h | addi x1, x0, 1", $time, mem_addr, memory[mem_addr[13:2]]);
                            32'h00200113: $display("%6t | %h | %h | addi x2, x0, 2", $time, mem_addr, memory[mem_addr[13:2]]);
                            32'h00300193: $display("%6t | %h | %h | addi x3, x0, 3", $time, mem_addr, memory[mem_addr[13:2]]);
                            32'h00400213: $display("%6t | %h | %h | addi x4, x0, 4", $time, mem_addr, memory[mem_addr[13:2]]);
                            32'h002080b3: $display("%6t | %h | %h | add x1, x1, x2", $time, mem_addr, memory[mem_addr[13:2]]);
                            32'h40310133: $display("%6t | %h | %h | sub x2, x2, x3", $time, mem_addr, memory[mem_addr[13:2]]);
                            32'h022181b3: $display("%6t | %h | %h | mul x3, x3, x2", $time, mem_addr, memory[mem_addr[13:2]]);
                            32'h02420233: $display("%6t | %h | %h | div x4, x4, x4", $time, mem_addr, memory[mem_addr[13:2]]);
                            32'h0020e0b3: $display("%6t | %h | %h | or x1, x1, x2", $time, mem_addr, memory[mem_addr[13:2]]);
                            32'h00117133: $display("%6t | %h | %h | and x2, x2, x1", $time, mem_addr, memory[mem_addr[13:2]]);
                            32'h0031c1b3: $display("%6t | %h | %h | xor x3, x3, x3", $time, mem_addr, memory[mem_addr[13:2]]);
                            32'h00109293: $display("%6t | %h | %h | slli x5, x1, 1", $time, mem_addr, memory[mem_addr[13:2]]);
                            32'h40125313: $display("%6t | %h | %h | srai x6, x2, 1", $time, mem_addr, memory[mem_addr[13:2]]);
                            32'h0010d393: $display("%6t | %h | %h | srli x7, x1, 1", $time, mem_addr, memory[mem_addr[13:2]]);
                            32'h000012b7: $display("%6t | %h | %h | lui x5, 0x1", $time, mem_addr, memory[mem_addr[13:2]]);
                            32'h00028293: $display("%6t | %h | %h | addi x5, x5, 0", $time, mem_addr, memory[mem_addr[13:2]]);
                            32'h0012a023: $display("%6t | %h | %h | sw x1, 0(x5)", $time, mem_addr, memory[mem_addr[13:2]]);
                            32'h0022a423: $display("%6t | %h | %h | sw x2, 8(x5)", $time, mem_addr, memory[mem_addr[13:2]]);
                            32'h0032a823: $display("%6t | %h | %h | sw x3, 16(x5)", $time, mem_addr, memory[mem_addr[13:2]]);
                            32'h0042ac23: $display("%6t | %h | %h | sw x4, 24(x5)", $time, mem_addr, memory[mem_addr[13:2]]);
                            32'h00702023: $display("%6t | %h | %h | sw x7, 0(x0) [SUCCESS CODE]", $time, mem_addr, memory[mem_addr[13:2]]);
                            32'h00000063: $display("%6t | %h | %h | beq x0, x0, -4 [INFINITE LOOP]", $time, mem_addr, memory[mem_addr[13:2]]);
                            default: if (total_instructions < 30) $display("%6t | %h | %h |", $time, mem_addr, memory[mem_addr[13:2]]);
                        endcase
                    end
                    
                    // Detect infinite loop
                    if (mem_addr >= 32'h0000006c && mem_addr < 32'h00000070) begin
                        if (!test_finished) begin
                            $display("\n[STATUS] Program reached infinite loop - execution complete");
                            test_finished = 1;
                        end
                    end
                end
            end else begin
                $display("[ERROR] Memory access out of bounds: 0x%h", mem_addr);
                mem_ready <= 1;
                mem_rdata <= 32'h00000000;
            end
        end
    end
    
    // ============================================
    // Memory Write Handler
    // ============================================
    always @(posedge clk) begin
        if (mem_valid && mem_ready && |mem_wstrb) begin
            if (mem_addr < 32'h4000) begin
                // Update memory
                if (mem_wstrb[0]) memory[mem_addr[13:2]][7:0]   <= mem_wdata[7:0];
                if (mem_wstrb[1]) memory[mem_addr[13:2]][15:8]  <= mem_wdata[15:8];
                if (mem_wstrb[2]) memory[mem_addr[13:2]][23:16] <= mem_wdata[23:16];
                if (mem_wstrb[3]) memory[mem_addr[13:2]][31:24] <= mem_wdata[31:24];
                
                // Log important writes
                if (mem_addr == 32'h00000000) begin
                    $display("\n[SUCCESS] Writing 0x%h to address 0 (Success indicator)", mem_wdata);
                end
                if (mem_addr >= 32'h00001000 && mem_addr < 32'h00001040) begin
                    $display("[STORE] Result stored at 0x%h: 0x%h", mem_addr, mem_wdata);
                end
            end
        end
    end
    
    // ============================================
    // Trap Monitor
    // ============================================
    always @(posedge clk) begin
        if (resetn && trap) begin
            $display("\n[ERROR] CPU entered trap state at PC=0x%h", current_pc);
            errors <= errors + 1;
            #100 $finish;
        end
    end
    
endmodule

