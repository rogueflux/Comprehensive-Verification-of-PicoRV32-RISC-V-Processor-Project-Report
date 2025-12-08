`timescale 1ns/1ps

module proper_hex_test;
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
    
    reg [31:0] mem [0:255];
    
    initial begin
        $display("=== PROPER HEX TEST ===");
        
        // Initialize memory
        for (integer i = 0; i < 256; i = i + 1) begin
            mem[i] = 32'h0;
        end
        
        // Try to load hex file
        $readmemh("../sim/test_converted.hex", mem);
        $display("Hex file load attempted");
        
        // Check what was loaded
        integer count = 0;
        $display("Checking loaded instructions:");
        for (integer i = 0; i < 20 && count < 5; i = i + 1) begin
            if (mem[i] != 0) begin
                $display("  mem[%0d] = 0x%08h", i, mem[i]);
                count = count + 1;
            end
        end
        
        if (count == 0) begin
            $display("WARNING: No instructions found - memory is all zeros");
            // Load a simple test
            mem[0] = 32'h00000013; // nop
            mem[1] = 32'h00000013; // nop
            $display("Loaded simple NOP program");
        end
        
        // Start CPU
        #100;
        rst = 0;
        $display("CPU started");
        
        // Run
        #50000;
        
        $display("Test completed");
        $display("Trap signal: %0d", trap);
        
        $finish;
    end
    
    always @(posedge clk) begin
        if (mem_valid && !mem_ready) begin
            mem_ready <= 1;
            if (mem_wstrb) begin
                mem[mem_addr >> 2] <= mem_wdata;
                $display("WRITE @0x%08h = 0x%08h", mem_addr, mem_wdata);
            end else begin
                mem_rdata <= mem[mem_addr >> 2];
                $display("READ  @0x%08h = 0x%08h", mem_addr, mem_rdata);
            end
        end else begin
            mem_ready <= 0;
        end
    end
endmodule

