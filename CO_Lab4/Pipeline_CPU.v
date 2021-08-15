// Class: 109暑 計算機組織 蔡文錦
// Author: 陳品劭 109550206
// Date: 20210812
module Simple_Single_CPU( clk_i, rst_n );

//I/O port
input         clk_i;
input         rst_n;

//Internal Signles
wire [32-1:0] add_pc;
wire [32-1:0] pc_inst;
wire [32-1:0] instr_o;
wire [5-1:0] Write_reg;
wire RegDst;
wire RegWrite;
wire [3-1:0] ALUOp;
wire ALUSrc;
wire [32-1:0] Write_Data;
wire [32-1:0] rs_data;
wire [32-1:0] rt_data;
wire [4-1:0] ALUCtrl;
wire [2-1:0] FURslt;
wire [32-1:0] sign_instr;
wire [32-1:0] zero_instr;
wire [32-1:0] Src_ALU_Shifter;
wire zero;
wire [32-1:0] result_ALU;
wire [32-1:0] result_Shifter;
wire overflow;
wire [5-1:0] ShamtSrc;
//MEM-WB
wire [32-1:0] MemReadData;
wire [32-1:0] WB_Data;
//control decode
wire Branch;
wire MemWrite;
wire MemRead;
wire MemtoReg;
wire Jump;
wire BranchType;
wire rt;
//pc
wire [32-1:0] add_add_pc;
wire [32-1:0] Branch_pc;
wire [32-1:0] Jump_pc;
wire [32-1:0] Jr_pc;
wire PCSrc;
//reg jal
wire [5-1:0] Jal_Write_reg;
wire [32-1:0] Jal_WB_Data;
wire Jal;
//

//modules
//IF
Program_Counter PC(
        .clk_i(clk_i),      
	    .rst_n(rst_n),     
	    .pc_in_i(Jr_pc),   
	    .pc_out_o(pc_inst) 
	    );
	
Adder Adder1(
        .src1_i(pc_inst),     
	    .src2_i(32'd4),
	    .sum_o(add_pc)    
	    );

Instr_Memory IM(
        .pc_addr_i(pc_inst),  
	    .instr_o(instr_o)    
	    );
//ID
Mux2to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(instr_o[20:16]),
        .data1_i(instr_o[15:11]),
        .select_i(RegDst),
        .data_o(Write_reg)
        );	

Mux2to1 #(.size(5)) Jal_Reg_Mux(
        .data0_i(Write_reg),
        .data1_i(5'b11111),
        .select_i(Jal),
        .data_o(Jal_Write_reg)
        );	

Mux2to1 #(.size(32)) Jal_WB_Mux(
        .data0_i(WB_Data),
        .data1_i(add_pc),
        .select_i(Jal),
        .data_o(Jal_WB_Data)
        );	

Reg_File RF(
        .clk_i(clk_i),      
	    .rst_n(rst_n) ,     
        .RSaddr_i(instr_o[25:21]) ,  
        .RTaddr_i(instr_o[20:16]) ,  
        .RDaddr_i(Jal_Write_reg) ,  
        .RDdata_i(Jal_WB_Data)  , 
        .RegWrite_i(RegWrite),
        .RSdata_o(rs_data) ,  
        .RTdata_o(rt_data)   
        );
	
Decoder Decoder(
        .instr_op_i(instr_o[32-1:26]), 
	    .RegWrite_o(RegWrite), 
	    .ALUOp_o(ALUOp),   
	    .ALUSrc_o(ALUSrc),   
	    .RegDst_o(RegDst),
		.Branch_o(Branch),
		.MemRead_o(MemRead),
		.MemWrite_o(MemWrite),
		.MemtoReg_o(MemtoReg),
		.Jump_o(Jump),
		.BranchType_o(BranchType),
		.Jal_o(Jal),
		.rt_o(rt)
		);
	
Sign_Extend SE(
        .data_i(instr_o[15:0]),
        .data_o(sign_instr)
        );

Zero_Filled ZF(
        .data_i(instr_o[15:0]),
        .data_o(zero_instr)
        );
//EX
Adder Adder2(
        .src1_i(add_pc),     
	    .src2_i(sign_instr << 2),
	    .sum_o(add_add_pc)    
	    );

ALU_Ctrl AC(
        .funct_i(instr_o[6-1:0]),   
        .ALUOp_i(ALUOp),   
        .ALU_operation_o(ALUCtrl),
		.FURslt_o(FURslt)
        );

Mux2to1 #(.size(32)) ALU_src2Src(
        .data0_i(rt_data),
        .data1_i(sign_instr),
        .select_i(ALUSrc),
        .data_o(Src_ALU_Shifter)
        );	

Mux2to1 #(.size(5)) Shamt_Src(
        .data0_i(instr_o[10:6]),
        .data1_i(rs_data[5-1:0]),
        .select_i(ALUCtrl[1]),
        .data_o(ShamtSrc)
        );	

ALU ALU(
		.aluSrc1(rs_data),
	    .aluSrc2(rt ? 32'b0 : Src_ALU_Shifter),
	    .ALU_operation_i(ALUCtrl),
		.result(result_ALU),
		.zero(zero),
		.overflow(overflow)
	    );
	
Mux2to1 #(.size(1)) BranchType_Mux(
        .data0_i(zero),
        .data1_i(~zero),
        .select_i(BranchType),
        .data_o(PCSrc)
        );
	
Shifter shifter( 
		.result(result_Shifter), 
		.leftRight(ALUCtrl[0]),
		.shamt(ShamtSrc),
		.sftSrc(Src_ALU_Shifter) 
		);
		
Mux3to1 #(.size(32)) RDdata_Source(
        .data0_i(result_ALU),
        .data1_i(result_Shifter),
		.data2_i(zero_instr),
        .select_i(FURslt),
        .data_o(Write_Data)
        );			
//MEM
Data_Memory DM(
        .clk_i(clk_i), 
		.addr_i(Write_Data),
		.data_i(rt_data),
		.MemRead_i(MemRead),
		.MemWrite_i(MemWrite),
		.data_o(MemReadData)
	);

Mux2to1 #(.size(32)) Branch_Mux(
        .data0_i(add_pc),
        .data1_i(add_add_pc),
        .select_i(Branch & PCSrc),
        .data_o(Branch_pc)
        );		
		
Mux2to1 #(.size(32)) Jump_Mux(
        .data0_i(Branch_pc),
        .data1_i({add_pc[31:28], instr_o[27:0] << 2}),
        .select_i(Jump),
        .data_o(Jump_pc)
        );	

Mux2to1 #(.size(32)) Jr_Mux(
        .data0_i(Jump_pc),
        .data1_i(rs_data),
        .select_i(~instr_o[5] & ~instr_o[4] & instr_o[3] & ~instr_o[2] & ~instr_o[1] & ~instr_o[0] & RegDst),
        .data_o(Jr_pc)
        );	
//WB
Mux2to1 #(.size(32)) WB_Mux(
        .data0_i(Write_Data),
        .data1_i(MemReadData),
        .select_i(MemtoReg),
        .data_o(WB_Data)
	);
	
	
endmodule



