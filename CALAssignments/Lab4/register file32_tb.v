`timescale 1ns/1ns
`include "register file32.v"

module RegisterFile_tb;

	//Inputs
	reg clk;
	reg rst;
	reg write;
	reg [4: 0] Aaddress;
	reg [4: 0] Baddress;
	reg [4: 0] Daddress;
	reg [31: 0] Ddata;


	//Outputs
	wire [31: 0] Adata;
	wire [31: 0] Bdata;


	//Instantiation of Unit Under Test
	RegisterFile uut (
		.clk(clk),
		.rst(rst),
		.write(write),
		.Aaddress(Aaddress),
		.Baddress(Baddress),
		.Daddress(Daddress),
		.Ddata(Ddata),
		.Adata(Adata),
		.Bdata(Bdata)
	);

    always #5 clk = !clk;

	initial begin
        $dumpfile("register file32_tb.vcd");
        $dumpvars(0, RegisterFile_tb);
	//Inputs initialization
		clk = 0;
		rst = 0;
		write = 0;
		Aaddress = 0;
		Baddress = 0;
		Daddress = 0;
		Ddata = 0;
        #51
        Daddress = 5'b10001;
        Ddata = 222;
        write = 1;
        #51
        Daddress = 0;
        Ddata = 777;
        #50
        Daddress = 5'b10010;
        #50
        Aaddress = 5'b10001;
        Baddress = 5'b10010;
        Daddress = 5'b10011;
        Ddata = Adata + Bdata;
        #50
        Aaddress = 5'b10011;
        #50
        $finish;

	end

endmodule