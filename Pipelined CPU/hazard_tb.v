`include "hazard.v"

module hazard_tb;
	reg [4:0] rsD, rtD, rsE, rtE;
 	reg  [4:0] writeregE,  writeregM, writeregW;
 	reg  regwriteE, regwriteM, regwriteW;
 	reg  memtoregE, memtoregM;

	reg [5:0] forwardaE_dump;
	reg [5:0] forwardbE_dump;
	reg [11:0] stall_dump;

	wire [1:0] forwardaE, forwardbE;
    wire  stallF, stallD, flushE;

	hazard uut(/*AUTOINST*/
        // Outputs
        .forwardaE		(forwardaE[1:0]),
        .forwardbE		(forwardbE[1:0]),
        .stallF		(stallF),
        .stallD		(stallD),
        .flushE		(flushE),
        // Inputs
        .rsD			(rsD[4:0]),
        .rtD			(rtD[4:0]),
        .rsE			(rsE[4:0]),
        .rtE			(rtE[4:0]),
        .writeregE		(writeregE[4:0]),
        .writeregM		(writeregM[4:0]),
        .writeregW		(writeregW[4:0]),
        .regwriteE		(regwriteE),
        .regwriteM		(regwriteM),
        .regwriteW		(regwriteW),
        .memtoregE		(memtoregE),
        .memtoregM		(memtoregM)
    );

	initial begin
		$dumpfile("hazard_tb.vcd");
		$dumpvars;
	end

	initial begin
		//testcase 1: SrcA forwarding
		// to forward data from M-stage
		#1
		rsE = 5'd7;
		writeregM = 5'd7;
		writeregW = 5'd8;

		regwriteM = 1'd1;
		regwriteW = 1'd1;

		#1 forwardaE_dump[1:0] = forwardaE;

		//testcase 2: SrcA forwarding
		// to forward data from W-stage
		#1
		rsE = 5'd7;
		writeregM = 5'd8;
		writeregW = 5'd7;

		regwriteM = 1'd1;
		regwriteW = 1'd1;

		#1 forwardaE_dump[3:2] = forwardaE;

		//testcase 3: SrcA forwarding
		// to not forward data
		#1
		rsE = 5'd7;
		writeregM = 5'd8;
		writeregW = 5'd9;

		regwriteM = 1'd1;
		regwriteW = 1'd1;

		#1 forwardaE_dump[5:4] = forwardaE;
		////////////////////////////////////////////////////
		//	SrcB forwarding
		///////////////////////////////////////////////////
		//testcase 4:
		// to forward data from M-stage
		#1
		rtE = 5'd7;
		writeregM = 5'd7;
		writeregW = 5'd8;

		regwriteM = 1'd1;
		regwriteW = 1'd1;

		#1 forwardbE_dump[1:0] = forwardbE;

		//testcase 5:
		// to forward data from W-stage
		#1
		rtE = 5'd7;
		writeregM = 5'd8;
		writeregW = 5'd7;

		regwriteM = 1'd1;
		regwriteW = 1'd1;

		#1 forwardbE_dump[3:2] = forwardbE;

		//testcase 6:
		// to not forward data
		#1
		rtE = 5'd7;
		writeregM = 5'd8;
		writeregW = 5'd9;

		regwriteM = 1'd1;
		regwriteW = 1'd1;

		#1 forwardbE_dump[5:4] = forwardbE;
		////////////////////////////////////////////////////
		//	LW stall
		///////////////////////////////////////////////////
		//testcase 1
		#1
		memtoregE = 1'd1;
		rtE = 5'd7;
		rsD = 5'd7;
		#1 stall_dump[2:0] = {stallF,stallD,flushE};

		//testcase 2
		#1
		memtoregE = 1'd1;
		rtE = 5'd7;
		rtD = 5'd7;
		#1 stall_dump[5:3] = {stallF,stallD,flushE};
		//testcase 3
		#1
		memtoregE = 1'd0;
		rtE = 5'd7;
		rtD = 5'd7;
		#1 stall_dump[8:6] = {stallF,stallD,flushE};

		//testcase 4
		#1
		memtoregE = 1'd1;
		rtE = 5'd7;
		rsD = 5'd8;
		rtD = 5'd9;

		#1 stall_dump[11:9] = {stallF,stallD,flushE};

		#1
		$finish;
	end
endmodule
