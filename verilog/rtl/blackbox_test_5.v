module blackbox_test_5(
`ifdef USE_POWER_PINS	
	inout vdda1,
	inout GND_GPIO,
`endif
	input [bits-1:0] clk_top,
	input [bits-1:0] Dis_top,
	input [BIT_SIZE-1:0] x_top,
	input [BIT_SIZE-1:0] x_bar_top,
	input [BIT_SIZE-1:0] k_top,
	input [BIT_SIZE-1:0] k_bar_top,

	output [BIT_SIZE-1:0] s_top,
	output [BIT_SIZE-1:0] s_bar_top,
	input Dis_Phase_top
	//inout vdda1,
	//inout GND_GPIO_top
);

parameter bits = 4;
parameter BIT_SIZE = 64;

bitsixtyfour_EESPFAL_switch_2 lane0 (
`ifdef USE_POWER_PINS	
	.vdda1(vdda1), 
	.GND_GPIO(GND_GPIO),
`endif
	.s(s_top[63:0]),
	.s_bar(s_bar_top[63:0]),
	.x(x_top[63:0]),
	.x_bar(x_bar_top[63:0]),
	.k(k_top[63:0]),
	.k_bar(k_bar_top[63:0]),
	.CLK(clk_top[3:0]),
	.Dis(Dis_top[3:0]),
	.Dis_Phase(Dis_Phase_top)
	//.vdda1(vdda1),
	//.GND_GPIO(GND_GPIO_top)
);	
endmodule
