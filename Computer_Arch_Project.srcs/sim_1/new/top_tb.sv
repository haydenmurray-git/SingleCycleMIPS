`timescale 1ns / 1ps
// Self-checking testbench for the Nexys A7 wrapper (top).
// Uses tiny clock-divider / debounce parameters so it finishes quickly.
// Needs memfile.mem available to the simulator (instruc_mem loads it).
module top_tb;
    logic        CLK100MHZ = 0, CPU_RESETN = 0, BTNC = 0;
    logic [15:0] SW = 16'h0000;
    logic [15:0] LED;
    logic        CA, CB, CC, CD, CE, CF, CG, DP;
    logic [7:0]  AN;
    int errors = 0;

    top #(.SLOW_HALF(8), .FAST_HALF(4), .DEBOUNCE(5))
        dut(CLK100MHZ, CPU_RESETN, BTNC, SW, LED, CA, CB, CC, CD, CE, CF, CG, DP, AN);

    always #5 CLK100MHZ = ~CLK100MHZ;                // 100 MHz

    // expected 7-segment pattern {g,f,e,d,c,b,a}, active low
    function automatic logic [6:0] seg_of(input logic [3:0] n);
        case (n)
            4'h0: return 7'b1000000;  4'h1: return 7'b1111001;
            4'h2: return 7'b0100100;  4'h3: return 7'b0110000;
            4'h4: return 7'b0011001;  4'h5: return 7'b0010010;
            4'h6: return 7'b0000010;  4'h7: return 7'b1111000;
            4'h8: return 7'b0000000;  4'h9: return 7'b0010000;
            4'ha: return 7'b0001000;  4'hb: return 7'b0000011;
            4'hc: return 7'b1000110;  4'hd: return 7'b0100001;
            4'he: return 7'b0000110;  default: return 7'b0001110;
        endcase
    endfunction

    task automatic check(input string what, input logic ok);
        if (!ok) begin $display("FAIL: %s", what); errors++; end
    endtask

    // check all 8 digits of the display against an expected 32-bit value
    // (event driven: sample each time the digit select (AN) changes)
    task automatic check_display(input string what, input logic [31:0] expect_val);
        logic [7:0] seen = 8'h00;
        while (seen != 8'hFF) begin
            @(AN); #1;
            for (int d = 0; d < 8; d++) begin
                if (AN === ~(8'b1 << d)) begin
                    seen[d] = 1'b1;
                    if ({CG,CF,CE,CD,CC,CB,CA} !== seg_of(expect_val[4*d +: 4])) begin
                        $display("FAIL: %s digit %0d shows %b, expected %b",
                                 what, d, {CG,CF,CE,CD,CC,CB,CA}, seg_of(expect_val[4*d +: 4]));
                        errors++;
                    end
                end
            end
        end
    endtask

    task automatic press_step();
        BTNC = 1; repeat (30) @(posedge CLK100MHZ);
        BTNC = 0; repeat (30) @(posedge CLK100MHZ);
    endtask

    task automatic do_reset();
        CPU_RESETN = 0; repeat (10) @(posedge CLK100MHZ);
        CPU_RESETN = 1; repeat (5)  @(posedge CLK100MHZ);
    endtask

    logic        got84 = 0;
    logic [31:0] pc_before;

    // watch for the final store of the test program (7 -> address 84)
    always @(negedge dut.cpu_clk)
        if (dut.memwrite && dut.aluout === 32'd84 && dut.writedata === 32'd7) got84 = 1;

    initial begin
        // ---- 1. free-run mode: program should reach its final store ----
        SW = 16'h0000;                                // run, slow, show pc
        do_reset();
        check("reset holds pc at 0 right after reset release", dut.pc === 32'd0);
        repeat (5000) @(posedge CLK100MHZ);
        check("free-run: program stored 7 at address 84", got84);

        // ---- 2. single-step mode ----
        SW = 16'h8000;                                // step mode (SW15)
        CPU_RESETN = 0; repeat (10) @(posedge CLK100MHZ);
        CPU_RESETN = 1; repeat (10) @(posedge CLK100MHZ);
        check("step: pc is 0 after reset", dut.pc === 32'd0);

        pc_before = dut.pc;
        repeat (2000) @(posedge CLK100MHZ);
        check("step: pc does not move without a button press", dut.pc === pc_before);

        repeat (5) press_step();
        check("step: 5 presses advance pc to 20", dut.pc === 32'd20);

        // ---- 3. LEDs ----
        check("LED[15:8] shows pc[9:2]", LED[15:8] === dut.pc[9:2]);
        check("LED[2] low when not in reset", LED[2] === 1'b0);

        // ---- 4. 7-segment display selections ----
        SW[1:0] = 2'b00;  check_display("display pc",        dut.pc);
        SW[1:0] = 2'b11;  check_display("display instr",     dut.instr);
        SW[1:0] = 2'b01;  check_display("display aluout",    dut.aluout);
        SW[1:0] = 2'b10;  check_display("display writedata", dut.writedata);

        if (errors == 0) $display("PASS: top wrapper checks passed");
        else             $display("FAILED: %0d errors", errors);
        $stop;
    end

    initial begin                                     // global timeout
        #60_000_000;
        $display("FAIL: timeout");
        $stop;
    end
endmodule
