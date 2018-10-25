`include "library.v"
`include "input_mux.v"
`include "fir.v"

/**********************
 *
 * subpixel_interpolation - top-level module that interpolates a array of subpixels
 *
 **********************/

module subpixel_interpolation(clk,rst, in_buffer,
                              out_A, out_B, out_C);
  parameter num_pixel = 8;
  parameter sizeofPixel = 8;
  input clk;
  input rst;
  input  [1799:0] in_buffer; //for (4+7)*(4+7) interpolation
  output [2559:0] out_A; //feedback buffer
  output [2559:0] out_B; //feedback buffer
  output [2559:0] out_C; //feedback buffer
  // reg [959:0] out_A; //feedback buffer
  // reg [959:0] out_B; //feedback buffer
  // reg [959:0] out_C; //feedback buffer
  /////////////////////////////

  wire [119:0] currentPixels;

  /////////////////////////////
  wire [7:0] sel;
  wire [7:0] sel2;
  wire [7:0] s;
  wire [7:0] so;
  wire [7:0] val;
  wire [7:0] cnt;
  // new inputs from outputs of last cycle
  wire [959:0] temp_A;
  wire [959:0] temp_B;
  wire [959:0] temp_C;

  wire [63:0] fir_out_a;
  wire [63:0] fir_out_b;
  wire [63:0] fir_out_c;
  wire load_out,load_L;

  counter pc(clk, rst, cnt);
  register #(.WIDTH(8)) select(clk, rst, 1'b0, cnt, sel);
  register #(.WIDTH(8)) select2(clk, rst, 1'b0, sel, sel2);

  input_array_mux input_mux(clk,rst,cnt,s,in_buffer, temp_A, temp_B, temp_C, cnt, currentPixels);

  // genvar i;
  // generate
  //   for (i = 0; i < 8 ; i++) begin : generate_filter_a
  //     FIR_A filter_a(clk,rst, currentPixels[i*sizeofPixel +: 64], any_out_A[i*4sizeOfPixel +:8]);
  //   end
  // endgenerate
  FIR_A filter_a1(clk,rst,s, so, currentPixels[0 +:64], fir_out_a[0 +:8]);
  FIR_A filter_a2(clk,rst,s, so, currentPixels[8 +:64], fir_out_a[8 +:8]);
  FIR_A filter_a3(clk,rst,s, so, currentPixels[16 +:64], fir_out_a[16 +:8]);
  FIR_A filter_a4(clk,rst,s, so, currentPixels[24 +:64], fir_out_a[24 +:8]);
  FIR_A filter_a5(clk,rst,s, so, currentPixels[32 +:64], fir_out_a[32 +:8]);
  FIR_A filter_a6(clk,rst,s, so, currentPixels[40 +:64], fir_out_a[40 +:8]);
  FIR_A filter_a7(clk,rst,s, so, currentPixels[48 +:64], fir_out_a[48 +:8]);
  FIR_A filter_a8(clk,rst,s, so, currentPixels[56 +:64], fir_out_a[56 +:8]);

  // assign out_A[sel +: 64] = fir_out_a;

  // genvar j;
  //
  // generate
  //   for (j = 0; j < 8 ; j++) begin : generate_filter_b
  //     FIR_B filter_b(currentPixels[i*sizeofPixel:63+i*sizeofPixel], any_out_B[i*sizeOfPixel:7+i*sizeofPixel],clk,rst);
  //   end
  // endgenerate
  //
  FIR_B filter_b1(clk,rst, currentPixels[0 +:64], fir_out_b[0 +:8]);
  FIR_B filter_b2(clk,rst, currentPixels[8 +:64], fir_out_b[8 +:8]);
  FIR_B filter_b3(clk,rst, currentPixels[16 +:64], fir_out_b[16 +:8]);
  FIR_B filter_b4(clk,rst, currentPixels[24 +:64], fir_out_b[24 +:8]);
  FIR_B filter_b5(clk,rst, currentPixels[32 +:64], fir_out_b[32 +:8]);
  FIR_B filter_b6(clk,rst, currentPixels[40 +:64], fir_out_b[40 +:8]);
  FIR_B filter_b7(clk,rst, currentPixels[48 +:64], fir_out_b[48 +:8]);
  FIR_B filter_b8(clk,rst, currentPixels[56 +:64], fir_out_b[56 +:8]);
  // genvar k;
  // generate
  //   for (k = 0; k < 8 ; k++) begin : generate_filter_c
  //     FIR_C filter_c(currentPixels[i*sizeofPixel:63+i*sizeofPixel], any_out_C[i*sizeOfPixel:7+i*sizeofPixel],clk,rst);
  //   end
  // endgenerate
  //

  FIR_C filter_c1(clk,rst, currentPixels[0 +:64], fir_out_c[0 +:8]);
  FIR_C filter_c2(clk,rst, currentPixels[8 +:64], fir_out_c[8 +:8]);
  FIR_C filter_c3(clk,rst, currentPixels[16 +:64], fir_out_c[16 +:8]);
  FIR_C filter_c4(clk,rst, currentPixels[24 +:64], fir_out_c[24 +:8]);
  FIR_C filter_c5(clk,rst, currentPixels[32 +:64], fir_out_c[32 +:8]);
  FIR_C filter_c6(clk,rst, currentPixels[40 +:64], fir_out_c[40 +:8]);
  FIR_C filter_c7(clk,rst, currentPixels[48 +:64], fir_out_c[48 +:8]);
  FIR_C filter_c8(clk,rst, currentPixels[56 +:64], fir_out_c[56 +:8]);

  assign load_L = !(so<(num_pixel+8));

  /*
   * registers to hold the horizontal half pixels
   */
  shift_reg sr_A(clk, rst, load_L, fir_out_a , temp_A);
  shift_reg sr_B(clk, rst, load_L, fir_out_b , temp_B);
  shift_reg sr_C(clk, rst, load_L, fir_out_c , temp_C);

  assign load_out = !(((so > 2) && (so < 12)) || ((so > 14) && (so < 48)));
  output_filler filler_a(clk, rst, load_out, sel, fir_out_a, out_A);
  output_filler filler_b(clk, rst, load_out, sel, fir_out_b, out_B);
  output_filler filler_c(clk, rst, load_out, sel, fir_out_c, out_C);

endmodule
