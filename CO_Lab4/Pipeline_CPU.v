// Class: 109暑 計算機組織 蔡文錦
// Author: 陳品劭 109550206
// Date: 20210821
module Pipeline_CPU( clk_i, rst_n );

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
//reg jal
wire [5-1:0] Jal_Write_reg;
wire [32-1:0] Jal_WB_Data;
wire Jal;
//MEM/WB
wire MEM_EX_ID_RegWrite;
wire [5-1:0] MEM_EX_Write_reg;

//modules
//IF
Program_Counter PC(
        .clk_i(clk_i),      
	    .rst_n(rst_n),     
	    .pc_in_i(add_pc),   
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
//IF/ID
wire [32-1:0] IF_instr;
Pipeline_Reg #(.size(32)) Pipeline_IM( 
		.clk_i(clk_i),
		.rst_i(rst_n),
		.data_i(instr_o),
		.data_o(IF_instr)
		);
//ID
Reg_File RF(
        .clk_i(clk_i),      
	    .rst_n(rst_n),     
        .RSaddr_i(IF_instr[25:21]),  
        .RTaddr_i(IF_instr[20:16]),  
        .RDaddr_i(MEM_EX_Write_reg),  
        .RDdata_i(WB_Data), 
        .RegWrite_i(MEM_EX_ID_RegWrite),
        .RSdata_o(rs_data),  
        .RTdata_o(rt_data)   
        );
	
Decoder Decoder(
        .instr_op_i(IF_instr[32-1:26]), 
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
        .data_i(IF_instr[15:0]),
        .data_o(sign_instr)
        );

Zero_Filled ZF(
        .data_i(IF_instr[15:0]),
        .data_o(zero_instr)
        );
//ID/EX
wire ID_RegDst;
wire ID_RegWrite;
wire [3-1:0] ID_ALUOp;
wire ID_ALUSrc;
wire ID_MemWrite;
wire ID_MemRead;
wire ID_MemtoReg;
Pipeline_Reg #(.size(9)) Pipeline_Control( 
		.clk_i(clk_i),
		.rst_i(rst_n),
		.data_i({RegWrite, ALUOp, ALUSrc, RegDst, MemRead, MemWrite, MemtoReg}),
		.data_o({ID_RegWrite, ID_ALUOp, ID_ALUSrc, ID_RegDst, ID_MemRead, ID_MemWrite, ID_MemtoReg})
		);
wire [32-1:0] ID_rs_data;
Pipeline_Reg #(.size(32)) Pipeline_RS( 
		.clk_i(clk_i),
		.rst_i(rst_n),
		.data_i(rs_data),
		.data_o(ID_rs_data)
		);
wire [32-1:0] ID_rt_data;
Pipeline_Reg #(.size(32)) Pipeline_RT( 
		.clk_i(clk_i),
		.rst_i(rst_n),
		.data_i(rt_data),
		.data_o(ID_rt_data)
		);
wire [32-1:0] ID_sign_instr;
Pipeline_Reg #(.size(32)) Pipeline_SE( 
		.clk_i(clk_i),
		.rst_i(rst_n),
		.data_i(sign_instr),
		.data_o(ID_sign_instr)
		);
wire [32-1:0] ID_zero_instr;
Pipeline_Reg #(.size(32)) Pipeline_ZF( 
		.clk_i(clk_i),
		.rst_i(rst_n),
		.data_i(zero_instr),
		.data_o(ID_zero_instr)
		);
wire [32-1:0] ID_IF_instr;
Pipeline_Reg #(.size(32)) Pipeline_IM_ID_EX( 
		.clk_i(clk_i),
		.rst_i(rst_n),
		.data_i(IF_instr),
		.data_o(ID_IF_instr)
		);
//EX
Mux2to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(ID_IF_instr[20:16]),
        .data1_i(ID_IF_instr[15:11]),
        .select_i(ID_RegDst),
        .data_o(Write_reg)
        );	

ALU_Ctrl AC(
        .funct_i(ID_IF_instr[6-1:0]),   
        .ALUOp_i(ID_ALUOp),   
        .ALU_operation_o(ALUCtrl),
		.FURslt_o(FURslt)
        );

