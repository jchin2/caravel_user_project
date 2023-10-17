module blackbox_test_2(
`ifdef USE_POWER_PINS	
	inout VDD,
	inout GND,
`endif
	input [BIT_SIZE-1:0] clk_top,
	input [BIT_SIZE-1:0] dis_top,
	input [BIT_SIZE-1:0] x_top,
	input [BIT_SIZE-1:0] x_bar_top,
	input [BIT_SIZE-1:0] k_top,
	input [BIT_SIZE-1:0] k_bar_top,

	output [BIT_SIZE-1:0] s_top,
	output [BIT_SIZE-1:0] s_bar_top,
	input Dis_Phase_top,
	inout GND_GPIO_top
);

parameter BIT_SIZE = 4;

bitfour_EESPFAL_switch lane0 (
`ifdef USE_POWER_PINS	
	.VDD(VDD), //Floating VDD pin to trick OpenLane
	.GND(GND),
`endif
	.s(s_top[3:0]),
	.s_bar(s_bar_top[3:0]),
	.x(x_top[3:0]),
	.x_bar(x_bar_top[3:0]),
	.k(k_top[3:0]),
	.k_bar(k_bar_top[3:0]),
	.CLK(clk_top[3:0]),
	.Dis(dis_top[3:0]),
	.Dis_Phase(Dis_Phase_top),
	.GND_GPIO(GND_GPIO_top)
);	
endmodule
