`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/31 09:23:49
// Design Name: 
// Module Name: Spi_Master_Ctrl
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

`define D #2

module Spi_Master_Ctrl #(
    parameter integer CPOL = 1'b1,  //空闲时SCK电平：1为高，0为低
    parameter integer CPHA = 1'b0,  //数据捕获边沿：0为第一个边沿，1为第2个边沿
    parameter integer BITS_ORDER = 1'b1  //数据传输位序：1为高位在前，0为低位在前
) (
    input clk,
    input rst_n,
    input [31:0] spi_freq,
    output SPI_CS,
    output SPI_SCLK,
    output SPI_MOSI,
    input SPI_MISO,

    input [7:0] tx_data,
    input trans_en,
    output reg [7:0] rx_data,
    output reg trans_done,
    output reg spi_busy
);

  localparam TIMEOUT_CNT_MAX = 48; //超过时间没收到下一个SPI包，则拉高CS

  reg  cs;
  reg  sclk;
  reg  mosi;
  wire miso;

  assign SPI_CS = cs;
  assign SPI_SCLK = sclk;
  assign SPI_MOSI = mosi;
  assign miso = SPI_MISO;

  //SPI的基准时钟频率为SCLK频率的2倍
  reg [31:0] clk_div_max;
  reg [31:0] clk_div_cnt;
  reg spi_clk_x2;

  reg [7:0] rx_data_r;
  reg [7:0] tx_data_r;
  reg [4:0] spi_state_cnt;

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      clk_div_max <= `D 32'd1;
    end else begin
      clk_div_max <= `D 24000000 / spi_freq;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      clk_div_cnt <= `D 32'd0;
      spi_clk_x2  <= `D 1'b0;
    end else if (clk_div_cnt >= clk_div_max - 1'd1) begin
      clk_div_cnt <= `D 32'd0;
      spi_clk_x2  <= `D 1'b1;
    end else begin
      clk_div_cnt <= `D clk_div_cnt + 1'd1;
      spi_clk_x2  <= `D 1'b0;
    end
  end



  //状态机，接收到en后开启传输，结束后记录超时时间，到达后cs拉高
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      spi_busy <= `D 1'b0;
      rx_data  <= `D 8'h00;
      tx_data_r<= `D 8'h00;
    end else if (trans_en) begin
      spi_busy <= `D 1'b1;
      if(BITS_ORDER)
        tx_data_r  <= `D {tx_data[0],tx_data[1],tx_data[2],tx_data[3],tx_data[4],tx_data[5],tx_data[6],tx_data[7]};
      else
        tx_data_r<= `D tx_data;
      rx_data  <= `D rx_data;
    end else if (spi_state_cnt >= 5'd17 - CPHA) begin
      spi_busy <= `D 1'b0;
      if(BITS_ORDER)
        rx_data  <= `D {rx_data_r[0],rx_data_r[1],rx_data_r[2],rx_data_r[3],rx_data_r[4],rx_data_r[5],rx_data_r[6],rx_data_r[7]};
      else
        rx_data  <= `D rx_data_r;
    end else begin
      spi_busy <= `D spi_busy;
      rx_data  <= `D rx_data;
    end
  end


  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      spi_state_cnt <= `D 5'd0;
      sclk <= `D CPOL;
    end else if (spi_state_cnt >= 5'd17 - CPHA) begin
      sclk <= `D CPOL;
      spi_state_cnt <= `D 5'd0;
    end else if (spi_clk_x2) begin
      if (spi_busy) begin
        if((CPHA == 1'b0) && (spi_state_cnt == 5'd0))
            sclk <= `D sclk;
        else
            sclk <= `D ~sclk;
        spi_state_cnt <= `D spi_state_cnt + 1'd1;
      end else begin
        sclk <= `D CPOL;
        spi_state_cnt <= `D 5'd0;
      end
    end else begin
      spi_state_cnt <= `D spi_state_cnt;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      mosi <= `D 1'b0;
      rx_data_r <= `D 8'h00;
    end else if (spi_clk_x2) begin
      if (spi_state_cnt >= 5'd16) begin
        mosi <= `D 1'b0;
        rx_data_r <= `D rx_data_r;
      end
      else if (~spi_state_cnt[0]) begin
        mosi <= `D tx_data_r[spi_state_cnt[4:1]];
      end else begin
        rx_data_r[spi_state_cnt[4:1]] <= `D miso;
      end
    end else begin
      mosi <= `D mosi;
      rx_data_r <= `D rx_data_r;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      trans_done <= `D 1'b0;
    end else if (spi_state_cnt >= 5'd17 - CPHA) trans_done <= `D 1'b1;
    else trans_done <= `D 1'b0;
  end


  reg [15:0]timeout_cnt;
  reg timeout_flag;

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        cs <= 1'b1;
        timeout_flag <= 1'b0;
        timeout_cnt <= 16'd0;
    end else begin
        if(trans_en) begin
            cs <= 1'b0;
            timeout_flag <= 1'b0;
            timeout_cnt <= 16'd0;
        end
        else if(trans_done) begin
            timeout_flag <= 1'b1;
            timeout_cnt <= 16'd0;
        end
        else if(timeout_flag) begin
            if(timeout_cnt >= TIMEOUT_CNT_MAX - 1'd1) begin
                cs <= 1'b1;
                timeout_flag <= 1'b0;
                timeout_cnt <= 16'd0;
            end else begin
                timeout_cnt <= timeout_cnt + 1'd1;
                cs <= 1'b0;
            end
        end
    end

  end
endmodule
