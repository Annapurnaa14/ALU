`ifndef ALU_ASSERTIONS_SV
`define ALU_ASSERTIONS_SV

`include "defines.svh"

module alu_assertions (
  input wire clk,RST,CE,MODE,CIN
  input wire [1:0] INP_VALID,
  input wire [`CW-1:0] CMD,
  input wire [`DW-1:0] OPA,OPB
  input wire [2*`DW-1:0] RES,
  input wire COUT,OFLOW,G,E,L,ERR);

  property p_reset;
    @(posedge clk)
    RST |-> (RES == 0 && ERR == 1'b0 && COUT == 1'b0 && OFLOW == 1'b0 && G==0 && E==0 && L==0 );
  endproperty
  assert property(p_reset);

    property ce_deasserted;
    @(posedge clk)
    !CE |=> $stable(RES) && $stable(ERR) && $stable(COUT) && $stable(OFLOW) && $stable(G) && $stable(E) && $stable(L);
  endproperty
  assert property(ce_deasserted);

    property p_timeout_err;
    @(posedge clk)
    (CE && (INP_VALID != 2'b11) && (INP_VALID != 2'b00)) [*16] |-> ERR;
  endproperty
  assert property(p_timeout_err);
  
  property p_invalid_arith_cmd;
    @(posedge clk)
    (CE && MODE && (INP_VALID == 2'b11) && (CMD > 4'd10)) |=> ERR;
  endproperty
  assert property(p_invalid_arith_cmd);

  property p_invalid_logic_cmd;
    @(posedge clk)
    (CE && !MODE && (INP_VALID == 2'b11) && (CMD > 4'd13)) |=> ERR;
  endproperty
  assert property(p_invalid_logic_cmd);

  property p_rotate_shift_err;
    @(posedge clk)
    (CE && !MODE && (INP_VALID == 2'b11) && ((CMD == 4'b1100) || (CMD == 4'b1101)) && (OPB[`DW-1 : `ROT_BITS] != '0)) |=> ERR;
  endproperty
  assert property(p_rotate_shift_err);

  property p_err_clear;
    @(posedge clk)
    ERR && CE && (INP_VALID == 2'b11) &&
    ((MODE && (CMD <= 4'd10)) || (!MODE && (CMD <= 4'd11))) |=> !ERR;
  endproperty
  assert property(p_err_clear);

  property p_mul_latency;
    @(posedge clk)
    (CE && MODE && (INP_VALID == 2'b11) && (CMD == 4'b1001)) |=> ##1 $changed(RES) || $stable(RES);
  endproperty
  assert property(p_mul_latency);

  property p_cmp_flags;
    @(posedge clk)
    (CE && MODE && (INP_VALID == 2'b11) && (CMD == 4'b1010)) |=> $onehot({G, E, L});
  endproperty
  assert property(p_cmp_flags);
endmodule
    
`endif
