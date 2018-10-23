
`timescale 1ns / 1ps
module tb;
    reg clk, reset;
  reg [55:0] inputPixels;
  wire [7:0] subPixel;
  reg [7:0] im_memory [0:14][0:14];
  wire [7:0] mux_out [0:14];

  reg [23:0] data [0:3];
// module subpixel_interpolation(clk,reset, im_memory,
//                               out_A, out_B, out_C, out_buffer);// FIR_A dut(inputPixels,subPixel,clk,reset);

initial begin
 $display("out_a=%h\n",mux_out[0]);
 $strobe("asdf`=%h\n",mux_out[1]);
 $monitor("as=%h\n",mux_out[2]);
 $monitor("f=%h\n",mux_out[3]);
 $monitor("d=%h\n",mux_out[4]);
 // $monitor("f=%h\n",mux_out[5]);

 // $monitor("out_a=%h\n",im_memory);
 // $monitor("image=%h\n",im_memory);
 // $monitor("image=%h\n",im_memory);

end
initial begin
  $display("Loading rom.");
  $readmemh("test_image.mem", im_memory);
  clk = 0;
  reset = 1;
  #1;
  reset = 0;
  #1;
  // mux_out = im_memory[0][0:14];

end

assign mux_out[0] = im_memory[0][1];
assign mux_out[1] = im_memory[1][1];
assign mux_out[2] = im_memory[2][1];
assign mux_out[3] = im_memory[3][1];
assign mux_out[4] = im_memory[4][1];
assign mux_out[5] = im_memory[5][1];
assign mux_out[6] = im_memory[6][1];

always
  #5 clk = !clk;
// $finish

endmodule


// module tb;
//     reg clk, reset;
//   reg [55:0] inputPixels;
//   wire [7:0] subPixel;

//     FIR_A dut(inputPixels,subPixel,clk,reset);

// initial begin
//   $monitor("monitor subpixel:%h", subPixel);
//   clk = 0;
//   reset = 1;
//   #1;
//   reset = 0;
//   #1
//   inputPixels[7:0] = 8'b0;
//   inputPixels[15:8] = 8'b1;
//   inputPixels[23:16] = 8'b10;
//   inputPixels[31:24] = 8'b11;
//   inputPixels[39:32] = 8'b101;
//   inputPixels[47:40] = 8'b00000111;
//   inputPixels[55:48] = 8'b100;
//   #5;

// end

// always
//   #5 clk = !clk;
// // /$finish

// endmodule
