`timescale 1ns/1ns

module decoder(a, y);
parameter width = 4;

input [width -1:0] a;
output reg [(width * 4) - 1:0] y;

always @ (a) begin
    y = 0;
    y[a] = 1'b1;
end

endmodule