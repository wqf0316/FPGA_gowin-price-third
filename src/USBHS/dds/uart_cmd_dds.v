`timescale 1ns/1ns

module uart_cmd_dds(
	sw4_state,
    sys_clk,
    reset_n,
    rx_data,
    rx_done,
	wave_select_1 	,
	wave_select_2 	,
	freq_ctrl_1		,
	phase_ctrl_1 	,
	freq_ctrl_2		,
	phase_ctrl_2 	
);
    input	sw4_state;
    input sys_clk;
    input reset_n;
    input [7:0]rx_data;
    input rx_done;
	output  reg  	[4:0]   	wave_select_1 	;   //输出channel1波形选择
	output  reg  	[4:0]   	wave_select_2 	;   //输出channel2波形选择
	output	reg		[31:0]		freq_ctrl_1		;
	output	reg		[31:0]		phase_ctrl_1 	;
	output	reg		[31:0]		freq_ctrl_2		;
	output	reg		[31:0]		phase_ctrl_2 	;

	reg	[7:0]	select;//输出通道和波形选择控制信号
	reg	[31:0]	fre_ctrl;//频率控制信号
	reg	[31:0]	phase_ctrl; // 初相位控制信号
    reg [7:0] data_str [11:0];
	reg uart_channel1_useable;
	reg uart_channel2_useable;
	reg finish_flag;
    always@(posedge sys_clk or negedge reset_n)	begin
		if(!reset_n) begin
			wave_select_1 <= 5'b0_0001;
			wave_select_2 <= 5'b0_0001;
			freq_ctrl_1   <= 0;
			freq_ctrl_2   <= 0;
			phase_ctrl_1  <= 0;
			phase_ctrl_2  <= 0;
			end
		else	if(sw4_state == 0) begin
			wave_select_1 <= 5'b0_0001;
			wave_select_2 <= 5'b0_0001;
			freq_ctrl_1   <= 32'd858994;//默认输出频率10kHz
			freq_ctrl_2   <= 32'd858994;//默认输出频率10kHz
			phase_ctrl_1  <= 32'd0;
			phase_ctrl_2  <= 32'd0;
			end
		else	if(select[5] == 0) begin
			wave_select_1 <= select[4:0];
			freq_ctrl_1   <= fre_ctrl;
			phase_ctrl_1  <= phase_ctrl;
			wave_select_2 <= wave_select_2;
			freq_ctrl_2   <= freq_ctrl_2;
			phase_ctrl_2  <= phase_ctrl_2;
			end
		else	if(select[5] == 1) begin
			wave_select_1 <= wave_select_1;
			freq_ctrl_1   <= freq_ctrl_1;
			phase_ctrl_1  <= phase_ctrl_1;
			wave_select_2 <= select[4:0];
			freq_ctrl_2   <= fre_ctrl;
			phase_ctrl_2  <= phase_ctrl;
			end		
/* 		else	begin
			wave_select_1 <= wave_select_1;
			freq_ctrl_1   <= freq_ctrl_1;
			phase_ctrl_1  <= phase_ctrl_1;
			wave_select_2 <= wave_select_2;
			freq_ctrl_2   <= freq_ctrl_2;
			phase_ctrl_2  <= phase_ctrl_2;
					end */
	end
    always@(posedge sys_clk)
	if((!reset_n) | (!sw4_state)) begin
		data_str[11] <=  8'b0;
        data_str[10] <=  8'b0;
        data_str[9]  <=  8'b0;
        data_str[8]  <=  8'b0;
        data_str[7]  <=  8'b0;
        data_str[6]  <=  8'b0;
        data_str[5]  <=  8'b0;
        data_str[4]  <=  8'b0;
        data_str[3]  <=  8'b0;
        data_str[2]  <=  8'b0;
        data_str[1]  <=  8'b0;
        data_str[0]  <=  8'b0;end
    else if(rx_done)begin
		data_str[11] <=  rx_data;
        data_str[10] <=  data_str[11];
        data_str[9]  <=  data_str[10];
        data_str[8]  <=  data_str[9];
        data_str[7]  <=  data_str[8];
        data_str[6]  <=  data_str[7];
        data_str[5]  <=  data_str[6];
        data_str[4]  <=  data_str[5];
        data_str[3]  <=  data_str[4];
        data_str[2]  <=  data_str[3];
        data_str[1]  <=  data_str[2];
        data_str[0]  <=  data_str[1];        
    end
    
    reg r_rx_done;
    always@(posedge sys_clk)
        r_rx_done <= rx_done;
    
    always@(posedge sys_clk or negedge reset_n)
    if(!reset_n) begin
        fre_ctrl <= 32'd858994;//默认输出频率10kHz
		phase_ctrl <= 0;//默认初始相位为0
		select <= 8'b0010_0001;
		finish_flag <= 0;
    end else if(r_rx_done)begin
        if((data_str[0] == 8'h55) && (data_str[1] == 8'hA5) && (data_str[11] == 8'hF0))begin
            select <=  data_str[2];
			fre_ctrl[31:24] <=  data_str[3];
            fre_ctrl[23:16] <=  data_str[4];
            fre_ctrl[15:8] 	<=  data_str[5];
            fre_ctrl[7:0] 	<=  data_str[6];
			phase_ctrl[31:24] 	<=  data_str[7];
            phase_ctrl[23:16] 	<=  data_str[8];
            phase_ctrl[15:8] 	<=  data_str[9];
            phase_ctrl[7:0] 	<=  data_str[10];
			finish_flag <= 1;
        end
		else
			finish_flag <= 0;
/* 		else	begin
	    fre_ctrl <= 32'd858994;//默认输出频率10kHz
		phase_ctrl <= 0;//默认初始相位为0
		//select <= 8'b0010_0001;
		end */
    end    
    
endmodule
