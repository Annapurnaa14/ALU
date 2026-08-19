`ifndef ALU_SCOREBOARD_SV
`define ALU_SCOREBOARD_SV
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "defines.svh"
`include "sequenceitem.sv"
`include "alu_config.sv"

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  uvm_tlm_analysis_fifo #(trans) inp_mon_fifo;
  uvm_tlm_analysis_fifo #(trans) out_mon_fifo;
  trans inp_mon_xn; trans out_mon_xn;

  function new(string name="scoreboard", uvm_component parent);
    super.new(name, parent);
     inp_mon_fifo = new("inp_mon_fifo", this);
     out_mon_fifo = new("out_mon_fifo", this);
  endfunction

  bit [`DW-1:0] oprd1, oprd2;
  bit oprd1_valid, oprd2_valid;
  bit [`CW-1:0] latched_cmd;
  bit latched_mode,latched_cin;
  int wait_cycle_cnt;
  
  typedef struct {
    bit [2*`DW-1:0] exp_res;
    bit exp_cout, exp_oflow, exp_g, exp_e, exp_l, exp_err;
    bit mode, cin;
    bit [`DW-1:0] a,b;
    bit [`CW-1:0] cmd;
    int delay_cycles;
  } pipe_item;

  pipe_item exp_pipeline[$];
  int num_match;
  int num_mismatch;

task run_phase(uvm_phase phase);
  fork
    forever begin
      inp_mon_fifo.get(inp_mon_xn);
      foreach (exp_pipeline[i]) begin
        if (exp_pipeline[i].delay_cycles > 0)
          exp_pipeline[i].delay_cycles--;
      end
      ref_model(inp_mon_xn);
    end
    forever begin
      out_mon_fifo.get(out_mon_xn);
      check_result(out_mon_xn);
    end
  join
endtask

task check_result(trans out);
    pipe_item exp;
bit mismatch_detected = 0;
    if (exp_pipeline.size() == 0) return;
    if (exp_pipeline[0].delay_cycles > 0) return;
    exp = exp_pipeline.pop_front();

  if ((out.RES !== exp.exp_res) || (out.ERR !== exp.exp_err) || (out.COUT !== exp.exp_cout)  || (out.OFLOW !== exp.exp_oflow) || (out.G !== exp.exp_g) || (out.E !== exp.exp_e) ||
        (out.L !== exp.exp_l)) 
    begin
      mismatch_detected = 1;
    end

    if (mismatch_detected) begin
      num_mismatch++;
        `uvm_error("SB_MISMATCH", $sformatf("@%0t ns | MODE:%0b CMD:%0b OPA:0x%0h OPB:0x%0h | RES Exp:0x%0h Got:0x%0h | ERR Exp:%0b Got:%0b | COUT Exp:%0b Got:%0b | OFLOW Exp:%0b Got:%0b | G Exp:%0b Got:%0b | E Exp:%0b Got:%0b | L Exp:%0b Got:%0b",
                 $time, exp.mode, exp.cmd, exp.a, exp.b,
                 exp.exp_res, out.RES,
                 exp.exp_err, out.ERR,
                 exp.exp_cout, out.COUT,
                 exp.exp_oflow, out.OFLOW,
                 exp.exp_g, out.G,
                 exp.exp_e, out.E,
                 exp.exp_l, out.L))
    end
else begin
  num_match++;
  `uvm_info("SB_PASS", $sformatf("@%0t ns Match! CMD=4'b%04b MODE=%0b RES=0x%0h ERR=%0b", $time, exp.cmd, exp.mode, out.RES, out.ERR), UVM_LOW)
    end
  endtask

  virtual task ref_model(trans tr);
    pipe_item item;
    bit [2*`DW-1:0] exp_res = '0;
    bit exp_cout = 0, exp_oflow = 0;
    bit exp_g = 0, exp_e = 0, exp_l = 0, exp_err = 0;

if (!tr.RST && tr.INP_VALID == 2'b00) return;
    if (tr.RST) begin
      oprd1 = '0;
      oprd2 = '0;
      oprd1_valid = 0;
      oprd2_valid = 0;
      wait_cycle_cnt = 0;
      exp_pipeline.delete();
      return;
    end
    case (tr.INP_VALID)
      2'b01: begin
        oprd1 = tr.OPA;
        oprd1_valid = 1;
        latched_cmd = tr.CMD;
        latched_mode = tr.MODE;
        latched_cin = tr.CIN;
      end
      2'b10: begin
        oprd2 = tr.OPB;
        oprd2_valid = 1;
        latched_cmd = tr.CMD;
        latched_mode = tr.MODE;
        latched_cin = tr.CIN;
      end
      2'b11: begin
        oprd1 = tr.OPA;
        oprd2 = tr.OPB;
        oprd1_valid = 1;
        oprd2_valid = 1;
        latched_cmd = tr.CMD;
        latched_mode = tr.MODE;
        latched_cin = tr.CIN;
      end
      default: begin
        oprd1_valid = 0;
        oprd2_valid = 0;
      end
    endcase

    if (oprd1_valid ^ oprd2_valid) begin
      wait_cycle_cnt++;
      if (wait_cycle_cnt > 16) begin
        exp_err = 1'b1;
        wait_cycle_cnt = 0;
      end
    end else if (oprd1_valid && oprd2_valid) begin
      wait_cycle_cnt = 0;
    end

    if ((oprd1_valid && oprd2_valid) || exp_err) begin
      item.cmd = latched_cmd;
      item.mode = latched_mode;
      item.a = oprd1;
      item.b = oprd2;
      item.cin = latched_cin;
      if (latched_mode == 1'b1 && (latched_cmd == 4'b1001 || latched_cmd == 4'b1010)) begin
        item.delay_cycles = 3;
      end else begin
        item.delay_cycles = 2;
      end

      if (latched_mode == 1'b1) begin 
        case (latched_cmd)
          4'b0000: {exp_cout, exp_res[`DW-1:0]} = oprd1 + oprd2;
          4'b0001: begin
            exp_res[`DW-1:0] = oprd1 - oprd2;
            exp_oflow = (oprd1 < oprd2);
          end
          4'b0010: {exp_cout, exp_res[`DW-1:0]} = oprd1 + oprd2 + latched_cin;
          4'b0011: begin
            exp_res[`DW-1:0] = oprd1 - oprd2 - latched_cin;
            exp_oflow = (oprd1 < (oprd2 + latched_cin));
          end
          4'b0100: exp_res[`DW-1:0] = oprd1 + 1;
          4'b0101: exp_res[`DW-1:0] = oprd1 - 1;
          4'b0110: exp_res[`DW-1:0] = oprd2 + 1;
          4'b0111: exp_res[`DW-1:0] = oprd2 - 1;
          4'b1000: begin
            exp_e = (oprd1 == oprd2);
            exp_g = (oprd1 > oprd2);
            exp_l = (oprd1 < oprd2);
          end
          4'b1001: exp_res = ({1'b0, oprd1} + 1'b1) * ({1'b0, oprd2} + 1'b1);
          4'b1010: exp_res = ({oprd1, 1'b0}) * oprd2;
          default: exp_err = 1'b1;
        endcase
      end else begin 
