
/*
 *
 */
module shift_reg (clock, reset_L, load_L, in, out);
  input		clock;
  input		reset_L;
  input load_L;
  input [63:0] in;
  output reg [959:0]	out;
  integer i=0;
  integer j=0;
  reg [63:0] regi [14:0];
  reg [119:0] regi_t [7:0];

  always @(posedge clock) begin
    if (~reset_L) begin
      for(i=0;i<15;i=i+1) begin
        regi[i] <= 64'b0;
      end
    end
    else if (~load_L) begin
      //byte shift register
      for( i=1;i<15;i=i+1) begin
        regi[i] <= regi[i-1];
      end
      regi[0] <= in;
    end


    for(i=0;i<15;i=i+1) begin
      for (j=0;j<8;j=j+1) begin
        regi_t[j][i*8 +:8] = regi[i][j*8 +:8];
      end
    end
    out = {regi_t[7],regi_t[6],regi_t[5],regi_t[4],regi_t[3],regi_t[2],regi_t[1],regi_t[0]};
  end

endmodule
