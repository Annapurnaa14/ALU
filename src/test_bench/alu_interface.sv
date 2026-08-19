`include "defines.svh"
interface alu_if(input bit clk);
 logic[`DW-1:0]OPA;
 logic[`DW-1:0]OPB;
 logic[`CW-1:0]CMD;
 logic[1:0]INP_VALID;
 logic RST,CE,MODE,CIN,COUT,OFLOW,G,E,L,ERR;;
 logic [(2*`DW)-1:0]RES;


clocking drv_cb@(posedge clk);
 default input #1 output #1;
 output OPA,OPB,RST,CE,MODE,CMD,INP_VALID,CIN;
endclocking


clocking inp_mon_cb@(posedge clk);
 default input #1 output #1;
  input OPA,OPB,RST,CE,MODE,CMD,INP_VALID,CIN;
endclocking

clocking out_mon_cb@(posedge clk);
 default input #1 output #1;
 input OPA,OPB,RST,CE,MODE,CMD,INP_VALID,CIN,ERR,RES,OFLOW;
 input G,E,L,COUT;
endclocking


modport DRVR(clocking drv_cb);
modport INP_MONI(clocking inp_mon_cb);
modport OUT_MONI(clocking out_mon_cb);


endinterface
