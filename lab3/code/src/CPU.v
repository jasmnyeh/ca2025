module CPU
(
    clk_i, 
    rst_i,
);

// Ports
input clk_i;
input rst_i;

// PC and Instruction Memory
wire [31:0] pc_i;
wire [31:0] pc_o;
wire [31:0] adder_pc_o;
wire [31:0] instr_o;

// Control
wire [6:0]  opcode_i;
wire [1:0]  ALUOp_o;
wire        RegWrite_o;
wire        MemtoReg_o;
wire        MemRead_o;
wire        MemWrite_o;
wire        ALUSrc_o;
wire        Branch_o;

// Registers
wire [4:0]  RS1addr_i;
wire [4:0]  RS2addr_i;
wire [4:0]  RDaddr_i;
wire [31:0] RS1data_o;
wire [31:0] RS2data_o;
wire [31:0] RDdata_i;

// ALU Control
wire [2:0]  funct3_i;
wire [6:0]  funct7_i;
wire [9:0]  funct_i;
wire [11:0] imm12_i;
wire [31:0] imm32_o;
wire [2:0] ALUCtrl_o;

// ALU
wire [31:0] ALUdata_i;
wire [31:0] ALUdata_o;

// Data Memory
wire [31:0] Memdata_o;

// IF_ID
wire [31:0] p0_pc_o; // for branching addr calculation
wire [31:0] p0_instr_o;

// ID_EX
wire [1:0]  p1_ALUOp_o;
wire        p1_ALUSrc_o;
wire        p1_RegWrite_o;
wire        p1_MemtoReg_o;
wire        p1_MemRead_o;
wire        p1_MemWrite_o;

wire [4:0]  p1_RS1addr_o;
wire [4:0]  p1_RS2addr_o;
wire [31:0] p1_RS1data_o;
wire [31:0] p1_RS2data_o;
wire [9:0]  p1_funct_o;
wire [31:0] p1_imm32_o;
wire [4:0]  p1_RDaddr_o;

// EX_MEM
wire        p2_RegWrite_o;
wire        p2_MemtoReg_o;
wire        p2_MemRead_o;
wire        p2_MemWrite_o;
wire [31:0] p2_RS2data_o;
wire [4:0]  p2_RDaddr_o;
wire [31:0] p2_ALUres_o;

// MEM_WB
wire        p3_RegWrite_o;
wire        p3_MemtoReg_o;
wire [31:0] p3_ALUres_o;
wire [31:0] p3_Memdata_o;
wire [4:0]  p3_RDaddr_o;

// Forwarding Unit
wire [1:0]  ForwardA_o;
wire [1:0]  ForwardB_o;
wire [31:0] ForwardAdata_o;
wire [31:0] ForwardBdata_o;

// Hazard Detection Unit
wire        noop_o;
wire        Stall_o;
wire        PCWrite_o;

// Branch predictor
wire [31:0] jump_addr_o; // CHANGE
wire [31:0] IF_pc_mux_i; // ok

wire        predictor;
wire        EX_Branching;
wire        EX_last_flush;
wire        EX_BEQ_flush; // indicate flush from beq
wire [31:0] EX_TargetPC;
wire [31:0] PC_ID_BranchingTarget;
wire [31:0] EX_pc;

assign EX_BEQ_flush = (!EX_last_flush && EX_Branching && (EX_ALU_toRegEXMEM == 0)) || (EX_last_flush && EX_Branching && (EX_ALU_toRegEXMEM != 0));
    //EX_Branching indicates last is branching instr. EX last didn't flush, but actually branch is taken.
    // or another case: taken branch, branch resolve result is nontaken
// end

// Assigning instruction fields
assign opcode_i   = p0_instr_o[6:0];    
assign RDaddr_i   = p0_instr_o[11:7];   
assign funct3_i   = p0_instr_o[14:12];  
assign RS1addr_i  = p0_instr_o[19:15]; 
assign RS2addr_i  = p0_instr_o[24:20]; 
assign funct7_i   = p0_instr_o[31:25]; 
assign funct_i    = {funct7_i, funct3_i};

