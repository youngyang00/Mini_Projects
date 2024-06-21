`timescale 1ns / 1ps

module RowMatCalculator#(
    parameter OP1_COL = 4,
    parameter OP1_WIDTH = 8,
    parameter WEIGHT_ROW = 4,
    parameter WEIGHT_COL = 8,
    parameter WEIGHT_WIDTH = 8,
    parameter DSPOUT_WIDTH = 8,
    parameter BRAM_DEPTH = 64
)(
    input                                               CLK,
    input                                               RSTN,
    input                                               START,
    input  signed  [OP1_WIDTH-1:0]                      OP1,

    output                                              DONE,
    output         [DSPOUT_WIDTH*WEIGHT_COL-1:0]        OUT
);  
    //dsp wire declaration  
    wire                                                dsp_en;
    wire                                                dsp_acc_en;
    wire           [WEIGHT_WIDTH-1:0]                   dsp_unpacked_op2[WEIGHT_COL-1:0];
    //bram wire declaration
    wire           [WEIGHT_COL*WEIGHT_WIDTH-1:0]        bram_packed_op2;
    wire           [$clog2(BRAM_DEPTH)-1:0]             bram_addr;
    wire                                                bram_rd_en;
    wire           [DSPOUT_WIDTH-1:0]                   dsp_unpacked_out [WEIGHT_COL-1:0];

    

//bram & dsp output unpacking
genvar j;
generate
    for (j = 0; j < WEIGHT_COL ; j=j+1) begin
        assign  dsp_unpacked_op2[j] = bram_packed_op2[WEIGHT_WIDTH * j +: WEIGHT_WIDTH]; 
        assign  OUT[DSPOUT_WIDTH*j +: DSPOUT_WIDTH] = dsp_unpacked_out[j];
    end
endgenerate



// dsp Declaration
genvar i;
generate
    for (i = 0; i < WEIGHT_COL; i = i + 1) begin :DSP
        DSP #(
            .WIDTH_OP1(OP1_WIDTH),
            .WIDTH_OP2(WEIGHT_WIDTH),
            .WIDTH_OUT(DSPOUT_WIDTH)
        ) DSP48E1 (
            .CLK(CLK),
            .RSTN(RSTN),
            .EN(dsp_en),
            .ACC_EN(dsp_acc_en),
            .OP1(OP1),
            .OP2(dsp_unpacked_op2[i]),
            .OUT(dsp_unpacked_out[i])
        );        
    end
endgenerate



xilinx_simple_dual_port_1_clock_ram #(
  .RAM_WIDTH(WEIGHT_COL*WEIGHT_WIDTH),                       // Specify RAM data width
  .RAM_DEPTH(BRAM_DEPTH),                     // Specify RAM depth (number of entries)
  .RAM_PERFORMANCE("LOW_LATENCY"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
  .INIT_FILE("C:/Users/sjh00/Matrix_multiplication_recursive_architecture/Matrix_multiplication_recursive_architecture.srcs/sources_1/new/WEIGHT_hex_padded.txt")                        // Specify name/location of RAM initialization file if using one (leave blank if not)
)WEIGHT_BRAM(
  .addra(),   // Write address bus, width determined from RAM_DEPTH
  .addrb(bram_addr),   // Read address bus, width determined from RAM_DEPTH
  .dina(),     // RAM input data, width determined from RAM_WIDTH
  .clka(CLK),     // Clock
  .wea(1'b0),       // Write enable
  .enb(bram_rd_en),	     // Read Enable, for additional power savings, disable when not in use
  .rstb(),     // Output reset (does not affect memory contents)
  .regceb(), // Output register enable
  .doutb(bram_packed_op2)    // RAM output data, width determined from RAM_WIDTH
);

// controller declaration
RMC_controller#(
    .WEIGHT_ROW(WEIGHT_ROW),
    .BRAM_DEPTH(BRAM_DEPTH)
)controller(
    .CLK(CLK),
    .RSTN(RSTN),
    .START(START),
// BRAM CONTROL 
    .BRAM_ADDR(bram_addr),
    .BRAM_RD_EN(bram_rd_en),
// DSP CONTROL
    .DSP_ACC_EN(dsp_acc_en),
    .DSP_EN(dsp_en),
// LCU OUTPUT
    .DONE(DONE)
);



endmodule

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



module xilinx_simple_dual_port_1_clock_ram #(
  parameter RAM_WIDTH = 64,                       // Specify RAM data width
  parameter RAM_DEPTH = 512,                      // Specify RAM depth (number of entries)
  parameter RAM_PERFORMANCE = "LOW_LATENCY", // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
  parameter INIT_FILE = ""                        // Specify name/location of RAM initialization file if using one (leave blank if not)
)(
  input [clogb2(RAM_DEPTH-1)-1:0] addra, // Write address bus, width determined from RAM_DEPTH
  input [clogb2(RAM_DEPTH-1)-1:0] addrb, // Read address bus, width determined from RAM_DEPTH
  input [RAM_WIDTH-1:0] dina,          // RAM input data
  input clka,                          // Clock
  input wea,                           // Write enable
  input enb,                           // Read Enable, for additional power savings, disable when not in use
  input rstb,                          // Output reset (does not affect memory contents)
  input regceb,                        // Output register enable
  output [RAM_WIDTH-1:0] doutb         // RAM output data
);

  reg [RAM_WIDTH-1:0] BRAM [RAM_DEPTH-1:0];
  reg [RAM_WIDTH-1:0] ram_data = {RAM_WIDTH{1'b0}};

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        $readmemh(INIT_FILE, BRAM, 0, RAM_DEPTH-1);
    end else begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          BRAM[ram_index] = {RAM_WIDTH{1'b0}};
    end
  endgenerate

  always @(posedge clka) begin
    if (wea)
      BRAM[addra] <= dina;
    if (enb)
      ram_data <= BRAM[addrb];
  end

  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
  generate
    if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register

      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
       assign doutb = ram_data;

    end else begin: output_register

      // The following is a 2 clock cycle read latency with improve clock-to-out timing

      reg [RAM_WIDTH-1:0] doutb_reg = {RAM_WIDTH{1'b0}};

      always @(posedge clka)
        if (rstb)
          doutb_reg <= {RAM_WIDTH{1'b0}};
        else if (regceb)
          doutb_reg <= ram_data;

      assign doutb = doutb_reg;

    end
  endgenerate

  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction

endmodule

module RMC_controller#(
    parameter WEIGHT_ROW = 4,
    parameter BRAM_DEPTH = 64
)(
    input CLK,
    input RSTN,
    input START,
// BRAM CONTROL 
    output reg [$clog2(BRAM_DEPTH)-1:0]  BRAM_ADDR,
    output reg BRAM_RD_EN,
// DSP CONTROL
    output reg DSP_ACC_EN,
    output reg DSP_EN,
// LCU OUTPUT
    output reg DONE
);

wire n_rst;

reg [2:0]                       current_state,next_state;
reg                             addr_cnt_en;

assign n_rst = ~RSTN;

always @(posedge CLK) begin
    if(n_rst) BRAM_ADDR <= {$clog2(WEIGHT_ROW){1'b0}};
    else begin
        if(addr_cnt_en) BRAM_ADDR <= BRAM_ADDR + 1'b1;
    end
end

always @(posedge CLK) begin
    if(n_rst) current_state <= 3'd0;
    else current_state <= next_state;
end

always @(*) begin
    case (current_state)
        3'd0: if(START) next_state = 3'd1; else next_state = 3'd0;
        3'd1: if(BRAM_ADDR==WEIGHT_ROW-1) next_state = 3'd2; else next_state = 3'd1; 
        3'd2: next_state = 3'd3;
        3'd3: next_state = 3'd4;
        3'd4: next_state = 3'd5;
        3'd5: next_state = 3'd5;
        default:next_state = 3'd0;
    endcase
end

always @(*) begin
    case (current_state)
        3'd0:begin
            addr_cnt_en=0;BRAM_RD_EN=0;
            DSP_ACC_EN=0;DSP_EN=0;
            DONE=0;
        end 
        3'd1:begin
            addr_cnt_en=1;BRAM_RD_EN=1;
            DSP_ACC_EN=1;DSP_EN=1;
            DONE=0;
        end
        3'd2:begin
            addr_cnt_en=0;BRAM_RD_EN=0;
            DSP_ACC_EN=1;DSP_EN=1;
            DONE=0;
        end
        3'd3:begin
            addr_cnt_en=0;BRAM_RD_EN=0;
            DSP_ACC_EN=1;DSP_EN=1;
            DONE=0;
        end
        3'd4:begin
            addr_cnt_en=0;BRAM_RD_EN=0;
            DSP_ACC_EN=1;DSP_EN=1;
            DONE=0;
        end
        3'd5:begin
            addr_cnt_en=0;BRAM_RD_EN=0;
            DSP_ACC_EN=0;DSP_EN=1;
            DONE=1;
        end
        default:begin
            addr_cnt_en=0;BRAM_RD_EN=0;
            DSP_ACC_EN=0;DSP_EN=0;
            DONE=0; 
        end
    endcase
end
endmodule
						
						