// Simple PicoRV32 Testbench for initial verification
`timescale 1ns/1ps

module picorv32_simple_tb;

    // Clock and reset
    reg clk = 0;
    reg resetn = 0;
    
    // PicoRV32 signals
    wire        mem_valid;
    wire        mem_instr;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    wire        mem_ready;
    wire [31:0] mem_rdata;
    
    // Simple memory
    reg [31:0] memory [0:1023];
    
    // Clock generation (50 MHz)
    always #10 clk = ~clk;
    
    // PicoRV32 instance
    picorv32 #(
        .ENABLE_COUNTERS(1),
        .ENABLE_MUL(1),
        .ENABLE_DIV(1),
        .ENABLE_IRQ(0)
    ) dut (
        .clk(clk),
        .resetn(resetn),
        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_ready(mem_ready),
        .mem_rdata(mem_rdata),
        .trap(trap)
    );
    
    // Memory model
    assign mem_ready = 1'b1;
    
    always @(posedge clk) begin
        if (mem_valid && |mem_wstrb) begin
            // Write operation
            if (mem_wstrb[0]) memory[mem_addr[11:2]][7:0]   <= mem_wdata[7:0];
            if (mem_wstrb[1]) memory[mem_addr[11:2]][15:8]  <= mem_wdata[15:8];
            if (mem_wstrb[2]) memory[mem_addr[11:2]][23:16] <= mem_wdata[23:16];
            if (mem_wstrb[3]) memory[mem_addr[11:2]][31:24] <= mem_wdata[31:24];
        end
    end
    
    assign mem_rdata = memory[mem_addr[11:2]];
    
    // Load test program
    initial begin
        integer i;
        // Initialize memory to zero
        for (i = 0; i < 1024; i = i + 1) begin
            memory[i] = 32'h00000000;
        end
        
        // Load simple test program
        // NOP, NOP, ADDI x1, x0, 1, SW x1, 0(x0), EBREAK
        memory[0] = 32'h00000013; // nop
        memory[1] = 32'h00000013; // nop  
        memory[2] = 32'h00100093; // addi x1, x0, 1
        memory[3] = 32'h00102023; // sw x1, 0(x0)
        memory[4] = 32'h00100073; // ebreak
    end
    
    // Test sequence
    initial begin
        $display("========================================");
        $display("Simple PicoRV32 Testbench");
        $display("========================================");
        
        // Reset
        resetn = 0;
        #100;
        resetn = 1;
        $display("Reset released at %0t ns", $time);
        
        // Run simulation
        #1000;
        
        // Check if test wrote to address 0
        if (memory[0] == 32'h00000001) begin
            $display("✅ TEST PASSED! Memory[0] = 0x%h", memory[0]);
        end else begin
            $display("❌ TEST FAILED! Memory[0] = 0x%h", memory[0]);
        end
        
        $display("Simulation completed at %0t ns", $time);
        $display("========================================");
        $finish;
    end
    
    // Monitor
    initial begin
        $timeformat(-9, 2, " ns", 10);
        #500; // Wait a bit before monitoring
        
        forever begin
            @(posedge clk);
            if (mem_valid && mem_instr) begin
                $display("PC: 0x%h, Instr: 0x%h", mem_addr, mem_rdata);
            end
            if (trap) begin
                $display("Trap detected at %t", $time);
                break;
            end
        end
    end
    
endmodule

