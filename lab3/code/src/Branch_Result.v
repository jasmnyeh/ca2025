module Branch_Result
(
    zero_i,
    branch_i,
    result_o
);

input   zero_i;
input   branch_i;
output  result_o;

assign result_o = zero_i && branch_i;

endmodule