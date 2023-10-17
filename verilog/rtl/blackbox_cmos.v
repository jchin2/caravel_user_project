module blackbox_cmos(
`ifdef USE_POWER_PINS	
	inout VDD,
	inout GND,
`endif
	input [BIT_SIZE-1:0] x_top,
	input [BIT_SIZE-1:0] x_bar_top,
	input [BIT_SIZE-1:0] k_top,
	input [BIT_SIZE-1:0] k_bar_top,
	output [BIT_SIZE-1:0] s_top
);

parameter BIT_SIZE = 4;

bitfour_CMOS lane0 (
`ifdef USE_POWER_PINS	
	.VDD(VDD),
	.GND(GND),
`endif
	.s(s_top[3:0]),
	.x(x_top[3:0]),
	.x_bar(x_bar_top[3:0]),
	.k(k_top[3:0]),
	.k_bar(k_bar_top[3:0])
);	
endmodule
