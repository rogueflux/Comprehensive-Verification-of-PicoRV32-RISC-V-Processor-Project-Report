// PicoRV32 testbench with HEX file loading
`timescale 1ns/1ps

module picorv32_hex_test;

    reg clk = 0;
    reg resetn = 0;

    // PicoRV32 interface
    wire        mem_valid;
    wire        mem_instr;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    wire        mem_ready;
    wire [31:0] mem_rdata;
    wire        trap;

    // Memory
    reg [31:0] memory [0:8191];  // 32KB memory

    // PicoRV32 instance
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

    // Assign mem_rdata from memory
    assign mem_rdata = memory[mem_addr >> 2];

    // Simple memory ready
    assign mem_ready = mem_valid;

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("========================================");
        $display("PicoRV32 HEX Test");
        $display("========================================");

        // Load HEX file
        if ($test$plusargs("hexload")) begin
            // Use absolute path to the hex file
            $readmemh("D:/SoC_1/riscv_dv_picorv32/sim/test.hex", memory);
            $display("HEX file loaded successfully");
        end else begin
            $display("Using built-in test program");
            // Simple test program: write 1 to memory[0]
            memory[0] = 32'h00000013; // nop
            memory[1] = 32'h00000013; // nop  
            memory[2] = 32'h00000013; // nop
            memory[3] = 32'h00000013; // nop
        end

        // Reset
        resetn = 0;
        #100;
        resetn = 1;
        $display("Reset released");

        // Wait for trap or timeout
        wait(trap);
        #10;
        
        $display("Trap detected - test completed");
        
        // Check result
        if (memory[0] == 32'h00000001) begin
            $display("✅ TEST PASSED! memory[0] = 0x%08h", memory[0]);
        end else begin
            $display("❌ TEST FAILED! memory[0] = 0x%08h", memory[0]);
        end
        
        $display("Simulation time: %0d ns", $time);
        $finish;
    end

    // Memory writes
    always @(posedge clk) begin
        if (mem_valid && mem_wstrb != 0) begin
            memory[mem_addr >> 2] <= mem_wdata;
            //$display("Write: addr=0x%08h, data=0x%08h", mem_addr, mem_wdata);
        end
    end

    // Monitor PC
    always @(posedge clk) begin
        if (resetn && mem_valid && mem_instr) begin
            //$display("PC: 0x%08h, Instr: 0x%08h", uut.pc, mem_rdata);
        end
    end

endmodule

