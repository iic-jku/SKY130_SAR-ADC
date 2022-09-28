`default_nettype none
//`include "define.vh"

//  Copyright 2022 Manuel Moser
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.


// Combinatoric process. 
// Converts binary to thermometer-code in a
// capacitor array with 16 rows, 32 columns, and 3 additional Bin-Caps.
// Notes: row[0] col[0] is a dummy-cap. 
//        c0_n and c0_p control the second LSB-Capacitor
module adc_row_col_decoder(
    input  wire[11:0] data,
    output wire[15:0] row_n,
    output wire[15:0] rowon_n,
    output wire[15:0] col_n,
    output wire[2:0]  bincap_n,
    output wire       c0_p,
    output wire       c0_n
	);

reg[15:0] row;
reg[15:0] rowon;
reg[31:0] col;

reg[2:0] bincap;
reg[4:0] col_intermediate;
reg[3:0] row_intermediate;

//[                data                ]
//[11][10][9][8][7][6][5][4][3][2][1][0]
//[    row     ][    col      ][bincap ]
always @(data) begin
	bincap <= data[2:0];
	col_intermediate <= data[7:3];
	row_intermediate <= data[11:8];
end



generate
genvar i;
always @(col_intermediate) begin
	for (i = 0; i <= 31 ; i = i + 1) begin 
		if (i%2==1) begin //odd
		    col[i] <= 1'b0;
			if (col_intermediate >= (31-i))
		    	col[i] <= 1'b1;
		end else begin //even
		    col[i] <= 1'b0;
			if (col_intermediate >= i)
		    	col[i] <= 1'b1;
		end
	end
end
endgenerate

generate
genvar j;
always @(row_intermediate) begin
	for (j = 0; j <= 15 ; j = j + 1) begin 
	    row[j] <= 1'b0;
		if (row_intermediate >= j) 
	    	row[j] <= 1'b1;

	    rowon[j] <= 1'b0;
		if (row_intermediate > j) 
	    	rowon[j] <= 1'b1;
	end
end
endgenerate	

//convert to Active-Low signals
assign row_n = ~row;
assign rowon_n = ~rowon;
assign col_n = ~col;
assign bincap_n = ~bincap;

//LSB capacitor C0 is always enabled or disabled
assign c0_p = 1'b1;
assign c0_n = 1'b0;

endmodule


