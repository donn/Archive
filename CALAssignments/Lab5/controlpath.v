`timescale 1ns/1ns

module controlpath(instruction, regWrite, regDestination, aluSource, aluControl, switch, branch, jump, memWrite, memToReg, controlBus);

    input [31:0] instruction;
    output reg [2:0] aluControl;
    output reg [3:0] controlBus;
    output reg regWrite, regDestination, aluSource, switch, branch, memWrite, memToReg, jump;

    wire [5:0] opcode, funct;
    assign opcode = instruction[31:26];
    assign funct = instruction[5:0];

    always @ (opcode or funct)
    begin
        regWrite = 0;
        regDestination = 0;
        aluSource = 0;
        branch = 0;
        memWrite = 0;
        memToReg = 0;
        switch = 0;
        aluControl = 0;
        controlBus = 0;
        jump = 0;
        // $display("Instruction: %h", instruction);
        // $display("Opcode: %h", opcode);
        case (opcode)
            6'h0: //R-type
            begin
                regWrite  = 1;
                case (funct)
                    6'h4: //sllv
                        aluControl = 3'b001;
                    6'h5: //slav (not officially supported)
                    begin
                        aluControl = 3'b001;
                        switch = 1;
                    end
                    6'h6: //srlv
                        aluControl = 3'b101;
                    6'h7: //srav
                    begin
                        aluControl = 3'b101;
                        switch = 1;
                    end
                    6'h20, 6'h21: //add, addu
                        aluControl = 3'b000;
                    6'h22, 6'h23: //sub, subu
                    begin
                        aluControl = 3'b000;
                        switch = 1;
                    end
                    6'h24: //and
                        aluControl = 3'b111;
                    6'h25: //or
                        aluControl = 3'b110;
                    6'h26: //xor
                        aluControl = 3'b100;
                    6'h27: //nor
                    begin
                        aluControl = 3'b110;
                        switch = 1;
                    end
                    6'h2A: //slt
                        aluControl = 3'b010;
                    6'h2B: //sltu
                        aluControl = 3'b011;
                    default:
                        aluControl = 3'bxxx;
                endcase
            end
            6'h8, 6'h9, 6'hA, 6'hC, 6'hD, 6'hE: //I-Type (ALU)
            begin
                regWrite  = 1;
                regDestination = 1;
                aluSource = 1;
                case (opcode)
                    6'h8, 6'h9:
                        aluControl = 3'b000;
                    6'hA:
                        aluControl = 3'b010;
                    6'hC:
                        aluControl = 3'b111;
                    6'hD:
                        aluControl = 3'b110;
                    6'hE:
                        aluControl = 3'b100;
                    default:
                        aluControl = 3'bxxx;
                endcase
            end
            6'h4, 6'h5: //I-Type (Branch)
            begin
                aluControl = 3'b111;
                aluSource = 1;
                branch = 1;
                switch = (opcode == 6'h5)? 1: 0;
            end
            //MARK: TO-DO: Finish Load/Store
            6'h20, 6'h21, 6'h22, 6'h23, 6'h24, 6'h25:
            begin //I-Type (Load)
                aluSource = 1;
                regDestination = 1;
                memToReg = 1;
                regWrite = 1;
            end
            6'h28, 6'h29, 6'h2B: //I-Type (Store)
            begin
                // $display("RegWrite: %d", regWrite);
                aluSource = 1;
                memWrite = 1;
                regDestination = 1;
                controlBus = 4'b1111;
            end
            6'h2: //Jump
            begin
                jump = 1;
            end
        endcase
    end



endmodule
