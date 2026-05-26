`timescale  1ns/1ns


//最小可测量频率为1HZ
//精度在千分之一最大可测量频率1MHz

module freq_meter_calc #(
    parameter CLK_FREQ = 32'd100_000_000 // 100 MHz
)
(	
	input	wire 		clk_100M		,
	input 	wire 		sys_clk			,
    input 	wire 		rst_n			,              // 低有效复位信号
    input 	wire 		input_signal	,	       // 输入的周期性数字信号
    output 	reg [27:0] 	duty_out		,    // 输出占空比（28位）（万分之一）
    output 	reg [27:0] 	high_time_out	,  // 输出高电平时间(us)（28位）
    output 	reg [27:0] 	low_time_out    ,// 输出低电平时间(us)（28位）
	output  reg   LED1
);
//local parameter define
	localparam CNT_MAX = 28'd100_000_000;
//reg define
	reg [27:0]	cnt_delay;
	reg	delay_flag;
    reg signal_reg1;
    reg signal_reg2;
    reg rising_flag;
    reg falling_flag;
    reg [39:0] high_time_count;  // 高电平计数
    reg [39:0] low_time_count;   // 低电平计数
	wire	[27:0]	high_time_out_next_us;
	wire [51:0]  high_time_out_next_ns;
	wire	[27:0]	low_time_out_next_us;
	wire [51:0] low_time_out_next_ns;
	wire	[39:0]	duty_out_next;
	//下面是调用ip核用到的参数
	reg	[39:0]	high_time_count_reg;
	reg	[39:0]	low_time_count_reg;
	wire [51:0]	high_time_count_1000;
	reg [39:0]  high_time_count_1000_reg;
	reg [39:0]	full_counter_reg;
//wire define
	wire clk_100M;          // 1000 MHz 输入时钟信号
	wire	[39:0]	full_counter;
	
	assign	full_counter = low_time_count+high_time_count;
	
	always @(posedge clk_100M or negedge rst_n) begin
		if (~rst_n) begin
			cnt_delay <= 0;
		end
		else	if(cnt_delay == CNT_MAX)	begin
			cnt_delay <= 0;
		end
		else	begin
			cnt_delay <= cnt_delay +1;
		end
	end
	always @(posedge clk_100M or negedge rst_n) begin
		if (~rst_n) 
			delay_flag <= 0;
		else if(cnt_delay == CNT_MAX-1)
			delay_flag <= 1;
		else
			delay_flag <= 0;
	end
	always @(posedge clk_100M or negedge rst_n) begin
		if (~rst_n)	begin
			duty_out 		<= 0;
			high_time_out 	<= 0;
			low_time_out  	<= 0;
			LED1 <= 0;end
		else if((delay_flag == 1)&((high_time_out_next_us > 100) |(high_time_out_next_us == 100) |(low_time_out_next_us == 100) | (low_time_out_next_us > 100))) begin
			duty_out 		<= duty_out_next[27:0];
			high_time_out 	<= high_time_out_next_us[27:0];
			low_time_out  	<= low_time_out_next_us[27:0]; 
			LED1 <= 0;end
		else if((delay_flag == 1)&(high_time_out_next_us < 100) & (low_time_out_next_us < 100)) begin
			duty_out 		<= duty_out_next[27:0];
			high_time_out 	<= high_time_out_next_ns[27:0];
			low_time_out  	<= low_time_out_next_ns[27:0]; 
			LED1 <= 1;end
		else	begin
			duty_out 		<= duty_out;
			high_time_out 	<= high_time_out;
			low_time_out  	<= low_time_out;	
			LED1 <= LED1;end
	end	
    // 通过寄存器让信号上升沿下降沿与时钟重合，允许最多2个时钟周期的误差
    always @(posedge clk_100M or negedge rst_n) begin
        if (~rst_n) begin
            signal_reg1 <= 0;
            signal_reg2 <= 0;
        end else begin
            signal_reg1 <= input_signal;
            signal_reg2 <= signal_reg1;
        end
    end

    // 上升沿标志寄存器
    always @(posedge clk_100M or negedge rst_n) begin
        if (~rst_n)
            rising_flag <= 0;
        else if (signal_reg1 == 1 && signal_reg2 == 0)
            rising_flag <= 1;
        else
            rising_flag <= 0;
    end

    // 下降沿标志寄存器
    always @(posedge clk_100M or negedge rst_n) begin
        if (~rst_n)
            falling_flag <= 0;
        else if (signal_reg1 == 0 && signal_reg2 == 1)
            falling_flag <= 1;
        else
            falling_flag <= 0;
    end

    // 高电平时间计数
    always @(posedge clk_100M or negedge rst_n) begin
        if (~rst_n)
            high_time_count <= 0;
		else if(rising_flag == 1)
			high_time_count <= 1;
        else if ((rising_flag != 1)&(signal_reg2 == 1))
            high_time_count <= high_time_count + 1;
        else
            high_time_count <= high_time_count;
    end

    // 低电平时间计数
    always @(posedge clk_100M or negedge rst_n) begin
        if (~rst_n)
            low_time_count <= 0;
        else if(falling_flag == 1)
			low_time_count <= 1;
        else if ((falling_flag != 1)&(signal_reg2 == 0))
            low_time_count <= low_time_count + 1;
        else
            low_time_count <= low_time_count;
    end

    // 下降沿时确定高电平持续时间（单位为微秒）
    always @(posedge clk_100M or negedge rst_n) begin
        if (~rst_n) begin
			high_time_count_reg <= 0;
            //high_time_out_next_us <= 0;
			//high_time_out_next_ns <= 0; 
			end
        else if (falling_flag == 1)begin
            // 高电平时间 = 高电平计数 * 1000000 / CLK_FREQ
				high_time_count_reg <= high_time_count;
				//high_time_out_next_ns <= (high_time_count)*10;
				//high_time_out_next_us <= (high_time_count) / 100;
				end
        else	begin
			high_time_count_reg <= high_time_count_reg;
            //high_time_out_next_us <= high_time_out_next_us;
			//high_time_out_next_ns <= high_time_out_next_ns; 
			end
    end

    // 上升沿时确定低电平持续时间和占空比
    always @(posedge clk_100M or negedge rst_n) begin
        if (~rst_n) begin
            //low_time_out_next_us <= 0;
			//low_time_out_next_ns <= 0;
			low_time_count_reg <= low_time_count_reg;
            //duty_out_next <= 0;
        end else if (rising_flag == 1) begin
            // 低电平时间 = 低电平计数 * 1000000 / CLK_FREQ
			low_time_count_reg <= low_time_count;
            //low_time_out_next_us <=  (low_time_count) /100 ;
			//low_time_out_next_ns <=  (low_time_count) *10;
            // 占空比计算 (单位：千分之一)
			high_time_count_1000_reg <= high_time_count_1000[39:0];
			full_counter_reg <= full_counter;
            //duty_out_next <= ((high_time_count * 1000) / full_counter);
        end else begin
			
            //low_time_out_next_us <= low_time_out_next_us;
			//low_time_out_next_ns <= low_time_out_next_ns;
			low_time_count_reg <= low_time_count_reg;
            //duty_out_next <= duty_out_next;
        end
    end

//计算us单位的高电平时间
	Integer_Division_1 division_high_time_us(
		.clk(sys_clk), //input clk
		.rstn(rst_n), //input rstn
		.dividend(high_time_count_reg), //input [39:0] dividend
		.divisor(12'd100), //input [11:0] divisor
		.quotient(high_time_out_next_us) //output [39:0] quotient
	);
//计算us单位的低电平时间
	Integer_Division_1 division_low_time_us(
		.clk(sys_clk), //input clk
		.rstn(rst_n), //input rstn
		.dividend(low_time_count_reg), //input [39:0] dividend
		.divisor(12'd100), //input [11:0] divisor
		.quotient(low_time_out_next_us) //output [39:0] quotient
	);
//计算ns单位的高电平时间
	Integer_Multiplier mult_high_time_ns(
		.mul_a(high_time_count_reg), //input [39:0] mul_a
		.mul_b(12'd10), //input [11:0] mul_b
		.product(high_time_out_next_ns) //output [51:0] product
	);
//计算ns单位的低电平时间
	Integer_Multiplier mult_low_time_ns(
		.mul_a(low_time_count_reg), //input [39:0] mul_a
		.mul_b(12'd10), //input [11:0] mul_b
		.product(low_time_out_next_ns) //output [51:0] product
	);
//计算1000倍的高电平计数
	Integer_Multiplier mult_high_time_count_1000(
		.mul_a(high_time_count), //input [39:0] mul_a
		.mul_b(12'd1000), //input [11:0] mul_b
		.product(high_time_count_1000) //output [51:0] product
	);
//计算占空比
	Integer_Division_2 division_duty_out(
		.clk(sys_clk), //input clk
		.rstn(rst_n), //input rstn
		.dividend(high_time_count_1000_reg), //input [39:0] dividend
		.divisor(full_counter_reg), //input [39:0] divisor
		.quotient(duty_out_next) //output [39:0] quotient
	);


endmodule

