// PicoRV32 RISCV-DV Testbench
// Top-level testbench for Vivado simulation

`timescale 1ns/1ps

module picorv32_riscv_dv_tb;

    // Clock and reset
    reg clk = 0;
    reg resetn = 0;
    
    // Test control
    reg test_start = 0;
    wire test_done;
    wire test_pass;
    wire [31:0] test_result;
    
    // Test program memory interface
    wire [31:0] imem_addr;
    wire [31:0] imem_rdata;
    wire imem_en;
    
    // Data memory interface  
    wire [31:0] dmem_addr;
    wire [31:0] dmem_rdata;
    wire [31:0] dmem_wdata;
    wire [3:0]  dmem_wstrb;
    wire dmem_en;
    wire dmem_ready;
    
    // Clock generation (50 MHz)
    always #10 clk = ~clk;
    
    // Device Under Test (DUT)
    picorv32_dv_wrapper dut (
        .clk(clk),
        .reset(resetn),
        .test_start(test_start),
        .test_done(test_done),
        .test_pass(test_pass),
        .test_result(test_result),
        .imem_addr(imem_addr),
        .imem_rdata(imem_rdata),
        .imem_en(imem_en),
        .dmem_addr(dmem_addr),
        .dmem_rdata(dmem_rdata),
        .dmem_wdata(dmem_wdata),
        .dmem_wstrb(dmem_wstrb),
        .dmem_en(dmem_en),
        .dmem_ready(dmem_ready)
    );
    
    // Test memory (instruction and data)
    test_memory u_memory (
        .clk(clk),
        .resetn(resetn),
        .imem_addr(imem_addr),
        .imem_rdata(imem_rdata),
        .imem_en(imem_en),
        .dmem_addr(dmem_addr),
        .dmem_rdata(dmem_rdata),
        .dmem_wdata(dmem_wdata),
        .dmem_wstrb(dmem_wstrb),
        .dmem_en(dmem_en),
        .dmem_ready(dmem_ready)
    );
    
    // Test sequence
    initial begin
        $display("========================================");
        $display("PicoRV32 RISCV-DV Verification Testbench");
        $display("========================================");
        $display("Time: %0t", $time);
        
        // Initialize
        resetn = 0;
        test_start = 0;
        
        // Wait a few cycles
        #100;
        
        // Release reset
        resetn = 1;
        $display("Reset released at time %0t", $time);
        #50;
        
        // Start test
        test_start = 1;
        $display("Test started at time %0t", $time);
        #20;
        test_start = 0;
        
        // Wait for test completion
        wait(test_done);
        $display("Test completed at time %0t", $time);
        $display("Test result: 0x%h", test_result);
        
        if (test_pass) begin
            $display("✅ TEST PASSED!");
        end else begin
            $display("❌ TEST FAILED!");
        end
        
        // Wait a bit more
        #100;
        
        $display("========================================");
        $display("Simulation complete");
        $display("========================================");
        $finish;
    end
    
    // Monitor
    initial begin
        $timeformat(-9, 2, " ns", 10);
        forever begin
            @(posedge clk);
            if (test_done) begin
                $display("Test done detected at %t", $time);
                break;
            end
        end
    end
    
endmodule

// Test memory module
module test_memory (
    input wire clk,
    input wire resetn,
    
    // Instruction memory interface
    input wire [31:0] imem_addr,
    output reg [31:0] imem_rdata,
    input wire imem_en,
    
    // Data memory interface
    input wire [31:0] dmem_addr,
    output reg [31:0] dmem_rdata,
    input wire [31:0] dmem_wdata,
    input wire [3:0]  dmem_wstrb,
    input wire dmem_en,
    output wire dmem_ready
);
    
    // Memory array (64KB)
    reg [7:0] memory [0:65535];
    
    // Ready signal
    assign dmem_ready = 1'b1;
    
    // Initialize memory
    initial begin
        integer i;
        for (i = 0; i < 65536; i = i + 1) begin
            memory[i] = 8'h00;
        end
        
        // Load test program
        $readmemh("test.hex", memory);
        $display("Test program loaded from test.hex");
    end
    
    // Instruction memory read
    always @(posedge clk) begin
        if (imem_en && resetn) begin
            if (imem_addr[31:16] == 16'h8000) begin
                imem_rdata <= {memory[imem_addr[15:0]+3],
                              memory[imem_addr[15:0]+2],
                              memory[imem_addr[15:0]+1],
                              memory[imem_addr[15:0]]};
            end else begin
                imem_rdata <= 32'h0;
            end
        end
    end
    
    // Data memory access
    always @(posedge clk) begin
        if (dmem_en && resetn) begin
            // Write
            if (|dmem_wstrb) begin
                if (dmem_wstrb[0]) memory[dmem_addr[15:0]+0] <= dmem_wdata[7:0];
                if (dmem_wstrb[1]) memory[dmem_addr[15:0]+1] <= dmem_wdata[15:8];
                if (dmem_wstrb[2]) memory[dmem_addr[15:0]+2] <= dmem_wdata[23:16];
                if (dmem_wstrb[3]) memory[dmem_addr[15:0]+3] <= dmem_wdata[31:24];
            end 
            // Read
            else begin
                dmem_rdata <= {memory[dmem_addr[15:0]+3],
                              memory[dmem_addr[15:0]+2],
                              memory[dmem_addr[15:0]+1],
                              memory[dmem_addr[15:0]]};
            end
        end
    end
    
endmodule

