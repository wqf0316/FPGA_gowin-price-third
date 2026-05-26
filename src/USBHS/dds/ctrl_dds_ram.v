//////////////////////////////////////////////////////////////////////////////////
// Company: 武汉芯路恒科技有限公司
// Engineer: 小梅哥团队
// Web: www.corecourse.cn
// 
// Create Date: 2020/07/20 00:00:00
// Design Name: ram_ip
// Module Name: ctrl
// Project Name: ram_ip
// Description: ram_ip控制程序
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ctrl_dds_ram(
	fx2_ifclk					,
	clk_50M					,
	reset_n					,
	SW7						,
	rx_data 				,
	rx_done_in				,
	rom_addr_channel_1		,
	rom_addr_channel_2		,
	dds_data_out_channel_1	,
	dds_data_out_channel_2
);
	wire reset;
	input fx2_ifclk;     //usb时钟48M
	input clk_50M;	   //时钟输入50M
	input reset_n;    //模块复位，低有效
	input SW7;
	input rx_done_in;    //串口一次数据接收完成标志 
	input [7:0] rx_data;
	input [11:0]rom_addr_channel_1;      //dpram读地址
	input [11:0]rom_addr_channel_2;      //dpram读地址
	output [7:0] dds_data_out_channel_1;
	output [7:0] dds_data_out_channel_2;

	reg [11:0]addra;      //dpram写地址
	reg [11:0]addrb;
	reg send_state;
	reg send_1st_en;
	reg tx_done_dly1;
	reg tx_done_dly2;
	reg tx_done_dly3;
	reg [7:0]	rx_data_reg_1;
	reg [7:0]	rx_data_reg_2;
	reg [7:0]	rx_data_reg_3;
	reg [7:0]	rx_data_reg_4;
	reg [27:0] clean_time;
	wire send_en_pre;
	wire rx_done;
	
	
    assign rx_done = SW7 ? rx_done_in : 1'b0;
    assign reset = ~reset_n;
	
	always@(posedge fx2_ifclk or posedge reset)
	if(reset)
		clean_time <= 0;
	else if(rx_done == 1)
		clean_time <= 0;
	else if(clean_time == 28'd50_000_000)
		clean_time <= 0;
	else
		clean_time <= clean_time + 1;
	
	always@(posedge fx2_ifclk or posedge reset)
	if(reset)
		addra <= 12'd0;
	else if(rx_done)
		addra <= addra + 1'b1;
	else if(clean_time == 28'd50_000_000)
		addra <= 12'd0;
	else
		addra <= addra;
	//数据延时四个周期，因为sram写入地址和数据有四个周期差
	always@(posedge fx2_ifclk or negedge reset_n)
		if(reset_n == 0)
			rx_data_reg_1 <= 0;
		else 
			rx_data_reg_1 <= rx_data;
	always@(posedge fx2_ifclk or negedge reset_n)
		if(reset_n == 0)
			rx_data_reg_2 <= 0;
		else 
			rx_data_reg_2 <= rx_data_reg_1;
	always@(posedge fx2_ifclk or negedge reset_n)
		if(reset_n == 0)
			rx_data_reg_3 <= 0;
		else 
			rx_data_reg_3 <= rx_data_reg_2;
	always@(posedge fx2_ifclk or negedge reset_n)
		if(reset_n == 0)
			rx_data_reg_4 <= 0;
		else 
			rx_data_reg_4 <= rx_data_reg_3;
	Gowin_SDPB Gowin_SDPB_channel_1(
    .dout(dds_data_out_channel_1), //output [7:0] dout
    .clka(fx2_ifclk), //input clka
    .cea(1'b1), //input cea
    .clkb(clk_50M), //input clkb
    .ceb(1'b1), //input cebS
    .oce(1'b1), //input oce
    .reset(~reset_n), //input reset
    .ada(addra), //input [11:0] ada
    .din(rx_data_reg_4), //input [7:0] din
    .adb(rom_addr_channel_1) //input [11:0] adb
    );
	
	Gowin_SDPB Gowin_SDPB_channel_2(
    .dout(dds_data_out_channel_2), //output [7:0] dout
    .clka(fx2_ifclk), //input clka
    .cea(1'b1), //input cea
    .clkb(clk_50M), //input clkb
    .ceb(1'b1), //input cebS
    .oce(1'b1), //input oce
    .reset(~reset_n), //input reset
    .ada(addra), //input [11:0] ada
    .din(rx_data_reg_4), //input [7:0] din
    .adb(rom_addr_channel_2) //input [11:0] adb
    );
endmodule