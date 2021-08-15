// Class: 109暑 計算機組織 蔡文錦
// Author: 陳品劭 109550206
// Date: 20210812
module Shifter( result, leftRight, shamt, sftSrc );

//I/O ports 
output	[32-1:0] result;

input			leftRight;
input	[5-1:0] shamt;
input	[32-1:0] sftSrc ;

//Internal Signals
wire	[32-1:0] result;

//Main function 
assign result = leftRight ? (sftSrc >> shamt) : (sftSrc << shamt);
	

endmodule