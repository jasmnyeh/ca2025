# Implementation of each modules

Compared to lab2, I replaced the `Branch_Unit` module with a new `branch_predictor` module and added two new 2-to-1 multiplexers to support branch prediction and recovery. I also added new variables inside ID_EX pipeline to store information that is needed for branch prediction. Aside from these changes, most parts of the implementation remain the same as in lab2.

## Adder.v
The Adder module performs a 32-bit addition. It takes two 32-bit inputs and outputs their sum. This module is used to compute PC + 4 for sequential instruction execution.

## ALU_Control.v
The ALU_Control module takes a 10-bit funct field (from funct7 and funct3) and a 2-bit ALUOp as input, then determines the ALUOp number first to see if it is an I-type, R-type, or branch instruction. Then, it determines funct to see which function it matches to, and passes the 3-bit result to the ALU. Then it outputs a 3-bit ALUCtrl_o to memorize which kind of ALU operation it is going to perform later in the ALU.

## ALU.v
The ALU module takes two 32-bit operands and a 3-bit control signal as input. The ALU performs the operation specified by the 3-bit control signal and outputs the result.

## Control.v
The Control module takes opcode_i and noop_i as the inputs, then determines if it’s an I-type, R-type, lw, sw, or beq instruction base on the opcode, and sets the seven outputs – ALUOp_o, ALUSrc_o, RegWrite_o, MemtoReg_o, MemRead_o, MemWrite_o, Branch_o accordingly.

## EX_MEM.v
EX_MEM’s inputs include: clk_i, RegWrite_i, MemtoReg_i, MemRead_i, MemWrite_i, RS2data_i, RDaddr_i, and ALUres_i. Its outputs include: RegWrite_o, MemtoReg_o, MemRead_o, MemWrite_o, RS2data_o, RDaddr_o, and ALUres_o. At every positive clock edge, the module updates its output registers to match the corresponding input values.

## Forwarding_Unit.v
Forwarding_Unit takes six inputs - EX_RS1addr_i, EX_RS2addr_i, MEM_RegWrite_i, MEM_RDaddr_i, WB_RegWrite_i, WB_RDaddr_i, and produces two outputs - ForwardA_o and ForwardB_o. Both outputs are initialized to 00. The module first checks for an EX hazard—if the condition is met, the corresponding output is set to 10. If not, it then checks for a MEM hazard; if that's true, the output is set to 01.

## Hazard_Detection.v
The Hazard_Detection module takes four inputs: RS1addr_i, RS2addr_i, EX_MemRead_i, and EX_RDaddr_i, and produces three outputs: NoOp_o, Stall_o, and PCWrite_o.
By default, NoOp_o = 0, Stall_o = 0, and PCWrite_o = 1, meaning the pipeline is executing normally without any stalls. The module then checks for hazards caused by load instructions using the condition described in the slides. If a hazard is detected, the outputs are set to: NoOp_o = 1, Stall_o = 1, and PCWrite_o = 0.

## ID_EX.v
ID_EX has tons of inputs and outputs. Inputs include: clk_i, Branch_i, last_flush_i, flush, target_PC_i, pc_i, ALUOp_i, ALUSrc_i, RegWrite_i, MemtoReg_i, MemRead_i, MemWrite_i, RS1data_i, RS2data_i, RS1addr_i, RS2addr_i, funct_i, imm32_i, and RDaddr_i. Each input except clk_i has a corresponding output with the same name but ending in _o. At every positive clock edge, the module updates its output registers to match the corresponding input values.

## IF_ID.v
IF_ID takes five inputs – clk_i, Stall_i, Flush_i, instr_i, pc_i and produces two outpus – instr_o, pc_o. On every rising edge of clk_i, if Flush_i bit is 1, then both pc_o and instr_o are set to 0. Otherwise, if Stall_i is 0 (not gonna stall), pc_i is passed to pc_o and instr_i is passed to instr_o.

## MEM_WB.v
MEM_WB takes six inputs - clk_i, RegWrite_i, MemtoReg_i, ALUres_i, Memdata_i, RDaddr_i and produces five outputs - RegWrite_o, MemtoReg_o, ALUres_o, Memdata_o, RDaddr_o. The module update its output registers to match the corresponding input values at every postitive clock edge.

