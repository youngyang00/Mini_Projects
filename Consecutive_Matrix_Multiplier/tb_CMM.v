`timescale 1ns / 1ps

module tb_CMM;
parameter INPUT_BRAM_FILE = "C:/Users/sjh00/consecutive_mat_mul/consecutive_mat_mul.srcs/sources_1/new/data/input_hexa.txt";
parameter PU1_WEIGHT_BRAM_FILE= "C:/Users/sjh00/consecutive_mat_mul/consecutive_mat_mul.srcs/sources_1/new/data/PU1_Bram_data.txt";
parameter PU2_WEIGHT_BRAM_FILE= "C:/Users/sjh00/consecutive_mat_mul/consecutive_mat_mul.srcs/sources_1/new/data/PU2_Bram_data.txt";

reg                     CLK,RSTN,START;
wire                    DONE,DONE_ROW;
wire  [4:0]             ROW_NUM;
wire  [255:0]           OUT;

reg   [31:0]            mat_element;

Consecutive_Matrix_Multipier#(
    .INPUT_BRAM_FILE(INPUT_BRAM_FILE),
    .PU1_WEIGHT_BRAM_FILE(PU1_WEIGHT_BRAM_FILE), 
    .PU2_WEIGHT_BRAM_FILE(PU2_WEIGHT_BRAM_FILE) 
)DUT(
    .START(START),
    .RSTN(RSTN),
    .CLK(CLK),
    .DONE(DONE),
    .DONE_ROW(DONE_ROW),
    .ROW_NUM(ROW_NUM),
    .OUT(OUT)
);

always begin
     #5 CLK = ~CLK;  // 10 ns clock period
end

integer file;
integer i;

initial begin
    file = $fopen("C:/Users/sjh00/consecutive_mat_mul/consecutive_mat_mul.srcs/sources_1/new/testbench_result.txt", "w");
    if (file == 0) begin
          $display("cannot open.");
    end
    CLK = 0;
    RSTN = 0;
    START = 0;

    #20

    RSTN = 1;
    #10
    START = 1;
    #10
    START = 0;

    wait(DONE);
    $fclose(file);
    $finish;
    
end

always @(posedge DONE_ROW) begin
    for (i = 0; i < 8; i = i + 1) begin
        mat_element = OUT[32*i +: 32];
        $fwrite(file, "%0h\n",mat_element);
        $display("%d",i);
    end
end


endmodule
