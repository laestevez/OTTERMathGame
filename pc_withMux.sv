`timescale 1ns / 1ps

module pc_withMux(
input clk, rst, PC_Write,
input [2:0] PC_SOURCE,
input [31:0] jalr, branch, jal,
input [31:0] CSR_MTVEC, CSR_MEPC,
output logic [31:0] count
    );
    logic [31:0] MUX_OUT;
    logic [31:0] pc_4;
    
    initial begin
    pc_4 = 0;
    end
    
    mux_6x1 mux6(
    .PC(pc_4),
    .JALR(jalr),
    .BRANCH(branch),
    .JAL(jal),
    .MTVEC(CSR_MTVEC),
    .MEPC(CSR_MEPC),
    .PC_SOURCE(PC_SOURCE),
    .MUX_OUT(MUX_OUT));
        
    pc pc1(.clk(clk),.rst(rst),.PC_Write(PC_Write),.data(MUX_OUT),
   .PC_COUNT(count));
   
    assign pc_4 = count + 4;   
 
endmodule
