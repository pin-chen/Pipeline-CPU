// Class: 109暑 計算機組織 蔡文錦
// Author: 陳品劭 109550206
// Date: 20210812
module Instr_Memory( pc_addr_i, instr_o	);

//I/O ports
input  [32-1:0]  pc_addr_i;
output [32-1:0]	 instr_o;

//Internal Signals
reg    [32-1:0]	 instr_o;
integer          i;

//32 words Memory
reg    [32-1:0]  Instr_Mem [0:32-1];

//Parameter
    
//Main function
always @(pc_addr_i) begin
	instr_o = Instr_Mem[pc_addr_i/4];
end
    
//Initial Memory Contents
initial begin
    for ( i=0; i<32; i=i+1 )
	    Instr_Mem[i] = 32'b0;
		
end
endmodule
