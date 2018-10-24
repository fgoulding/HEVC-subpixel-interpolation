`include "library.v"

module tb;
  reg clk, reset;
  reg load;
  reg [63:0] inputPixels;
  reg [7:0] sel;
  wire [7:0] cnt;

  counter dut(
    .clk(clk),
    .reset_L(reset),
    .cnt(cnt)
    );

  integer i;
  integer j;
initial begin
  // $monitor("inputPixels = %h",inputPixels);
  $monitor("%h\n", cnt);

end

initial begin
  clk = 0;
  reset = 0;
  #40;
  reset = 1;


end


always
  #2 clk = !clk;

initial begin
  #10000 $finish;
end




endmodule
