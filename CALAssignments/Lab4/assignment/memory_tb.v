`timescale 1ns/1ns

`include "rom.v"
`include "ram.v"

module memory_tb;

reg [31:0] address;
reg enable;
reg clk;
reg error;

wire [7:0] transfer;
wire [7:0] dout;

rom uuta(.adr(address), .dout(transfer));
ram uutb(.clk(clk), .we(enable), .adr(address), .din(transfer), .dout(dout));

always #5 clk = !clk;

integer ai;

initial
begin
    $dumpfile("memory_tb.vcd");
    $dumpvars(0, memory_tb);
    clk = 0;
    address = 0;
    enable = 0;
    error = 0;
    #100;
    enable = 1;
    #3;
    for (ai = 0; ai < 34; ai = ai + 1)
    begin
        address = ai;
        #10;
    end
    enable = 0;
    for (ai = 0; ai < 34; ai = ai + 1)
    begin
        address = ai;
        error = (transfer != dout);
        #10;
    end
    $finish;
end

endmodule