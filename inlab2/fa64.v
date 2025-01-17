module full_adder_64bit( A, B, carry_in, S, carry_out );
	input	[63:0]	A, B;
	input		carry_in;
	output	[63:0]	S;
	output		carry_out;

	wire [62:0] carries;
	// Implement a 64-bit adder using array instantiated 1-bit adders
	// ASSUME: bit 63 of 63:0 is the MSB

	// ----FILL IN HERE----
	full_adder_1bit adder[63:0] ( .A(A), .B(B), .carry_in({carries,carry_in}), .S(S), .carry_out({carry_out,carries}) );
	// ----------------------

endmodule 
