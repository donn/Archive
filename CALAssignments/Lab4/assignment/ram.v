`ifndef _ram_v
`define _ram_v

`timescale 1ns/1ns

//Assuming N is address space, added new "depth" parameter
module ram(clk, we, adr, din, dout);

parameter N = 32;
parameter M = 8;
parameter L = 1024;

input clk, we;
input[N - 1:0] adr;
input[M - 1: 0] din;
output[M - 1: 0] dout;

reg[M - 1:0] storage[L - 1:0];

integer ai;

initial
begin
    for (ai = 0; ai < L - 1; ai = ai + 1)
        storage[ai] <= 0;
end

always @ (posedge clk)
begin
    if (we)
        storage[adr & {$clog2(L){1'b1}}] <=  din; 
end

assign dout = storage[adr & {$clog2(L){1'b1}}];

endmodule
`endif