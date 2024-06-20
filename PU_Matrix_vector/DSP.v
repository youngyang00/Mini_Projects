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
    .OP1(),
    .OP2(),
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

    input   wire  signed [WIDTH_OP1-1:0] OP1,
    input   wire  signed [WIDTH_OP2-1:0] OP2,

    output  wire  signed [WIDTH_OUT-1:0] OUT
);


reg signed [WIDTH_OP1-1:0] reg_op1;
reg signed [WIDTH_OP2-1:0] reg_op2;

(* use_dsp = "yes" *) reg signed [WIDTH_OUT-1:0] reg_mul;
(* use_dsp = "yes" *) reg signed [WIDTH_OUT-1:0] reg_acc;

wire    n_rst;
assign n_rst = ~RSTN;


always @(posedge CLK) begin
    if(n_rst) begin
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
            if(ACC_EN) reg_acc <= reg_mul + reg_acc;   
        end
    end
end
assign OUT = reg_acc;

endmodule
