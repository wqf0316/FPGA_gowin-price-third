`timescale  1ns/1ns

module  dds
(
    input   wire            sys_clk     	,   //系统时钟,50MHz
    input   wire            sys_rst_n   	,   //复位信号,低电平有效
    input   wire    [4:0]   wave_select_1 	,   //输出channel1波形选择
	input   wire    [4:0]   wave_select_2 	,   //输出channel2波形选择
	input	wire	[31:0]	freq_ctrl_1		,
	input	wire	[31:0]	phase_ctrl_1 	,
	input	wire	[31:0]	freq_ctrl_2		,
	input	wire	[31:0]	phase_ctrl_2 	,
	input	wire	[7:0]	data_reg5_channel_1,
	input	wire	[7:0]	data_reg5_channel_2,
    output  reg     [7:0]   data_out_1		,	//波形输出
	output	reg		[7:0]	data_out_2		,
	output	reg     [11:0]  rom_addr_channel_1    ,   //ROM通道1读地址
	output	reg     [11:0]  rom_addr_channel_2       //ROM通道2读地址
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   sin_wave    =   5'b00001     ,   //正弦波
            squ_wave    =   5'b00010     ,   //方波
            tri_wave    =   5'b00100     ,   //三角波
            saw_wave    =   5'b01000     ,   //锯齿波
			half_sin_wave = 5'b10000	 ;	 //半正弦波
parameter   FREQ_CTRL   =   32'd42949   ,   //相位累加器单次累加值
            PHASE_CTRL  =   12'd1024    ;   //相位偏移量

//reg   define
reg     [31:0]  fre_add_channel_1     ;   //相位累加器,最大值为
reg		[31:0]	fre_add_channel_2	  ;
reg     [4:0]   wave_select_1_reg 	;
reg     [4:0]   wave_select_2_reg 	;
reg		[31:0]	freq_ctrl_1_reg		;
reg		[31:0]	phase_ctrl_1_reg 	;
reg		[31:0]	freq_ctrl_2_reg		;
reg		[31:0]	phase_ctrl_2_reg 	;



//wire   define
wire    key_restart;
wire	[7:0]	data_reg1_channel_1;
wire	[7:0]	data_reg2_channel_1;
wire	[7:0]	data_reg3_channel_1;
wire	[7:0]	data_reg4_channel_1;


wire	[7:0]	data_reg1_channel_2;
wire	[7:0]	data_reg2_channel_2;
wire	[7:0]	data_reg3_channel_2;
wire	[7:0]	data_reg4_channel_2;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)	begin
		wave_select_1_reg 	<=0	;
		wave_select_2_reg 	<=0	;
		freq_ctrl_1_reg		<=0	;
		phase_ctrl_1_reg 	<=0	;
		freq_ctrl_2_reg		<=0	;
		phase_ctrl_2_reg 	<=0	;
	end
	else begin
		wave_select_1_reg 	<= wave_select_1 	;
		wave_select_2_reg 	<= wave_select_2 	;
		freq_ctrl_1_reg		<= freq_ctrl_1		;
		phase_ctrl_1_reg 	<= phase_ctrl_1 	    ;
		freq_ctrl_2_reg		<= freq_ctrl_2		;
		phase_ctrl_2_reg 	<= phase_ctrl_2 		;		
	end
	
assign key_restart = ((wave_select_1_reg==wave_select_1)
&&(wave_select_2_reg == wave_select_2)
&&(freq_ctrl_1_reg	== freq_ctrl_1)
&&(phase_ctrl_1_reg == phase_ctrl_1)
&&(freq_ctrl_2_reg	== freq_ctrl_2)
&&(phase_ctrl_2_reg == phase_ctrl_2))? 0:1;	
	
	
always@(posedge sys_clk)
    case(wave_select_1)
        sin_wave:		data_out_1 <= 8'd255 - data_reg1_channel_1;
        squ_wave:		data_out_1 <= 8'd255 - data_reg2_channel_1;
        tri_wave:		data_out_1 <= 8'd255 - data_reg3_channel_1;
        saw_wave:		data_out_1 <= 8'd255 - data_reg4_channel_1;
		half_sin_wave:	data_out_1 <= 8'd255 - data_reg5_channel_1;
		default:		data_out_1 <= 8'd255 - data_reg1_channel_1;
    endcase
always@(posedge sys_clk)
    case(wave_select_2)
        sin_wave:		data_out_2 <= 8'd255 - data_reg1_channel_2;
        squ_wave:		data_out_2 <= 8'd255 - data_reg2_channel_2;
        tri_wave:		data_out_2 <= 8'd255 - data_reg3_channel_2;
        saw_wave:		data_out_2 <= 8'd255 - data_reg4_channel_2;
		half_sin_wave:	data_out_2 <= 8'd255 - data_reg5_channel_2;
		default:		data_out_2 <= 8'd255 - data_reg1_channel_2;	
    endcase	
	
	
//fre_add:相位累加器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)	begin
        fre_add_channel_1 <=  32'd0;
		fre_add_channel_2 <= 32'd0;	end
	else	if(key_restart == 1'b1)	begin
		fre_add_channel_1 <= 32'd0;
		fre_add_channel_2 <= 32'd0;	end
    else	begin
        fre_add_channel_1 <=  fre_add_channel_1 + freq_ctrl_1;
		fre_add_channel_2 <=  fre_add_channel_2 + freq_ctrl_2;	end
//rom_addr读地址
always@(posedge	sys_clk or negedge	sys_rst_n)
	if(sys_rst_n == 1'b0)
        begin
            rom_addr_channel_1        <=  12'd0;
			rom_addr_channel_2        <=  12'd0;
        end
	else	begin	
		rom_addr_channel_1 <= fre_add_channel_1[31:20] + phase_ctrl_1[31:20];
		rom_addr_channel_2 <= fre_add_channel_2[31:20] + phase_ctrl_2[31:20];	end
		

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------------------- rom_wave_inst for channel_1 ------------------------
Gowin_pROM_sin_wave sin_wave_inst_channel_1(
    .dout(data_reg1_channel_1)	, //output [7:0] dout
    .clk(sys_clk)		, //input clk
    .oce(1'b1)		, //input oce
    .ce(1'b1)		, //input ce
    .reset(~sys_rst_n)	, //input reset
    .ad(rom_addr_channel_1) 		  //input [11:0] ad
);
Gowin_pROM_squ_wave squ_wave_inst_channel_1(
    .dout(data_reg2_channel_1)	, //output [7:0] dout
    .clk(sys_clk)		, //input clk
    .oce(1'b1)		, //input oce
    .ce(1'b1)		, //input ce
    .reset(~sys_rst_n)	, //input reset
    .ad(rom_addr_channel_1) 		  //input [11:0] ad
);
Gowin_pROM_tri_wave tri_wave_inst_channel_1(
    .dout(data_reg3_channel_1)	, //output [7:0] dout
    .clk(sys_clk)		, //input clk
    .oce(1'b1)		, //input oce
    .ce(1'b1)		, //input ce
    .reset(~sys_rst_n)	, //input reset
    .ad(rom_addr_channel_1) 		  //input [11:0] ad
);

Gowin_pROM_saw_wave saw_wave_inst_channel_1(
    .dout(data_reg4_channel_1)	, //output [7:0] dout
    .clk(sys_clk)		, //input clk
    .oce(1'b1)		, //input oce
    .ce(1'b1)		, //input ce
    .reset(~sys_rst_n)	, //input reset
    .ad(rom_addr_channel_1) 		  //input [11:0] ad
);


/* Gowin_pROM_half_sin_wave half_sin_wave_inst_channel_1(
    .dout(data_reg5_channel_1)		, //output [7:0] dout
    .clk(sys_clk)		, //input clk
    .oce(1'b1)		, //input oce
    .ce(1'b1)			, //input ce
    .reset(~sys_rst_n)	, //input reset
    .ad(rom_addr_channel_1) 		  //input [11:0] ad
); */
//------------------------- rom_wave_inst for channel_2 ------------------------


Gowin_pROM_sin_wave sin_wave_inst_channel_2(
    .dout(data_reg1_channel_2)	, //output [7:0] dout
    .clk(sys_clk)		, //input clk
    .oce(1'b1)		, //input oce
    .ce(1'b1)		, //input ce
    .reset(~sys_rst_n)	, //input reset
    .ad(rom_addr_channel_2) 		  //input [11:0] ad
);
Gowin_pROM_squ_wave squ_wave_inst_channel_2(
    .dout(data_reg2_channel_2)	, //output [7:0] dout
    .clk(sys_clk)		, //input clk
    .oce(1'b1)		, //input oce
    .ce(1'b1)		, //input ce
    .reset(~sys_rst_n)	, //input reset
    .ad(rom_addr_channel_2) 		  //input [11:0] ad
);
Gowin_pROM_tri_wave tri_wave_inst_channel_2(
    .dout(data_reg3_channel_2)	, //output [7:0] dout
    .clk(sys_clk)		, //input clk
    .oce(1'b1)		, //input oce
    .ce(1'b1)		, //input ce
    .reset(~sys_rst_n)	, //input reset
    .ad(rom_addr_channel_2) 		  //input [11:0] ad
);

Gowin_pROM_saw_wave saw_wave_inst_channel_2(
    .dout(data_reg4_channel_2)	, //output [7:0] dout
    .clk(sys_clk)		, //input clk
    .oce(1'b1)		, //input oce
    .ce(1'b1)		, //input ce
    .reset(~sys_rst_n)	, //input reset
    .ad(rom_addr_channel_2) 		  //input [11:0] ad
);


/* Gowin_pROM_half_sin_wave half_sin_wave_inst_channel_2(
    .dout(data_reg5_channel_2)		, //output [7:0] dout
    .clk(sys_clk)		, //input clk
    .oce(1'b1)		, //input oce
    .ce(1'b1)			, //input ce
    .reset(~sys_rst_n)	, //input reset
    .ad(rom_addr_channel_2) 		  //input [11:0] ad
); */
endmodule
