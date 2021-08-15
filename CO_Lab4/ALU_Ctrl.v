// Class: 109暑 計算機組織 蔡文錦
// Author: 陳品劭 109550206
// Date: 20210812
module ALU_Ctrl( funct_i, ALUOp_i, ALU_operation_o, FURslt_o );

//I/O ports 
input      [6-1:0] funct_i;
input      [3-1:0] ALUOp_i;

output     [4-1:0] ALU_operation_o;  
output     [2-1:0] FURslt_o;
     
//Internal Signals
wire		[4-1:0] ALU_operation_o;
wire		[2-1:0] FURslt_o;

//parameter
parameter addi = 3'b011;
parameter lwsw  = 3'b000;
parameter beq  = 3'b001;
parameter bne  = 3'b110;
parameter blt  = 3'b100;
parameter bgez = 3'b101;
//Main function
assign ALU_operation_o =  ({ALUOp_i,funct_i} == 9'b010010011 || ALUOp_i == addi || ALUOp_i == lwsw) ? 4'b0010 : //add
			 		      ({ALUOp_i,funct_i} == 9'b010010001 || ALUOp_i == beq || ALUOp_i == bne) ? 4'b0110 :  //sub
			 		      ({ALUOp_i,funct_i} == 9'b010010100) ? 4'b0000 :  //and
			 		      ({ALUOp_i,funct_i} == 9'b010010110) ? 4'b0001 :  //or 
			  		      ({ALUOp_i,funct_i} == 9'b010010101) ? 4'b1100 :  //nor 
			 		      ({ALUOp_i,funct_i} == 9'b010110000 || ALUOp_i == blt || ALUOp_i == bgez ) ? 4'b0111 :  //slt
			 		      ({ALUOp_i,funct_i} == 9'b010000000) ? 4'b0000 :  //sll
			 		      ({ALUOp_i,funct_i} == 9'b010000010) ? 4'b0001 :  //srl
			 		      ({ALUOp_i,funct_i} == 9'b010000110) ? 4'b0010 :  //sllv
					      ({ALUOp_i,funct_i} == 9'b010000100) ? 4'b0011 : 4'b0000;  //srlv others
assign FURslt_o =  	(ALUOp_i == lwsw || ALUOp_i == beq || ALUOp_i == bne || ALUOp_i == blt || ALUOp_i == bgez) ? 2'b00 :		//
					({ALUOp_i,funct_i} == 9'b010010011 || ALUOp_i == addi) ? 2'b00 : //add
					({ALUOp_i,funct_i} == 9'b010010001) ? 2'b00 :  //sub
					({ALUOp_i,funct_i} == 9'b010010100) ? 2'b00 :  //and
					({ALUOp_i,funct_i} == 9'b010010110) ? 2'b00 :  //or 
					({ALUOp_i,funct_i} == 9'b010010101) ? 2'b00 :  //nor 
			 		({ALUOp_i,funct_i} == 9'b010110000) ? 2'b00 :  //slt
			 		({ALUOp_i,funct_i} == 9'b010000000) ? 2'b01 :  //sll
					({ALUOp_i,funct_i} == 9'b010000010) ? 2'b01 :  //srl
					({ALUOp_i,funct_i} == 9'b010000110) ? 2'b01 :  //sllv
					({ALUOp_i,funct_i} == 9'b010000100) ? 2'b01 : 2'b00;  //srlv others

endmodule     
