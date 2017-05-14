`define _lab_4
`include "alu32.v"

module alu32_tb;

reg [31:0] a, b;
reg [3:0] f;
reg [4:0] shamt;

wire [31:0] y;
wire zero;

reg [31:0] ych;
wire error;

assign error = (y != ych);

alu32 uut(.a(a), .b(b), .f(f), .shamt(shamt), .y(y), .zero(zero));

initial begin
$dumpfile("alu32_tb.vcd");
$dumpvars(0, alu32_tb);
#50 //ADD
a = $random;
b = $random;
f = 4'b0000;
shamt = $random;
ych = a + b;
#50 //SUB
a = $random;
b = $random;
f = 4'b1000;
shamt = $random;
ych = a - b;
#50 //SLL
a = $random;
b = $random;
f = 4'b0001;
shamt = 5;
ych = a << shamt;
#50 //SLA
a = $random;
b = $random;
f = 4'b1001;
shamt = 5;
ych = $signed(a) <<< shamt;
#50 //XOR
a = $random;
b = $random;
f = 4'b0100;
shamt = $random;
ych = a ^ b;
#50 //SRL
a = $random;
b = $random;
f = 4'b0101;
shamt = $random;
ych = a >> shamt;
#50 //SRA
a = $random;
b = $random;
f = 4'b1101;
shamt = $random;
ych = $signed(a) >>> shamt;
#50 //OR
a = $random;
b = $random;
f = 4'b0110;
shamt = $random;
ych = a | b;
#50 //AND
a = $random;
b = $random;
f = 4'b0111;
shamt = $random;
ych = a & b;
end

endmodule