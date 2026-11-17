`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2026 10:50:11 AM
// Design Name: 
// Module Name: regfile_tb
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


 
// Testbench for regfile
// clk period = 10 ns, rising edges at 0, 10, 20, ...
// inputs change at 5, 15, 25, ... (between edges)
 
module regfile_tb();
 
  logic        clk;
  logic        we3;
  logic [4:0]  ra1, ra2, wa3;
  logic [31:0] wd3;
  logic [31:0] rd1, rd2;
 
  // instantiate device under test
  regfile dut(clk, we3, ra1, ra2, wa3, wd3, rd1, rd2);
 
  // generate clock (same as HDL Example 7.12)
  always
  begin
    clk <= 1; #5; clk <= 0; #5;
  end
 
  // apply stimulus
  initial
  begin
    we3 = 0; wa3 = 0;  wd3 = 0;            // start with writes off
    ra1 = 5; ra2 = 10;                     // watch $5 and $10 the whole time
    #5;
    we3 = 1; wa3 = 5;  wd3 = 32'h000000AA;  #10;  // write AA to $5 (rd1 updates)
    wa3 = 10; wd3 = 32'h12345678;           #10;  // write to $10 (rd2 updates)
    wa3 = 0;  wd3 = 32'hFFFFFFFF;           #10;  // try to write $0
    we3 = 0; wa3 = 5;  wd3 = 32'hDEADBEEF;  #10;  // we3 off, $5 should stay AA
    ra1 = 0; ra2 = 5;                       #10;  // $0 reads 0, $5 still AA
    ra1 = 10; ra2 = 10;                     #10;  // both ports read same reg
    $stop;
  end
 
endmodule
