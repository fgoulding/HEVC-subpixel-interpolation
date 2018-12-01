module FIR_A_M(clock, reset_L,s,so, inputPixels, subPixel);

  input [63:0] inputPixels; // flattened input pixels
  input clock;
  input reset_L;
  input [7:0] s;
  output reg [7:0] so;
  output [7:0] subPixel;
  reg [7:0] subPixel;
  reg [15:0] sum_;

  always @(posedge clock)
  begin
    if(!reset_L)
      begin
        subPixel = 8'b0;
        so = 8'b0;
      end
    else
      begin
        sum_ = ((inputPixels[15:8]<<2) +
                - ((inputPixels[23:16]<<3))
                + ((inputPixels[31:24]<<6)-(inputPixels[31:24]<<3))
                + ((inputPixels[39:32]<<4))
                - ((inputPixels[47:40]<<2))
                + inputPixels[55:48] - inputPixels[7:0]) >> 6;
        if (sum_>255) begin
          subPixel = 255;
        end
        else begin
          subPixel = sum_[7:0];
        end
        so = s;
      end
  end

endmodule

module FIR_B_M( clock, reset_L, inputPixels, subPixel);
  input clock;
  input reset_L;
  input [63:0] inputPixels; // flattened input pixels
  output reg [7:0] subPixel;

  reg [15:0] sum_;

  always @(posedge clock)
  begin
    if(!reset_L)
      begin
        subPixel = 8'b0;
      end
    else
      begin
				sum_ = (((inputPixels[15:8] + inputPixels[55:48]) << 2)
                - (((inputPixels[23:16] + inputPixels[47:40]) << 3)
                + ((inputPixels[23:16] + inputPixels[47:40]) << 1)
                + (inputPixels[23:16] + inputPixels[47:40]))
                + (((inputPixels[31:24] + inputPixels[39:32]) << 5)
                + ((inputPixels[31:24] + inputPixels[39:32]) << 3))
                - inputPixels[63:56] - inputPixels[7:0]) >> 6;
        if (sum_>255) begin
          subPixel = 255;
        end
        else begin
          subPixel = sum_[7:0];
        end
      end
  end

endmodule

module FIR_C_M(clock, reset_L, inputPixels, subPixel);
  input clock;
  input reset_L;
  input [63:0] inputPixels; // flattened input pixels
  output [7:0] subPixel;
  reg [7:0] subPixel;
  reg [15:0] sum_;

  always @(posedge clock)
  begin
    if(!reset_L)
      begin
        subPixel = 8'b0;
      end
    else
      begin

        sum_ = ((inputPixels[47:40]<<2) +
              - ((inputPixels[39:32]<<3))
              + ((inputPixels[31:24]<<6)-(inputPixels[31:24]<<3))
              + ((inputPixels[23:16]<<4))
              - ((inputPixels[15:8]<<2))
              + inputPixels[7:0] - inputPixels[55:48]) >> 6;

        if (sum_>255) begin
          subPixel = 255;
        end
        else begin
          subPixel = sum_[7:0];
        end
      end
  end

endmodule
