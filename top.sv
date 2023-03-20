`timescale 1ns / 1ps
module top(
input [31:0] rs1, rs2,
input [6:0] CU_OPCODE,
input [2:0] FUNC,
input [6:0] FUNC7,
input INT_TAKEN,
output logic [3:0] alu_fun,
output logic alu_srcA,
output logic [1:0] alu_srcB, rf_wr_sel,
output logic [2:0] pcSource
    );
    
logic br_eq, br_lt, br_ltu;

branchCond branch1(.rs1(rs1),.rs2(rs2),.br_eq(br_eq),.br_lt(br_lt),.br_ltu(br_ltu));

controlUnit controlUnit1(
    .br_eq(br_eq),
    .br_lt(br_lt),
    .br_ltu(br_ltu),
    .INT_TAKEN(INT_TAKEN),
    .CU_OPCODE(CU_OPCODE),
    .FUNC(FUNC),
    .FUNC7(FUNC7),
    .alu_fun(alu_fun),
    .alu_srcA(alu_srcA),
    .alu_srcB(alu_srcB), 
    .pcSource(pcSource), 
    .rf_wr_sel(rf_wr_sel));
    
endmodule
