`timescale 1ns / 1ps
module tb_dsp();
    parameter WIDTH_OP1 = 18;
    parameter WIDTH_OP2 = 25;
    parameter WIDTH_OUT = 48;
    parameter CLK_PERIOD=10;
    integer rand_value1;
    integer rand_value2;
    integer partial_sum;
    
    integer cycle;
    
    reg RSTN;
    reg CLK;
    reg EN;
    reg ACC_EN;
    reg ACC_IN_EN;
    reg signed [WIDTH_OP1-1:0] OP1;
    reg signed [WIDTH_OP2-1:0] OP2;
    
    wire signed [WIDTH_OUT-1:0] OUT;
DSP #(
    .WIDTH_OP1(WIDTH_OP1),
    .WIDTH_OP2(WIDTH_OP2),
    .WIDTH_OUT(WIDTH_OUT)
) dsp_instance (
    .CLK(CLK),
    .RSTN(RSTN),
    .EN(EN),
    .ACC_EN(ACC_EN),
    .ACC_IN_EN(ACC_IN_EN),
    .OP1(OP1),
    .OP2(OP2),
    .ACC(),
    .OUT(OUT)
);

initial begin
    CLK=0;
    forever #(CLK_PERIOD/2) CLK = ~CLK;
end



initial begin
    cycle=0;
    partial_sum=0;
    RSTN=0;
    EN=1;
    ACC_EN=0;
    ACC_IN_EN=0;
    OP1=0;
    OP2=0;   
    
    
    #15 RSTN = 1;
    #20 RSTN = 0;
    #20 RSTN = 1;
    #10 ACC_EN=1;
    
    repeat(11)begin
        partial_sum= partial_sum+OP1*OP2;
        rand_value1 = $random % 32;
        rand_value2 = $random % 32;
        #10 OP1=rand_value1 ; OP2=rand_value2;
        cycle=cycle+1;
    end
    OP1=0; OP2=0;
    
    @(posedge CLK);
    @(posedge CLK);
    @(posedge CLK);
    @(posedge CLK);
    $display("test: %d ,Ideal: %d", OUT, partial_sum);
    $finish;
    
end


endmodule
