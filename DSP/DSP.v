/*

DSP #(
    .WIDTH_OP1(),
    .WIDTH_OP2(),
    .WIDTH_OUT()
) dsp_instance (
    .CLK(),
    .RSTN(),
    .EN(),
    .ACC_EN(),
    .ACC_IN_EN(),
    .OP1(),
    .OP2(),
    .ACC(),
    .OUT()
);


*/

module DSP#(
    parameter WIDTH_OP1 = 18,
    parameter WIDTH_OP2 = 18,
    parameter WIDTH_OUT = 48
)
(
    input   wire                         CLK,
    input   wire                         RSTN,
    input   wire                         EN,
    input   wire                         ACC_EN, // 2 cycle delayed
    input   wire                         ACC_IN_EN, // use only when calculate A*B+C

    input   wire  signed [WIDTH_OP1-1:0] OP1,
    input   wire  signed [WIDTH_OP2-1:0] OP2,
    input   wire  signed [WIDTH_OUT-1:0] ACC,

    output  wire  signed [WIDTH_OUT-1:0] OUT
);
reg acc_delay1,acc_delay2;

reg signed [WIDTH_OP1-1:0] reg_op1;
reg signed [WIDTH_OP2-1:0] reg_op2;

(* use_dsp = "yes" *) reg signed [WIDTH_OUT-1:0] reg_mul;
(* use_dsp = "yes" *) reg signed [WIDTH_OUT-1:0] reg_acc;


always @(posedge CLK) begin
    acc_delay1 <= ACC_EN;
    acc_delay2 <= acc_delay1;
end

always @(posedge CLK) begin
    if(!RSTN) begin
        reg_op1 <= {WIDTH_OP1{1'sd0}};
        reg_op2 <= {WIDTH_OP2{1'sd0}};
        reg_acc <= {WIDTH_OUT{1'sd0}}; 
        reg_mul <= {WIDTH_OUT{1'sd0}};
    end
    else begin
        if(EN)begin
            reg_op1 <= OP1;
            reg_op2 <= OP2;
            reg_mul <= reg_op1 * reg_op2;
            if(acc_delay2) reg_acc <= reg_mul + reg_acc;   
            else if(ACC_IN_EN) reg_acc <= ACC;
        end
    end
end
assign OUT = reg_acc;

endmodule
