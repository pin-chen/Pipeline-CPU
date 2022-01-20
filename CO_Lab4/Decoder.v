// Class: 109暑 計算機組織 蔡文錦
// Author: 陳品劭 109550206
// Date: 20210821
module Decoder( instr_op_i, RegWrite_o,	ALUOp_o, ALUSrc_o, RegDst_o, Branch_o, MemRead_o, MemWrite_o, MemtoReg_o, Jump_o, BranchType_o, Jal_o, rt_o);
     
//I/O ports
input	[6-1:0] instr_op_i;

output			RegWrite_o;
output	[3-1:0] ALUOp_o;
output			ALUSrc_o;
output			RegDst_o;
 
//Internal Signals
wire	[3-1:0] ALUOp_o;
wire			ALUSrc_o;
wire			RegWrite_o;
wire			RegDst_o;

//parameter
parameter RType= 6'b000000;
parameter addi = 6'b001000;
parameter lw   = 6'b101100;
parameter sw   = 6'b101101;
parameter beq  = 6'b001010;
parameter bne  = 6'b001011;
parameter jump = 6'b000010;
parameter jal  = 6'b000011;
parameter blt  = 6'b001110;
parameter bnez = 6'b001100;
parameter bgez = 6'b001101;

//new signals
output wire Branch_o;
output wire MemRead_o;
output wire MemWrite_o;
output wire MemtoReg_o;
output wire Jump_o;
output wire BranchType_o;
output wire Jal_o;
output wire rt_o;

//Main function
assign RegWrite_o = (instr_op_i == RType) ? 1'b1 :
					(instr_op_i == addi) ? 1'b1 : 
					(instr_op_i == lw) ? 1'b1 : 
					(instr_op_i == jal) ? 1'b1 : 1'b0;
assign ALUOp_o = 	(instr_op_i == RType) ? 3'b010 :
					(instr_op_i == addi) ? 3'b011 : 
					(instr_op_i == lw) ? 3'b000 :
					(instr_op_i == sw) ? 3'b000 :
					(instr_op_i == beq) ? 3'b001 :
					(instr_op_i == bne) ? 3'b110 :
					(instr_op_i == bnez) ? 3'b110 :
					(instr_op_i == blt) ? 3'b100 : 
					(instr_op_i == bgez) ? 3'b101 : 3'b000;
assign ALUSrc_o = 	(instr_op_i == RType) ? 1'b0 :
					(instr_op_i == addi) ? 1'b1 :
					(instr_op_i == lw) ? 1'b1 :
					(instr_op_i == sw) ? 1'b1 : 1'b0;
assign RegDst_o = 	(instr_op_i == RType) ? 1'b1 :
					(instr_op_i == addi) ? 1'b0 : 1'b0;
assign Branch_o = 	(instr_op_i == bne) ? 1'b1 :
					(instr_op_i == beq) ? 1'b1 :
					(instr_op_i == bnez) ? 1'b1 :
					(instr_op_i == blt) ? 1'b1 :
					(instr_op_i == bgez) ? 1'b1 : 1'b0;
assign MemRead_o = 	(instr_op_i == lw) ? 1'b1 : 1'b0;
assign MemWrite_o = (instr_op_i == sw) ? 1'b1 : 1'b0;
assign MemtoReg_o = (instr_op_i == lw) ? 1'b1 : 1'b0;
assign Jump_o = 	(instr_op_i == jump) ? 1'b1 : 
					(instr_op_i == jal) ? 1'b1 : 1'b0;
assign BranchType_o=(instr_op_i == beq) ? 1'b0 : 
					(instr_op_i == bne) ? 1'b1 : 
					(instr_op_i == bnez) ? 1'b1 :
					(instr_op_i == blt) ? 1'b1 :
					(instr_op_i == bgez) ? 1'b0 : 1'b0;
assign Jal_o =		(instr_op_i == jal) ? 1'b1 : 1'b0;
assign rt_o =		(instr_op_i == bnez) ? 1'b1 :
					(instr_op_i == bgez) ? 1'b1 : 1'b0;
endmodule
   