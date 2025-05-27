module ALU_Control
(
    funct_i,
    ALUOp_i,
    ALUCtrl_o
);

// Ports
input  [9:0] funct_i;      // [9:3] = funct7, [2:0] = funct3
input  [1:0] ALUOp_i;     
output [2:0] ALUCtrl_o;

reg [2:0] ALUCtrl_o;
wire [6:0] funct7 = funct_i[9:3];
wire [2:0] funct3 = funct_i[2:0];

always @(*) begin
    ALUCtrl_o = 3'b000; // default value to prevent latch
    case (ALUOp_i)
        2'b10: begin // R-type
            case (funct3)
                3'b111: ALUCtrl_o = 3'b000; // and
                3'b100: ALUCtrl_o = 3'b001; // xor
                3'b001: ALUCtrl_o = 3'b010; // sll
                3'b000: begin
                    case (funct7)
                        7'b0000000: ALUCtrl_o = 3'b011; // add
                        7'b0100000: ALUCtrl_o = 3'b100; // sub
                        7'b0000001: ALUCtrl_o = 3'b101; // mul
                    endcase
                end
            endcase
        end

        2'b00: begin // I-type
            case (funct3)
                3'b000: ALUCtrl_o = 3'b011; // addi
                3'b101: ALUCtrl_o = 3'b111; // srai
                3'b010: ALUCtrl_o = 3'b011; // lw & sw -> add
            endcase
        end

        2'b01: begin
            ALUCtrl_o = 3'b100; // beq -> sub
        end
    endcase
end

endmodule

