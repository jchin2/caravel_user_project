/// sta-blackbox
(*blackbox*)
module bitfour_EESPFAL (
`ifdef USE_POWER_PINS
	inout wire VDD,
	inout wire GND,
`endif
  	input wire [BIT_SIZE-1:0] CLK,
    input wire [BIT_SIZE-1:0] Dis,
    input wire [BIT_SIZE-1:0] x,
    input wire [BIT_SIZE-1:0] x_bar,
    input wire [BIT_SIZE-1:0] k,
    input wire [BIT_SIZE-1:0] k_bar,
    output wire [BIT_SIZE-1:0] s,
    output wire [BIT_SIZE-1:0] s_bar,
    inout wire some_GND
);

parameter BIT_SIZE = 4;


endmodule

