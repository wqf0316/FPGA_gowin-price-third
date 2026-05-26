//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.11.03 (64-bit)
//Part Number: GW5AT-LV138PG484AC1/I0
//Device: GW5AT-138
//Device Version: B
//Created Time: Wed Oct 29 13:53:34 2025

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	Integer_Division_2 your_instance_name(
		.clk(clk), //input clk
		.rstn(rstn), //input rstn
		.dividend(dividend), //input [41:0] dividend
		.divisor(divisor), //input [39:0] divisor
		.quotient(quotient) //output [41:0] quotient
	);

//--------Copy end-------------------
