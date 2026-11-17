`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2026 10:51:11 AM
// Design Name: 
// Module Name: dmem
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


// Data Memory (based on HDL Example 7.14, Harris & Harris)
// 64 words x 32 bits, combinational read,
// write on the rising edge of clk when we is high
 
module dmem(input  logic clk, we,[31:0] a, wd,
            output logic [31:0] rd);
 
  logic [31:0] RAM[63:0];                  // 64 words, 32 bits each
 
  // write on rising edge of clk (sw)
  always_ff @(posedge clk)
  begin
    if (we)
    begin
      RAM[a[31:2]] <= wd;
    end
  end
 
  // read combinationally (lw), word aligned
  assign rd = RAM[a[31:2]];
 
endmodule
