`timescale 1ns / 1ps

module mux_2x1 #(parameter width = 32)(
input logic [width-1:0] d0,d1,
input logic s,
output logic[width-1:0]y
);
assign y = s? d1 :d0;
endmodule

