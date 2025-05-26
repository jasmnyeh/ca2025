module CPU
(
    clk_i, 
    rst_i,
);

// Ports
input               clk_i;
input               rst_i;

// Wires
wire [31:0] pc_current;
wire [31:0] pc_next;
wire [31:0] instruction;
wire [6:0] opcode;
wire [2:0] funct3;
wire [6:0] funct7;
wire [4:0] rs1, rs2, rd;
wire [31:0] rs1_data, rs2_data;
wire [31:0] sign_extended;
wire [31:0] alu_src2;
wire [31:0] alu_result;
wire [2:0] alu_control;
wire [1:0] alu_op;
wire [11:0] imm;
wire alu_src;
wire reg_write;

// Instruction Fields
assign opcode = instruction[6:0];
assign rd = instruction[11:7];
assign funct3 = instruction[14:12];
assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign funct7 = instruction[31:25];
assign imm = instruction[31:20];

Control Control(
    .opcode_i(opcode),
    .ALUOp_o(alu_op),
    .ALUSrc_o(alu_src),
    .RegWrite_o(reg_write)
);

Adder Add_PC(
    .data1_i(pc_current),
    .data2_i(32'd4),
    .data_o(pc_next)
);

PC PC(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .pc_i(pc_next),
    .pc_o(pc_current)
);

Instruction_Memory Instruction_Memory(
    .addr_i(pc_current),
    .instr_o(instruction)
);

Registers Registers(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .RS1addr_i(rs1),
    .RS2addr_i(rs2),
    .RDaddr_i(rd),
    .RDdata_i(alu_result),
    .RegWrite_i(reg_write),
    .RS1data_o(rs1_data),
    .RS2data_o(rs2_data)
);

MUX32 MUX_ALUSrc(
    .data1_i(rs2_data),
    .data2_i(sign_extended),
    .select_i(alu_src),
    .data_o(alu_src2)
);

Sign_Extend Sign_Extend(
    .data_i(imm),
    .data_o(sign_extended)
);
  
ALU ALU(
    .data1_i(rs1_data),
    .data2_i(alu_src2),
    .ALUCtrl_i(alu_control),
    .data_o(alu_result)
);

ALU_Control ALU_Control(
    .funct_i({funct7, funct3}),
    .ALUOp_i(alu_op),
    .ALUCtrl_o(alu_control)
);

endmodule

