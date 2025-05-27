module Branch_Unit
(
    Branch_i,
    predict_i,
    ID_pc_i,
    imm32_i,
    
    Flush_o,
    jump_addr_o
);

// Ports
input         predict_i;
input [31:0]  RS1data_i;
input [31:0]  RS2data_i;
input         Branch_i;
input [31:0]  ID_pc_i;
input [31:0]  imm32_i;

output        Flush_o;
output [31:0] jump_addr_o;

reg Flush_o;

assign jump_addr_o = ID_pc_i + (imm32_i << 1); 

always @(Branch_i or predict_i) begin
    Flush_o = 1'b0;
    if (Branch_i && predict_i) begin
        Flush_o = 1'b1;
    end
end

endmodule
