/// sta-blackbox
(*blackbox*)
module bitfour_EESPFAL_switch_2 (
//Commented out the ifdef and endif block for make blackbox_test_4 
`ifdef USE_POWER_PINS  
	inout wire vdda1,
	inout wire GND_GPIO,
`endif
  	input wire [BIT_SIZE-1:0] CLK,
    input wire [BIT_SIZE-1:0] Dis,
    input wire [BIT_SIZE-1:0] x,
    input wire [BIT_SIZE-1:0] x_bar,
    input wire [BIT_SIZE-1:0] k,
    input wire [BIT_SIZE-1:0] k_bar,
    output wire [BIT_SIZE-1:0] s,
    output wire [BIT_SIZE-1:0] s_bar,
    input wire Dis_Phase,
    
//comment these out as well when you go back to make blackbox_test_3 or needing the use_power_pins block
//   inout wire vdda1,
//   inout wire GND_GPIO
);

parameter BIT_SIZE = 4;


endmodule

