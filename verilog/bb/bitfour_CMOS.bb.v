/// sta-blackbox
(*blackbox*)
module bitfour_CMOS (
`ifdef USE_POWER_PINS
	inout  VDD,
	inout  GND,
`endif
    input wire [BIT_SIZE-1:0] x,
    input wire [BIT_SIZE-1:0] x_bar,
    input wire [BIT_SIZE-1:0] k,
    input wire [BIT_SIZE-1:0] k_bar,
    output wire [BIT_SIZE-1:0] s
);

parameter BIT_SIZE = 4;


endmodule
