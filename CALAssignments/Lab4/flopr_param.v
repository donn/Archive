`timescale 1ns/1ns

module flopr_param(clk, rst, d, q);
    parameter width = 32;
    input clk, rst;
    input [width - 1:0] q;

    output [width - 1:0] d;
    reg [width - 1:0] d;

    always @ (posedge clk) begin
        if (rst)
            d <= 32'b0;
        else
            d <= q;
    end
endmodule