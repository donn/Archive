`timescale 1ns/1ns

//"" is an invalid verilog module name. Cannot comply with interface.

module times4(a, b);

input [31:0] a;
output [31:0] b;

assign b = {a[29:0], 2'b00};

endmodule