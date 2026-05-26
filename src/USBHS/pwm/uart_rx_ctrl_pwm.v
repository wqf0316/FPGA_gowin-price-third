module uart_rx_ctrl_pwm(
	fx2_ifclk,
    sys_clk,
    reset_n,
	SW3,
    rx_data,
	rx_done,
	pwm_out,
	user_ctrl_series_out
);
	input fx2_ifclk;
    input sys_clk;
    input reset_n;
	input SW3;
    input [7:0] rx_data;
	input rx_done;
	
	
	output [3:0]	pwm_out;
	output [3:0]	user_ctrl_series_out;
	wire [7:0] series_length;
	wire [23:0] series_set;
    wire [7:0] pwm_select;
    wire [31:0]time_set;
	wire [31:0]full_time_set;
	wire [31:0]high_time_set;

    parameter Baud_Set = 3'd4;
    
	counter_pwm		counter_pwm
	(
		.sys_clk				(sys_clk				),
		.reset_n				(reset_n				),
		.SW3				(SW3				),
		.series_set				(series_set				),
		.series_length			(series_length			),
		.full_time_set       	(full_time_set       	),
		.time_set		    	(time_set		    	),
		.high_time_set       	(high_time_set       	),
		.pwm_select          	(pwm_select          	),
		.pwm_out				(pwm_out				),
		.user_ctrl_series_out	(user_ctrl_series_out	)
	);
	
	
	uart_cmd_pwm	uart_cmd_pwm
	(
		.sys_clk			(fx2_ifclk			)	,
		.reset_n			(reset_n			)	,
		.SW3			(SW3		    )   ,
		.rx_data			(rx_data			)	,
		.rx_done			(rx_done			)	,
		.series_set			(series_set			)	,
		.series_length		(series_length		),
		.full_time_set      (full_time_set      )	,
		.time_set		    (time_set		    )	,
		.high_time_set      (high_time_set      ) 	,
		.pwm_select         (pwm_select         )   
	);
    

endmodule
