module	TOP_ALL (
    input       clk50m,
    input       reset_n,
    inout [7:0] fx2_fdata,  //  FX2型USB2.0芯片的SlaveFIFO的数据线
    input       fx2_flagb,  //  FX2型USB2.0芯片的端点2 OUT空标志，1为非空，0为空
    input       fx2_flagc,  //  FX2型USB2.0芯片的端点6 IN满标志，1为非满，0为满
    input       fx2_ifclk,  //  FX2型USB2.0芯片的接口时钟信号

    output [1:0] fx2_faddr,  //  FX2型USB2.0芯片的SlaveFIFO的FIFO地址线
    output fx2_sloe,  //  FX2型USB2.0芯片的SlaveFIFO的输出使能信号，低电平有效
    output fx2_slwr,  //  FX2型USB2.0芯片的SlaveFIFO的写控制信号，低电平有效
    output fx2_slrd,  //  FX2型USB2.0芯片的SlaveFIFO的读控制信号，低电平有效
    output fx2_pkt_end,  //数据包结束标志信号
    output fx2_slcs,
    //FPGA与FX2之间的SPI接口，用来传输端点0的特定数据包
    input  FX2_SPI_CS,
    input  FX2_SPI_SCLK,
    input  FX2_SPI_MOSI,
    output FX2_SPI_MISO,
    //拨码开关用来切换数码管的显示内容和SPI/UART功能
    input  SW0,     //切换数码管显示
    input  SW1,     //在SW6为1的情况下切换SPI/UART，1为UART
	input  SW2,     // 在SW6=1且SW=1的情况下，切换cdc接收，1为uart，0为iic
	input  SW3,    // SW03为0时控制转PWM波和自定义序列的初始化
	input  SW4,		//SW4为0时DDS为默认输出
	input  SW5,		//SW5为0时为数字信号测量，为1时为USB2.0协议解析
	input  SW6,		//SW6为0时接受logic信号，为1时接受（uart/iic/spi);
	input  SW7,		//SW7为1时接收手绘波形输入数据
    //数码管显示
    output sh_cp,
    output st_cp,
    output ds,
    //UART连接到板载的USB转串口芯片
    output uart_tx,
    input  uart_rx,
    //SPI连接到板载的ADC128S
    output SPI_M_CS,
    output SPI_M_SCLK,
    output SPI_M_MOSI,
    input  SPI_M_MISO,
	//SPI 引出IO口
    output SPI_M_CS_io,
    output SPI_M_SCLK_io,
    output SPI_M_MOSI_io,
    //input  SPI_M_MISO_io,	

	output	[3:0] pwm_out,
	output	[3:0] user_ctrl_series_out,
	
	
	//iic接口
	inout i2c_sdat,
    output i2c_sclk,
	//iic接口（引出io）
	inout  i2c_sdat_io,
	output i2c_sclk_io,
	
	//DDS接口
    output  wire            dac_clk_1     		,   //输入DAC_1模块时钟
	output  wire            dac_clk_2     		,   //输入DAC_2模块时钟
    output  wire    [7:0]   dac_data_1          ,//输入DAC模块波形数据
	output	wire	[7:0]	dac_data_2			,

    //ACM2108
    input [7:0]ad_in1,         
	input [7:0]ad_in2,         
	output  ad_clk1,         
	output  ad_clk2,            


    //eth_rx
    input         rgmii_rx_clk_i,
    input  [3:0]  rgmii_rxd,
    input         rgmii_rxdv,
    output 		  eth_rst_n, 
    output        eth_mdc,
    output        eth_mdio, 

    //eth_tx
    output        rgmii_tx_clk,
    output  [3:0] rgmii_txd,
    output        rgmii_txen,

    //ddr
    output [13:0] O_ddr_addr        ,
    output [2:0] O_ddr_ba           ,
    output O_ddr_cs_n               ,
    output O_ddr_ras_n              ,
    output O_ddr_cas_n              ,
    output O_ddr_we_n               ,
    output O_ddr_clk                ,
    output O_ddr_clk_n              ,
    output O_ddr_cke                ,
    output O_ddr_odt                ,
    output O_ddr_reset_n            ,
    output [1:0] O_ddr_dqm          ,
    inout  [15:0] IO_ddr_dq          ,
    inout  [1:0] IO_ddr_dqs          ,
    inout  [1:0] IO_ddr_dqs_n        ,
	
	input  KEY_1,
	input  input_signal,
	//led
	output LED0, //数码管高低电平显示指示，亮为ns，不亮为us
	output LED1, //ADC网口传输
	output LED2, //ADC网口传输
	output LED3,  //ADC网口传输
/* 	output LED4,
	output LED5,
	output LED6,
	output LED7, */
	//
	//逻辑分析仪信号
	input	[7:0]	signal_in_logic
);


wire	sh_cp_digital_measure;
wire	st_cp_digital_measure;
wire	ds_digital_measure;
wire	sh_cp_usb_measure;
wire	st_cp_usb_measure;
wire	ds_usb_measure;

//引出iicio口和引出spiio口：
assign  i2c_sclk_io = i2c_sclk;
assign   SPI_M_CS_io = SPI_M_CS;
assign   SPI_M_SCLK_io = SPI_M_SCLK;
assign	 SPI_M_MOSI_io = SPI_M_MOSI;
//assign	 SPI_M_MISO_io = SPI_M_MISO;


assign  sh_cp = (SW5) ? sh_cp_usb_measure : sh_cp_digital_measure;
assign  st_cp = (SW5) ? st_cp_usb_measure : st_cp_digital_measure;
assign  ds = (SW5) ? ds_usb_measure    : ds_digital_measure;

