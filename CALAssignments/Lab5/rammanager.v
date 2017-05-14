`timescale 1ns / 1ns
`include "../Lab4/assignment/ram.v"

module rammanager(clk, writeEnables, memin, memaddr, memout);
	
	input clk;
	input[31:0] memaddr, memin;
	input[3:0] writeEnables;
	output[31:0] memout;
	
	wire[3:0] finalWrite;
	wire[10:0] midAddr  [3:0];
	wire[8:0] finalAddr [3:0];
	wire[31:0] finalIn, finalOut, ramOut;
	
	Mux4 #(1) mw1(writeEnables[0], writeEnables[1], writeEnables[2], writeEnables[3], memaddr[1:0], finalWrite[0]);
	Mux4 #(1) mw2(writeEnables[1], writeEnables[2], writeEnables[3], writeEnables[0], memaddr[1:0], finalWrite[1]);
	Mux4 #(1) mw3(writeEnables[2], writeEnables[3], writeEnables[0], writeEnables[1], memaddr[1:0], finalWrite[2]);
	Mux4 #(1) mw4(writeEnables[3], writeEnables[0], writeEnables[1], writeEnables[2], memaddr[1:0], finalWrite[3]);
	
	assign midAddr[0] = memaddr;
	assign midAddr[1] = memaddr + 1;
	assign midAddr[2] = memaddr + 2;
	assign midAddr[3] = memaddr + 3;
	
	assign finalAddr[0] = midAddr[0][10:2];
	assign finalAddr[1] = midAddr[1][10:2];
	assign finalAddr[2] = midAddr[2][10:2];
	assign finalAddr[3] = midAddr[3][10:2];
	
	Mux4 #(8) mi1(memin[7:0], memin[15:8], memin[23:16], memin[31:24], memaddr[1:0], finalIn[ 7: 0]);
	Mux4 #(8) mi2(memin[15:8], memin[23:16], memin[31:24], memin[7:0], memaddr[1:0], finalIn[15: 8]);
	Mux4 #(8) mi3(memin[23:16], memin[31:24], memin[7:0], memin[15:8], memaddr[1:0], finalIn[23:16]);
	Mux4 #(8) mi4(memin[31:24], memin[7:0], memin[15:8], memin[23:16], memaddr[1:0], finalIn[31:24]);

	ram #(9, 8, 1024) ramA (
	  .clk(clk),
	  .we(finalWrite[0]),
	  .adr(finalAddr[0]),
	  .din(finalIn[7:0]),
	  .dout(ramOut[7:0])
	);
	
	ram #(9, 8, 1024) ramB (
	  .clk(clk),
	  .we(finalWrite[1]),
	  .adr(finalAddr[1]),
	  .din(finalIn[15:8]),
	  .dout(ramOut[15:8])
	);
	
	ram #(9, 8, 1024) ramC (
	  .clk(clk),
	  .we(finalWrite[2]),
	  .adr(finalAddr[2]),
	  .din(finalIn[23:16]),
	  .dout(ramOut[23:16])
	);
	
	ram #(9, 8, 1024) ramD (
	  .clk(clk),
	  .we(finalWrite[3]),
	  .adr(finalAddr[3]),
	  .din(finalIn[31:24]),
	  .dout(ramOut[31:24])
	);
	
	Mux4 #(8) mo1(ramOut[7:0], ramOut[31:24], ramOut[23:16], ramOut[15:8], memaddr[1:0], finalOut[ 7: 0]);
	Mux4 #(8) mo2(ramOut[15:8], ramOut[7:0], ramOut[31:24], ramOut[23:16], memaddr[1:0], finalOut[15: 8]);
	Mux4 #(8) mo3(ramOut[23:16], ramOut[15:8], ramOut[7:0], ramOut[31:24], memaddr[1:0], finalOut[23:16]);
	Mux4 #(8) mo4(ramOut[31:24], ramOut[23:16], ramOut[15:8], ramOut[7:0], memaddr[1:0], finalOut[31:24]);

	assign memout = ramOut;

endmodule
