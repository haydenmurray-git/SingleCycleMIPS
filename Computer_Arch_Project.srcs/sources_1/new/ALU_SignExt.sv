`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 12:29:04 PM
// Design Name: 
// Module Name: ALU_SignExt
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


// ALU (based on Figure 5.15 / Exercise 5.9, Harris & Harris)
// f = 010 add, 110 sub, 000 and, 001 or, 111 slt

module alu(input  logic [31:0] a, b,
           input  logic [2:0]  f,
           output logic [31:0] y,
           output logic        zero);

  logic [31:0] bb, sum;

  assign bb  = f[2] ? ~b : b;              // invert b for sub and slt
  assign sum = a + bb + f[2];              // f[2] is carry in, so a + ~b + 1 = a - b

  assign y = (f[1:0] == 2'b00) ? (a & bb) :
             (f[1:0] == 2'b01) ? (a | bb) :
             (f[1:0] == 2'b10) ? sum :
                                 {31'b0, sum[31]};   // slt: 1 if a - b is negative

  assign zero = (y == 0);                  // used by beq

endmodule


// Sign Extension (based on HDL Example 7.9, Harris & Harris)

module signext(input  logic [15:0] a,
               output logic [31:0] y);

  assign y = {{16{a[15]}}, a};             // copy sign bit into upper 16

endmodule
