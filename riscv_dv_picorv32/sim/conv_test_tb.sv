
`timescale 1ns/1ps

module conv_test;
    reg clk = 0;
    reg rst = 0;
    
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
    
    reg [31:0] mem [0:1023];
    integer write_count = 0;
    
    initial begin
        \$display("=== TEST WITH CONVERTED HEX ===");
        
        // Load converted hex file
        \$readmemh("test_converted.hex", mem);
        \$display("Converted hex file loaded");
        
        // Show first few instructions
        \$display("First 5 instructions:");
        for (integer i = 0; i < 5; i = i + 1) begin
            \$display("  [%0d] = 0x%08h", i, mem[i]);
        end
        
        // Reset
        rst = 1;
        #100;
        rst = 0;
        \$display("CPU started");
        
        // Run for a while
        #100000;
        
        \$display("Test completed");
        \$display("Total writes: %0d", write_count);
        \$display("Trap signal: %0d", trap);
        
        // Check some memory locations
        \$display("Memory check (first 16 locations):");
        for (integer i = 0; i < 16; i = i + 1) begin
            if (mem[i] != 0) begin
                \$display("  [%0d] = 0x%08h", i, mem[i]);
            end
        end
        
        \$finish;
    end
    
    always @(posedge clk) begin
        if (mem_valid && !mem_ready) begin
            mem_ready <= 1;
            if (mem_wstrb) begin
                mem[mem_addr >> 2] <= mem_wdata;
                write_count = write_count + 1;
                \$display("[%0t] Write #%0d: addr=0x%08h, data=0x%08h", 
                         \$time, write_count, mem_addr, mem_wdata);
            end else begin
                mem_rdata <= mem[mem_addr >> 2];
                \$display("[%0t] Fetch: PC=0x%08h, instr=0x%08h", 
                         \$time, mem_addr, mem_rdata);
            end
        end else begin
            mem_ready <= 0;
        end
    end
endmodule

