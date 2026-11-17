`timescale 1ns / 1ps
// Whole-core test. Uses a behavioral instruction ROM inside the testbench
// (so it does not depend on the team's imem) and the team's dmem.
// Program computes values and finally stores 7 at address 84 (and 7 at 80).
module mips_tb;
    logic        clk, reset;
    logic [31:0] pc, instr, aluout, writedata, readdata;
    logic        memwrite;

    logic [31:0] rom [0:17];
    initial begin
        rom[0]  = 32'h20020005; // addi $2,$0,5
        rom[1]  = 32'h2003000c; // addi $3,$0,12
        rom[2]  = 32'h2067fff7; // addi $7,$3,-9
        rom[3]  = 32'h00e22025; // or   $4,$7,$2
        rom[4]  = 32'h00642824; // and  $5,$3,$4
        rom[5]  = 32'h00a42820; // add  $5,$5,$4
        rom[6]  = 32'h10a70008; // beq  $5,$7,+8   (not taken)
        rom[7]  = 32'h0064202a; // slt  $4,$3,$4
        rom[8]  = 32'h10800001; // beq  $4,$0,+1   (taken)
        rom[9]  = 32'h20050000; // addi $5,$0,0    (skipped)
        rom[10] = 32'h00e2202a; // slt  $4,$7,$2
        rom[11] = 32'h00853820; // add  $7,$4,$5
        rom[12] = 32'h00e23822; // sub  $7,$7,$2
        rom[13] = 32'hac670044; // sw   $7,68($3)  -> mem[80]=7
        rom[14] = 32'h8c020050; // lw   $2,80($0)
        rom[15] = 32'h08000011; // j    17
        rom[16] = 32'h20020001; // addi $2,$0,1    (skipped)
        rom[17] = 32'hac020054; // sw   $2,84($0)  -> mem[84]=7
    end
    assign instr = rom[pc[31:2]];

    mips cpu(clk, reset, pc, instr, memwrite, aluout, writedata, readdata);
    dmem dm(clk, memwrite, aluout, writedata, readdata);

    initial begin clk = 0; forever #5 clk = ~clk; end

    initial begin
        reset = 1; #22; reset = 0;
    end

    // success: a store of 7 to address 84
    always @(negedge clk) begin
        if (memwrite) begin
            if (aluout === 32'd84 && writedata === 32'd7) begin
                $display("PASS: stored 7 at address 84");
                $stop;
            end else if (aluout !== 32'd80) begin
                $display("FAIL: unexpected store addr=%0d data=%0d", aluout, writedata);
                $stop;
            end
        end
    end

    initial begin
        #2000;
        $display("FAIL: timeout, pc=%h", pc);
        $stop;
    end
endmodule
