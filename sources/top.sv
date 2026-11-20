`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////
// Nexys A7-100T wrapper for the single-cycle MIPS.
//
//   CPU_RESETN (red button)  reset (active low on the board)
//   SW[15]   0 = free-run, 1 = single-step with BTNC (one clock edge per press)
//   SW[14]   free-run speed: 0 = slow (~2 Hz), 1 = fast (~1 kHz)
//   SW[1:0]  7-segment shows: 00 pc, 01 aluout, 10 writedata, 11 instr
//   LED[0]   memwrite      LED[1] cpu clock      LED[2] reset active
//   LED[15:8] pc[9:2] (instruction word index)
//
// The core runs on a registered "cpu_clk" generated from the 100 MHz clock.
//////////////////////////////////////////////////////////////////////////////
module top #(
    parameter SLOW_HALF = 25_000_000,   // 100 MHz / (2*25M) = 2 Hz
    parameter FAST_HALF = 50_000,       // 100 MHz / (2*50k) = 1 kHz
    parameter DEBOUNCE  = 1_000_000     // ~10 ms stable time
)(
    input  logic        CLK100MHZ,
    input  logic        CPU_RESETN,
    input  logic        BTNC,
    input  logic [15:0] SW,
    output logic [15:0] LED,
    output logic        CA, CB, CC, CD, CE, CF, CG, DP,
    output logic [7:0]  AN
);
    // ---------------- reset (synchronized) ----------------
    logic [1:0] rst_sync = 2'b11;
    always_ff @(posedge CLK100MHZ) rst_sync <= {rst_sync[0], ~CPU_RESETN};
    wire reset = rst_sync[1];

    // ---------------- step button ----------------
    logic step_level;
    debounce #(.LIMIT(DEBOUNCE)) db(CLK100MHZ, BTNC, step_level);

    // ---------------- cpu clock ----------------
    logic        cpu_clk = 1'b0;
    logic [31:0] cnt = 32'd0;
    wire  [31:0] half = SW[14] ? FAST_HALF : SLOW_HALF;

    always_ff @(posedge CLK100MHZ) begin
        if (SW[15]) begin
            cnt     <= 0;
            cpu_clk <= step_level;            // one rising edge per button press
        end else if (cnt >= half - 1) begin
            cnt     <= 0;
            cpu_clk <= ~cpu_clk;
        end else begin
            cnt     <= cnt + 1;
        end
    end

    // ---------------- processor + memories ----------------
    logic [31:0] pc, instr, aluout, writedata, readdata;
    logic        memwrite;

    mips        cpu(cpu_clk, reset, pc, instr, memwrite, aluout, writedata, readdata);
    instruc_mem imem(pc[7:2], instr);
    dmem        dmem0(cpu_clk, memwrite, aluout, writedata, readdata);

    // ---------------- display ----------------
    logic [31:0] shown;
    always_comb begin
        case (SW[1:0])
            2'b00:   shown = pc;
            2'b01:   shown = aluout;
            2'b10:   shown = writedata;
            default: shown = instr;
        endcase
    end

    sevenseg_driver disp(CLK100MHZ, shown, {CG, CF, CE, CD, CC, CB, CA}, DP, AN);

    // ---------------- LEDs ----------------
    always_comb begin
        LED       = 16'b0;
        LED[0]    = memwrite;
        LED[1]    = cpu_clk;
        LED[2]    = reset;
        LED[15:8] = pc[9:2];
    end
endmodule


// Button debouncer: synchronizes the input and only changes the output
// after it has been stable for LIMIT clock cycles.
module debounce #(parameter LIMIT = 1_000_000)
                 (input  logic clk, noisy,
                  output logic clean);
    logic [1:0]  sync = 2'b00;
    logic [31:0] count = 0;
    initial clean = 1'b0;

    always_ff @(posedge clk) begin
        sync <= {sync[0], noisy};
        if (sync[1] == clean) begin
            count <= 0;
        end else if (count >= LIMIT - 1) begin
            clean <= sync[1];
            count <= 0;
        end else begin
            count <= count + 1;
        end
    end
endmodule


// Scans the 8 digits (active-low anodes and segments) showing a 32-bit hex value.
module sevenseg_driver(input  logic        clk,
                       input  logic [31:0] value,
                       output logic [6:0]  seg,   // {g,f,e,d,c,b,a}, active low
                       output logic        dp,
                       output logic [7:0]  an);
    logic [19:0] refresh = 0;
    always_ff @(posedge clk) refresh <= refresh + 1;

    wire  [2:0] sel = refresh[19:17];
    logic [3:0] nibble;

    always_comb begin
        an     = ~(8'b1 << sel);
        nibble = value[4*sel +: 4];
        dp     = 1'b1;                         // decimal point off
        case (nibble)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'ha: seg = 7'b0001000;
            4'hb: seg = 7'b0000011;
            4'hc: seg = 7'b1000110;
            4'hd: seg = 7'b0100001;
            4'he: seg = 7'b0000110;
            default: seg = 7'b0001110;         // f
        endcase
    end
endmodule
