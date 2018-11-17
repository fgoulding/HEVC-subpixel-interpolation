/*
 * module: register
 *
 * A positive-edge clocked parameterized register with (active low) load enable
 * and asynchronous reset. The parameter is the bit-width of the register.
 */
module register (
  clock,
  reset_L,
  load_L,
  in,
  out
   );
   parameter WIDTH = 960;
   input [WIDTH-1:0] in;
   input load_L;
   input clock;
   input reset_L;
   output reg [WIDTH-1:0] out;

   always @ (posedge clock, negedge reset_L) begin
      if(!reset_L)
         out <= 'h0000;
      else if (~load_L)
         out <= in;
   end
endmodule

module counter (clk, reset_L, cnt);
  input		clk;
  input		reset_L;
  output	[7:0]	cnt;
  reg	[7:0]	cnt;

  always @(posedge clk)
    if (!reset_L)
      cnt = 0;
    else
      cnt = cnt + 1;

endmodule

module counter_wA (clk, reset_L, active, cnt);
  input		clk;
  input		reset_L;
  input		active;
  output	[63:0]	cnt;
  reg	[63:0]	cnt;

  always @(posedge clk)
    if (!reset_L)
      cnt = 0;
    else begin
      if (active)
        cnt = cnt + 1;
    end
endmodule

/*
 *
 */
module shift_reg (clock, reset_L, load_L, in, out);
  input		clock;
  input		reset_L;
  input load_L;
  input [63:0] in;
  output reg [959:0]	out;
  integer i;
  integer j;
  reg [63:0] regi [14:0];
  reg [119:0] regi_t [7:0];

  always @(negedge clock) begin
    if (!reset_L) begin
        regi[0] = 8'b0;
        regi[1] = 8'b0;
        regi[2] = 8'b0;
        regi[3] = 8'b0;
        regi[4] = 8'b0;
        regi[5] = 8'b0;
        regi[6] = 8'b0;
        regi[7] = 8'b0;
        regi[8] = 8'b0;
        regi[9] = 8'b0;
        regi[10] = 8'b0;
        regi[11] = 8'b0;
        regi[12] = 8'b0;
        regi[13] = 8'b0;
        regi[14] = 8'b0;
        for(i=0;i<15;i=i+1) begin
          for (j=0;j<8;j=j+1) begin
            regi_t[j][i*8 +:8] = regi[i][j*8 +:8];
          end
        end
      out = {regi_t[7],regi_t[6],regi_t[5],regi_t[4],regi_t[3],regi_t[2],regi_t[1],regi_t[0]};

    end
    else if (~load_L) begin
      //byte shift register
      for( i=0;i<14;i=i+1) begin
        regi[i] <= regi[i+1];
      end
      regi[14] <= in;
      for(i=0;i<15;i=i+1) begin
        for (j=0;j<8;j=j+1) begin
          regi_t[j][i*8 +:8] = regi[i][j*8 +:8];
        end
      end
    out = {regi_t[7],regi_t[6],regi_t[5],regi_t[4],regi_t[3],regi_t[2],regi_t[1],regi_t[0]};
    end
  end

endmodule

/*
 *
 */
module input_shift_reg(clock, reset_L, load_L, in, out);
  input		clock;
  input		reset_L;
  input load_L;
  input [119:0] in;
  output reg [1799:0]	out;
  integer i;
  integer j;
  reg [119:0] regi [14:0];
  //reg [119:0] regi_t [7:0];

  always @(negedge clock) begin
    if (!reset_L) begin
        regi[0] = 8'b0;
        regi[1] = 8'b0;
        regi[2] = 8'b0;
        regi[3] = 8'b0;
        regi[4] = 8'b0;
        regi[5] = 8'b0;
        regi[6] = 8'b0;
        regi[7] = 8'b0;
        regi[8] = 8'b0;
        regi[9] = 8'b0;
        regi[10] = 8'b0;
        regi[11] = 8'b0;
        regi[12] = 8'b0;
        regi[13] = 8'b0;
        regi[14] = 8'b0;
      out = {regi[14],regi[13],regi[12],regi[11],regi[10],regi[9],regi[8],
             regi[7],regi[6],regi[5],regi[4],regi[3],regi[2],regi[1],regi[0]};

    end
    else if (~load_L) begin
      //byte shift register
      for(i=0;i<14;i=i+1) begin
        regi[i] <= regi[i+1];
      end
      regi[14] <= in;

      out = {regi[14],regi[13],regi[12],regi[11],regi[10],regi[9],regi[8],
             regi[7],regi[6],regi[5],regi[4],regi[3],regi[2],regi[1],regi[0]};
    end
  end

endmodule

module output_filler(clock, reset_L, load_L, sel, in, out);
  input		clock;
  input		reset_L;
  input load_L;
  input [7:0] sel;
  input [63:0] in;
  output reg [2559:0]	out; //8 rows by 8 cols by 5 pixels by 8 bits
  integer i=0;
  integer j=0;
  reg [63:0] regi [39:0]; //8*8 by 8*5

  always @(negedge clock) begin
    if (!reset_L) begin
      for(i=0;i<40;i=i+1) begin
        regi[i] = 64'b0;
      end

          out = {regi[39],regi[38],regi[37],regi[36],regi[35],regi[34],regi[33],regi[32],
                regi[31],regi[30],regi[29],regi[28],regi[27],regi[26],regi[25],regi[24],
                regi[23],regi[22],regi[21],regi[20],regi[19],regi[18],regi[17],regi[16],
                regi[15],regi[14],regi[13],regi[12],regi[11],regi[10],regi[9],regi[8],
                regi[7],regi[6],regi[5],regi[4],regi[3],regi[2],regi[1],regi[0]};

    end
    //make load L check that sel is not 0,1,2 or 11,12,13,14
    //or greater than num of total pixels
    else if (~load_L) begin
      for( i=1;i<40;i=i+1) begin
        regi[i] <= regi[i-1];
      end
      regi[0] <= in;
      // //byte shift register
      // if ((sel > 2) && (sel < 11)) begin
      //   regi[sel-3] <= in;
      // end else if ((sel > 14) && (sel < 48)) begin
      //   regi[sel-7] <= in;
      // end

    out = {regi[39],regi[38],regi[37],regi[36],regi[35],regi[34],regi[33],regi[32],
          regi[31],regi[30],regi[29],regi[28],regi[27],regi[26],regi[25],regi[24],
          regi[23],regi[22],regi[21],regi[20],regi[19],regi[18],regi[17],regi[16],
          regi[15],regi[14],regi[13],regi[12],regi[11],regi[10],regi[9],regi[8],
          regi[7],regi[6],regi[5],regi[4],regi[3],regi[2],regi[1],regi[0]};
    end
    else begin
      out = {regi[39],regi[38],regi[37],regi[36],regi[35],regi[34],regi[33],regi[32],
            regi[31],regi[30],regi[29],regi[28],regi[27],regi[26],regi[25],regi[24],
            regi[23],regi[22],regi[21],regi[20],regi[19],regi[18],regi[17],regi[16],
            regi[15],regi[14],regi[13],regi[12],regi[11],regi[10],regi[9],regi[8],
            regi[7],regi[6],regi[5],regi[4],regi[3],regi[2],regi[1],regi[0]};
    end
  end

endmodule
