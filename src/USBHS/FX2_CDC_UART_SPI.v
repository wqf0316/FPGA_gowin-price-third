`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/29 09:47:09
// Design Name: 
// Module Name: FX2_CDC_UART_SPI
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FX2_CDC_UART_SPI (
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
	input  SW2,     // 在SW=1的情况下，切换cdc接收，1为uart，0为iic。
	input  SW6,		//SW6为0时是逻辑分析仪功能，为1时是其他功能
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
	
	//输出串口信号，到其他模块进行处理
	output	byte_tx_data,
	output	byte_send_en,
	
	//iic的输入信号
	input	iic_cdc_data,
	input	iic_cdc_done,
	//logic分析仪输入信号
	input 	logic_analysize_data,
	input	logic_analysize_en
);

  wire [7:0] Param0;
  wire [7:0] Param1;
  wire [7:0] Param2;
  wire [7:0] Param3;
  wire [7:0] Param4;
  wire [7:0] Param5;
  wire [7:0] Param6;

  User_Param User_Param_inst (
      .clk     (fx2_ifclk),
      .reset_n (rst_n & reset_n),
      .SPI_CS  (FX2_SPI_CS),
      .SPI_SCLK(FX2_SPI_SCLK),
      .SPI_MOSI(FX2_SPI_MOSI),
      .SPI_MISO(FX2_SPI_MISO),
      .Param0  (Param0),
      .Param1  (Param1),
      .Param2  (Param2),
      .Param3  (Param3),
      .Param4  (Param4),
      .Param5  (Param5),
      .Param6  (Param6)
  );

  wire [ 7:0] sel;  //数码管位选（选择当前要显示的数码管）
  wire [ 6:0] seg;  //数码管段选（当前要显示的内容)
  wire [31:0] disp_data;

  hc595_driver hc595_driver (
      .clk    (fx2_ifclk),
      .reset_n(rst_n & reset_n),
      .data   ({1'd1, seg, sel}),
      .s_en   (1'b1),
      .sh_cp  (sh_cp),
      .st_cp  (st_cp),
      .ds     (ds)
  );

  hex8 hex8 (
      .clk      (fx2_ifclk),
      .reset_n  (rst_n & reset_n),
      .en       (1'b1),
      .disp_data(disp_data),
      .sel      (sel),
      .seg      (seg)
  );


  // 三态处理
  wire [7:0] fx2_fdata_in;
  wire [7:0] fx2_fdata_out;
  assign fx2_fdata_in = fx2_slrd ? 8'h00 : fx2_fdata;
  assign fx2_fdata    = fx2_slwr ? 8'hZZ : fx2_fdata_out;

  wire byte_send_en;
  wire byte_tx_done;
  wire byte_rx_done;
  wire [7:0] byte_tx_data;
  wire [7:0] byte_rx_data;
  wire [7:0] iic_cdc_data;
  wire  iic_cdc_done;
  wire [7:0] logic_analysize_data;
  wire   logic_analysize_en;

  wire uart_send_en;
  wire uart_send_done;
  wire uart_recv_done;
  wire spi_trans_en;
  wire spi_trans_done;
  wire [7:0] uart_tx_data;
  wire [7:0] uart_rx_data;
  wire [7:0] spi_tx_data;
  wire [7:0] spi_rx_data;

  assign disp_data = SW0 ? {8'h00, Param6, Param5, Param4} : {Param3, Param2, Param1, Param0};

  assign uart_send_en = SW1 ? byte_send_en : 1'b0;
  assign spi_trans_en = SW1 ? 1'b0 : byte_send_en;
  assign uart_tx_data = SW1 ? byte_tx_data : 8'h00;
  assign spi_tx_data = SW1 ? 8'h00 : byte_tx_data;
  assign byte_tx_done = SW1 ? uart_send_done : spi_trans_done;
  assign byte_rx_done = SW6 ? (SW1 ? (SW2 ? uart_recv_done : iic_cdc_done ): spi_trans_done ) : logic_analysize_en  ;
  assign byte_rx_data = SW6 ? (SW1 ? (SW2 ? uart_rx_data   : iic_cdc_data ): spi_rx_data) : logic_analysize_data    ;

  wire rx_fifo_full;
  wire rx_fifo_empty;
  wire rx_fifo_pop;

  wire tx_fifo_full;
  wire tx_fifo_push;
  wire tx_fifo_empty;
  wire tx_fifo_pop;

  fifo_1024x8 tx_fifo (
      .din       (fx2_fdata_in),
      .write_busy(tx_fifo_push),
      .fifo_full (tx_fifo_full),
      .dout      (byte_tx_data),
      .read_busy (tx_fifo_pop),
      .fifo_empty(tx_fifo_empty),
      .fifo_clk  (fx2_ifclk),
      .reset_    (rst_n & reset_n),
      .fifo_flush(1'b0)
  );

  // rx fifo
  fifo_1024x8 rx_fifo (
      .din       (byte_rx_data),
      .write_busy((byte_rx_done & (~rx_fifo_full))),
      .fifo_full (rx_fifo_full),
      .dout      (fx2_fdata_out),
      .read_busy (rx_fifo_pop),
      .fifo_empty(rx_fifo_empty),
      .fifo_clk  (fx2_ifclk),
      .reset_    (rst_n & reset_n),
      .fifo_flush(1'b0)
  );

  fx2_fifo_crtl fx2_fifo_crtl_inst (
      .fx2_ifclk(fx2_ifclk),
      .reset_n(rst_n & reset_n),
	  //都跟FX2输入输出有关，绑定输入输出引脚
      .fx2_flagb(fx2_flagb),  // FX2型USB2.0芯片的端点2 OUT空标志，1为非空，0为空
      .fx2_flagc(fx2_flagc),  // FX2型USB2.0芯片的端点6 IN满标志，1为非满，0为满
      .fx2_faddr(fx2_faddr),  // FX2型USB2.0芯片的SlaveFIFO的FIFO地址线
      .fx2_sloe(fx2_sloe),  // FX2型USB2.0芯片的SlaveFIFO的输出使能信号，低电平有效
      .fx2_slwr(fx2_slwr),  // FX2型USB2.0芯片的SlaveFIFO的写控制信号，低电平有效
      .fx2_slrd(fx2_slrd),  // FX2型USB2.0芯片的SlaveFIFO的读控制信号，低电平有效
	  //与其他模块交互信号
      .rx_fifo_empty(rx_fifo_empty),
      .rx_fifo_full(rx_fifo_full),
      .tx_fifo_full(tx_fifo_full),
      .tx_fifo_push(tx_fifo_push),
      .rx_fifo_pop(rx_fifo_pop),
      .fx2_pkt_end(fx2_pkt_end)
  );

  byte_tx_control byte_tx_control(
    .clk(fx2_ifclk),
    .rst_n(rst_n & reset_n),
    .tx_fifo_empty(tx_fifo_empty),
    .byte_tx_done(byte_tx_done),
    .tx_fifo_pop(tx_fifo_pop),
    .byte_send_en(byte_send_en)
);


  wire [31:0] Baud_Rate;
  wire [31:0] SPI_M_Freq;

  assign Baud_Rate  = {Param3, Param2, Param1, Param0};
  assign SPI_M_Freq = {Param3, Param2, Param1, Param0};

  uart_byte_tx uart_byte_tx (
      .Clk       (fx2_ifclk),
      .Rst_n     (rst_n & reset_n),
      .data_byte (uart_tx_data),
      .send_en   (uart_send_en),
      .Baud_Rate (Baud_Rate),
      .uart_tx   (uart_tx),
      .Tx_Done   (uart_send_done),
      .uart_state(uart_state)
  );


  uart_byte_rx uart_byte_rx (
      .Clk      (fx2_ifclk),
      .Rst_n    (rst_n & reset_n),
      .Baud_Rate(Baud_Rate),
      .uart_rx  (uart_rx),
      .data_byte(uart_rx_data),
      .Rx_Done  (uart_recv_done)
  );


  Spi_Master_Ctrl #(
      .CPOL(1'b1),  //空闲时SCK电平：1为高，0为低
      .CPHA(1'b1),  //数据捕获边沿：0为第一个边沿，1为第2个边沿
      .BITS_ORDER(1'b1)  //数据传输位序：1为高位在前，0为低位在前
  ) Spi_Master_Ctrl (
      .clk(fx2_ifclk),
      .rst_n(rst_n & reset_n),
      .spi_freq(SPI_M_Freq),
      .SPI_CS(SPI_M_CS),
      .SPI_SCLK(SPI_M_SCLK),
      .SPI_MOSI(SPI_M_MOSI),
      .SPI_MISO(SPI_M_MISO),
      .tx_data(spi_tx_data),
      .trans_en(spi_trans_en),
      .rx_data(spi_rx_data),
      .trans_done(spi_trans_done),
      .spi_busy(spi_busy)
  );

    reg [23:0]rst_cnt;
    reg rst_n;

    always @(posedge clk,negedge reset_n)begin  //由于高云复位寄存器问题，增加加一个延时复位
    if(!reset_n)
        rst_cnt <= 0;
    else if(rst_cnt == 5_000_000)
        rst_cnt <= rst_cnt;
    else
        rst_cnt <= rst_cnt + 1;
    end

    always @(posedge clk ,negedge reset_n)begin
    if(!reset_n)
        rst_n <= 0;
    else if((rst_cnt >= 4_000_000) && (rst_cnt <= 4_500_000))
        rst_n <= 0;
    else
        rst_n <= 1;
    end

endmodule
