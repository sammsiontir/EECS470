`timescale 1ns/100ps

//
// The ALU
//
// given the command code CMD and proper operands A and B, compute the
// result of the instruction
//
// This module is purely combinational
//
module alu_unit(//Inputs
           opa,
           opb,
           func,
           
           // Output
           result
          );

  input  [63:0] opa;
  input  [63:0] opb;
  input   [4:0] func;
  output [63:0] result;

  reg    [63:0] result;

  // This function computes a signed less-than operation
  function signed_lt;
    input [63:0] a, b;
    
    if (a[63] == b[63]) 
      signed_lt = (a < b); // signs match: signed compare same as unsigned
    else
      signed_lt = a[63];   // signs differ: a is smaller if neg, larger if pos
  endfunction

  always @*
  begin
    case (func)
      `ALU_ADDQ:   result = opa + opb;
      `ALU_SUBQ:   result = opa - opb;
      `ALU_AND:    result = opa & opb;
      `ALU_BIC:    result = opa & ~opb;
      `ALU_BIS:    result = opa | opb;
      `ALU_ORNOT:  result = opa | ~opb;
      `ALU_XOR:    result = opa ^ opb;
      `ALU_EQV:    result = opa ^ ~opb;
      `ALU_SRL:    result = opa >> opb[5:0];
      `ALU_SLL:    result = opa << opb[5:0];
      `ALU_SRA:    result = (opa >> opb[5:0]) | ({64{opa[63]}} << (64 -
                             opb[5:0])); // arithmetic from logical shift
      `ALU_CMPULT: result = { 63'd0, (opa < opb) };
      `ALU_CMPEQ:  result = { 63'd0, (opa == opb) };
      `ALU_CMPULE: result = { 63'd0, (opa <= opb) };
      `ALU_CMPLT:  result = { 63'd0, signed_lt(opa, opb) };
      `ALU_CMPLE:  result = { 63'd0, (signed_lt(opa, opb) || (opa == opb)) };
      default:     result = 64'hdeadbeefbaadbeef; // here only to force
                                                  // a combinational solution
                                                  // a casex would be better
    endcase
  end
endmodule // alu_unit

//
// BrCond module
//
// Given the instruction code, compute the proper condition for the
// instruction; for branches this condition will indicate whether the
// target is taken.
//
// This module is purely combinational
//
module brcond(// Inputs
              opa,        // Value to check against condition
              func,       // Specifies which condition to check

              // Output
              cond        // 0/1 condition result (False/True)
             );

  input   [2:0] func;
  input  [63:0] opa;
  output        cond;
  
  reg           cond;

  always @*
  begin
    case (func[1:0]) // 'full-case'  All cases covered, no need for a default
      2'b00: cond = (opa[0] == 0);  // LBC: (lsb(opa) == 0) ?
      2'b01: cond = (opa == 0);     // EQ: (opa == 0) ?
      2'b10: cond = (opa[63] == 1); // LT: (signed(opa) < 0) : check sign bit
      2'b11: cond = (opa[63] == 1) || (opa == 0); // LE: (signed(opa) <= 0)
    endcase
  
     // negate cond if func[2] is set
    if (func[2])
      cond = ~cond;
  end
endmodule // brcond


module alu(// Inputs
           clock,
           reset,
           I_X_NPC,
           I_X_IR,
           I_X_rega,
           I_X_regb,
           I_X_opa_select,
           I_X_opb_select,
           I_X_alu_func,
           I_X_cond_branch,
           I_X_uncond_branch,
                
           // Outputs
           X_alu_result_out,
           X_take_branch_out
          );

  input         clock;               // system clock
  input         reset;               // system reset
  input  [63:0] I_X_NPC;           // incoming instruction PC+4
  input  [31:0] I_X_IR;            // incoming instruction
  input  [63:0] I_X_rega;          // register A value from reg file
  input  [63:0] I_X_regb;          // register B value from reg file
  input   [1:0] I_X_opa_select;    // opA mux select from decoder
  input   [1:0] I_X_opb_select;    // opB mux select from decoder
  input   [4:0] I_X_alu_func;      // ALU function select from decoder
  input         I_X_cond_branch;   // is this a cond br? from decoder
  input         I_X_uncond_branch; // is this an uncond br? from decoder

  output [63:0] X_alu_result_out;   // ALU result
  output        X_take_branch_out;  // is this a taken branch?

  reg    [63:0] opa_mux_out, opb_mux_out;
  wire          brcond_result;
   
   // set up possible immediates:
   //   mem_disp: sign-extended 16-bit immediate for memory format
   //   br_disp: sign-extended 21-bit immediate * 4 for branch displacement
   //   alu_imm: zero-extended 8-bit immediate for ALU ops
  wire [63:0] mem_disp = { {48{I_X_IR[15]}}, I_X_IR[15:0] };
  wire [63:0] br_disp  = { {41{I_X_IR[20]}}, I_X_IR[20:0], 2'b00 };
  wire [63:0] alu_imm  = { 56'b0, I_X_IR[20:13] };
   
   //
   // ALU opA mux
   //
  always @*
  begin
    case (I_X_opa_select)
      `ALU_OPA_IS_REGA:     opa_mux_out = I_X_rega;
      `ALU_OPA_IS_MEM_DISP: opa_mux_out = mem_disp;
      `ALU_OPA_IS_NPC:      opa_mux_out = I_X_NPC;
      `ALU_OPA_IS_NOT3:     opa_mux_out = ~64'h3;
    endcase
  end

   //
   // ALU opB mux
   //
  always @*
  begin
     // Default value, Set only because the case isnt full.  If you see this
     // value on the output of the mux you have an invalid opb_select
    opb_mux_out = 64'hbaadbeefdeadbeef;
    case (I_X_opb_select)
      `ALU_OPB_IS_REGB:    opb_mux_out = I_X_regb;
      `ALU_OPB_IS_ALU_IMM: opb_mux_out = alu_imm;
      `ALU_OPB_IS_BR_DISP: opb_mux_out = br_disp;
    endcase 
  end

   //
   // instantiate the ALU
   //
  alu_unit alu_0 (// Inputs
                  .opa(opa_mux_out),
                  .opb(opb_mux_out),
                  .func(I_X_alu_func),

                  // Output
                  .result(X_alu_result_out)
                 );

   //
   // instantiate the branch condition tester
   //
  brcond brcond (// Inputs
                .opa(I_X_rega),       // always check regA value
                .func(I_X_IR[28:26]), // inst bits to determine check

                // Output
                .cond(brcond_result)
               );

   // ultimate "take branch" signal:
   //    unconditional, or conditional and the condition is true
  assign X_take_branch_out = I_X_uncond_branch| (I_X_cond_branch & brcond_result);

endmodule // module alu

