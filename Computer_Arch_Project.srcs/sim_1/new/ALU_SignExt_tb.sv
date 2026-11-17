`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 12:32:26 PM
// Design Name: 
// Module Name: ALU_SignExt_tb
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


module alu_signext_tb();

  logic [31:0] a, b, y;
  logic [2:0]  f;
  logic        zero;
  logic [15:0] imm;
  logic [31:0] signimm;

  alu     dut1(a, b, f, y, zero);
  signext dut2(imm, signimm);

  initial
  begin
    imm = 0;
    a = 32'd5; b = 32'd3; f = 3'b010;   #10;  // add: 5 + 3 = 8
    f = 3'b110;                         #10;  // sub: 5 - 3 = 2
    f = 3'b000;                         #10;  // and: 5 & 3 = 1
    f = 3'b001;                         #10;  // or:  5 | 3 = 7
    f = 3'b111;                         #10;  // slt: 5 < 3, y = 0
    a = 32'd3; b = 32'd5;               #10;  // slt: 3 < 5, y = 1
    a = 32'd5; f = 3'b110;              #10;  // sub: 5 - 5 = 0, zero = 1
    imm = 16'd5;                        #10;  // positive: 00000005
    imm = -16'd5;                       #10;  // negative: fffffffb
    $stop;
  end

endmodule
