`timescale 1ns/1ns
`include "flopr_param.v"

module flopr_param_tb;

	//Inputs
	reg clk;
	reg rst;
	reg [31: 0] q;

	//Outputs
	wire [31: 0] d;

	//Instantiation of Unit Under Test
	flopr_param uut (
		.clk(clk),
		.rst(rst),
		.q(q),
		.d(d)
	);

    always #50 clk = !clk;

	initial begin
    $dumpfile("flopr_param_tb.vcd");
    $dumpvars(0, flopr_param_tb);
    
	//Inputs initialization
		clk = 0;
		rst = 1;
		q = 0;
	//Wait for the reset
		#110;
        rst = 0;
        q = 400;
        #110;
        rst = 1;
        #50;
	end

endmodule