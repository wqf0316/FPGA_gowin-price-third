`timescale 1ns/1ns

module uart_cmd_logic(
    fx2_ifclk				,
    reset_n				,
    rx_data				,
    rx_done				,
    cmd_start_stop		,
	cmd_trigger_enable  ,
	cmd_trigger_position,
	cmd_sample_depth    ,
	cmd_trigger_channel ,
	cmd_trigger_mod		,
	cmd_valid			
);
    
    input fx2_ifclk;
    input reset_n;
    input [7:0]rx_data;
    input rx_done;
	output reg  [7:0]	cmd_start_stop		 ;
    output reg  [7:0]	cmd_trigger_enable   ;
    output reg  [7:0]	cmd_trigger_position ;
    output reg  [7:0]	cmd_sample_depth     ;
    output reg  [7:0]	cmd_trigger_channel  ;
    output reg  [7:0]	cmd_trigger_mod		 ;
	output reg         cmd_valid			 ;


    reg [7:0] data_str [8:0];
	
//移位寄存
    always@(posedge fx2_ifclk)
    if(rx_done)begin
        data_str[8] 	<= #1 	rx_data;
		data_str[7] 	<= #1 	data_str[8];
        data_str[6] 	<= #1 	data_str[7];
        data_str[5] 	<= #1 	data_str[6];
        data_str[4] 	<= #1 	data_str[5];
        data_str[3] 	<= #1 	data_str[4];
        data_str[2] 	<= #1 	data_str[3];
        data_str[1] 	<= #1 	data_str[2];
        data_str[0] 	<= #1 	data_str[1];        
    end
 //打一拍，为了与后面数据赋值在同一时间   
    reg r_rx_done;
    always@(posedge fx2_ifclk)
        r_rx_done <= rx_done;
    
    always@(posedge fx2_ifclk or negedge reset_n)
		if(!reset_n) begin
			cmd_start_stop		   <= 0;
			cmd_trigger_enable     <= 0;
			cmd_trigger_position   <= 0;
			cmd_sample_depth       <= 0;
			cmd_trigger_channel    <= 0;
			cmd_trigger_mod		   <= 0;
			cmd_valid			   <= 0 ;
			
			
    end else if(r_rx_done)begin
        if((data_str[0] == 8'hAA) && (data_str[1] == 8'h55) && (data_str[8] == 8'hF0))begin
			cmd_start_stop		   <= data_str[2] ;
			cmd_trigger_enable     <= data_str[3] ;
			cmd_trigger_position   <= data_str[4] ;
			cmd_sample_depth       <= data_str[5] ;
			cmd_trigger_channel    <= data_str[6] ;
			cmd_trigger_mod		   <= data_str[7] ;
			cmd_valid			   <= 1 ;

        end
    end else
			cmd_valid <= 0;

    
endmodule
