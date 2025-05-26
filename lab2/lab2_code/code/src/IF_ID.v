module IF_ID
(
    clk_i,

    Stall_i,
    Flush_i,
    instr_i,
    pc_i,

    instr_o,
    pc_o
);

// Ports
input        clk_i;
input        Stall_i;
input        Flush_i;
input [31:0] pc_i;
input [31:0] instr_i;

output reg [31:0] pc_o;
output reg [31:0] instr_o;

always @(posedge clk_i) begin
    if (Flush_i) begin
        pc_o    <= 32'b0;
        instr_o <= 32'b0;
    end
    else if (!Stall_i) begin
        pc_o    <= pc_i;
        instr_o <= instr_i;
    end
    // If Stall_i is 1, hold current values (do nothing)
end

endmodule