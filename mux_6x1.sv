`timescale 1ns / 1ps

module mux_6x1(
    input [31:0] PC,
    input [31:0] JALR,
    input [31:0] BRANCH,
    input [31:0] JAL,
    input [31:0] MTVEC,
    input [31:0] MEPC,
    input [2:0] PC_SOURCE,
    output logic [31:0] MUX_OUT
    );
    
    always_comb
    begin
        case(PC_SOURCE)
            3'b000: MUX_OUT = PC;
            3'b001: MUX_OUT = JALR;
            3'b010: MUX_OUT = BRANCH;
            3'b011: MUX_OUT = JAL;
            3'b100: MUX_OUT = MTVEC;
            3'b101: MUX_OUT = MEPC;
            default: MUX_OUT = PC;
        endcase
    end
endmodule