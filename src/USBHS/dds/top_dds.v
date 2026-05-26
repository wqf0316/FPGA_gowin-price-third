`timescale  1ns/1ns
/////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/10
// Module Name   : top_dds
// Project Name  : top_dds
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : DDS信号发生器顶层模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  top_dds
(
    input   wire            sys_clk     		,   //系统时钟,50MHz
	input   wire 			fx2_ifclk			,
    input   wire            sys_rst_n   		,   //复位信号,低电平有效
	input	wire			sw4_state   		,	//SW4为0时DDS为默认输出
	input   wire 			SW7					,	//SW7为1时接收手绘波形输入数据
	input	wire	[7:0]	rx_data				,
	input   wire            rx_done         	,
    output  wire            dac_clk_1     		,   //输入DAC_1模块时钟
	output  wire            dac_clk_2     		,   //输入DAC_2模块时钟
    output  wire    [7:0]   dac_data_1          ,//输入DAC模块波形数据
	output	wire	[7:0]	dac_data_2
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire    [4:0]   wave_select_1 ;   //波形选择
wire	[4:0]	wave_select_2;
wire	key_restart;
wire	[31:0]	freq_ctrl_1	     ;
wire	[31:0]	phase_ctrl_1     ;
wire	[31:0]	freq_ctrl_2	     ;
wire	[31:0]	phase_ctrl_2     ;
wire	[7:0]	data_reg5_channel_1;
wire	[7:0]	data_reg5_channel_2;
wire	[11:0]	rom_addr_channel_1;
wire	[11:0]	rom_addr_channel_2;
parameter   CNT_MAX =   20'd999_999;    //计数器计数最大值
//dac_clka:DAC模块时钟
assign  dac_clk_1  = ~sys_clk;
assign  dac_clk_2  = ~sys_clk;
//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//-------------------------- dds_inst -----------------------------
/* dds		dds_inst
(
    .sys_clk     	(sys_clk     	)	,   //系统时钟,50MHz
    .sys_rst_n   	(sys_rst_n   	)	,   //复位信号,低电平有效
    .wave_select_1 	(wave_select_1 	)	,   //输出channel1波形选择
	.wave_select_2 	(wave_select_2 	)	,   //输出channel2波形选择
	.freq_ctrl_1	(freq_ctrl_1	)	,
	.phase_ctrl_1 	(phase_ctrl_1 	)	,
	.freq_ctrl_2	(freq_ctrl_2	)	,
	.phase_ctrl_2 	(phase_ctrl_2 	)	,
    .data_out_1		(dac_data_1		)	,	//波形输出
	.data_out_2	    (dac_data_2	)
); */

dds		dds_inst
(
    .sys_clk     		(sys_clk     		)	,   //系统时钟,50MHz
    .sys_rst_n   		(sys_rst_n   		)	,   //复位信号,低电平有效
    .wave_select_1 		(wave_select_1 		)	,   //输出channel1波形选择
	.wave_select_2 		(wave_select_2 		)	,   //输出channel2波形选择
	.freq_ctrl_1		(freq_ctrl_1		)	,
	.phase_ctrl_1 		(phase_ctrl_1 		)	,
	.freq_ctrl_2		(freq_ctrl_2		)	,
	.phase_ctrl_2 		(phase_ctrl_2 		)	,
	.data_reg5_channel_1(data_reg5_channel_1)	,
	.data_reg5_channel_2(data_reg5_channel_2)	,
    .data_out_1			(dac_data_1			)	,	//波形输出
	.data_out_2			(dac_data_2			)	,
	.rom_addr_channel_1 (rom_addr_channel_1 )   	,   //ROM通道1读地址
	.rom_addr_channel_2 (rom_addr_channel_2 )   	   //ROM通道2读地址
);


ctrl_dds_ram	ctrl_dds_ram_inst
(
	.fx2_ifclk				(fx2_ifclk				)	,
	.clk_50M				(sys_clk				)	,
	.reset_n				(sys_rst_n				)	,
	.SW7					(SW7					)	,
	.rx_data 				(rx_data 				)	,
	.rx_done_in				(rx_done				)	,
	.rom_addr_channel_1		(rom_addr_channel_1		)	,
	.rom_addr_channel_2		(rom_addr_channel_2		)	,
	.dds_data_out_channel_1	(data_reg5_channel_1	)	,
	.dds_data_out_channel_2 (data_reg5_channel_2 ) 
);



uart_cmd_dds	uart_cmd_dds_inst
(
    .sys_clk		(fx2_ifclk		)	,
    .reset_n		(sys_rst_n		)	,
	.sw4_state		(sw4_state      )	,
    .rx_data		(rx_data		)	,
    .rx_done		(rx_done		)	,
	.wave_select_1 	(wave_select_1 	)	,
	.wave_select_2 	(wave_select_2 	)	,
	.freq_ctrl_1	(freq_ctrl_1	)	,
	.phase_ctrl_1 	(phase_ctrl_1 	)	,
	.freq_ctrl_2	(freq_ctrl_2	)	,
	.phase_ctrl_2 	(phase_ctrl_2 	)
);
//----------------------- key_control_inst ------------------------

endmodule
