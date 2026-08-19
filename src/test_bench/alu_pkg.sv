`ifndef ALU_PKG_SV
`define ALU_PKG_SV

package alu_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;

  `include "defines.svh"

  `include "alu_config.sv"
  `include "sequenceitem.sv"

  `include "inpmon.sv"
  `include "outmon.sv"
  `include "alu_driver.sv"
  `include "alu_sequencer.sv"
  `include "inpagent.sv"
  `include "outagent.sv"

  `include "alu_coverage.sv"
  `include "alu_scb.sv"
  `include "alu_env.sv"
  `include "alu_sequence.sv"

  `include "alu_test.sv"
endpackage

`endif
