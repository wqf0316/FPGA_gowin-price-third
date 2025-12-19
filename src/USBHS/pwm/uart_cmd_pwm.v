`timescale 1ns/1ns

module uart_cmd_pwm(
    sys_clk				,
    reset_n				,
	SW3  				,
    rx_data				,
    rx_done				,
	series_length		,
	series_set			,
    full_time_set       ,
    time_set		    ,
    high_time_set       ,
    pwm_select          
);
    
    input sys_clk;
    input reset_n;
	input SW3;
    input [7:0]rx_data;
    input rx_done;
	output reg [7:0]  series_length ;
    output reg [23:0] series_set	;
	output reg [31:0] full_time_set ;
	output reg [31:0] time_set		;
    output reg [31:0] high_time_set ;
    output reg [7:0]  pwm_select    ;
    reg [7:0] data_str [11:0];
	
//移位寄存
    always@(posedge sys_clk)
	if(SW3 ==0) begin
		data_str[11] 	<= #1 	0;
		data_str[10] 	<= #1 	0;
		data_str[9] 	<= #1 	0;
        data_str[8] 	<= #1 	0;
		data_str[7] 	<= #1 	0;
        data_str[6] 	<= #1 	0;
        data_str[5] 	<= #1 	0;
        data_str[4] 	<= #1 	0;
        data_str[3] 	<= #1 	0;
        data_str[2] 	<= #1 	0;
        data_str[1] 	<= #1 	0;
        data_str[0] 	<= #1 	0; 
	end
    else if(rx_done)begin
		data_str[11] 	<= #1 	rx_data;
		data_str[10] 	<= #1 	data_str[11];
		data_str[9] 	<= #1 	data_str[10];
        data_str[8] 	<= #1 	data_str[9];
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
    always@(posedge sys_clk)
        r_rx_done <= rx_done;
    
    always@(posedge sys_clk or negedge reset_n)
		if((!reset_n) | SW3 == 0) begin
			series_set	         <= 24'b1010_1010;
			full_time_set        <= 32'd100;
			time_set		     <= 32'd50;
			high_time_set        <= 32'd50;
			pwm_select           <= 8'b0000_0001;
			series_length        <= 8'd8;
			
			
    end else if(r_rx_done)begin
        if((data_str[0] == 8'h55) && (data_str[1] == 8'hA5) && (data_str[11] == 8'hF0))begin
            high_time_set[31:24] 	<= #1 	data_str[3];
            high_time_set[23:16] 	<= #1 	data_str[4];
            high_time_set[15:8] 	<= #1 	data_str[5];
            high_time_set[7:0] 		<= #1 	data_str[6];
            full_time_set[31:24] 	<= #1 	data_str[7];
            full_time_set[23:16] 	<= #1 	data_str[8];
            full_time_set[15:8] 	<= #1 	data_str[9];
            full_time_set[7:0] 		<= #1 	data_str[10];
            time_set[31:24] 		<= #1 	data_str[7];
            time_set[23:16] 		<= #1 	data_str[8];
            time_set[15:8] 			<= #1 	data_str[9];
            time_set[7:0] 			<= #1 	data_str[10];
			series_length  			<= #1	data_str[3];
			series_set[23:16]  			<= #1	data_str[4];
			series_set[15:8]  			<= #1	data_str[5];
			series_set[7:0]  			<= #1	data_str[6];
			pwm_select <= #1 data_str[2];
        end
    end    
    
endmodule
