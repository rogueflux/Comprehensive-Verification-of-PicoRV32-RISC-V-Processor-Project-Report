# Test with hex file in correct location
create_project -force hex_test ./hex_sim -part xc7a100tcsg324-1
set_property target_language Verilog [current_project]

# Add files
add_files -norecurse ../../picorv32/picorv32.v

# Create testbench with hex file loading
set tb_content {
`timescale 1ns/1ps

module hex_test;
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
    
    reg [31:0] mem [0:1023];
    integer instruction_count = 0;
    
    initial begin
        \$display("=== HEX FILE TEST ===");
        
        // Initialize memory to 0
        for (integer i = 0; i < 1024; i = i + 1) begin
            mem[i] = 32'h0;
        end
        
        // Load hex file
        \$readmemh("test_converted.hex", mem);
        \$display("Hex file loaded");
        
        // Check what was loaded
        \$display("Loaded instructions (first 10):");
        integer loaded_count = 0;
        for (integer i = 0; i < 1024 && loaded_count < 10; i = i + 1) begin
            if (mem[i] != 0) begin
                \$display("  [%0d] = 0x%08h", i, mem[i]);
                loaded_count = loaded_count + 1;
            end
        end
        
        if (loaded_count == 0) begin
            \$display("ERROR: No instructions loaded!");
            \$display("Current directory: %s", \$realtime);
            \$system("pwd");
            \$system("ls -la *.hex");
            \$finish;
        end
        
        // Start CPU
        #100;
        rst = 0;
        \$display("CPU started");
        
        // Run for a while
        #200000;
        
        \$display("Test completed");
        \$display("Instructions fetched: %0d", instruction_count);
        \$display("Trap: %0d", trap);
        
        \$finish;
    end
    
    // Count instruction fetches
    always @(posedge clk) begin
        if (!rst && mem_valid && !mem_instr) begin
            instruction_count <= instruction_count + 1;
        end
    end
    
    // Memory interface
    always @(posedge clk) begin
        if (mem_valid && !mem_ready) begin
            mem_ready <= 1;
            if (mem_wstrb) begin
                mem[mem_addr >> 2] <= mem_wdata;
                \$display("[%0t] STORE @0x%08h = 0x%08h", \$time, mem_addr, mem_wdata);
            end else begin
                mem_rdata <= mem[mem_addr >> 2];
                if (!rst) begin
                    \$display("[%0t] FETCH @0x%08h = 0x%08h", \$time, mem_addr, mem_rdata);
                end
            end
        end else begin
            mem_ready <= 0;
        end
    end
endmodule
}

# Write and add testbench
set fh [open "hex_test_tb.sv" w]
puts $fh $tb_content
close $fh

add_files -norecurse hex_test_tb.sv

# Set top
set_property top hex_test [get_filesets sources_1]
set_property top hex_test [get_filesets sim_1]

# Copy hex file to simulation directory before launching
file copy -force test_converted.hex ./hex_sim/

puts "Launching simulation..."
launch_simulation

run 100us
close_sim
exit 0
