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
  
  counter pc(clk, reset, cnt);
  register #(.WIDTH(8)) select(clk, reset, 1'b0, cnt, sel);

  input_array_mux input_mux(clk,reset,in_buffer, temp_A, temp_B, temp_C, sel, currentPixels);

  // genvar i;
  // generate
  //   for (i = 0; i < 8 ; i++) begin : generate_filter_a
  //     FIR_A filter_a(clk,reset, currentPixels[i*sizeofPixel +: 64], any_out_A[i*4sizeOfPixel +:8]);
  //   end
  // endgenerate
  FIR_A filter_a1(clk,reset, currentPixels[0 +:64], fir_out_a[0 +:8]);
  FIR_A filter_a2(clk,reset, currentPixels[8 +:64], fir_out_a[8 +:8]);
  FIR_A filter_a3(clk,reset, currentPixels[16 +:64], fir_out_a[16 +:8]);
  FIR_A filter_a4(clk,reset, currentPixels[24 +:64], fir_out_a[24 +:8]);
  FIR_A filter_a5(clk,reset, currentPixels[32 +:64], fir_out_a[32 +:8]);
  FIR_A filter_a6(clk,reset, currentPixels[40 +:64], fir_out_a[40 +:8]);
  FIR_A filter_a7(clk,reset, currentPixels[48 +:64], fir_out_a[48 +:8]);
  FIR_A filter_a8(clk,reset, currentPixels[56 +:64], fir_out_a[56 +:8]);

  // assign out_A[sel +: 64] = fir_out_a;

  // genvar j;
  //
  // generate
  //   for (j = 0; j < 8 ; j++) begin : generate_filter_b
  //     FIR_B filter_b(currentPixels[i*sizeofPixel:63+i*sizeofPixel], any_out_B[i*sizeOfPixel:7+i*sizeofPixel],clk,reset);
  //   end
  // endgenerate
  //
  FIR_B filter_b1(clk,reset, currentPixels[0 +:64], fir_out_b[0 +:8]);
  FIR_B filter_b2(clk,reset, currentPixels[8 +:64], fir_out_b[8 +:8]);
  FIR_B filter_b3(clk,reset, currentPixels[16 +:64], fir_out_b[16 +:8]);
  FIR_B filter_b4(clk,reset, currentPixels[24 +:64], fir_out_b[24 +:8]);
  FIR_B filter_b5(clk,reset, currentPixels[32 +:64], fir_out_b[32 +:8]);
  FIR_B filter_b6(clk,reset, currentPixels[40 +:64], fir_out_b[40 +:8]);
  FIR_B filter_b7(clk,reset, currentPixels[48 +:64], fir_out_b[48 +:8]);
  FIR_B filter_b8(clk,reset, currentPixels[56 +:64], fir_out_b[56 +:8]);
  // genvar k;
  // generate
  //   for (k = 0; k < 8 ; k++) begin : generate_filter_c
  //     FIR_C filter_c(currentPixels[i*sizeofPixel:63+i*sizeofPixel], any_out_C[i*sizeOfPixel:7+i*sizeofPixel],clk,reset);
  //   end
  // endgenerate
  //

  FIR_C filter_c1(clk,reset, currentPixels[0 +:64], fir_out_c[0 +:8]);
  FIR_C filter_c2(clk,reset, currentPixels[8 +:64], fir_out_c[8 +:8]);
  FIR_C filter_c3(clk,reset, currentPixels[16 +:64], fir_out_c[16 +:8]);
  FIR_C filter_c4(clk,reset, currentPixels[24 +:64], fir_out_c[24 +:8]);
  FIR_C filter_c5(clk,reset, currentPixels[32 +:64], fir_out_c[32 +:8]);
  FIR_C filter_c6(clk,reset, currentPixels[40 +:64], fir_out_c[40 +:8]);
  FIR_C filter_c7(clk,reset, currentPixels[48 +:64], fir_out_c[48 +:8]);
  FIR_C filter_c8(clk,reset, currentPixels[56 +:64], fir_out_c[56 +:8]);

  assign load_L = ~(cnt<(num_pixel+7));

  /*
   * registers to hold the horizontal half pixels
   */
  shift_reg sr_A(clock, reset, load_L, fir_out_a , temp_A);
  shift_reg sr_B(clock, reset, load_L, fir_out_b , temp_B);
  shift_reg sr_C(clock, reset, load_L, fir_out_c , temp_C);

  assign load_out = ~((sel > 2) && (sel < 11)) || ((sel > 14) && (sel < 47));
  output_filler filler_a(clock, reset, load_L, sel, fir_out_a, out_A);
  output_filler filler_b(clock, reset, load_L, sel, fir_out_b, out_B);
  output_filler filler_c(clock, reset, load_L, sel, fir_out_c, out_C);

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

module output_filler(clock, reset_L, load_L, sel, in, out);
  input		clock;
  input		reset_L;
  input load_L;
  input [7:0] sel;
  input [63:0] in;
  output reg [2559:0]	out; //8 rows by 8 cols by 5 pixels by 8 bits
  integer i=0;
  integer j=0;
  reg [63:0] regi [39:0]; //8*8 by 8*5

  always @(posedge clock) begin
    if (reset_L) begin
      for(i=0;i<40;i=i+1) begin
        regi[i] <= 64'b0;
      end
    end
    //make load L check that sel is not 0,1,2 or 11,12,13,14
    //or greater than num of total pixels
    else if (~load_L) begin
      //byte shift register
      if ((sel > 2) && (sel < 11)) begin
        regi[sel-3] <= in;
      end else if (sel > 14) begin
        regi[sel-7] <= in;
      end
    end

    out = {regi[39],regi[38],regi[37],regi[36],regi[35],regi[34],regi[33],regi[32],
          regi[31],regi[30],regi[29],regi[28],regi[27],regi[26],regi[25],regi[24],
          regi[23],regi[22],regi[21],regi[20],regi[19],regi[18],regi[17],regi[16],
          regi[15],regi[14],regi[13],regi[12],regi[11],regi[10],regi[9],regi[8],
          regi[7],regi[6],regi[5],regi[4],regi[3],regi[2],regi[1],regi[0]};
  end

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
