// Self-checking testbench for the control unit.
module controller_tb;
    logic [5:0] op, funct;
    logic       zero;
    logic       memtoreg, memwrite, pcsrc, alusrc, regdst, regwrite, jump;
    logic [2:0] alucontrol;
    int errors = 0;

    controller dut(.*);

    task automatic check(string name,
        input logic [5:0] o, f, input logic z,
        input logic e_regwrite, e_regdst, e_alusrc, e_memwrite,
                    e_memtoreg, e_jump, e_pcsrc,
        input logic [2:0] e_alu);
        op = o; funct = f; zero = z; #1;
        if ({regwrite,regdst,alusrc,memwrite,memtoreg,jump,pcsrc,alucontrol} !==
            {e_regwrite,e_regdst,e_alusrc,e_memwrite,e_memtoreg,e_jump,e_pcsrc,e_alu}) begin
            $display("FAIL %s: got rw=%b rd=%b as=%b mw=%b mt=%b j=%b pc=%b alu=%b",
                     name, regwrite, regdst, alusrc, memwrite, memtoreg, jump, pcsrc, alucontrol);
            errors++;
        end
    endtask

    initial begin
        //                       op        funct     z  rw rd as mw mt j  pc alu
        check("add ", 6'b000000, 6'b100000, 0, 1, 1, 0, 0, 0, 0, 0, 3'b010);
        check("sub ", 6'b000000, 6'b100010, 0, 1, 1, 0, 0, 0, 0, 0, 3'b110);
        check("and ", 6'b000000, 6'b100100, 0, 1, 1, 0, 0, 0, 0, 0, 3'b000);
        check("or  ", 6'b000000, 6'b100101, 0, 1, 1, 0, 0, 0, 0, 0, 3'b001);
        check("slt ", 6'b000000, 6'b101010, 0, 1, 1, 0, 0, 0, 0, 0, 3'b111);
        check("lw  ", 6'b100011, 6'b000000, 0, 1, 0, 1, 0, 1, 0, 0, 3'b010);
        check("sw  ", 6'b101011, 6'b000000, 0, 0, 0, 1, 1, 0, 0, 0, 3'b010);
        check("addi", 6'b001000, 6'b000000, 0, 1, 0, 1, 0, 0, 0, 0, 3'b010);
        check("beq0", 6'b000100, 6'b000000, 0, 0, 0, 0, 0, 0, 0, 0, 3'b110);
        check("beq1", 6'b000100, 6'b000000, 1, 0, 0, 0, 0, 0, 0, 1, 3'b110);
        check("j   ", 6'b000010, 6'b000000, 0, 0, 0, 0, 0, 0, 1, 0, 3'b010);
        check("nop ", 6'b111111, 6'b000000, 0, 0, 0, 0, 0, 0, 0, 0, 3'b010);
        if (errors == 0) $display("PASS: all control checks passed");
        else             $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
