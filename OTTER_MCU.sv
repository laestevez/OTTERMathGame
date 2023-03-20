`timescale 1ns / 1ps
module OTTER_MCU(
    input clk,
    input rst,
    input INTR,
    input [31:0] IOBUS_IN,
    output logic [31:0] IOBUS_OUT,
    output logic [31:0] IOBUS_ADDR,
    output IOBUS_WR
);

//////////////////////inputs\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

logic PC_Write, regWrite, memWrite, memRead1, memRead2,alu_srcA;
logic [1:0] alu_srcB, rf_wr_sel; 
logic [2:0] pcSource;
logic [3:0] alu_fun;

//////////////////////////Immed\\\\\\\\\\\\\\\\\\\\\\\\\\\

logic [31:0] I_immed, U_immed, S_immed;

////////////////////Components\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

logic [31:0] CSR_MTVEC, CSR_MEPC, RD;    
logic [31:0] jalr, branch, jal, count, pc_4;

pc_withMux muxPC(.clk(clk),.rst(rst),.PC_Write(PC_Write), .PC_SOURCE(pcSource),
    .jalr(jalr),
    .branch(branch),
    .jal(jal),
    .CSR_MTVEC(CSR_MTVEC), 
    .CSR_MEPC(CSR_MEPC),
    .count(count));

//REG FILL//
logic [31:0] rs1, rs2, RFMux;
reg_file RegisterFile(.clk(clk), .en(regWrite), .addr1(IR[19:15]), .addr2(IR[24:20]), .wa(IR[11:7]), 
    .wd(RFMux),
    .rs1(rs1),
    .rs2(rs2));

//ALU///
logic [31:0] ALU_OUT, regA, regB;
ALU ALU1(.A(regA), .B(regB), .ALU_FUN(alu_fun), .ALU_OUT(ALU_OUT));

//Branch and Decoder//
logic INT_TAKEN;
top branchDecoder(.rs1(rs1), .rs2(rs2),
    .CU_OPCODE(IR[6:0]),
    .FUNC(IR[14:12]),
    .FUNC7(IR[31:25]),
    .INT_TAKEN(INT_TAKEN),
    .alu_fun(alu_fun),
    .alu_srcA(alu_srcA),
    .alu_srcB(alu_srcB),
    .pcSource(pcSource),
    .rf_wr_sel(rf_wr_sel));
    
//CSR//
logic CSR_MIE, CSR_WRITE;
CSR  my_csr (
    .CLK       (clk),
    .RST       (rst),
    .INT_TAKEN (INT_TAKEN),
    .ADDR      (IR[31:20]),
    .PC        (count),
    .WD        (ALU_OUT),
    .WR_EN     (CSR_WRITE), 
    .RD        (RD),
    .CSR_MEPC  (CSR_MEPC),
    .CSR_MTVEC (CSR_MTVEC), 
    .CSR_MIE   (CSR_MIE));

//CU FSM//
logic interrupt;
assign interrupt = CSR_MIE & INTR;

CU_FSM CUFSM(.clk(clk),
    .RST(rst),
    .interrupt(interrupt),
    .ir(IR[6:0]),
    .pcWrite(PC_Write),
    .regWrite(regWrite),
    .memWrite(memWrite),
    .memRead1(memRead1),
    .memRead2(memRead2),
    .CSR_WRITE(CSR_WRITE),
    .INT_TAKEN(INT_TAKEN));

//MEMORY//
logic [31:0] IR, MEM_DOUT2;
OTTER_mem_byte OTTER_MEM(
    .MEM_ADDR1(count),     //Instruction Memory Port
    .MEM_ADDR2(ALU_OUT),     //Data Memory Port
    .MEM_CLK(clk),
    .MEM_DIN2(rs2),
    .MEM_WRITE2(memWrite),
    .MEM_READ1(memRead1),
    .MEM_READ2(memRead2),
    .IO_IN(IOBUS_IN),
    .MEM_SIZE(IR[13:12]),
    .MEM_SIGN(IR[14]),
    .MEM_DOUT1(IR),
    .MEM_DOUT2(MEM_DOUT2),
    .IO_WR(IOBUS_WR));

//////////////////MULTIPLEXERS\\\\\\\\\\\\\\\\\\\\\\

//2x1 srcA Mux//
mux_2x1 srcAMux(.d0(rs1),.d1(U_immed),.s(alu_srcA),.y(regA));

//4x1 srcB Mux//
mux_4x1 srcBMux(.zero(rs2), .one(I_immed), .two(S_immed), .three(count),
    .sel(alu_srcB),
    .mux_out(regB));

//4x1 REG FIle Mux//
assign pc_4 = count + 4;
mux_4x1 RegFileMux(.zero(pc_4),.one(RD), .two(MEM_DOUT2), .three(ALU_OUT),
    .sel(rf_wr_sel),
    .mux_out(RFMux));
    
//////////////////////OUTPUTS\\\\\\\\\\\\\\\\\\\\

assign IOBUS_ADDR = ALU_OUT;
assign IOBUS_OUT = rs2;

//////////////////////IMMEDIATE GEN\\\\\\\\\\\\\\\\\\\\

logic [31:0] B_immed, J_immed;
assign I_immed = {{21{IR[31]}},IR[30:20]};
assign U_immed = {IR[31:12],12'b0};
assign S_immed = {{21{IR[31]}},IR[30:25],IR[11:7]};
assign B_immed = {{20{IR[31]}},IR[7],IR[30:25],IR[11:8],1'b0};
assign J_immed = {{12{IR[31]}},IR[19:12],IR[20],IR[30:25],IR[24:21],1'b0};

//////////////////////TARGET GEN\\\\\\\\\\\\\\\\\\\\

assign jalr = rs1 + I_immed;
assign branch = count + B_immed;
assign jal = count + J_immed;

endmodule

