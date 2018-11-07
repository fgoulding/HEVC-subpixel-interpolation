`include "library.v"

module tb;
  reg clk, reset;
  reg load;
  reg [63:0] inputPixels;
  reg [7:0] sel;
  reg [7:0] im_memory [0:14][0:14];
  wire [959:0] out;

  shift_reg dut(
    .clock(clk),
    .reset_L(reset),
    .load_L(load),
    .in(inputPixels),
    .out(out)
    );

  integer i;
  integer j;
initial begin
  // $monitor("inputPixels = %h",inputPixels);
  $monitor("%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h\n\n\n",out[119:0],out[239:120],out[359:240],out[479:360],out[599:480],out[719:600],out[839:720],out[959:840]);

end

initial begin
  $write("Loading rom...");
  $readmemh("test_image_3.mem", im_memory);

  $display("Done");


  clk = 0;
  reset = 0;
  #40;
  reset = 1;
  inputPixels = {im_memory[0][7],im_memory[0][6],im_memory[0][5],im_memory[0][4],im_memory[0][3],im_memory[0][2],im_memory[0][1],im_memory[0][0]};
  // $display("inputPixels = %h",inputPixels);

  load = 0;
  #40;
  inputPixels = {im_memory[1][7],im_memory[1][6],im_memory[1][5],im_memory[1][4],im_memory[1][3],im_memory[1][2],im_memory[1][1],im_memory[1][0]};
  // $display("inputPixels = %h",inputPixels);

  load = 0;
  #40;
  inputPixels = {im_memory[2][7],im_memory[2][6],im_memory[2][5],im_memory[2][4],im_memory[2][3],im_memory[2][2],im_memory[2][1],im_memory[2][0]};
  load = 0;
  #40;
  sel = 16;
  #40;
  sel = 15;
  #40;

end


always
  #10 clk = !clk;

initial begin
  #1000 $finish;
end




endmodule
