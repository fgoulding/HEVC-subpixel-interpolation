`include "input_mux.v"

/**********************
 *
 * subpixel_interpolation - top-level module that interpolates a array of subpixels
 *
 **********************/

module subpixel_interpolation(clk,reset, in_buffer,
                              out_A, out_B, out_C, out_buffer);
  parameter num_pixel = 8;
  parameter sizeofPixel = 8;
  input clk;
  input reset;
  input  [1799:0] in_buffer; //for (4+7)*(4+7) interpolation
  output [959:0] out_A; //feedback buffer
  output [959:0] out_B; //feedback buffer
  output [959:0] out_C; //feedback buffer

  // reg [959:0] out_A; //feedback buffer
  // reg [959:0] out_B; //feedback buffer
  // reg [959:0] out_C; //feedback buffer
  /////////////////////////////
  output [511:0] out_buffer;
  reg [511:0] out_buffer;
  wire [119:0] currentPixels;

  /////////////////////////////
  wire [7:0] sel;
  wire [7:0] cnt;
  // new inputs from outputs of last cycle
  wire [959:0] temp_A;
  wire [959:0] temp_B;
  wire [959:0] temp_C;

  // intermediate output buffers for the FIRs
  wire [959:0] any_out_A;
  wire [959:0] any_out_B;
  wire [959:0] any_out_C;

  register #(.WIDTH(960)) A(clk, reset, 1'b0,out_A, temp_A);

  register #(.WIDTH(960)) B(clk, reset, 1'b0,out_B, temp_B);
  register #(.WIDTH(960)) C(clk, reset, 1'b0,out_C, temp_C);
  counter pc(clk, reset, cnt);
  register #(.WIDTH(8)) select(clk, reset, 1'b0, cnt, sel);

  // row_select sel_modulo(clk, reset, sel, row); //select which row based on some modulo of counter (sel)
  input_array_mux input_mux(clk,reset,in_buffer, temp_A, temp_B, temp_C, sel, currentPixels);

  // genvar i;
  // generate
  //   for (i = 0; i < 8 ; i++) begin : generate_filter_a
  //     FIR_A filter_a(clk,reset, currentPixels[i*sizeofPixel +: 64], any_out_A[i*4sizeOfPixel +:8]);
  //   end
  // endgenerate
  FIR_A filter_a1(clk,reset, currentPixels[0 +:64], any_out_A[0 +:8]);
  FIR_A filter_a2(clk,reset, currentPixels[8 +:64], any_out_A[8 +:8]);
  FIR_A filter_a3(clk,reset, currentPixels[16 +:64], any_out_A[16 +:8]);
  FIR_A filter_a4(clk,reset, currentPixels[24 +:64], any_out_A[24 +:8]);
  FIR_A filter_a5(clk,reset, currentPixels[32 +:64], any_out_A[32 +:8]);
  FIR_A filter_a6(clk,reset, currentPixels[40 +:64], any_out_A[40 +:8]);
  FIR_A filter_a7(clk,reset, currentPixels[48 +:64], any_out_A[48 +:8]);
  FIR_A filter_a8(clk,reset, currentPixels[56 +:64], any_out_A[56 +:8]);
  // genvar j;
  //
  // generate
  //   for (j = 0; j < 8 ; j++) begin : generate_filter_b
  //     FIR_B filter_b(currentPixels[i*sizeofPixel:63+i*sizeofPixel], any_out_B[i*sizeOfPixel:7+i*sizeofPixel],clk,reset);
  //   end
  // endgenerate
  //
  FIR_B filter_b1(clk,reset, currentPixels[0 +:64], any_out_B[0 +:8]);
  FIR_B filter_b2(clk,reset, currentPixels[8 +:64], any_out_B[8 +:8]);
  FIR_B filter_b3(clk,reset, currentPixels[16 +:64], any_out_B[16 +:8]);
  FIR_B filter_b4(clk,reset, currentPixels[24 +:64], any_out_B[24 +:8]);
  FIR_B filter_b5(clk,reset, currentPixels[32 +:64], any_out_B[32 +:8]);
  FIR_B filter_b6(clk,reset, currentPixels[40 +:64], any_out_B[40 +:8]);
  FIR_B filter_b7(clk,reset, currentPixels[48 +:64], any_out_B[48 +:8]);
  FIR_B filter_b8(clk,reset, currentPixels[56 +:64], any_out_B[56 +:8]);
  // genvar k;
  // generate
  //   for (k = 0; k < 8 ; k++) begin : generate_filter_c
  //     FIR_C filter_c(currentPixels[i*sizeofPixel:63+i*sizeofPixel], any_out_C[i*sizeOfPixel:7+i*sizeofPixel],clk,reset);
  //   end
  // endgenerate
  //

  FIR_C filter_c1(clk,reset, currentPixels[0 +:64], any_out_C[0 +:8]);
  FIR_C filter_c2(clk,reset, currentPixels[8 +:64], any_out_C[8 +:8]);
  FIR_C filter_c3(clk,reset, currentPixels[16 +:64], any_out_C[16 +:8]);
  FIR_C filter_c4(clk,reset, currentPixels[24 +:64], any_out_C[24 +:8]);
  FIR_C filter_c5(clk,reset, currentPixels[32 +:64], any_out_C[32 +:8]);
  FIR_C filter_c6(clk,reset, currentPixels[40 +:64], any_out_C[40 +:8]);
  FIR_C filter_c7(clk,reset, currentPixels[48 +:64], any_out_C[48 +:8]);
  FIR_C filter_c8(clk,reset, currentPixels[56 +:64], any_out_C[56 +:8]);

  assign out_A = any_out_A;
  assign out_B = any_out_B;
  assign out_C = any_out_C;

  // // outputMux(any_out_A,any_out_B,any_out_C, temp_A, temp_B, temp_C,
  //           // sel, clk, reset, out_A, out_B, outr_C, out_buffer);

endmodule

module FIR_A(clock, reset, inputPixels, subPixel);

  input [63:0] inputPixels; // flattened input pixels
  input clock;
  input reset;
  output [7:0] subPixel;
  reg [7:0] subPixel;
  parameter c1 = -1; parameter c2 = 4; parameter c3 = -10;
  parameter c4 = 58; parameter c5 = 17; parameter c6 = -5;
  parameter c7 = 1;

  always @(posedge clock or posedge reset)
  begin
    if(reset)
      begin
        subPixel = 8'b0;
      end
    else
      begin
        subPixel = (c1*inputPixels[7:0] + c2*inputPixels[15:8] + c3*inputPixels[23:16] + c4*inputPixels[31:24] +
                    c5*inputPixels[39:32] + c6*inputPixels[47:40] + c7*inputPixels[55:48])/64;
      end
  end

endmodule

module FIR_B( clock, reset, inputPixels, subPixel);
  input clock;
  input reset;
  input [63:0] inputPixels; // flattened input pixels
  output [7:0] subPixel;
  reg [7:0] subPixel;
  parameter c1 = -1; parameter c2 = 4; parameter c3 = -11;
  parameter c4 = 40; parameter c5 = 40; parameter c6 = -11;
  parameter c7 = 4 ; parameter c8 = -1;

  always @(posedge clock or posedge reset)
  begin
    if(reset)
      begin
        subPixel = 8'b0;
      end
    else
      begin
				subPixel = (c1*inputPixels[7:0] + c2*inputPixels[15:8] + c3*inputPixels[23:16] + c4*inputPixels[31:24] +
                    c5*inputPixels[39:32] + c6*inputPixels[47:40] + c7*inputPixels[55:48] + c8*inputPixels[63:56])/64;
      end
  end

endmodule

module FIR_C(clock, reset, inputPixels, subPixel);
  input clock;
  input reset;
  input [63:0] inputPixels; // flattened input pixels
  output [7:0] subPixel;
  reg [7:0] subPixel;
  parameter c1 =  1; parameter c2 = -5; parameter c3 = 17;
  parameter c4 = 58; parameter c5 = -10; parameter c6 = 4;
  parameter c7 = -1;

  always @(posedge clock or posedge reset)
  begin
    if(reset)
      begin
        subPixel = 8'b0;
      end
    else
      begin
				subPixel = (c1*inputPixels[7:0] + c2*inputPixels[15:8] + c3*inputPixels[23:16] + c4*inputPixels[31:24] +
                    c5*inputPixels[39:32] + c6*inputPixels[47:40] + c7*inputPixels[55:48])/64;
      end
  end

endmodule

/*
 * module: register
 *
 * A positive-edge clocked parameterized register with (active low) load enable
 * and asynchronous reset. The parameter is the bit-width of the register.
 */
module register (
  clock,
  reset_L,
  load_L,
  in,
  out
   );
   parameter WIDTH = 960;
   input [WIDTH-1:0] in;
   input load_L;
   input clock;
   input reset_L;
   output reg [WIDTH-1:0] out;

   always @ (posedge clock, negedge reset_L) begin
      if(~reset_L)
         out <= 'h0000;
      else if (~load_L)
         out <= in;
   end
endmodule

module counter (clk, reset, cnt);
  input		clk;
  input		reset;
  output	[7:0]	cnt;
  reg	[7:0]	cnt;

  always @(posedge clk)
    if (!reset)
      cnt = cnt + 1;
    else
      cnt = 0;

endmodule

//
// //
// // module outputMux(
// //   any_in_a,
// //   any_in_b,
// //   any_in_c,
// //   in_a,
// //   in_b,
// //   in_c,
// //   sel,
// //   start_index,
// //   clk,
// //   reset,
// //   out_a,
// //   out_b,
// //   out_c,
// //   out
// // 	);
// //
// //   parameter num_pixel = 8;
// //   input [7:0] any_out_A [0:(num_pixel+7)-1][0:num_pixel-1];
// //   input [7:0] any_out_B [0:(num_pixel+7)-1][0:num_pixel-1];
// //   input [7:0] any_out_C [0:(num_pixel+7)-1][0:num_pixel-1];
// //   input [7:0] in_a [0:(num_pixel+7)-1][0:num_pixel-1];
// //   input [7:0] in_b [0:(num_pixel+7)-1][0:num_pixel-1];
// //   input [7:0] in_c [0:(num_pixel+7)-1][0:num_pixel-1];
// //   input [7:0] sel;
// //   input [7:0] start_index;
// //   output [7:0] out_a [0:(num_pixel+7)-1][0:num_pixel-1]; //feedback buffer
// //   output [7:0] out_a [0:(num_pixel+7)-1][0:num_pixel-1]; //feedback buffer
// //   output [7:0] out_c [0:(num_pixel+7)-1][0:num_pixel-1]; //feedback buffer
// //   output [127:0] out [0:(num_pixel-1)][0:(num_pixel-1)];
// //
// //   reg [7:0] out_a [0:(num_pixel+7)-1][0:num_pixel-1];
// //   reg [7:0] out_a [0:(num_pixel+7)-1][0:num_pixel-1];
// //   reg [7:0] out_c [0:(num_pixel+7)-1][0:num_pixel-1];
// //   reg [127:0] out [0:(num_pixel-1)][0:(num_pixel-1)];
// //
// //   parameter integer_rows = num_pixel+7;
// //   parameter integer_cols = (num_pixel+7)*2
// //   parameter half_a_cols = integer_cols + num_pixel
// //   parameter half_b_cols = integer_cols + num_pixel*2
// //   parameter half_c_cols = integer_cols + num_pixel*3
// //
// //   always @(posedge clock or posedge reset)
// //  	begin: MUX
// //     if (sel < integer_rows) begin
// //       out_a <= any_out_A;
// //       out_b <= any_out_B;
// //       out_c <= any_out_C;
// //       //and out <= some conct. of any_out_A, any_out_B, any_out_C based on start_index.
// //     end else if (sel < integer_cols) begin
// //       out_a <= in_a;
// //       out_b <= in_b;
// //       out_c <= in_c;
// //       //and out <= some conct. of any_out_A, any_out_B, any_out_C based on start_index.
// //     end else if (sel < half_a_cols) begin
// //       out_a <= in_a;
// //       out_b <= in_b;
// //       out_c <= in_c;
// //       //and out <= some conct. of any_out_A, any_out_B, any_out_C based on start_index.
// //     end else if (sel < half_b_cols) begin
// //       out_a <= in_a;
// //       out_b <= in_b;
// //       out_c <= in_c;
// //       //and out <= some conct. of any_out_A, any_out_B, any_out_C based on start_index.
// //     end else if (sel < half_c_cols) begin
// //       out_a <= in_a;
// //       out_b <= in_b;
// //       out_c <= in_c;
// //       //and out <= some conct. of any_out_A, any_out_B, any_out_C based on start_index.
// //     end else begin
// //       out_a <= in_a;
// //       out_b <= in_b;
// //       out_c <= in_c;
// //       out <= 0;
// //  	end
// //  endmodule //End Of Module mux
// //
// //