Mux2to1 #(.size(32)) ALU_src2Src(
        .data0_i(ID_rt_data),
        .data1_i(ID_sign_instr),
        .select_i(ALUSrc),
        .data_o(Src_ALU_Shifter)
        );	

Mux2to1 #(.size(5)) Shamt_Src(
        .data0_i(ID_IF_instr[10:6]),
        .data1_i(ID_rs_data[5-1:0]),
        .select_i(ALUCtrl[1]),
        .data_o(ShamtSrc)
        );	

ALU ALU(
		.aluSrc1(ID_rs_data),
	    .aluSrc2(Src_ALU_Shifter),
	    .ALU_operation_i(ALUCtrl),
		.result(result_ALU),
		.zero(zero),
		.overflow(overflow)
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
		.data2_i(ID_zero_instr),
        .select_i(FURslt),
        .data_o(Write_Data)
        );	
//EX/MEM
wire EX_ID_RegWrite;
wire EX_ID_MemWrite;
wire EX_ID_MemRead;
wire EX_ID_MemtoReg;
Pipeline_Reg #(.size(4)) Pipeline_Control_EX( 
		.clk_i(clk_i),
		.rst_i(rst_n),
		.data_i({ID_RegWrite, ID_MemRead, ID_MemWrite, ID_MemtoReg}),
		.data_o({EX_ID_RegWrite, EX_ID_MemRead, EX_ID_MemWrite, EX_ID_MemtoReg})
		);
wire [32-1:0] EX_Write_Data;
Pipeline_Reg #(.size(32)) Pipeline_Write_Data( 
		.clk_i(clk_i),
		.rst_i(rst_n),
		.data_i(Write_Data),
		.data_o(EX_Write_Data)
		);
wire [32-1:0] EX_ID_rt_data;
Pipeline_Reg #(.size(32)) Pipeline_RT_EX( 
		.clk_i(clk_i),
		.rst_i(rst_n),
		.data_i(ID_rt_data),
		.data_o(EX_ID_rt_data)
		);
wire [5-1:0] EX_Write_reg;
Pipeline_Reg #(.size(5)) Pipeline_Write_reg( 
		.clk_i(clk_i),
		.rst_i(rst_n),
		.data_i(Write_reg),
		.data_o(EX_Write_reg)
		);		
		
//MEM
Data_Memory DM(
        .clk_i(clk_i), 
		.addr_i(EX_Write_Data),
		.data_i(EX_ID_rt_data),
		.MemRead_i(EX_ID_MemRead),
		.MemWrite_i(EX_ID_MemWrite),
		.data_o(MemReadData)
	);
//MEM/WB
wire MEM_EX_ID_MemtoReg;
Pipeline_Reg #(.size(2)) Pipeline_Control_MEM( 
		.clk_i(clk_i),
		.rst_i(rst_n),
		.data_i({EX_ID_RegWrite, EX_ID_MemtoReg}),
		.data_o({MEM_EX_ID_RegWrite, MEM_EX_ID_MemtoReg})
		);
wire [32-1:0] MEM_EX_Write_Data;
Pipeline_Reg #(.size(32)) Pipeline_Write_Data_MEM( 
		.clk_i(clk_i),
		.rst_i(rst_n),
		.data_i(EX_Write_Data),
		.data_o(MEM_EX_Write_Data)
		);
wire [32-1:0] MEM_MemReadData;
Pipeline_Reg #(.size(32)) Pipeline_MEM_Data( 
		.clk_i(clk_i),
		.rst_i(rst_n),
		.data_i(MemReadData),
		.data_o(MEM_MemReadData)
		);

Pipeline_Reg #(.size(5)) Pipeline_Write_reg_MEM( 
		.clk_i(clk_i),
		.rst_i(rst_n),
		.data_i(EX_Write_reg),
		.data_o(MEM_EX_Write_reg)
		);		
//WB
Mux2to1 #(.size(32)) WB_Mux(
        .data0_i(MEM_EX_Write_Data),
        .data1_i(MEM_MemReadData),
        .select_i(MEM_EX_ID_MemtoReg),
        .data_o(WB_Data)
	);
	
	
endmodule



