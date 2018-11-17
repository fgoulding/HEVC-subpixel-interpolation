`define PIXEL_SIZE 5

module  input_array_mux(
  clock,
  reset,
  s,
  so,
  integer_array,
  b_half_array,
  sel,
  mux
 );

  parameter num_pixel = 8;
  input clock;
  input reset;
  input [7:0] s;
  output reg [7:0] so;
  input [1799:0] integer_array;
  input [959:0] b_half_array;
  input [7:0] sel;

  output[119:0] mux;
  reg [119:0] mux;

  wire [7:0] val;
  wire  [119:0] in_buffer [0:14]; //for (4+7)*(4+7) interpolation
  wire  [119:0] in_half_B_buffer [0:8]; //for (4+7)*(4+7) interpolation

  parameter integer_rows = num_pixel+7+1;
  parameter integer_cols = integer_rows + num_pixel;
  // parameter half_a_cols = integer_cols + num_pixel;
  parameter half_b_cols = integer_cols + num_pixel;
  // parameter half_c_cols = half_b_cols + num_pixel;

  assign {in_buffer[14],in_buffer[13],in_buffer[12],in_buffer[11],in_buffer[10],
          in_buffer[9],in_buffer[8],in_buffer[7],in_buffer[6],in_buffer[5],
          in_buffer[4],in_buffer[3],in_buffer[2],in_buffer[1],in_buffer[0]} = integer_array;

  assign {in_half_B_buffer[7],in_half_B_buffer[6],in_half_B_buffer[5],in_half_B_buffer[4],
          in_half_B_buffer[3],in_half_B_buffer[2],in_half_B_buffer[1],in_half_B_buffer[0]} = b_half_array;

  assign val = (sel-integer_rows+3)*8;

  always @(posedge clock)
 	begin: MUX
    so = s;
    if (sel < integer_rows) begin
      //select row from integer_array
      //use case to select row? or just pass an input row somehow?
      mux <= in_buffer[14];
    end
    else if (sel < integer_cols) begin
      mux[7:0] <= in_buffer[0][val +: 8];
      mux[15:8] <= in_buffer[1][val +: 8];
      mux[23:16] <= in_buffer[2][val +: 8];
      mux[31:24] <= in_buffer[3][val +: 8];
      mux[39:32] <= in_buffer[4][val +: 8];
      mux[47:40] <= in_buffer[5][val +: 8];
      mux[55:48] <= in_buffer[6][val +: 8];
      mux[63:56] <= in_buffer[7][val +: 8];
      mux[71:64] <= in_buffer[8][val +: 8];
      mux[79:72] <= in_buffer[9][val +: 8];
      mux[87:80] <= in_buffer[10][val +: 8];
      mux[95:88] <= in_buffer[11][val +: 8];
      mux[103:96] <= in_buffer[12][val +: 8];
      mux[111:104] <= in_buffer[13][val +: 8];
      mux[119:112] <= in_buffer[14][val +: 8];
    //
    // end else if (sel < half_a_cols) begin
    //   mux <= in_half_A_buffer[sel-integer_cols];
    end else if (sel < half_b_cols) begin
      mux <= in_half_B_buffer[sel-integer_cols];
    // end else if (sel < half_c_cols) begin
    //   mux <= in_half_C_buffer[sel-half_b_cols];
    end
    else begin
      mux <= 15'b0;
    end
 	end
 endmodule //End Of Module mux
