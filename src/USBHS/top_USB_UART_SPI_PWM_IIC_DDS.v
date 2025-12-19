module	top_USB_UART_SPI_PWM_IIC_DDS (
    input       clk,
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
    input  SW1,     //切换SPI/UART，1为UART
	input  SW2,     // 在SW=1的情况下，切换cdc接收，1为uart，0为iic
	input  SW3,    // SW03为0时控制转PWM波和自定义序列的初始化
	input  SW4,		//SW4为0时DDS为默认输出
	input  SW6,		//SW6为0时是逻辑分析仪功能，为1时是其他功能
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


	output	[3:0] pwm_out,
	output	[3:0] user_ctrl_series_out,
	
	
	//iic接口
	inout i2c_sdat,
	inout i2c_sdat_io,
    output i2c_sclk,
	//DDS接口
    output  wire            dac_clk_1     		,   //输入DAC_1模块时钟
	output  wire            dac_clk_2     		,   //输入DAC_2模块时钟
    output  wire    [7:0]   dac_data_1          ,//输入DAC模块波形数据
	output	wire	[7:0]	dac_data_2			,
	//逻辑分析仪信号
	input	[7:0]		signal_in_logic			
);

	
	//输出串口信号，到其他模块进行处理
	wire	[7:0]	byte_tx_data;
	wire	byte_send_en;
    wire    [7:0]  iic_cdc_data;
	wire    iic_cdc_done;
	wire	[7:0] logic_analysize_data;
	wire	logic_analysize_en;
FX2_CDC_UART_SPI FX2_CDC_UART_SPI
(
    .clk		(clk		)	,
    .reset_n	(reset_n	)	,
    .fx2_fdata	(fx2_fdata	),  //  FX2型USB2.0芯片的SlaveFIFO的数据线
    .fx2_flagb	(fx2_flagb	),  //  FX2型USB2.0芯片的端点2 OUT空标志，1为非空，0为空
    .fx2_flagc	(fx2_flagc	),  //  FX2型USB2.0芯片的端点6 IN满标志，1为非满，0为满
    .fx2_ifclk	(fx2_ifclk	),  //  FX2型USB2.0芯片的接口时钟信号
	
    .fx2_faddr		(fx2_faddr		),  //  FX2型USB2.0芯片的SlaveFIFO的FIFO地址线
    .fx2_sloe		(fx2_sloe		),  //  FX2型USB2.0芯片的SlaveFIFO的输出使能信号，低电平有效
    .fx2_slwr		(fx2_slwr		),  //  FX2型USB2.0芯片的SlaveFIFO的写控制信号，低电平有效
    .fx2_slrd		(fx2_slrd		),  //  FX2型USB2.0芯片的SlaveFIFO的读控制信号，低电平有效
    .fx2_pkt_end	(fx2_pkt_end	),  //数据包结束标志信号
    .fx2_slcs		(fx2_slcs		),
    //FPGA与FX2之间的SPI接口，用来传输端点0的特定数据包
    .FX2_SPI_CS			(FX2_SPI_CS			),
    .FX2_SPI_SCLK		(FX2_SPI_SCLK		),
    .FX2_SPI_MOSI		(FX2_SPI_MOSI		),
    .FX2_SPI_MISO		(FX2_SPI_MISO		),
    //拨码开关用来切换数码管的显示内容和SPI/UART功能
    .SW0(SW0),     //切换数码管显示
    .SW1(SW1),     //切换SPI/UART，1为UART
	.SW2(SW2),
	.SW6(SW6),
    //数码管显示
    .sh_cp	(sh_cp	)	,
    .st_cp	(st_cp	)	,
    .ds		(ds		)	,
    //UART连接到板载的USB转串口芯片
    .uart_tx(uart_tx),
    .uart_rx(uart_rx),
    //SPI连接到板载的ADC128S
    .SPI_M_CS		(SPI_M_CS		),
    .SPI_M_SCLK		(SPI_M_SCLK		),
    .SPI_M_MOSI		(SPI_M_MOSI		),
    .SPI_M_MISO		(SPI_M_MISO		),
	
	//输出串口信号，到其他模块进行处理
	.byte_tx_data(byte_tx_data),
	.byte_send_en(byte_send_en),
	
	.iic_cdc_data(iic_cdc_data),
	.iic_cdc_done(iic_cdc_done),
	.logic_analysize_data(logic_analysize_data),
	.logic_analysize_en(logic_analysize_en)
	
);
uart_rx_ctrl_pwm	uart_rx_ctrl_pwm
(
	.fx2_ifclk					(fx2_ifclk				)	,
    .sys_clk					(clk					)	,
    .reset_n					(reset_n					)	,
	.SW3						(SW3				)	,
    .rx_data					(byte_tx_data),
	.rx_done					(byte_send_en),
	.pwm_out					(pwm_out					)	,
	.user_ctrl_series_out    	(user_ctrl_series_out)
);

top_dds	top_dds_inst
(
    .sys_clk     	(clk     	)	,   //系统时钟,50MHz
	.fx2_ifclk		(fx2_ifclk		)	,
    .sys_rst_n   	(reset_n   	)	,   //复位信号,低电平有效
	.sw4_state   	(SW4   	)	,	//SW4为0时DDS为默认输出
	.SW7            (SW7				) ,
	.rx_data		(byte_tx_data		)	,
	.rx_done        (byte_send_en        ) 	,
    .dac_clk_1     	(dac_clk_1     	)	,   //输入DAC_1模块时钟
	.dac_clk_2     	(dac_clk_2     	)	,   //输入DAC_2模块时钟
    .dac_data_1     (dac_data_1     )   ,//输入DAC模块波形数据
	.dac_data_2     (dac_data_2)
);

iic_top iic_top
(
	.clk_USB_FX		(fx2_ifclk		)	,
    .rst_n			(reset_n			)	,	
    .i2c_sclk		(i2c_sclk		)	,
    .i2c_sdat		(i2c_sdat		)	,
	.i2c_sdat_io    (i2c_sdat_io    )   ,
    .rx_data		(byte_tx_data  )	,
	.rx_done		(byte_send_en	)	,
	.data_byte		(iic_cdc_data		)	,   
	.byte_send_en   (iic_cdc_done)
	
);

logic_top	logic_top_inst
(
    .fx2_ifclk	(fx2_ifclk	)	,
    .reset_n	(reset_n	)	,
    .rx_data	(byte_tx_data	)	,
    .rx_done	(byte_send_en	)	,
    .signal_in	(signal_in_logic	)	,
    .tx_data	(logic_analysize_data	)	,
    .tx_en      (logic_analysize_en)
);

endmodule