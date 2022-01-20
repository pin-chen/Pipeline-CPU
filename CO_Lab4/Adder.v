// Class: 109暑 計算機組織 蔡文錦
// Author: 陳品劭 109550206
// Date: 20210821
module Adder( src1_i, src2_i, sum_o	);

//I/O ports
input	[32-1:0] src1_i;
input	[32-1:0] src2_i;
output	[32-1:0] sum_o;

//Internal Signals
wire	[32-1:0] sum_o;
    
//Main function
assign sum_o = src1_i + src2_i;


endmodule
