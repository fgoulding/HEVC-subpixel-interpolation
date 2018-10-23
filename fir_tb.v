`include "input_mux.v"

module tb;
  reg clk, reset;
  reg [55:0] inputPixels;
  reg [7:0] sel;
  reg [7:0] im_memory [0:14][0:14];
  reg [1799:0] integer_array;
  reg [959:0] a_half_array;
  reg [959:0] b_half_array;
  reg [959:0] c_half_array;
  wire [119:0] mux_out;

  input_array_mux dut (
    .clock(clk),
    .reset(reset),
    .integer_array(integer_array),
    .a_half_array(a_half_array),
    .b_half_array(b_half_array),
    .c_half_array(c_half_array),
    .sel(sel),
    .mux(mux_out)
   );
  integer i;
  integer j;
initial begin
  $monitor("mux_out = %h",mux_out);
end

initial begin
  $write("Loading rom...");
  $readmemh("test_image_2.mem", im_memory);

  for (i=0; i<15; i=i+1) begin
    for (j=0; j<15; j=j+1) begin
      integer_array[(8*i)+(j*8*15) +: 8] = im_memory[j][i];
    end
  end

  //
  // integer_array = {im_memory[14], im_memory[13], im_memory[12], im_memory[11], im_memory[10], im_memory[9], im_memory[8], im_memory[7],
  //                  im_memory[6], im_memory[5], im_memory[4], im_memory[3], im_memory[2], im_memory[1], im_memory[0]};
  $display("Done");


  clk = 0;
  reset = 1;
  #10;
  reset = 0;
  sel = 0;
  #10;
  sel = 1;
  #10;
  sel = 2;
  #10;
  sel = 16;
  #10;
  sel = 15;
  #10;

end


always
  #2 clk = !clk;

initial begin
  #1000000 $finish;
end




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
