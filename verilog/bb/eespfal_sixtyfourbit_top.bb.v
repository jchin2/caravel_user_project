/// sta-blackbox
(*blackbox*)
module eespfal_sixtyfourbit_top(
`ifdef USE_POWER_PINS	
	inout wire vdda1,
	inout wire GND_GPIO,
`endif
	input wire [bits-1:0] clk_top,
	input wire [bits-1:0] Dis_top,
	input wire [BIT_SIZE-1:0] x_top,
	input wire [BIT_SIZE-1:0] x_bar_top,
	input wire [BIT_SIZE-1:0] k_top,
	input wire [BIT_SIZE-1:0] k_bar_top,

	output wire [BIT_SIZE-1:0] s_top,
	output wire [BIT_SIZE-1:0] s_bar_top,
	input wire Dis_Phase_top
	//inout vdda1,
	//inout GND_GPIO_top
);

parameter bits = 4;
parameter BIT_SIZE = 64;
	
endmodule
