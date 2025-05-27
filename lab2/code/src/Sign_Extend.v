module Sign_Extend
(
    data_i,
    data_o
);

// Ports
input  [11:0] data_i;     // 12-bit immediate
output [31:0] data_o;     // 32-bit sign-extended output

// Sign extension logic
assign data_o = {{20{data_i[11]}}, data_i};

endmodule