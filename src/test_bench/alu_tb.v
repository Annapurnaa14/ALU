`timescale 1ns/1ps

module tb;
    parameter N     = 8;
    parameter CMD_W = 4;
    reg CLK, RST, CIN, CE, MODE;
    reg [1:0]   INP_VALID;
    reg [3:0]   CMD;
    reg [N-1:0] OPA, OPB;
    wire [2*N-1:0] RES;
    wire OFLOW, COUT, G, L, E, ERR;

 alucode #(N, CMD_W) DUT (
        .CLK(CLK), .RST(RST), .CIN(CIN), .CE(CE), .MODE(MODE),
        .INP_VALID(INP_VALID),
        .CMD(CMD),
        .OPA(OPA), .OPB(OPB),
        .RES(RES), .OFLOW(OFLOW), .COUT(COUT),
        .G(G), .L(L), .E(E), .ERR(ERR)
    );

    //  Scoreboard registers
    reg [2*N-1:0] exp_RES;
    reg           exp_G, exp_L, exp_E, exp_ERR;
    integer       pass_cnt, fail_cnt, tid;

    task driver;
        input            mode_in;
        input [3:0]      cmd_in;
        input [N-1:0]    opa_in, opb_in;
        input            cin_in;
        input [1:0]      iv_in;
        input integer    extra_clks;   // 0 = single cycle, >0 = multicycle
        begin
            @(posedge CLK);
            MODE      = mode_in;
            CMD       = cmd_in;
            OPA       = opa_in;
            OPB       = opb_in;
            CIN       = cin_in;
            INP_VALID = iv_in;
            CE        = 1;
            repeat(extra_clks) @(posedge CLK);
        end
    endtask

   
     task monitor;
        input [8*20:1] label;
        begin
            @(posedge CLK); #1;
            $display("[MON]  %-20s  RES=%0d(%b)  COUT=%b OFLOW=%b  G=%b L=%b E=%b ERR=%b",
                      label, RES, RES, COUT, OFLOW, G, L, E, ERR);
        end
    endtask

     task scoreboard;
        begin
            if (RES   === exp_RES  &&
                G     === exp_G    &&
                L     === exp_L    &&
                E     === exp_E    &&
                ERR   === exp_ERR) begin
                $display("[PASS] Test#%0d  RES=%0d G=%b L=%b E=%b ERR=%b",
                          tid, RES, G, L, E, ERR);
                pass_cnt = pass_cnt + 1;
            end else begin
                $display("[FAIL] Test#%0d", tid);
                $display("       GOT  RES=%0d G=%b L=%b E=%b ERR=%b",
                          RES, G, L, E, ERR);
                $display("       EXP  RES=%0d G=%b L=%b E=%b ERR=%b",
                          exp_RES, exp_G, exp_L, exp_E, exp_ERR);
                fail_cnt = fail_cnt + 1;
            end
            tid = tid + 1;
        end
    endtask

    initial begin
        CLK = 0; RST = 1; CE = 1;
        pass_cnt = 0; fail_cnt = 0; tid = 0;
        #10; RST = 0;

        // ============================================================
        //  ARITHMETIC  (MODE=1)
        // ============================================================
        $display("\n--- ARITHMETIC ---");

        // ADD: 3+2=5
        driver(1, 4'd0, 8'd3, 8'd2, 1'b0, 2'b11, 0);
        monitor("ADD");
        exp_RES=16'd5; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // SUB: 3-2=1
        driver(1, 4'd1, 8'd3, 8'd2, 1'b0, 2'b11, 0);
        monitor("SUB");
        exp_RES=16'd1; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // ADD_CIN CIN=0: 3+2+0=5
        driver(1, 4'd2, 8'd3, 8'd2, 1'b0, 2'b11, 0);
        monitor("ADD_CIN0");
        exp_RES=16'd5; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // ADD_CIN CIN=1: 3+2+1=6
        driver(1, 4'd2, 8'd3, 8'd2, 1'b1, 2'b11, 0);
        monitor("ADD_CIN1");
        exp_RES=16'd6; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // SUB_CIN CIN=0: 3-2-0=1
        driver(1, 4'd3, 8'd3, 8'd2, 1'b0, 2'b11, 0);
        monitor("SUB_CIN0");
        exp_RES=16'd1; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // SUB_CIN CIN=1: 3-2-1=0
        driver(1, 4'd3, 8'd3, 8'd2, 1'b1, 2'b11, 0);
        monitor("SUB_CIN1");
        exp_RES=16'd0; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // INC_A: OPA=3 => 4
        driver(1, 4'd4, 8'd3, 8'd4, 1'b0, 2'b11, 0);
        monitor("INC_A");
        exp_RES=16'd4; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // DEC_A: OPA=0 => wraps to 0xFF
        driver(1, 4'd5, 8'd0, 8'd0, 1'b0, 2'b11, 0);
        monitor("DEC_A");
        exp_RES=16'h00FF; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // INC_B: OPB=2 => 3
        driver(1, 4'd6, 8'd0, 8'd2, 1'b0, 2'b11, 0);
        monitor("INC_B");
        exp_RES=16'd3; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // DEC_B: OPB=2 => 1
        driver(1, 4'd7, 8'd0, 8'd2, 1'b0, 2'b11, 0);
        monitor("DEC_B");
        exp_RES=16'd1; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // CMP: OPA=5 > OPB=3 => G=1
        driver(1, 4'd8, 8'd5, 8'd3, 1'b0, 2'b11, 0);
        monitor("CMP");
        exp_RES=16'd0; exp_G=1; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // MUL (A+1)*(B+1): 3*4=12
        driver(1, 4'd9, 8'd2, 8'd3, 1'b0, 2'b11, 2);
        monitor("MUL (A+1)*(B+1)");
        exp_RES=16'd12; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // MUL (A<<1)*B: 10*2=20
        driver(1, 4'd10, 8'd5, 8'd2, 1'b0, 2'b11, 2);
        monitor("MUL (A<<1)*B");
        exp_RES=16'd20; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // ============================================================
        //  LOGIC  (MODE=0)
        // ============================================================
        $display("\n--- LOGIC ---");

        // AND: 0xA & 0xC = 0x8
        driver(0, 4'd0, 8'b0000_1010, 8'b0000_1100, 1'b0, 2'b11, 0);
        monitor("AND");
        exp_RES=16'h0008; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // NAND: ~(0xA & 0xC)
        driver(0, 4'd1, 8'b0000_1010, 8'b0000_1100, 1'b0, 2'b11, 0);
        monitor("NAND");
        exp_RES=16'hFFF7; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // OR: 0xA | 0xC = 0xE
        driver(0, 4'd2, 8'b0000_1010, 8'b0000_1100, 1'b0, 2'b11, 0);
        monitor("OR");
        exp_RES=16'h000E; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // NOR: ~(0xA | 0xC)
        driver(0, 4'd3, 8'b0000_1010, 8'b0000_1100, 1'b0, 2'b11, 0);
        monitor("NOR");
        exp_RES=16'hFFF1; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // XOR: 0xA ^ 0xC = 0x6
        driver(0, 4'd4, 8'b0000_1010, 8'b0000_1100, 1'b0, 2'b11, 0);
        monitor("XOR");
        exp_RES=16'h0006; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // XNOR: ~(0xA ^ 0xC)
        driver(0, 4'd5, 8'b0000_1010, 8'b0000_1100, 1'b0, 2'b11, 0);
        monitor("XNOR");
        exp_RES=16'hFFF9; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // NOT_A: ~8'b1010 = 8'hF5
        driver(0, 4'd6, 8'b1010, 8'b1100, 1'b0, 2'b11, 0);
        monitor("NOT_A");
        exp_RES=16'h00F5; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // NOT_B: ~8'b1100 = 8'hF3
        driver(0, 4'd7, 8'b1010, 8'b1100, 1'b0, 2'b11, 0);
        monitor("NOT_B");
        exp_RES=16'h00F3; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // SHR1_A: 8'b1010 >> 1 = 0x05
        driver(0, 4'd8, 8'b1010, 8'b1100, 1'b0, 2'b11, 0);
        monitor("SHR1_A");
        exp_RES=16'h0005; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // SHL1_A: 8'b1010 << 1 = 0x14
        driver(0, 4'd9, 8'b1010, 8'b1100, 1'b0, 2'b11, 0);
        monitor("SHL1_A");
        exp_RES=16'h0014; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // SHR1_B: 8'b0110 >> 1 = 0x03
        driver(0, 4'd10, 8'b1010, 8'b0110, 1'b0, 2'b11, 0);
        monitor("SHR1_B");
        exp_RES=16'h0003; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // SHL1_B: 8'b0110 << 1 = 0x0C
        driver(0, 4'd11, 8'b1010, 8'b0110, 1'b0, 2'b11, 0);
        monitor("SHL1_B");
        exp_RES=16'h000C; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // ROL 0: 8'b1001 rotate left 0 => 8'b1001
        driver(0, 4'd12, 8'b1001, 8'b0000, 1'b0, 2'b11, 0);
        monitor("ROL 0");
        exp_RES=16'h0009; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // ROL 1: 8'b0000_1001 <<< 1 => 8'b0001_0010
        driver(0, 4'd12, 8'b0000_1001, 8'b0001, 1'b0, 2'b11, 0);
        monitor("ROL 1");
        exp_RES=16'h0012; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // ROL 3: 8'b0000_1001 <<< 3 => 8'b0100_1000
        driver(0, 4'd12, 8'b0000_1001, 8'b0011, 1'b0, 2'b11, 0);
        monitor("ROL 3");
        exp_RES=16'h0048; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // ROL ERROR: OPB=9 > N => ERR=1
        driver(0, 4'd12, 8'b1001, 8'b1001, 1'b0, 2'b11, 0);
        monitor("ROL ERROR");
        exp_RES=16'h0000; exp_G=0; exp_L=0; exp_E=0; exp_ERR=1;
        scoreboard;

        // ROR 1: 8'b0000_1001 >>> 1 => 8'b1000_0100
        driver(0, 4'd13, 8'b0000_1001, 8'b0001, 1'b0, 2'b11, 0);
        monitor("ROR 1");
        exp_RES=16'h0084; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // ROR 2: 8'b0000_1001 >>> 2 => 8'b0100_0010
        driver(0, 4'd13, 8'b0000_1001, 8'b0010, 1'b0, 2'b11, 0);
        monitor("ROR 2");
        exp_RES=16'h0042; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // ROR ERROR: OPB=14 > N => ERR=1
        driver(0, 4'd13, 8'b1001, 8'b1110, 1'b0, 2'b11, 0);
        monitor("ROR ERROR");
        exp_RES=16'h0000; exp_G=0; exp_L=0; exp_E=0; exp_ERR=1;
        scoreboard;

        // INC A zero (CMD=4 logic=XOR): 0^0=0
        driver(0, 4'd4, 8'd0, 8'd0, 1'b0, 2'b11, 0);
        monitor("INC A zero (XOR)");
        exp_RES=16'h0000; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

        // INC MAX B (CMD=6 logic=NOT_B): ~0xFF = 0x00
        driver(0, 4'd6, 8'd0, 8'hFF, 1'b0, 2'b11, 0);
        monitor("INC MAX B (NOT_B)");
        exp_RES=16'h0000; exp_G=0; exp_L=0; exp_E=0; exp_ERR=0;
        scoreboard;

       repeat(5) @(posedge CLK);
        $display("\n========================================");
        $display("  SCOREBOARD SUMMARY");
        $display("  PASS : %0d", pass_cnt);
        $display("  FAIL : %0d", fail_cnt);
        $display("========================================\n");
        $finish;
    end

endmodule
