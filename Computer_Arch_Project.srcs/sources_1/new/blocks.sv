`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 01:26:25 PM
// Design Name: 
// Module Name: blocks
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



// Building blocks (based on HDL Examples 7.7 - 7.11, Harris & Harris)

// Adder: used for PC + 4 and the branch target
module adder(input  logic [31:0] a, b,
             output logic [31:0] y);

  assign y = a + b;

endmodule


// Shift left by 2 (multiply by 4)
module sl2(input  logic [31:0] a,
           output logic [31:0] y);

  assign y = {a[29:0], 2'b00};

endmodule


// 2:1 mux
module mux2 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1,
              input  logic             s,
              output logic [WIDTH-1:0] y);

  assign y = s ? d1 : d0;

endmodule


// Resettable flip-flop: used for the PC register
module flopr #(parameter WIDTH = 8)
              (input  logic             clk, reset,
               input  logic [WIDTH-1:0] d,
               output logic [WIDTH-1:0] q);

  always_ff @(posedge clk or posedge reset)
  begin
    if (reset)
    begin
      q <= 0;
    end
    else
    begin
      q <= d;
    end
  end

endmodule
