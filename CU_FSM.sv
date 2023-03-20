`timescale 1ns / 1ps

module CU_FSM(
    input clk,
    input interrupt,
    input RST,
    input [6:0] ir,
    output logic pcWrite,
    output logic regWrite,
    output logic memWrite,
    output logic memRead1,
    output logic memRead2,
    output logic CSR_WRITE, INT_TAKEN
    );

    logic [1:0] NS, PS;
    
    parameter[1:0] INST_FETCH = 2'b00, DEC_EXE = 2'b01, WRT_BACK = 2'b10, INTRUPT = 2'b11;

    always_ff @(posedge clk) begin
        if(RST == 1'b1)
            PS <= INST_FETCH;
        else 
            PS <= NS;
    end

    always_comb
    begin
    
    pcWrite = 1'b0; regWrite = 1'b0; CSR_WRITE = 1'b0; INT_TAKEN = 1'b0;
    memWrite = 1'b0; memRead1 = 1'b0; memRead2 = 1'b0;
    
    case(PS)

        INST_FETCH:
            begin
            pcWrite <= 1'b0;
            memRead1 <= 1'b1;
            NS = DEC_EXE;
            end

            
        DEC_EXE:
            begin
            pcWrite = 1'b1;
            
            if(ir == 7'b1100011) // branch
                begin
                if(interrupt)
                    NS = INTRUPT;
                else
                    NS = INST_FETCH;
                end

                
            else if(ir == 7'b0000011) //load
                begin
                memRead2 = 1'b1;
                NS = WRT_BACK;
                end
                        
            else if(ir == 7'b0100011) //store
                begin
                memWrite = 1'b1;
                if(interrupt)
                    NS = INTRUPT;
                else
                    NS = INST_FETCH;
                end
            else if(ir == 7'b1110011) //CSRRWs
                begin 
                regWrite = 1'b1;
                CSR_WRITE = 1'b1;
                if(interrupt)
                    NS = INTRUPT;
                else
                    NS = INST_FETCH;
                end
            else 
                begin
                regWrite <= 1'b1;
                if(interrupt)
                    NS = INTRUPT;
                else
                    NS = INST_FETCH;
                end
            end

          
        WRT_BACK:
            begin
            pcWrite <= 1'b0;
            memWrite <= 1'b0;
            regWrite <= 1'b1;
            if(interrupt)
                NS = INTRUPT;
            else
                NS = INST_FETCH;
            end
            
        INTRUPT:
            begin
            pcWrite = 1'b1; regWrite = 1'b0; CSR_WRITE = 1'b1; INT_TAKEN = 1'b1;
            memWrite = 1'b0; memRead1 = 1'b1; memRead2 = 1'b0;
            NS = INST_FETCH;
            end
            
        default NS = INST_FETCH;
        
    endcase
    end

endmodule

