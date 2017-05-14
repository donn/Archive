module hazard
(
    input [4:0] rsD, rtD, rsE, rtE,
    input  [4:0] writeregE,  writeregM, writeregW,
    input  regwriteE, regwriteM, regwriteW,
    input  memtoregE, memtoregM, branchD,
    output [1:0] forwardaE, forwardbE,
    output  stallF, stallD, flushE
);

assign forwardaE = ((rsE === writeregM)? 2'b10: ((rsE === writeregW)? 2'b01: 2'b00)) & {2{rsE != 5'b0}};
assign forwardbE = ((rtE === writeregM)? 2'b10: ((rtE === writeregW)? 2'b01: 2'b00)) & {2{rtE != 5'b0}};

assign flushE = ((rsD == rtE) | (rtD == rtE)) & memtoregE;
assign stallD = flushE;
assign stallF = stallD;

endmodule