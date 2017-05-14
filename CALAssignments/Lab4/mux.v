`ifndef _rb_mux
`define _rb_mux

`timescale 1ns/1ns

module Mux2(A, B, sel, O);
    parameter width = 32;
    input sel;
    input  [width - 1:0] A, B;
    output [width - 1:0] O;
    assign O = (sel)? B : A;
endmodule

module Mux4(A, B, C, D, sel, O);
    parameter width = 32;
    input  [1:0] sel;
    input  [width - 1:0] A, B, C, D;
    output [width - 1:0] O;
    
    wire [width - 1:0] w1, w2;
    Mux2 #(width) m1(A, B, sel[0], w1);
    Mux2 #(width) m2(C, D, sel[0], w2);
    Mux2 #(width) m3(w1, w2, sel[1], O);
endmodule

module Mux8(A, B, C, D, E, F, G, H, sel, O);
    parameter width = 32;
    input  [2:0] sel;
    input  [width - 1:0] A, B, C, D, E, F, G, H;
    output [width - 1:0] O;
    
    wire [width - 1:0] w1, w2;
    Mux4 #(width) m1(A, B, C, D, sel[1:0], w1);
    Mux4 #(width) m2(E, F, G, H, sel[1:0], w2);
    Mux2 #(width) m3(w1, w2, sel[2], O);
endmodule

module mux4(d0, d1, d2, d3, s, y);
    parameter width = 32;
    input [width - 1:0] d0, d1, d2, d3;
    input [1:0] s;
    output [width - 1:0] y;

    Mux4 #(width) m(.A(d0), .B(d1), .C(d2), .D(d3), .sel(s), .O(y));
endmodule

module mux2(d0, d1, s, y);
    parameter width = 32;
    input [width - 1:0] d0, d1;
    input s;
    output [width - 1:0] y;

    Mux2 #(width) m(.A(d0), .B(d1), .sel(s), .O(y));
endmodule


`endif