## MUX32.v
The MUX32 module is a 2-to-1 multiplexer. It takes two 32-bit inputs and a single-bit selector. If the selector is 1, the output is the second input; if 0, the output is the first input. This is used to choose between register data and immediate values for ALU input.

## MUX32FU.v
The MUX32FU module is a 4-to-1 multiplexer that selects one of four 32-bit inputs based on a 2-bit selector. It is used as the multiplexer in the two forwarding paths that feed the ALU inputs. The selection logic is as follows:
- 00: Selects the register value from the ID/EX pipeline, no hazard.
- 01: Selects the write-back data from the MEM/WB stage to resolve a MEM hazard.
- 10: Selects the ALU result from the EX/MEM stage to resolve an EX hazard.
The selector bits are determined by the output of the Forwarding_Unit, which detects hazards and determines the appropriate forwarding source.

## Sign_Extend.v
The Sign_Extend module takes a 12-bit immediate as input and sign-extends it to 32 bits. It does so by copying the sign bit (the 11th bit) into the upper 20 bits. This allows the immediate to be correctly interpreted as a signed 32-bit value during ALU operations.

## branch_predictor.v
The `branch_predictor` module implements a simple 2-bit saturating counter branch predictor. It maintains a state that is updated on every branch instruction based on whether the previous branch was taken or not. The predictor outputs a prediction (`predict_o`) that is high if the state is in either of the "taken" states, and low otherwise. The state is updated only when a branch instruction is resolved, using the actual branch outcome. This helps the CPU speculate on the next PC value and improves pipeline performance by reducing branch misprediction penalties.

## CPU.v
The CPU module is the top-level module that integrates all components. It defines the datapath and control logic needed to execute R-type, I-type, sw, lw, and beq instructions in pipeline cycles.

## Modifications to CPU.v for Branch Prediction
To integrate the branch predictor into the pipeline, I made several changes to `CPU.v`. I instantiated the `branch_predictor` module and connected its `update_i` input to indicate when a branch instruction is resolved, and its `result_i` input to the actual branch outcome (whether the branch was taken). The predictor's output (`predictor`) is used in the fetch stage to select the predicted next PC.

Additionally, I added two new 2-to-1 multiplexers: `MUX32 PC_ID_Branching` and `MUX32 PC_EX_Branching`.
- `PC_ID_Branching` selects between the sequential PC (PC + 4) and the branch target computed in the ID stage, based on the branch prediction result.
- `PC_EX_Branching` selects between the predicted PC and the corrected PC from the EX stage in case a branch misprediction is detected.

These MUXes, together with the branch predictor, allow the CPU to speculatively fetch instructions based on branch predictions and to recover gracefully from mispredictions by flushing and redirecting the pipeline as needed.


# Difficulties encountered and solutions in this lab

I spent a significant amount of time debugging this lab, and ultimately found my main mistakes by using the gtkwave waveform viewer. Initially, I encountered many syntax errors, such as forgetting to declare inputs or outputs in a module before using them. After resolving these issues with the command `iverilog -g2012 -o cpu code/supplied/*.v code/src/*.v`, I faced more challenging functional bugs.

One major issue was seeing non-deterministic values like `IFID_Flush = x` in my outputs, which pointed to uninitialized or incorrectly declared variables. After fixing these declaration and initialization problems, I thought my design was correct, but then noticed that the output always showed `Predict = 1`. This indicated a problem with my `branch_predictor` module not updating its prediction state properly.

Initially, I tried to debug by modifying `testbench.v` and printing variables, which was time-consuming and not very effective. Eventually, I used gtkwave to inspect the waveforms and quickly identified that `last_instr_beq` in my branch predictor was not updating as expected. This led me to realize that my reset and state update logic were incorrect. After correcting the reset logic and ensuring the predictor state updated on every branch instruction, I was able to pass both testcases.

# Development environment
Developed on a macOS system using Verilog. Code was written and edited using Visual Studio Code, then ran the simulation on Jupiter. Debugged by using the waveform visualization tool gtkwave.
