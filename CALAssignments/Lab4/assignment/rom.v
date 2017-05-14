`ifndef _rom_v
`define _rom_v

//Assuming N is address space, added new "depth" parameter
module rom(adr, dout);

parameter N = 32;
parameter M = 8;
parameter L = 33;

input[N - 1:0] adr;
output[M - 1: 0] dout;

reg[M - 1:0] storage[L - 1:0];

initial
begin
    $readmemh("rom.txt", storage, 0, L - 1);
end

assign dout = storage[adr & {$clog2(L){1'b1}}];

endmodule
`endif