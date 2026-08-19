`ifndef ALU_CONFIG_SV
`define ALU_CONFIG_SV
`include"uvm_macros.svh"
import uvm_pkg::*;

`include "defines.svh"
class alu_config extends uvm_object;
`uvm_object_utils(alu_config)

  virtual alu_if vif;
  uvm_active_passive_enum input_agent_is_active;
  uvm_active_passive_enum output_agent_is_active;

  function new(string name="alu_config");
        super.new(name);
  endfunction
  
endclass
`endif
