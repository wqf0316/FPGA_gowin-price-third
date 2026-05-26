module	top_digital_measure
(
	input	sys_clk,
	input	sys_rst_n,
	input	key_in,
	input	input_signal,
	output	sh_cp,
	output	st_cp,
	output	ds,
	output	LED1
);
wire	[27:0]	display_value;
wire	clk_100M;
wire	[7:0]	point;
/* pwm_out pwm_out_inst
(
	.clk_50m(sys_clk)	,      		// 50MHz时钟输入
	.rst_n	(sys_rst_n	)	,        	// 低电平复位信号
	.pwm_out(input_signal)  		     	// 输出方波信号
); */

top_measure_output top_measure_output_inst
(
	.clk_100M	(clk_100M)		,
	.sys_clk   	(sys_clk   	)	,
	.sys_rst_n 	(sys_rst_n 	)	,
	.input_signal(input_signal)	,
	.key_in		(key_in		)	,
	.display_value(display_value),
	.point(point),
	.LED1(LED1)
);

dt_display_top dt_display_top_inst
(
	.clk	(sys_clk	)			,
	.reset_n(sys_rst_n)				,
	.display_value(display_value)	,
	.point(point)					,
	.sh_cp	(sh_cp	)				,
	.st_cp	(st_cp	)				,
	.ds       (ds)
);

Gowin_PLL_digital_measure Gowin_PLL_digital_measure(
        .clkin(sys_clk), //input  clkin
        .init_clk(sys_clk), //input  init_clk
        .clkout0(clk_100M), //output  clkout0
        .reset(~sys_rst_n) //input  reset
);
endmodule