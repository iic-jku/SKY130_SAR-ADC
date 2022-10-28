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
`default_nettype none

//***************************************
// Note: use RSZ_DONT_TOUCH_RX on 
// inp_analog, inn_analog, ctop_pmatrix_analog, ctop_nmatrix_analog
// Reason -> no buffers on analog nets
//***************************************

//Top module ADC Control
module adc_top(
   input wire clk_vcm, // 32.768Hz VCM generation clock
   input wire rst_n,   // reset
   input wire inp_analog,     // P differential input
   input wire inn_analog,     // N differential input
   input wire start_conversion_in,   
   input wire [15:0] config_1_in,    
   input wire [15:0] config_2_in,    
   output wire [15:0] result_out,    
   output wire conversion_finished_out
   );

//Configuration byte 1 mapping   
// config_1_in[2:0] = Average control
// config_1_in[5:3] = Oversampling control
// config_1_in[9:6] = unused
wire [5:0] delay_edgedetect_w = config_1_in[15:10];
//Configuration byte 2 mapping
wire [4:0] delay_1_w = config_2_in[4:0];
wire [4:0] delay_2_w = config_2_in[9:5];
wire [4:0] delay_3_w = config_2_in[14:10];
wire delaycontrol_en_w = config_2_in[15];

//*******************************************
//      Digital Core
//*******************************************
adc_core_digital core(
   .rst_n(rst_n),
   .config_1_in(config_1_in),
   .config_2_in(config_2_in),
   .result_out(result_out),
   .conv_finished_out(conversion_finished_out),
   // Connections to Comparator-Latch
   .comparator_in(result_comp),
   // Connections to Clockloop-Generator with Edgedetect
   .clk_dig_in(clk_dig_cgen),
   .enable_loop_out(ena_loop_core),
   // Connections to Cap-Matrix
   .sample_matrix_out(sample_matrix_core),
   .sample_matrix_out_n(sample_matrix_core_n),
   .sample_switch_out(sample_switch_core),
   .sample_switch_out_n(sample_switch_core_n),
   .pmatrix_col_out_n(pmatrix_col_core_n),
   .pmatrix_row_out_n(pmatrix_row_core_n),
   .pmatrix_rowon_out_n(pmatrix_rowon_core_n),
   .pmatrix_bincap_out_n(pmatrix_bincap_core_n),
   .pmatrix_c0_out_n(pmatrix_c0_core_n),
   .nmatrix_col_out_n(nmatrix_col_core_n),
   .nmatrix_row_out_n(nmatrix_row_core_n),
   .nmatrix_rowon_out_n(nmatrix_rowon_core_n),
   .nmatrix_bincap_out_n(nmatrix_bincap_core_n),
   .nmatrix_c0_out_n(nmatrix_c0_core_n)
);

wire sample_matrix_core, sample_matrix_core_n;
wire sample_switch_core, sample_switch_core_n;
wire [31:0] pmatrix_col_core_n, nmatrix_col_core_n;
wire [15:0] pmatrix_row_core_n, nmatrix_row_core_n;
wire [15:0] pmatrix_rowon_core_n, nmatrix_rowon_core_n;
wire [2:0]  pmatrix_bincap_core_n, nmatrix_bincap_core_n;
wire [2:0]  pmatrix_c0_core_n, nmatrix_c0_core_n;
wire ena_loop_core;

//*******************************************
//      Clock Loop with Edge-Detection
//      **** HARDENED MACRO ****
//*******************************************


adc_clkgen_with_edgedetect cgen (
   .ena_in(ena_loop_core),
   .start_conv_in(start_conversion_in),
   .ndecision_finish_in(decision_finish_comp_n),
   .clk_dig_out(clk_dig_cgen),
   .clk_comp_out(clk_comp_cgen),
   .enable_dlycontrol_in(delaycontrol_en_w),
   .dlycontrol1_in(delay_1_w),
   .dlycontrol2_in(delay_2_w),
   .dlycontrol3_in(delay_3_w),
   .dlycontrol4_in(delay_edgedetect_w),
   .sample_p_in(sample_matrix_core),
   .sample_n_in(sample_matrix_core),
   .nsample_p_in(sample_matrix_core_n),
   .nsample_n_in(sample_matrix_core_n),
   .sample_p_out(sample_pmatrix_cgen),
   .sample_n_out(sample_nmatrix_cgen),
   .nsample_p_out(sample_pmatrix_cgen_n),
   .nsample_n_out(sample_nmatrix_cgen_n)
   );

wire clk_dig_cgen;    
wire clk_comp_cgen;  
wire sample_pmatrix_cgen, sample_pmatrix_cgen_n;
wire sample_nmatrix_cgen, sample_nmatrix_cgen_n;
  
//*******************************************
//      Matrix P-side
//      **** HARDENED MACRO ****
//*******************************************
(*keep*)
adc_array_matrix_12bit pmat (
   .sample(sample_pmatrix_cgen),
   .sample_n(sample_pmatrix_cgen_n),
   .row_n(pmatrix_row_core_n),
   .rowon_n(pmatrix_rowon_core_n),
   .col_n(pmatrix_col_core_n),
   .en_bit_n(pmatrix_bincap_core_n),
   .en_C0_n(pmatrix_c0_core_n),
   .sw(sample_switch_core), 
   .sw_n(sample_switch_core_n), 
   .analog_in(inp_analog), 
   .ctop(ctop_pmatrix_analog)
   );
wire ctop_pmatrix_analog; 

//*******************************************
//      Matrix N-side
//      **** HARDENED MACRO ****
//*******************************************
(*keep*)
adc_array_matrix_12bit nmat (
   .sample(sample_nmatrix_cgen),
   .sample_n(sample_nmatrix_cgen_n),
   .row_n(nmatrix_row_core_n),
   .rowon_n(nmatrix_rowon_core_n),
   .col_n(nmatrix_col_core_n),
   .en_bit_n(nmatrix_bincap_core_n),
   .en_C0_n(nmatrix_c0_core_n),
   .sw(sample_switch_core), 
   .sw_n(sample_switch_core_n), 
   .analog_in(inn_analog), 
   .ctop(ctop_nmatrix_analog)
   );
wire ctop_nmatrix_analog; 

//*******************************************
//      Comparator latch
//      **** HARDENED MACRO ****
//*******************************************
(*keep*)
adc_comp_latch comp (
   .clk(clk_comp_cgen),
   .inp(ctop_pmatrix_analog),
   .inn(ctop_nmatrix_analog),
   .comp_trig(decision_finish_comp_n),
   .latch_qn(_linting_unused_ok),
   .latch_q(result_comp)
   );

   wire decision_finish_comp_n;
   wire result_comp;
   wire _linting_unused_ok;

//*******************************************
//      VCM generator
//      **** HARDENED MACRO ****
//*******************************************
(*keep*)
adc_vcm_generator vcm (
   .clk(clk_vcm)
);

endmodule



//*******************************************
//      MACRO BLACKBOX DEFINITIONS
//*******************************************
(* Blackbox *)
module adc_array_matrix_12bit (sample,sample_n,row_n,rowon_n,col_n,en_bit_n,en_C0_n,sw,sw_n,analog_in,ctop);
   input sample,sample_n;
   input [15:0] row_n;
   input [15:0] rowon_n;
   input [31:0] col_n;
   input [2:0] en_bit_n;
   input en_C0_n;
   input sw, sw_n, analog_in,ctop;
endmodule

(* Blackbox *)
module adc_clkgen_with_edgedetect(ena_in,start_conv_in,ndecision_finish_in,clk_dig_out,clk_comp_out,enable_dlycontrol_in,dlycontrol1_in,dlycontrol2_in,dlycontrol3_in,dlycontrol4_in,sample_p_in,sample_n_in,nsample_p_in,nsample_n_in,sample_p_out,sample_n_out,nsample_p_out,nsample_n_out);
    input wire ena_in;             // enable signal from the digital clock core. 0 halts the self-clocked loop
    input wire start_conv_in;         // triggers a conversion once with edge-detection
    input wire ndecision_finish_in;   // comparator signalizes finished conversion
    output wire clk_dig_out;           // digital clock
    output wire clk_comp_out;          // comparator clock
    input wire enable_dlycontrol_in;  // 0 = max delays, 1 = configurable delays
    input wire [4:0] dlycontrol1_in;  // delay 1 of 3 in loop. Delay = 5ns*dlycontrol1
    input wire [4:0] dlycontrol2_in;  // delay 2 of 3 in loop. Delay = 5ns*dlycontrol2
    input wire [4:0] dlycontrol3_in;  // delay 3 of 3 in loop. Delay = 5ns*dlycontrol3
    input wire [5:0] dlycontrol4_in;  // edge detect pulse width. Delay = 5ns*dlycontrol4
    // integration of additional buffers for sample matrix
    input wire sample_p_in;           
    input wire sample_n_in;
    input wire nsample_p_in;
    input wire nsample_n_in;
    output wire sample_p_out;
    output wire sample_n_out;
    output wire nsample_p_out;
    output wire nsample_n_out;
endmodule

(* Blackbox *)
module adc_comp_latch(clk,inp,inn,comp_trig,latch_qn,latch_q);
    input wire  clk,inp,inn,comp_trig;
    output wire latch_qn,latch_q;
endmodule

(* Blackbox *)
module adc_vcm_generator(clk);
    input wire  clk;
endmodule
