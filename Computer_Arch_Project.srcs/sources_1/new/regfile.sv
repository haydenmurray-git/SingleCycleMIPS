`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2026 10:47:49 AM
// Design Name: 
// Module Name: regfile
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


// Register File (based on HDL Example 7.6, Harris & Harris)
// 32 x 32-bit registers, two combinational read ports,
// one write port on the rising edge of clk, $0 hardwired to 0
 
module regfile(input  logic clk,we3,[4:0]  ra1, ra2, wa3,[31:0] wd3,
               output logic [31:0] rd1, rd2);
 
  logic [31:0] rf[31:0];                   // 32 registers, 32 bits each
 
  // write third port on rising edge of clk
  always_ff @(posedge clk)
  begin
    if (we3)
    begin
      rf[wa3] <= wd3;
    end
  end
 
  // read two ports combinationally, register 0 hardwired to 0
  assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
  assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
 
endmodule