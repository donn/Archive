`timescale 1ns/1ns
`include "adder.v"

module adder_tb;

reg [31:0] a, b;
wire [31:0] y;

reg [31:0] ych;
wire error;

assign error = (y != ych);

adder uut(.a(a), .b(b), .y(y));

integer i;

initial begin
$dumpfile("adder_tb.vcd");
$dumpvars(0, adder_tb);
#50 //ADD
for (i = 0; i < 16; i = i + 1) begin
    a = $random;
    b = $random;
    ych = a + b;
    #50;
end
end

endmodule