module CMM_controller(
    input                                  CLK,
    input                                  RSTN,
    input                                  START,
    input                                  PU_DONE,

    output reg                             PU_PREVENT_ADR_CLR,
    output reg                             PU_ACC_CLR,
    output reg                             PU_START,
    output reg [5:0]                       PU_ACC_NUM,
    output reg                             PU1_SEL,
    output reg                             PU2_SEL,
    output reg [$clog2(2048)-1:0]          INPUT_BRAM_ADDR,
    output reg                             INPUT_BRAM_RD_EN,
    output reg                             SHIFT_EN,
    output reg                             DATA_IN_EN,
    output reg                             DONE,
    output reg                             DONE_ROW,
    output reg [4:0]                       ROW_NUM
);

localparam BRAM_ADDR_WIDTH =  $clog2(2048);

wire            n_rst;
reg     [4:0]   current_state,next_state; 
reg             addr_cnt_en;
reg     [5:0]   input_cnt;
reg             input_cnt_rst;

assign n_rst = ~ RSTN;


always @(posedge CLK) begin
    if(n_rst) begin
        INPUT_BRAM_ADDR <= {$clog2(BRAM_ADDR_WIDTH){1'b0}};
    end
    else begin
        if(addr_cnt_en) begin
            INPUT_BRAM_ADDR <= INPUT_BRAM_ADDR + 1;
        end
    end

    if(n_rst | input_cnt_rst) input_cnt <= 6'b0;
    else begin
        if(addr_cnt_en) input_cnt <= input_cnt + 1;
    end       
end



always @(posedge CLK) begin
    if(n_rst)begin
        current_state <= 5'd0;
    end
    else begin
        current_state <= next_state;
    end
end

always @(*) begin
    case (current_state)
        5'd0:begin // Inital state
            PU_PREVENT_ADR_CLR=1'b0;
            PU_ACC_CLR = 1'b0;
            PU_START= 1'b0;
            PU_ACC_NUM= 6'd0;
            PU1_SEL= 1'b0;
            PU2_SEL= 1'b0;
            addr_cnt_en = 1'b0;
            INPUT_BRAM_RD_EN= 1'b0;
            SHIFT_EN= 1'b0;
            DATA_IN_EN= 1'b0;
            DONE=1'b0;
            DONE_ROW=1'b0;
            ROW_NUM =5'd0;
            input_cnt_rst=1'b0;
        end
        5'd1:begin // Data load from Bram & PU in enable  
            PU_PREVENT_ADR_CLR=1'b0;
            PU_ACC_CLR = 1'b0;
            PU_START = 1'b1;
            PU_ACC_NUM = 6'd63;
            INPUT_BRAM_RD_EN = 1'b1;
            PU1_SEL= 1'b0;
            PU2_SEL= 1'b0;
            addr_cnt_en = 1'b0;
            SHIFT_EN= 1'b0;
            DATA_IN_EN= 1'b0;
            DONE=1'b0;
            DONE_ROW=1'b0;
            ROW_NUM = ROW_NUM;
            input_cnt_rst=1'b0;
        end
        5'd2:begin // proceed Matrix multiplication
            PU_PREVENT_ADR_CLR=1'b0;
            PU_ACC_CLR = 1'b0;
            PU_ACC_NUM = 6'd63;
            addr_cnt_en = 1'b1;
            INPUT_BRAM_RD_EN = 1'b1;
            PU_START = 1'b0;
            PU1_SEL= 1'b0;
            PU2_SEL= 1'b0;
            SHIFT_EN= 1'b0;
            DATA_IN_EN= 1'b0;
            DONE=1'b0;
            DONE_ROW=1'b0;
            ROW_NUM = ROW_NUM;
            input_cnt_rst=1'b0;
        end
        5'd3:begin 
            PU_PREVENT_ADR_CLR=1'b0;
            PU_ACC_CLR = 1'b0;
            PU_ACC_NUM = 6'd63;
            addr_cnt_en = 1'b0;
            INPUT_BRAM_RD_EN = 1'b1;
            PU_START = 1'b0;
            PU1_SEL= 1'b0;
            PU2_SEL= 1'b0;
            SHIFT_EN= 1'b0;
            DATA_IN_EN= 1'b0;
            DONE=1'b0;
            DONE_ROW=1'b0;
            ROW_NUM = ROW_NUM;
            input_cnt_rst=1'b0;
        end
        5'd4:begin //first matrix multiplication done & load to enable buffer
            PU_PREVENT_ADR_CLR=1'b0;
            PU_ACC_CLR= 1'b0;
            PU_ACC_NUM = 6'd63;
            addr_cnt_en = 1'b0;
            INPUT_BRAM_RD_EN = 1'b0;
            PU_START = 1'b0;
            PU1_SEL= 1'b1;
            PU2_SEL= 1'b1;
            SHIFT_EN= 1'b0;
            DATA_IN_EN= 1'b1;
            DONE=1'b0;
            DONE_ROW=1'b0;
            ROW_NUM = ROW_NUM;
            input_cnt_rst=1'b0;
        end
        5'd5:begin //first matrix multiplication done & load to enable buffer
            PU_PREVENT_ADR_CLR=1'b1;
            PU_ACC_CLR= 1'b0;
            PU_ACC_NUM = 6'd63;
            addr_cnt_en = 1'b0;
            INPUT_BRAM_RD_EN = 1'b0;
            PU_START = 1'b0;
            PU1_SEL= 1'b1;
            PU2_SEL= 1'b1;
            SHIFT_EN= 1'b0;
            DATA_IN_EN= 1'b1;
            DONE=1'b0;
            DONE_ROW=1'b0;
            ROW_NUM = ROW_NUM;
            input_cnt_rst=1'b0;
        end
        5'd6:begin //PU CLR
            PU_PREVENT_ADR_CLR=1'b1;
            PU_ACC_CLR= 1'b1;
            PU_ACC_NUM = 6'd8;
            addr_cnt_en = 1'b0;
            INPUT_BRAM_RD_EN = 1'b0;
            PU_START = 1'b0;
            PU1_SEL= 1'b1;
            PU2_SEL= 1'b1;
            SHIFT_EN= 1'b0;
            DATA_IN_EN= 1'b0;
            DONE=1'b0;
            DONE_ROW=1'b0;
            ROW_NUM = ROW_NUM;
            input_cnt_rst=1'b1;
        end
        5'd7:begin 
            PU_PREVENT_ADR_CLR=1'b1;
            PU_ACC_CLR= 1'b0;
            PU_ACC_NUM = 6'd8;
            addr_cnt_en = 1'b0;
            INPUT_BRAM_RD_EN = 1'b0;
            PU_START = 1'b1;
            PU1_SEL= 1'b1;
            PU2_SEL= 1'b1;
            SHIFT_EN= 1'b0;
            DATA_IN_EN= 1'b0;
            DONE=1'b0;
            DONE_ROW=1'b0;
            ROW_NUM = ROW_NUM;
            input_cnt_rst=1'b0;
        end
        5'd8:begin //proceed Secnod matrix multiplication 
            PU_PREVENT_ADR_CLR=1'b0;
            PU_ACC_CLR= 1'b0;
            PU_ACC_NUM = 6'd8;
            addr_cnt_en = 1'b0;
            INPUT_BRAM_RD_EN = 1'b0;
            PU_START = 1'b0;
            PU1_SEL= 1'b1;
            PU2_SEL= 1'b1;
            SHIFT_EN= 1'b1;
            DATA_IN_EN= 1'b0;
            DONE=1'b0;
            DONE_ROW=1'b0;
            ROW_NUM = ROW_NUM;
            input_cnt_rst=1'b0;
        end


        5'd10:begin // register initalize for next matrix row calculation
            PU_PREVENT_ADR_CLR=1'b0;
            PU_ACC_CLR = 1'b1;
            PU_START= 1'b0;
            PU_ACC_NUM= 6'd0;
            PU1_SEL= 1'b0;
            PU2_SEL= 1'b0;
            addr_cnt_en = 1'b1;
            INPUT_BRAM_RD_EN= 1'b0;
            SHIFT_EN= 1'b0;
            DATA_IN_EN= 1'b0;
            DONE=1'b0;
            DONE_ROW=1'b1;
            ROW_NUM = ROW_NUM + 1;
            input_cnt_rst=1'b0;
        end
        
        5'd11:begin // Inital state
            PU_PREVENT_ADR_CLR=1'b0;
            PU_ACC_CLR= 1'b0;
            PU_ACC_NUM = 6'd7;
            addr_cnt_en = 1'b0;
            INPUT_BRAM_RD_EN = 1'b0;
            PU_START = 1'b0;
            PU1_SEL= 1'b1;
            PU2_SEL= 1'b1;
            SHIFT_EN= 1'b0;
            DATA_IN_EN= 1'b0;
            DONE=1'b0;
            DONE_ROW=1'b0;
            ROW_NUM = ROW_NUM;
            input_cnt_rst=1'b1;
        end

        5'd9:begin // register initalize for next matrix row calculation
            PU_PREVENT_ADR_CLR=1'b0;
            PU_ACC_CLR = 1'b1;
            PU_START= 1'b0;
            PU_ACC_NUM= 6'd0;
            PU1_SEL= 1'b0;
            PU2_SEL= 1'b0;
            addr_cnt_en = 1'b1;
            INPUT_BRAM_RD_EN= 1'b0;
            SHIFT_EN= 1'b0;
            DATA_IN_EN= 1'b0;
            DONE=1'b1;
            DONE_ROW=1'b1;
            ROW_NUM = ROW_NUM + 1;
            input_cnt_rst=1'b0;
        end
        


        default: begin
            PU_PREVENT_ADR_CLR=1'b0;
            PU_ACC_CLR =1'b0;
            PU_START= 1'b0;
            PU_ACC_NUM= 6'd0;
            PU1_SEL= 1'b0;
            PU2_SEL= 1'b0;
            addr_cnt_en = 1'b0;
            INPUT_BRAM_RD_EN= 1'b0;
            SHIFT_EN= 1'b0;
            DATA_IN_EN= 1'b0;
            DONE=1'b0;
            DONE_ROW=1'b0;
            ROW_NUM =5'd0;
            addr_cnt_en=1'b0;
            input_cnt_rst=1'b0;
        end
    endcase
end

always @(*) begin
    case (current_state)
        5'd0: if(START) next_state = 5'd1; else next_state = 5'd0;
        5'd1: next_state = 5'd2;
        5'd2: if(input_cnt==62) next_state = 5'd3; else next_state = 5'd2;
        5'd3: if(PU_DONE)next_state = 5'd4; else next_state = 5'd3;
        5'd4: next_state = 5'd5;
        5'd5: next_state = 5'd6;
        5'd6: next_state = 5'd7;
        5'd7: next_state = 5'd8;
        5'd8: if(PU_DONE)begin
            if(ROW_NUM != 31)next_state = 5'd10;else next_state = 5'd9;
        end
            else next_state = next_state;
        5'd10: next_state = 5'd11;
        5'd9: next_state = next_state;
        5'd11: next_state =  5'd1;
    
        default: next_state = 5'd0;
    endcase
end
    
endmodule

