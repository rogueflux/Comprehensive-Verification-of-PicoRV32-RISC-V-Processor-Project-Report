`timescale 1ns/1ps

module picorv32_debug_test;

    reg clk = 0;
    reg resetn = 0;

    wire        mem_valid;
    wire        mem_instr;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    wire        mem_ready;
    wire [31:0] mem_rdata;
    wire        trap;

    reg [31:0] memory [0:1023];
    
    picorv32 #(
        .ENABLE_MUL(1),
        .ENABLE_DIV(1),
        .ENABLE_IRQ(0),
        .ENABLE_TRACE(0)
    ) uut (
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

    assign mem_rdata = memory[mem_addr >> 2];
    assign mem_ready = mem_valid;

    always #5 clk = ~clk;

    integer cycle_count = 0;
    
    initial begin
        $display("========================================");
        $display("PicoRV32 DEBUG Test");
        $display("========================================");

        // Load hex file
        $readmemh("../sim/test.hex", memory);
        $display("Loaded test.hex");
        
        // Show first few instructions
        $display("First 5 instructions:");
        for (integer i = 0; i < 5; i = i + 1) begin
            $display("  memory[%0d] = 0x%08h", i, memory[i]);
        end

        // Reset
        resetn = 0;
        #100;
        resetn = 1;
        $display("Reset released at time %0t", $time);

        // Run until trap or timeout
        while (!trap && cycle_count < 10000) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;
        end
        
        if (trap) begin
            $display("TRAP detected at cycle %0d, time %0t", cycle_count, $time);
        end else begin
            $display("Timeout at cycle %0d", cycle_count);
        end
        
        // Show memory results
        $display("Memory results (first 20 locations):");
        for (integer i = 0; i < 20; i = i + 1) begin
            if (memory[i] != 32'h0) begin
                $display("  memory[%0d] = 0x%08h", i, memory[i]);
            end
        end
        
        // Check for any write to memory[0]
        if (memory[0] == 32'h00000001) begin
            $display("✅ TEST PASSED! Found success flag at memory[0]");
        end else if (memory[0] == 32'h93001000) begin
            $display("⚠️  memory[0] still contains first instruction (program didn't write to it)");
            $display("   This test program might write success to a different location");
        end else begin
            $display("❓ memory[0] = 0x%08h (unknown result)", memory[0]);
        end
        
        $display("Simulation completed in %0d cycles", cycle_count);
        $finish;
    end

    // Monitor all memory writes
    always @(posedge clk) begin
        if (mem_valid && mem_wstrb != 0) begin
            memory[mem_addr >> 2] <= mem_wdata;
            $display("[%0t] WRITE: addr=0x%08h (index %0d), data=0x%08h", 
                     $time, mem_addr, mem_addr >> 2, mem_wdata);
        end
    end
    
    // Monitor instruction fetches (using mem_addr for PC when mem_instr is true)
    always @(posedge clk) begin
        if (resetn && mem_valid && mem_instr) begin
            $display("[%0t] FETCH: PC~0x%08h, instr=0x%08h", 
                     $time, mem_addr, mem_rdata);
        end
    end

endmodule