assign imm12_i = (opcode_i == 7'b0100011) ? {p0_instr_o[31:25], p0_instr_o[11:7]} : // sw (S-type)
                 (opcode_i == 7'b1100011) ? {p0_instr_o[31], p0_instr_o[7], p0_instr_o[30:25], p0_instr_o[11:8]} :  // beq (B-type)
                 p0_instr_o[31:20]; // Default: I-type (e.g. lw, addi)

initial begin
    // Hazard Detection Unit
    CPU.Hazard_Detection.Stall_o   = 1'b0;
    CPU.Hazard_Detection.NoOp_o    = 1'b0;
    CPU.Hazard_Detection.PCWrite_o = 1'b1;

    // IF/ID
    CPU.IF_ID.pc_o     = 32'b0;
    CPU.IF_ID.instr_o  = 32'b0;

    // ID/EX
    CPU.ID_EX.ALUOp_o     = 2'b00;
    CPU.ID_EX.ALUSrc_o    = 1'b0;
    CPU.ID_EX.RegWrite_o  = 1'b0;
    CPU.ID_EX.MemtoReg_o  = 1'b0;
    CPU.ID_EX.MemRead_o   = 1'b0;
    CPU.ID_EX.MemWrite_o  = 1'b0;
    CPU.ID_EX.RS1addr_o   = 5'b0;
    CPU.ID_EX.RS2addr_o   = 5'b0;
    CPU.ID_EX.RS1data_o   = 32'b0;
    CPU.ID_EX.RS2data_o   = 32'b0;
    CPU.ID_EX.funct_o     = 10'b0;
    CPU.ID_EX.imm32_o     = 32'b0;
    CPU.ID_EX.RDaddr_o    = 5'b0;

    // EX/MEM
    CPU.EX_MEM.ALUres_o     = 32'b0;
    CPU.EX_MEM.RegWrite_o   = 1'b0;
    CPU.EX_MEM.MemtoReg_o   = 1'b0;
    CPU.EX_MEM.MemRead_o    = 1'b0;
    CPU.EX_MEM.MemWrite_o   = 1'b0;
    CPU.EX_MEM.RS2data_o    = 32'b0;
    CPU.EX_MEM.RDaddr_o     = 5'b0;

    // MEM/WB
    CPU.MEM_WB.ALUres_o     = 32'b0;
    CPU.MEM_WB.RegWrite_o   = 1'b0;
    CPU.MEM_WB.MemtoReg_o   = 1'b0;
    CPU.MEM_WB.Memdata_o    = 32'b0;
    CPU.MEM_WB.RDaddr_o     = 5'b0;
end

Control Control(
    .opcode_i(opcode_i),
    .noop_i(noop_o),
    .ALUOp_o(ALUOp_o),
    .ALUSrc_o(ALUSrc_o),
    .RegWrite_o(RegWrite_o),
    .MemtoReg_o(MemtoReg_o),
    .MemRead_o(MemRead_o),
    .MemWrite_o(MemWrite_o),
    .Branch_o(Branch_o)
);

Adder Add_PC(
    .data1_i(pc_o),
    .data2_i(32'd4),
    .data_o(adder_pc_o)
);

PC PC(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .PCWrite_i(PCWrite_o),
    .pc_i(IF_pc_mux_i),
    .pc_o(pc_o)
);

Instruction_Memory Instruction_Memory(
    .addr_i(pc_o),
    .instr_o(instr_o)
);

Registers Registers(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .RS1addr_i(RS1addr_i),
    .RS2addr_i(RS2addr_i),
    .RDaddr_i(p3_RDaddr_o), 
    .RDdata_i(RDdata_i),
    .RegWrite_i(p3_RegWrite_o), 
    .RS1data_o(RS1data_o), 
    .RS2data_o(RS2data_o) 
);

MUX32 MUX_ALUSrc(
    .data1_i(ForwardBdata_o),
    .data2_i(p1_imm32_o),
    .select_i(p1_ALUSrc_o),
    .data_o(ALUdata_i)
);

Sign_Extend Sign_Extend(
    .data_i(imm12_i),
    .data_o(imm32_o)
);

ALU ALU(
    .data1_i(ForwardAdata_o),
    .data2_i(ALUdata_i),
    .ALUCtrl_i(ALUCtrl_o),
    .data_o(ALUdata_o)
);

ALU_Control ALU_Control(
    .funct_i(p1_funct_o),
    .ALUOp_i(p1_ALUOp_o),
    .ALUCtrl_o(ALUCtrl_o)
);

Data_Memory Data_Memory(
    .clk_i(clk_i), 
    .addr_i(p2_ALUres_o), 
    .MemRead_i(p2_MemRead_o),
    .MemWrite_i(p2_MemWrite_o),
    .data_i(p2_RS2data_o),
    .data_o(Memdata_o)
);

MUX32 MUX_WriteSrc(
    .data1_i(p3_ALUres_o),
    .data2_i(p3_Memdata_o),
    .select_i(p3_MemtoReg_o),
    .data_o(RDdata_i)
);

IF_ID IF_ID(
    .clk_i(clk_i),
    .Stall_i(Stall_o),
    .flush_i((Branch_o && predictor) || EX_BEQ_flush),
    .instr_i(instr_o),
    .pc_i(pc_o),
    .instr_o(p0_instr_o),
    .pc_o(p0_pc_o)
);

ID_EX ID_EX(
    .clk_i(clk_i),
    .flush(EX_BEQ_flush),

    .pc_i(p0_pc_o),
    .target_PC_i(p0_pc_o + ((ID_ImmGen_toRegIDEX) << 1)),
    .Branch_i(Branch_o),
    .last_flush_i(Branch_o && predictor),
    .ALUOp_i(ALUOp_o),
    .ALUSrc_i(ALUSrc_o),
    .RegWrite_i(RegWrite_o),
    .MemtoReg_i(MemtoReg_o),
    .MemRead_i(MemRead_o),
    .MemWrite_i(MemWrite_o),

    .RS1data_i(RS1data_o), 
    .RS2data_i(RS2data_o),
    .RS1addr_i(RS1addr_i),
    .RS2addr_i(RS2addr_i),
    .funct_i(funct_i),
    .imm32_i(imm32_o),
    .RDaddr_i(RDaddr_i),

    .Branch_o(EX_Branching),
    .last_flush_o(EX_last_flush),
    .pc_o(EX_pc),
    .target_PC_o(EX_TargetPC),
    .ALUOp_o(p1_ALUOp_o),
    .ALUSrc_o(p1_ALUSrc_o),
    .RegWrite_o(p1_RegWrite_o),
    .MemtoReg_o(p1_MemtoReg_o),
    .MemRead_o(p1_MemRead_o),
    .MemWrite_o(p1_MemWrite_o),

    .RS1addr_o(p1_RS1addr_o),
    .RS2addr_o(p1_RS2addr_o),
    .RS1data_o(p1_RS1data_o), 
    .RS2data_o(p1_RS2data_o),
    .funct_o(p1_funct_o),
    .imm32_o(p1_imm32_o),
    .RDaddr_o(p1_RDaddr_o)
);

EX_MEM EX_MEM(
    .clk_i(clk_i),
    .RegWrite_i(p1_RegWrite_o),
    .MemtoReg_i(p1_MemtoReg_o),
    .MemRead_i(p1_MemRead_o),
    .MemWrite_i(p1_MemWrite_o),
    .RS2data_i(ForwardBdata_o),
    .RDaddr_i(p1_RDaddr_o),
    .ALUres_i(ALUdata_o),

    .RegWrite_o(p2_RegWrite_o),
    .MemtoReg_o(p2_MemtoReg_o),
    .MemRead_o(p2_MemRead_o),
    .MemWrite_o(p2_MemWrite_o),
    .RS2data_o(p2_RS2data_o),
    .RDaddr_o(p2_RDaddr_o),
    .ALUres_o(p2_ALUres_o)
);

MEM_WB MEM_WB(
    .clk_i(clk_i),

    .RegWrite_i(p2_RegWrite_o),
    .MemtoReg_i(p2_MemtoReg_o),
    .ALUres_i(p2_ALUres_o),
    .Memdata_i(Memdata_o),
    .RDaddr_i(p2_RDaddr_o),

    .RegWrite_o(p3_RegWrite_o),
    .MemtoReg_o(p3_MemtoReg_o),
    .ALUres_o(p3_ALUres_o),
    .Memdata_o(p3_Memdata_o),
    .RDaddr_o(p3_RDaddr_o)
);

Forwarding_Unit Forwarding_Unit(
    .EX_RS1addr_i(p1_RS1addr_o),
    .EX_RS2addr_i(p1_RS2addr_o),
    .MEM_RegWrite_i(p2_RegWrite_o),
    .MEM_RDaddr_i(p2_RDaddr_o),
    .WB_RegWrite_i(p3_RegWrite_o),
    .WB_RDaddr_i(p3_RDaddr_o),
    
    .ForwardA_o(ForwardA_o),
    .ForwardB_o(ForwardB_o) 
);

MUX32FU ForwardA(
    .data1_i(p1_RS1data_o),
    .data2_i(RDdata_i),
    .data3_i(p2_ALUres_o),
    .select_i(ForwardA_o),
    .data_o(ForwardAdata_o)
);

MUX32FU ForwardB(
    .data1_i(p1_RS2data_o),
    .data2_i(RDdata_i),
    .data3_i(p2_ALUres_o),
    .select_i(ForwardB_o),
    .data_o(ForwardBdata_o)
);

Hazard_Detection Hazard_Detection(
    .RS1addr_i(RS1addr_i),
    .RS2addr_i(RS2addr_i),
    .EX_MemRead_i(p1_MemRead_o),
    .EX_RDaddr_i(p1_RDaddr_o),
    
    .NoOp_o(noop_o),
    .Stall_o(Stall_o),
    .PCWrite_o(PCWrite_o)
);

MUX32 PC_ID_Branching(
    .data1_i(adder_pc_o),
    .data2_i(p0_pc_o + ((ID_ImmGen_toRegIDEX) << 1)),
    .select_i(Branch_o && predictor),
    .data_o(PC_ID_BranchingTarget)
);

MUX32 PC_EX_Branching(
    .data1_i(PC_ID_BranchingTarget),
    .data2_i((EX_ALU_toRegEXMEM == 0) ? EX_TargetPC : EX_pc + 4),
    .select_i(EX_BEQ_flush),
    .data_o(IF_pc_mux_i)
);

branch_predictor branch_predictor
(
    .clk_i(clk_i), 
    .rst_i(rst_i),
    .update_i(Branch_o), // Update only for branch instructions
    .result_i(EX_ALU_toRegEXMEM == 0), 
    .predict_o(predictor)
);

endmodule