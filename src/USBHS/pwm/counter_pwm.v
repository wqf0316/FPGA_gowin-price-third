`timescale 1ns/1ns

module counter_pwm(
    sys_clk				,
    reset_n				,
	SW3			,
	series_set			,
	series_length		,
    full_time_set       ,
    time_set		    ,
    high_time_set       ,
    pwm_select          ,
	pwm_out				,
	user_ctrl_series_out
);

	input	sys_clk;
	input	reset_n;
	input	SW3;
    input [23:0]  series_set	;
	input [7:0]	 series_length;
	input [31:0] full_time_set ;
	input [31:0] time_set		;
    input [31:0] high_time_set ;
    input [7:0]  pwm_select    ;
	output	wire	[3:0]	pwm_out;
	output	wire	[3:0]	user_ctrl_series_out;
	
	

	reg		 [23:0]  series_set_reg			;
	reg		 [7:0]	 series_length_reg		;
	reg		 [31:0]  full_time_set_reg 		;
	reg		 [31:0]  time_set_reg			;
    reg		 [31:0]  high_time_set_reg 		;
    reg		 [7:0]   pwm_select_reg    		;
	reg				refreash_flag;
	reg		[3:0]	pwm_out_reg;
	reg 	[3:0]	user_ctrl_series_out_reg;
	reg		[31:0]	high_time_reg_channel_1_reg		;	//PWM高电平时间寄存
	reg		[31:0]	high_time_reg_channel_2_reg		;
	reg		[31:0]	high_time_reg_channel_3_reg		;
	reg		[31:0]	high_time_reg_channel_4_reg		;
			
	reg		[31:0]	full_time_reg_channel_1_reg		;	//PWM一个周期时间寄存
	reg		[31:0]	full_time_reg_channel_2_reg		;
	reg		[31:0]	full_time_reg_channel_3_reg		;
	reg		[31:0]	full_time_reg_channel_4_reg		;	

	reg		[31:0]	time_reg_channel_1_reg			;			//用户自定义序列一个信号时间寄存
	reg		[31:0]	time_reg_channel_2_reg			;
	reg		[31:0]	time_reg_channel_3_reg			;
	reg		[31:0]	time_reg_channel_4_reg			;
	
	reg		[23:0]	series_set_reg_channel_1	;	//用户自定义序列序列信号寄存
	reg		[23:0]	series_set_reg_channel_2	;
	reg		[23:0]	series_set_reg_channel_3	;
	reg		[23:0]	series_set_reg_channel_4	;

	reg		[7:0]  series_length_reg_channel_1;
	reg		[7:0]  series_length_reg_channel_2;
	reg		[7:0]  series_length_reg_channel_3;
	reg		[7:0]  series_length_reg_channel_4;

    reg [31:0]	counter_high_time_1;
    reg	[31:0]	counter_high_time_2;
    reg [31:0]	counter_high_time_3;
    reg	[31:0]	counter_high_time_4;

    reg [31:0]	counter_full_time_1;
    reg	[31:0]	counter_full_time_2;
    reg [31:0]	counter_full_time_3;
    reg	[31:0]	counter_full_time_4;

    reg [31:0]	counter_time_1;
    reg	[31:0]	counter_time_2;
    reg [31:0]	counter_time_3;
    reg	[31:0]	counter_time_4;	
	
	reg [4:0]	counter_state_1;
	reg [4:0]	counter_state_2;
	reg [4:0]	counter_state_3;
	reg [4:0]	counter_state_4;
	
	reg			high_time_flag_1;
	reg			high_time_flag_2;
	reg			high_time_flag_3;
	reg			high_time_flag_4;
	reg			low_time_flag_1;
	reg			low_time_flag_2;
	reg			low_time_flag_3;
	reg			low_time_flag_4;
	reg			low_time_flag_1;
	reg			time_flag_1;
	reg			time_flag_2;
	reg			time_flag_3;
	reg			time_flag_4;
	
	assign		pwm_out = pwm_out_reg;
	assign		user_ctrl_series_out = user_ctrl_series_out_reg;
	
	always@(posedge sys_clk or negedge reset_n)
		if(!reset_n) begin
			pwm_select_reg 		<= 0;
			series_set_reg		<= 0;
			series_length_reg 	<= 0;
			full_time_set_reg 	<= 0;
			time_set_reg		<= 0;
			high_time_set_reg 	<= 0;
		end
			
		else begin
			pwm_select_reg <= pwm_select;
			series_set_reg		<= series_set		;
			series_length_reg 	<= series_length 	;
			full_time_set_reg 	<= full_time_set	;
			time_set_reg		<= time_set		;
			high_time_set_reg 	<= high_time_set	;
			end
	always@(posedge sys_clk or negedge reset_n)
		if(!reset_n)
			refreash_flag <= 0;
		else  if((pwm_select !=pwm_select_reg) | (series_set_reg !=series_set) | (series_length_reg !=series_length)
		 | (full_time_set_reg !=full_time_set)
		 | (time_set_reg !=time_set) | (high_time_set_reg !=high_time_set))
			refreash_flag <= 1;
		else	
			refreash_flag <= 0;
	
	always@(posedge sys_clk or negedge reset_n)	begin
		if(!reset_n)	begin
			high_time_reg_channel_1_reg		<=	32'd0;
			high_time_reg_channel_2_reg		<=  32'd0;
			high_time_reg_channel_3_reg		<=  32'd0;
			high_time_reg_channel_4_reg		<=  32'd0;
											
			full_time_reg_channel_1_reg		<=  32'd0;
			full_time_reg_channel_2_reg		<=  32'd0;
			full_time_reg_channel_3_reg		<=  32'd0;
			full_time_reg_channel_4_reg		<=  32'd0;
											
			time_reg_channel_1_reg			<=  32'd0;
			time_reg_channel_2_reg			<=  32'd0;
			time_reg_channel_3_reg			<=  32'd0;
			time_reg_channel_4_reg			<=  32'd0;
											
			series_set_reg_channel_1	<=  24'd0;
			series_set_reg_channel_2	<=  24'd0;
			series_set_reg_channel_3	<=  24'd0;
	        series_set_reg_channel_4	<=  24'd0;
			
			series_length_reg_channel_1  <= 8'b0;
			series_length_reg_channel_2  <= 8'b0;
			series_length_reg_channel_3  <= 8'b0;
			series_length_reg_channel_4  <= 8'b0;
			
			end
		else    if(SW3  == 0)		begin
			high_time_reg_channel_1_reg		<=	32'd50_000;
			high_time_reg_channel_2_reg		<=  32'd50_000;
			high_time_reg_channel_3_reg		<=  32'd50_000;
			high_time_reg_channel_4_reg		<=  32'd50_000;
											
			full_time_reg_channel_1_reg		<=  32'd100_000;
			full_time_reg_channel_2_reg		<=  32'd100_000;
			full_time_reg_channel_3_reg		<=  32'd100_000;
			full_time_reg_channel_4_reg		<=  32'd100_000;
											
			time_reg_channel_1_reg			<=  32'd50_000;
			time_reg_channel_2_reg			<=  32'd50_000;
			time_reg_channel_3_reg			<=  32'd50_000;
			time_reg_channel_4_reg			<=  32'd50_000;
											
			series_set_reg_channel_1	<=  24'b1010_1010;
			series_set_reg_channel_2	<=  24'b1010_1010;
			series_set_reg_channel_3	<=  24'b1010_1010;
	        series_set_reg_channel_4	<=  24'b1010_1010;
			
			series_length_reg_channel_1  <= 8'd8;
			series_length_reg_channel_2  <= 8'd8;
			series_length_reg_channel_3  <= 8'd8;
			series_length_reg_channel_4  <= 8'd8;
			
			end
		else	if(pwm_select == 8'b0000_0001)	begin 
			high_time_reg_channel_1_reg		<=	high_time_set;
			high_time_reg_channel_2_reg		<=  high_time_reg_channel_2_reg;
			high_time_reg_channel_3_reg		<=  high_time_reg_channel_3_reg;
			high_time_reg_channel_4_reg		<=  high_time_reg_channel_4_reg;
											
			full_time_reg_channel_1_reg		<=  full_time_set;
			full_time_reg_channel_2_reg		<=  full_time_reg_channel_2_reg;
			full_time_reg_channel_3_reg		<=  full_time_reg_channel_3_reg;
			full_time_reg_channel_4_reg		<=  full_time_reg_channel_4_reg;
											
			time_reg_channel_1_reg			<=  time_reg_channel_1_reg;
			time_reg_channel_2_reg			<=  time_reg_channel_2_reg;
			time_reg_channel_3_reg			<=  time_reg_channel_3_reg;
			time_reg_channel_4_reg			<=  time_reg_channel_4_reg;
											
			series_set_reg_channel_1	<=  series_set_reg_channel_1;
			series_set_reg_channel_2	<=  series_set_reg_channel_2;
			series_set_reg_channel_3	<=  series_set_reg_channel_3;
	        series_set_reg_channel_4	<=  series_set_reg_channel_4;
			
			series_length_reg_channel_1  <= series_length_reg_channel_1;
			series_length_reg_channel_2  <= series_length_reg_channel_2;
			series_length_reg_channel_3  <= series_length_reg_channel_3;
			series_length_reg_channel_4  <= series_length_reg_channel_4;
			end
		else	if(pwm_select == 8'b0000_0010)	begin 
			high_time_reg_channel_1_reg		<=	high_time_reg_channel_1_reg;
			high_time_reg_channel_2_reg		<=  high_time_set;
			high_time_reg_channel_3_reg		<=  high_time_reg_channel_3_reg;
			high_time_reg_channel_4_reg		<=  high_time_reg_channel_4_reg;
											
			full_time_reg_channel_1_reg		<=  full_time_reg_channel_1_reg;
			full_time_reg_channel_2_reg		<=  full_time_set;
			full_time_reg_channel_3_reg		<=  full_time_reg_channel_3_reg;
			full_time_reg_channel_4_reg		<=  full_time_reg_channel_4_reg;
											
			time_reg_channel_1_reg			<=  time_reg_channel_1_reg;
			time_reg_channel_2_reg			<=  time_reg_channel_2_reg;
			time_reg_channel_3_reg			<=  time_reg_channel_3_reg;
			time_reg_channel_4_reg			<=  time_reg_channel_4_reg;
											
			series_set_reg_channel_1	<=  series_set_reg_channel_1;
			series_set_reg_channel_2	<=  series_set_reg_channel_2;
			series_set_reg_channel_3	<=  series_set_reg_channel_3;
	        series_set_reg_channel_4	<=  series_set_reg_channel_4;
			
			series_length_reg_channel_1  <= series_length_reg_channel_1;
			series_length_reg_channel_2  <= series_length_reg_channel_2;
			series_length_reg_channel_3  <= series_length_reg_channel_3;
			series_length_reg_channel_4  <= series_length_reg_channel_4;
			end
		else	if(pwm_select == 8'b0000_0100)	begin 
			high_time_reg_channel_1_reg		<=	high_time_reg_channel_1_reg;
			high_time_reg_channel_2_reg		<=  high_time_reg_channel_2_reg;
			high_time_reg_channel_3_reg		<=  high_time_set;
			high_time_reg_channel_4_reg		<=  high_time_reg_channel_4_reg;
											
			full_time_reg_channel_1_reg		<=  full_time_reg_channel_1_reg;
			full_time_reg_channel_2_reg		<=  full_time_reg_channel_2_reg;
			full_time_reg_channel_3_reg		<=  full_time_set;
			full_time_reg_channel_4_reg		<=  full_time_reg_channel_4_reg;
											
			time_reg_channel_1_reg			<=  time_reg_channel_1_reg;
			time_reg_channel_2_reg			<=  time_reg_channel_2_reg;
			time_reg_channel_3_reg			<=  time_reg_channel_3_reg;
			time_reg_channel_4_reg			<=  time_reg_channel_4_reg;
											
			series_set_reg_channel_1	<=  series_set_reg_channel_1;
			series_set_reg_channel_2	<=  series_set_reg_channel_2;
			series_set_reg_channel_3	<=  series_set_reg_channel_3;
	        series_set_reg_channel_4	<=  series_set_reg_channel_4;
			
			series_length_reg_channel_1  <= series_length_reg_channel_1;
			series_length_reg_channel_2  <= series_length_reg_channel_2;
			series_length_reg_channel_3  <= series_length_reg_channel_3;
			series_length_reg_channel_4  <= series_length_reg_channel_4;
			end
		else	if(pwm_select == 8'b0000_1000)	begin 
			high_time_reg_channel_1_reg		<=	high_time_reg_channel_1_reg;
			high_time_reg_channel_2_reg		<=  high_time_reg_channel_2_reg;
			high_time_reg_channel_3_reg		<=  high_time_reg_channel_3_reg;
			high_time_reg_channel_4_reg		<=  high_time_set;
											
			full_time_reg_channel_1_reg		<=  full_time_reg_channel_1_reg;
			full_time_reg_channel_2_reg		<=  full_time_reg_channel_2_reg;
			full_time_reg_channel_3_reg		<=  full_time_reg_channel_3_reg;
			full_time_reg_channel_4_reg		<=  full_time_set;
											
			time_reg_channel_1_reg			<=  time_reg_channel_1_reg;
			time_reg_channel_2_reg			<=  time_reg_channel_2_reg;
			time_reg_channel_3_reg			<=  time_reg_channel_3_reg;
			time_reg_channel_4_reg			<=  time_reg_channel_4_reg;
											
			series_set_reg_channel_1	<=  series_set_reg_channel_1;
			series_set_reg_channel_2	<=  series_set_reg_channel_2;
			series_set_reg_channel_3	<=  series_set_reg_channel_3;
	        series_set_reg_channel_4	<=  series_set_reg_channel_4;
			
			series_length_reg_channel_1  <= series_length_reg_channel_1;
			series_length_reg_channel_2  <= series_length_reg_channel_2;
			series_length_reg_channel_3  <= series_length_reg_channel_3;
			series_length_reg_channel_4  <= series_length_reg_channel_4;
			end
		else	if(pwm_select == 8'b0001_0000)	begin 
			high_time_reg_channel_1_reg		<=	high_time_reg_channel_1_reg;
			high_time_reg_channel_2_reg		<=  high_time_reg_channel_2_reg;
			high_time_reg_channel_3_reg		<=  high_time_reg_channel_3_reg;
			high_time_reg_channel_4_reg		<=  high_time_reg_channel_4_reg;
											
			full_time_reg_channel_1_reg		<=  full_time_reg_channel_1_reg;
			full_time_reg_channel_2_reg		<=  full_time_reg_channel_2_reg;
			full_time_reg_channel_3_reg		<=  full_time_reg_channel_3_reg;
			full_time_reg_channel_4_reg		<=  full_time_reg_channel_4_reg;
											
			time_reg_channel_1_reg			<=  time_set;
			time_reg_channel_2_reg			<=  time_reg_channel_2_reg;
			time_reg_channel_3_reg			<=  time_reg_channel_3_reg;
			time_reg_channel_4_reg			<=  time_reg_channel_4_reg;
											
			series_set_reg_channel_1	<=  series_set;
			series_set_reg_channel_2	<=  series_set_reg_channel_2;
			series_set_reg_channel_3	<=  series_set_reg_channel_3;
	        series_set_reg_channel_4	<=  series_set_reg_channel_4;
			
			series_length_reg_channel_1  <= series_length;
			series_length_reg_channel_2  <= series_length_reg_channel_2;
			series_length_reg_channel_3  <= series_length_reg_channel_3;
			series_length_reg_channel_4  <= series_length_reg_channel_4;
			end
		else	if(pwm_select == 8'b0010_0000)	begin 
			high_time_reg_channel_1_reg		<=	high_time_reg_channel_1_reg;
			high_time_reg_channel_2_reg		<=  high_time_reg_channel_2_reg;
			high_time_reg_channel_3_reg		<=  high_time_reg_channel_3_reg;
			high_time_reg_channel_4_reg		<=  high_time_reg_channel_4_reg;
											
			full_time_reg_channel_1_reg		<=  full_time_reg_channel_1_reg;
			full_time_reg_channel_2_reg		<=  full_time_reg_channel_2_reg;
			full_time_reg_channel_3_reg		<=  full_time_reg_channel_3_reg;
			full_time_reg_channel_4_reg		<=  full_time_reg_channel_4_reg;
											
			time_reg_channel_1_reg			<=  time_reg_channel_1_reg;
			time_reg_channel_2_reg			<=  time_set;
			time_reg_channel_3_reg			<=  time_reg_channel_3_reg;
			time_reg_channel_4_reg			<=  time_reg_channel_4_reg;
											
			series_set_reg_channel_1	<=  series_set_reg_channel_1;
			series_set_reg_channel_2	<=  series_set;
			series_set_reg_channel_3	<=  series_set_reg_channel_3;
	        series_set_reg_channel_4	<=  series_set_reg_channel_4;
			
			series_length_reg_channel_1  <= series_length_reg_channel_1;
			series_length_reg_channel_2  <= series_length;
			series_length_reg_channel_3  <= series_length_reg_channel_3;
			series_length_reg_channel_4  <= series_length_reg_channel_4;
			end
		else	if(pwm_select == 8'b0100_0000)	begin 
			high_time_reg_channel_1_reg		<=	high_time_reg_channel_1_reg;
			high_time_reg_channel_2_reg		<=  high_time_reg_channel_2_reg;
			high_time_reg_channel_3_reg		<=  high_time_reg_channel_3_reg;
			high_time_reg_channel_4_reg		<=  high_time_reg_channel_4_reg;
											
			full_time_reg_channel_1_reg		<=  full_time_reg_channel_1_reg;
			full_time_reg_channel_2_reg		<=  full_time_reg_channel_2_reg;
			full_time_reg_channel_3_reg		<=  full_time_reg_channel_3_reg;
			full_time_reg_channel_4_reg		<=  full_time_reg_channel_4_reg;
											
			time_reg_channel_1_reg			<=  time_reg_channel_1_reg;
			time_reg_channel_2_reg			<=  time_reg_channel_2_reg;
			time_reg_channel_3_reg			<=  time_set;
			time_reg_channel_4_reg			<=  time_reg_channel_4_reg;
											
			series_set_reg_channel_1	<=  series_set_reg_channel_1;
			series_set_reg_channel_2	<=  series_set_reg_channel_2;
			series_set_reg_channel_3	<=  series_set;
	        series_set_reg_channel_4	<=  series_set_reg_channel_4;
			
			series_length_reg_channel_1  <= series_length_reg_channel_1;
			series_length_reg_channel_2  <= series_length_reg_channel_2;
			series_length_reg_channel_3  <= series_length;
			series_length_reg_channel_4  <= series_length_reg_channel_4;
			end
		else	if(pwm_select == 8'b1000_0000)	begin 
			high_time_reg_channel_1_reg		<=	high_time_reg_channel_1_reg;
			high_time_reg_channel_2_reg		<=  high_time_reg_channel_2_reg;
			high_time_reg_channel_3_reg		<=  high_time_reg_channel_3_reg;
			high_time_reg_channel_4_reg		<=  high_time_reg_channel_4_reg;
											
			full_time_reg_channel_1_reg		<=  full_time_reg_channel_1_reg;
			full_time_reg_channel_2_reg		<=  full_time_reg_channel_2_reg;
			full_time_reg_channel_3_reg		<=  full_time_reg_channel_3_reg;
			full_time_reg_channel_4_reg		<=  full_time_reg_channel_4_reg;
											
			time_reg_channel_1_reg			<=  time_reg_channel_1_reg;
			time_reg_channel_2_reg			<=  time_reg_channel_2_reg;
			time_reg_channel_3_reg			<=  time_reg_channel_3_reg;
			time_reg_channel_4_reg			<=  time_set;
											
			series_set_reg_channel_1	<=  series_set_reg_channel_1;
			series_set_reg_channel_2	<=  series_set_reg_channel_2;
			series_set_reg_channel_3	<=  series_set_reg_channel_3;
	        series_set_reg_channel_4	<=  series_set;
			
			series_length_reg_channel_1  <= series_length_reg_channel_1;
			series_length_reg_channel_2  <= series_length_reg_channel_2;
			series_length_reg_channel_3  <= series_length_reg_channel_3;
			series_length_reg_channel_4  <= series_length;
			end
		else	begin
			high_time_reg_channel_1_reg		<=	high_time_reg_channel_1_reg;
			high_time_reg_channel_2_reg		<=  high_time_reg_channel_2_reg;
			high_time_reg_channel_3_reg		<=  high_time_reg_channel_3_reg;
			high_time_reg_channel_4_reg		<=  high_time_reg_channel_4_reg;
											
			full_time_reg_channel_1_reg		<=  full_time_reg_channel_1_reg;
			full_time_reg_channel_2_reg		<=  full_time_reg_channel_2_reg;
			full_time_reg_channel_3_reg		<=  full_time_reg_channel_3_reg;
			full_time_reg_channel_4_reg		<=  full_time_reg_channel_4_reg;
											
			time_reg_channel_1_reg			<=  time_reg_channel_1_reg;
			time_reg_channel_2_reg			<=  time_reg_channel_2_reg;
			time_reg_channel_3_reg			<=  time_reg_channel_3_reg;
			time_reg_channel_4_reg			<=  time_reg_channel_4_reg;
											
			series_set_reg_channel_1	<=  series_set_reg_channel_1;
			series_set_reg_channel_2	<=  series_set_reg_channel_2;
			series_set_reg_channel_3	<=  series_set_reg_channel_3;
	        series_set_reg_channel_4	<=  series_set_reg_channel_4;
			
			series_length_reg_channel_1  <= series_length_reg_channel_1;
			series_length_reg_channel_2  <= series_length_reg_channel_2;
			series_length_reg_channel_3  <= series_length_reg_channel_3;
			series_length_reg_channel_4  <= series_length_reg_channel_4;
			end
	end	

//以下是PWM输出1的控制逻辑
    always@(posedge sys_clk or negedge reset_n)
		if(!reset_n)
			counter_high_time_1 <=  0;
		else if(refreash_flag == 1)
			counter_high_time_1 <=  0;
		else if(high_time_flag_1 == 1)
			counter_high_time_1 <=  0;
		else if(counter_high_time_1 == high_time_reg_channel_1_reg)
			counter_high_time_1 <=  counter_high_time_1;
		else
			counter_high_time_1 <=  counter_high_time_1 + 1'b1;
    
    always@(posedge sys_clk or negedge reset_n)
		if(!reset_n) 
			low_time_flag_1 <=  0; 
		else if(counter_high_time_1 == high_time_reg_channel_1_reg - 2)
			low_time_flag_1 <=  1;
		else	
			low_time_flag_1 <=   0;
	
   always@(posedge sys_clk or negedge reset_n)
		if(!reset_n)
			counter_full_time_1 <=  0;
		else if(refreash_flag == 1)
			counter_full_time_1 <=  0;
		else if(counter_full_time_1 == full_time_reg_channel_1_reg -1)
			counter_full_time_1 <=  0;
		else
			counter_full_time_1 <=  counter_full_time_1 + 1'b1;

    always@(posedge sys_clk or negedge reset_n)
		if(!reset_n) 
			high_time_flag_1 <=  0; 
		else if(counter_full_time_1 == full_time_reg_channel_1_reg - 2)
			high_time_flag_1 <=  1;
		else	
			high_time_flag_1 <=   0;
	always@(posedge sys_clk or negedge reset_n)
		if(!reset_n) 
			pwm_out_reg[0] <= 0;
		else if(high_time_flag_1 == 1)
			pwm_out_reg[0]	<= 1;
		else if(low_time_flag_1 == 1)
			pwm_out_reg[0]	<= 0;
		else
			pwm_out_reg[0]  <= pwm_out_reg[0];
			
//以下是PWM输出2的控制逻辑
    always@(posedge sys_clk or negedge reset_n)
		if(!reset_n)
			counter_high_time_2 <=  0;
		else if(refreash_flag == 1)
			counter_high_time_2 <=  0;
		else if(high_time_flag_2 == 1)
			counter_high_time_2 <=  0;
		else if(counter_high_time_2 == high_time_reg_channel_2_reg )
			counter_high_time_2 <=  counter_high_time_2;
		else
			counter_high_time_2 <=  counter_high_time_2 + 1'b1;
    
    always@(posedge sys_clk or negedge reset_n)
		if(!reset_n) 
			low_time_flag_2 <=  0; 
		else if(counter_high_time_2 == high_time_reg_channel_2_reg - 2)
			low_time_flag_2 <=  1;
		else	
			low_time_flag_2 <=   0;
	
   always@(posedge sys_clk or negedge reset_n)
		if(!reset_n)
			counter_full_time_2 <=  0;
		else if(refreash_flag == 1)
			counter_full_time_2 <=  0;
		else if(counter_full_time_2 == full_time_reg_channel_2_reg - 1 )
			counter_full_time_2 <=  0;
		else
			counter_full_time_2 <=  counter_full_time_2 + 1'b1;

    always@(posedge sys_clk or negedge reset_n)
		if(!reset_n) 
			high_time_flag_2 <=  0; 
		else if(counter_full_time_2 == full_time_reg_channel_2_reg - 2)
			high_time_flag_2 <=  1;
		else	
			high_time_flag_2 <=   0;
	always@(posedge sys_clk or negedge reset_n)
		if(!reset_n) 
			pwm_out_reg[1] <= 0;
		else if(high_time_flag_2 == 1)
			pwm_out_reg[1]	<= 1;
		else if(low_time_flag_2 == 1)
			pwm_out_reg[1]	<= 0;
		else
			pwm_out_reg[1]  <= pwm_out_reg[1];
			
//以下是PWM输出3的控制逻辑
    always@(posedge sys_clk or negedge reset_n)
		if(!reset_n)
			counter_high_time_3 <=  0;
		else if(refreash_flag == 1)
			counter_high_time_3 <=  0;
		else if(high_time_flag_3 == 1)
			counter_high_time_3 <=  0;
		else if(counter_high_time_3 == high_time_reg_channel_3_reg )
			counter_high_time_3 <=  counter_high_time_3;
		else
			counter_high_time_3 <=  counter_high_time_3 + 1'b1;
    
    always@(posedge sys_clk or negedge reset_n)
		if(!reset_n) 
			low_time_flag_3 <=  0; 
		else if(counter_high_time_3 == high_time_reg_channel_3_reg - 2)
			low_time_flag_3 <=  1;
		else	
			low_time_flag_3 <=   0;
	
   always@(posedge sys_clk or negedge reset_n)
		if(!reset_n)
			counter_full_time_3 <=  0;
		else if(refreash_flag == 1)
			counter_full_time_3 <=  0;
		else if(counter_full_time_3 == full_time_reg_channel_3_reg - 1)
			counter_full_time_3 <=  0;
		else
			counter_full_time_3 <=  counter_full_time_3 + 1'b1;

    always@(posedge sys_clk or negedge reset_n)
		if(!reset_n) 
			high_time_flag_3 <=  0; 
		else if(counter_full_time_3 == full_time_reg_channel_3_reg - 2)
			high_time_flag_3 <=  1;
		else	
			high_time_flag_3 <=   0;
	always@(posedge sys_clk or negedge reset_n)
		if(!reset_n) 
			pwm_out_reg[2] <= 0;
		else if(high_time_flag_3 == 1)
			pwm_out_reg[2]	<= 1;
		else if(low_time_flag_3 == 1)
			pwm_out_reg[2]	<= 0;
		else
			pwm_out_reg[2]  <= pwm_out_reg[2];			
			

//以下是PWM输出4的控制逻辑
    always@(posedge sys_clk or negedge reset_n)
		if(!reset_n)
			counter_high_time_4 <=  0;
		else if(refreash_flag == 1)
			counter_high_time_4 <=  0;
		else if(high_time_flag_4 == 1)
			counter_high_time_4 <=  0;
		else if(counter_high_time_4 == high_time_reg_channel_4_reg)
			counter_high_time_4 <=  counter_high_time_4;
		else
			counter_high_time_4 <=  counter_high_time_4 + 1'b1;
    
    always@(posedge sys_clk or negedge reset_n)
		if(!reset_n) 
			low_time_flag_4 <=  0; 
		else if(counter_high_time_4 == high_time_reg_channel_4_reg - 2)
			low_time_flag_4 <=  1;
		else	
			low_time_flag_4 <=   0;
	
   always@(posedge sys_clk or negedge reset_n)
		if(!reset_n)
			counter_full_time_4 <=  0;
		else if(refreash_flag == 1)
			counter_full_time_4 <=  0;
		else if(counter_full_time_4 == full_time_reg_channel_4_reg - 1 )
			counter_full_time_4 <=  0;
		else
			counter_full_time_4 <=  counter_full_time_4 + 1'b1;

    always@(posedge sys_clk or negedge reset_n)
		if(!reset_n) 
			high_time_flag_4 <=  0; 
		else if(counter_full_time_4 == full_time_reg_channel_4_reg - 2)
			high_time_flag_4 <=  1;
		else	
			high_time_flag_4 <=   0;
	always@(posedge sys_clk or negedge reset_n)
		if(!reset_n) 
			pwm_out_reg[3] <= 0;
		else if(high_time_flag_4 == 1)
			pwm_out_reg[3]	<= 1;
		else if(low_time_flag_4 == 1)
			pwm_out_reg[3]	<= 0;
		else
			pwm_out_reg[3]  <= pwm_out_reg[3];
	
	
	
	
//用户自定义序列1输出	
	always@(posedge sys_clk or negedge reset_n)
		if(!reset_n)
			counter_time_1 <=  0;
		else if(refreash_flag == 1)
			counter_time_1 <=  0;
		else if(counter_time_1 >= time_reg_channel_1_reg - 1)
			counter_time_1 <=  0;
		else
			counter_time_1 <=  counter_time_1 + 1'b1;
		
    always@(posedge sys_clk or negedge reset_n)
		if((!reset_n) | refreash_flag) 
			counter_state_1 <=  series_length_reg_channel_1 - 1;
		else if(counter_time_1 == time_reg_channel_1_reg - 2)
				if(counter_state_1 == 0)
					counter_state_1 <=  (series_length_reg_channel_1 - 1);
				else
					counter_state_1 <=  counter_state_1 - 1'b1;
			
	always@(posedge sys_clk or negedge reset_n)
		if(!reset_n)
			user_ctrl_series_out_reg[0] <=  0;
		else case(counter_state_1)
			0 :user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[0 ];
			1 :user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[1 ];
			2 :user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[2 ];
			3 :user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[3 ];
			4 :user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[4 ];
			5 :user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[5 ];
			6 :user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[6 ];
			7 :user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[7 ];
			8 :user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[8 ];
			9 :user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[9 ];
			10:user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[10];
			11:user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[11];
			12:user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[12];
			13:user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[13];
			14:user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[14];
			15:user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[15];
			16:user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[16];
			17:user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[17];
			18:user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[18];
			19:user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[19];
			20:user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[20];
			21:user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[21];
			22:user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[22];
			23:user_ctrl_series_out_reg[0] <=  series_set_reg_channel_1[23];
			default:user_ctrl_series_out_reg[0] <=  user_ctrl_series_out_reg[0];
		endcase
    
//用户自定义序列2输出
	always@(posedge sys_clk or negedge reset_n)
		if(!reset_n)
			counter_time_2 <=  0;
		else if(refreash_flag == 1)
			counter_time_2 <=  0;
		else if(counter_time_2 >= time_reg_channel_2_reg - 1)
			counter_time_2 <=  0;
		else
			counter_time_2 <=  counter_time_2 + 1'b1;
		
    always@(posedge sys_clk or negedge reset_n)
		if((!reset_n) | refreash_flag) 
			counter_state_2 <=  series_length_reg_channel_2 - 1;
		else if(counter_time_2 == time_reg_channel_2_reg - 2)
				if(counter_state_2 == 0)
					counter_state_2 <=  (series_length_reg_channel_2 - 1);
				else
					counter_state_2 <=  counter_state_2 - 1'b1;



	always@(posedge sys_clk or negedge reset_n)
		if(!reset_n)
			user_ctrl_series_out_reg[1] <=  0;
		else case(counter_state_2)
			0 :user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[0 ];
			1 :user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[1 ];
			2 :user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[2 ];
			3 :user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[3 ];
			4 :user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[4 ];
			5 :user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[5 ];
			6 :user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[6 ];
			7 :user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[7 ];
			8 :user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[8 ];
			9 :user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[9 ];
			10:user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[10];
			11:user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[11];
			12:user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[12];
			13:user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[13];
			14:user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[14];
			15:user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[15];
			16:user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[16];
			17:user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[17];
			18:user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[18];
			19:user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[19];
			20:user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[20];
			21:user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[21];
			22:user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[22];
			23:user_ctrl_series_out_reg[1] <=  series_set_reg_channel_2[23];
			default:user_ctrl_series_out_reg[1] <=  user_ctrl_series_out_reg[1];
		endcase
    
		
//用户自定义序列3输出
	always@(posedge sys_clk or negedge reset_n)
		if(!reset_n)
			counter_time_3 <=  0;
		else if(refreash_flag == 1)
			counter_time_3 <=  0;
		else if(counter_time_3 >= time_reg_channel_3_reg - 1)
			counter_time_3 <=  0;
		else
			counter_time_3 <=  counter_time_3 + 1'b1;
    always@(posedge sys_clk or negedge reset_n)
		if((!reset_n) | refreash_flag)
			counter_state_3 <=  series_length_reg_channel_3 - 1;
		else if(counter_time_3 == time_reg_channel_3_reg - 2)
				if(counter_state_3 == 0)
					counter_state_3 <=  (series_length_reg_channel_3 - 1);
				else
					counter_state_3 <=  counter_state_3 - 1'b1;



	always@(posedge sys_clk or negedge reset_n)
		if(!reset_n)
			user_ctrl_series_out_reg[2] <=  0;
		else case(counter_state_3)
			0 :user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[0 ];
			1 :user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[1 ];
			2 :user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[2 ];
			3 :user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[3 ];
			4 :user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[4 ];
			5 :user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[5 ];
			6 :user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[6 ];
			7 :user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[7 ];
			8 :user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[8 ];
			9 :user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[9 ];
			10:user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[10];
			11:user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[11];
			12:user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[12];
			13:user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[13];
			14:user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[14];
			15:user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[15];
			16:user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[16];
			17:user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[17];
			18:user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[18];
			19:user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[19];
			20:user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[20];
			21:user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[21];
			22:user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[22];
			23:user_ctrl_series_out_reg[2] <=  series_set_reg_channel_3[23];
			default:user_ctrl_series_out_reg[2] <=  user_ctrl_series_out_reg[2];
		endcase
    
	
//用户自定义序列4输出
	always@(posedge sys_clk or negedge reset_n)
		if(!reset_n)
			counter_time_4 <=  0;
		else if(refreash_flag == 1)
			counter_time_4 <=  0;
		else if(counter_time_4 >= time_reg_channel_4_reg - 1)
			counter_time_4 <=  0;
		else
			counter_time_4 <=  counter_time_4 + 1'b1;
		
    always@(posedge sys_clk or negedge reset_n)
		if((!reset_n) | refreash_flag)
			counter_state_4 <=  series_length_reg_channel_4 - 1;
		else if(counter_time_4 == time_reg_channel_4_reg - 2)
				if(counter_state_4 == 0)
					counter_state_4 <=  (series_length_reg_channel_4 - 1);
				else
					counter_state_4 <=  counter_state_4 - 1'b1;
					
					
					
	always@(posedge sys_clk or negedge reset_n)
		if(!reset_n)
			user_ctrl_series_out_reg[3] <=  0;
		else case(counter_state_4)
			0 :user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[0 ];
			1 :user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[1 ];
			2 :user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[2 ];
			3 :user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[3 ];
			4 :user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[4 ];
			5 :user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[5 ];
			6 :user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[6 ];
			7 :user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[7 ];
			8 :user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[8 ];
			9 :user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[9 ];
			10:user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[10];
			11:user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[11];
			12:user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[12];
			13:user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[13];
			14:user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[14];
			15:user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[15];
			16:user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[16];
			17:user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[17];
			18:user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[18];
			19:user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[19];
			20:user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[20];
			21:user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[21];
			22:user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[22];
			23:user_ctrl_series_out_reg[3] <=  series_set_reg_channel_4[23];
			default:user_ctrl_series_out_reg[3] <=  user_ctrl_series_out_reg[3];
		endcase


endmodule    