module branch_predictor
(
    clk_i, 
    rst_i,

    update_i, // is current instruction current branch?
	result_i, // is the branch taken?
	predict_o
);
input clk_i, rst_i, update_i, result_i;
output predict_o;

localparam STRONGLY_TAKEN = 0;
localparam WEAKLY_TAKEN = 1;
localparam WEAKLY_NONTAKEN = 2;
localparam STRONGLY_NONTAKEN = 3;

reg [1:0] state_r;
wire [1:0] state_w; // next state

reg last_instr_beq;

assign predict_o = (state_r == STRONGLY_TAKEN) || (state_r == WEAKLY_TAKEN);

function [2:0] next_state;
    input last_is_beq;
    input [1:0] this_state;
    input result;
    begin
        if(last_instr_beq) begin
            case(this_state) 
            STRONGLY_TAKEN: begin
                next_state = result? STRONGLY_TAKEN: WEAKLY_TAKEN;
            end
            WEAKLY_TAKEN: begin
                next_state = result? STRONGLY_TAKEN: WEAKLY_NONTAKEN;
            end
            WEAKLY_NONTAKEN: begin
                next_state = result? WEAKLY_TAKEN: STRONGLY_NONTAKEN;
            end
            STRONGLY_NONTAKEN: begin
                next_state = result? WEAKLY_NONTAKEN: STRONGLY_NONTAKEN; 
            end
            endcase
        end
        else begin
            next_state = this_state;
        end
    end
endfunction

assign state_w = next_state(last_instr_beq, state_r, result_i);

always @(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
        state_r <= STRONGLY_TAKEN;
        last_instr_beq <= 0;
    end
    else begin
        state_r <= state_w;
        last_instr_beq <= update_i;
    end
end

endmodule