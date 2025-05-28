module branch_predictor
(
    clk_i, 
    rst_i,

    update_i, // is the last instruction a branch?
	result_i, // result of the last branch instruction (taken or not taken)
	predict_o
);
input       clk_i;
input       rst_i;
input       update_i;
input       result_i;
output      predict_o;

localparam  STRONGLY_TAKEN    = 0; // 00
localparam  WEAKLY_TAKEN      = 1; // 01
localparam  WEAKLY_NONTAKEN   = 2; // 10
localparam  STRONGLY_NONTAKEN = 3; // 11

reg  [1:0]  state_current;
wire [1:0]  state_next; // next state

reg last_instr_beq;

assign predict_o = (state_current == STRONGLY_TAKEN) || (state_current == WEAKLY_TAKEN);

function  [2:0] next_state;
    input       last_is_beq;
    input [1:0] this_state;
    input       result;
    begin
        if (last_instr_beq) begin
            case (this_state) 
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

assign state_next = next_state(last_instr_beq, state_current, result_i);

always @(posedge clk_i or negedge rst_i) begin
    if (~rst_i) begin // reset state
        state_current <= STRONGLY_TAKEN;
        last_instr_beq <= 0;
    end
    else begin
        state_current <= state_next;
        last_instr_beq <= update_i;
    end
end

endmodule