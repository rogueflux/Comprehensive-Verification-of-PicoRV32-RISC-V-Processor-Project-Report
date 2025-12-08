`timescale 1ns/1ps

module simple_direct_test;
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
    integer cycle_count = 0;
    
    initial begin
        $display("=== DIRECT TEST WITH CONVERTED HEX ===");
        
        // Initialize memory
        for (integer i = 0; i < 1024; i = i + 1) begin
            mem[i] = 32'h0;
        end
        
        // Try to load the converted hex file
        $readmemh("test_converted.hex", mem);
        $display("Converted hex file loaded (or attempted)");
        
        // Check what was loaded
        $display("First 5 memory locations after load:");
        for (integer i = 0; i < 5; i = i + 1) begin
            $display("  mem[%0d] = 0x%08h", i, mem[i]);
        end
        
        // Reset
        rst = 1;
        #100;
        rst = 0;
        $display("CPU started at time %0t", $time);
        
        // Run for a fixed time
        #100000;
        
        $display("Test ended at time %0t", $time);
        $display("Cycle count: %0d", cycle_count);
        $display("Trap signal: %0d", trap);
        
        // Check final memory
        $display("Final memory (first 16 locations):");
        for (integer i = 0; i < 16; i = i + 1) begin
            $display("  [%0d] = 0x%08h", i, mem[i]);
        end
        
        $finish;
    end
    
    // Count cycles
    always @(posedge clk) begin
        if (!rst) begin
            cycle_count <= cycle_count + 1;
        end
    end
    
    // Memory interface
    always @(posedge clk) begin
        if (mem_valid && !mem_ready) begin
            mem_ready <= 1;
            if (mem_wstrb) begin
                mem[mem_addr >> 2] <= mem_wdata;
                $display("[%0t] WRITE to addr 0x%08h: 0x%08h", 
                         $time, mem_addr, mem_wdata);
            end else begin
                mem_rdata <= mem[mem_addr >> 2];
                $display("[%0t] READ from addr 0x%08h: 0x%08h", 
                         $time, mem_addr, mem_rdata);
            end
        end else begin
            mem_ready <= 0;
        end
    end
endmodule

