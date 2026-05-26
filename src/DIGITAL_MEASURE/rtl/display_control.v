module display_control(
	input  [27:0] freq_out,    // 输出频率（28位）（Hz）
    input  [27:0] duty_out,    // 输出占空比（28位）（万分之一）
    input  [27:0] high_time_out,  // 输出高电平时间(us)（28位）
    input  [27:0] low_time_out,    // 输出低电平时间(us)（28位） 
	input clk_sys,
	input rst_n,
	input key_flag,
	output		[27:0]  display_value,
	output		[7:0]	point
);
reg 	[3:0]	current_state;
reg		[27:0]  display_value;
reg 	[7:0]	point;
parameter 	STATE_FREQ = 4'b0001;
parameter 	STATE_HIGH_TIME = 4'b0010;
parameter 	STATE_LOW_TIME = 4'b0100;
parameter 	STATE_DUTY = 4'b1000;

always@(posedge clk_sys or negedge rst_n)	begin
	if(rst_n == 0)
		current_state <= STATE_FREQ;
	else	if(key_flag ==1)	
		case(current_state)
			STATE_FREQ:					current_state <= STATE_HIGH_TIME;
			STATE_HIGH_TIME:			current_state <= STATE_LOW_TIME;
			STATE_LOW_TIME:				current_state <= STATE_DUTY;
			STATE_DUTY:					current_state <= STATE_FREQ;
			default:current_state <= current_state;
		endcase
end

always@(posedge clk_sys or negedge rst_n)	begin
	if(rst_n == 0)
		display_value <= 0;
	else
		case(current_state)
			STATE_FREQ:			begin				display_value <= freq_out;
											point <= 8'b0000_1000;
								end
			STATE_HIGH_TIME:	begin			display_value <= high_time_out;
											point <= 8'b0000_0000;
								end
			STATE_LOW_TIME:		begin		display_value <= low_time_out;
											point <= 8'b0000_0000;
								end
			STATE_DUTY:			begin		display_value <= duty_out;
											point <= 8'b0000_0010;
								end
			default:			begin		display_value <= freq_out;
											point <= 8'b0000_0000;
								end
		endcase
end

endmodule