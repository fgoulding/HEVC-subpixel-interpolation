`include "sub_pixel.v"

module tb;
  reg clk, reset;
  reg [55:0] inputPixels;
  reg [7:0] im_memory [0:14][0:14];
  reg [1799:0] integer_array;
  wire [2559:0] A;
  wire [2559:0] B;
  wire [2559:0] C;
  wire [63:0] fir_out_a;
  wire [63:0] fir_out_b;
  wire [63:0] fir_out_c;
  wire [959:0] temp_A;
  wire [959:0] temp_B;
  wire [959:0] temp_C;
  wire [7:0] cnt;
  wire load_out;
  wire [7:0] sel;
  wire [119:0] currentPixels;

  subpixel_interpolation dut(
    .clk(clk),
    .rst(reset),
    .in_buffer(integer_array),
    .out_A(A),
    .out_B(B),
    .out_C(C),
    .cnt(cnt),
    .fir_out_a(fir_out_a),
    .fir_out_b(fir_out_b),
    .fir_out_c(fir_out_c),
    .temp_A(temp_A),
    .temp_B(temp_B),
    .temp_C(temp_C),
    .load_out(load_out),
    .sel(sel),
    .currentPixels(currentPixels)
    );

  integer i;
  integer j;
initial begin
  $monitor({"clk = %b; reset:%h cnt:%h loadOut:%h sel:%h ---\n %h\n %h\nA: \n %h\n %h\n %h\n %h\n %h\n %h\n %h\n %h\n ------\n",
  "D: \n %h\n %h\n %h\n %h\n %h\n %h\n %h\n %h\n ------\n",
   "E: \n %h\n %h\n %h\n %h\n %h\n %h\n %h\n %h\n ------\n",
   "F: \n %h\n %h\n %h\n %h\n %h\n %h\n %h\n %h\n ------\n",
   "G: \n %h\n %h\n %h\n %h\n %h\n %h\n %h\n %h\n ------\n\n"},
  clk,reset,cnt, load_out, sel, currentPixels,fir_out_a,
  A[63:0],
  A[127:64],
  A[191:128],
  A[255:192],
  A[319:256],
  A[383:320],
  A[447:384],
  A[511:448],
  A[575:512],
  A[639:576],
  A[703:640],
  A[767:704],
  A[831:768],
  A[895:832],
  A[959:896],
  A[1023:960],
  A[1087:1024],
  A[1151:1088],
  A[1215:1152],
  A[1279:1216],
  A[1343:1280],
  A[1407:1344],
  A[1471:1408],
  A[1535:1472],
  A[1599:1536],
  A[1663:1600],
  A[1727:1664],
  A[1791:1728],
  A[1855:1792],
  A[1919:1856],
  A[1983:1920],
  A[2047:1984],
  A[2111:2048],
  A[2175:2112],
  A[2239:2176],
  A[2303:2240],
  A[2367:2304],
  A[2431:2368],
  A[2495:2432],
  A[2559:2496]);
  // $monitor({"cnt:%h---\n currentPixels: %h firA: \n %h %h %h %h %h %h %h %h\n ------\n",
  // "%h\n"},
  // cnt, currentPixels,
  // fir_out_a[7:0],fir_out_a[15:8],fir_out_a[23:16],fir_out_a[31:24],
  // fir_out_a[39:32],fir_out_a[47:40], fir_out_a[55:48], fir_out_a[63:56],
  // temp_A);
end

initial begin
  $write("Loading rom...");
  $readmemh("test_image_2.mem", im_memory);

  for (i=0; i<15; i=i+1) begin
    for (j=0; j<15; j=j+1) begin
      integer_array[(8*i)+(j*8*15) +: 8] = im_memory[j][i];
    end
  end
  $display("Done");
  clk = 0;
  reset = 0;
  #130;
  reset = 1;

end


always
  #120 clk = !clk;


initial begin
  // #3700 $finish;
  // #5300 $finish; //A and D finish
  #13500 $finish;

end




endmodule
