`timescale 1ns/1ps

module tb;
parameter N = 8;
parameter CMD_W = 4;

reg CLK, RST, CIN, CE, MODE;
reg [1:0] INP_VALID;
reg [3:0] CMD;
reg [N-1:0] OPA, OPB;
wire [2*N-1:0] RES;
wire OFLOW, COUT, G, L, E, ERR;

// DUT instatiation
alicode #(N, CMD_W) DUT (
    .CLK(CLK), .RST(RST),.CIN(CIN),.CE(CE),.MODE(MODE),
    .INP_VALID(INP_VALID),
    .CMD(CMD),
    .OPA(OPA),.OPB(OPB),
    .RES(RES),.OFLOW(OFLOW),.COUT(COUT),
    .G(G), .L(L),.E(E), .ERR(ERR)
);

always #5 CLK = ~CLK;
initial begin
    CLK = 0; RST = 1;  CE  = 1; #10 RST = 0;

// Arithmetic Operations
    MODE = 1;
    INP_VALID = 2'b11;
    OPA = 3; OPB = 2; CIN = 0;
    CMD = 0; #10; $display("ADD= %0d (EXP=5)", RES);
    CMD = 1; #10; $display("SUB = %0d (EXP=1)", RES);
    CMD = 2; CIN = 0; #10; $display("ADD_CIN0 = %0d (EXP=5)", RES);
    CMD = 2; CIN = 1; #10; $display("ADD_CIN1= %0d (EXP=6)", RES);
    CMD = 3; CIN = 0; #10; $display("SUB_CIN0 = %0d (EXP=1)", RES);
    CMD = 3; CIN = 1; #10; $display("SUB_CIN = %0d (EXP=0)", RES);
    CMD = 4; OPA = 3; OPB= 4; #10; $display("INC_A  = %0d (EXP=4)", RES);
    CMD = 5; OPA = 0; OPB=0; #10; $display("DEC_A  = %0d (EXP=0-1)", RES);
    CMD = 6; OPB = 2; #10; $display("INC_B= %0d (EXP=3)", RES);
    CMD = 7; OPB = 2; #10; $display("DEC_B = %0d (EXP=1)", RES);
    CMD = 8; OPA = 5; OPB = 3; #10;
    $display("CMP G=%b L=%b E=%b (EXP=1 0 0)", G, L, E);
    MODE = 1;
    CMD = 9;
    OPA = 2; OPB = 3;
    repeat(3)
    #10;
    $display("MUL (A+1)*(B+1) = %0d (EXP=12)", RES);

    CMD = 10;
    OPA = 5; OPB = 2;
    repeat(3)
    #10;
    $display("MUL (A<<1)*B    = %0d (EXP=12)", RES);

   //Logic 
    MODE = 0;
    OPA = 4'b1010;
    OPB = 4'b1100;

    CMD = 0; #10; $display("AND  = %b (1000)", RES);
    CMD = 1; #10; $display("NAND= %b", RES);
    CMD = 2; #10; $display("OR = %b (1110)", RES);
    CMD = 3; #10; $display("NOR= %b", RES);
    CMD = 4; #10; $display("XOR = %b", RES);
    CMD = 5; #10; $display("XNOR  = %b", RES);
    CMD = 6; OPA = 4'b1010; #10; $display("NOT_A = %b (0101)", RES);
    CMD = 7; OPB = 4'b1100; #10; $display("NOT_B  = %b", RES);
    CMD = 8; OPA = 4'b1010; #10; $display("SHR1_A  = %b", RES);
    CMD = 9; #10; $display("SHL1_A  = %b", RES);
    CMD = 10; OPB = 4'b0110; #10; $display("SHR1_B = %b", RES);
    CMD = 11; #10; $display("SHL1_B = %b", RES);
    CMD = 12;
    OPA = 4'b1001;
    OPB = 4'b0000; #10; $display("ROL 0      = %b", RES);
    OPB = 4'b0001; #10; $display("ROL 1      = %b", RES);
    OPB = 4'b0011; #10; $display("ROL 3      = %b", RES);
    OPB = 4'b1001; #10; $display("ROL ERROR  = %b ERR=%b", RES, ERR);
    CMD = 13;
    OPA = 4'b1001;
    OPB = 4'b0001; #10; $display("ROR 1      = %b", RES);
    OPB = 4'b0010; #10; $display("ROR 2      = %b", RES);
    OPB = 4'b1110; #10; $display("ROR ERROR  = %b ERR=%b", RES, ERR);
    CMD = 4; OPA = 0; #10; $display("INC A   (zero)    = %0d", RES);
    CMD = 6; OPB = 4'b1111; #10; $display("INC MAX B  = %0d", RES);

    $finish;
end

endmodule
