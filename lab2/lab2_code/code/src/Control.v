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

reg [1:0] ALUOp_o;
reg       ALUSrc_o;
reg       RegWrite_o;
reg       MemtoReg_o;
reg       MemRead_o;
reg       MemWrite_o;
reg       Branch_o;

// updates happen whenever any input in the sensitivity list changes
always @(*) begin  
    // Default values (safe for NoOp and undefined opcodes)
    ALUOp_o     = 2'b00;
    ALUSrc_o    = 0;
    RegWrite_o  = 0;
    MemtoReg_o  = 0;
    MemRead_o   = 0;
    MemWrite_o  = 0;
    Branch_o    = 0;

    if (!noop_i) begin
        case (opcode_i)
            7'b0110011: begin // R-type
                ALUOp_o    = 2'b10;
                ALUSrc_o   = 0;
                RegWrite_o = 1;
            end

            7'b0010011: begin // I-type
                ALUOp_o    = 2'b00;
                ALUSrc_o   = 1;
                RegWrite_o = 1;
            end

            7'b0000011: begin // lw
                ALUOp_o     = 2'b00;
                ALUSrc_o    = 1;
                RegWrite_o  = 1;
                MemtoReg_o  = 1;
                MemRead_o   = 1;
            end

            7'b0100011: begin // sw
                ALUOp_o     = 2'b00;
                ALUSrc_o    = 1;
                MemWrite_o  = 1;
            end

            7'b1100011: begin // beq
                ALUOp_o     = 2'b01;
                Branch_o    = 1;
            end
        endcase
    end
end

endmodule