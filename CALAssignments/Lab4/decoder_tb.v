`timescale 1ns/1ns
`include "decoder.v"

module decoder_tb;

reg [3: 0] a;
wire [15: 0] y;

decoder uut(.a(a), .y(y));

integer i;

initial begin
    $dumpfile("decoder_tb.vcd");
    $dumpvars(0, decoder_tb);
    #100;
    for(i = 0; i < 16; i++) begin
        a = i;
        #50;
    end
end

endmodule