`timescale 1ns/1ns

module FA(a, b, ci, s, co);
input a, b, ci;
output co, s;

assign {co, s} = a + b + ci;

endmodule