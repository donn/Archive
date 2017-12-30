//Pipelined CPU (mix of combinational and behavioral)
//Some modules missing, here for reference.
`include "hazard.v"

module computer;

    reg clk;
    reg rst;
    always #5 clk = !clk;
    initial
    begin
        $dumpfile("computer.vcd");
        $dumpvars(0, computer);
        #50
        clk = 0;
        rst = 1;
        #100
        rst = 0;
        #1000
        $finish;
    end

    //Fetch
    wire stall_F;
    wire [31:0] Instruction_F;
    wire [31:0] PCNext_F;
    wire [31:0] PCPlus4_F;
    reg [31:0] ProgramCounter_F;

    assign PCPlus4_F = ProgramCounter_F + 4;
    assign PCNext_F = 0? PCBranch_M: PCPlus4_F;

    rom #(30, 32, 18) uutc(.adr(ProgramCounter_F[31:2]), .dout(Instruction_F));

    //Fetch->Decode
    wire stall_D;
    reg [31:0] Instr_D;
    reg [31:0] PCPlus4_D;

    always @ (posedge clk)
    begin
        if (rst)
            ProgramCounter_F = -4;
        else
        begin
            if (!stall_F)
            begin
                ProgramCounter_F <= PCNext_F;
            end
            if (!stall_D)
            begin
                Instr_D <= Instruction_F;
                PCPlus4_D <=  PCPlus4_F;
            end
        end
    end

    //Decode
    wire [31:0] RegRdData1_D;
    wire [31:0] RegRdData2_D;
    wire [31:0] SignImm_D;
    wire [4:0] DstAddrIType_D;
    wire [4:0] DstAddrRType_D;
    
    //Instruction Signals
    //R-type fields
    wire [5:0] RType_funct;
    wire [4:0] RType_rs;
    wire [4:0] RType_rt;
    wire [4:0] RType_rd;
    wire [4:0] RType_shamt;
    //I-type fields
    wire [4:0] IType_rs;
    wire [4:0] IType_rt;
    wire [15:0] IType_imm;
    //J-type fields
    wire [31:0] JType_addr;
    //Register File
    reg [31:0] rf[31:0];
    reg [2:0] aluControl;
    reg [3:0] controlBus;
    reg regWrite, regDestination, aluSource, switch, branch, memWrite, memToReg, jump;

    wire [5:0] opcode, funct;
    assign opcode = Instr_D[31:26];
    assign funct = Instr_D[5:0];

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


    always @(negedge clk)
    begin
        if (rst)
        begin
            rf[0] <= 32'b0;
            rf[1] <= 32'b0;
            rf[2] <= 32'b0;
            rf[3] <= 32'b0;
            rf[4] <= 32'b0;
            rf[5] <= 32'b0;
            rf[6] <= 32'b0;
            rf[7] <= 32'b0;
            rf[8] <= 32'b0;
            rf[9] <= 32'b0;
            rf[10] <= 32'b0;
            rf[11] <= 32'b0;
            rf[12] <= 32'b0;
            rf[13] <= 32'b0;
            rf[14] <= 32'b0;
            rf[15] <= 32'b0;
            rf[16] <= 32'b0;
            rf[17] <= 32'b0;
            rf[18] <= 32'b0;
            rf[19] <= 32'b0;
            rf[20] <= 32'b0;
            rf[21] <= 32'b0;
            rf[22] <= 32'b0;
            rf[23] <= 32'b0;
            rf[24] <= 32'b0;
            rf[25] <= 32'b0;
            rf[26] <= 32'b0;
            rf[27] <= 32'b0;
            rf[28] <= 32'b0;
            rf[29] <= 32'd4096;
            rf[30] <= 32'b0;
            rf[31] <= 32'b0;
        end
    else
        begin
        if (RegWrite_W)
            begin
                rf[WriteReg_W] <= Result_W;
                rf[0] <= 32'b0;
            end
        end
    end

    assign opcode = Instr_D[31:26];
    assign RType_funct = Instr_D[5:0];
    assign RType_rs = Instr_D[25:21];
    assign RType_rt = Instr_D[20:16];
    assign RType_rd = Instr_D[15:11];
    assign RType_shamt = Instr_D[10:6];
    assign IType_rs = Instr_D[25:21];
    assign IType_rt = Instr_D[20:16];
    assign IType_imm = Instr_D[15:0];
    assign JType_addr = {PCPlus4_D[31:28], Instr_D[25:0], 2'b00};

    //Miscellaneous
    assign RegRdData1_D = rf[RType_rs];
    assign RegRdData2_D = rf[RType_rt];
    assign SignImm_D = {{16{IType_imm[15]}}, IType_imm};
    assign DstAddrIType_D = IType_rt;
    assign DstAddrRType_D = RType_rd;

    //Decode->Execute
    wire flush_E;
    reg RegWrite_E;
    reg MemToReg_E;
    reg MemWrite_E;
    reg Branch_E;
    reg Jump_E;
    reg [3:0] ALUControl_E;
    reg ALUSrc_E;
    reg RegDest_E;

    reg [31:0] RsData_E;
    reg [31:0] RtData_E;

    reg [4:0] Rs_E;
    reg [4:0] Rt_E;
    reg [4:0] Rd_E;
    reg [4:0] Shamt_E;

    reg [31:0] SignImm_E;
    reg [31:0] PCPlus4_E;

    always @(posedge clk)
    begin
        if (flush_E)
        begin
            RegWrite_E <= 0;
            MemToReg_E <= 0;
            MemWrite_E <= 0;
            Branch_E <= 0;
            ALUControl_E <= 0;
            ALUSrc_E <= 0;
            RegDest_E <= 0;
            Jump_E <= 0;
            Shamt_E <= 0;

            RsData_E <= 0;
            RtData_E <= 0;
            SignImm_E <= 0;

            Rs_E <= 0;
            Rt_E <= 0;
            Rd_E <= 0;
        end
        else
        begin
            RegWrite_E <= regWrite;
            MemToReg_E <= memToReg;
            MemWrite_E <= memWrite;
            Branch_E <= branch;
            ALUControl_E <= aluControl;
            ALUSrc_E <= aluSource;
            RegDest_E <= regDestination;
            Jump_E <= jump;
            Shamt_E <= RType_shamt;

            RsData_E <= RegRdData1_D;
            RtData_E <= RegRdData2_D;
            SignImm_E <= SignImm_D;

            Rs_E <= RType_rs;
            Rt_E <= RType_rt;
            Rd_E <= RType_rd;
        end
    end

    //Execute
    wire [1:0] forwarda_E;
    wire [1:0] forwardb_E;
    wire Zero_E;
    wire [31:0] ALUOut_E;
    wire [31:0] PCBranch_E;
    wire [31:0] Current_E;
    wire [31:0] SrcA_E;
    wire [31:0] SrcB_E;
    wire [4:0] WriteReg_E;    
    wire [31:0] WriteData_E;


    assign SrcA_E = forwarda_E[1]? ALUOut_M: (forwarda_E[0]? Result_W: RsData_E);
    assign WriteData_E = forwardb_E[1]? ALUOut_M: (forwardb_E[0]? Result_W: RtData_E);
    assign SrcB_E = ALUSrc_E? SignImm_E: WriteData_E;
    assign PCBranch_E = {SignImm_E[29:0], 2'b00} + PCPlus4_E;
    assign WriteReg_E = RegDest_E? Rt_E: Rd_E;

    alu32 uut(.a(SrcA_E), .b(SrcB_E), .f(ALUControl_E), .shamt(Shamt_E), .y(ALUOut_E), .zero(Zero_E));

    //Execute->Memory
    reg RegWrite_M;
    reg MemToReg_M;
    reg MemWrite_M;
    reg Zero_M;
    reg [31:0] ALUOut_M;
    reg [31:0] WriteData_M;
    reg [4:0] WriteReg_M;
    reg [31:0] PCBranch_M;

    always @ (posedge clk)
    begin
        RegWrite_M <= RegWrite_E;
        MemToReg_M <= MemToReg_E;
        MemWrite_M <= MemWrite_E;
        Zero_M <= Zero_E;
        ALUOut_M <= ALUOut_E;
        WriteData_M <= WriteData_E;
        WriteReg_M <= WriteReg_E;
        PCBranch_M <= PCBranch_E; 
    end

    //Memory
    wire [31:0] ReadData_M;

    rammanager datamemory(.clk(clk), .writeEnables({4{MemWrite_M}}), .memin(WriteData_M), .memaddr(ALUOut_M), .memout(ReadData_M));

    //Memory->WriteBack
    reg RegWrite_W;
    reg MemToReg_W;
    reg [31:0] ALUOut_W;
    reg [31:0] ReadData_W;
    reg [4:0] WriteReg_W;

    always @ (posedge clk)
    begin
        RegWrite_W <= RegWrite_M;
        MemToReg_W <= MemToReg_M;
        ALUOut_W <= ALUOut_M;
        ReadData_W <= ReadData_M;
        WriteReg_W <= WriteReg_M;
    end

    //WriteBack
    wire [31:0] Result_W;

    assign Result_W = MemToReg_W? ReadData_W: ALUOut_W;

    //Hazard Unit
    hazard hu
    (
        .rsD(RType_rs), .rtD(RType_rt), .rsE(Rs_E), .rtE(Rt_E),
        .writeregE(WriteReg_E), .writeregM(WriteReg_M), .writeregW(WriteReg_W),
        .regwriteE(RegWrite_E), .regwriteM(RegWrite_M), .regwriteW(RegWrite_W),
        .memtoregE(MemToReg_E), .memtoregM(MemToReg_M), .branchD(branch),
        .forwardaE(forwarda_E), .forwardbE(forwardb_E),
        .stallF(stall_F), .stallD(stall_D), .flushE(flush_E)
    );


endmodule