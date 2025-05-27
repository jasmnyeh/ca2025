module Control
(
    opcode_i,
    ALUOp_o,
    ALUSrc_o,
    RegWrite_o
);

// Ports
input  [6:0] opcode_i;
output       ALUSrc_o;
output       RegWrite_o;
output [1:0] ALUOp_o;

reg ALUSrc_o;
reg RegWrite_o;
reg [1:0] ALUOp_o;

always @(*) begin  
    case (opcode_i)
        7'b0110011: begin // R-type
            ALUSrc_o   = 0;
            RegWrite_o = 1;
            ALUOp_o    = 2'b10;
        end

        7'b0010011: begin // I-type
            ALUSrc_o   = 1;
            RegWrite_o = 1;
            ALUOp_o    = 2'b00;
        end

        default: begin
            ALUSrc_o   = 0;
            RegWrite_o = 1;
            ALUOp_o    = 2'b10;
        end
    endcase
end

endmodule