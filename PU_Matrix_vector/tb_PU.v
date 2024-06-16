`timescale 1ns / 1ps

module tb_PU();
localparam WIDTH_OP1 = 16;
localparam WIDTH_OP2 = 16;
localparam WIDTH_OUT = 32;
localparam MATRIX_ROW = 8;
localparam MATRIX_COL = 16;

localparam CLOCK_PERIOD = 10;

reg signed [WIDTH_OP1-1:0]                     TB_A;
reg signed [WIDTH_OP2-1:0]                     TB_B[MATRIX_ROW-1:0];
reg signed [WIDTH_OUT-1:0]                     TB_PARTIAL_SUM[MATRIX_ROW-1:0];

reg [WIDTH_OP1-1:0]                     A;
reg [WIDTH_OP2 * MATRIX_ROW-1:0]        B;
reg                                     CLK;
reg                                     START;
reg                                     RSTN;

wire [WIDTH_OUT*MATRIX_ROW-1:0]         OUT;
wire                                    DONE;


PU #(
    .WIDTH_OP1(WIDTH_OP1),
    .WIDTH_OP2(WIDTH_OP2),
    .WIDTH_OUT(WIDTH_OUT),
    .MATRIX_ROW(MATRIX_ROW),
    .MATRIX_COL(MATRIX_COL)
) pu_inst (
    .A(A),
    .B(B),
    .START(START),
    .CLK(CLK),
    .RSTN(RSTN),
    .OUT(OUT),
    .DONE(DONE)
);

initial begin
    CLK = 0;
    forever #(CLOCK_PERIOD/2) CLK = ~CLK;
end

integer i;

initial begin
    for (i = 0; i < MATRIX_ROW ; i = i + 1) begin
        TB_PARTIAL_SUM[i] = 0;
    end
    A=0;
    B=0;
    CLK=0;
    START=0;
    RSTN=0;

    #30 RSTN=1;
    @(posedge CLK);
    START= 1;
    @(posedge CLK);

    repeat(16) begin
        @(posedge CLK);
        #5;
        A = $random % 32;
        TB_A = A;
        for (i = 0; i < MATRIX_ROW ; i = i + 1) begin
            B[WIDTH_OP1*i +: WIDTH_OP1] = $random % 32;
            TB_B[i] = B[WIDTH_OP1*i +: WIDTH_OP1];
            TB_PARTIAL_SUM[i] = TB_PARTIAL_SUM[i] + TB_A * TB_B[i];
        end
    end
end






endmodule
