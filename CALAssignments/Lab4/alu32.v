`timescale 1ns/1ns
`ifdef _lab_4
    `include "mux.v"
`else
    `include "../Lab4/mux.v"
`endif

module ALU(A, B, switch, operation, O, Z, N, C, V); //Z: Zero flag. N: Negative flag. C: Carry. V: Overflow. 
    input [2:0] operation;
    input [31:0] A, B;
    input switch;
    output [31:0] O;
    output Z, N, C, V;
    
    wire [31:0] add, sl, sla, shift, slt, sltu, lxor, sr, sra, lor, land;
    wire c, v;
    
    assign {c, add} = switch? A - B: A + B;
    assign slt = ($signed(A) < ($signed(B))? 32'b1: 32'b0);
    assign sltu = (A < B)? 32'b1: 32'b0;
    assign lxor = A ^ B;
    assign lor = A | B;
    assign land = A & B;

    assign sl = A << B[4:0];
    assign sr = A >> B[4:0];
    assign sla = $signed(A) <<<  B[4:0];
    assign sra = $signed(A) >>>  B[4:0];
    
    Mux8 mux8(.A(add), .B(switch? sla: sl), .C(slt), .D(sltu), .E(lxor), .F(switch? sra: sr), .G({32{switch}} ^ lor), .H(land), .sel(operation), .O(O));

    assign v = c ^ (add[31] ^ A[31] ^ B[31]);
    assign {C, V} = (operation == 3'b000)? ({c, v}): (2'b00);
    assign Z = (O == 32'b0)? 1'b1: 1'b0;
    assign N = O[31];
endmodule

module alu32(a, b, shamt, f, y, zero);
    input [31:0] a, b;
    input [3:0] f;
    input [4:0] shamt;

    output [31:0] y;
    output zero;

    wire [31:0] secondOperand;

    Mux2 mux2(.A(b), .B({27'b0, shamt}), .O(secondOperand), .sel(2'b01 == f[1:0]));

    ALU alu(.A(a), .B(secondOperand), .switch(f[3]), .operation(f[2:0]), .O(y), .Z(zero));

endmodule