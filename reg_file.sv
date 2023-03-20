`timescale 1ns / 1ps

module reg_file(
    input clk, en, 
    input [4:0] addr1, addr2, wa,
    input[31:0] wd,
    output logic [31:0] rs1, rs2
);
logic [31:0] ram [0:31];

assign rs1 = (addr1 != 5'd0)?ram[addr1]:32'd0;
assign rs2 = (addr2 != 5'd0)?ram[addr2]:32'd0;  

always_ff @(posedge clk)
    begin 
    if(en == 1 && wa != 0)
            ram[wa] <= wd;
    end
endmodule
