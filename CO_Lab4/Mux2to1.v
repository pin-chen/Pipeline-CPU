// Class: 109暑 計算機組織 蔡文錦
// Author: 陳品劭 109550206
// Date: 20210821
module Mux2to1( data0_i, data1_i, select_i, data_o );

parameter size = 0;			   
			
//I/O ports               
input wire	[size-1:0] data0_i;          
input wire	[size-1:0] data1_i;
input wire	select_i;
output wire	[size-1:0] data_o; 

//Main function
assign data_o = select_i ? data1_i : data0_i;

endmodule      
    