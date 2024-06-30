`timescale 1ns / 1ps

module top_tb;

    // Parameters
    parameter OP1_ROW = 8;
    parameter OP1_COL = 4;
    parameter OP1_WIDTH = 8;
    parameter WEIGHT_ROW = 4;
    parameter WEIGHT_COL = 8;
    parameter WEIGHT_WIDTH = 8;
    parameter DSPOUT_WIDTH = 16;
    parameter BRAM_WIDTH = 64;
    parameter BRAM_DEPTH = 32;
    parameter BRAM_FILE_NAME = "C:/Users/sjh00/Matrix_multiplication_recursive_architecture/Matrix_multiplication_recursive_architecture.srcs/sources_1/new/WEIGHT_hex_padded.txt";
    
    // Inputs
    reg CLK;
    reg RSTN;
    reg START;
    reg signed  [OP1_WIDTH-1:0]             OP1;
    reg signed  [DSPOUT_WIDTH-1:0]          mat_element;
    reg         [$clog2(WEIGHT_ROW)-1:0]      ACC_NUM;

    // Outputs
    wire DONE;
    wire [DSPOUT_WIDTH*WEIGHT_COL-1:0] OUT;


    // Instantiate the Unit Under Test (UUT)
    RowMatCalculator #(
        .OP1_COL(OP1_COL),
        .OP1_WIDTH(OP1_WIDTH),
        .WEIGHT_ROW(WEIGHT_ROW),
        .WEIGHT_COL(WEIGHT_COL),
        .WEIGHT_WIDTH(WEIGHT_WIDTH),
        .DSPOUT_WIDTH(DSPOUT_WIDTH),
        .BRAM_WIDTH(BRAM_WIDTH),
        .BRAM_DEPTH(BRAM_DEPTH),
        .BRAM_FILE_NAME(BRAM_FILE_NAME)
    ) uut (
        .CLK(CLK),
        .RSTN(RSTN),
        .START(START),
        .OP1(OP1),
        .ACC_NUM(ACC_NUM),
        .DONE(DONE),
        .OUT(OUT)
    );

    integer file;
    // Clock generation
    always begin
        #5 CLK = ~CLK;  // 10 ns clock period
    end
    integer i;
    initial begin
        file = $fopen("C:/Users/sjh00/Matrix_multiplication_recursive_architecture/Matrix_multiplication_recursive_architecture.srcs/sources_1/new/Test_Result.txt", "w");
        if (file == 0) begin
          $display("cannot open.");
        end
        // Initialize Inputs
        CLK = 0;
        RSTN = 0;
        START = 0;
        OP1 = 0;
        ACC_NUM = 3;

        // Wait for global reset
        #100;
        
        // Reset sequence
        RSTN = 1;
        #10;
        RSTN = 0;
        #10;
        RSTN = 1;
        #10;
        START = 1;
        #10 
        START = 0;
        wait(DONE==1);

        for (i = 0; i < WEIGHT_COL; i = i + 1) begin
            mat_element = OUT[DSPOUT_WIDTH*i +: DSPOUT_WIDTH];
            $fwrite(file, "%0d\n",mat_element);
            $display("%d",i);
        end
        $fclose(file);

        repeat(4) @(posedge CLK);
        RSTN = 0;

        
    end

    initial begin
        #150 OP1 = 09;
        #10  OP1 = 03;
        #10  OP1 = 07;
        #10  OP1 = 02;
    end

endmodule
