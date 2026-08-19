`ifndef ALU_SEQUENCE_SV
`define ALU_SEQUENCE_SV
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "sequenceitem.sv"

class base_seq extends uvm_sequence #(trans);
   `uvm_object_utils(base_seq)
   function new(string name = "base_seq");
     super.new(name);
   endfunction
task body();
  req=trans::type_id::create("req");
  begin
   start_item(req);
   assert(req.randomize());
   finish_item(req);
   end
   endtask
endclass

class direct_cases extends base_seq;
  `uvm_object_utils(direct_cases)
   function new(string name = "direct_cases");
     super.new(name);
   endfunction
   task body();
     req = trans::type_id::create("req");
     start_item(req);
     assert(req.randomize() with { MODE == 1'b1; CMD == 4'b0010; INP_VALID == 2'b11; CE == 1'b1; RST == 1'b0; OPA=='d5; OPB=='d8; });     finish_item(req);
     req = trans::type_id::create("req");
     start_item(req);
     assert(req.randomize() with { RST == 1'b1; });
     finish_item(req);
     req = trans::type_id::create("req");
     start_item(req);
     assert(req.randomize() with { CE == 1'b0; RST == 1'b0; });
     finish_item(req);

     repeat (18) begin
       req = trans::type_id::create("req");
       start_item(req);
       assert(req.randomize() with { INP_VALID == 2'b01; CE == 1'b1; RST == 1'b0; });
       finish_item(req);
     end
   endtask
endclass


class arithmetic_ops_seq extends base_seq;
   `uvm_object_utils(arithmetic_ops_seq)
   function new(string name = "arithmetic_ops_seq");
     super.new(name);
   endfunction
  task body();
     req = trans::type_id::create("req");
     start_item(req);
     assert(req.randomize() with { MODE == 1'b1; CMD == 4'd0; OPA == 'd10; OPB == 'd5; INP_VALID == 2'b11; CE == 1'b1; RST == 1'b0; });
     finish_item(req);
     req = trans::type_id::create("req");
     start_item(req);
     assert(req.randomize() with { MODE == 1'b1; CMD == 4'd1; OPA == 'd20; OPB == 'd8; INP_VALID == 2'b11; CE == 1'b1; RST == 1'b0; });
     finish_item(req); 
     req = trans::type_id::create("req");
     start_item(req);
     assert(req.randomize() with { MODE == 1'b1; CMD == 4'd2; OPA == 'd15; OPB == 'd3; CIN == 1'b1; INP_VALID == 2'b11; CE == 1'b1; RST == 1'b0; });
     finish_item(req);
     req = trans::type_id::create("req");
     start_item(req);
     assert(req.randomize() with { MODE == 1'b1; CMD == 4'd3; OPA == 'd25; OPB == 'd5; CIN == 1'b1; INP_VALID == 2'b11; CE == 1'b1; RST == 1'b0; });
     finish_item(req);
     req = trans::type_id::create("req");
     start_item(req);
     assert(req.randomize() with { MODE == 1'b1; CMD == 4'd4; OPA == ((1 << `DW) - 1); INP_VALID == 2'b11; CE == 1'b1; RST == 1'b0; });
     finish_item(req);
     req = trans::type_id::create("req");
     start_item(req);
     assert(req.randomize() with { MODE == 1'b1; CMD == 4'd5; OPA == 'd0; INP_VALID == 2'b11; CE == 1'b1; RST == 1'b0; });
     finish_item(req);
     req = trans::type_id::create("req");
     start_item(req);
     assert(req.randomize() with { MODE == 1'b1; CMD == 4'd6; OPB == ((1 << `DW) - 1); INP_VALID == 2'b11; CE == 1'b1; RST == 1'b0; });
     finish_item(req);
     req = trans::type_id::create("req");
     start_item(req);
     assert(req.randomize() with { MODE == 1'b1; CMD == 4'd7; OPB == 'd0; INP_VALID == 2'b11; CE == 1'b1; RST == 1'b0; });
     finish_item(req);
     req = trans::type_id::create("req");
     start_item(req);
     assert(req.randomize() with { MODE == 1'b1; CMD == 4'd8; OPA == 'd12; OPB == 'd12; INP_VALID == 2'b11; CE == 1'b1; RST == 1'b0; });
     finish_item(req);
    req = trans::type_id::create("req");
     start_item(req);
     assert(req.randomize() with { MODE == 1'b1; CMD == 4'd9; OPA == 'd10; OPB == 'd5; INP_VALID == 2'b11; CE == 1'b1; RST == 1'b0; });
     finish_item(req);
   endtask
endclass

class logical_ops extends base_seq;
   `uvm_object_utils(logical_ops)
   function new(string name = "logical_ops");
     super.new(name);
   endfunction

   task body();
     req = trans::type_id::create("req");
     start_item(req);
     assert(req.randomize() with { MODE == 1'b0; CMD == 4'd0; OPA == 'hFF; OPB == 'h0F; INP_VALID == 2'b11; CE == 1'b1; RST == 1'b0; });
     finish_item(req);
     req = trans::type_id::create("req");
     start_item(req);
     assert(req.randomize() with { MODE == 1'b0; CMD == 4'd1; OPA == 'hF0; OPB == 'h0F; INP_VALID == 2'b11; CE == 1'b1; RST == 1'b0; });
     finish_item(req);
     req = trans::type_id::create("req");
     start_item(req);
     assert(req.randomize() with { MODE == 1'b0; CMD == 4'd2; OPA == 'hAA; OPB == 'h55; INP_VALID == 2'b11; CE == 1'b1; RST == 1'b0; });
     finish_item(req);

    req = trans::type_id::create("req");
     start_item(req);
     assert(req.randomize() with { MODE == 1'b0; CMD == 4'd12; OPA == 'h81; OPB == 'd2; INP_VALID == 2'b11; CE == 1'b1; RST == 1'b0; });
     finish_item(req);

     req = trans::type_id::create("req");
     start_item(req);
     assert(req.randomize() with { MODE == 1'b0; CMD == 4'd13; OPA == 'h81; OPB == 'd2; INP_VALID == 2'b11; CE == 1'b1; RST == 1'b0; });
     finish_item(req);
   endtask
endclass

class err_seq extends base_seq;
   `uvm_object_utils(err_seq)
   function new(string name = "err_seq");
     super.new(name);
   endfunction
  
   task body();
     req = trans::type_id::create("req");
     req.c2.constraint_mode(0);
     start_item(req);
     assert(req.randomize() with { MODE == 1'b1; CMD == 4'd11; INP_VALID == 2'b11; CE == 1'b1; RST == 1'b0; });
     finish_item(req);
     req = trans::type_id::create("req");
     req.c2.constraint_mode(0);
     start_item(req);
     assert(req.randomize() with { MODE == 1'b0; CMD == 4'd14; INP_VALID == 2'b11; CE == 1'b1; RST == 1'b0; });
     finish_item(req);
     req = trans::type_id::create("req");
     start_item(req);
     assert(req.randomize() with { MODE == 1'b0; CMD == 4'd12; OPA == 'hFF; OPB == 'b10000001; INP_VALID == 2'b11; CE == 1'b1; RST == 1'b0; });
     finish_item(req);
     req = trans::type_id::create("req");
     start_item(req);
     assert(req.randomize() with { MODE == 1'b1; CMD == 4'd0; INP_VALID == 2'b11; CE == 1'b1; RST == 1'b0; });
     finish_item(req);
   endtask
endclass

`endif
