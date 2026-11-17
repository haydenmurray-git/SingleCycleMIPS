`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 02:07:08 PM
// Design Name: 
// Module Name: instruc_mem_tb
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



module instruc_mem_tb();

  logic [5:0]  a;
  logic [31:0] rd;

  instruc_mem dut(a, rd);

  initial
  begin
    a = 0;                            #10;  // addi $2, $0, 5   -> 20020005
    a = 1;                            #10;  // addi $3, $0, 12  -> 2003000c
    a = 2;                            #10;  // addi $7, $3, -9  -> 2067fff7
    a = 3;                            #10;  // or $4, $7, $2    -> 00e22025
    a = 6;                            #10;  // beq $5, $7, end  -> 10a7000a
    a = 13;                           #10;  // sw $7, 68($3)    -> ac670044
    a = 14;                           #10;  // lw $2, 80($0)    -> 8c020050
    a = 17;                           #10;  // sw $2, 84($0)    -> ac020054 (last)
    a = 18;                           #10;  // past the program -> X
    $stop;
  end

endmodule
