`timescale 1ns/1ns
`include ".v"

module _tb;

reg [31:0] a;
wire [31:0] b;

times4 uut(.a(a), .b(b));

initial begin
    $dumpfile(".vcd");
    $dumpvars(0, _tb);
    #50
    a = 40;
    #50;
end

endmodule