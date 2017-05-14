// Testbench for ArrayMultiplier

`timescale 1ns/1ns

module ArrayMultiplier_tb;

	//Inputs
	reg [31: 0] A;
	reg [31: 0] B;

    //Outputs
	wire [63: 0] Z;
	
	wire error;
	
	reg [63: 0] Zch;
	assign error = (Z != Zch);
	
	//Instantiation of Unit Under Test
	ArrayMultiplier uut (
		.A(A),
		.B(B),
		.Z(Z)
	);

    integer a;

	initial begin
	for (a = 0; a < 10; a = a + 1)
	begin
	    A = $urandom;
	    B = $urandom;
	    Zch = A * B;
	    #50;
	end

	end

endmodule