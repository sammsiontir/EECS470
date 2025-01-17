// This is one stage of an 8 stage (9 depending on how you look at it)
// pipelined multiplier that multiplies 2 64-bit integers and returns
// the low 64 bits of the result.  This is not an ideal multiplier but
// is sufficient to allow a faster clock period than straight *
module mult_stage(clock, reset, 
                  product_in,  mplier_in,  mcand_in,  start,
                  product_out, mplier_out, mcand_out, done);

  parameter NBIT = 4;
  parameter TBIT = 64;
  input clock, reset, start;
  input [TBIT-1:0] product_in, mplier_in, mcand_in;

  output done;
  output [TBIT-1:0] product_out, mplier_out, mcand_out;

  reg  [TBIT-1:0] prod_in_reg, partial_prod_reg;
  wire [TBIT-1:0] partial_product, next_mplier, next_mcand;

  reg [TBIT-1:0] mplier_out, mcand_out;
  reg done;

  wire [NBIT-1:0] ZBIT = 0;
  
  assign product_out = prod_in_reg + partial_prod_reg;

  assign partial_product = mplier_in[NBIT-1:0] * mcand_in; 

  assign next_mplier = {ZBIT,mplier_in[TBIT-1:NBIT]}; 
  assign next_mcand = {mcand_in[TBIT-1-NBIT:0],ZBIT}; 

  always @(posedge clock)
  begin
    prod_in_reg      <= #1 product_in;
    partial_prod_reg <= #1 partial_product;
    mplier_out       <= #1 next_mplier;
    mcand_out        <= #1 next_mcand;
  end

  always @(posedge clock)
  begin
    if(reset)
      done <= #1 1'b0;
    else
      done <= #1 start;
  end

endmodule

