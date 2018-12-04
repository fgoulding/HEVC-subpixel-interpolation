`include "library.v"
`include "input_mux_single_row.v"
`include "fir_approx_multiplierless.v"

`define OFFSET 5

/**********************
 *
 * subpixel_interpolation - top-level module that interpolates a array of subpixels
 *
 **********************/

module subpixel_interpolation(clk,rst, in_row,next_row,
                              // out_A, out_B, out_C,
                              cnt,
                              fir_out_a, fir_out_b, fir_out_c,
                              temp_A, temp_B,temp_C, load_out_t, so,s,currentPixels,load_L,is_row,is_output_row,sel2);
  parameter num_pixel = 8;
  parameter sizeofPixel = 8;
  input clk;
  input rst;

  // this should just be 1 row in size...
  input  [119:0] in_row;
  output [63:0] next_row;

  output [7:0] cnt;
  output [63:0] fir_out_a;
  output [63:0] fir_out_b;
  output [63:0] fir_out_c;
  output [959:0] temp_A;
  output [959:0] temp_B;
  output [959:0] temp_C;
  output load_out_t;
  output [1:0] so;
  output [1:0] s;

output load_L;
output is_row;
output is_output_row;
output [9:0] sel2;

  /////////////////////////////
  output [119:0] currentPixels;
  wire [119:0] currentPixels;

  /////////////////////////////
  wire [9:0] sel;
  wire [9:0] sel2;
  wire [1:0] s;
  wire [1:0] so;
  wire [7:0] val;
  wire [7:0] cnt;
  wire [7:0] cnt_mod;
  // new inputs from outputs of last cycle
  wire [959:0] temp_A;
  wire [959:0] temp_B;
  wire [959:0] temp_C;
  wire first_round;
  wire [63:0] fir_out_a;
  wire [63:0] fir_out_b;
  wire [63:0] fir_out_c;
  wire load_out,load_L,load_in;
  wire _update_row;
  wire [63:0] next_row;
  wire [63:0] meta_row;
  wire is_row, is_output_row, is_col;

  assign _update_row = 1'b1;

  counter_wA row_counter(clk,rst, load_in, next_row);
  counter pc(clk, rst, cnt);
  counter_903reset meta_row_counter(clk, rst, meta_row);

  // register #(.WIDTH(8)) select(clk, rst, 1'b0, cnt, sel);
  // register #(.WIDTH(8)) select2(clk, rst, 1'b0, sel, sel2);

  // shift register where output is in_buffer
  wire  [1799:0] in_buffer; //for (4+7)*(4+7) interpolation
  assign first_round = (meta_row <= 49);
  assign load_in = !( (first_round && (cnt <= 15)) || (first_round && (cnt == 49)) || (!first_round && (cnt <= 11)) );

  assign load_L = !( (first_round && (cnt<=(16)) ) || (first_round && (cnt == 49)) || ( !first_round && (cnt <= 12) ) );

  assign is_row = ( first_round && (0 <= cnt) && (cnt <= 14) ) || ( !first_round && (0 <= cnt) && (cnt <= 7) );
  // assign is_output_row = ( first_round && ((3+3 <= cnt) && (cnt <= 10))) &&  ( !first_round && (0 <= cnt) && (cnt <= 8) );
  assign is_output_row = ( first_round && ((3 <= cnt) && (cnt <= 10))) ||  ( !first_round && (0 <= cnt) && (cnt <= 6) );
  assign is_output = ( first_round && ((17 <= cnt) && (cnt <= 48))) || (first_round && (cnt == 49) )  ;

  assign is_col = (2 < cnt) && (cnt <10);


  assign load_out = ( ( (is_output_row || is_output) ) );

  // assign load_out = !( ( first_round && ( is_output_row || ((cnt > 16) && (cnt < 50)) ) ) ||
                       // (!first_round && ( is_output_row || ((cnt > 15) && (cnt < 50))) )     );

  register #(.WIDTH(10)) select(clk, rst, 1'b0, {cnt,load_out,load_L}, sel);

  register #(.WIDTH(10)) select2(clk, rst, 1'b0, sel, sel2);

  input_shift_reg input_register(clk, rst, load_in,in_row,in_buffer);
  input_array_mux input_mux(clk,rst,sel2,s,in_buffer, temp_A, temp_B, temp_C, sel2[9:2],first_round, currentPixels);

  // genvar i;
  // generate
  //   for (i = 0; i < 8 ; i++) begin : generate_filter_a
  //     FIR_A_M filter_a(clk,rst, currentPixels[i*sizeofPixel +: 64], any_out_A[i*4sizeOfPixel +:8]);
  //   end
  // endgenerate
  FIR_A_M filter_a1(clk,rst,s, so, currentPixels[0 +:64], fir_out_a[0 +:8]);
  FIR_A_M filter_a2(clk,rst,s, so, currentPixels[8 +:64], fir_out_a[8 +:8]);
  FIR_A_M filter_a3(clk,rst,s, so, currentPixels[16 +:64], fir_out_a[16 +:8]);
  FIR_A_M filter_a4(clk,rst,s, so, currentPixels[24 +:64], fir_out_a[24 +:8]);
  FIR_A_M filter_a5(clk,rst,s, so, currentPixels[32 +:64], fir_out_a[32 +:8]);
  FIR_A_M filter_a6(clk,rst,s, so, currentPixels[40 +:64], fir_out_a[40 +:8]);
  FIR_A_M filter_a7(clk,rst,s, so, currentPixels[48 +:64], fir_out_a[48 +:8]);
  FIR_A_M filter_a8(clk,rst,s, so, currentPixels[56 +:64], fir_out_a[56 +:8]);

  // assign out_A[sel +: 64] = fir_out_a;

  // genvar j;
  //
  // generate
  //   for (j = 0; j < 8 ; j++) begin : generate_filter_b
  //     FIR_B_M filter_b(currentPixels[i*sizeofPixel:63+i*sizeofPixel], any_out_B[i*sizeOfPixel:7+i*sizeofPixel],clk,rst);
  //   end
  // endgenerate
  //
  FIR_B_M filter_b1(clk,rst, currentPixels[0 +:64], fir_out_b[0 +:8]);
  FIR_B_M filter_b2(clk,rst, currentPixels[8 +:64], fir_out_b[8 +:8]);
  FIR_B_M filter_b3(clk,rst, currentPixels[16 +:64], fir_out_b[16 +:8]);
  FIR_B_M filter_b4(clk,rst, currentPixels[24 +:64], fir_out_b[24 +:8]);
  FIR_B_M filter_b5(clk,rst, currentPixels[32 +:64], fir_out_b[32 +:8]);
  FIR_B_M filter_b6(clk,rst, currentPixels[40 +:64], fir_out_b[40 +:8]);
  FIR_B_M filter_b7(clk,rst, currentPixels[48 +:64], fir_out_b[48 +:8]);
  FIR_B_M filter_b8(clk,rst, currentPixels[56 +:64], fir_out_b[56 +:8]);
  // genvar k;
  // generate
  //   for (k = 0; k < 8 ; k++) begin : generate_filter_c
  //     FIR_C_M filter_c(currentPixels[i*sizeofPixel:63+i*sizeofPixel], any_out_C[i*sizeOfPixel:7+i*sizeofPixel],clk,rst);
  //   end
  // endgenerate
  //

  FIR_C_M filter_c1(clk,rst, currentPixels[0 +:64], fir_out_c[0 +:8]);
  FIR_C_M filter_c2(clk,rst, currentPixels[8 +:64], fir_out_c[8 +:8]);
  FIR_C_M filter_c3(clk,rst, currentPixels[16 +:64], fir_out_c[16 +:8]);
  FIR_C_M filter_c4(clk,rst, currentPixels[24 +:64], fir_out_c[24 +:8]);
  FIR_C_M filter_c5(clk,rst, currentPixels[32 +:64], fir_out_c[32 +:8]);
  FIR_C_M filter_c6(clk,rst, currentPixels[40 +:64], fir_out_c[40 +:8]);
  FIR_C_M filter_c7(clk,rst, currentPixels[48 +:64], fir_out_c[48 +:8]);
  FIR_C_M filter_c8(clk,rst, currentPixels[56 +:64], fir_out_c[56 +:8]);

  // assign load_L = so[0];

  /*
   * registers to hold the horizontal half pixels
   */
  // shift_reg sr_A(clk, rst, s[0], fir_out_a , temp_A);
  shift_reg sr_B(clk, rst, s[0], fir_out_b , temp_B);
  // shift_reg sr_C(clk, rst, s[0], fir_out_c , temp_C);

  assign load_out_t = s[1];
  // output_filler filler_a(clk, rst, load_out, sel, fir_out_a, out_A);
  // output_filler filler_b(clk, rst, load_out, sel, fir_out_b, out_B);
  // output_filler filler_c(clk, rst, load_out, sel, fir_out_c, out_C);

endmodule
