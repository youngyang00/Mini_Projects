/*

PU #(
    .WIDTH_OP1(),
    .WIDTH_OP2(),
    .WIDTH_OUT(),
    .MATRIX_ROW(),
    .MATRIX_COL()
) pu_instance (
    .A(),                        
    .B(),                        
    .START(),                   
    .CLK(),                     
    .RSTN(),                    
    .OUT(),                      
    .DONE()                      
);

*/

module PU#(
    parameter WIDTH_OP1 = 16,
    parameter WIDTH_OP2 = 16,
    parameter WIDTH_OUT = 32,

    parameter MATRIX_ROW = 8,
    parameter MATRIX_COL = 16
)(
    input [WIDTH_OP1-1:0]                   A,
    input [WIDTH_OP2 * MATRIX_ROW-1:0]      B,
    input                                   START,
    input                                   CLK,
    input                                   RSTN,

    output [WIDTH_OUT*MATRIX_ROW-1:0]       OUT,
    output                                  DONE
    );

    wire    [WIDTH_OP1-1:0]                 wr_op2[MATRIX_ROW-1:0];   
    wire    [WIDTH_OUT-1:0]                 wr_unpacked_out [MATRIX_ROW-1:0];
    
    wire                                    wr_en;
    wire                                    wr_acc_en;
    wire                                    wr_dsp_rstn;

    //B unpacking 

    genvar j;
    generate
        for (j = 0; j < MATRIX_ROW ; j=j+1) begin
            assign  wr_op2[j] = B[WIDTH_OP2 * j +:WIDTH_OP2]; 
        end
    endgenerate

    //OUT packing

    genvar k;
    generate
        for (k = 0; k < MATRIX_ROW; k = k + 1) begin
            assign OUT[WIDTH_OUT * k +: WIDTH_OUT] = wr_unpacked_out[k];
        end
    endgenerate


    //DSP instance

    genvar i;
    generate
        for(i = 0; i < MATRIX_ROW ; i = i + 1) begin : DSP
            DSP #(
                .WIDTH_OP1(WIDTH_OP1),
                .WIDTH_OP2(WIDTH_OP2),
                .WIDTH_OUT(WIDTH_OUT)
            ) dsp_inst (
                .CLK(CLK),
                .RSTN(RSTN|wr_dsp_rstn),
                .EN(wr_en),
                .ACC_EN(wr_acc_en),
                .OP1(A),
                .OP2(wr_op2[i]),
                .OUT(wr_unpacked_out[i])
            );          
        end
    endgenerate

    //CTRL instance

    CTRL#(
        .MATRIX_COL(MATRIX_COL)
    )ctrl(
        .CLK(CLK),
        .RSTN(RSTN),
        .START(START),
        .DONE(DONE),
        .EN(wr_en),
        .ACC_EN(wr_acc_en),
        .DSP_RSTN(wr_dsp_rstn)
    );


endmodule

module CTRL#(
    parameter MATRIX_COL = 16
)(
    input       CLK,
    input       RSTN,
    input       START,

    output reg  DONE,
    output reg  EN,
    output reg  ACC_EN,
    output reg  DSP_RSTN
);

localparam  CNT_WIDTH = $clog2(MATRIX_COL);

wire n_rst;

reg [2:0] current_state,next_state;
reg [CNT_WIDTH:0] cnt;
reg cnt_en;

assign n_rst = ~ RSTN;

always @(posedge CLK) begin
    if(n_rst)begin
        cnt <= {CNT_WIDTH{1'b0}};
    end
    else if(cnt_en) begin
        cnt <= cnt + 1;
    end
end

always @(posedge CLK) begin
    if(n_rst) current_state <= 3'd0;
    else current_state <= next_state;
end

always @(*) begin
    case (current_state)
        3'd0: if(START)next_state = 3'd1; else next_state = 3'd0;
        3'd1: if(cnt==MATRIX_COL+2) next_state = 3'd2; else next_state = 3'd1;
        3'd2: next_state = 3'd2;
        default: next_state=3'd0;
    endcase
end

always @(*) begin
    case (current_state)
        3'd0:begin
            DONE=0;EN=0;ACC_EN=0;DSP_RSTN=0;cnt_en=0;
        end
        3'd1:begin
            DONE=0;EN=1;ACC_EN=1;DSP_RSTN=1;cnt_en=1;
        end
        3'd2:begin
            DONE=1;EN=1;ACC_EN=0;DSP_RSTN=1;cnt_en=0;
        end
        default: begin 
            DONE=0;EN=0;ACC_EN=0;DSP_RSTN=0;cnt_en=0;
        end
    endcase
end
    

endmodule
