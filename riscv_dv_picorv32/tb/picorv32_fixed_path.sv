`timescale 1ns/1ps

module picorv32_fixed_path;

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

    integer cycle_count = 0;
    
    initial begin
        $display("========================================");
        $display("PicoRV32 FIXED PATH Test");
        $display("========================================");

        // Load hex file with ABSOLUTE PATH
        $readmemh("D:/SoC_1/riscv_dv_picorv32/sim/test.hex", memory);
        $display("Hex file loaded with absolute path");
        
        // Show first few instructions
        $display("First 5 instructions in memory:");
        for (integer i = 0; i < 5; i = i + 1) begin
            $display("  [%0d] = 0x%08h", i, memory[i]);
        end

        // Reset
        resetn = 0;
        repeat(10) @(posedge clk);
        resetn = 1;
        $display("Reset released");

        // Run until trap or timeout
        while (!trap && cycle_count < 2000) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;
        end
        
        if (trap) begin
            $display("TRAP detected at cycle %0d", cycle_count);
        end else begin
            $display("Timeout at cycle %0d", cycle_count);
        end
        
        // Show final memory
        $display("Final memory (first 16 locations):");
        for (integer i = 0; i < 16; i = i + 1) begin
            $display("  [%0d] = 0x%08h", i, memory[i]);
        end
        
        $display("Simulation completed");
        $finish;
    end

    // Memory interface
    always @(posedge clk) begin
        if (mem_valid && !mem_ready) begin
            mem_ready <= 1'b1;
            
            if (mem_wstrb != 0) begin
                // Write operation
                memory[mem_addr >> 2] <= mem_wdata;
                $display("[%0t] WRITE: addr=0x%08h, data=0x%08h", 
                         $time, mem_addr, mem_wdata);
            end else begin
                // Read operation
                mem_rdata <= memory[mem_addr >> 2];
                if (mem_instr) begin
                    $display("[%0t] FETCH: PC~0x%08h, instr=0x%08h", 
                             $time, mem_addr, mem_rdata);
                end
            end
        end else begin
            mem_ready <= 1'b0;
        end
    end

endmodule

