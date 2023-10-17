/// sta-blackbox
(*blackbox*)
module bitsixtyfour_CMOS_G_VDD (
//Commented out the ifdef and endif block for make blackbox_test_4 
`ifdef USE_POWER_PINS  
	inout wire vdda2,
	inout wire vssa2,
`endif
    input wire [BIT_SIZE-1:0] x,
    input wire [BIT_SIZE-1:0] x_bar,
    input wire [BIT_SIZE-1:0] k,
    input wire [BIT_SIZE-1:0] k_bar,
    output wire [BIT_SIZE-1:0] s
    
//comment these out as well when you go back to make blackbox_test_3 or needing the use_power_pins block
//   	inout wire vdda1,
//  	inout wire GND_GPIO
);

parameter BIT_SIZE = 64;

endmodule

