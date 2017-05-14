`timescale 1ns/1ns
`include "datapath.v"
`include "controlpath.v"

module cpu(clk, rst, pcOut, instruction, addressBus, memoryDataReceived, memoryDataSent, controlBus);

    input clk, rst;

    input [31:0] memoryDataReceived;
    output [31:0] memoryDataSent;
    output [31:0] addressBus;
    output [3:0] controlBus;

    input [31:0] instruction;
    wire [2:0] aluControl;
    wire regWrite, regDestination, aluSource, branch, memWrite, memToReg, switch;

    datapath dp(clk, rst, instruction, regWrite, regDestination, aluSource, aluControl, switch, branch, memWrite, memToReg, pcSource, pcBranch, pcJump, pcPlus4, addressBus, memoryDataReceived, memoryDataSent);

    controlpath cp(.instruction(instruction), .regWrite(regWrite), .regDestination(regDestination), .aluSource(aluSource), .aluControl(aluControl), .switch(switch), .branch(branch), .jump(jump), .memWrite(memWrite), .memToReg(memToReg), .controlBus(controlBus));

    //Program Counter
    reg [31:0] programCounter;
    output [31: 0] pcOut;

    wire [31:0] pcBranch, pcJump, pcPlus4;
    wire pcSource, jump;

    assign pcPlus4 = programCounter + 4;

    always @ (posedge clk)
    begin
        if (rst)
            programCounter = -4;
        else
        begin
            programCounter <= jump? pcJump: (pcSource? pcBranch: pcPlus4);
        end
    end

    assign pcOut = programCounter;

endmodule