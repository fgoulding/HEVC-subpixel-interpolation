module FIR_A(clock, reset_L,s,so, inputPixels, subPixel);

  input [63:0] inputPixels; // flattened input pixels
  input clock;
  input reset_L;
  input [7:0] s;
  output reg [7:0] so;
  output [7:0] subPixel;
  reg [7:0] subPixel;
  parameter c1 = -1; parameter c2 = 4; parameter c3 = -10;
  parameter c4 = 58; parameter c5 = 17; parameter c6 = -5;
  parameter c7 = 1;

  always @(posedge clock)
  begin
    if(!reset_L)
      begin
        subPixel = 8'b0;
        so = 8'b0;
      end
    else
      begin
        subPixel = (c1*inputPixels[7:0] + c2*inputPixels[15:8] + c3*inputPixels[23:16] + c4*inputPixels[31:24] +
                    c5*inputPixels[39:32] + c6*inputPixels[47:40] + c7*inputPixels[55:48])/64;
        so = s;
      end
  end

endmodule

module FIR_B( clock, reset_L, inputPixels, subPixel);
  input clock;
  input reset_L;
  input [63:0] inputPixels; // flattened input pixels
  output [7:0] subPixel;
  reg [7:0] subPixel;
  parameter c1 = -1; parameter c2 = 4; parameter c3 = -11;
  parameter c4 = 40; parameter c5 = 40; parameter c6 = -11;
  parameter c7 = 4 ; parameter c8 = -1;

  always @(posedge clock)
  begin
    if(!reset_L)
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

module FIR_C(clock, reset_L, inputPixels, subPixel);
  input clock;
  input reset_L;
  input [63:0] inputPixels; // flattened input pixels
  output [7:0] subPixel;
  reg [7:0] subPixel;
  parameter c1 =  1; parameter c2 = -5; parameter c3 = 17;
  parameter c4 = 58; parameter c5 = -10; parameter c6 = 4;
  parameter c7 = -1;

  always @(posedge clock)
  begin
    if(!reset_L)
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