exp_cout = 0; exp_oflow = 0; exp_g = 0; exp_e = 0; exp_l = 0;

        case (latched_cmd)
          4'b0000: exp_res = {{(2*`DW-`DW){1'b0}}, oprd1 & oprd2};
          4'b0001: exp_res = {{(2*`DW-`DW){1'b0}}, ~(oprd1 & oprd2)};
          4'b0010: exp_res = {{(2*`DW-`DW){1'b0}}, oprd1 | oprd2};
          4'b0011: exp_res = {{(2*`DW-`DW){1'b0}}, ~(oprd1 | oprd2)};
          4'b0100: exp_res = {{(2*`DW-`DW){1'b0}}, oprd1 ^ oprd2};
          4'b0101: exp_res = {{(2*`DW-`DW){1'b0}}, ~(oprd1 ^ oprd2)};
          4'b0110: exp_res = {{(2*`DW-`DW){1'b0}}, ~oprd1};
          4'b0111: exp_res = {{(2*`DW-`DW){1'b0}}, ~oprd2};
          4'b1000: exp_res = {{(2*`DW-`DW){1'b0}}, oprd1 >> 1};
          4'b1001: exp_res = {{(2*`DW-`DW){1'b0}}, oprd1 << 1};
          4'b1010: exp_res = {{(2*`DW-`DW){1'b0}}, oprd2 >> 1};
          4'b1011: exp_res = {{(2*`DW-`DW){1'b0}}, oprd2 << 1};
          4'b1100: begin 
            if (oprd2[7:4] != 4'b0000) exp_err = 1'b1;
            exp_res[`DW-1:0] = (oprd1 << oprd2[2:0]) | (oprd1 >> (`DW - oprd2[2:0]));
          end
          4'b1101: begin 
            if (oprd2[7:4] != 4'b0000) exp_err = 1'b1;
            exp_res[`DW-1:0] = (oprd1 >> oprd2[2:0]) | (oprd1 << (`DW - oprd2[2:0]));
          end
          default: exp_err = 1'b1;
        endcase
      end
      item.exp_res = exp_res;
      item.exp_cout = exp_cout;
      item.exp_oflow = exp_oflow;
      item.exp_g = exp_g;
      item.exp_e = exp_e;
      item.exp_l = exp_l;
      item.exp_err = exp_err;
      exp_pipeline.push_back(item);
      oprd1_valid = 0; oprd2_valid = 0;
    end
  endtask

  function void report_phase(uvm_phase phase);
    `uvm_info("SB_SUMMARY", $sformatf("Scoreboard results: %0d match, %0d mismatch, %0d still pending",
                num_match, num_mismatch, exp_pipeline.size()), UVM_NONE)
  endfunction
endclass
`endif

