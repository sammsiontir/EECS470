// This is an 8 stage (9 depending on how you look at it) pipelined 
// multiplier that multiplies 2 64-bit integers and returns the low 64 bits 
// of the result.  This is not an ideal multiplier but is sufficient to 
// allow a faster clock period than straight *
// This module instantiates 8 pipeline stages as an array of submodules.
module mult(clock, reset, mplier, mcand, start, product, done);

  parameter NSTAGE = 8;
  parameter TBIT = 64;
  input clock, reset, start;
  input [TBIT-1:0] mcand, mplier;

  output [TBIT-1:0] product;
  output done;

  wire [TBIT-1:0] mcand_out, mplier_out;
  wire [((NSTAGE-1)*TBIT)-1:0] internal_products, internal_mcands, internal_mpliers;
  wire [NSTAGE-2:0] internal_dones;

  wire [TBIT-1:0] ZBIT = 0;
  
  mult_stage #(.TBIT(TBIT), .NBIT(64/NSTAGE)) mstage [NSTAGE-1:0] 
    (.clock(clock),
     .reset(reset),
     .product_in({internal_products,ZBIT}),
     .mplier_in({internal_mpliers,mplier}),
     .mcand_in({internal_mcands,mcand}),
     .start({internal_dones,start}),
     .product_out({product,internal_products}),
     .mplier_out({mplier_out,internal_mpliers}),
     .mcand_out({mcand_out,internal_mcands}),
     .done({done,internal_dones})
    );

endmodule
