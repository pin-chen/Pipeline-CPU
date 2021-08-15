// Class: 109暑 計算機組織 蔡文錦
// Author: 陳品劭 109550206
// Date: 20210812
module Sign_Extend( data_i, data_o );

//I/O ports
input	[16-1:0] data_i;
output	[32-1:0] data_o;

//Internal Signals
wire	[32-1:0] data_o;

//Sign extended
assign data_o[32-1:0] = {{16{data_i[16-1]}},data_i[16-1:0]};


endmodule      
