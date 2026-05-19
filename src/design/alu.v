`timescale 1ns / 1ps
module alucode #(parameter N = 4, parameter CMD_W = 4)
(
    input  wire CLK, RST, CIN, CE, MODE,
    input  wire [1:0] INP_VALID,
    input  wire [CMD_W-1:0] CMD,
    input  wire [N-1:0] OPA, OPB,
    output reg  [2*N-1:0] RES,
    output reg  OFLOW, COUT, G, L, E, ERR
);

    localparam ROT_BITS = $clog2(N);

    reg [N-1:0] a, b;
    reg [2*N-1:0] result;
    reg cout, oflow, g, l, e, err;

    reg [N-1:0] mul_A0, mul_B0;
    reg [CMD_W-1:0] mul_CMD0;
    reg [2*N-1:0] mul_RES1;
    reg mul_valid0, mul_valid1;

    always @(*) begin
        result = 0;
        cout   = 0;
        oflow  = 0;
        g      = 0;
        l      = 0;
        e      = 0;
        err    = 0;

        case (INP_VALID)
            2'b01: begin a = OPA; b = 0; end
            2'b10: begin a = 0;   b = OPB; end
            2'b11: begin a = OPA; b = OPB; end
            default: begin a = 0; b = 0; end
        endcase

        // ---------------- ARITHMETIC  = MODE 1 ----------------
        if (MODE) begin
            case (CMD)

                0: begin
                    if (INP_VALID == 2'b11) begin
                        result = a + b;
                        cout = result[N];
                    end else err = 1;
                end

                1: begin
                    if (INP_VALID == 2'b11) begin
                        result = a - b;
                        oflow = (a < b);
                    end else err = 1;
                end

                2: begin
                    if (INP_VALID == 2'b11) begin
                        result = a + b + CIN;
                        cout = result[N];
                    end else err = 1;
                end

              3: begin
                if (INP_VALID == 2'b11) begin
                    result = a - b - CIN;
                    oflow = (a < (b + CIN));
                end
                else err = 1;
                end

                4: begin
                    if (INP_VALID == 2'b01 || INP_VALID == 2'b11)
                        result = a + 1;
                    else err = 1;
                end

                5: begin
                    if (INP_VALID == 2'b01 || INP_VALID == 2'b11)
                        result = a - 1;
                    else err = 1;
                end

                6: begin
                    if (INP_VALID == 2'b10 || INP_VALID == 2'b11)
                    result = b + 1;
                    else err = 1;
                end

                7: begin
                    if (INP_VALID == 2'b10 || INP_VALID == 2'b11)
                        result = b - 1;
                    else err = 1;
                end

                8: begin
                    if (INP_VALID == 2'b11) begin
                        g = (a > b);
                        l = (a < b);
                        e = (a == b);
                    end else err = 1;
                end

                11: begin
               if (INP_VALID == 2'b11) begin
                 result = $signed(a) + $signed(b);
                oflow = (a[N-1] == b[N-1]) && (result[N-1] != a[N-1]);
                end
                else err = 1;
            end

            12: begin
                if (INP_VALID == 2'b11) begin
                    result = $signed(a) - $signed(b);
                    oflow = (a[N-1] != b[N-1]) && (result[N-1] != a[N-1]);
                end
                else err = 1;
            end        

                default: err = 1;

            endcase
        end

        // ---------------- LOGICAL = MODE 0 ----------------
        else begin
            case (CMD)

                0: begin
                    if (INP_VALID == 2'b11) result = a & b;
                    else err = 1;
                end

                1: begin
                    if (INP_VALID == 2'b11) result = ~(a & b);
                    else err = 1;
                end

                2: begin
                    if (INP_VALID == 2'b11) result = a | b;
                    else err = 1;
                end

                3: begin
                    if (INP_VALID == 2'b11) result = ~(a | b);
                    else err = 1;
                end

                4: begin
                    if (INP_VALID == 2'b11) result = a ^ b;
                    else err = 1;
                end

                5: begin
                    if (INP_VALID == 2'b11) result = ~(a ^ b);
                    else err = 1;
                end

                6: begin
                    if (INP_VALID == 2'b01 || INP_VALID == 2'b11) result = ~a;
                    else err = 1;
                end

                7: begin
                    if (INP_VALID == 2'b10 || INP_VALID == 2'b11) result = ~b;
                    else err = 1;
                end

                8: begin
                if (INP_VALID == 2'b01 || INP_VALID == 2'b11)
                    result = a >> 1;
                else err = 1;
                end

            9: begin
                if (INP_VALID == 2'b01 || INP_VALID == 2'b11)
                    result = a << 1;
                    else err = 1;
                end

        10: begin
            if (INP_VALID == 2'b10 || INP_VALID == 2'b11)
               result = b >> 1;
                else err = 1;
            end

        11: begin
            if (INP_VALID == 2'b10 || INP_VALID == 2'b11)
                result = b << 1;
                else err = 1;
        end

        12: begin
    if ((INP_VALID == 2'b11) &&
        (b[N-1:ROT_BITS] == {(N-ROT_BITS){1'b0}}))
    begin
        result = (a << b[ROT_BITS-1:0]) |
                 (a >> (N - b[ROT_BITS-1:0]));
    end
    else begin
        err = 1;
        result = (a << b[ROT_BITS-1:0]) |
                 (a >> (N - b[ROT_BITS-1:0]));
    end
end

13: begin
    if ((INP_VALID == 2'b11) &&
        (b[N-1:ROT_BITS] == {(N-ROT_BITS){1'b0}}))
    begin
        result = (a >> b[ROT_BITS-1:0]) |
                 (a << (N - b[ROT_BITS-1:0]));
    end
    else begin
        err = 1;
        result = (a >> b[ROT_BITS-1:0]) |
                 (a << (N - b[ROT_BITS-1:0]));
    end
end
                default: err = 1;

            endcase
        end
    end

    always @(posedge CLK or posedge RST) begin
     if (RST) begin
    RES <= 0;
    COUT <= 0;
    OFLOW <= 0;
    G <= 0;
    L <= 0;
    E <= 0;
    ERR <= 0;

    mul_A0 <= 0;
    mul_B0 <= 0;
    mul_CMD0 <= 0;
    mul_RES1 <= 0;
    mul_valid0 <= 0;
    mul_valid1 <= 0;
end

        else if (CE) begin

            // stage 1
            if (MODE && INP_VALID == 2'b11 && (CMD == 4'd9 || CMD == 4'd10)) begin
                mul_A0 <= OPA;
                mul_B0 <= OPB;
                mul_CMD0 <= CMD;
                mul_valid0 <= 1;
            end
            else begin
                mul_valid0 <= 0;
            end

            // stage 2
            mul_valid1 <= mul_valid0;

            if (mul_valid0) begin
                if (mul_CMD0 == 4'd9)
                    mul_RES1 <= (mul_A0 + 1) * (mul_B0 + 1);
                else
                    mul_RES1 <= (mul_A0 << 1) * mul_B0;
            end

            // stage 3
            if (mul_valid1) begin
                RES <= mul_RES1;
                COUT <= 0;
                OFLOW <= 0;
                G <= 0;
                L <= 0;
                E <= 0;
                ERR <= 0;
            end

            else if (!(MODE && (CMD == 4'd9 || CMD == 4'd10))) begin
                RES <= result;
                COUT <= cout;
                OFLOW <= oflow;
                G <= g;
                L <= l;
                E <= e;
                ERR <= err;
            end
        end
    end

endmodule
