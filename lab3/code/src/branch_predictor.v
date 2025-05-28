module Branch_Predictor
(
    clk_i,
    rst_i,
    Branch_i,
    update_i,
    result_i,
    predict_o
);

input          clk_i;
input          rst_i;
input          Branch_i;
input          update_i;
input          result_i;
output         predict_o;

reg            predict_o;
reg [1:0]      history;

always @(*) begin
    case (history)
        2'b00: predict_o = 0; // strongly not taken
        2'b01: predict_o = 0; // weakly not taken
        2'b10: predict_o = 1; // weakly taken
        2'b11: predict_o = 1; // strongly taken
    endcase
end

always @(posedge clk_i or negedge rst_i) begin
    if (~rst_i) begin
        history <= 2'b11; // start with strongly taken
    end
    else if (Branch_i) begin // if a branch instruction is executed
        if (update_i == result_i) begin // if the prediction was correct
            case (history)
                2'b00: history = 2'b00;
                2'b01: history = 2'b00;
                2'b10: history = 2'b11;
                2'b11: history = 2'b11;
            endcase
        end
        else begin
            case (history)
                2'b00: history = 2'b01;
                2'b01: history = 2'b10;
                2'b10: history = 2'b01;
                2'b11: history = 2'b10;
            endcase
        end
    end
end

endmodule