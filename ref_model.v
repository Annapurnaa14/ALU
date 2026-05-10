module ref_model #(parameter N = 4, parameter CMD_W = 4);
    reg MODE , CIN;
    reg [1:0] INP_VALID;
    reg [CMD_W-1:0] CMD;
    reg [N-1:0] OPA, OPB;

  //registers to store expected outputs
    reg [2*N-1:0] exp_RES={2*N{1'b0}};
    reg exp_COUT=1'b0, exp_OFLOW=1'b0, exp_G=1'b0, exp_L=1'b0, exp_E=1'b0, exp_ERR=1'b0;

    //multiplication - pipelining registers
    reg [2*N-1:0] pipe_res [0:2];
    reg pipe_cout [0:2];
    reg pipe_oflow [0:2];
    reg pipe_g [0:2];
    reg pipe_l [0:2];
    reg pipe_e [0:2];
    reg pipe_err [0:2];

    integer i;

    task compute;
        begin
            exp_RES = 0;
            exp_COUT = 0;
            exp_OFLOW = 0;
            exp_G = 0;
            exp_L = 0;
            exp_E = 0;
            exp_ERR = 0;

            if (MODE) begin
                case (CMD)
                    0: if (INP_VALID==2'b11) exp_RES = OPA + OPB;
                    1: if (INP_VALID==2'b11) exp_RES = OPA - OPB;
                    2: if (INP_VALID==2'b11) exp_RES = OPA + OPB + CIN;
                    3: if (INP_VALID==2'b11) exp_RES = OPA - OPB - CIN;
                    4: exp_RES = OPA + 1;
                    5: exp_RES = OPA - 1;
                    6: exp_RES = OPB + 1;
                    7: exp_RES = OPB - 1;
                    8: begin
                        exp_G = (OPA > OPB);
                        exp_L = (OPA < OPB);
                        exp_E = (OPA == OPB);
                    end
                    9:  exp_RES = (OPA + 1) * (OPB + 1);
                    10: exp_RES = (OPA << 1) * OPB;
                    default: exp_ERR = 1;
                endcase
            end
          
            else 
              begin
                case (CMD)
                    0: exp_RES = OPA & OPB;
                    1: exp_RES = ~(OPA & OPB);
                    2: exp_RES = OPA | OPB;
                    3: exp_RES = ~(OPA | OPB);
                    4: exp_RES = OPA ^ OPB;
                    5: exp_RES = ~(OPA ^ OPB);
                    6: exp_RES = ~OPA;
                    7: exp_RES = ~OPB;
                    default: exp_ERR = 1;
                endcase
            end
        end
    endtask


  // to create 3 cycle delays
    task shift_pipeline;
        begin
            for (i = 2; i > 0; i = i - 1) begin
                pipe_res[i]   = pipe_res[i-1];
                pipe_cout[i]  = pipe_cout[i-1];
                pipe_oflow[i] = pipe_oflow[i-1];
                pipe_g[i]     = pipe_g[i-1];
                pipe_l[i]     = pipe_l[i-1];
                pipe_e[i]     = pipe_e[i-1];
                pipe_err[i]   = pipe_err[i-1];
            end

            pipe_res[0]   = exp_RES;
            pipe_cout[0]  = exp_COUT;
            pipe_oflow[0] = exp_OFLOW;
            pipe_g[0]     = exp_G;
            pipe_l[0]     = exp_L;
            pipe_e[0]     = exp_E;
            pipe_err[0]   = exp_ERR;
        end
    endtask

endmodule
