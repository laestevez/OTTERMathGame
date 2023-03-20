`timescale 1ns / 1ps

module mux_4x1(
input logic [31:0] zero,one,two,three,
input logic [1:0] sel,
output logic [31:0] mux_out
);
logic [31:0] low, hi;

mux_2x1 lowmux(zero,one,sel[0],low);
mux_2x1 himux(two,three,sel[0],hi);
mux_2x1 outmux(low,hi,sel[1],mux_out);
endmodule
