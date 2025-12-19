module logic_sample (
    input  wire        fx2_ifclk,
    input  wire        reset_n,
    input  wire [7:0]  signal_in,

    // 命令接口
    input  wire [7:0]  cmd_start_stop,
    input  wire [7:0]  cmd_trigger_enable,
    input  wire [7:0]  cmd_trigger_position, // 采样位置百分比
    input  wire [7:0]  cmd_sample_depth,
    input  wire [7:0]  cmd_trigger_channel,
    input  wire [7:0]  cmd_trigger_mod,
    input  wire        cmd_valid,

    // RAM A口接口
    output reg  [15:0] wr_addr,    // 写地址
    output reg  [7:0]  wr_data,    // 写数据
    output reg         wr_en,      // 写使能

    // 状态输出
    output reg [15:0]  sample_count,
    output reg         sample_done
);

    //---------------- 参数转换 ----------------
    reg [23:0] total_depth;
    reg [23:0] trigger_index;
	reg [23:0] sample_count_reg;
	reg [7:0] signal_in_reg_1;
	reg [7:0] signal_in_reg_2;
	reg [7:0] signal_in_reg_3;
	//对输入信号打三拍
	always @(posedge fx2_ifclk or negedge reset_n) begin
        if (!reset_n)
            signal_in_reg_1 <= 0;
        else
            signal_in_reg_1 <= signal_in;
    end
	
	always @(posedge fx2_ifclk or negedge reset_n) begin
        if (!reset_n)
            signal_in_reg_2 <= 0;
        else
            signal_in_reg_2 <= signal_in_reg_1;
    end
	
	always @(posedge fx2_ifclk or negedge reset_n) begin
        if (!reset_n)
            signal_in_reg_3 <= 0;
        else
            signal_in_reg_3 <= signal_in_reg_3;
    end
	
	
	
    always @(*) begin
        case (cmd_sample_depth)
            8'h00: total_depth = 1000;
            8'h01: total_depth = 5000;
            8'h02: total_depth = 10000;
            8'h03: total_depth = 20000;
            8'h04: total_depth = 50000;
            default: total_depth = 10000;
        endcase

        case (cmd_trigger_position)
            8'h00: trigger_index = 0;
            8'h01: trigger_index = total_depth / 4;       // 25%
            8'h02: trigger_index = total_depth / 2;       // 50%
            8'h03: trigger_index = (total_depth * 3) / 4; // 75%
            8'h04: trigger_index = total_depth;
            default: trigger_index = total_depth / 2;
        endcase
    end

    //---------------- 触发条件检测 ----------------
    reg prev_bit;
    wire cur_bit = signal_in_reg_3[cmd_trigger_channel];
    reg trigger_match;

    always @(posedge fx2_ifclk or negedge reset_n) begin
        if (!reset_n)
            prev_bit <= 0;
        else
            prev_bit <= cur_bit;
    end

    // 按模式判断触发符合条件
    always @(*) begin
        trigger_match = 1'b0;
        case (cmd_trigger_mod)
            8'h00: trigger_match = (!prev_bit &&  cur_bit); // 上升沿
            8'h01: trigger_match = ( prev_bit && !cur_bit); // 下降沿
            8'h02: trigger_match = ( cur_bit);              // 高电平
            8'h03: trigger_match = (!cur_bit);              // 低电平
            8'h04: trigger_match = (prev_bit != cur_bit);   // 双沿
            default: trigger_match = 1'b0;
        endcase
    end

    //---------------- FSM 状态定义 ----------------
    localparam S_IDLE     = 3'd0,
               S_PRETRIG  = 3'd1,
               S_POSTTRIG = 3'd2,
               S_DONE     = 3'd3;

    reg [2:0] state;
    reg [15:0] pre_ptr; // 环形缓冲指针

    //---------------- FSM 主逻辑 ----------------
	always @(posedge fx2_ifclk or negedge reset_n) begin
    if (!reset_n) begin
        state         <= S_IDLE;
        wr_en         <= 0;
        wr_data       <= 0;
        wr_addr       <= 0;
        sample_count_reg  <= 0;
        sample_done   <= 0;
        pre_ptr       <= 0;
    end else begin
        wr_en       <= 0; // 默认不写
        sample_done <= 0;

        case(state)
            // 空闲状态，等待开始命令
            S_IDLE: begin
                wr_en         <= 0;
                wr_data       <= 0;
                wr_addr       <= 0;
                sample_count_reg  <= 0;
                sample_done   <= 0;
                pre_ptr       <= 0;

                if (cmd_valid && cmd_start_stop == 8'h01) begin
                    pre_ptr      <= 0;
                    sample_count_reg <= 0;
                    if (cmd_trigger_enable != 8'h00)
                        state <= S_PRETRIG;
                    else
                        state <= S_POSTTRIG;
                end
            end

            // 触发前采集（环形缓冲）
            S_PRETRIG: begin
                if (cmd_valid && cmd_start_stop == 8'h00) begin
                    // MCU请求停止
                    state         <= S_IDLE;
                    wr_addr       <= 0;
                    sample_count_reg  <= 0;
                    pre_ptr       <= 0;
                end 
				else begin
                    wr_en   <= 1;
                    wr_data <= signal_in_reg_3;
                    wr_addr <= pre_ptr;                   
                    pre_ptr <= (pre_ptr + 1) % trigger_index;
                    if (trigger_match) begin
                        sample_count_reg <= pre_ptr + 1;
                        state        <= S_POSTTRIG;
                    end
                end
            end

            // 触发后采集
            S_POSTTRIG: begin
                if (cmd_valid && cmd_start_stop == 8'h00) begin
                    // MCU请求停止
                    state         <= S_IDLE;
                    wr_addr       <= 0;
                    sample_count_reg  <= 0;
                end else begin
                    wr_en   <= 1;
                    wr_data <= signal_in_reg_3;
                    wr_addr <= sample_count_reg;
                    sample_count_reg <= sample_count_reg + 1;
                    if (sample_count_reg >= total_depth) begin
                        state       <= S_DONE;
                    end
                end
            end

            // 完成状态
            S_DONE: begin
                if (cmd_valid && cmd_start_stop == 8'h00) begin
                    // MCU请求停止
                    state         <= S_IDLE;
                    wr_addr       <= 0;
                    sample_count_reg  <= 0;
                end else begin
                    sample_done <= 1;
					sample_count <= sample_count_reg;
                    state       <= S_IDLE;
                end
            end
        endcase
    end
end



endmodule