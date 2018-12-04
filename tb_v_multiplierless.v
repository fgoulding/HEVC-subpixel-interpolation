`include "sub_pixel_multiplierless.v"

module tb;
  reg clk, reset;
  reg [55:0] inputPixels;
  reg [7:0] im_memory [0:14][0:14];
  reg [119:0] im_rows [0:14];
  wire [119:0] input_row;
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
  wire [63:0] next_row;

  subpixel_interpolation dut(
    .clk(clk),
    .rst(reset),
    .in_row(input_row),
    .next_row(next_row),
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

  assign input_row = im_rows[next_row];

  integer i;
  integer j;
  integer f_a;
  integer f_b;
  integer f_c;
initial begin
  f_a = $fopen("output/output_paris_red_2_a_multiplierless.txt");
  f_b = $fopen("output/output_paris_red_2_b_multiplierless.txt");
  f_c = $fopen("output/output_paris_red_2_c_multiplierless.txt");
  $monitor({"clk = %b; next_row = %d;  reset:%h cnt:%h loadOut:%h sel:%h ---\n",
  "%h\n",
  "%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h\n------\n",
  "%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h\n------\n",
  "%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h\n------\n",
   "%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h\n------\n",
   "%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h\n------\n",
   "%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h\n------\n\n"},
  clk,next_row,reset,cnt, load_out, sel, input_row,fir_out_c,
  temp_C[119:0],
  temp_C[239:120],
  temp_C[359:240],
  temp_C[479:360],
  temp_C[599:480],
  temp_C[719:600],
  temp_C[839:720],
  temp_C[959:840],
  C[63:0],
  C[127:64],
  C[191:128],
  C[255:192],
  C[319:256],
  C[383:320],
  C[447:384],
  C[511:448],
  C[575:512],
  C[639:576],
  C[703:640],
  C[767:704],
  C[831:768],
  C[895:832],
  C[959:896],
  C[1023:960],
  C[1087:1024],
  C[1151:1088],
  C[1215:1152],
  C[1279:1216],
  C[1343:1280],
  C[1407:1344],
  C[1471:1408],
  C[1535:1472],
  C[1599:1536],
  C[1663:1600],
  C[1727:1664],
  C[1791:1728],
  C[1855:1792],
  C[1919:1856],
  C[1983:1920],
  C[2047:1984],
  C[2111:2048],
  C[2175:2112],
  C[2239:2176],
  C[2303:2240],
  C[2367:2304],
  C[2431:2368],
  C[2495:2432],
  C[2559:2496]);
  // $monitor({"cnt:%h---\n currentPixels: %h firA: \n %h %h %h %h %h %h %h %h\n ------\n",
  // "%h\n"},
  // cnt, currentPixels,
  // fir_out_a[7:0],fir_out_a[15:8],fir_out_a[23:16],fir_out_a[31:24],
  // fir_out_a[39:32],fir_out_a[47:40], fir_out_a[55:48], fir_out_a[63:56],
  // temp_A);
end

initial begin
  $write("Loading rom...");
  $readmemh("split_images/paris_red_2", im_memory);

  for (i=0; i<15; i=i+1) begin
  // im_rows[i] = {im_memory[i][14],im_memory[i][13],im_memory[i][12],im_memory[i][11],im_memory[i][10],
  //               im_memory[i][9],im_memory[i][8],im_memory[i][7],im_memory[i][6],im_memory[i][5],
  //               im_memory[i][4],im_memory[i][3],im_memory[i][2],im_memory[i][1],im_memory[i][0]};
  im_rows[i] = {im_memory[i][0],im_memory[i][1],im_memory[i][2],im_memory[i][3],im_memory[i][4],
                im_memory[i][5],im_memory[i][6],im_memory[i][7],im_memory[i][8],im_memory[i][9],
                im_memory[i][10],im_memory[i][11],im_memory[i][12],im_memory[i][13],im_memory[i][14]};
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
  #13500 $fwrite(f_c, {"%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h\n",
    "%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h\n",
    "%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h\n",
     "%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h\n",
     "%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h"},
     C[63:0],
     C[127:64],
     C[191:128],
     C[255:192],
     C[319:256],
     C[383:320],
     C[447:384],
     C[511:448],
     C[575:512],
     C[639:576],
     C[703:640],
     C[767:704],
     C[831:768],
     C[895:832],
     C[959:896],
     C[1023:960],
     C[1087:1024],
     C[1151:1088],
     C[1215:1152],
     C[1279:1216],
     C[1343:1280],
     C[1407:1344],
     C[1471:1408],
     C[1535:1472],
     C[1599:1536],
     C[1663:1600],
     C[1727:1664],
     C[1791:1728],
     C[1855:1792],
     C[1919:1856],
     C[1983:1920],
     C[2047:1984],
     C[2111:2048],
     C[2175:2112],
     C[2239:2176],
     C[2303:2240],
     C[2367:2304],
     C[2431:2368],
     C[2495:2432],
     C[2559:2496]);
$fwrite(f_b, {"%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h\n",
     "%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h\n",
     "%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h\n",
      "%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h\n",
      "%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h"},
      B[63:0],
      B[127:64],
      B[191:128],
      B[255:192],
      B[319:256],
      B[383:320],
      B[447:384],
      B[511:448],
      B[575:512],
      B[639:576],
      B[703:640],
      B[767:704],
      B[831:768],
      B[895:832],
      B[959:896],
      B[1023:960],
      B[1087:1024],
      B[1151:1088],
      B[1215:1152],
      B[1279:1216],
      B[1343:1280],
      B[1407:1344],
      B[1471:1408],
      B[1535:1472],
      B[1599:1536],
      B[1663:1600],
      B[1727:1664],
      B[1791:1728],
      B[1855:1792],
      B[1919:1856],
      B[1983:1920],
      B[2047:1984],
      B[2111:2048],
      B[2175:2112],
      B[2239:2176],
      B[2303:2240],
      B[2367:2304],
      B[2431:2368],
      B[2495:2432],
      B[2559:2496]);
$fwrite(f_a, {"%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h\n",
     "%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h\n",
     "%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h\n",
      "%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h\n",
      "%h\n%h\n%h\n%h\n%h\n%h\n%h\n%h"},
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
  $fclose(f_c);
  $fclose(f_b);
  $fclose(f_a);
  $finish;

end




endmodule
