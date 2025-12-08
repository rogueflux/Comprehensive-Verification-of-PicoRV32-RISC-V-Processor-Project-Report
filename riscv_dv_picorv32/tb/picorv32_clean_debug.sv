`timescale 1ns/1ps

module picorv32_clean_debug;

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
    integer write_count = 0;
    
    initial begin
        $display("========================================");
        $display("PicoRV32 CLEAN DEBUG Test");
        $display("========================================");

        // Load hex file
        $readmemh("../sim/test.hex", memory);
        $display("Loaded test.hex");
        
        // Show first few instructions
        $display("First 10 instructions in memory:");
        for (integer i = 0; i < 10; i = i + 1) begin
            $display("  [%0d] = 0x%08h", i, memory[i]);
        end

        // Reset
        resetn = 0;
        repeat(10) @(posedge clk);
        resetn = 1;
        $display("Reset released");

        // Run until trap or timeout
        while (!trap && cycle_count < 5000) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;
            
            // Show progress every 100 cycles
            if (cycle_count % 100 == 0) begin
                $display("Cycle %0d", cycle_count);
            end
        end
        
        if (trap) begin
            $display("TRAP detected at cycle %0d", cycle_count);
        end else begin
            $display("Timeout at cycle %0d", cycle_count);
        end
        
        // Show final memory state
        $display("Final memory state (first 32 locations):");
        for (integer i = 0; i < 32; i = i + 1) begin
            $display("  [%0d] = 0x%08h", i, memory[i]);
        end
        
        $display("Total writes detected: %0d", write_count);
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
                write_count = write_count + 1;
                $display("[%0t] WRITE #%0d: addr=0x%08h, data=0x%08h", 
                         $time, write_count, mem_addr, mem_wdata);
            end else begin
                // Read operation
                mem_rdata <= memory[mem_addr >> 2];
                if (mem_instr) begin
                    $display("[%0t] INSTR FETCH: PC~0x%08h, instr=0x%08h", 
                             $time, mem_addr, mem_rdata);
                end
            end
        end else begin
            mem_ready <= 1'b0;
        end
    end

endmodule

