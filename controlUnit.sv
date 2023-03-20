`timescale 1ns / 1ps

module controlUnit(
input br_eq,
input br_lt,
input br_ltu,
input INT_TAKEN,
input [6:0] CU_OPCODE,
input [2:0] FUNC,
input [6:0] FUNC7,
output logic [3:0] alu_fun,
output logic alu_srcA,
output logic [1:0] alu_srcB, rf_wr_sel,
output logic [2:0] pcSource
    );
    
typedef enum logic[6:0] {
    LUI     = 7'b0110111,
    AUIPC   = 7'b0010111,
    JAL     = 7'b1101111,
    JALR    = 7'b1100111,
    BRANCH  = 7'b1100011,
    LOAD    = 7'b0000011,
    STORE   = 7'b0100011,
    OP_IMM  = 7'b0010011,
    OP      = 7'b0110011,
    CSRW    = 7'b1110011
    } 
opcode_t;opcode_t OPCODE;
assign OPCODE = opcode_t'(CU_OPCODE);

always_comb
    begin
    alu_fun <= 4'b1111; alu_srcA <= 0; alu_srcB <= 0;
    pcSource <= 0; rf_wr_sel <= 0;
    
    case(CU_OPCODE)
        
        LUI:
            begin
			    alu_srcA <= 1'b1;
			    alu_fun <= 4'b1001;
               	rf_wr_sel <= 2'b11;
            end
        AUIPC:
            begin
                alu_srcA <= 1'b1;
                alu_fun <= 4'b0000;
                alu_srcB <= 2'b11;
                rf_wr_sel <= 2'b11;
            end
        JAL:
            begin
                pcSource <= 3'b011;
                rf_wr_sel <= 2'b00;
 
            end
        JALR:
            begin
                if(FUNC == 3'b000)
                begin
                     pcSource <= 3'b001;
                     alu_srcB <= 2'b01;
                     rf_wr_sel <= 2'b00;
            	end
            end
        BRANCH:
            begin
              
          //BRANCH EQUAL
          if(FUNC == 3'b000 && br_eq == 1 )
          begin
             if (INT_TAKEN)
                pcSource <= 3'b100;
             else
	           pcSource <= 3'b010;
		  rf_wr_sel <= 1'b0;
          end
	               
         //BRANCH NOT EQUAL
         if(FUNC == 3'b001 && br_eq == 0)
         begin
		 pcSource <= 3'b010;
	     rf_wr_sel <= 1'b0;
	     end
				
        //BRANCH LESS THAN
        if(FUNC == 3'b100 && br_lt == 1)
        begin
			pcSource <= 3'b010;
			rf_wr_sel <= 1'b0;
				
            	end
            	
        //BRANCH GREATER THAN EQUAL
        if(FUNC == 3'b101 && (br_lt == 0 || br_eq == 1))
        begin
			pcSource <= 3'b010;
			rf_wr_sel <= 1'b0;
				
            	end
	    //BRANCH LESS THAN UNSIGNED
        if(FUNC == 3'b110 && br_ltu == 1)
            begin
			pcSource <= 3'b010;
			rf_wr_sel <= 1'b0;
            end
            
	    //BRANCH GREATER THAN EQUAL UNSIGNED
        if(FUNC == 3'b111 && (br_ltu == 0 || br_eq == 1) )
            begin
			pcSource <= 3'b010;
			rf_wr_sel <= 1'b0;
			end		
		 	
        end
        
        LOAD:
            begin
			alu_srcA <= 1'b0;
            alu_srcB <= 2'b01;
            rf_wr_sel <= 2'b10;
            alu_fun <= 4'b0000;
            end
        STORE:
            begin
			alu_srcA <= 1'b0;
			alu_srcB <= 2'b10;
			rf_wr_sel <= 2'b10;
			alu_fun <= 4'b0000;
            end
        OP_IMM:
            begin
			alu_srcB <= 2'b01;
			rf_wr_sel <= 2'b11;

			//addi
			if(FUNC == 3'b000)
				alu_fun <= 4'b0000;
			//slti
			if(FUNC == 3'b010)
				alu_fun <= 4'b0010;
			//sltiu
			if(FUNC == 3'b011)
				alu_fun <= 4'b0011;
			//xori
			if(FUNC == 3'b100)
				alu_fun <= 4'b0100;
			//ori
			if(FUNC == 3'b110)
				alu_fun <= 4'b0110;
			//andi
			if(FUNC == 3'b111)
				alu_fun <= 4'b0111;
			//slli
			if(FUNC == 3'b001 && FUNC7 == 7'b0000000)
				alu_fun <= 4'b0001;
			//srli
			if(FUNC == 3'b101 && FUNC7 == 7'b0000000)
				alu_fun <= 4'b0101;
			//srai
			if(FUNC == 3'b101 && FUNC7 == 7'b0100000)
				alu_fun <= 4'b1101;
            end
        OP:
            begin
			alu_srcA <= 1'b0;
			alu_srcB <= 1'b0;
			rf_wr_sel <= 2'b11;
            //add
            if(FUNC == 3'b000 && FUNC7 == 7'b0000000)
                alu_fun <= 4'b0000;
			//sub
			if(FUNC == 3'b000 && FUNC7 == 7'b0100000)
                alu_fun <= 4'b1000;
			//sll
			if(FUNC == 3'b001)
                alu_fun <= 4'b0001;
			//slt
			if(FUNC == 3'b010)
                alu_fun <= 4'b0010;
			//sltu
			if(FUNC == 3'b011)
                alu_fun <= 4'b0011;
			//xor
			if(FUNC == 3'b100)
                alu_fun <= 4'b0100;
			//srl
			if(FUNC ==3'b101 && FUNC7 == 7'b0000000)
                alu_fun <= 4'b0101;
			//sra
			if(FUNC == 3'b101 && FUNC7 == 7'b0100000)
                alu_fun <= 4'b1101;
			//or
			if(FUNC == 3'b110)
                alu_fun <= 4'b0110;
			//and
			if(FUNC == 3'b111)
                alu_fun <= 4'b0111;

            end
       CSRW:
         begin
            // mret
            if (FUNC == 3'b000)
                pcSource = 3'b101;
                rf_wr_sel = 2'b01;
            //csrrw
            if (FUNC == 3'b001) 
                pcSource = 3'b000;
                rf_wr_sel = 2'b01;
            end
      endcase
      
    end
endmodule
