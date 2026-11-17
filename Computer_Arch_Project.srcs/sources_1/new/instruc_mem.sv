`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 02:05:34 PM
// Design Name: 
// Module Name: instruc_mem
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



// Instruction Memory (based on HDL Example 7.15, Harris & Harris)
// 64 words x 32 bits, read only, loaded from memfile.dat

module instruc_mem(input  logic [5:0]  a,
            output logic [31:0] rd);

  logic [31:0] RAM[63:0];                  // 64 words, 32 bits each

  // load the program at the start of simulation
  initial
  begin
    $readmemh("memfile.mem", RAM);
  end

  // read combinationally, a is the word address
  assign rd = RAM[a];

endmodule