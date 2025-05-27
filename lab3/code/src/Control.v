module Control
(
    opcode_i,
    noop_i,

    ALUOp_o,
    ALUSrc_o,
    RegWrite_o,
    MemtoReg_o,
    MemRead_o,
    MemWrite_o,
    Branch_o
);

// Ports
input  [6:0] opcode_i;
input        noop_i;

output [1:0] ALUOp_o;
output       ALUSrc_o;
output       RegWrite_o;
output       MemtoReg_o;
output       MemRead_o;
output       MemWrite_o;
output       Branch_o;

// reg [1:0] ALUOp_o;
// reg       ALUSrc_o;
// reg       RegWrite_o;
// reg       MemtoReg_o;
// reg       MemRead_o;
// reg       MemWrite_o;
// reg       Branch_o;

// updates happen whenever any input in the sensitivity list changes
assign ALUOp_o    = (noop_i)                ? 2'b00 :
                    (opcode_i == 7'b0110011) ? 2'b10 : // R-type
                    (opcode_i == 7'b1100011) ? 2'b01 : // beq
                                               2'b00;  // others

assign ALUSrc_o   = (noop_i)                ? 1'b0  :
                    (opcode_i == 7'b0110011) ? 1'b0  : // R-type
                                               (opcode_i != 7'b1100011); // all but beq

assign RegWrite_o = (noop_i)                ? 1'b0  :
                    (opcode_i == 7'b0110011) ? 1'b1  : // R-type
                    (opcode_i == 7'b0010011) ? 1'b1  : // I-type
                    (opcode_i == 7'b0000011) ? 1'b1  : // lw
                                               1'b0;

assign MemtoReg_o = (noop_i)                ? 1'b0  :
                    (opcode_i == 7'b0000011) ? 1'b1  : // lw
                                               1'b0;

assign MemRead_o  = (noop_i)                ? 1'b0  :
                    (opcode_i == 7'b0000011) ? 1'b1  : // lw
                                               1'b0;

assign MemWrite_o = (noop_i)                ? 1'b0  :
                    (opcode_i == 7'b0100011) ? 1'b1  : // sw
                                               1'b0;

assign Branch_o   = (noop_i)                ? 1'b0  :
                    (opcode_i == 7'b1100011) ? 1'b1  : // beq
                                               1'b0;

endmodule