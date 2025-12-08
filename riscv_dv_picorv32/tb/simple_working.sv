`timescale 1ns/1ps

module simple_working_corrected;

    reg clk = 0;
    reg resetn = 0;

    wire        mem_valid;
    wire        mem_instr;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    reg         mem_ready = 0;
    reg  [31:0] mem_rdata = 0;
    wire        trap;

    reg [31:0] memory [0:1023];
    
    picorv32 dut (
        .clk(clk),
        .resetn(resetn),
        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),
        .trap(trap)
    );

    always #5 clk = ~clk;

    initial begin
        $display("=== SIMPLE WORKING TEST (CORRECTED) ===");
        
        // Initialize all memory to 0
        for (integer i = 0; i < 1024; i = i + 1) begin
            memory[i] = 32'h0;
        end
        
        // CORRECTED: Write 1 to address 0x1000 (memory[256])
        // li t0, 0x1000        # load address 0x1000 into t0
        // li t1, 1             # load value 1 into t1  
        // sw t1, 0(t0)         # store t1 to address in t0
        // ebreak               # trap
        memory[0] = 32'h000012b7;  // lui t0, 0x1
        memory[1] = 32'h00028313;  // addi t1, zero, 1
        memory[2] = 32'h0062a023;  // sw t1, 0(t0)
        memory[3] = 32'h00100073;  // ebreak (trap)
        
        $display("Loaded corrected test program");
        $display("mem[0] = 0x%08h (lui t0, 0x1)", memory[0]);
        $display("mem[1] = 0x%08h (addi t1, zero, 1)", memory[1]);
        $display("mem[2] = 0x%08h (sw t1, 0(t0))", memory[2]);
        $display("mem[3] = 0x%08h (ebreak)", memory[3]);

        // Reset
        resetn = 0;
        #100;
        resetn = 1;
        $display("Reset released");

        // Run for some time
        #5000;
        
        // Check results - should write to address 0x1000 (memory[256])
        $display("Checking memory[256] (address 0x1000) = 0x%08h", memory[256]);
        if (memory[256] == 32'h00000001) begin
            $display("✅ TEST PASSED! Successfully wrote 1 to address 0x1000");
        end else begin
            $display("❌ TEST FAILED - Expected 0x00000001 at address 0x1000");
            $display("   Actually wrote to address 0x%08h with value 0x%08h", 
                     dut.mem_addr, memory[dut.mem_addr >> 2]);
        end
        
        $finish;
    end

    // Memory interface
    always @(posedge clk) begin
        if (mem_valid && !mem_ready) begin
            mem_ready <= 1'b1;
            
            if (mem_wstrb != 0) begin
                // Write operation
                memory[mem_addr >> 2] <= mem_wdata;
                $display("[%0t] WRITE: addr=0x%08h (mem[%0d]), data=0x%08h", 
                         $time, mem_addr, mem_addr >> 2, mem_wdata);
            end else begin
                // Read operation
                mem_rdata <= memory[mem_addr >> 2];
                if (mem_instr) begin
                    $display("[%0t] FETCH: PC=0x%08h, instr=0x%08h", 
                             $time, mem_addr, mem_rdata);
                end
            end
        end else begin
            mem_ready <= 1'b0;
        end
    end

endmodule

