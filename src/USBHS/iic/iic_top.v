//板级运行时请将下属代码注释以屏蔽，仿真时将下属代码取消注释以生效
//`define DO_SIM 1
module iic_top(
	clk_USB_FX,
    rst_n,
    i2c_sclk,
    i2c_sdat,
	i2c_sdat_io,
    rx_data,
	rx_done,
	data_byte,   
	byte_send_en
	
);
	input clk_USB_FX;
    input rst_n;
    inout i2c_sdat;
	inout i2c_sdat_io;
    output i2c_sclk;
    input	[7:0]	rx_data;
	input			rx_done;
    output [7:0] 	data_byte   ;
	output 			byte_send_en;
	
	wire [15:0] addr;
    wire ack;
    wire RW_Done;
      
    wire eeprom_rd_done; 
	wire eeprom_wr_done; 
    
    wire [127:0]eeprom_rddata;
    wire wrreg_req;
    wire rdreg_req;
    wire [7:0]wrdata;
    wire [7:0]rddata;
    
    wire [15:0]address;
    wire [127:0]cmd_data;
    wire [7:0]num_cmd;
    wire cmdvalid;
    wire [7:0] device_id;    
   
	 convert convert(
		  .clk_fs(clk_USB_FX),
		  .rst_n(rst_n),
		  .rddata(rddata),
		  .RW_Done(RW_Done),
		  .ack(ack),
		  .address(address),
		  .cmd_data(cmd_data),
		  .num_cmd(num_cmd),
		  .cmdvalid(cmdvalid),
		  .eeprom_rddata(eeprom_rddata),	
		  .wrdata(wrdata),
		  .wrreg_req(wrreg_req),
		  .rdreg_req(rdreg_req),
		  .addr(addr),
		  .eeprom_rd_done(eeprom_rd_done),
		  .eeprom_wr_done(eeprom_wr_done)
	 );

    
    i2c_control i2c_control(
        .Clk(clk_USB_FX), 
        .Rst_n(rst_n), 
        
        .wrreg_req(wrreg_req),
        .rdreg_req(rdreg_req),
        .addr(addr),
        .addr_mode(1'b1),
        .wrdata(wrdata),
        .rddata(rddata),
        .device_id(device_id),//8'b1010_0000
        .RW_Done(RW_Done),
        .ack(ack),
    `ifdef DO_SIM
        .dly_cnt_max(250-1),
    `else
        .dly_cnt_max(250000-1),
    `endif
        .i2c_sclk(i2c_sclk),
        .i2c_sdat(i2c_sdat),
		.i2c_sdat_io(i2c_sdat_io)
    );


    uart_cmd_iic uart_cmd_iic(
        .Clk(clk_USB_FX),
        .Reset_n(rst_n),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .address(address),
        .data(cmd_data),
        .num_cmd(num_cmd),
		.device_id(device_id),
        .cmdvalid(cmdvalid)
    );
    
    uart_data_tx
    #(
        .DATA_WIDTH(128),
        .MSB_FIRST(1)
    )
    uart_data_tx(
        .Clk(clk_USB_FX),
        .Rst_n(rst_n),
        .data(eeprom_rddata),
        .send_en(eeprom_rd_done),   
		.Tx_Done(),
		.data_byte(data_byte),
		.byte_send_en(byte_send_en)
    );

endmodule