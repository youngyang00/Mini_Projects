module Consecutive_Matrix_Multipier#(
    parameter INPUT_BRAM_FILE = "C:/Users/sjh00/consecutive_mat_mul/consecutive_mat_mul.srcs/sources_1/new/data/input_hexa.txt",
    parameter PU1_WEIGHT_BRAM_FILE= "C:/Users/sjh00/consecutive_mat_mul/consecutive_mat_mul.srcs/sources_1/new/data/PU1_Bram_data.txt",
    parameter PU2_WEIGHT_BRAM_FILE= "C:/Users/sjh00/consecutive_mat_mul/consecutive_mat_mul.srcs/sources_1/new/data/PU2_Bram_data.txt"
)(
    input                   START,
    input                   RSTN,
    input                   CLK,

    output                  DONE,
    output                  DONE_ROW,
    output [4:0]            ROW_NUM,
    output [255:0]          OUT
);

// PU wire
wire             [15:0]                 input_data [1:0];
wire             [255:0]                PU_out     [1:0]; 

//BRAM
wire             [15:0]                 input_bram_out;

//TEMP_BUFFER
wire             [511:0]                buffer_in;
wire             [63:0]                 buffer_out;
//final add operatrion wire
wire    signed   [31:0]                 add_result [7:0];
wire    signed   [31:0]                 add1 [7:0];
wire    signed   [31:0]                 add2 [7:0];


//control pu signal
wire                                    PU_prevent_adr_clr;
wire                                    PU_acc_clr;
wire                                    PU_start;
wire             [5:0]                  PU_acc_num;
wire                                    PU1_sel;
wire                                    PU2_sel;
//control bram signal
wire             [$clog2(2048)-1:0]     input_bram_adr;
wire                                    input_bram_rd_en;
//control temp_buffer signal
wire                                    shift_en;
wire                                    data_in_en;
wire             [1:0]                  pu_done;


genvar i;

generate
    for (i = 0; i < 8; i = i + 1) begin
        assign add1[i] = PU_out[0][32*i +: 32];
        assign add2[i] = PU_out[1][32*i +: 32];
        assign add_result[i] = add1[i] + add2[i];

        assign OUT[32*i +: 32] = add_result[i];
    end

endgenerate


assign input_data[0] = PU1_sel ? buffer_out [23:8]  : input_bram_out;
assign input_data[1] = PU2_sel ? buffer_out [55:40] : input_bram_out;
assign buffer_in = {PU_out[1],PU_out[0]};



PU_RowMatrix #(
    .OP1_COL(64),
    .OP1_WIDTH(16),
    .WEIGHT_ROW(64),
    .WEIGHT_COL(8),
    .WEIGHT_WIDTH(16),
    .DSPOUT_WIDTH(32),
    .BRAM_WIDTH(128),
    .BRAM_DEPTH(128),
    .BRAM_FILE_NAME(PU1_WEIGHT_BRAM_FILE)
) PU1 (
    .CLK(CLK),
    .RSTN(RSTN & ~(PU_acc_clr)),
    .START(PU_start),
    .OP1(input_data[0]),
    .ACC_NUM(PU_acc_num),
    .PREVENT_ADR_CLR(PU_prevent_adr_clr),
    .DONE(pu_done[0]),
    .OUT(PU_out[0])
);
    
PU_RowMatrix #(
    .OP1_COL(64),
    .OP1_WIDTH(16),
    .WEIGHT_ROW(64),
    .WEIGHT_COL(8),
    .WEIGHT_WIDTH(16),
    .DSPOUT_WIDTH(32),
    .BRAM_WIDTH(128),
    .BRAM_DEPTH(128),
    .BRAM_FILE_NAME(PU2_WEIGHT_BRAM_FILE)
) PU2 (
    .CLK(CLK),
    .RSTN(RSTN & ~(PU_acc_clr)),
    .START(PU_start),
    .OP1(input_data[1]),
    .ACC_NUM(PU_acc_num),
    .PREVENT_ADR_CLR(PU_prevent_adr_clr),
    .DONE(pu_done[1]),
    .OUT(PU_out[1])
);

xilinx_simple_dual_port_1_clock_ram #(
  .RAM_WIDTH(16),                       // Specify RAM data width
  .RAM_DEPTH(2048),                     // Specify RAM depth (number of entries)
  .RAM_PERFORMANCE("LOW_LATENCY"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
  .INIT_FILE(INPUT_BRAM_FILE) // Specify name/location of RAM initialization file if using one (leave blank if not)
)input_bram(
  .addra(),   // Write address bus, width determined from RAM_DEPTH
  .addrb(input_bram_adr),   // Read address bus, width determined from RAM_DEPTH
  .dina(),     // RAM input data, width determined from RAM_WIDTH
  .clka(CLK),     // Clock
  .wea(1'b0),       // Write enable
  .enb(input_bram_rd_en),	     // Read Enable, for additional power savings, disable when not in use
  .rstb(),     // Output reset (does not affect memory contents)
  .regceb(), // Output register enable
  .doutb(input_bram_out)    // RAM output data, width determined from RAM_WIDTH
);

Shift_REG TEMP_BUFFER(
    .CLK(CLK),
    .SHIFT_EN(shift_en),
    .SHIFT_IN(),
    .DATA_IN(buffer_in),
    .DATA_IN_EN(data_in_en),
    .SHIFT_OUT(buffer_out)
);

CMM_controller  CMM_controller(
    .CLK(CLK),
    .RSTN(RSTN),
    .START(START),
    .PU_DONE(pu_done[0] & pu_done[1]),
    .PU_PREVENT_ADR_CLR(PU_prevent_adr_clr),
    .PU_ACC_CLR(PU_acc_clr),
    .PU_START(PU_start),
    .PU_ACC_NUM(PU_acc_num),
    .PU1_SEL(PU1_sel),
    .PU2_SEL(PU2_sel),
    .INPUT_BRAM_ADDR(input_bram_adr),
    .INPUT_BRAM_RD_EN(input_bram_rd_en),
    .SHIFT_EN(shift_en),
    .DATA_IN_EN(data_in_en),
    .DONE(DONE),
    .DONE_ROW(DONE_ROW),
    .ROW_NUM(ROW_NUM)
);





endmodule