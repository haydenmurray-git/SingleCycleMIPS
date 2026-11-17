`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2026 10:52:13 AM
// Design Name: 
// Module Name: dmem_tb
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


// Testbench for dmem
// clk period = 10 ns, rising edges at 0, 10, 20, ...
// inputs change at 5, 15, 25, ... (between edges)
 
module dmem_tb();
 
  logic        clk, we;
  logic [31:0] a, wd;
  logic [31:0] rd;
 
  dmem dut(clk, we, a, wd, rd);
 
  // clock
  always
  begin
    clk <= 1; #5; clk <= 0; #5;
  end
 
  initial
  begin
    we = 0; a = 0; wd = 0;
    #5;
    we = 1; a = 32'd0; wd = 32'd5;    #10;  // store 5 at address 0
    a = 32'd4; wd = 32'd15;           #10;  // store 15 at address 4
    we = 0; a = 32'd0;                #10;  // read address 0
    a = 32'd4;                        #10;  // read address 4
    wd = 32'd99;                      #10;  // we = 0, address 4 stays 15
    $stop;
  end
 
endmodule