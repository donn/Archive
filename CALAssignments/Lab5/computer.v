`include "cpu.v"
`include "rammanager.v"
`include "../Lab4/assignment/rom.v"

module computer;

reg clk;
reg rst;

wire [31: 0] pcOut, instruction, addressBus, memToCPU, cpuToMem;
wire [3: 0] controlBus;

cpu uuta(clk, rst, pcOut, instruction, addressBus, memToCPU, cpuToMem, controlBus);
rammanager uutb(.clk(clk), .writeEnables(controlBus), .memin(cpuToMem), .memaddr(addressBus), .memout(memToCPU));
rom #(30, 32, 18) uutc(.adr(pcOut[31:2]), .dout(instruction));

always #5 clk = !clk;

initial
begin
    $dumpfile("computer.vcd");
    $dumpvars(0, computer);
    #50 //ADD
    clk = 0;
    rst = 1;
    #100
    rst = 0;
    #1000
    $finish;
end

endmodule