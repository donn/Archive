`timescale 1ns/1ns

`include "signext.v"

module signext_tb;

	//Inputs
	reg [31: 0] a;


	//Outputs
	wire [31: 0] y;


	//Instantiation of Unit Under Test
	signext uut (
		.a(a),
		.y(y)
	);


	initial begin
	//Inputs initialization
    $dumpfile("signext_tb.vcd");
    $dumpvars(0, signext_tb);
		a = 0;


	//Wait for the reset
		#100;
		a = 16'hFFFF;
		#50
		a = 16'h0FFF;
		#50;

	end

endmodule