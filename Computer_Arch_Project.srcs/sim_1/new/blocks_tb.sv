`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 01:28:09 PM
// Design Name: 
// Module Name: blocks_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



// Tests the building blocks by wiring them into the
// next PC logic from the single-cycle diagram

module blocks_tb();

  logic        clk, reset, branch;
  logic [31:0] imm;
  logic [31:0] pc, pcplus4, immsh, pcbranch, pcnext;

  flopr #(32) dut1(clk, reset, pcnext, pc);          // PC register
  adder       dut2(pc, 32'd4, pcplus4);              // PC + 4
  sl2         dut3(imm, immsh);                      // imm << 2
  adder       dut4(pcplus4, immsh, pcbranch);        // branch target
  mux2 #(32)  dut5(pcplus4, pcbranch, branch, pcnext);

  // clock
  always
  begin
    clk <= 1; #5; clk <= 0; #5;
  end

  initial
  begin
    reset = 1; branch = 0; imm = 0;
    #5;
    reset = 0;                        #30;  // pc counts 4, 8, 12
    branch = 1; imm = 32'd3;          #10;  // branch: 16 + 12 = 28
    branch = 0;                       #10;  // back to pc + 4: 32
    reset = 1;                        #10;  // pc resets to 0
    $stop;
  end

endmodule
