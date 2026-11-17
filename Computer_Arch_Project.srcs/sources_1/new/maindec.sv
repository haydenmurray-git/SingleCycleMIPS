// Main decoder: opcode -> datapath control signals.
// Supported: R-type, lw, sw, beq, addi, j
module maindec(
    input  logic [5:0] op,
    output logic       memtoreg, memwrite,
    output logic       branch, alusrc,
    output logic       regdst, regwrite,
    output logic       jump,
    output logic [1:0] aluop
);
    logic [8:0] controls;

    assign {regwrite, regdst, alusrc, branch, memwrite,
            memtoreg, jump, aluop} = controls;

    always_comb begin
        case (op)
            6'b000000: controls = 9'b1_1_0_0_0_0_0_10; // R-type
            6'b100011: controls = 9'b1_0_1_0_0_1_0_00; // lw
            6'b101011: controls = 9'b0_0_1_0_1_0_0_00; // sw
            6'b000100: controls = 9'b0_0_0_1_0_0_0_01; // beq
            6'b001000: controls = 9'b1_0_1_0_0_0_0_00; // addi
            6'b000010: controls = 9'b0_0_0_0_0_0_1_00; // j
            default:   controls = 9'b0_0_0_0_0_0_0_00; // unknown op: act as a nop
        endcase
    end
endmodule
