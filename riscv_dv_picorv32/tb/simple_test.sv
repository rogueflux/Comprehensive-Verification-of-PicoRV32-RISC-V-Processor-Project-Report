`timescale 1ns/1ps

module simple_test;
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
    
    initial begin
        $display("=== Simple Test with Converted HEX ===");
        
        // Load converted hex file
        $readmemh("../sim/test_converted.hex", mem);
        $display("Converted hex file loaded");
        
        // Show first few
        $display("First 5 instructions:");
        for (integer i = 0; i < 5; i = i + 1) begin
            $display("  [%0d] = 0x%08h", i, mem[i]);
        end
        
        // Reset
        rst = 1;
        #100;
        rst = 0;
        $display("CPU started");
        
        // Run
        #50000;
        
        $display("Test completed");
        if (trap) $display("Trap detected");
        $finish;
    end
    
    always @(posedge clk) begin
        if (mem_valid && !mem_ready) begin
            mem_ready <= 1;
            if (mem_wstrb) begin
                mem[mem_addr >> 2] <= mem_wdata;
                $display("Write: addr=0x%08h, data=0x%08h", mem_addr, mem_wdata);
            end else begin
                mem_rdata <= mem[mem_addr >> 2];
            end
        end else begin
            mem_ready <= 0;
        end
    end
endmodule