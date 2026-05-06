module aludesign #(parameter N = 4) (OPA, OPB, INP_VALID, CIN, CLK, RST, CMD, CE, MODE,COUT, OFLOW, RES, G, E, L, ERR);

input  [N-1:0] OPA, OPB;
input  CLK, RST, CE, MODE, CIN;
input  [1:0] INP_VALID;
input  [3:0] CMD;

output reg [2*N-1:0] RES={2*N{1'b0}};
output reg COUT  = 1'b0;
output reg OFLOW = 1'b0;
output reg G = 1'b0;
output reg E = 1'b0;
output reg L  = 1'b0;
output reg ERR = 1'b0;

reg [N-1:0] OPA_1, OPB_1;
reg signed [N:0]   signedOPA_ext, signedOPB_ext;
reg signed [N+1:0] signedRES;
reg [N-1:0]   Mul_OPA, Mul_OPB;
reg [2*N-1:0] Mul_RES;
reg M1active, M2active;

wire [N:0] add_result;
wire [N:0] add_withc_result;
assign add_result  = {1'b0, OPA_1} + {1'b0, OPB_1};
assign add_withc_result = {1'b0, OPA_1} + {1'b0, OPB_1} + {{N{1'b0}}, CIN};

always @(*) begin
    OPA_1 = {N{1'b0}};
    OPB_1 = {N{1'b0}};
    if (CE) begin
        if (INP_VALID[0]) OPA_1 = OPA;
        if (INP_VALID[1]) OPB_1 = OPB;
    end
end

always @(posedge CLK or posedge RST) begin
    if (RST) begin
        RES <= {2*N{1'b0}};
        COUT<= 1'b0;
        OFLOW  <= 1'b0;
        G  <= 1'b0;
        E <= 1'b0;
        L  <= 1'b0;
        ERR  <= 1'b0;
        Mul_OPA  <= {N{1'b0}};
        Mul_OPB  <= {N{1'b0}};
        Mul_RES  <= {2*N{1'b0}};
        M1active <= 1'b0;
        M2active <= 1'b0;
    end
    else if (CE) begin
        M2active <= M1active;
        Mul_RES  <= Mul_OPA * Mul_OPB;
		
        if (CMD == 4'b1001 && MODE == 1'b1) begin
            Mul_OPA  <= OPA_1 + 1'b1;
            Mul_OPB  <= OPB_1 + 1'b1;
            M1active <= 1'b1;
        end else begin
            M1active <= 1'b0;
        end

        if (MODE) begin
            RES   <= {2*N{1'b0}};
            COUT  <= 1'b0;
            OFLOW <= 1'b0;
            G     <= 1'b0;
            E     <= 1'b0;
            L     <= 1'b0;
            ERR   <= 1'b0;

            case (CMD)
                4'b0000: begin
                    if (INP_VALID == 2'b11) begin
                        RES  <= {{N{1'b0}}, add_result[N-1:0]};
                        COUT <= add_result[N];
                    end
                end

                4'b0001: begin
                    if (INP_VALID == 2'b11) begin
                        OFLOW <= (OPA_1 < OPB_1) ? 1'b1 : 1'b0;
                        RES   <= {{N{1'b0}}, OPA_1 - OPB_1};
                    end
                end

                4'b0010: begin
                    if (INP_VALID == 2'b11) begin
                        RES  <= {{N{1'b0}}, addc_result[N-1:0]};
                        COUT <= addc_result[N];
                    end
                end

                4'b0011: begin
                    if (INP_VALID == 2'b11) begin
                        OFLOW <= (OPA_1 < OPB_1) ? 1'b1 : 1'b0;
                        RES   <= {{N{1'b0}}, OPA_1 - OPB_1 - {{N-1{1'b0}}, CIN}};
                    end
                end

                4'b0100: begin
                    if ((INP_VALID == 2'b11) || (INP_VALID == 2'b01))
                        RES <= {{N{1'b0}}, OPA_1 + 1'b1};
                end

                4'b0101: begin
                    if ((INP_VALID == 2'b11) || (INP_VALID == 2'b01))
                        RES <= {{N{1'b0}}, OPA_1 - 1'b1};
                    else
                        ERR <= 1'b1;
                end

                4'b0110: begin
                    if (INP_VALID == 2'b10)
                        RES <= {{N{1'b0}}, OPB_1 + 1'b1};
                end

                4'b0111: begin
                    if (INP_VALID == 2'b10)
                        RES <= {{N{1'b0}}, OPB_1 - 1'b1};
                end

                4'b1000: begin
                    RES <= {2*N{1'b0}};
                    if (OPA_1 == OPB_1) begin
                        E <= 1'b1; G <= 1'b0; L <= 1'b0;
                    end else if (OPA_1 > OPB_1) begin
                        E <= 1'b0; G <= 1'b1; L <= 1'b0;
                    end else begin
                        E <= 1'b0; G <= 1'b0; L <= 1'b1;
                    end
                end

                4'b1001: begin
                    if (M2active)
                        RES <= Mul_RES;
                end

                4'b1010: begin
                    if (INP_VALID == 2'b11)
                        RES <= ({{N{1'b0}}, OPA_1} << 1) * {{N{1'b0}}, OPB_1};
                end

                4'b1011: begin
                    if (INP_VALID == 2'b11) begin
                        signedOPA_ext = $signed({{1'b0}, OPA_1});
                        signedOPB_ext = $signed({{1'b0}, OPB_1});
                        signedRES     = signedOPA_ext + signedOPB_ext;
                        RES   <= {{N{1'b0}}, signedRES[N-1:0]};
                        COUT  <= signedRES[N];
                        OFLOW <=(OPA_1[N-1] == OPB_1[N-1]) && (signedRES[N-1] != OPA_1[N-1]);

                        if ($signed(OPA_1) > $signed(OPB_1)) begin
                            G <= 1'b1; E <= 1'b0; L <= 1'b0;
                        end else if ($signed(OPA_1) == $signed(OPB_1)) begin
                            G <= 1'b0; E <= 1'b1; L <= 1'b0;
                        end else begin
                            G <= 1'b0; E <= 1'b0; L <= 1'b1;
                        end
                    end
                end

                4'b1100: begin
                    if (INP_VALID == 2'b11) begin
                        signedOPA_ext = $signed({{1'b0}, OPA_1});
                        signedOPB_ext = $signed({{1'b0}, OPB_1});
                        signedRES     = signedOPA_ext - signedOPB_ext;
                        RES   <= {{N{1'b0}}, signedRES[N-1:0]};
                        COUT  <= signedRES[N];
                        OFLOW <= (OPA_1[N-1] != OPB_1[N-1]) && (signedRES[N-1] != OPA_1[N-1]);

                        if ($signed(OPA_1) > $signed(OPB_1)) begin
                            G <= 1'b1; E <= 1'b0; L <= 1'b0;
                        end else if ($signed(OPA_1) == $signed(OPB_1)) begin
                            G <= 1'b0; E <= 1'b1; L <= 1'b0;
                        end else begin
                            G <= 1'b0; E <= 1'b0; L <= 1'b1;
                        end
                    end
                end

                default: begin
                    RES   <= {2*N{1'b0}};
                    COUT  <= 1'b0;
                    OFLOW <= 1'b0;
                    G     <= 1'b0;
                    E     <= 1'b0;
                    L     <= 1'b0;
                    ERR   <= 1'b0;
                end

            endcase

        end
        else begin
            RES   <= {2*N{1'b0}};
            COUT  <= 1'b0;
            OFLOW <= 1'b0;
            G     <= 1'b0;
            E     <= 1'b0;
            L     <= 1'b0;
            ERR   <= 1'b0;

            case (CMD)
                4'b0000: RES <= {{N{1'b0}}, OPA_1 & OPB_1};
                4'b0001: RES <= {{N{1'b0}}, ~(OPA_1 & OPB_1)};
                4'b0010: RES <= {{N{1'b0}}, OPA_1 | OPB_1};
                4'b0011: RES <= {{N{1'b0}}, ~(OPA_1 | OPB_1)};
                4'b0100: RES <= {{N{1'b0}}, OPA_1 ^ OPB_1};
                4'b0101: RES <= {{N{1'b0}}, ~(OPA_1 ^ OPB_1)};
                4'b0110: RES <= {{N{1'b0}}, ~OPA_1};
                4'b0111: RES <= {{N{1'b0}}, ~OPB_1};
                4'b1000: RES <= {{N{1'b0}}, OPA_1 >> 1};
                4'b1001: RES <= {{N{1'b0}}, OPA_1 << 1};
                4'b1010: RES <= {{N{1'b0}}, OPB_1 >> 1};
                4'b1011: RES <= {{N{1'b0}}, OPB_1 << 1};

                4'b1100: begin
                    ERR <= (OPB_1[N-1:3] != {(N-3){1'b0}}) ? 1'b1 : 1'b0;
                    if (OPB_1[2:0] == 3'b000)
                        RES <= {{N{1'b0}}, OPA_1};
                    else
                        RES <= {{N{1'b0}},
                                (OPA_1 << OPB_1[2:0]) | (OPA_1 >> (N - OPB_1[2:0]))};
                end

                4'b1101: begin
                    ERR <= (OPB_1[N-1:3] != {(N-3){1'b0}}) ? 1'b1 : 1'b0;
                    if (OPB_1[2:0] == 3'b000)
                        RES <= {{N{1'b0}}, OPA_1};
                    else
                        RES <= {{N{1'b0}},
                                (OPA_1 >> OPB_1[2:0]) | (OPA_1 << (N - OPB_1[2:0]))};
                end

                default: begin
                    RES   <= {2*N{1'b0}};
                    COUT  <= 1'b0;
                    OFLOW <= 1'b0;
                    G     <= 1'b0;
                    E     <= 1'b0;
                    L     <= 1'b0;
                    ERR   <= 1'b0;
                end

            endcase
        end

    end
end

endmodule
