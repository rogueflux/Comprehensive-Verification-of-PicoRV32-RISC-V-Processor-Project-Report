`timescale 1ns/1ps

module simple_hex_test;
    reg clk = 0;
    reg rst = 1;
    
    wire        mem_valid;
    reg         mem_ready = 0;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    reg  [31:0] mem_rdata = 0;
    wire        trap;
    
    picorv32 cpu (
        .clk(clk),
        .resetn(~rst),
        .mem_valid(mem_valid),
        .mem_instr(),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),
        .trap(trap)
    );
    
    always #5 clk = ~clk;
    
    reg [31:0] mem [0:511];  // 2KB memory
    
    initial begin
        $display("=== SIMPLE HEX TEST ===");
        
        // Initialize memory to 0
        for (integer i = 0; i < 512; i = i + 1) begin
            mem[i] = 32'h0;
        end
        
        $display("Trying to load test_converted.hex...");
        
        // Try to load hex file
        $readmemh("test_converted.hex", mem);
        
        // Check what was loaded
        integer loaded_count = 0;
        $display("Checking loaded instructions:");
        for (integer i = 0; i < 20; i = i + 1) begin
            if (mem[i] != 0) begin
                $display("  mem[%0d] = 0x%08h", i, mem[i]);
                loaded_count = loaded_count + 1;
            end
        end
        
        if (loaded_count == 0) begin
            $display("ERROR: No instructions loaded! File may be empty or not found.");
            $display("Current directory: %s", $realtime);
            $finish;
        else
            $display("Successfully loaded %0d instructions", loaded_count);
        end
        
        // Start CPU
        #100;
        rst = 0;
        $display("CPU started at time %0t", $time);
        
        // Run simulation
        #100000;
        
        $display("Test completed at time %0t", $time);
        $display("Trap signal: %0d", trap);
        
        $finish;
    end
    
    // Simple memory interface
    always @(posedge clk) begin
        if (mem_valid && !mem_ready) begin
            mem_ready <= 1;
            if (mem_wstrb) begin
                mem[mem_addr >> 2] <= mem_wdata;
                $display("[%0t] WRITE @0x%08h = 0x%08h", $time, mem_addr, mem_wdata);
            end else begin
                mem_rdata <= mem[mem_addr >> 2];
                $display("[%0t] READ  @0x%08h = 0x%08h", $time, mem_addr, mem_rdata);
            end
        end else begin
            mem_ready <= 0;
        end
    end
endmodule

