`timescale 1ns / 1ps

module pc(
input clk, rst, PC_Write,
input [31:0] data,
output logic [31:0] PC_COUNT
    );
    always_ff @ (posedge clk)
    begin
        if (rst == 1) PC_COUNT <= 0;
	  else if (PC_Write == 1) PC_COUNT <= data;
    end
endmodule


