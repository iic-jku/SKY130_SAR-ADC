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

`include "adc_control_nonbinary.v"
`timescale 10us/1us

module adc_control_nonbinary_tb;
  parameter MATRIX_BITS = 12;
  reg clk;
  reg rst;
  reg comparator_in;
  reg [2:0] avg_control;
  wire sample;
  wire nsample;
  wire enable;
  wire conv_finished;
  wire[MATRIX_BITS-1:0]  p_switch;
  wire[MATRIX_BITS-1:0]  n_switch;
  wire[MATRIX_BITS-1:0]  result;

  adc_control_nonbinary testmodule (
	   .clk(clk),
	   .rst(rst),
	   .comparator_in(comparator_in),
	   .avg_control(avg_control),
	   .sample(sample),
	   .nsample(nsample),
	   .enable(enable),
	   .conv_finished(conv_finished),
	   .p_switch(p_switch),
	   .n_switch(n_switch),
	   .result(result)
	   );	

   initial begin
   	$dumpfile("dump.vcd");
   	$dumpvars(0,
   		clk,
   		rst,
   		comparator_in,
   		avg_control,
   		sample,
   		nsample,
   		enable,
   		conv_finished,
   		p_switch,
   		n_switch,
   		result,
   		testmodule);
   end
   
   initial begin
   	#1 rst=1;
    #1 rst=0;
    #1 rst=1;
    #1 rst=1; avg_control = 3'b001;
    #1 comparator_in = 0;

    // first value is d1792
    avg_control = 3'b001; //4x averaging    
    #2 comparator_in = 0; //0001
    #2 comparator_in = 1; //8000
    #2 comparator_in = 0; //4000
    #2 comparator_in = 0; //2000
    #2 comparator_in = 0; //1000
    #2 comparator_in = 0; //0800
    #2 comparator_in = 0; //0400
    #2 comparator_in = 0; //0200
    #2 comparator_in = 0; //0100
    #2 comparator_in = 0; //0080
    #2 comparator_in = 0; //0040
    #2 comparator_in = 0; //0020
    //averaging
    #2 comparator_in = 0; //0010
    #2 comparator_in = 0;
    #2 comparator_in = 0;
    //averaging
    #2 comparator_in = 0; //0008
    #2 comparator_in = 0;
    #2 comparator_in = 0;
    //averaging
    #2 comparator_in = 0; //0004
    #2 comparator_in = 0;
    #2 comparator_in = 0;
    //averaging
    #2 comparator_in = 0; //0002
    #2 comparator_in = 0;
    #2 comparator_in = 0;
        

    // second value is d1024
    avg_control = 3'b000; //0x averaging
    #2 comparator_in = 0; //0001
    #2 comparator_in = 0; //8000
    #2 comparator_in = 1; //4000
    #2 comparator_in = 0; //2000
    #2 comparator_in = 0; //1000
    #2 comparator_in = 0; //0800
    #2 comparator_in = 0; //0400
    #2 comparator_in = 0; //0200
    #2 comparator_in = 0; //0100
    #2 comparator_in = 0; //0080
    #2 comparator_in = 0; //0040
    #2 comparator_in = 0; //0020
    //averaging
    #2 comparator_in = 0; //0010
    //averaging
    #2 comparator_in = 0; //0008
    //averaging
    #2 comparator_in = 0; //0004
    //averaging
    #2 comparator_in = 0; //0002
    
    // third value is d13
    avg_control = 3'b000; //0x averaging
    #2 comparator_in = 0; //0001
    #2 comparator_in = 0; //8000
    #2 comparator_in = 0; //4000
    #2 comparator_in = 0; //2000
    #2 comparator_in = 0; //1000
    #2 comparator_in = 0; //0800
    #2 comparator_in = 0; //0400
    #2 comparator_in = 0; //0200
    #2 comparator_in = 0; //0100
    #2 comparator_in = 0; //0080
    #2 comparator_in = 0; //0040
    #2 comparator_in = 0; //0020
    //averaging
    #2 comparator_in = 1; //0010
    //averaging
    #2 comparator_in = 1; //0008
    //averaging
    #2 comparator_in = 1; //0004
    //averaging
    #2 comparator_in = 1; //0002

    // fourth value is d515
    avg_control = 3'b010; //8x averaging
    #2 comparator_in = 0; //0001
    #2 comparator_in = 0; //8000
    #2 comparator_in = 0; //4000
    #2 comparator_in = 1; //2000 +512
    #2 comparator_in = 0; //1000
    #2 comparator_in = 0; //0800
    #2 comparator_in = 0; //0400
    #2 comparator_in = 0; //0200
    #2 comparator_in = 0; //0100
    #2 comparator_in = 0; //0080
    #2 comparator_in = 0; //0040
    #2 comparator_in = 0; //0020
    //averaging
    #2 comparator_in = 0; //0010
    #2 comparator_in = 1; 
    #2 comparator_in = 0; 
    #2 comparator_in = 1; 
    #2 comparator_in = 0; 
    #2 comparator_in = 0; 
    #2 comparator_in = 0; 
    //averaging
    #2 comparator_in = 0; //0008
    #2 comparator_in = 0; 
    #2 comparator_in = 0;
    #2 comparator_in = 0; 
    #2 comparator_in = 0; 
    #2 comparator_in = 0; 
    #2 comparator_in = 1; 
    //averaging
    #2 comparator_in = 1; //0010 +2
    #2 comparator_in = 0; 
    #2 comparator_in = 0;
    #2 comparator_in = 1; 
    #2 comparator_in = 0; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    //averaging
    #2 comparator_in = 1; //0010 +1
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    

    // fifth value is max value with max averaging d4095
    avg_control = 3'b100; //0x averaging
    #2 comparator_in = 0; //0001
    #2 comparator_in = 1; //8000
    #2 comparator_in = 1; //4000
    #2 comparator_in = 1; //2000
    #2 comparator_in = 1; //1000
    #2 comparator_in = 1; //0800
    #2 comparator_in = 1; //0400
    #2 comparator_in = 1; //0200
    #2 comparator_in = 1; //0100
    #2 comparator_in = 1; //0080
    #2 comparator_in = 1; //0040
    #2 comparator_in = 1; //0020
    //averaging
    #2 comparator_in = 1; //0010
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    //averaging
    #2 comparator_in = 1; //0008
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    //averaging
    #2 comparator_in = 1; //0004
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    //averaging
    #2 comparator_in = 1; //0002
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 
    #2 comparator_in = 1; 



    //  sixth value zero without averaging
    avg_control = 3'b000; //0x averaging
    #2 comparator_in = 0; //0001
    #2 comparator_in = 0; //8000
    #2 comparator_in = 0; //4000
    #2 comparator_in = 0; //2000
    #2 comparator_in = 0; //1000
    #2 comparator_in = 0; //0800
    #2 comparator_in = 0; //0400
    #2 comparator_in = 0; //0200
    #2 comparator_in = 0; //0100
    #2 comparator_in = 0; //0080
    #2 comparator_in = 0; //0040
    #2 comparator_in = 0; //0020
    //averaging
    #2 comparator_in = 0; //0010
    //averaging
    #2 comparator_in = 0; //0008
    //averaging
    #2 comparator_in = 0; //0004
    //averaging
    #2 comparator_in = 0; //0002

    #512 $finish;
   end

    initial begin
   	#1 clk=0;
    #6 clk=0;
    forever begin
    	#1 clk = ~clk;
    end
    end  


endmodule

