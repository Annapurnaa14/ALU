
`ifndef ALU_AGENT_SV
`define ALU_AGENT_SV
`include "uvm_macros.svh"
`include "sequenceitem.sv"
`include "alu_config.sv"
`include "alu_driver.sv"
`include "inpmon.sv"
`include "alu_sequencer.sv"

class alu_agent extends uvm_agent;
  `uvm_component_utils(alu_agent)

  driver drvh;
  input_monitor monh;
  sequencer sqrh;
  alu_config m_cfg;

  function new(string name = "inp_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(alu_config)::get(this, "", "alu_config", m_cfg))
      `uvm_fatal(get_type_name(), "Agent: Failed to get alu_config object!")

    monh = input_monitor::type_id::create("monh", this);
    if (m_cfg.input_agent_is_active == UVM_ACTIVE)
    begin
      drvh  = driver::type_id::create("drvh", this);
      sqrh = sequencer::type_id::create("sqrh", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (m_cfg.input_agent_is_active == UVM_ACTIVE) begin
      drvh.seq_item_port.connect(sqrh.seq_item_export);
    end
  endfunction
endclass

`endif
