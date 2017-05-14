`timescale 1ns/1ns
`define _lab_5
`include "../Lab4/alu32.v"
`include "../Lab4/register file32.v"
`include "../Lab4/mux.v"

module datapath(clk, rst, instruction, regWrite, regDestination, aluSource, aluControl, switch, branch, memWrite, memToReg, pcSource, pcBranch, pcJump, pcPlus4, addressBus, memoryDataRecieved, memoryDataSent);
    input clk, rst;

    input [31:0] instruction, pcPlus4;
    input [2:0] aluControl;
    input regWrite, regDestination, aluSource, switch, branch, memWrite, memToReg;

    output [31:0] pcBranch, pcJump;
    output pcSource;

    input [31:0] memoryDataRecieved;
    output [31:0] addressBus, memoryDataSent;

    wire [4:0] destinationRegisterAddress;
    mux2 #(5) destinationMux(.d0(instruction[15:11]), .d1(instruction[20:16]), .s(regDestination), .y(destinationRegisterAddress));

    wire [31: 0] aData, bData;
    RegisterFile file(.clk(clk), .rst(rst), .Aaddress(instruction[25:21]), .Baddress(instruction[20:16]), .Daddress(destinationRegisterAddress), .Adata(aData), .Bdata(bData), .Ddata(memToReg? memoryDataRecieved: addressBus), .write(regWrite));

    wire [31:0] aluOut, immediate;
    wire Z, N, C, V;

    assign immediate = {{16{instruction[15]}}, instruction[15:0]};

    ALU alu(.A(aData), .B(aluSource? immediate : bData), .switch(switch), .operation(aluControl[2:0]), .O(addressBus), .Z(Z), .N(N), .C(C), .V(V));

    assign memoryDataSent = bData;

    assign pcJump = {pcPlus4[31:28], instruction[25:0], 2'b0};
    assign pcBranch = {immediate[29:0], 2'b0} + pcPlus4;
    assign pcSource = branch & (Z ^ switch);
endmodule
