module ID_EX
(
    clk_i,

    flush,
    pc_i,
    target_PC_i,
    Branch_i,
    last_flush_i,

    ALUOp_i,
    ALUSrc_i,
    RegWrite_i,
    MemtoReg_i,
    MemRead_i,
    MemWrite_i,

    RS1data_i, 
    RS2data_i,
    RS1addr_i,
    RS2addr_i,
    funct_i,
    imm32_i,
    RDaddr_i,

    pc_o,
    target_PC_o,
    Branch_o,
    last_flush_o,

    ALUOp_o,
    ALUSrc_o,
    RegWrite_o,
    MemtoReg_o,
    MemRead_o,
    MemWrite_o,

    RS1addr_o,
    RS2addr_o,
    RS1data_o, 
    RS2data_o,
    funct_o,
    imm32_o,
    RDaddr_o
);

// Ports
input               Branch_i;
input               last_flush_i;
input               flush;
input   [31:0]      target_PC_i;
input   [31:0]      pc_i;

input               clk_i;
input   [1:0]       ALUOp_i;
input               ALUSrc_i;
input               RegWrite_i;
input               MemtoReg_i;
input               MemRead_i;
input               MemWrite_i;

input   [4:0]       RS1addr_i;
input   [4:0]       RS2addr_i;
input   [31:0]      RS1data_i; 
input   [31:0]      RS2data_i;
input   [9:0]       funct_i;
input   [31:0]      imm32_i;
input   [4:0]       RDaddr_i;

output              Branch_o;
output              last_flush_o;
output  [31:0]      target_PC_o;
output  [31:0]      pc_o;

output  [1:0]       ALUOp_o;
output              ALUSrc_o;
output              RegWrite_o;
output              MemtoReg_o;
output              MemRead_o;
output              MemWrite_o;

output  [4:0]       RS1addr_o;
output  [4:0]       RS2addr_o;
output  [31:0]      RS1data_o; 
output  [31:0]      RS2data_o;
output  [9:0]       funct_o;
output  [31:0]      imm32_o;
output  [4:0]       RDaddr_o;

reg     [1:0]       ALUOp_o;
reg                 ALUSrc_o;
reg                 RegWrite_o;
reg                 MemtoReg_o;
reg                 MemRead_o;
reg                 MemWrite_o;
reg     [4:0]       RS1addr_o;
reg     [4:0]       RS2addr_o;
reg     [31:0]      RS1data_o; 
reg     [31:0]      RS2data_o;
reg     [9:0]       funct_o;
reg     [31:0]      imm32_o;
reg     [4:0]       RDaddr_o;

always@(posedge clk_i) begin
    if (flush) begin
        ALUOp_o <= 0;
        ALUSrc_o <= 0;
        RegWrite_o <= 0;
        MemtoReg_o <= 0;
        MemRead_o <= 0;
        MemWrite_o <= 0;
        RS1addr_o <= 0;
        RS2addr_o <= 0;
        RS1data_o <= 0;
        RS2data_o <= 0;
        funct_o <= 0;
        imm32_o <= 0;
        RDaddr_o <= 0;
        pc_o <= 0;
        target_PC_o <= 0;
        Branch_o <= 0;
        last_flush_o <= 0;
    end
    else begin
        ALUOp_o <= ALUOp_i;
        ALUSrc_o <= ALUSrc_i;
        RegWrite_o <= RegWrite_i;
        MemtoReg_o <= MemtoReg_i;
        MemRead_o <= MemRead_i;
        MemWrite_o <= MemWrite_i;
        RS1addr_o <= RS1addr_i;
        RS2addr_o <= RS2addr_i;
        RS1data_o <= RS1data_i;
        RS2data_o <= RS2data_i;
        funct_o <= funct_i;
        imm32_o <= imm32_i;
        RDaddr_o <= RDaddr_i;
        pc_o <= pc_i;
        target_PC_o <= target_PC_i;
        Branch_o <= Branch_i;
        last_flush_o <= last_flush_i;
    end
end

endmodule
