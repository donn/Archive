`timescale 1ns/1ns
`include "mux.v"

module mux_tb;

reg [31: 0] d0a, d1a, d0b, d1b, d2b, d3b;
reg [1: 0] sa, sb;

wire [31: 0] ya, yb;

mux2 uuta(.d0(d0a), .d1(d1a), .s(sa[0]), .y(ya));
mux4 uutb(.d0(d0b), .d1(d1b), .d2(d2b), .d3(d3b), .s(sb), .y(yb));

initial begin
    $dumpfile("mux_tb.vcd");
    $dumpvars(0, mux_tb);
    sa = 1'b0;
    sb = 2'b00;
    d0a = 32'hA;
    d1a = 32'hB;
    d0b = 32'hA;
    d1b = 32'hB;
    d2b = 32'hC;
    d3b = 32'hD;
    #100
    sa = 1'b1;
    sb = 2'b01;
    #5
    sb = 2'b10;
    #5
    sb = 2'b11;
    #5;  
end

endmodule