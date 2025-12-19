module top_measure_output(
	input	clk_100M	,
	input	sys_clk   ,
	input 	sys_rst_n ,
	input	input_signal,
	input	key_in,
	output	[27:0]	display_value,
	output	[7:0]	point,
	output       LED1


);

wire	key_flag;
wire	[27:0]  freq_out;		
wire	[27:0]  duty_out	;	
wire	[27:0]  high_time_out;	
wire	[27:0]  low_time_out;	



key_filter
#(
   .CNT_MAX(20'd999_999) //计数器计数最大值
)
key_filter_inst
(
    .sys_clk   (sys_clk)  ,   //系统时钟50Mhz
    .sys_rst_n (sys_rst_n)  ,   //全局复位
    .key_in    (key_in)  ,   //按键输入信号
    .key_flag  (key_flag)      //key_flag为1时表示消抖后检测到按键被按下
);

display_control	display_control_inst
(
	.freq_out		(freq_out	),    // 输出频率（28位）（Hz）
	.duty_out		(duty_out	),    // 输出占空比（28位）（万分之一）
	.high_time_out	(high_time_out),  // 输出高电平时间(us)（28位）
	.low_time_out	(low_time_out),    // 输出低电平时间(us)（28位） 
	.clk_sys		(sys_clk	),
	.rst_n			(sys_rst_n		),
	.key_flag		(key_flag	),
	.display_value  (display_value),
	.point			(point)
);

freq_meter_calc #(
    .CLK_FREQ(32'd100_000_000) // 100 MHz
)
freq_meter_calc_inst
(
	.clk_100M		(clk_100M)		,
	.sys_clk		(sys_clk	),          // 1000 MHz 输入时钟信号
	.rst_n			(sys_rst_n		),              // 低有效复位信号
	.input_signal	(input_signal),       // 输入的周期性数字信号
	.duty_out		(duty_out	),    // 输出占空比（28位）（万分之一）
	.high_time_out	(high_time_out),  // 输出高电平时间(us)（28位）
	.low_time_out   (low_time_out ), // 输出低电平时间(us)（28位）
	.LED1           (LED1		)
);


freq_meter_calc_2   freq_meter_calc_2_inst
(
	.clk_100M		(clk_100M)		,
	.sys_clk     	(sys_clk     )	,   //系统时钟,频率50MHz
	.sys_rst_n   	(sys_rst_n   )	,   //复位信号,低电平有效
	.input_signal   (input_signal) 	,   //待检测时钟
	.freq           (freq_out  ) //待检测时钟频率

);

endmodule