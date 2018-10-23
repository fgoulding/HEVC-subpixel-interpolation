/**********************
 *
 * subpixel_interpolation - top-level module that interpolates a array of subpixels
 *   
 *
 **********************/

module subpixel_interpolation(clk,reset, in_buffer,
                              out_A, out_B, out_C, out_buffer);
  parameter num_pixel = 8;
  parameter sizeofPixel = 8;
  input clk;
  input reset;
  input  [7:0] in_buffer [0:(num_pixel+7)-1][0:(num_pixel+7)-1]; //for (4+7)*(4+7) interpolation
  output [7:0] out_A [0:(num_pixel+7)-1][0:num_pixel-1]; //feedback buffer
  output [7:0] out_B [0:(num_pixel+7)-1][0:num_pixel-1]; //feedback buffer
  output [7:0] out_C [0:(num_pixel+7)-1][0:num_pixel-1]; //feedback buffer 
  output [127:0] out_buffer [0:(num_pixel-1)][0:(num_pixel-1)]; //for inner 4*4 only. 4*16 values per pixel 
  
  // new inputs from outputs of last cycle
  wire [7:0] temp_A [0:(num_pixel+7)-1][0:num_pixel-1];
  wire [7:0] temp_B [0:(num_pixel+7)-1][0:num_pixel-1];
  wire [7:0] temp_C [0:(num_pixel+7)-1][0:num_pixel-1];
  
  // intermediate output buffers for the FIRs
  wire [7:0] any_out_A [0:(num_pixel+7)-1][0:num_pixel-1]; 
  wire [7:0] any_out_B [0:(num_pixel+7)-1][0:num_pixel-1];
  wire [7:0] any_out_C [0:(num_pixel+7)-1][0:num_pixel-1];
  
  //apply FIR_A, FIR_B, FIR_C on 
  register A(clk, reset, out_A, temp_A);
  register B(clk, reset, out_B, temp_B);
  register C(clk, reset, out_C, temp_C);
  counter pc(clk, reset, cnt);
  register select(clk, reset, cnt, sel);
  
  // row_select sel_modulo(clk, reset, sel, row); //select which row based on some modulo of counter (sel)
  input_array_mux input_mux(in_buffer, temp_A, temp_B, temp_C, sel, row, inputPixels);
  
  genvar i; 
  generate        
    for (i = 0; i < 8 ; i++) begin : generate_filter_a     
      FIR_A filter_a(inputPixels[i*sizeofPixel:63+i*sizeofPixel], any_out_A[i*sizeOfPixel:7+i*sizeofPixel],clk,reset);
    end
  endgenerate 
  genvar j; 

  generate        
    for (j = 0; j < 8 ; j++) begin : generate_filter_b      
      FIR_B filter_b(inputPixels[i*sizeofPixel:63+i*sizeofPixel], any_out_B[i*sizeOfPixel:7+i*sizeofPixel],clk,reset);
    end
  endgenerate

  genvar k; 
  generate        
    for (k = 0; k < 8 ; k++) begin : generate_filter_c    
      FIR_C filter_c(inputPixels[i*sizeofPixel:63+i*sizeofPixel], any_out_C[i*sizeOfPixel:7+i*sizeofPixel],clk,reset);
    end
  endgenerate 
      
  // outputMux(any_out_A,any_out_B,any_out_C, temp_A, temp_B, temp_C,
            // sel, clk, reset, out_A, out_B, outr_C, out_buffer);
      
endmodule 


module outputMux(
  any_in_a,
  any_in_b,
  any_in_c,
  in_a,
  in_b,
  in_c,
  sel,
  start_index,
  clk,
  reset,
  out_a,
  out_b,
  out_c,
  out
	);
   
  parameter num_pixel = 8;
  input [7:0] any_out_A [0:(num_pixel+7)-1][0:num_pixel-1]; 
  input [7:0] any_out_B [0:(num_pixel+7)-1][0:num_pixel-1];
  input [7:0] any_out_C [0:(num_pixel+7)-1][0:num_pixel-1];
  input [7:0] in_a [0:(num_pixel+7)-1][0:num_pixel-1]; 
  input [7:0] in_b [0:(num_pixel+7)-1][0:num_pixel-1];
  input [7:0] in_c [0:(num_pixel+7)-1][0:num_pixel-1];
  input [7:0] sel;
  input [7:0] start_index;
  output [7:0] out_a [0:(num_pixel+7)-1][0:num_pixel-1]; //feedback buffer
  output [7:0] out_a [0:(num_pixel+7)-1][0:num_pixel-1]; //feedback buffer
  output [7:0] out_c [0:(num_pixel+7)-1][0:num_pixel-1]; //feedback buffer 
  output [127:0] out [0:(num_pixel-1)][0:(num_pixel-1)]; 
  
  reg [7:0] out_a [0:(num_pixel+7)-1][0:num_pixel-1]; 
  reg [7:0] out_a [0:(num_pixel+7)-1][0:num_pixel-1]; 
  reg [7:0] out_c [0:(num_pixel+7)-1][0:num_pixel-1];  
  reg [127:0] out [0:(num_pixel-1)][0:(num_pixel-1)]; 
  
  parameter integer_rows = num_pixel+7;
  parameter integer_cols = (num_pixel+7)*2
  parameter half_a_cols = integer_cols + num_pixel
  parameter half_b_cols = integer_cols + num_pixel*2
  parameter half_c_cols = integer_cols + num_pixel*3
  	
  always @(posedge clock or posedge reset)
 	begin: MUX
    if (sel < integer_rows) begin
      out_a <= any_out_A;
      out_b <= any_out_B;
      out_c <= any_out_C;
      //and out <= some conct. of any_out_A, any_out_B, any_out_C based on start_index.
    end else if (sel < integer_cols) begin
      out_a <= in_a;
      out_b <= in_b;
      out_c <= in_c;
      //and out <= some conct. of any_out_A, any_out_B, any_out_C based on start_index.
    end else if (sel < half_a_cols) begin
      out_a <= in_a;
      out_b <= in_b;
      out_c <= in_c;
      //and out <= some conct. of any_out_A, any_out_B, any_out_C based on start_index.
    end else if (sel < half_b_cols) begin
      out_a <= in_a;
      out_b <= in_b;
      out_c <= in_c;
      //and out <= some conct. of any_out_A, any_out_B, any_out_C based on start_index.
    end else if (sel < half_c_cols) begin
      out_a <= in_a;
      out_b <= in_b;
      out_c <= in_c;
      //and out <= some conct. of any_out_A, any_out_B, any_out_C based on start_index.
    end else begin
      out_a <= in_a;
      out_b <= in_b;
      out_c <= in_c;
      out <= 0; 
 	end
 endmodule //End Of Module mux

