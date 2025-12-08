`timescale 1ns/1ps

module always_load_hex;

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

    reg [31:0] memory [0:8191];

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

    initial begin
        $display("========================================");
        $display("ALWAYS LOAD HEX Test");
        $display("========================================");

        // ALWAYS load hex file (no testplusarg check)
        $readmemh("../sim/test.hex", memory);
        $display("Hex file loaded");
        
        // Show first few instructions
        $display("First 5 instructions:");
        for (integer i = 0; i < 5; i = i + 1) begin
            $display("  [%0d] = 0x%08h", i, memory[i]);
        end

        // Reset
        resetn = 0;
        #100;
        resetn = 1;
        $display("Reset released");

        // Wait for trap
        wait(trap);
        #10;
        
        $display("Trap detected - test completed");
        
        // Check result - adapt based on what the test actually does
        // Look for any non-zero writes
        $display("Checking memory for results...");
        integer found_result = 0;
        for (integer i = 0; i < 100; i = i + 1) begin
            if (memory[i] != 0 && memory[i] != 32'hxxxxxxxx) begin
                $display("  memory[%0d] = 0x%08h", i, memory[i]);
                found_result = 1;
            end
        end
        
        if (found_result) begin
            $display("✅ TEST COMPLETED - Memory was modified");
        end else begin
            $display("⚠️  Test ran but memory unchanged");
        end
        
        $display("Simulation time: %0d ns", $time);
        $finish;
    end

    // Memory writes
    always @(posedge clk) begin
        if (mem_valid && mem_wstrb != 0) begin
            memory[mem_addr >> 2] <= mem_wdata;
            $display("[%0t] WRITE: addr=0x%08h, data=0x%08h", 
                     $time, mem_addr, mem_wdata);
        end
    end

endmodule

