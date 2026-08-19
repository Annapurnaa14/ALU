`include "uvm_macros.svh"
import uvm_pkg::*;
`include"sequenceitem.sv"
`include "alu_config.sv"
class driver extends uvm_driver#(trans);
`uvm_component_utils(driver)
 virtual alu_if.DRV vif;
 alu_config m_cfg;

 function new(string name="driver",uvm_component parent);
        super.new(name,parent);
 endfunction

 function void build_phase(uvm_phase phase);
        super.build_phase(phase);
   if(!uvm_config_db#(alu_config)::get(this,"","alu_config",m_cfg))
        `uvm_fatal(get_type_name(),"Driver Getting Failed")
 endfunction

 function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vif=m_cfg.vif;
 endfunction


task run_phase(uvm_phase phase);
        begin
        @(vif.drv_cb);
         vif.drv_cb.RST<=1'b1;
        @(vif.drv_cb);
         vif.drv_cb.RST<=1'b0;

        forever
                begin
                   seq_item_port.get_next_item(req);
                   drive(req);
                   seq_item_port.item_done();
               end
        end
 endtask

task drive(trans data2duv);
    begin
      `uvm_info("DRIVER", $sformatf("Driving Transaction:\n%s", data2duv.sprint()), UVM_LOW)
      @(vif.drv_cb);
      vif.drv_cb.CE  <= data2duv.CE;
      vif.drv_cb.INP_VALID  <= data2duv.INP_VALID;
      vif.drv_cb.OPA <= data2duv.OPA;
      vif.drv_cb.OPB <= data2duv.OPB;
      vif.drv_cb.MODE <= data2duv.MODE;
      vif.drv_cb.CMD <= data2duv.CMD;

      if ((data2duv.MODE == 1'b1) && (data2duv.CMD == 4'b0010 || data2duv.CMD == 4'b0011))
begin
        vif.drv_cb.CIN <= data2duv.CIN;
      end else begin
        vif.drv_cb.CIN <= 1'b0;
      end
    end
  endtask
endclass
~