endmodule

module  input_array_mux(
  integer_array, 
  a_half_array,
  b_half_array,
  c_half_array,
  sel, 
  mux_out   
 );
 
  parameter num_pixel = 8;
  input [7:0] integer_array [0:(num_pixel+7)-1][0:(num_pixel+7)-1];
  input [7:0] a_half_array [0:(num_pixel+7)-1][0:num_pixel-1];
  input [7:0] b_half_array [0:(num_pixel+7)-1][0:num_pixel-1];
  input [7:0] c_half_array [0:(num_pixel+7)-1][0:num_pixel-1];
  input [7:0] sel;
  input [7:0] row;
  output[7:0] mux_out[(num_pixel+7)-1:0];
  reg  	[7:0] mux_out[(num_pixel+7)-1:0];
  parameter integer_rows = num_pixel+7;
  parameter integer_cols = (num_pixel+7)*2
  parameter half_a_cols = integer_cols + num_pixel
  parameter half_b_cols = integer_cols + num_pixel*2
  parameter half_c_cols = integer_cols + num_pixel*3
  	
  always @(posedge clock or posedge reset)
 	begin: MUX
=    if (sel < integer_rows) begin
      //select row from integer_array 
      //use case to select row? or just pass an input row somehow?
      mux_out <= integer_array[row];
    end else if (sel < integer_cols) begin
      mux_out[0] <= integer_array[0][sel-integer_rows]; //or transpose
      mux_out[1] <= integer_array[1][sel-integer_rows]; //or transpose
      mux_out[2] <= integer_array[2][sel-integer_rows]; //or transpose
      mux_out[3] <= integer_array[3][sel-integer_rows]; //or transpose
      mux_out[4] <= integer_array[4][sel-integer_rows]; //or transpose
      mux_out[5] <= integer_array[5][sel-integer_rows]; //or transpose
      mux_out[6] <= integer_array[6][sel-integer_rows]; //or transpose
      mux_out[7] <= integer_array[7][sel-integer_rows]; //or transpose
      mux_out[8] <= integer_array[8][sel-integer_rows]; //or transpose
      mux_out[9] <= integer_array[9][sel-integer_rows]; //or transpose
      mux_out[10] <= integer_array[10][sel-integer_rows]; //or transpose
      mux_out[11] <= integer_array[11][sel-integer_rows]; //or transpose
      mux_out[12] <= integer_array[12][sel-integer_rows]; //or transpose
      mux_out[13] <= integer_array[13][sel-integer_rows]; //or transpose
      mux_out[14] <= integer_array[14][sel-integer_rows]; //or transpose

    end else if (sel < half_a_cols) begin
      mux_out <= half_a_array[sel - integer_rows - integer_cols - half_a_cols];
    end else if (sel < half_b_cols) begin
      mux_out <= half_b_array[sel - integer_rows - integer_cols - half_a_cols];
    end else if (sel < half_c_cols) begin
      mux_out <= half_c_array[sel - integer_rows - integer_cols - half_a_cols - half_b_cols];
    end else begin
      mux_out <= {(8*num_pixel+7){1'b0}}; 
 	end
 endmodule //End Of Module mux

    
// module shift_array(clk, reset, inputPixels, startIndex, outputPixels);
//   parameter num_pixel = 8;
//   input clk;
//   input reset;
//   input [((num_pixel+7)*8)-1:0] inputPixels;
//   input [7:0] startIndex; 
//   output [63:0] outputPixels;

//   always @(posedge clock)
  
  
// endmodule 
    
module FIR_A(inputPixels, subPixel,clock,reset);
  input [63:0] inputPixels; // flattened input pixels
  input clock;
  input reset;
  output reg[7:0] subPixel;  
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

module FIR_B(inputPixels, subPixel, clock, reset);
  input [63:0] inputPixels; // flattened input pixels
  output [7:0] subPixel;
  
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

module FIR_C(inputPixels, subPixel, clock, reset);
  input [63:0] inputPixels; // flattened input pixels
  output [7:0] subPixel;
  
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
  

module tb;
  reg clk, reset;
  reg [55:0] inputPixels;
  wire [7:0] subPixel;

  FIR_A dut(inputPixels,subPixel,clk,reset);

initial begin
  $monitor("monitor subpixel:%h", subPixel);
  clk = 0;
  reset = 1;
  #1;
  reset = 0;
  #1
  inputPixels[7:0] = 8'b0;
  inputPixels[15:8] = 8'b1;
  inputPixels[23:16] = 8'b10;
  inputPixels[31:24] = 8'b11;
  inputPixels[39:32] = 8'b101;
  inputPixels[47:40] = 8'b00000111;
  inputPixels[55:48] = 8'b100;
  #5;
s
end

always
  #5 clk = !clk;
// /$finish

endmodule

