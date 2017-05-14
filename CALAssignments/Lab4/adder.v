`timescale 1ns/1ns

module adder(a, b, y);
parameter width = 32;

input [width - 1: 0] a;
input [width - 1: 0] b;

output [width -1: 0] y;

assign y = a + b;
endmodule