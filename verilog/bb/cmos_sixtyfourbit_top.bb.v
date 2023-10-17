/// sta-blackbox
(*blackbox*)
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

endmodule
