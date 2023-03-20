`timescale 1ns / 1ps

module branchCond(
input [31:0] rs1, rs2,
output logic br_eq, br_lt, br_ltu
    );
always_comb
    begin
    br_eq <= 0; br_lt <= 0; br_ltu <= 0;
    
        if(rs1 == rs2)
            br_eq <= 1;           
        else if($signed(rs1) < $signed(rs2))
            br_lt <= 1;        
        else if(rs1 < rs2)
            br_ltu <= 1;
    end
endmodule