`timescale 1ns/1ns

module signext(a, y);
    parameter inputLength = 16;
    
    input [31:0] a;
    output [31:0] y;
    
    assign y = {{(32 - inputLength){a[inputLength - 1]}}, a[inputLength - 1: 0]};
endmodule