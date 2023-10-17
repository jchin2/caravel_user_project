module cmos_sixtyfourbit_top(
`ifdef USE_POWER_PINS	
	inout vdda2,
	inout vssa2,
`endif
	input [BIT_SIZE-1:0] x_top,
	input [BIT_SIZE-1:0] x_bar_top,
	input [BIT_SIZE-1:0] k_top,
	input [BIT_SIZE-1:0] k_bar_top,
	output [BIT_SIZE-1:0] s_top
);

parameter BIT_SIZE = 64;

bitsixtyfour_CMOS_G_VDD lane0 (
`ifdef USE_POWER_PINS	
	.vdda2(vdda2), 
	.vssa2(vssa2),
`endif
	.s(s_top[63:0]),
	.x(x_top[63:0]),
	.x_bar(x_bar_top[63:0]),
	.k(k_top[63:0]),
	.k_bar(k_bar_top[63:0])
);	
endmodule
