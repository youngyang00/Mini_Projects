module Shift_REG(
    input                   CLK,
    input                   SHIFT_EN,
    input   [63:0]          SHIFT_IN,
    input   [511:0]         DATA_IN,
    input                   DATA_IN_EN,

    output      [63:0]      SHIFT_OUT
);

reg     [63:0]      regfile [7:0];

assign SHIFT_OUT = regfile[7];

integer i;

always @(posedge CLK) begin
    if(SHIFT_EN) begin
        for (i = 0; i < 8; i = i + 1) begin
            regfile[i+1] <= regfile[i];
        end
        regfile[0] <= SHIFT_IN;
    end

    if(DATA_IN_EN) begin
        for (i = 0; i < 8; i = i + 1 ) begin
            regfile[7-i] <= DATA_IN[64*i +: 64];
        end
    end
end 
endmodule