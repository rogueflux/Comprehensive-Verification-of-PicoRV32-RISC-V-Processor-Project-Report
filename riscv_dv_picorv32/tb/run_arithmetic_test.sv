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
    // Memory Model
    // ============================================
    reg [31:0] memory [0:1023];  // 4KB memory
    integer i;
    
    // ============================================
    // Initial Block - Test Setup
    // ============================================
    initial begin
        $display("=========================================");
        $display("Starting PicoRV32 Arithmetic Test");
        $display("=========================================");
        
        // Initialize memory to NOPs
        for (i = 0; i < 1024; i = i + 1) begin
            memory[i] = 32'h00000013;
        end
        
        // ============================================
        // SIMPLE ARITHMETIC TEST PROGRAM
        // Addresses are word addresses (divide by 4)
        // ============================================
        
        // Test 1: Basic arithmetic
        memory[0] = 32'h00100093;  // addi x1, x0, 1       # x1 = 1
        memory[1] = 32'h00200113;  // addi x2, x0, 2       # x2 = 2
        memory[2] = 32'h00300193;  // addi x3, x0, 3       # x3 = 3
        memory[3] = 32'h00400213;  // addi x4, x0, 4       # x4 = 4
        
        // Addition
        memory[4] = 32'h002080b3;  // add x1, x1, x2       # x1 = 1 + 2 = 3
        memory[5] = 32'h00310133;  // add x2, x2, x3       # x2 = 2 + 3 = 5
        
        // Subtraction
        memory[6] = 32'h404181b3;  // sub x3, x3, x4       # x3 = 3 - 4 = -1
        memory[7] = 32'h40520233;  // sub x4, x4, x5       # x4 = 4 - 5 = -1 (x5=0)
        
        // Logical operations
        memory[8] = 32'h0020e0b3;  // or x1, x1, x2        # x1 = 3 | 5 = 7
        memory[9] = 32'h00117133;  // and x2, x2, x1       # x2 = 5 & 7 = 5
        memory[10] = 32'h0031c1b3; // xor x3, x3, x3       # x3 = -1 ^ -1 = 0
        
        // Shift operations
        memory[11] = 32'h00109293; // slli x5, x1, 1       # x5 = 7 << 1 = 14
        memory[12] = 32'h40125313; // srai x6, x4, 1       # x6 = -1 >> 1 = -1
        
        // Store results to address 0x200 for verification
        memory[13] = 32'h000012b7; // lui x5, 0x2          # x5 = 0x2000
        memory[14] = 32'h00028293; // addi x5, x5, 0       # x5 = 0x2000
        
        memory[15] = 32'h0012a023; // sw x1, 0(x5)         # Store x1 (7) at 0x2000
        memory[16] = 32'h0022a423; // sw x2, 8(x5)         # Store x2 (5) at 0x2008
        memory[17] = 32'h0032a823; // sw x3, 16(x5)        # Store x3 (0) at 0x2010
        memory[18] = 32'h0042ac23; // sw x4, 24(x5)        # Store x4 (-1) at 0x2018
        memory[19] = 32'h0052a023; // sw x5, 0(x5)         # Store x5 (0x2000) at 0x2000
        memory[20] = 32'h0062a423; // sw x6, 8(x5)         # Store x6 (-1) at 0x2008
        
        // Load success code into x7
        memory[21] = 32'h123453b7; // lui x7, 0x12345      # 
        memory[22] = 32'h67838393; // addi x7, x7, 0x678   # x7 = 0x12345678
        
        // Store success code at address 0 (overwrites first instruction)
        memory[23] = 32'h00702023; // sw x7, 0(x0)         # Store success at address 0
        
        // Terminate with infinite loop
        memory[24] = 32'h00000063; // beq x0, x0, -4       # Infinite loop
        
        // Fill rest with nops to prevent running into garbage
        for (i = 25; i < 100; i = i + 1) begin
            memory[i] = 32'h00000013; // nop
        end
        
        // Reset sequence
        $display("[%0t] Applying reset...", $time);
        resetn = 0;
        mem_ready = 0;
        #100;
        
        $display("[%0t] Releasing reset...", $time);
        resetn = 1;
        
        $display("[%0t] Starting test execution...", $time);
        
        // Run for enough cycles
        #5000;
        
        // Check results
        $display("\n=========================================");
        $display("Test Results Verification");
        $display("=========================================");
        
        // Check if success code was written to address 0
        if (memory[0] == 32'h12345678) begin
            $display("✅ SUCCESS: Arithmetic test completed!");
            $display("   Success code 0x12345678 found at address 0");
            errors = 0;
        end else begin
            $display("❌ FAILED: Success code not found at address 0");
            $display("   Found: %h", memory[0]);
            errors = 1;
        end
        
        // Display stored results
        $display("\nStored Results at 0x2000:");
        $display("0x2000: %h (x1 should be 7)", memory[512]);   // 0x2000 >> 2 = 512
        $display("0x2008: %h (x2 should be 5)", memory[514]);   // 0x2008 >> 2 = 514
        $display("0x2010: %h (x3 should be 0)", memory[516]);   // 0x2010 >> 2 = 516
        $display("0x2018: %h (x4 should be ffffffff)", memory[518]); // 0x2018 >> 2 = 518
        
        $display("\nProgram Counter at end: %h", current_pc);
        $display("Instructions executed: %0d", total_instructions);
        
        $display("\n=========================================");
        $display("Test Complete");
        $display("Errors detected: %0d", errors);
        $display("=========================================");
        
        if (errors == 0) begin
            $display("✅ ALL TESTS PASSED!");
        end else begin
            $display("❌ TEST FAILED!");
        end
        
        $finish;
    end
    
    // ============================================
    // Memory Access Handler
    // ============================================
    always @(posedge clk) begin
        mem_ready <= 0;
        
        if (mem_valid && !mem_ready) begin
            if (mem_addr < 32'h1000) begin  // Within 4KB
                mem_rdata <= memory[mem_addr[11:2]];  // Word addressing
                mem_ready <= 1;
                
                if (mem_instr) begin
                    current_pc <= mem_addr;
                    total_instructions <= total_instructions + 1;
                    
                    // Show first 30 instructions
                    if (total_instructions < 30) begin
                        $display("[%0t] PC=%h, Instr=%h", 
                                 $time, mem_addr, memory[mem_addr[11:2]]);
                    end
                    
                    // Detect infinite loop
                    if (mem_addr >= 32'h00000064 && mem_addr < 32'h00000068) begin
                        if (!test_finished) begin
                            $display("[%0t] Reached infinite loop - test program completed", $time);
                            test_finished = 1;
                        end
                    end
                end
            end else begin
                $display("[%0t] ERROR: Memory access out of bounds: %h", $time, mem_addr);
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
            if (mem_addr < 32'h1000) begin
                // Update memory
                if (mem_wstrb[0]) memory[mem_addr[11:2]][7:0]   <= mem_wdata[7:0];
                if (mem_wstrb[1]) memory[mem_addr[11:2]][15:8]  <= mem_wdata[15:8];
                if (mem_wstrb[2]) memory[mem_addr[11:2]][23:16] <= mem_wdata[23:16];
                if (mem_wstrb[3]) memory[mem_addr[11:2]][31:24] <= mem_wdata[31:24];
                
                // Show important writes
                if (mem_addr == 32'h00000000) begin
                    $display("[%0t] Writing to address 0: %h (Success code)", 
                             $time, mem_wdata);
                end
                if (mem_addr >= 32'h00002000 && mem_addr < 32'h00002020) begin
                    $display("[%0t] Storing result at %h: %h", 
                             $time, mem_addr, mem_wdata);
                end
            end
        end
    end
    
    // ============================================
    // Trap Monitor
    // ============================================
    always @(posedge clk) begin
        if (resetn && trap) begin
            $display("[%0t] ERROR: CPU entered trap state at PC=%h", $time, current_pc);
            errors <= errors + 1;
            #100 $finish;
        end
    end
    
endmodule