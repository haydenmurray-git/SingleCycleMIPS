// Control unit for the single-cycle MIPS. Interface matches the textbook's
// controller (op = instr[31:26], funct = instr[5:0]) so it drops into mips.sv.
module controller(
    input  logic [5:0] op, funct,
    input  logic       zero,
    output logic       memtoreg, memwrite,
    output logic       pcsrc, alusrc,
    output logic       regdst, regwrite,
    output logic       jump,
    output logic [2:0] alucontrol
);
    logic [1:0] aluop;
    logic       branch;

    maindec md(op, memtoreg, memwrite, branch, alusrc,
               regdst, regwrite, jump, aluop);
    aludec  ad(funct, aluop, alucontrol);

    assign pcsrc = branch & zero;
endmodule
