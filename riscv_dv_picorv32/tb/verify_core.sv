`timescale 1ns/1ps

module verify_core;
    reg clk = 0;
    reg rst = 0;
    
    wire        mem_valid;
    reg         mem_ready = 0;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    reg  [31:0] mem_rdata = 0;
    
    picorv32 cpu (
        .clk(clk),
        .resetn(~rst),
        .mem_valid(mem_valid),
        .mem_instr(),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata)
    );
    
    always #5 clk = ~clk;
    
    reg [31:0] mem [0:255];
    integer write_count = 0;
    
    initial begin
        $display("=== CORE VERIFICATION TEST ===");
        
        // Load a simple program: write 0x12345678 to address 0x4
        mem[0] = 32'h123456b7;  // lui a3, 0x12345
        mem[1] = 32'h67868693;  // addi a3, a3, 0x678
        mem[2] = 32'h00400713;  // addi a4, zero, 4
        mem[3] = 32'h00e72023;  // sw a3, 0(a4)
        mem[4] = 32'h00000073;  // ebreak
        
        $display("Test program loaded");
        
        // Reset
        rst = 1;
        #100;
        rst = 0;
        $display("CPU started");
        
        // Run
        #10000;
        
        $display("Test completed");
        $display("Write count: %0d", write_count);
        $display("Memory[1] (address 0x4) = 0x%08h", mem[1]);
        
        if (write_count > 0) begin
            $display("✅ CPU IS WORKING! It executed instructions and wrote to memory.");
        end else begin
            $display("❌ CPU not working properly");
        end
        
        $finish;
    end
    
    always @(posedge clk) begin
        if (mem_valid && !mem_ready) begin
            mem_ready <= 1;
            if (mem_wstrb) begin
                mem[mem_addr >> 2] <= mem_wdata;
                write_count = write_count + 1;
                $display("Write #%0d: addr=0x%08h, data=0x%08h", 
                         write_count, mem_addr, mem_wdata);
            end else begin
                mem_rdata <= mem[mem_addr >> 2];
                $display("Fetch: PC=0x%08h, instr=0x%08h", mem_addr, mem_rdata);
            end
        end else begin
            mem_ready <= 0;
        end
    end
endmodule

