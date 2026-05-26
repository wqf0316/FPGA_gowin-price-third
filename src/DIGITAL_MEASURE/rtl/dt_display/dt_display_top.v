//////////////////////////////////////////////////////////////////////////////////
// Company: 武汉芯路恒科技有限公司
// Engineer: 小梅哥团队
// Web: www.corecourse.cn
// 
// Create Date: 2020/07/20 00:00:00
// Design Name: hex8
// Module Name: hex_top
// Project Name: hex8
// Description: 数码管显示项目的顶层文件，协调VIO，hex8和hc595的工作和接口
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module dt_display_top(
	clk,
	reset_n,
	display_value,
	point,
	sh_cp,
	st_cp,
	ds

);

	input clk;	//50M
	input reset_n;
	input [27:0]display_value;
	input	[7:0]	point;
	output sh_cp;
	output st_cp;
	output ds;
	
	wire [7:0] sel;//数码管位选（选择当前要显示的数码管）
	wire [7:0] seg;//数码管段选（当前要显示的内容)
	
	hc595_driver hc595_driver_digital_measure(
		.clk(clk),
		.reset_n(reset_n),
		.data({seg,sel}),
		.s_en(1'b1),
		.sh_cp(sh_cp),
		.st_cp(st_cp),
		.ds(ds)
	);
	seg_dynamic  seg_dynamic_inst
	(
		.sys_clk     (clk), //系统时钟，频率50MHz
		.sys_rst_n   (reset_n), //复位信号，低有效
		.data        (display_value), //数码管要显示的值 (28位输入数据)
		.point       (point), //小数点显示,高电平有效 (支持到千万位)
		.seg_en      (1), //数码管使能信号，高电平有效
		.sign        (0), //符号位，高电平显示负号
		.sel         (sel), //数码管位选信号
		.seg         (seg)  //数码管段选信号
	);

endmodule