top_USB_UART_SPI_PWM_IIC_DDS  top_USB_UART_SPI_PWM_IIC_DDS_inst
(
    .clk			(clk50m			),
    .reset_n		(reset_n		),
    .fx2_fdata		(fx2_fdata		),  //  FX2型USB2.0芯片的SlaveFIFO的数据线
    .fx2_flagb		(fx2_flagb		),  //  FX2型USB2.0芯片的端点2 OUT空标志，1为非空，0为空
    .fx2_flagc		(fx2_flagc		),  //  FX2型USB2.0芯片的端点6 IN满标志，1为非满，0为满
    .fx2_ifclk		(fx2_ifclk		),  //  FX2型USB2.0芯片的接口时钟信号
    .fx2_faddr		(fx2_faddr		),  //  FX2型USB2.0芯片的SlaveFIFO的FIFO地址线
    .fx2_sloe		(fx2_sloe		),  //  FX2型USB2.0芯片的SlaveFIFO的输出使能信号，低电平有效
    .fx2_slwr		(fx2_slwr		),  //  FX2型USB2.0芯片的SlaveFIFO的写控制信号，低电平有效
    .fx2_slrd		(fx2_slrd		),  //  FX2型USB2.0芯片的SlaveFIFO的读控制信号，低电平有效
    .fx2_pkt_end	(fx2_pkt_end	),  //数据包结束标志信号
    .fx2_slcs		(fx2_slcs		),
    .FX2_SPI_CS		(FX2_SPI_CS		),
    .FX2_SPI_SCLK	(FX2_SPI_SCLK	),
    .FX2_SPI_MOSI	(FX2_SPI_MOSI	),
    .FX2_SPI_MISO	(FX2_SPI_MISO	),
    .SW0			(SW0			),     //切换数码管显示
    .SW1			(SW1			),     //切换SPI/UART，1为UART
	.SW2			(SW2			),     // 在SW=1的情况下，切换cdc接收，1为uart，0为iic
	.SW3			(SW3			),    // SW03为0时控制转PWM波和自定义序列的初始化
	.SW4			(SW4			),		//SW4为0时DDS为默认输出
	.SW6			(SW6			),
	.SW7			(SW7			),		//SW7为1时接收手绘波形输入数据
    .sh_cp			(sh_cp_usb_measure			),
    .st_cp			(st_cp_usb_measure			),
    .ds				(ds_usb_measure				),
    .uart_tx		(uart_tx		),
    .uart_rx		(uart_rx		),
    .SPI_M_CS		(SPI_M_CS		),
    .SPI_M_SCLK		(SPI_M_SCLK		),
    .SPI_M_MOSI		(SPI_M_MOSI		),
    .SPI_M_MISO		(SPI_M_MISO		),
	.pwm_out				(pwm_out				),
	.user_ctrl_series_out	(user_ctrl_series_out	),
	.i2c_sdat				(i2c_sdat				),
	.i2c_sdat_io			(i2c_sdat_io			),
    .i2c_sclk				(i2c_sclk				),
    .dac_clk_1     			(dac_clk_1     			),   //输入DAC_1模块时钟
	.dac_clk_2     			(dac_clk_2     			),   //输入DAC_2模块时钟
    .dac_data_1         	(dac_data_1         	),//输入DAC模块波形数据
	.dac_data_2             (dac_data_2)			,
	.signal_in_logic		(signal_in_logic		)
);

top_acm2108_ddr3_rgmii  top_acm2108_ddr3_rgmii_inst(
    //System clock reset
    .clk50m        			(clk50m        			),
    .reset_n       			(reset_n       			), 
    .led           			({LED3,LED2,LED1}           			),
    .ad_in1					(ad_in1					),         
	.ad_in2					(ad_in2					),         
	.ad_clk1				(ad_clk1				),         
	.ad_clk2				(ad_clk2				),            
    .rgmii_rx_clk_i			(rgmii_rx_clk_i			),
    .rgmii_rxd				(rgmii_rxd				),
    .rgmii_rxdv				(rgmii_rxdv				),
    .eth_rst_n				(eth_rst_n				), 
    .eth_mdc				(eth_mdc				),
    .eth_mdio				(eth_mdio				), 
    .rgmii_tx_clk			(rgmii_tx_clk			),
    .rgmii_txd				(rgmii_txd				),
    .rgmii_txen				(rgmii_txen				),
    .O_ddr_addr        		(O_ddr_addr        		),
    .O_ddr_ba           	(O_ddr_ba           	),
    .O_ddr_cs_n             (O_ddr_cs_n             ),
    .O_ddr_ras_n            (O_ddr_ras_n            ),
    .O_ddr_cas_n            (O_ddr_cas_n            ),
    .O_ddr_we_n             (O_ddr_we_n             ),
    .O_ddr_clk              (O_ddr_clk              ),
    .O_ddr_clk_n            (O_ddr_clk_n            ),
    .O_ddr_cke              (O_ddr_cke              ),
    .O_ddr_odt              (O_ddr_odt              ),
    .O_ddr_reset_n          (O_ddr_reset_n          ),
    .O_ddr_dqm         		(O_ddr_dqm         		),
    .IO_ddr_dq          	(IO_ddr_dq          	),
    .IO_ddr_dqs          	(IO_ddr_dqs          	),
    .IO_ddr_dqs_n           (IO_ddr_dqs_n        )

);
top_digital_measure		top_digital_measure_inst
(
	.sys_clk		(clk50m		),
	.sys_rst_n		(reset_n		),
	.key_in			(KEY_1			),
	.input_signal	(input_signal	),
	.sh_cp			(sh_cp_digital_measure			),
	.st_cp			(st_cp_digital_measure			),
	.ds				(ds_digital_measure				),
	.LED1           (LED0)
);
endmodule